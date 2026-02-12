# ClaudeCode Settings JSONs

ClaudeCodeでのAI開発におけるコマンド許可/拒否のデフォルト設定を提供するリポジトリです。

## 概要

このリポジトリは、Claude Code（Anthropic社のAI開発支援ツール）のプロジェクト設定用JSONファイルのテンプレート集です。セキュリティレベルや用途に応じた複数のパターンを用意しており、これらをコピーして自分のプロジェクトに適用することで、適切なツール権限設定を素早く導入できます。

## 特徴

- **セキュリティレベル別設定**: Basic（最小権限）、Standard（推奨）、Advanced（全権限）
- **MCP統合設定**: GitHub、Actions、Security、Browser Automationなど
- **Skills設定**: Skill開発用、実行用
- **Agent/Team設定**: マルチエージェント協調、専門エージェント設定

## ディレクトリ構成

```
configs/
├── basic/              # 基本設定（最小権限・読み取り専用）
├── standard/           # 標準設定（推奨・バランス型）
├── advanced/           # 上級設定（全権限・信頼環境用）
├── mcp/                # MCP統合設定
│   ├── github-readonly.json
│   ├── github-actions.json
│   ├── github-security.json
│   └── browser-automation.json
├── skills/             # Skills関連設定
│   ├── skill-development.json
│   └── skill-execution.json
└── agent-team/         # Agent/Team設定
    ├── team-coordination.json
    ├── explorer-agent.json
    ├── builder-agent.json
    └── coder-agent.json
```

## 使い方

### 1. 設定ファイルのコピー

プロジェクトのニーズに合った設定を選択し、`.claude/settings.json`としてコピーします：

```bash
# 標準設定を使用する場合
cp configs/standard/settings.json your-project/.claude/settings.json
```

### 2. 複数の設定の組み合わせ

基本設定にMCP設定を追加する場合は、手動でマージします：

```bash
# 標準設定をベースに
cp configs/standard/settings.json your-project/.claude/settings.json

# MCP GitHub設定を追加で参照
cat configs/mcp/github-readonly.json
```

### 3. カスタマイズ

コピーした設定ファイルは、プロジェクトの要件に合わせて編集できます。

## 設定パターン詳細

### Basic（基本設定）

**用途**: 未信頼コードのレビュー、高セキュリティ環境

**特徴**:
- 読み取り専用操作のみ許可
- ファイル変更不可
- コマンド実行不可
- コード探索・レビュー専用

**許可ツール**: `view`, `grep`, `glob`, `list_bash`

### Standard（標準設定）

**用途**: 通常の開発プロジェクト（推奨）

**特徴**:
- ファイル編集・作成可能
- 制限付きBashコマンド実行
- 安全なGitHub操作（MCP経由）
- ブラウザ自動化は無効

**許可ツール**: ファイル操作、Git、npm/pip等のビルドツール、GitHub MCP（読み取り）

**制限**: 破壊的コマンド（rm -rf、sudo等）は拒否

### Advanced（上級設定）

**用途**: 完全に信頼できる環境、経験豊富な開発者

**特徴**:
- ほぼ全ての操作を許可
- インタラクティブBashセッション可能
- ブラウザ自動化フル機能
- 全てのGitHub MCP操作

**制限**: システム破壊的なコマンドのみ拒否

### MCP設定

#### GitHub Readonly
- GitHub APIへの読み取り専用アクセス
- リポジトリ探索、コード検索、PR/Issue閲覧

#### GitHub Actions
- CI/CDワークフロー監視
- ジョブログ取得
- ワークフロー実行状況確認

#### GitHub Security
- セキュリティスキャン結果の閲覧
- Code Scanning、Secret Scanningアラート確認

#### Browser Automation
- Playwright経由のブラウザ操作
- UI テスト、Webスクレイピング
- JavaScript実行は制限

### Skills設定

#### Skill Development
- Claude Code Skills の開発用
- スキル構造の強制
- コードレビュー必須

#### Skill Execution
- 承認済みSkillsの実行用
- 分離実行環境
- リソース制限

### Agent/Team設定

#### Team Coordination
- マルチエージェント協調
- 並列実行サポート
- タスク委譲可能

#### Explorer Agent
- コードベース探索特化
- 高速検索・分析
- 読み取り専用

#### Builder Agent
- ビルド・テスト実行特化
- 主要エコシステム対応
- コマンド実行のみ

#### Coder Agent
- コード開発・修正特化
- ファイル編集フル機能
- セキュリティスキャン統合

## セキュリティ考慮事項

1. **最小権限の原則**: 必要最小限の権限から始める
2. **段階的な権限拡大**: プロジェクトの信頼度に応じて権限を拡大
3. **定期的なレビュー**: 権限設定を定期的に見直す
4. **監査ログ**: 重要な操作は記録を確認
5. **環境分離**: 開発、ステージング、本番で異なる設定を使用

## 推奨設定フロー

```
新規プロジェクト
    ↓
Standard設定でスタート
    ↓
必要に応じてMCP設定を追加
    ↓
信頼度が高まったらAdvancedへ
    ↓
チーム開発ならAgent設定も検討
```

## トラブルシューティング

### 権限エラーが発生する

```json
{
  "allowedTools": ["必要なツール名"]
}
```
を追加してください。

### 設定が反映されない

1. `.claude/settings.json`の配置を確認
2. JSON構文エラーをチェック
3. Claude Codeを再起動

## ライセンス

MIT License

## 貢献

プルリクエストを歓迎します。新しい設定パターンの提案や既存設定の改善をお待ちしています。

## 関連リソース

- [Claude Code公式ドキュメント](https://code.claude.com/docs)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)
- [Claude Code Skills Guide](https://gist.github.com/alirezarezvani/a0f6e0a984d4a4adc4842bbe124c5935)

## 更新履歴

- 2026-02-12: 初回リリース
  - Basic/Standard/Advanced設定
  - MCP統合設定（GitHub、Actions、Security、Browser）
  - Skills設定（開発・実行）
  - Agent/Team設定（協調、Explorer、Builder、Coder）
