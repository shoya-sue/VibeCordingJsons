# VibeCording Template — Claude Code + Codex + GitHub Copilot CLI

Complete configuration for Claude Code, Codex, and GitHub Copilot CLI with `ecc` plugin integration (from the `everything-claude-code` marketplace).

## What's Included

| Category | Contents |
|----------|----------|
| Claude Code settings | 3-tier permissions, 10 configured event hooks (of 27) + ECC hooks, Agent Teams, auto-memory |
| Skills (Claude) | 10 local + 261 via ECC plugin (ECC 2.0.0) |
| Agents (Claude) | 64 agents via ECC plugin (ECC 2.0.0; code-reviewer, architect, language-specific reviewers, etc.) |
| Rules | 55 ECC rules (common 10 + 9 languages × 5) + 3 custom (subagent-delegation, team-coordination, obsidian-mcp) |
| MCP Servers | obsidian, context7, playwright, deepwiki, excalidraw, github, plaud (optional, Plaud owners) |
| Codex | `.codex/config.toml` with high-effort model defaults, memories, matching MCP servers, and Codex-only fail-open hooks |
| Copilot CLI | copilot-instructions.md, 8 skills, 4 agents |
| VSCode | Workspace config with auto-start task |

## Quick Start

```bash
# 1. Install ECC plugin (plugin renamed everything-claude-code → ecc in 2.0.0)
/plugin marketplace add affaan-m/everything-claude-code
/plugin install ecc@everything-claude-code

# 2. Install template (copies rules that plugins can't distribute)
./install.sh            # Global install to ~
./install.sh /path/to/proj  # Project-specific install
```

## Key Features

### ECC Integration (everything-claude-code)

The plugin provides:
- **64 agents** (ECC 2.0.0) — language-specific reviewers (TS, Python, Go, Rust, Java, Kotlin, C++, Flutter, Swift), architect, planner, tdd-guide, security-reviewer, build resolvers, etc.
- **261 skills** (ECC 2.0.0) — TDD workflow, coding standards, API design, deployment patterns, deep research, and more
- **ECC hooks** — session continuity, cost tracking, MCP health monitoring, compact suggestions, console.log detection
- **Profile control** — `ECC_HOOK_PROFILE=standard` (minimal/standard/strict)

### Subagent Cost Optimization

Subagent usage does not count against billing quotas:
- Code review → `ecc:code-reviewer` (sonnet)
- Security review → `ecc:security-reviewer` (sonnet)
- Architecture → `ecc:architect` (opus)
- Language reviews → `ecc:{lang}-reviewer` (sonnet)
- Tests → test-runner (built-in, sonnet)
- Exploration → Explore agent (inherits session model, ≤opus; v2.1.198+ — was haiku)

### Team Coordination

Use Agent Teams when:
- 3+ independent files/modules need simultaneous changes
- Frontend + backend work can proceed in parallel
- Research and implementation can overlap

### Permissions Model

- **Allow**: File read/write on standard dirs, git ops, package managers, gh CLI, MCP tools
- **Ask**: git push, npm publish, docker push, terraform apply, kubectl apply
- **Deny**: Destructive ops, secret files, force push, hard reset

### Hooks (10 configured of 27 events + ECC)

All lifecycle events are logged, plus ECC enhancements:
- **Session continuity** — Auto-resumes context from previous sessions
- **Cost tracking** — Token usage and cost logged to `~/.claude/metrics/costs.jsonl`
- **MCP health** — Monitors MCP server availability, auto-reconnects on failure
- **Compact suggestion** — Advises manual `/compact` at logical boundaries (after 50+ tool calls)
- **Console.log detection** — Warns about debug statements in modified files
- **Desktop notifications** — macOS notification when Claude responds

## Customization

Edit `CLAUDE.md` and `settings.json` to match your project's needs. Use `CLAUDE.local.md` and `settings.local.json` for personal overrides (not committed to git).

### ECC Hook Control

```bash
# Disable specific ECC hooks
export ECC_DISABLED_HOOKS="stop:desktop-notify,post:edit:console-warn"

# Change hook profile
export ECC_HOOK_PROFILE=minimal  # or strict
```
