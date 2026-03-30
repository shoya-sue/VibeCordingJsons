# Full Pattern — All Features Enabled

Complete configuration for Claude Code and GitHub Copilot CLI with all features activated.

## What's Included

| Category | Contents |
|----------|----------|
| Claude Code settings | 3-tier permissions, 21 hooks, Agent Teams, auto-memory |
| Skills (Claude) | explain-code, fix-issue, review-pr, generate-changelog, dependency-audit, create-issue, gh-workflow |
| Agents (Claude) | code-reviewer (haiku), test-runner (sonnet), security-reviewer (haiku) |
| Rules | code-style, api-conventions, subagent-delegation, team-coordination |
| MCP Servers | context7, playwright, deepwiki, excalidraw, github |
| Copilot CLI | copilot-instructions.md, 8 skills, 4 agents |
| VSCode | Workspace config with auto-start task |

## Quick Start

```bash
# Global install (applies to all projects)
./install.sh full ~

# Project install
./install.sh full /path/to/your/project
```

## Key Features

### Subagent Cost Optimization

Subagent usage does not count against billing quotas. The configuration enforces:
- Read-only tasks → Explore agent (haiku)
- Code review → code-reviewer agent (haiku)
- Security review → security-reviewer agent (haiku)
- Tests → test-runner agent (sonnet)
- GitHub ops → always via `gh` CLI

### Team Coordination

Use Agent Teams when:
- 3+ independent files/modules need simultaneous changes
- Frontend + backend work can proceed in parallel
- Research and implementation can overlap

### Permissions Model

- **Allow**: File read/write on standard dirs, git ops, package managers, gh CLI, MCP tools
- **Ask**: git push, npm publish, docker push, terraform apply, kubectl apply
- **Deny**: Destructive ops, secret files, force push, hard reset

### Hooks (21 Events)

All lifecycle events are logged:
- Session: SessionStart, SessionEnd, Stop
- Tools: PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest
- User: UserPromptSubmit
- Notifications: Notification, InstructionsLoaded, ConfigChange
- Subagents: SubagentStart, SubagentStop
- Teams: TeammateIdle, TaskCompleted
- Worktrees: WorktreeCreate, WorktreeRemove
- Compaction: PreCompact, PostCompact
- MCP: Elicitation, ElicitationResult

## Customization

Edit `CLAUDE.md` and `settings.json` to match your project's needs. Use `CLAUDE.local.md` and `settings.local.json` for personal overrides (not committed to git).
