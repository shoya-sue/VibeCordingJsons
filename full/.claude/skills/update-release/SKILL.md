---
name: update-release
description: Research latest Claude Code / ECC changes, generate update doc, implement changes, commit, PR, install to ~/, and cut a GitHub release
argument-hint: "[docs/YYYY-MM-DD-update.md] [version]"
user-invokable: true
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "WebSearch", "WebFetch", "Bash(git *)", "Bash(gh *)", "Bash(./install.sh *)", "Bash(ls *)", "Bash(sort *)", "Bash(tail *)"]
---

# update-release

Arguments: `$ARGUMENTS`

## Pre-flight: Environment Snapshot

Before doing anything else, capture the current local state. This is ground truth — never assume from changelog alone.

```bash
# What ECC versions are locally installed?
ls ~/.claude/plugins/cache/everything-claude-code/everything-claude-code/ 2>/dev/null | sort -V
```

Record:
- `LOCAL_ECC_LATEST` — highest installed version (e.g. `1.9.0`)
- `CURRENT_ECC_IN_SETTINGS` — current value from `full/.claude/settings.json` CLAUDE_PLUGIN_ROOT

If `LOCAL_ECC_LATEST` is empty → ECC is not installed locally. Skip all ECC version changes entirely.

## Procedure

### 0. Prepare the update document

**If `$ARGUMENTS` points to an existing file** — skip generation, go to step 1.

**If the file does not exist (or no argument given)** — generate it:

1. Determine the filename: `docs/YYYY-MM-DD-update.md` using today's date
2. Research the latest changes via web search:
   - Claude Code changelog: search "Claude Code changelog site:docs.anthropic.com" and fetch the page
   - ECC plugin releases: fetch `https://github.com/affaan-m/everything-claude-code/releases`
   - Look for: new hook events, new settings keys, new agent/skill counts, deprecated commands, model ID changes
3. Compare findings against the current state of the repo:
   - `full/.claude/settings.json` — hook events, effortLevel, model, CLAUDE_PLUGIN_ROOT version
   - `full/.claude/rules/ecc/common/hooks.md` — event list
   - `full/.claude/rules/ecc/common/performance.md` — model IDs
   - `full/CLAUDE.md` and `README.md` — counts and descriptions
   - `full/.github/copilot-instructions.md` — CLI commands

4. **ECC version triage rule** (CRITICAL — apply before writing the doc):
   - If changelog mentions a new ECC version (e.g. `1.11.0`):
     - Check if it equals `LOCAL_ECC_LATEST`
     - **If NOT installed locally** → mark as ⚪ スキップ with reason: "ECC X.Y.Z not installed locally — install.sh auto-detects from disk, updating the template to an uninstalled version will break hooks"
     - **If installed locally** → mark as 🔴 必須, update `CLAUDE_PLUGIN_ROOT` in `full/.claude/settings.json`

5. Write `docs/YYYY-MM-DD-update.md` with this structure:
   ```markdown
   # VibeCording Update — YYYY-MM-DD

   ## 変更点サマリー
   <brief summary>

   ## 環境スナップショット
   - Local ECC installed: <LOCAL_ECC_LATEST>
   - Template ECC version: <CURRENT_ECC_IN_SETTINGS>

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

### 5. Post-merge install and validation (BLOCKING)

After the user confirms merge:

```bash
git pull
./install.sh full ~
```

**Immediately validate the install output:**

1. Capture the line `ECC version: X.Y.Z (auto-detected)` from the output
2. Grep the installed settings: `grep CLAUDE_PLUGIN_ROOT ~/.claude/settings.json`
3. Verify the path in `CLAUDE_PLUGIN_ROOT` actually exists on disk:
   ```bash
   ls "$(grep -o 'everything-claude-code/[^"]*' ~/.claude/settings.json | head -1 | sed 's|everything-claude-code/||')" 2>/dev/null || echo "PATH_NOT_FOUND"
   ```
   More precisely: extract the CLAUDE_PLUGIN_ROOT value and check the directory exists.

**Validation gate:**
- If `CLAUDE_PLUGIN_ROOT` path does NOT exist → **STOP**. Do not create a release. Report the exact path that is missing and what versions are locally available. Fix the settings manually before continuing.
- If `CLAUDE_PLUGIN_ROOT` path exists → proceed.

### 6. Create GitHub release

Only after validation passes:

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
- Environment snapshot (ECC local vs template)
- Files changed (list)
- Items skipped and why
- Validation result (ECC path confirmed ✓ or ✗)
- PR URL
- Release URL
