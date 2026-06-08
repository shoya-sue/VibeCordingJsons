# Hooks System

## Hook Types (handlers)

| タイプ | 説明 |
|--------|------|
| `command` | シェルコマンドを実行 |
| `http` | JSON を URL に POST（v2.1.69+） |
| `prompt` | Claude へのシングルターン評価（v2.1.85+） |
| `agent` | サブエージェントを起動してツール操作（v2.1.85+） |
| `mcp_tool` | MCP ツールを直接呼び出し（v2.1.118+） |

> `SessionStart` / `Setup` / `SubagentStart` には `command` 型しか設定できない（`prompt` / `agent` 型を設定すると v2.1.142+ で明示的エラー）。

## All Hook Events (27 events)

| イベント | タイミング | ブロッキング |
|---------|-----------|-------------|
| `SessionStart` | セッション開始時 | No |
| `UserPromptSubmit` | プロンプト送信前 | Yes |
| `PreToolUse` | ツール実行前 | Yes |
| `PostToolUse` | ツール実行後 | No |
| `PostToolUseFailure` | ツール実行失敗後 | No |
| `PermissionRequest` | 権限確認時 | No |
| `PermissionDenied` | 権限拒否時（`retry: true` 返却可） | No |
| `Notification` | 通知発生時 | No |
| `SubagentStart` | サブエージェント開始時 | No |
| `SubagentStop` | サブエージェント停止時 | Yes |
| `Stop` | 応答完了時（8 連続ブロックで自動終了、`CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` で変更、v2.1.143+） | Yes |
| `StopFailure` | Stop フック失敗時 | No |
| `TeammateIdle` | チームメイト待機時 | No |
| `TaskCreated` | タスク作成時 | Yes |
| `TaskCompleted` | タスク完了時 | No |
| `ConfigChange` | 設定変更時 | No |
| `CwdChanged` | カレントディレクトリ変更時 | No |
| `FileChanged` | ファイル変更検知時 | No |
| `WorktreeCreate` | ワークツリー作成時（`type:"http"` で `worktreePath` 返却可、v2.1.84+） | No |
| `WorktreeRemove` | ワークツリー削除時 | No |
| `PreCompact` | コンテキスト圧縮前 | No |
| `PostCompact` | コンテキスト圧縮後 | No |
| `Elicitation` | MCP サーバーが構造化入力を要求時 | Yes |
| `ElicitationResult` | MCP Elicitation 応答後 | No |
| `InstructionsLoaded` | 設定ファイル読み込み時 | No |
| `MessageDisplay` | アシスタントメッセージ表示直前（テキストを変換/非表示にできる、v2.1.152+） | Yes |
| `SessionEnd` | セッション終了時 | No |

## Advanced Features

### Conditional Filtering (`if` field, v2.1.85+)

```jsonc
{
  "matcher": "Bash",
  "if": "Bash(git *)",   // 権限ルール構文でフィルタ
  "hooks": [...]
}
```

### Input Modification (`returnPolicy`, v2.1.85+)

```jsonc
{
  "type": "command",
  "command": "...",
  "returnPolicy": "updatedInput"   // PreToolUse でインプット変更
}
```

### PreToolUse `defer` 権限決定 (v2.1.89+)

```jsonc
// PreToolUse フックから "defer" を返すと通常の権限確認フローに委ねる
{ "decision": "defer" }
```

### UserPromptSubmit セッションタイトル設定 (v2.1.94+)

```jsonc
// UserPromptSubmit フックから sessionTitle を返すとセッションタイトルを設定
{
  "hookSpecificOutput": {
    "sessionTitle": "My Session Title"
  }
}
```

### PostToolUse `duration_ms` 入力 (v2.1.119+)

PostToolUse/PostToolUseFailure フックの入力 JSON に `duration_ms`（ツール実行時間、ms）が含まれる。
権限確認と PreToolUse フック実行時間は除外される。パフォーマンス監視系フックで利用可能。

### PostToolUse ツール出力置換（v2.1.121+）

PostToolUse フックから `hookSpecificOutput.updatedToolOutput` を返すと、
全ツール（Bash、Read、MCP ツール等）のツール出力を Claude に見せる内容に置換できる。
v2.1.121 以前は MCP ツールのみ対応。

```jsonc
// PostToolUse フックから返すと Claude が見るツール出力を差し替え
{
  "hookSpecificOutput": {
    "updatedToolOutput": "sanitized or augmented output here"
  }
}
```

### コマンド exec 形式 (`args: string[]`, v2.1.139+)

`args` フィールドを使うとシェルを経由せず直接実行（パスにスペースがあってもクォート不要）:

```jsonc
{
  "type": "command",
  "args": ["node", "/path/to/script.js"],   // シェルなし直接起動
  "timeout": 10
}
```

