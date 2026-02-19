# Minimal - 読み取り専用

コードレビュー・探索専用。書き込み一切不可。

## コピー先

| ファイル | コピー先 |
|---------|---------|
| `.claude/settings.json` | `.claude/settings.json` |
| `.claude/settings.local.json` | `.claude/settings.local.json`（個人用、gitignore） |
| `CLAUDE.md` | プロジェクトルート `CLAUDE.md` |
| `CLAUDE.local.md` | プロジェクトルート `CLAUDE.local.md`（個人用、gitignore） |

```bash
# install.sh で一括コピー
git clone https://github.com/shoya-sue/ClaudeCodeJsons.git
cd ClaudeCodeJsons
./install.sh minimal /path/to/your/project
```

## 含まれる権限

- ソースコード・設定ファイルの読み取り
- `git status` / `git diff` / `git log` / `git branch` / `git show`
- Write / Edit / Skill / MCPSearch は全拒否
- MCP サーバー不要
