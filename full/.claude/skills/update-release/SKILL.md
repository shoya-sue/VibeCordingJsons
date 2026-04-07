---
name: update-release
description: Apply a VibeCording update doc (docs/YYYY-MM-DD-update.md), commit, PR, install to ~/, and cut a GitHub release
argument-hint: "<docs/YYYY-MM-DD-update.md> [version]"
user-invokable: true
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "Bash(git *)", "Bash(gh *)", "Bash(./install.sh *)"]
---

# update-release

Update doc: `$ARGUMENTS`

## Procedure

### 1. Parse the update document

Read the specified file (e.g. `docs/2026-04-07-update.md`).

Identify items by priority:
- 🔴 **必須** — implement all without exception
- 🟡 **推奨** — implement unless there is a clear reason to skip
- ⚪ **スキップ** — skip (record reason)

Before editing any file, check with Grep/Glob whether the change is already applied (no-op check).

### 2. Implement changes

Apply each 🔴 and 🟡 item. For each:
1. Read the target file first
2. Apply the minimal diff
3. Verify the change is correct

### 3. Determine next version

If `[version]` argument is provided, use it.
Otherwise, read the latest release tag with `gh release list --limit 1` and bump the minor version (e.g. v0.5.0 → v0.6.0).

### 4. Commit and create PR

```bash
git add <changed files>
git commit -m "feat: <summary from update doc>"
gh pr create --title "..." --body "..."
```

Ask the user to review and merge, or auto-merge if the user has pre-approved.

### 5. Install to home directory

After merge (or after commit if working on main):

```bash
git pull
./install.sh full ~
```

### 6. Create GitHub release

```bash
gh release create <version> \
  --title "<version> - <short title>" \
  --notes "<release notes>"
```

Release notes format:
- H2: theme of the release
- Sections per change area (Updated / New / Fixed)
- Table for counts/comparisons where applicable
- `**Full Changelog**` link at the bottom

### 7. Report

Output a summary:
- Files changed (list)
- Items skipped and why
- PR URL
- Release URL
