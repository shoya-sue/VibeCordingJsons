---
name: gh-workflow
description: Manage GitHub workflows — issues, PRs, CI/CD status — using gh CLI
argument-hint: "<command> [args]"
user-invokable: true
allowed-tools: ["Bash(gh *)", "Bash(git *)", "Read", "Glob", "Grep"]
---

# gh-workflow

Execute GitHub workflow operations using `$ARGUMENTS`.

## Supported Operations

### Issues
- `gh issue view <number>` — Read issue details
- `gh issue create --title "..." --body "..."` — Create new issue
- `gh issue list -s open` — List open issues
- `gh issue edit <number>` — Update issue

### Pull Requests
- `gh pr view <number>` — Read PR details
- `gh pr create --title "..." --body "..."` — Create PR
- `gh pr diff <number>` — View PR diff
- `gh pr merge <number> --squash` — Merge PR (confirm with user first)
- `gh pr review <number> --approve` — Approve PR

### CI/CD
- `gh run list --limit 5` — Recent workflow runs
- `gh run view <run-id> --log-failed` — Failed run logs

## Rules

- Always use `gh` CLI — never `curl` to api.github.com
- Use `gh api` only when no dedicated `gh` subcommand exists
- Confirm with user before: creating issues, merging PRs, approving PRs
- Include `Closes #<number>` in PR body when fixing issues
