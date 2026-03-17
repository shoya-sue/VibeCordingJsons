# Project Name

## Overview

<!-- プロジェクトの概要を1-2行で記載 -->

## Tech Stack

<!-- 使用技術を記載 -->
<!-- 例: TypeScript, React, Node.js, PostgreSQL, Docker, Kubernetes -->

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
├── integration/   # 統合テスト
└── e2e/           # E2E テスト（Playwright）
docs/              # ドキュメント
scripts/           # ビルド・デプロイスクリプト
.claude/
├── skills/        # カスタムスキル定義
└── agents/        # カスタムエージェント定義
```

## Conventions

- <!-- コーディング規約を記載 -->
- <!-- 命名規則を記載 -->
- テストは `tests/` 配下に配置
- コミットメッセージは Conventional Commits 形式
- Docker イメージは `Dockerfile` で定義

## Commands

```bash
npm test              # テスト実行
npm run lint          # リント
npm run build         # ビルド
docker compose up     # ローカル環境起動
make deploy-staging   # ステージングデプロイ
```

## Infrastructure

- <!-- インフラ構成を記載 -->
- `terraform plan` は許可、`terraform apply` は手動確認必須
- `kubectl delete namespace/node` は禁止

## Slash Commands

- `/model opusplan` — Opus で計画、Sonnet で実行の自動切り替え（コスト最適化）
- `/effort low|medium|high` — モデルの思考レベルを設定（○ ◐ ●）。`/effort auto` でリセット
- `/memory` — 自動メモリの管理（閲覧・編集・削除）
- `/loop 5m check deploy` — 定期的にプロンプトを繰り返し実行
- `/plan fix the auth bug` — 説明付きでプランモードを開始
- `/simplify` — コードを簡素化
- `/batch` — 複数タスクを一括実行
- `/context` — コンテキスト最適化の提案を表示
- `/copy N` — N番目のアシスタント応答をクリップボードにコピー

## Important Notes

- `.env.production` は読み取り禁止（settings.json の deny で制御済み）
- Agent Teams 有効 — 複数エージェントが並行作業可能
- Sandbox 有効 — Bash コマンドはサンドボックス内で実行
- Hooks でコマンドログ・ファイル変更ログを自動記録（全21イベント対応）
- MCP Elicitation 対応 — MCP サーバーがタスク中に構造化入力を要求可能
- 自動メモリ有効 — Claude が作業中に有用なコンテキストを自動保存
