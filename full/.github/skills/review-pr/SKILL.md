---
name: review-pr
description: Review a Pull Request by analyzing diffs for bugs, security, and performance issues.
user-invokable: true
---

# review-pr

When to use: PR reviews, security checks, pre-merge validation.

## Procedure

1. Get changes: `gh pr view <number>` and `gh pr diff <number>`
2. Review criteria:
   - **Correctness** — Logic bugs
   - **Security** — Injection, auth gaps
   - **Performance** — N+1 queries, expensive operations
   - **Test coverage** — Missing tests for new code
   - **Breaking changes** — API compatibility
3. Post review: `gh pr review <number> --comment --body "..."`

## Output Format

- Issues found (with file:line references)
- Concerns (potential problems)
- Positives (good patterns observed)
- Verdict: Approve / Request Changes / Comment
