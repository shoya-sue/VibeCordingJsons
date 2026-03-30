# Minimal — Read-Only

Code review and exploration only. No write access.

## Copy Destinations

| File | Destination |
|------|-------------|
| `.claude/settings.json` | `.claude/settings.json` |
| `.claude/settings.local.json` | `.claude/settings.local.json` (personal, gitignored) |
| `project.code-workspace` | `<project-name>.code-workspace` |
| `CLAUDE.md` | Project root `CLAUDE.md` |
| `CLAUDE.local.md` | Project root `CLAUDE.local.md` (personal, gitignored) |
| `AGENTS.md` | Project root `AGENTS.md` |

```bash
# Batch install with install.sh
git clone https://github.com/shoya-sue/VibeCordingJsons.git
cd VibeCordingJsons
./install.sh minimal /path/to/your/project
```

## Included Permissions

- Read source code and configuration files
- `git status` / `git diff` / `git log` / `git branch` / `git show`
- Write / Edit / Skill / MCPSearch are all denied
- No MCP servers required

## VSCode Workspace Settings

`project.code-workspace` includes the following settings:

| Category | Settings |
|----------|----------|
| **Editor** | formatOnSave, tabSize: 2, bracketPairColorization |
| **File excludes** | `.git`, `.DS_Store`, `__pycache__` |
| **Terminal** | zsh (macOS default) |
| **Extensions** | GitHub Copilot, Copilot Chat |

> **Note**: No Claude Code auto-start task is included since this is a read-only configuration.

## Copilot CLI Settings

### Included Files

| File | Description |
|------|-------------|
| `.github/copilot-instructions.md` | Read-only mode instructions |
| `AGENTS.md` | Universal AI agent instructions for Copilot CLI / Gemini CLI |

### Features

- **copilot-instructions.md**: Read-only instructions only
- Skills: None
- Agents: None

### Constraints

- File creation / editing / deletion: Not allowed
- Git commit / push: Not allowed
- Test execution: Not allowed
