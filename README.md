# VibeCording Settings

Claude Code と GitHub Copilot CLI のベストプラクティステンプレート集。
`settings.json` / `.mcp.json` / `CLAUDE.md` / `AGENTS.md` / Skills / Agents / Rules / VSCode ワークスペース設定を一式提供。

## 使い方

### グローバルインストール（個人利用におすすめ）

ホームディレクトリにインストールすると、**全プロジェクトに自動適用**されます。
プロジェクトごとの設定ファイルは不要です。

```bash
git clone https://github.com/shoya-sue/VibeCordingJsons.git
cd VibeCordingJsons
./install.sh full ~
```

これだけで `~/.claude/settings.json` にフル設定が入り、以降どのプロジェクトで `claude` を起動しても同じ設定が使われます。
プロジェクト固有の設定が必要になった場合のみ、そのプロジェクトの `.claude/settings.json` を追加してください（配列設定はマージ、単一値設定は上書き）。

### プロジェクトインストール（チーム開発向け）

チームで共有する設定をプロジェクトに配置する場合：

```bash
./install.sh standard /path/to/your/project
```

### GitHub 上で手動コピー

使いたいパターンのディレクトリを開き、各ファイルの中身をコピー。

## 3つのパターン

| パターン | 用途 | 含まれるファイル |
|---------|------|-----------------|
| **[Minimal](minimal/)** | コードレビュー・探索のみ | `.claude/settings.json`, `CLAUDE.md`, `AGENTS.md`, VSCode workspace |
| **[Standard](standard/)** | 日常の開発作業（**推奨**） | 上記 + `.mcp.json`, Skills, Rules |
| **[Full](full/)** | 全機能活用 | 上記 + Agents, Sandbox, Agent Teams, Auto Start |

各ディレクトリの README に詳細なコピー先とインストール手順があります。

## settings.json vs settings.local.json

| ファイル | 用途 | Git 管理 |
|---------|------|---------|
| `settings.json` | チーム共有のベースライン設定 | する |
| `settings.local.json` | 個人用の上書き（モデル選択、追加権限等） | しない（gitignore） |

`settings.local.json` は `settings.json` の設定を上書きします。
同様に `CLAUDE.md`（チーム共有）と `CLAUDE.local.md`（個人用）の対応があります。

## パターン比較

| 機能 | Minimal | Standard | Full |
|------|---------|----------|------|
| **Claude Code** | | | |
| ファイル読み取り | src/tests/docs | src/tests/docs + 設定ファイル | 全ファイル |
| ファイル書き込み | **不可** | src/tests/docs | 主要ディレクトリ |
| git 操作 | 参照のみ | add/commit まで | 全操作 |
| permissions.ask | なし | git push, npm publish | + docker/terraform/kubectl |
| パッケージマネージャー | **不可** | npm/yarn/pnpm/bun | 同左 |
| テスト実行 | **不可** | pytest/cargo/go | 同左 |
| Docker / K8s | **不可** | **不可** | docker/kubectl |
| MCP サーバー | **不可** | 4サーバー | 5サーバー + 全許可 |
| Skills | **不可** | explain-code, generate-changelog, create-issue | + fix-issue, review-pr, dependency-audit |
| Agents | なし | なし | code-reviewer, test-runner |
| Rules | なし | code-style | + api-conventions |
| Hooks | なし | 5イベント（ログ） | 全21イベント + macOS 通知 |
| Sandbox | なし | なし | 有効（network 制御付き） |
| Agent Teams | なし | なし | 有効 |
| Attribution | なし | コミット・PR 署名 | 同左 |
| **Copilot CLI** | | | |
| copilot-instructions.md | 読み取り専用指示 | 標準開発指示 | 全機能指示 |
| Skills | なし | explain-code, code-reviewer | + fix-issue, review-pr, test-runner |
| Agents | なし | なし | code-reviewer, github-workflow, code-explorer, test-runner |
| AGENTS.md | ✅ | ✅ | ✅ |
| **VSCode Workspace** | | | |
| エディタ設定 | 基本（formatOnSave, tabSize） | 全設定（autoSave, git, search） | 同左 + minimap: off |
| 拡張機能 | Copilot のみ | + GitLens, Prettier, ESLint, EditorConfig | + Docker |
| Claude Code タスク | なし | バックグラウンドタスク 1個 | + Auto Start（folderOpen） |
| ランチ構成テンプレート | なし | なし | 空テンプレート付き |

