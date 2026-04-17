---
name: fix-issue
description: Read a GitHub Issue and propose/apply code fixes
argument-hint: "<issue-number>"
user-invokable: true
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "Bash(gh issue *)", "Bash(git *)", "Bash(npm test *)"]
---

# fix-issue

Fix GitHub Issue `$ARGUMENTS`.

## Procedure

1. Run `gh issue view $ARGUMENTS` to read the issue
2. Identify the relevant code
3. Analyze root cause
4. Write the fix
5. Run tests to verify
6. Output a summary of changes
