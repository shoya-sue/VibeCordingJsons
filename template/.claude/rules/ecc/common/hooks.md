# Hooks System

## Hook Types (handlers)

| タイプ | 説明 |
|--------|------|
| `command` | シェルコマンドを実行 |
| `http` | JSON を URL に POST（v2.1.69+） |
| `prompt` | Claude へのシングルターン評価（v2.1.85+） |
| `agent` | サブエージェントを起動してツール操作（v2.1.85+） |
| `mcp_tool` | MCP ツールを直接呼び出し（v2.1.118+） |

## All Hook Events (26 events)

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
| `Stop` | 応答完了時 | Yes |
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