## AI エージェントが読み込む指示ファイル

各 AI ツールが自動で読み込む指示ファイルの一覧：

| ファイル | Claude Code | Copilot CLI | Gemini CLI | 用途 |
|---------|------------|-------------|------------|------|
| `CLAUDE.md` | ✅ | ✅ | — | Claude Code 向け詳細指示 |
| `AGENTS.md` | — | ✅ | ✅ | 汎用 AI エージェント指示 |
| `.github/copilot-instructions.md` | — | ✅ | — | Copilot プロジェクト指示 |
| `~/.copilot/copilot-instructions.md` | — | ✅ | — | Copilot ユーザーレベル指示 |
| `~/.claude/CLAUDE.md` | ✅ | — | — | Claude Code グローバル指示 |

**推奨配置**: `CLAUDE.md`（Claude Code 専用）と `AGENTS.md`（汎用）の両方をプロジェクトルートに配置。
`~/.copilot/copilot-instructions.md` にユーザーレベルの設定を置くと全プロジェクトに適用されます。

## ディレクトリ構成

```text
.
├── minimal/
│   ├── .claude/
│   │   ├── settings.json
│   │   └── settings.local.json
│   ├── .github/
│   │   └── copilot-instructions.md
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   ├── CLAUDE.local.md
│   ├── project.code-workspace
│   └── README.md
├── standard/
│   ├── .claude/
│   │   ├── settings.json
│   │   ├── settings.local.json
│   │   ├── skills/explain-code/SKILL.md
│   │   └── rules/code-style.md
│   ├── .github/
│   │   ├── copilot-instructions.md
│   │   └── skills/
│   │       ├── explain-code/SKILL.md
│   │       └── code-reviewer/SKILL.md
│   ├── .mcp.json
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   ├── CLAUDE.local.md
│   ├── project.code-workspace
│   └── README.md
├── full/
│   ├── .claude/
│   │   ├── settings.json
│   │   ├── settings.local.json
│   │   ├── skills/
│   │   │   ├── explain-code/SKILL.md
│   │   │   ├── fix-issue/SKILL.md
│   │   │   ├── review-pr/SKILL.md
│   │   │   ├── generate-changelog/SKILL.md
│   │   │   └── dependency-audit/SKILL.md
│   │   ├── agents/
│   │   │   ├── code-reviewer.md
│   │   │   └── test-runner.md
│   │   └── rules/
│   │       ├── code-style.md
│   │       └── api-conventions.md
│   ├── .github/
│   │   ├── copilot-instructions.md
│   │   ├── skills/
│   │   │   ├── explain-code/SKILL.md
│   │   │   ├── code-reviewer/SKILL.md
│   │   │   ├── fix-issue/SKILL.md
│   │   │   ├── review-pr/SKILL.md
│   │   │   ├── test-runner/SKILL.md
│   │   │   ├── create-issue/SKILL.md
│   │   │   ├── generate-changelog/SKILL.md
│   │   │   └── dependency-audit/SKILL.md
│   │   └── agents/
│   │       ├── code-reviewer.agent.md
│   │       ├── github-workflow.agent.md
│   │       ├── code-explorer.agent.md
│   │       └── test-runner.agent.md
│   ├── .mcp.json
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   ├── CLAUDE.local.md
│   ├── project.code-workspace
│   └── README.md
├── install.sh
├── .claude/settings.json
├── .mcp.json
├── AGENTS.md
├── CLAUDE.md
├── LICENSE
└── README.md
```

## settings.json 設定項目一覧

### permissions（権限制御 — 3段階）

```jsonc
{
  "permissions": {
    "allow": [...],  // 自動許可
    "ask": [...],    // 毎回確認（allow と deny の中間）
    "deny": [...]    // 常に拒否
  }
}
```

対応パターン:

