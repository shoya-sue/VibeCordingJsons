# VibeCording Settings

Claude Code と GitHub Copilot CLI のベストプラクティステンプレートを提供するリポジトリ。

## Tech Stack

Bash, JSON, Markdown（コードは含まない。設定テンプレートのみ）

## Project Structure

```text
.
├── minimal/           # 読み取り専用パターン
│   ├── .claude/       # settings.json, settings.local.json
│   ├── .github/       # copilot-instructions.md
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   └── README.md
├── standard/          # 日常開発パターン（推奨）
│   ├── .claude/       # settings + skills + rules
│   ├── .github/       # copilot-instructions.md + 2 skills
│   ├── .mcp.json
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   └── README.md
├── full/              # 全機能パターン
│   ├── .claude/       # settings + skills + agents + rules
│   ├── .github/       # copilot-instructions.md + 5 skills + 4 agents
│   ├── .mcp.json
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   └── README.md
├── install.sh         # 一括インストールスクリプト
└── README.md          # ドキュメント
```

## Conventions

- 各パターンは自己完結型（GitHub 上で個別にコピー可能）
- settings.json の権限は最小権限の原則に従う
- SKILL.md のフロントマターは `user-invokable`（`user-invocable` ではない）
- SKILL.md に `allowed-tools` でツール制限が可能（例: `allowed-tools: ["Read", "Glob", "Grep"]`）
- `.mcp.json` の API キーは `${ENV_VAR}` 形式で参照
- テンプレート内のコメントは `<!-- -->` で記載
- CLAUDE.md と AGENTS.md の両方をプロジェクトルートおよび各ティアに配置

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
