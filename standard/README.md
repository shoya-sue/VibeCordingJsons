# Standard - 日常開発（推奨）

ほとんどの開発者に最適なバランス設定。

## コピー先

| ファイル | コピー先 |
|---------|---------|
| `.claude/settings.json` | `.claude/settings.json` |
| `.claude/settings.local.json` | `.claude/settings.local.json`（個人用、gitignore） |
| `.claude/skills/explain-code/SKILL.md` | `.claude/skills/explain-code/SKILL.md` |
| `.claude/rules/code-style.md` | `.claude/rules/code-style.md` |
| `project.code-workspace` | `<プロジェクト名>.code-workspace` |
| `.mcp.json` | プロジェクトルート `.mcp.json` |
| `CLAUDE.md` | プロジェクトルート `CLAUDE.md` |
| `CLAUDE.local.md` | プロジェクトルート `CLAUDE.local.md`（個人用、gitignore） |
| `AGENTS.md` | プロジェクトルート `AGENTS.md` |

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
- **hooks**: 5イベント対応（ログ出力のみ、通知なし）
  - SessionStart, PreToolUse(Bash), PostToolUse(Write|Edit), PostToolUseFailure, Stop
- **skills**: `/explain-code` — コード解説スキル
- **rules**: code-style — コーディングスタイルルール
- **MCP**: 4サーバー（Context7, Playwright, DeepWiki, GitHub）
- **attribution**: コミット・PR に Claude Code 署名を自動付与

## 拒否される操作

`rm -rf`, `sudo`, `force-push`, `hard reset`, secrets 読み取り

## VSCode ワークスペース設定

`project.code-workspace` に以下の設定を含む:

| カテゴリ | 設定内容 |
|---------|---------|
| **エディタ** | formatOnSave, tabSize: 2, bracketPairColorization |
| **ファイル管理** | autoSave (1秒遅延), exclude, watcherExclude |
| **検索除外** | node_modules, dist, build, .next, coverage, lock files |
| **Git** | repositoryScanMaxDepth: 3, autoRepositoryDetection |
| **ターミナル** | zsh（macOS デフォルト） |
| **拡張機能** | Copilot, Copilot Chat, GitLens, Prettier, ESLint, EditorConfig |
| **タスク** | Claude Code 自動起動（バックグラウンド） |

### Claude Code 自動起動タスク

ワークスペースに定義された `🟩 Claude Code` タスクにより、VSCode のターミナルパネルで Claude Code を直接操作可能:

- `claude -c` で既存セッション復帰、なければ新規起動
- zsh ログインシェルで実行（環境変数・パスを完全読み込み）
- バックグラウンドタスクとして常駐

> **Tip**: `Cmd+Shift+P` → `Tasks: Run Task` → `🟩 Claude Code` で手動起動も可能。

## Copilot CLI 設定

### 含まれるファイル

| ファイル | 説明 |
|---------|------|
| `.github/copilot-instructions.md` | 日常開発指示・Claude Code 連携 |
| `.github/skills/explain-code/SKILL.md` | コード解説スキル |
| `.github/skills/code-reviewer/SKILL.md` | 高精度レビュースキル |
| `AGENTS.md` | Copilot CLI / Gemini CLI 等の汎用 AI エージェント指示 |

### 機能

- **copilot-instructions.md**: 標準開発指示・Claude Code 連携
- **Skills**: explain-code, code-reviewer (2個)
- Agents: なし

### 使い方

```
/explain-code @src/auth.ts
/code-reviewer
```
