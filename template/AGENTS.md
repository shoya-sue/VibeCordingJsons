# AI Agent Configuration

## Included Files

Copy all files from the `template/` directory to your project root or home directory (or run `./install.sh`).

## Features

### Claude Code
- 3-tier permissions (allow / ask / deny)
- 10 configured event hooks (of 27 supported by Claude Code) + ECC hooks (session continuity, cost tracking, MCP health, compact suggestion)
- `claude agents` — Agent view (Research Preview): all sessions in a unified list (configure dispatched sessions with `--add-dir` / `--settings` / `--mcp-config` / `--plugin-dir` / `--permission-mode` / `--model` / `--effort` / `--agent` / `--dangerously-skip-permissions` / `--allow-dangerously-skip-permissions`, v2.1.142–143; `--agent` overrides the `agent` settings key honored since v2.1.157)
- 10 skills: explain-code, fix-issue, review-pr, generate-changelog, dependency-audit, create-issue, gh-workflow, obsidian-synthesis, sync-memory, update-release
- 38 agents via `everything-claude-code` plugin (ECC 1.10.0; plugin-provided — code-reviewer, security-reviewer, architect, tdd-guide, language-specific reviewers, etc.)
- 55 rules: `ecc/common/` (10) + 9 languages × 5 (typescript, python, golang, rust, swift, java, kotlin, cpp, php)
- 3 custom rules: subagent-delegation, team-coordination, obsidian-mcp
- 6 MCP servers: obsidian, context7, playwright, deepwiki, excalidraw, github
- Agent Teams enabled with auto teammate mode
- Attribution enabled (commits and PRs)
- **Requires** `everything-claude-code` plugin

### Copilot CLI
- copilot-instructions.md with full agent/skill/fleet configuration
- 8 skills documented in copilot-instructions.md (2 shipped as SKILL.md packages: code-reviewer, test-runner): explain-code, code-reviewer, fix-issue, review-pr, test-runner, create-issue, generate-changelog, dependency-audit
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
- Never use `curl`/`wget` to api.github.com (in Claude Code these hit the `curl *` ask rule and prompt; `gh *` is allowlisted)
- `gh api repos/<owner>/<repo>/...` is the fallback when no `gh` subcommand fits
- Fetch non-GitHub web pages with the harness web-fetch tool, not `curl`

## Plugin Setup

```bash
# 1. Install plugin
/plugin marketplace add affaan-m/everything-claude-code
/plugin install everything-claude-code@everything-claude-code

# 2. Install rules (plugins cannot auto-distribute rules)
./install.sh ~              # Global (recommended for personal use)
./install.sh /path/to/proj  # Project-specific
```
