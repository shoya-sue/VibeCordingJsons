# ClaudeCode Settings JSONs

ClaudeCodeの`.claude/settings.json`用の設定テンプレート集です。プロジェクトに応じた権限設定をコピーして使えます。

## どのJSONを使うべきか

### 🎯 最適化済み設定（推奨・そのまま使える）

**✨ NEW: 高度なオプションを組み込み済みの最適化設定**

| 状況 | 使用するJSON | 説明 |
|------|-------------|------|
| 📖 コードレビューのみ | `configs/optimized/basic-optimized.json` | 読み取り専用 + セキュア権限管理 + 高速モデル |
| 👨‍💻 **通常の開発（最推奨）** | `configs/optimized/standard-optimized.json` | 標準設定 + 権限管理 + 自動Git状態表示 + 最新モデル |
| 🚀 完全信頼環境 | `configs/optimized/advanced-optimized.json` | 全機能 + マルチエージェント + 詳細フック |

**特徴**:
- ✅ すぐに使える：そのままコピーして使用可能
- ✅ ベストプラクティス：実用的な設定を組み込み済み
- ✅ 最適化済み：permissions、env、llm、hooks等を適切に設定

### 🔐 基本設定（カスタマイズ用）

従来の設定ファイル。必要に応じて手動で組み合わせ可能。

| 状況 | 使用するJSON | 説明 |
|------|-------------|------|
| 📖 コードレビューのみ | `configs/basic/settings.json` | 読み取り専用。ファイル変更・コマンド実行不可 |
| 👨‍💻 通常の開発 | `configs/standard/settings.json` | ファイル編集可能、安全なコマンド実行、GitHub連携 |
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

### 推奨：最適化済み設定を使う（最も簡単）

```bash
# 1. 最適化済みの標準設定をコピー（最推奨）
cp configs/optimized/standard-optimized.json .claude/settings.json

# 2. Claude Codeを再起動して適用
# 設定はそのまま使えます！
```

### 従来の方法：基本設定を使う

```bash
# 1. 標準設定をコピー
cp configs/standard/settings.json .claude/settings.json

# 2. 必要に応じて高度なオプションを追加
jq -s '.[0] * .[1]' .claude/settings.json configs/examples/hooks-focused.json > .claude/settings.new.json
mv .claude/settings.new.json .claude/settings.json

# 3. Claude Codeを再起動して適用
```

## ディレクトリ構成

```
configs/
├── optimized/                   # 🎯 最適化済み（推奨・そのまま使える）
│   ├── basic-optimized.json     # 読み取り専用 + 高度オプション
│   ├── standard-optimized.json  # 標準設定 + 高度オプション（最推奨）
│   └── advanced-optimized.json  # 全機能 + 高度オプション
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
    ├── agents-focused.json      # カスタムエージェントの例
    └── combined-standard-advanced.json # 既存設定との組み合わせ例
```

## よくある質問

### Q: 設定が反映されない
A: Claude Codeを再起動してください。`.claude/settings.json`がプロジェクトルートにあることを確認してください。

### Q: 複数の設定を組み合わせたい
A: 手動でJSONをマージするか、`jq`コマンドを使用してください：
```bash
# 既存設定とMCP設定を組み合わせる
jq -s '.[0] * .[1]' configs/standard/settings.json configs/mcp/github-readonly.json > .claude/settings.json

# 既存設定に高度なオプション（フック等）を追加
jq -s '.[0] * .[1]' configs/standard/settings.json configs/examples/hooks-focused.json > .claude/settings.json
```

### Q: 新しい高度なオプションは既存設定と一緒に使えますか？
A: はい、完全に互換性があります！既存の`allowedTools`や`toolRestrictions`と一緒に、`permissions`、`env`、`llm`、`hooks`などの新しいオプションを追加できます。

**推奨：最適化済み設定を使う**
```bash
# すぐに使える最適化済み設定（推奨）
cp configs/optimized/standard-optimized.json .claude/settings.json
```

**カスタマイズする場合：手動でマージ**
```bash
# 既存設定に高度なオプションを追加
jq -s '.[0] * .[1]' configs/standard/settings.json configs/examples/hooks-focused.json > .claude/settings.json
```

### Q: 「最適化済み設定」と「基本設定」の違いは？
A: 
- **最適化済み設定** (`configs/optimized/`): 高度なオプション（permissions、env、llm、hooks等）を実用的に組み込み済み。**そのまま使えて推奨**。
- **基本設定** (`configs/basic/`, `configs/standard/`, `configs/advanced/`): 従来の設定。必要に応じて手動でカスタマイズする場合に使用。
- **examples設定** (`configs/examples/`): 高度なオプションの学習用サンプル。組み合わせの参考に。

ほとんどの場合、最適化済み設定をそのまま使うのが最も簡単で効率的です。

### Q: 権限エラーが出る
A: `.claude/settings.json`の`allowedTools`に必要なツールを追加してください。

## 詳細情報

- **高度なカスタマイズオプション**: [ADVANCED_CUSTOMIZATION.md](ADVANCED_CUSTOMIZATION.md) - コマンド許可リスト以外の設定オプション（権限管理、環境変数、モデル設定、フック、カスタムエージェントなど）
- 詳細なリファレンス: [REFERENCE.md](REFERENCE.md)
- JSONスキーマ: [schema.json](schema.json)
- ライセンス: [MIT](LICENSE)

## 貢献

プルリクエストを歓迎します。詳細は[REFERENCE.md](REFERENCE.md)の「貢献ガイド」セクションを参照してください。
