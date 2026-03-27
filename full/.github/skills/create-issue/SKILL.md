---
name: create-issue
description: Create a GitHub Issue for discovered problems or improvements.
user-invokable: true
---

# create-issue

When to use: Bug reporting, feature tracking, tech debt documentation.

## Procedure

1. Organize: file location, reproduction steps, impact
2. Check duplicates: `gh issue list -s open --search "keyword"`
3. Select labels: bug, enhancement, tech-debt, security
4. Confirm with user
5. Create: `gh issue create --title "..." --body "..." --label "..."`

## Issue Template

```markdown
## Summary
[1-2 line description]

## Details
- **File**: `path/to/file:line`
- **Impact**: [affected areas]

## Steps to Reproduce (for bugs)
1. ...

## Expected Behavior
[what should happen]

## Priority
[High/Medium/Low with rationale]
```

## Rules

- Always confirm with user before creating
- Never include secrets in issue body
