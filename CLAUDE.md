# VibeCording Settings

Repository providing best practice templates for Claude Code and GitHub Copilot CLI.

## Tech Stack

Bash, JSON, Markdown (no application code; configuration templates only)

## Project Structure

```text
.
├── template/          # Single template (all features)
│   ├── .claude/       # settings.json + skills + agents + rules
│   ├── .github/       # copilot-instructions.md + 2 skill packages + 4 agents
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
- SKILL.md command bodies escape literal `$` before digits as `\$` (v2.1.163+)
- `.mcp.json` API keys use `${ENV_VAR}` format
- Template comments use `<!-- -->` format
- Both CLAUDE.md and AGENTS.md are placed at project root and in template/

## Commands

```bash
./install.sh           # Global install to ~ (default)
./install.sh ~         # Global install to home directory
./install.sh /path     # Install to specified project directory
bash scripts/check-counts.sh   # Verify documented counts match the filesystem (run before release)
```

## Important Notes

- Never write actual API keys or secrets in templates
- template/README.md is auto-displayed on GitHub at template/
- install.sh overwrites existing files (back up project-specific settings first)
- This repository's own `.claude/settings.json` is optimized for template development
- Recommended model in settings.local.json is `opusplan` (auto-switch: Opus for planning, Sonnet for execution)
- Hooks support all 27 events (including PostCompact, Elicitation, ElicitationResult, MessageDisplay, SessionEnd)
- Context management: no `CLAUDE_CODE_AUTO_COMPACT_WINDOW` override by default — it's a 1M-context opt-in workaround for [#43989](https://github.com/anthropics/claude-code/issues/43989); standard 200K users rely on native auto-compaction + active hygiene (`/context`, `/compact`, `/clear`, `/goal`, subagent delegation). See `template/.claude/rules/ecc/common/performance.md`
