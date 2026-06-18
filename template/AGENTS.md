# AI Agent Configuration

## Included Files

Copy all files from the `template/` directory to your project root or home directory (or run `./install.sh`).

## Features

### Claude Code
- 3-tier permissions (allow / ask / deny)
- 10 configured event hooks (of 27 supported by Claude Code) + ECC hooks (session continuity, cost tracking, MCP health, compact suggestion)
- `claude agents` — Agent view (Research Preview): all sessions in a unified list (configure dispatched sessions with `--add-dir` / `--settings` / `--mcp-config` / `--plugin-dir` / `--permission-mode` / `--model` / `--effort` / `--agent` / `--dangerously-skip-permissions` / `--allow-dangerously-skip-permissions`, v2.1.142–143; `--agent` overrides the `agent` settings key honored since v2.1.157)
- 10 skills: explain-code, fix-issue, review-pr, generate-changelog, dependency-audit, create-issue, gh-workflow, obsidian-synthesis, sync-memory, voice-input
- Voice input: native `/voice` dictation enabled and set to Japanese (`voice`/`language` in settings.json). The `voice-input` skill cleans up rough Japanese dictation, and `.claude/skills/voice-input/scripts/voice-dictate.sh` provides a fully-local offline whisper.cpp path (harness-agnostic — also usable from Copilot CLI / any terminal). Native `/voice` itself is Claude Code only. See `.claude/skills/voice-input/SETUP.md`
- 64 agents via `ecc` plugin (ECC 2.0.0, from the `everything-claude-code` marketplace; plugin-provided — code-reviewer, security-reviewer, architect, tdd-guide, language-specific reviewers, etc.; addressed as `ecc:<agent>`)
- 55 rules: `ecc/common/` (10) + 9 languages × 5 (typescript, python, golang, rust, swift, java, kotlin, cpp, php)
- 3 custom rules: subagent-delegation, team-coordination, obsidian-mcp
- 6 MCP servers: obsidian, context7, playwright, deepwiki, excalidraw, github
- Agent Teams enabled with auto teammate mode
- Attribution enabled (commits and PRs)
- **Requires** the `ecc` plugin (from the `everything-claude-code` marketplace)

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
# 1. Install plugin (renamed everything-claude-code → ecc in 2.0.0)
/plugin marketplace add affaan-m/everything-claude-code
/plugin install ecc@everything-claude-code

# 2. Install rules (plugins cannot auto-distribute rules)
./install.sh ~              # Global (recommended for personal use)
./install.sh /path/to/proj  # Project-specific
```
