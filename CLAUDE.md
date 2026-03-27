# VibeCording Settings

Repository providing best practice templates for Claude Code and GitHub Copilot CLI.

## Tech Stack

Bash, JSON, Markdown (no application code; configuration templates only)

## Project Structure

```text
.
├── minimal/           # Read-only pattern
│   ├── .claude/       # settings.json, settings.local.json
│   ├── .github/       # copilot-instructions.md
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   └── README.md
├── standard/          # Everyday development pattern (recommended)
│   ├── .claude/       # settings + skills + rules
│   ├── .github/       # copilot-instructions.md + 2 skills
│   ├── .mcp.json
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   └── README.md
├── full/              # All features pattern
│   ├── .claude/       # settings + skills + agents + rules
│   ├── .github/       # copilot-instructions.md + 8 skills + 4 agents
│   ├── .mcp.json
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   └── README.md
├── install.sh         # Batch install script
└── README.md          # Documentation
```

## Conventions

- Each pattern is self-contained (can be copied individually from GitHub)
- settings.json permissions follow the principle of least privilege
- SKILL.md frontmatter uses `user-invokable` (not `user-invocable`)
- SKILL.md supports `allowed-tools` to restrict tools (e.g., `allowed-tools: ["Read", "Glob", "Grep"]`)
- SKILL.md can use `${CLAUDE_SKILL_DIR}` to reference the skill's own directory
- `.mcp.json` API keys use `${ENV_VAR}` format
- Template comments use `<!-- -->` format
- Both CLAUDE.md and AGENTS.md are placed at project root and in each tier

## Commands

```bash
./install.sh minimal /path/to/project   # Install minimal pattern
./install.sh standard /path/to/project  # Install standard pattern
./install.sh full /path/to/project      # Install full pattern
./install.sh full ~                     # Global install to home directory
```

## Important Notes

- Never write actual API keys or secrets in templates
- Each pattern's README.md is auto-displayed on GitHub
- install.sh overwrites existing files (back up project-specific settings first)
- This repository's own `.claude/settings.json` is optimized for template development
- Recommended model in settings.local.json is `opusplan` (auto-switch: Opus for planning, Sonnet for execution)
- Hooks support all 21 events (including PostCompact, Elicitation, ElicitationResult)