| パターン | 説明 | 例 |
|---------|------|-----|
| `Read(glob)` | ファイル読み取り | `Read(src/**)` |
| `Write(glob)` | ファイル書き込み | `Write(src/**)` |
| `Edit(glob)` | ファイル編集 | `Edit(**/*.ts)` |
| `Bash(pattern)` | シェルコマンド | `Bash(git *)` |
| `mcp__server__tool` | MCP ツール | `mcp__context7__*` |
| `Skill(pattern)` | スキル実行 | `Skill(explain-code:*)` |
| `MCPSearch` | MCP 検索 | `MCPSearch` |

### hooks（イベントフック — 全21イベント対応）

4種類のフックタイプ: `command`（シェル）、`http`（HTTP リクエスト）、`prompt`（LLM 判定）、`agent`（サブエージェント）

```jsonc
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "echo 'Before bash'", "timeout": 10 },
          // HTTP hooks: 外部 URL に JSON を POST（v2.1.69+）
          { "type": "http", "url": "http://localhost:3000/hooks/pre-tool", "timeout": 5 }
        ]
      }
    ]
  }
}
```

全イベント一覧:

| イベント | タイミング | ブロック可能 |
|---------|-----------|------------|
| `SessionStart` | セッション開始 | No |
| `UserPromptSubmit` | プロンプト送信前 | Yes |
| `PreToolUse` | ツール実行前 | Yes |
| `PostToolUse` | ツール実行後 | No |
| `PostToolUseFailure` | ツール実行失敗後 | No |
| `PermissionRequest` | 権限確認時 | No |
| `Notification` | 通知発行時 | No |
| `SubagentStart` | サブエージェント開始時 | No |
| `SubagentStop` | サブエージェント停止時 | Yes |
| `Stop` | レスポンス停止時 | Yes |
| `TeammateIdle` | チームメイト待機時 | No |
| `TaskCompleted` | タスク完了時 | No |
| `ConfigChange` | 設定変更時 | No |
| `WorktreeCreate` | ワークツリー作成時 | No |
| `WorktreeRemove` | ワークツリー削除時 | No |
| `PreCompact` | コンテキスト圧縮前 | No |
| `PostCompact` | コンテキスト圧縮後 | No |
| `Elicitation` | MCP サーバーが構造化入力を要求時 | Yes |
| `ElicitationResult` | MCP Elicitation の応答後 | No |
| `InstructionsLoaded` | 指示ファイル読込時 | No |
| `SessionEnd` | セッション終了時 | No |

**timeout の単位**: 秒（例: `"timeout": 10` → 10秒）

### env（環境変数）

| 変数 | 説明 | 推奨値 |
|------|------|--------|
| `MCP_TIMEOUT` | MCP タイムアウト (ms) | `10000`-`15000` |
| `MAX_MCP_OUTPUT_TOKENS` | MCP 出力上限トークン | `25000`-`50000` |
| `BASH_MAX_TIMEOUT_MS` | Bash タイムアウト (ms) | `120000`-`300000` |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 出力トークン上限（Opus 4.6: 最大128k） | `64000` |
| `ENABLE_TOOL_SEARCH` | ツール検索の有効化 | `auto` |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | コンテキスト自動圧縮 (%) | `50` |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Agent Teams 有効化 | `1` |
| `CLAUDE_CODE_AUTO_MEMORY_PATH` | 自動メモリ保存先パス | `""` (デフォルト) |
| `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` | SessionEnd フックのタイムアウト (ms) | `5000` |
| `CLAUDE_CODE_DISABLE_CRON` | `/loop` のスケジュール実行を無効化 | `1` |
| `CLAUDE_CODE_SIMPLE` | 最小モード（Skills/Memory/Hooks/MCP 無効） | `1` |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | 組み込み git 指示を無効化 | `1` |
| `MAX_THINKING_TOKENS` | 思考トークン上限 | モデル依存 |

### その他の設定項目

