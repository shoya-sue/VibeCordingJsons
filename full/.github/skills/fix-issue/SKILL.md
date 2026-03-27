---
name: fix-issue
description: Read a GitHub Issue and apply code fixes. Use issue URL or number.
user-invokable: true
---

# fix-issue

When to use: Fixing bugs from Issues, implementing feature requests.

## Procedure

1. Get issue content: `gh issue view <number> --json title,body,labels`
2. Check for existing PRs: `gh pr list --search "Closes #<number>"`
3. Investigate impact: `grep -r "keyword" src/`
4. Implement fix
5. Commit: `git commit -m "fix: [summary]\n\nCloses #<number>"`
6. Create PR: `gh pr create --title "fix: [title]" --body "Closes #<number>"`

## Rules

- Always use `gh` CLI for GitHub operations
- Confirm with user before creating PRs
