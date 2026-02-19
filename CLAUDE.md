# ClaudeCode Settings JSONs

Claude Code のベストプラクティステンプレートを提供するリポジトリ。

## Tech Stack

Bash, JSON, Markdown（コードは含まない。設定テンプレートのみ）

## Project Structure

```text
.
├── minimal/           # 読み取り専用パターン
│   ├── .claude/       # settings.json, settings.local.json
│   ├── CLAUDE.md
│   └── README.md
├── standard/          # 日常開発パターン（推奨）
│   ├── .claude/       # settings + skills + rules
│   ├── .mcp.json
│   ├── CLAUDE.md
│   └── README.md
├── full/              # 全機能パターン
│   ├── .claude/       # settings + skills + agents + rules
│   ├── .mcp.json
│   ├── CLAUDE.md
│   └── README.md
├── install.sh         # 一括インストールスクリプト
└── README.md          # ドキュメント
```

## Conventions

- 各パターンは自己完結型（GitHub 上で個別にコピー可能）
- settings.json の権限は最小権限の原則に従う
- SKILL.md のフロントマターは `user-invokable`（`user-invocable` ではない）
- SKILL.md に `allowed-tools` は使用不可（Claude Code 未サポート）
- `.mcp.json` の API キーは `${ENV_VAR}` 形式で参照
- テンプレート内のコメントは `<!-- -->` で記載

## Commands

```bash
./install.sh minimal /path/to/project   # minimal パターンをインストール
./install.sh standard /path/to/project  # standard パターンをインストール
./install.sh full /path/to/project      # full パターンをインストール
./install.sh full ~                     # ホームディレクトリにグローバル設定
```

## Important Notes

- テンプレート内に実際の API キーやシークレットを書かないこと
- 各パターンの README.md は GitHub ブラウザで自動表示される
- install.sh は既存ファイルを上書きする（プロジェクト固有設定は先にバックアップ）
- このリポジトリ自体の `.claude/settings.json` はテンプレート開発用に最適化済み