| 項目 | 説明 |
|------|------|
| `$schema` | IDE での自動補完を有効化 |
| `model` | デフォルトモデルの指定 |
| `language` | 応答言語（`"japanese"` 等） |
| `autoMemoryEnabled` | 自動メモリ機能の有効/無効（デフォルト: `true`） |
| `attribution` | コミット・PR への署名テキスト |
| `sandbox` | Bash サンドボックス（enabled, autoAllowBashIfSandboxed, excludedCommands, network） |
| `teammateMode` | Agent Teams 表示モード（`auto` / `in-process` / `tmux`） |
| `autoMemoryDirectory` | 自動メモリの保存先ディレクトリ |
| `modelOverrides` | モデルピッカーのエントリを別のモデル ID にマッピング |
| `includeGitInstructions` | 組み込みの git commit/PR 指示の有効/無効 |
| `worktree.sparsePaths` | `--worktree` 使用時に sparse-checkout するパス |
| `enableAllProjectMcpServers` | `.mcp.json` のサーバー自動有効化 |
| `enabledPlugins` | プラグインの有効/無効（例: `{"formatter@acme-tools": true}`） |

## 設定の階層

Claude Code は以下の優先順位で設定を適用する（上ほど優先）:

1. CLI 引数（セッション限定）
2. `.claude/settings.local.json`（個人用、gitignore 推奨）
3. `.claude/settings.json`（チーム共有、Git 管理）
4. `~/.claude/settings.local.json`（グローバル個人用）
5. `~/.claude/settings.json`（グローバルデフォルト）

**グローバル設定のカスケード**: `~/.claude/settings.json` に設定すれば、プロジェクト側に `.claude/settings.json` がなくても全プロジェクトに自動適用される。個人利用であればグローバル設定だけで十分。

**マージルール**:
- **単一値**（`model`, `language` 等）→ 上位が完全に上書き
- **配列値**（`permissions.allow`, `deny` 等）→ 全レベルの値がマージされる

## VSCode ワークスペース設定

各パターンに `project.code-workspace` を同梱。VSCode の「ファイル > ワークスペースを開く」で読み込み可能。

### パターン別の機能

| 機能 | Minimal | Standard | Full |
|------|---------|----------|------|
| エディタ設定 | formatOnSave, tabSize: 2 | + autoSave, search/watcher excludes | + minimap: off, vendor excludes |
| 拡張機能推奨 | Copilot, Copilot Chat | + GitLens, Prettier, ESLint, EditorConfig | + Docker |
| Claude Code タスク | — | `🟩 Claude Code` (バックグラウンド) | + `🚀 Auto Start` (フォルダ開放時自動起動) |
| ランチ構成 | — | — | 空テンプレート |

### Claude Code バックグラウンドタスク

Standard / Full パターンでは、VSCode タスクとして Claude Code をバックグラウンド起動できます。

```jsonc
// project.code-workspace 内のタスク定義（抜粋）
{
  "label": "🟩 Claude Code",
  "type": "shell",
  "command": "claude -c || claude",
  "isBackground": true,
  "options": {
    "shell": { "executable": "/bin/zsh", "args": ["-l", "-c"] }
  }
}
```

- **Standard**: `Cmd+Shift+P` → `Tasks: Run Task` → `🟩 Claude Code` で手動起動
- **Full**: フォルダを開くと自動的に Claude Code ターミナルが起動（`runOn: folderOpen`）

### マルチプロジェクト構成

Full パターンの `project.code-workspace` を編集して、複数プロジェクトの Claude Code を並行管理できます。

```jsonc
{
  "folders": [
    { "path": ".", "name": "frontend" },
    { "path": "../backend", "name": "backend" }
  ],
  "tasks": {
    "tasks": [
      { "label": "🟦 Frontend Claude", "command": "cd ${workspaceFolder:frontend} && claude -c || claude", ... },
      { "label": "🟩 Backend Claude", "command": "cd ${workspaceFolder:backend} && claude -c || claude", ... }
    ]
  }
}
```

`presentation.group` でタスクパネルの色分けも可能です（詳細は `full/README.md` を参照）。

## モデル選択とコスト最適化

Claude Code では `/model` コマンドでセッション中にモデルを切り替えられます。

