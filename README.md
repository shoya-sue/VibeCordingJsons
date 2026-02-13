# ClaudeCode Settings JSONs

ClaudeCodeの`.claude/settings.json`用の設定テンプレート集です。**3つの選択肢から選ぶだけ**で、すぐに使えます。

## 🎯 どれを使えばいい？（3つだけ）

| 用途 | ファイル | いつ使う？ |
|------|---------|-----------|
| 📖 **コードレビュー** | `configs/basic-optimized.json` | コードを読むだけ。変更しない |
| 👨‍💻 **通常の開発（推奨）** | `configs/standard-optimized.json` | ほとんどのプロジェクトはこれ |
| 🚀 **フル機能** | `configs/advanced-optimized.json` | 全ての制限を外したい |

## クイックスタート

```bash
# 1. 設定をコピー（ほとんどの人はこれ）
cp configs/standard-optimized.json .claude/settings.json

# 2. Claude Codeを再起動
# 完了！
```

## それぞれの違いは？

### 📖 basic-optimized.json（読み取り専用）
- ✅ ファイルを読む、検索する
- ❌ ファイルを編集できない
- ❌ コマンドを実行できない
- 💡 使う場面：信頼できないコードのレビュー

### 👨‍💻 standard-optimized.json（推奨）
- ✅ ファイルを読む、編集する
- ✅ 安全なコマンド実行（npm、git等）
- ✅ GitHub連携
- ✅ セッション開始時にGit状態を自動表示
- ❌ 危険なコマンド（rm -rf、sudo等）は拒否
- 💡 使う場面：ほとんどの開発プロジェクト（**これを選べば間違いなし**）

### 🚀 advanced-optimized.json（上級者向け）
- ✅ ほぼ全ての操作が可能
- ✅ マルチエージェント機能
- ✅ ブラウザ自動化
- ✅ 詳細なフック設定
- ⚠️ 危険なコマンドのみ拒否
- 💡 使う場面：完全に信頼できる環境、経験豊富な開発者

## 高度な使い方（オプション）

### 追加機能が必要な場合

特殊な機能が必要な場合は、`configs/add-ons/`にある設定を組み合わせられます：

```bash
# 例：標準設定にGitHub Actions監視を追加
jq -s '.[0] * .[1]' \
  configs/standard-optimized.json \
  configs/add-ons/mcp/github-actions.json \
  > .claude/settings.json
```

利用可能なアドオン：
- `add-ons/mcp/` - GitHub API連携、ブラウザ自動化
- `add-ons/skills/` - Claude Code Skills開発・実行
- `add-ons/agent-team/` - マルチエージェント開発

### 従来の設定ファイル

過去の設定ファイルは`configs/legacy/`にあります。新規利用は非推奨です。

## ディレクトリ構成

```
configs/
├── basic-optimized.json           # 📖 読み取り専用
├── standard-optimized.json        # 👨‍💻 通常の開発（推奨）
├── advanced-optimized.json        # 🚀 フル機能
├── add-ons/                       # オプション：追加機能
│   ├── mcp/                       #   GitHub API、ブラウザ等
│   ├── skills/                    #   Skills開発・実行
│   └── agent-team/                #   マルチエージェント
└── legacy/                        # 非推奨：過去の設定ファイル
```

## よくある質問

### Q: 設定が反映されない
A: Claude Codeを再起動してください。`.claude/settings.json`がプロジェクトルートにあることを確認してください。

### Q: どれを選べばいい？
A: **迷ったら`standard-optimized.json`を使ってください**。ほとんどのプロジェクトに適しています。

### Q: 追加機能が欲しい
A: `configs/add-ons/`から必要な設定を組み合わせられます：
```bash
# 例：GitHub Actions監視を追加
jq -s '.[0] * .[1]' \
  configs/standard-optimized.json \
  configs/add-ons/mcp/github-actions.json \
  > .claude/settings.json
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
