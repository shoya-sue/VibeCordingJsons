---
description: Subagent delegation rules for cost optimization
---

# Subagent Delegation Rules

Subagent usage does not count against billing quotas. Always delegate work to subagents when possible.

## Delegation Matrix

| Task Type | Agent Type | Model |
|-----------|-----------|-------|
| Codebase exploration / questions | Explore | haiku |
| Code review (read-only) | code-reviewer agent | haiku |
| Test execution / fixing | test-runner agent | sonnet |
| Heavy implementation | general-purpose agent | sonnet |
| GitHub operations | general-purpose agent | sonnet |

## GitHub Operations

- Always use `gh` CLI for GitHub API operations, never raw `curl` to api.github.com
- Prefer `gh issue view`, `gh pr view`, `gh run list` over git remote queries
- Use `gh api` as last resort when `gh` subcommands are insufficient

## Anti-Patterns

- Do NOT perform research that a subagent could handle
- Do NOT run tests in the main context when test-runner agent exists
- Do NOT review code in the main context when code-reviewer agent exists
