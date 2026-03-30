# AI Agent Configuration — Full Pattern

## Included Files

Copy all files from the `full/` directory to your project root or home directory.

## Features

### Claude Code
- 3-tier permissions (allow / ask / deny)
- 21 event hooks (lifecycle, tools, subagents, teams, worktrees, compaction, elicitation)
- 7 skills: explain-code, fix-issue, review-pr, generate-changelog, dependency-audit, create-issue, gh-workflow
- 3 agents: code-reviewer (haiku, read-only), test-runner (sonnet, edits allowed), security-reviewer (haiku, read-only)
- 4 rules: code-style, api-conventions, subagent-delegation, team-coordination
- 5 MCP servers: context7, playwright, deepwiki, excalidraw, github
- Agent Teams enabled with auto teammate mode
- Attribution enabled (commits and PRs)
- everything-claude-code plugin enabled

### Copilot CLI
- copilot-instructions.md with full agent/skill/fleet configuration
- 8 skills: explain-code, code-reviewer, fix-issue, review-pr, test-runner, create-issue, generate-changelog, dependency-audit
- 4 agents: code-reviewer, test-runner, code-explorer, github-workflow

### Denied Operations

- `rm -rf`, `mkfs`, `dd if=/dev/zero` — destructive filesystem operations
- `terraform destroy`, `terraform apply -auto-approve` — unreviewed infra changes
- `kubectl delete namespace/node` — cluster-critical deletions
- Reading `.env*`, `secrets/`, `.aws/`, `.ssh/`, `*.key`, `*.pem`
- `git push --force`, `git reset --hard` — destructive git operations

### Subagent Delegation

All skills enforce subagent delegation for cost optimization:
- Subagent usage does not count against billing quotas
- Main agent coordinates; subagents execute
- See `.claude/rules/subagent-delegation.md` for the full delegation matrix

### GitHub Operations

- All GitHub API operations use `gh` CLI exclusively
- Never use `curl` to api.github.com
- `gh api` is the last resort fallback

## Installation

```bash
./install.sh full ~              # Global (recommended for personal use)
./install.sh full /path/to/proj  # Project-specific
```