| モデルエイリアス | 説明 | 推奨シーン |
|-----------------|------|-----------|
| `opus` | Opus 4.6（最高性能） | 複雑なアーキテクチャ設計 |
| `sonnet` | Sonnet 4.6（バランス型） | 日常の開発作業 |
| `haiku` | Haiku 4.5（高速・低コスト） | 簡単な質問・コードレビュー |
| **`opusplan`** | **Opus で計画 → Sonnet で実行（自動切替）** | **コスト最適化の推奨設定** |

**`/model opusplan` のワークフロー**:
1. Plan モード（Shift+Tab）で Opus 4.6 が複雑な思考・設計を担当
2. プラン確定後、自動で Sonnet 4.6 に切り替わり実装を実行
3. サブスクリプションの週間クォータを節約しつつ、高品質な計画を維持

`settings.local.json` で `"model": "opusplan"` を設定すればデフォルトで有効化。

### エフォートレベル

`/effort` コマンドでモデルの思考量を制御できます:

| レベル | シンボル | 用途 |
|--------|---------|------|
| `low` | ○ | 簡単なタスク、クイック応答 |
| `medium` | ◐ | 通常の開発作業（Opus 4.6 デフォルト） |
| `high` | ● | 複雑な推論、深い分析 |
| `auto` | — | デフォルトにリセット |

「ultrathink」とメッセージに含めると、次のターンだけ high effort が有効になります。

## ベストプラクティス

- **最小権限**: 必要な権限だけを `allow` に記載する
- **ask を活用**: push / publish 等は `ask` で毎回確認
- **明示的拒否**: 危険な操作は `deny` で明示的にブロック
- **`/model opusplan` を活用**: 計画は Opus、実装は Sonnet で自動切替してコスト最適化
- **MCP は 4-5 個**: 多すぎると起動が遅くなり逆効果
- **CLAUDE.md は 150 行以内**: コンテキストに確実に含まれる
- **secrets は書かない**: `.env` や API キーを settings.json に入れない
- **Hooks 活用**: ファイル変更通知やコマンドログで作業を可視化
- **Sandbox 有効化**: 信頼できる環境でも sandbox で安全性を担保
- **`--dangerously-skip-permissions` は使わない**: セキュリティリスク大
- **CLAUDE.md + AGENTS.md の両方を配置**: Claude Code と Copilot CLI の両方をカバー
- **project.code-workspace を活用**: エディタ設定・拡張機能・Claude Code タスクをチームで統一
- **`/memory` で自動メモリを管理**: Claude が保存したコンテキストを定期的に確認・整理
- **`/effort` でコスト制御**: 簡単なタスクには `low`、複雑な設計には `high` を使い分け
- **HTTP hooks で外部連携**: `type: "http"` で Slack 通知や CI トリガーなど外部サービスと連携
- **Agent の `resume` は廃止**: v2.1.77 で `SendMessage({to: agentId})` に移行（破壊的変更）

## 参考

### Claude Code
- [Claude Code 公式ドキュメント](https://code.claude.com/docs/en/overview)
- [Settings](https://code.claude.com/docs/en/settings)
- [Permissions](https://code.claude.com/docs/en/permissions)
- [Hooks リファレンス](https://code.claude.com/docs/en/hooks)
- [Hooks ガイド](https://code.claude.com/docs/en/hooks-guide)
- [Skills](https://code.claude.com/docs/en/skills)
- [Sub-Agents](https://code.claude.com/docs/en/sub-agents)
- [MCP](https://code.claude.com/docs/en/mcp)
- [Agent Teams](https://code.claude.com/docs/en/agent-teams)
- [Memory (CLAUDE.md)](https://code.claude.com/docs/en/memory)
- [Sandboxing](https://code.claude.com/docs/en/sandboxing)
- [Best Practices](https://code.claude.com/docs/en/best-practices)
- [Changelog](https://code.claude.com/docs/en/changelog)

### GitHub Copilot CLI
- [Copilot CLI 公式ドキュメント](https://docs.github.com/copilot/concepts/agents/about-copilot-cli)
- [Copilot CLI の使い方](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli)
- [GitHub Copilot ベストプラクティス](https://docs.github.com/copilot/using-github-copilot/best-practices-for-using-github-copilot)
- [カスタム指示ファイル](https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)
- [Model Context Protocol](https://modelcontextprotocol.io/)

## ライセンス

[MIT](LICENSE)
