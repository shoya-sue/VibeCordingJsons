# Minimal - 読み取り専用

コードレビュー・探索専用。書き込み一切不可。

## コピー先

| ファイル | コピー先 |
|---------|---------|
| `.claude/settings.json` | `.claude/settings.json` |
| `.claude/settings.local.json` | `.claude/settings.local.json`（個人用、gitignore） |
| `CLAUDE.md` | プロジェクトルート `CLAUDE.md` |
| `CLAUDE.local.md` | プロジェクトルート `CLAUDE.local.md`（個人用、gitignore） |
| `AGENTS.md` | プロジェクトルート `AGENTS.md` |

```bash
# install.sh で一括コピー
git clone https://github.com/shoya-sue/VibeCordingJsons.git
cd VibeCordingJsons
./install.sh minimal /path/to/your/project
```

## 含まれる権限

- ソースコード・設定ファイルの読み取り
- `git status` / `git diff` / `git log` / `git branch` / `git show`
- Write / Edit / Skill / MCPSearch は全拒否
- MCP サーバー不要

## Copilot CLI 設定

### 含まれるファイル

| ファイル | 説明 |
|---------|------|
| `.copilot/copilot-instructions.md` | 読み取り専用モードの指示 |
| `AGENTS.md` | Copilot CLI / Gemini CLI 等の汎用 AI エージェント指示 |

### 機能

- **copilot-instructions.md**: 読み取り専用指示のみ
- Skills: なし
- Agents: なし

### 制約

- ファイルの作成・編集・削除: 不可
- Git コミット・プッシュ: 不可
- テスト実行: 不可
