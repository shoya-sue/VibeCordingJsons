# Standard — Everyday Development (Recommended)

Optimal balanced settings for most developers.

## Copy Destinations

| File | Destination |
|------|-------------|
| `.claude/settings.json` | `.claude/settings.json` |
| `.claude/settings.local.json` | `.claude/settings.local.json` (personal, gitignored) |
| `.claude/skills/explain-code/SKILL.md` | `.claude/skills/explain-code/SKILL.md` |
| `.claude/rules/code-style.md` | `.claude/rules/code-style.md` |
| `project.code-workspace` | `<project-name>.code-workspace` |
| `.mcp.json` | Project root `.mcp.json` |
| `CLAUDE.md` | Project root `CLAUDE.md` |
| `CLAUDE.local.md` | Project root `CLAUDE.local.md` (personal, gitignored) |
| `AGENTS.md` | Project root `AGENTS.md` |

```bash
# Batch install with install.sh
git clone https://github.com/shoya-sue/VibeCordingJsons.git
cd VibeCordingJsons
./install.sh standard /path/to/your/project
```

If using a GitHub PAT, set the environment variable:

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_xxxx"
```

## Included Features

- **permissions**: 3-tier access control (allow / ask / deny)
- **ask**: `git push`, `npm publish` require confirmation each time
- **hooks**: 5 events (logging only, no notifications)
  - SessionStart, PreToolUse(Bash), PostToolUse(Write|Edit), PostToolUseFailure, Stop
- **skills**: `/explain-code` — code explanation skill
- **rules**: code-style — coding style conventions
- **MCP**: 4 servers (Context7, Playwright, DeepWiki, GitHub)
- **attribution**: Automatic Claude Code signature on commits and PRs

## Denied Operations

`rm -rf`, `sudo`, `force-push`, `hard reset`, reading secrets

## VSCode Workspace Settings

`project.code-workspace` includes the following settings:

| Category | Settings |
|----------|----------|
| **Editor** | formatOnSave, tabSize: 2, bracketPairColorization |
| **File management** | autoSave (1s delay), exclude, watcherExclude |
| **Search excludes** | node_modules, dist, build, .next, coverage, lock files |
| **Git** | repositoryScanMaxDepth: 3, autoRepositoryDetection |
| **Terminal** | zsh (macOS default) |
| **Extensions** | Copilot, Copilot Chat, GitLens, Prettier, ESLint, EditorConfig |
| **Tasks** | Claude Code auto-start (background) |

### Claude Code Auto-Start Task

The `Claude Code` task defined in the workspace runs Claude Code directly in the VSCode terminal panel:

- `claude -c` resumes an existing session, or starts a new one
- Runs in a zsh login shell (full environment variables and PATH loaded)
- Runs as a background task

> **Tip**: `Cmd+Shift+P` → `Tasks: Run Task` → `Claude Code` for manual start.

## Copilot CLI Settings

### Included Files

| File | Description |
|------|-------------|
| `.github/copilot-instructions.md` | Everyday development instructions with Claude Code integration |
| `.github/skills/explain-code/SKILL.md` | Code explanation skill |
| `.github/skills/code-reviewer/SKILL.md` | High-accuracy review skill |
| `AGENTS.md` | Universal AI agent instructions for Copilot CLI / Gemini CLI |

### Features

- **copilot-instructions.md**: Standard development instructions with Claude Code integration
- **Skills**: explain-code, code-reviewer (2 skills)
- Agents: None

### Usage

```
/explain-code @src/auth.ts
/code-reviewer
```
