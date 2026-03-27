---
name: create-issue
description: Create a GitHub Issue for discovered problems or improvements
argument-hint: "<title>"
user-invokable: true
allowed-tools: ["Bash(gh issue *)", "Bash(git log *)", "Bash(git blame *)", "Read", "Glob", "Grep"]
---

# create-issue

Create a GitHub Issue for `$ARGUMENTS`.

## Procedure

1. Organize details (file location, reproduction steps, impact)
2. Select appropriate labels
3. Compose issue body
4. Confirm with user before creating via `gh issue create`

## Labels

| Situation | Label |
|-----------|-------|
| Crash / malfunction | `bug` |
| New feature / improvement | `enhancement` |
| Refactoring / tech debt | `tech-debt` |
| Vulnerability / auth gap | `security` |

## Issue Template

```
## Summary
[1-2 line description]

## Details
- **File**: `path/to/file.ts:L42`
- **Impact**: [affected components/features]

## Reproduction Steps (for bugs)
1. ...

## Expected Behavior
[what should happen]

## Priority
[High/Medium/Low with rationale]
```

## Important

- Always confirm with user before creating the issue
- Check for duplicates: `gh issue list -s open`
- Never include secrets or sensitive data in issue body
