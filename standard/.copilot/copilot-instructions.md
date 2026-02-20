# GitHub Copilot CLI — Standard 設定

## 役割と思想

このプロジェクトでは **日常開発モード** で GitHub Copilot CLI を使用します。
コードの理解・編集・テスト・GitHub ワークフローを効率化します。

## エージェント活用方針

| タスク種別 | 使用エージェント | 理由 |
|-----------|----------------|------|
| コードベース探索・質問 | `explore` (Haiku) | 高速・安価・並列安全 |
| テスト/ビルド/lint 実行 | `task` (Haiku) | 冗長出力を隔離 |
| コードレビュー | `code-reviewer` | 専用プロンプト最適化 |
| 複雑な多段階タスク | `general-purpose` (Sonnet) | 高品質な推論が必要 |

## Claude Code との連携

| Copilot CLI が得意 | Claude Code が得意 |
|------------------|------------------|
| GitHub Issues/PR 操作 | 大規模リファクタリング |
| クイックフィックス | 複雑なデバッグセッション |
| コードの説明・質問 | アーキテクチャ設計 |

共有コンテキスト: `CLAUDE.md` / `AGENTS.md` に両ツール共通の指示を記載。

## スキル活用ガイド

- **explain-code** — コードの構造・ロジックを日本語解説 → `/explain-code`
- **code-reviewer** — コード品質・セキュリティレビュー → `/code-reviewer`

## コーディング規約

- コミットメッセージは **Conventional Commits** 形式 (`feat:`, `fix:`, `chore:` 等)
- コメントは **日本語** で記述
- テストファーストで開発 (TDD)
- 最小限の変更で目的を達成する

## セキュリティ規則

- `.env.production` は読み取り禁止
- `kubectl delete namespace/node` は禁止
- `terraform apply` は手動確認必須
- シークレットをコードにコミットしない
