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

## Slash Commands

- `/model opusplan` — Opus で計画、Sonnet で実行の自動切り替え（コスト最適化）
- `/effort low|medium|high` — モデルの思考レベルを設定（○ ◐ ●）
- `/memory` — 自動メモリの管理
- `/plan` — プランモードを開始（Shift+Tab でも切替可能）
- `/context` — コンテキスト最適化の提案を表示

## Important Notes

- `.env` に API キーを格納（Git 管理外）
- `src/`, `tests/`, `docs/` のみ Claude Code で編集可能
- force-push 禁止
