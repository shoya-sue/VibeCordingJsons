# Standard - 日常開発（推奨）

ほとんどの開発者に最適なバランス設定。

## コピー先

| ファイル | コピー先 |
|---------|---------|
| `.claude/settings.json` | `.claude/settings.json` |
| `.claude/settings.local.json` | `.claude/settings.local.json`（個人用、gitignore） |
| `.claude/skills/explain-code/SKILL.md` | `.claude/skills/explain-code/SKILL.md` |
| `.claude/rules/code-style.md` | `.claude/rules/code-style.md` |
| `.mcp.json` | プロジェクトルート `.mcp.json` |
| `CLAUDE.md` | プロジェクトルート `CLAUDE.md` |
| `CLAUDE.local.md` | プロジェクトルート `CLAUDE.local.md`（個人用、gitignore） |

```bash
# install.sh で一括コピー
git clone https://github.com/shoya-sue/VibeCordingJsons.git
cd VibeCordingJsons
./install.sh standard /path/to/your/project
```

GitHub PAT を使う場合は環境変数を設定:

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_xxxx"
```

## 含まれる機能

- **permissions**: allow / ask / deny の3段階制御
- **ask**: `git push`, `npm publish` は毎回確認
- **hooks**: PostToolUse（ファイル変更通知）、Stop（セッション終了ログ）
- **skills**: `/explain-code` — コード解説スキル
- **rules**: code-style — コーディングスタイルルール
- **MCP**: 4サーバー（Context7, Playwright, DeepWiki, GitHub）
- **attribution**: コミット・PR に Claude Code 署名を自動付与

## 拒否される操作

`rm -rf`, `sudo`, `force-push`, `hard reset`, secrets 読み取り

## Copilot CLI 設定

### 含まれるファイル

| ファイル | 説明 |
|---------|------|
| `.copilot/copilot-instructions.md` | 日常開発指示・Claude Code 連携 |
| `.copilot/skills/explain-code/SKILL.md` | コード解説スキル |
| `.copilot/skills/code-reviewer/SKILL.md` | 高精度レビュースキル |

### 機能

- **copilot-instructions.md**: 標準開発指示・Claude Code 連携
- **Skills**: explain-code, code-reviewer (2個)
- Agents: なし

### 使い方

```
/explain-code @src/auth.ts
/code-reviewer
```
