# VibeCording Settings

Repository providing best-practice templates for Claude Code, Codex, and GitHub Copilot CLI.

## Tech Stack

Bash, JSON, Markdown (no application code; configuration templates only)

## Project Structure

```text
.
├── template/          # Single template (all features enabled)
│   ├── .claude/       # settings.json + skills + agents + rules + hooks + scheduled-tasks
│   ├── .github/       # copilot-instructions.md + 2 skill packages + 4 agents
│   ├── .codex/        # config.toml + Codex hooks
│   ├── .mcp.json
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   └── README.md
├── install.sh         # Installer script
├── docs/              # Dated update history
├── AGENTS.md
├── CLAUDE.md
└── README.md          # Documentation
```

## Conventions

- Single template: all features enabled (no tiers)
- settings.json permissions follow the principle of least privilege
- SKILL.md frontmatter uses `user-invokable` (not `user-invocable`); `scheduled-tasks/` skills run via scheduler and omit it
- SKILL.md supports `allowed-tools` to restrict tools (e.g., `allowed-tools: ["Read", "Glob", "Grep"]`)
- `.mcp.json` API keys use `${ENV_VAR}` format
- Template comments use `<!-- -->` format
- Both CLAUDE.md and AGENTS.md are placed at project root and in `template/`

## Commands

```bash
./install.sh                       # Global install to ~ (default)
./install.sh ~                     # Global install to home directory
./install.sh /path/to/project      # Install to a specific project directory
bash scripts/check-counts.sh       # Verify documented counts match the filesystem
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
- Major structural changes to the `template/` layout (require prior confirmation)

### Notes for Template Editing

1. The repository ships a single unified `template/` — do not reintroduce tiered layouts
2. SKILL.md requires `user-invokable: true` frontmatter (except `scheduled-tasks/` skills)
3. Agent files require `description` and `tools` frontmatter
4. After changes, verify install behavior with `./install.sh` and run `bash scripts/check-counts.sh` to confirm documented counts still match the filesystem

### GitHub Operations

- Always use `gh` CLI for GitHub API operations, never raw `curl`/`wget` to api.github.com (in Claude Code these hit the `curl *` ask rule and prompt; `gh *` is allowlisted)
- For non-GitHub web pages, use the harness web-fetch tool, not `curl`
