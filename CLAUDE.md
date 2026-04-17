# VibeCording Settings

Repository providing best practice templates for Claude Code and GitHub Copilot CLI.

## Tech Stack

Bash, JSON, Markdown (no application code; configuration templates only)

## Project Structure

```text
.
├── template/          # Single template (all features)
│   ├── .claude/       # settings.json + skills + agents + rules
│   ├── .github/       # copilot-instructions.md + 8 skills + 4 agents
│   ├── .mcp.json
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   └── README.md
├── install.sh         # Installer script
├── docs/              # Update history
└── README.md          # Documentation
```

## Conventions

- Single template: all features enabled (no tiers)
- settings.json permissions follow the principle of least privilege
- SKILL.md frontmatter uses `user-invokable` (not `user-invocable`)
- SKILL.md supports `allowed-tools` to restrict tools (e.g., `allowed-tools: ["Read", "Glob", "Grep"]`)
- SKILL.md can use `${CLAUDE_SKILL_DIR}` to reference the skill's own directory
- `.mcp.json` API keys use `${ENV_VAR}` format
- Template comments use `<!-- -->` format
- Both CLAUDE.md and AGENTS.md are placed at project root and in template/

## Commands

```bash
./install.sh           # Global install to ~ (default)
./install.sh ~         # Global install to home directory
./install.sh /path     # Install to specified project directory
```

## Important Notes

- Never write actual API keys or secrets in templates
- template/README.md is auto-displayed on GitHub at template/
- install.sh overwrites existing files (back up project-specific settings first)
- This repository's own `.claude/settings.json` is optimized for template development
- Recommended model in settings.local.json is `opusplan` (auto-switch: Opus for planning, Sonnet for execution)
- Hooks support all 26 events (including PostCompact, Elicitation, ElicitationResult, SessionEnd)
