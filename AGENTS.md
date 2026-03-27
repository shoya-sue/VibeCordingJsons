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

## AI Agent Usage Policy

This is a template repository. Follow these guidelines when working on it.

### Allowed Operations

- Read and edit all Markdown, JSON, and Bash files
- `git add` / `git commit`
- `bash install.sh` for testing

### Prohibited Operations

- Writing actual API keys or secrets into templates
- Running `install.sh` on production projects without confirmation
- Major structural changes to tier layouts (require prior confirmation)

### Notes for Template Editing

1. Maintain the design where features increase from `minimal/` → `standard/` → `full/`
2. SKILL.md requires `user-invokable: true` frontmatter
3. Agent files require `description` and `tools` frontmatter
4. After changes, verify install behavior with `./install.sh`
