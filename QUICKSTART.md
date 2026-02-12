# Quick Reference Guide

このガイドは、各設定ファイルの選び方を簡単に示します。

## 1分で選ぶ設定ファイル

### 質問1: プロジェクトの信頼度は？

- **未信頼/レビューのみ** → `configs/basic/settings.json`
- **通常の開発プロジェクト** → `configs/standard/settings.json`
- **完全に信頼できる環境** → `configs/advanced/settings.json`

### 質問2: GitHub連携が必要？

YES → 以下のいずれかを追加：
- リポジトリ閲覧のみ → `configs/mcp/github-readonly.json`
- CI/CD監視 → `configs/mcp/github-actions.json`
- セキュリティ分析 → `configs/mcp/github-security.json`

NO → そのまま

### 質問3: ブラウザ自動化が必要？

YES → `configs/mcp/browser-automation.json` を追加

NO → そのまま

### 質問4: チーム開発/マルチエージェント？

YES → 以下から選択：
- チーム協調 → `configs/agent-team/team-coordination.json`
- 個別エージェント → `explorer-agent.json`, `builder-agent.json`, `coder-agent.json`

NO → そのまま

### 質問5: Skillsを開発/使用？

YES → 以下から選択：
- Skills開発中 → `configs/skills/skill-development.json`
- Skills実行 → `configs/skills/skill-execution.json`

NO → そのまま

## クイックスタート

### 最速セットアップ（コピー1行）

```bash
# 推奨設定（ほとんどのプロジェクトに適用可能）
cp configs/standard/settings.json .claude/settings.json
```

### 対話式セットアップ

```bash
# テンプレートのセットアップスクリプトを使用
./templates/setup.sh
```

### 手動カスタマイズ

```bash
# テンプレートをコピーして編集
cp templates/project-template.json .claude/settings.json
# エディタで編集
vim .claude/settings.json
```

## よくあるパターン

### パターンA: Node.js Web開発
```bash
cp configs/standard/settings.json .claude/settings.json
# GitHub連携追加したい場合
# configs/mcp/github-readonly.json の内容を手動でマージ
```

### パターンB: Python Data Science
```bash
cp configs/standard/settings.json .claude/settings.json
# bash allowedCommands に以下を追加:
# "jupyter notebook", "python -m jupyter"
```

### パターンC: セキュリティ監査
```bash
cp configs/basic/settings.json .claude/settings.json
# configs/mcp/github-security.json の内容をマージ
```

### パターンD: CI/CD デバッグ
```bash
cp configs/standard/settings.json .claude/settings.json
# configs/mcp/github-actions.json の内容をマージ
```

## トラブルシューティング

### エラー: "Tool not allowed"
→ `.claude/settings.json` の `allowedTools` に必要なツールを追加

### エラー: "Command not permitted"
→ `toolRestrictions.bash.allowedCommands` に必要なコマンドを追加

### 設定が反映されない
→ Claude Codeを再起動

## 詳細情報

- 全設定の一覧: `INDEX.md`
- 使用例とシナリオ: `EXAMPLES.md`
- 完全なドキュメント: `README.md`
- 貢献方法: `CONTRIBUTING.md`

## サポートが必要？

1. まず `EXAMPLES.md` で類似のシナリオを確認
2. `INDEX.md` で全設定ファイルを確認
3. それでも不明な場合は Issue を作成