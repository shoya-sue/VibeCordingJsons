---
name: update-release
description: Research latest Claude Code / ECC changes, generate update doc, implement changes, commit, PR, install to ~/, and cut a GitHub release
argument-hint: "[docs/YYYY-MM-DD-update.md] [version]"
user-invokable: true
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "WebSearch", "WebFetch", "Bash(git *)", "Bash(gh *)", "Bash(./install.sh *)"]
---

# update-release

Arguments: `$ARGUMENTS`

## Procedure

### 0. Prepare the update document

**If `$ARGUMENTS` points to an existing file** — skip generation, go to step 1.

**If the file does not exist (or no argument given)** — generate it:

1. Determine the filename: `docs/YYYY-MM-DD-update.md` using today's date
2. Research the latest changes via web search:
   - Claude Code changelog: search "Claude Code changelog site:docs.anthropic.com" and fetch the page
   - ECC plugin releases: fetch `https://github.com/anthropics/claude-code/releases` and `https://github.com/affaan-m/everything-claude-code/releases`
   - Look for: new hook events, new settings keys, new agent/skill counts, deprecated commands, model ID changes
3. Compare findings against the current state of the repo:
   - `full/.claude/settings.json` — hook events, effortLevel, model, CLAUDE_PLUGIN_ROOT version
   - `full/.claude/rules/ecc/common/hooks.md` — event list
   - `full/.claude/rules/ecc/common/performance.md` — model IDs
   - `full/CLAUDE.md` and `README.md` — counts and descriptions
   - `full/.github/copilot-instructions.md` — CLI commands
4. Write `docs/YYYY-MM-DD-update.md` with this structure:
   ```markdown
   # VibeCording Update — YYYY-MM-DD

   ## 変更点サマリー
   <brief summary>

   ## トリアージ済みアクションリスト

   ### 🔴 必須
   - [ ] #N: <change> — `<target file>`

   ### 🟡 推奨
   - [ ] #N: <change> — `<target file>`

   ### ⚪ スキップ
   - #N: <change> — 理由: <reason>

   ## 変更詳細
   <per-item details with before/after>
   ```

### 1. Parse the update document

Read the update doc and identify all 🔴/🟡/⚪ items.

Before editing any file, check with Grep/Glob whether the change is already applied (no-op check). Mark no-ops as ⚪ スキップ with reason "already applied".

### 2. Implement changes

Apply each 🔴 and 🟡 item. For each:
1. Read the target file first
2. Apply the minimal diff
3. Verify the change is correct

### 3. Determine next version

If `[version]` argument is provided, use it.
Otherwise: `gh release list --limit 1` → bump minor version (e.g. v0.6.0 → v0.7.0).

### 4. Commit and create PR

```bash
git add <changed files>
git commit -m "feat: <summary from update doc>"
gh pr create --title "..." --body "..."
```

Ask the user to review and merge.

### 5. Install to home directory

After the user confirms merge:

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
