# Project Name

## Overview

<!-- プロジェクトの概要を1-2行で記載 -->

## Tech Stack

<!-- 使用技術を記載 -->
<!-- 例: TypeScript, React, Node.js, PostgreSQL -->

## Project Structure

```text
src/
├── components/    # UI コンポーネント
├── pages/         # ページ
├── utils/         # ユーティリティ
└── types/         # 型定義
```

## Commands

```bash
# 開発サーバー起動
npm run dev

# テスト実行
npm test

# ビルド
npm run build
```

## AI エージェント使用ポリシー（Standard）

このプロジェクトでは **日常開発モード** で AI エージェントを使用します。

### ツール使い分け

| 用途 | 使用するツール |
|------|--------------|
| コードレビュー・探索 | Copilot CLI / Claude Code |
| GitHub Issues・PR | Copilot CLI (`/fix-issue`, `/review-pr`) |
| 複雑なリファクタリング | Claude Code |
| テスト実行・修正 | Copilot CLI (`/test-runner`) |

### 許可される操作

- ソースコード・テスト・ドキュメントの読み取り・編集
- `git add` / `git commit`（push は要確認）
- `npm install` / テスト実行
- MCP ツール経由の GitHub 操作

### 禁止される操作

- `git push --force`
- `rm -rf`
- シークレット・API キーの読み書き
- 本番環境への直接デプロイ

## コーディング規約

- コミットメッセージは Conventional Commits 形式（`feat:`, `fix:`, `chore:` 等）
- コメントは日本語で記述
- テストファーストで開発（TDD）

## 注意事項

- 変更前に必ず `git diff` で確認
- 大きな変更は小さなステップに分割して実行
- 不明な仕様は推測せず Issue または PR のコメントで確認
