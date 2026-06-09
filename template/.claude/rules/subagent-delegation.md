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

- Always use `gh` CLI for GitHub API operations, never raw `curl`/`wget` to api.github.com
- Prefer `gh issue view`, `gh pr view`, `gh run list` over git remote queries
- Use `gh api` (e.g. `gh api repos/<owner>/<repo>/compare/<a>...<b>`) when no dedicated `gh` subcommand fits — still never `curl` the API
- For non-GitHub web pages (changelogs, docs, release notes), use the `WebFetch` tool, not `curl`

**Why this matters (permission friction):** `Bash(gh *)` and `WebFetch(*)` are allowlisted, so they run without a prompt. `Bash(curl *)`/`Bash(wget *)` sit in the `ask` list, so every raw `curl` to a URL forces a manual approval prompt. Routing through `gh`/`WebFetch` keeps the workflow frictionless **and** matches official guidance: Bash arg patterns like `Bash(curl <url> *)` are fragile, and per `deny → ask → allow` precedence a `curl` allow rule can't override the broad `curl *` ask rule anyway. This applies in the main context and in every spawned subagent — pass the directive into subagent prompts when delegating GitHub/web research.

## Anti-Patterns

- Do NOT perform research that a subagent could handle
- Do NOT run tests in the main context when test-runner agent exists
- Do NOT review code in the main context when a language-specific reviewer exists
