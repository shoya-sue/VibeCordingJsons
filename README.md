# ClaudeCode Settings JSONs

Claude Code のベストプラクティステンプレート集。
`settings.json` / `.mcp.json` / `CLAUDE.md` / Skills / Agents / Rules を一式提供。

## 使い方

### install.sh で一括コピー（推奨）

```bash
git clone https://github.com/shoya-sue/ClaudeCodeJsons.git
cd ClaudeCodeJsons
./install.sh standard /path/to/your/project
```

### GitHub 上で手動コピー

使いたいパターンのディレクトリを開き、各ファイルの中身をコピー。

## 3つのパターン

| パターン | 用途 | 含まれるファイル |
|---------|------|-----------------|
| **[Minimal](minimal/)** | コードレビュー・探索のみ | `.claude/settings.json`, `CLAUDE.md` |
| **[Standard](standard/)** | 日常の開発作業（**推奨**） | 上記 + `.mcp.json`, Skills, Rules |
| **[Full](full/)** | 全機能活用 | 上記 + Agents, Sandbox, Agent Teams |

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
| ファイル読み取り | src/tests/docs | src/tests/docs + 設定ファイル | 全ファイル |
| ファイル書き込み | **不可** | src/tests/docs | 主要ディレクトリ |
| git 操作 | 参照のみ | add/commit まで | 全操作 |
| permissions.ask | なし | git push, npm publish | + docker/terraform/kubectl |
| パッケージマネージャー | **不可** | npm/yarn/pnpm/bun | 同左 |
| テスト実行 | **不可** | pytest/cargo/go | 同左 |
| Docker / K8s | **不可** | **不可** | docker/kubectl |
| MCP サーバー | **不可** | 4サーバー | 5サーバー + 全許可 |
| Skills | **不可** | explain-code | + fix-issue, review-pr |
| Agents | なし | なし | code-reviewer, test-runner |
| Rules | なし | code-style | + api-conventions |
| Hooks | なし | PostToolUse, Stop | + SessionStart, PreToolUse |
| Sandbox | なし | なし | 有効（network 制御付き） |
| Agent Teams | なし | なし | 有効 |
| Attribution | なし | コミット・PR 署名 | 同左 |

## ディレクトリ構成

```text
.
├── minimal/
│   ├── .claude/
│   │   ├── settings.json
│   │   └── settings.local.json
│   ├── CLAUDE.md
│   ├── CLAUDE.local.md
│   └── README.md
├── standard/
│   ├── .claude/
│   │   ├── settings.json
│   │   ├── settings.local.json
│   │   ├── skills/explain-code/SKILL.md
│   │   └── rules/code-style.md
│   ├── .mcp.json
│   ├── CLAUDE.md
│   ├── CLAUDE.local.md
│   └── README.md
├── full/
│   ├── .claude/
│   │   ├── settings.json
│   │   ├── settings.local.json
│   │   ├── skills/
│   │   │   ├── explain-code/SKILL.md
│   │   │   ├── fix-issue/SKILL.md
│   │   │   └── review-pr/SKILL.md
│   │   ├── agents/
│   │   │   ├── code-reviewer.md
│   │   │   └── test-runner.md
│   │   └── rules/
│   │       ├── code-style.md
│   │       └── api-conventions.md
│   ├── .mcp.json
│   ├── CLAUDE.md
│   ├── CLAUDE.local.md
│   └── README.md
├── install.sh
├── .claude/settings.json
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

### hooks（イベントフック — 14イベント対応）

3種類のフックタイプ: `command`（シェル）、`prompt`（LLM 判定）、`agent`（サブエージェント）

```jsonc
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "echo 'Before bash'", "timeout": 5000 }
        ]
      }
    ]
  }
}
```

主要イベント:

| イベント | タイミング | ブロック可能 |
|---------|-----------|------------|
| `SessionStart` | セッション開始 | No |
| `UserPromptSubmit` | プロンプト送信前 | Yes |
| `PreToolUse` | ツール実行前 | Yes |
| `PostToolUse` | ツール実行後 | No |
| `Stop` | セッション停止時 | Yes |
| `SubagentStop` | サブエージェント停止時 | Yes |

### env（環境変数）

| 変数 | 説明 | 推奨値 |
|------|------|--------|
| `MCP_TIMEOUT` | MCP タイムアウト (ms) | `10000`-`15000` |
| `MAX_MCP_OUTPUT_TOKENS` | MCP 出力上限トークン | `25000`-`50000` |
| `BASH_MAX_TIMEOUT_MS` | Bash タイムアウト (ms) | `120000`-`300000` |
| `ENABLE_TOOL_SEARCH` | ツール検索の有効化 | `auto` |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | コンテキスト自動圧縮 (%) | `50` |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Agent Teams 有効化 | `1` |
| `MAX_THINKING_TOKENS` | 思考トークン上限 | モデル依存 |

### その他の設定項目

| 項目 | 説明 |
|------|------|
| `$schema` | IDE での自動補完を有効化 |
| `model` | デフォルトモデルの指定 |
| `language` | 応答言語（`"japanese"` 等） |
| `attribution` | コミット・PR への署名テキスト |
| `sandbox` | Bash サンドボックス（enabled, excludedCommands, network） |
| `teammateMode` | Agent Teams 表示モード（`auto` / `in-process` / `tmux`） |
| `enableAllProjectMcpServers` | `.mcp.json` のサーバー自動有効化 |

## 設定の階層

Claude Code は以下の優先順位で設定を適用する:

1. CLI 引数（セッション限定）
2. `.claude/settings.local.json`（個人用、gitignore 推奨）
3. `.claude/settings.json`（チーム共有、Git 管理）
4. `~/.claude/settings.local.json`（グローバル個人用）
5. `~/.claude/settings.json`（グローバルデフォルト）

## ベストプラクティス

- **最小権限**: 必要な権限だけを `allow` に記載する
- **ask を活用**: push / publish 等は `ask` で毎回確認
- **明示的拒否**: 危険な操作は `deny` で明示的にブロック
- **MCP は 4-5 個**: 多すぎると起動が遅くなり逆効果
- **CLAUDE.md は 150 行以内**: コンテキストに確実に含まれる
- **secrets は書かない**: `.env` や API キーを settings.json に入れない
- **Hooks 活用**: ファイル変更通知やコマンドログで作業を可視化
- **Sandbox 有効化**: 信頼できる環境でも sandbox で安全性を担保
- **`--dangerously-skip-permissions` は使わない**: セキュリティリスク大

## 参考

- [Claude Code 公式ドキュメント](https://code.claude.com/docs)
- [Settings](https://code.claude.com/docs/settings)
- [Hooks](https://code.claude.com/docs/hooks)
- [Skills](https://code.claude.com/docs/skills)
- [Sub-Agents](https://code.claude.com/docs/sub-agents)
- [MCP](https://code.claude.com/docs/mcp)
- [Agent Teams](https://code.claude.com/docs/agent-teams)
- [Memory (CLAUDE.md)](https://code.claude.com/docs/memory)
- [Best Practices](https://code.claude.com/docs/best-practices)
- [Model Context Protocol](https://modelcontextprotocol.io/)

## ライセンス

[MIT](LICENSE)
