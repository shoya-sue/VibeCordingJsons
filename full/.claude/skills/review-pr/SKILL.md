---
name: review-pr
description: Review a Pull Request for bugs, security, and performance issues
argument-hint: "<pr-number>"
user-invokable: true
allowed-tools: ["Read", "Glob", "Grep", "Bash(gh pr *)"]
---

# review-pr

Review Pull Request `$ARGUMENTS`.

## Review Criteria

1. **Correctness** — Logic bugs
2. **Security** — Injection, auth gaps, etc.
3. **Performance** — N+1 queries, unnecessary re-renders
4. **Readability** — Naming, structure, comments
5. **Tests** — Coverage and edge cases

## Output Format

Per finding: **[High/Medium/Low]** filename:line — Description
