# ClaudeCode Settings JSONs

ClaudeCodeの`.claude/settings.json`用の設定テンプレート集です。プロジェクトに応じた権限設定をコピーして使えます。

## どのJSONを使うべきか

### 🔐 セキュリティレベルで選ぶ

| 状況 | 使用するJSON | 説明 |
|------|-------------|------|
| 📖 コードレビューのみ | `configs/basic/settings.json` | 読み取り専用。ファイル変更・コマンド実行不可 |
| 👨‍💻 通常の開発（推奨） | `configs/standard/settings.json` | ファイル編集可能、安全なコマンド実行、GitHub連携 |
| 🚀 完全信頼環境 | `configs/advanced/settings.json` | 全機能利用可能。経験豊富な開発者向け |

### 🔌 機能で選ぶ（追加設定）

| 必要な機能 | 使用するJSON |
|-----------|-------------|
| GitHub API連携 | `configs/mcp/github-readonly.json` |
| CI/CD監視 | `configs/mcp/github-actions.json` |
| セキュリティスキャン | `configs/mcp/github-security.json` |
| ブラウザ自動化 | `configs/mcp/browser-automation.json` |
| Skills開発 | `configs/skills/skill-development.json` |
| Skills実行 | `configs/skills/skill-execution.json` |

### 👥 チーム開発で選ぶ

| 開発スタイル | 使用するJSON |
|-------------|-------------|
| マルチエージェント協調 | `configs/agent-team/team-coordination.json` |
| コード探索専用 | `configs/agent-team/explorer-agent.json` |
| ビルド・テスト専用 | `configs/agent-team/builder-agent.json` |
| コード編集専用 | `configs/agent-team/coder-agent.json` |

## クイックスタート

```bash
# 1. 標準設定をコピー（ほとんどのプロジェクトに推奨）
cp configs/standard/settings.json .claude/settings.json

# 2. 設定を確認・編集
vim .claude/settings.json

# 3. Claude Codeを再起動して適用
```

## ディレクトリ構成

```
configs/
├── basic/settings.json          # 最小権限（読み取り専用）
├── standard/settings.json       # 推奨設定（バランス型）
├── advanced/settings.json       # 全権限（信頼環境用）
├── mcp/                         # MCP統合
│   ├── github-readonly.json
│   ├── github-actions.json
│   ├── github-security.json
│   └── browser-automation.json
├── skills/                      # Skills
│   ├── skill-development.json
│   └── skill-execution.json
├── agent-team/                  # マルチエージェント
│   ├── team-coordination.json
│   ├── explorer-agent.json
│   ├── builder-agent.json
│   └── coder-agent.json
└── examples/                    # 高度なカスタマイズ例
    ├── advanced-options.json    # 全オプション網羅
    ├── permissions-focused.json # 権限管理の例
    ├── hooks-focused.json       # フック機能の例
    └── agents-focused.json      # カスタムエージェントの例
```

## よくある質問

### Q: 設定が反映されない
A: Claude Codeを再起動してください。`.claude/settings.json`がプロジェクトルートにあることを確認してください。

### Q: 複数の設定を組み合わせたい
A: 手動でJSONをマージするか、`jq`コマンドを使用してください：
```bash
jq -s '.[0] * .[1]' configs/standard/settings.json configs/mcp/github-readonly.json > .claude/settings.json
```

### Q: 権限エラーが出る
A: `.claude/settings.json`の`allowedTools`に必要なツールを追加してください。

## 詳細情報

- **高度なカスタマイズオプション**: [ADVANCED_CUSTOMIZATION.md](ADVANCED_CUSTOMIZATION.md) - コマンド許可リスト以外の設定オプション（権限管理、環境変数、モデル設定、フック、カスタムエージェントなど）
- 詳細なリファレンス: [REFERENCE.md](REFERENCE.md)
- JSONスキーマ: [schema.json](schema.json)
- ライセンス: [MIT](LICENSE)

## 貢献

プルリクエストを歓迎します。詳細は[REFERENCE.md](REFERENCE.md)の「貢献ガイド」セクションを参照してください。
