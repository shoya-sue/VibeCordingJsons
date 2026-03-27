---
name: generate-changelog
description: Generate a Conventional Commits-based CHANGELOG from git history
argument-hint: "<from-ref>..<to-ref>"
user-invokable: true
allowed-tools: ["Read", "Write", "Edit", "Glob", "Bash(git log *)", "Bash(git tag *)", "Bash(git describe *)", "Bash(gh pr list *)", "Bash(gh release *)"]
---

# generate-changelog

Generate CHANGELOG for range `$ARGUMENTS`. If no argument, use latest tag to HEAD.

## Procedure

1. Identify range: `git describe --tags --abbrev=0` for latest tag
2. Classify commits by Conventional Commits prefix
3. Generate CHANGELOG in Keep a Changelog format
4. Write to file

## Classification

| Prefix | Category |
|--------|----------|
| `feat:` | Features |
| `fix:` | Bug Fixes |
| `docs:` | Documentation |
| `perf:` | Performance |
| `refactor:` | Refactoring |
| `test:` | Tests |
| `chore:` `ci:` `build:` | Maintenance |
| `BREAKING CHANGE:` / `\!:` | Breaking Changes |

## Output Format (Keep a Changelog)

```
## [Unreleased] - YYYY-MM-DD

### Breaking Changes
### Features
### Bug Fixes
### Maintenance
```

Include PR numbers as links. Exclude merge commits (`--no-merges`).
