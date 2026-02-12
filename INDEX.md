# Configuration Index

このファイルは、利用可能な全ての設定ファイルの一覧と説明です。

## セキュリティレベル別設定

### Basic（基本設定）
- **ファイル**: `configs/basic/settings.json`
- **セキュリティレベル**: 最高
- **用途**: 未信頼コードのレビュー、高セキュリティ環境
- **主な制限**: 読み取り専用、ファイル変更不可、コマンド実行不可
- **推奨環境**: セキュリティ最優先のプロジェクト

### Standard（標準設定）
- **ファイル**: `configs/standard/settings.json`
- **セキュリティレベル**: 中
- **用途**: 通常の開発プロジェクト（推奨）
- **主な機能**: ファイル編集、制限付きコマンド実行、GitHub MCP
- **推奨環境**: ほとんどの開発プロジェクト

### Advanced（上級設定）
- **ファイル**: `configs/advanced/settings.json`
- **セキュリティレベル**: 低
- **用途**: 完全に信頼できる環境
- **主な機能**: ほぼ全ての操作が可能
- **推奨環境**: 経験豊富な開発者、完全信頼環境

## MCP統合設定

### GitHub Readonly
- **ファイル**: `configs/mcp/github-readonly.json`
- **機能**: GitHub API読み取り専用アクセス
- **ツール**: リポジトリ探索、コード検索、PR/Issue閲覧
- **必要な権限**: GitHub token (read)

### GitHub Actions
- **ファイル**: `configs/mcp/github-actions.json`
- **機能**: CI/CDワークフロー監視
- **ツール**: ワークフロー実行状況、ジョブログ取得
- **必要な権限**: GitHub token (actions:read)

### GitHub Security
- **ファイル**: `configs/mcp/github-security.json`
- **機能**: セキュリティスキャン結果の閲覧
- **ツール**: Code Scanning、Secret Scanningアラート
- **必要な権限**: GitHub token (security_events:read)

### Browser Automation
- **ファイル**: `configs/mcp/browser-automation.json`
- **機能**: Playwright経由のブラウザ操作
- **ツール**: UI テスト、Webスクレイピング
- **制限**: JavaScript実行制限、ファイルアップロード制限

## Skills設定

### Skill Development
- **ファイル**: `configs/skills/skill-development.json`
- **用途**: Claude Code Skillsの開発
- **機能**: スキル構造の強制、コードレビュー必須
- **制限**: 開発操作のみ、実行は別設定で

### Skill Execution
- **ファイル**: `configs/skills/skill-execution.json`
- **用途**: 承認済みSkillsの実行
- **機能**: 分離実行環境、リソース制限
- **制限**: ファイル変更不可、読み取りと実行のみ

## Agent/Team設定

### Team Coordination
- **ファイル**: `configs/agent-team/team-coordination.json`
- **用途**: マルチエージェント協調開発
- **機能**: 並列実行、タスク委譲、進捗レポート
- **特徴**: 最大10エージェント、3つの専門ロール

### Explorer Agent
- **ファイル**: `configs/agent-team/explorer-agent.json`
- **ロール**: コードベース探索
- **モデル**: Claude 3.5 Haiku（高速）
- **機能**: 読み取り専用、高速検索・分析
- **制限**: ファイル変更不可、コマンド実行不可

### Builder Agent
- **ファイル**: `configs/agent-team/builder-agent.json`
- **ロール**: ビルド・テスト実行
- **モデル**: Claude 3.5 Haiku（高速）
- **機能**: コマンド実行、主要エコシステム対応
- **制限**: ファイル編集不可、コマンド実行のみ

### Coder Agent
- **ファイル**: `configs/agent-team/coder-agent.json`
- **ロール**: コード開発・修正
- **モデル**: Claude 3.5 Sonnet（高品質）
- **機能**: フルファイル編集、セキュリティスキャン統合
- **制限**: インタラクティブBash無効

## テンプレート

### Project Template
- **ファイル**: `templates/project-template.json`
- **用途**: 新規プロジェクトのカスタマイズベース
- **特徴**: バランスの取れた初期設定
- **カスタマイズ**: プロジェクト要件に応じて調整

### Setup Script
- **ファイル**: `templates/setup.sh`
- **用途**: インタラクティブな設定セットアップ
- **使い方**: `./templates/setup.sh`
- **機能**: 対話形式で設定を選択・配置

## 設定の組み合わせ推奨パターン

### パターン1: Web開発スタンダード
```
基本: configs/standard/settings.json
追加: configs/mcp/github-readonly.json
```

### パターン2: セキュリティ重視開発
```
基本: configs/standard/settings.json
追加: configs/mcp/github-security.json
追加: codeql_checker, gh-advisory-database（標準に含まれる）
```

### パターン3: CI/CD統合
```
基本: configs/standard/settings.json
追加: configs/mcp/github-actions.json
```

### パターン4: チーム開発
```
基本: configs/agent-team/team-coordination.json
または個別: explorer-agent.json, builder-agent.json, coder-agent.json
```

### パターン5: Skills開発ワークフロー
```
開発時: configs/skills/skill-development.json
実行時: configs/skills/skill-execution.json
```

## バージョン情報

- 初回作成: 2026-02-12
- 設定ファイル数: 14
- カテゴリ数: 5（Basic/Standard/Advanced, MCP, Skills, Agent/Team, Templates）

## 参照

- 詳細な使用方法: `EXAMPLES.md`
- 貢献ガイド: `CONTRIBUTING.md`
- スキーマ定義: `schema.json`