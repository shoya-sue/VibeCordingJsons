# AI Agent Configuration — Full Pattern

## Included Files

Copy all files from the `full/` directory to your project root or home directory.

## Features

### Claude Code
- 3-tier permissions (allow / ask / deny)
- 21 event hooks + ECC hooks (session continuity, cost tracking, MCP health, compact suggestion)
- 7 skills: explain-code, fix-issue, review-pr, generate-changelog, dependency-audit, create-issue, gh-workflow
- 30 agents via `everything-claude-code` plugin (code-reviewer, security-reviewer, architect, tdd-guide, language-specific reviewers, etc.)
- 50 rules: `ecc/common/` (10) + 8 languages × 5 (typescript, python, golang, rust, swift, java, kotlin, cpp)
- 2 custom rules: subagent-delegation, team-coordination
- 5 MCP servers: context7, playwright, deepwiki, excalidraw, github
- Agent Teams enabled with auto teammate mode
- Attribution enabled (commits and PRs)
- **Requires** `everything-claude-code` plugin

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
- Language-specific reviewers: typescript, python, go, rust, java, kotlin, cpp
- See `.claude/rules/subagent-delegation.md` for the full delegation matrix

### GitHub Operations

- All GitHub API operations use `gh` CLI exclusively
- Never use `curl` to api.github.com
- `gh api` is the last resort fallback

## Plugin Setup

```bash
# 1. Install plugin
/plugin marketplace add affaan-m/everything-claude-code
/plugin install everything-claude-code@everything-claude-code

# 2. Install rules (plugins cannot auto-distribute rules)
./install.sh full ~              # Global (recommended for personal use)
./install.sh full /path/to/proj  # Project-specific
```
