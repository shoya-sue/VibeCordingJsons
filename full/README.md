# Full Pattern — All Features Enabled + ECC Integration

Complete configuration for Claude Code and GitHub Copilot CLI with `everything-claude-code` plugin integration.

## What's Included

| Category | Contents |
|----------|----------|
| Claude Code settings | 3-tier permissions, 21 hooks + ECC hooks, Agent Teams, auto-memory |
| Skills (Claude) | 7 local + 136 via ECC plugin |
| Agents (Claude) | 30 agents via ECC plugin (code-reviewer, architect, language-specific reviewers, etc.) |
| Rules | 50 ECC rules (common + 8 languages) + subagent-delegation + team-coordination |
| MCP Servers | context7, playwright, deepwiki, excalidraw, github |
| Copilot CLI | copilot-instructions.md, 8 skills, 4 agents |
| VSCode | Workspace config with auto-start task |

## Quick Start

```bash
# 1. Install ECC plugin
/plugin marketplace add affaan-m/everything-claude-code
/plugin install everything-claude-code@everything-claude-code

# 2. Install template (copies rules that plugins can't distribute)
./install.sh full ~              # Global
./install.sh full /path/to/proj  # Project
```

## Key Features

### ECC Integration (everything-claude-code)

The plugin provides:
- **30 agents** — language-specific reviewers (TS, Python, Go, Rust, Java, Kotlin, C++, Flutter, Swift), architect, planner, tdd-guide, security-reviewer, build resolvers, etc.
- **136 skills** — TDD workflow, coding standards, API design, deployment patterns, deep research, and more
- **ECC hooks** — session continuity, cost tracking, MCP health monitoring, compact suggestions, console.log detection
- **Profile control** — `ECC_HOOK_PROFILE=standard` (minimal/standard/strict)

### Subagent Cost Optimization

Subagent usage does not count against billing quotas:
- Code review → `everything-claude-code:code-reviewer` (sonnet)
- Security review → `everything-claude-code:security-reviewer` (sonnet)
- Architecture → `everything-claude-code:architect` (opus)
- Language reviews → `everything-claude-code:{lang}-reviewer` (sonnet)
- Tests → test-runner (built-in, sonnet)
- Exploration → Explore agent (haiku)

### Team Coordination

Use Agent Teams when:
- 3+ independent files/modules need simultaneous changes
- Frontend + backend work can proceed in parallel
- Research and implementation can overlap

### Permissions Model

- **Allow**: File read/write on standard dirs, git ops, package managers, gh CLI, MCP tools
- **Ask**: git push, npm publish, docker push, terraform apply, kubectl apply
- **Deny**: Destructive ops, secret files, force push, hard reset

### Hooks (21 Events + ECC)

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
