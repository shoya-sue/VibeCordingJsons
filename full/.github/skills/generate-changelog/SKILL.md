---
name: generate-changelog
description: Generate a Conventional Commits-based CHANGELOG from git log and PR history.
user-invokable: true
---

# generate-changelog

When to use: Version changelogs, release notes, change summaries.

## Procedure

1. Get latest tag: `git describe --tags --abbrev=0`
2. List commits: `git log <tag>..HEAD --oneline --no-merges`
3. Classify by Conventional Commits prefix:
   - `feat:` → Features
   - `fix:` → Bug Fixes
   - `docs:` → Documentation
   - `perf:` → Performance
   - `BREAKING CHANGE:` → Breaking Changes
4. Generate CHANGELOG in Keep a Changelog format

## Output

Breaking Changes at top, PR links included, merge commits excluded.
