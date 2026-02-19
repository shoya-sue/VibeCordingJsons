# Full - 全機能

信頼できる環境向け。Agent Teams・Sandbox・Hooks・Skills・Agents のフル構成。

## コピー先

| ファイル | コピー先 |
|---------|---------|
| `.claude/settings.json` | `.claude/settings.json` |
| `.claude/settings.local.json` | `.claude/settings.local.json`（個人用、gitignore） |
| `.claude/skills/explain-code/SKILL.md` | `.claude/skills/explain-code/SKILL.md` |
| `.claude/skills/fix-issue/SKILL.md` | `.claude/skills/fix-issue/SKILL.md` |
| `.claude/skills/review-pr/SKILL.md` | `.claude/skills/review-pr/SKILL.md` |
| `.claude/agents/code-reviewer.md` | `.claude/agents/code-reviewer.md` |
| `.claude/agents/test-runner.md` | `.claude/agents/test-runner.md` |
| `.claude/rules/code-style.md` | `.claude/rules/code-style.md` |
| `.claude/rules/api-conventions.md` | `.claude/rules/api-conventions.md` |
| `.mcp.json` | プロジェクトルート `.mcp.json` |
| `CLAUDE.md` | プロジェクトルート `CLAUDE.md` |
| `CLAUDE.local.md` | プロジェクトルート `CLAUDE.local.md`（個人用、gitignore） |

```bash
# install.sh で一括コピー
git clone https://github.com/shoya-sue/ClaudeCodeJsons.git
cd ClaudeCodeJsons
./install.sh full /path/to/your/project
```

GitHub PAT を使う場合は環境変数を設定:

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_xxxx"
```

## 含まれる機能

- **permissions**: allow / ask / deny の3段階制御
- **ask**: `git push`, `npm publish`, `docker push`, `terraform apply`, `kubectl apply`
- **hooks**: SessionStart / PreToolUse / PostToolUse / Stop の4イベント
- **skills**: `/explain-code`, `/fix-issue`, `/review-pr`
- **agents**: code-reviewer（読み取り専用レビュー）、test-runner（テスト実行・修正）
- **rules**: code-style, api-conventions（パス別ルール）
- **MCP**: 5サーバー（Context7, Playwright, DeepWiki, Excalidraw, GitHub）
- **sandbox**: 有効（network: github.com, npmjs, pypi のみ許可）
- **Agent Teams**: 有効（teammateMode: auto）
- **attribution**: コミット・PR に Claude Code 署名を自動付与

## 拒否される操作

`rm -rf /`, `mkfs`, `terraform destroy`, `kubectl delete namespace/node`, 本番 secrets 読み取り
