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
├── services/      # API クライアント・ビジネスロジック
├── utils/         # ユーティリティ
└── types/         # 型定義
tests/
├── unit/          # ユニットテスト
└── integration/   # 統合テスト
docs/              # ドキュメント
```

## Conventions

- <!-- コーディング規約を記載 -->
- <!-- 命名規則を記載 -->
- テストは `tests/` 配下に配置
- コミットメッセージは Conventional Commits 形式

## Commands

```bash
npm test          # テスト実行
npm run lint      # リント
npm run build     # ビルド
```

## Important Notes

- `.env` に API キーを格納（Git 管理外）
- `src/`, `tests/`, `docs/` のみ Claude Code で編集可能
- force-push 禁止