### PostToolUse `continueOnBlock` (v2.1.139+)

PostToolUse フックがブロック（`"continue": false`）したとき、デフォルトはターンを終了。
`continueOnBlock: true` を設定するとブロック理由を Claude に返してターンを継続できる:

```jsonc
{
  "matcher": "Write|Edit",
  "continueOnBlock": true,
  "hooks": [...]
}
```

### Hook Input: `effort.level` フィールドと `$CLAUDE_EFFORT` 環境変数 (v2.1.133+)

すべてのフック入力 JSON に `effort.level` フィールドが含まれる。
`command` 型フックおよび Bash サブプロセスでは `$CLAUDE_EFFORT` 環境変数として参照可能。

値: `"low"` / `"medium"` / `"high"` / `"xhigh"`

```jsonc
// command フック内で現在の effort レベルに応じて挙動を切り替える例
{
  "type": "command",
  "command": "echo \"effort=$CLAUDE_EFFORT\""
}
```

### フック出力 `terminalSequence` フィールド (v2.1.141+)

フック JSON 出力に `terminalSequence` フィールドを返すと、ターミナルを乗っ取らずに
デスクトップ通知・ウィンドウタイトル・ベル等のエスケープシーケンスを発行できる。
通知系・ステータス可視化系フックでスクリーン更新を干渉せずに使える。

```jsonc
// 例: ターン完了時にデスクトップ通知（OSC 9）とウィンドウタイトル更新（OSC 2）を行う
{
  "hookSpecificOutput": {
    "terminalSequence": "]9;Task complete]2;claude:done"
  }
}
```

### SessionStart hook 拡張: `reloadSkills` / `sessionTitle` (v2.1.152+)

`SessionStart` フックは以下 2 フィールドを返せる:

- `reloadSkills: true` — フックが新規 skill を install した直後、現セッションで再スキャンして利用可能化
- `hookSpecificOutput.sessionTitle` — 開始/再開時のセッションタイトル設定（`UserPromptSubmit` 版 v2.1.94+ と同形式）

```jsonc
// SessionStart フックから返すと現セッションで新規 skill を即時利用可能 + タイトル設定
{
  "reloadSkills": true,
  "hookSpecificOutput": {
    "sessionTitle": "Onboarding flow"
  }
}
```

### Skill / Slash command の `disallowed-tools` frontmatter (v2.1.152+)

Skill / slash command の frontmatter に `disallowed-tools` を指定すると、そのスキル/コマンドがアクティブな間だけモデルから特定ツールを取り除ける。`allowed-tools` のホワイトリスト指定と対比してブラックリスト指定が可能になった。

```yaml
---
name: read-only-audit
description: 監査用に書き込み系ツールを封じる
allowed-tools: ["Read", "Glob", "Grep"]
disallowed-tools: ["Bash"]
---
```

### Stop / SubagentStop フック入力: `background_tasks` と `session_crons` フィールド (v2.1.145+)

Stop / SubagentStop フックの入力 JSON に以下 2 フィールドが含まれる:

- `background_tasks` — 現在実行中のバックグラウンドタスク（`claude --bg` で起動した bg セッションや subagent が spawn した Bash bg プロセス）の配列
- `session_crons` — このセッションでスケジュールされた cron / 定期実行ジョブの配列

`claude --bg` のメインストリーム化に伴い、応答完了時に未完了 bg タスクの有無を判定したり、cron 設定をログ出力したりするユースケースで利用できる。

```jsonc
// 入力 JSON 例（抜粋）
{
  "background_tasks": [/* 実行中の bg タスク */],
  "session_crons":   [/* スケジュール済み cron */]
}
```

### Stop / SubagentStop フック出力: `additionalContext` フィールド (v2.1.163+)

Stop / SubagentStop フックから `hookSpecificOutput.additionalContext` を返すと、
エラーラベルなしで Claude に追加コンテキスト（フィードバック）を渡せる。
従来の block（`decision: "block"` + reason）はエラー扱いの表示になるのに対し、
こちらは非エラーで文脈注入のみを行う。

```jsonc
// Stop フックから返すと非エラーで Claude にフィードバックを渡せる
{
  "hookSpecificOutput": {
    "additionalContext": "未コミットの変更が 3 ファイル残っています"
  }
}
```

## Auto-Accept Permissions

Use with caution:
- Enable for trusted, well-defined plans
- Disable for exploratory work
- Never use dangerously-skip-permissions flag
- Configure `allowedTools` in `~/.claude.json` instead

## TodoWrite Best Practices

Use TodoWrite tool to:
- Track progress on multi-step tasks
- Verify understanding of instructions
- Enable real-time steering
- Show granular implementation steps

Todo list reveals:
- Out of order steps
- Missing items
- Extra unnecessary items
- Wrong granularity
- Misinterpreted requirements
