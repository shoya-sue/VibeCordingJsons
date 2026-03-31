---
description: Subagent delegation rules for cost optimization — uses everything-claude-code agents
---

# Subagent Delegation Rules

Subagent usage does not count against billing quotas. Always delegate work to subagents when possible.
Agents are provided by the `everything-claude-code` plugin — no custom agent files needed.

## Delegation Matrix

| Task Type | Agent Type | Model |
|-----------|-----------|-------|
| Codebase exploration | Explore | haiku |
| Code review | everything-claude-code:code-reviewer | sonnet |
| Security review | everything-claude-code:security-reviewer | sonnet |
| Test execution / fixing | test-runner (built-in) | sonnet |
| Heavy implementation | general-purpose | sonnet |
| Architecture planning | everything-claude-code:architect | opus |
| Documentation updates | everything-claude-code:doc-updater | haiku |
| Python review | everything-claude-code:python-reviewer | sonnet |
| TypeScript review | everything-claude-code:typescript-reviewer | sonnet |
| Go review | everything-claude-code:go-reviewer | sonnet |
| Rust review | everything-claude-code:rust-reviewer | sonnet |
| Java review | everything-claude-code:java-reviewer | sonnet |
| Kotlin review | everything-claude-code:kotlin-reviewer | sonnet |
| C++ review | everything-claude-code:cpp-reviewer | sonnet |

## GitHub Operations

- Always use `gh` CLI for GitHub API operations, never raw `curl` to api.github.com
- Prefer `gh issue view`, `gh pr view`, `gh run list` over git remote queries
- Use `gh api` as last resort when `gh` subcommands are insufficient

## Anti-Patterns

- Do NOT perform research that a subagent could handle
- Do NOT run tests in the main context when test-runner agent exists
- Do NOT review code in the main context when a language-specific reviewer exists
