---
name: update-release
description: Research latest Claude Code / ECC changes, deep-analyze impact, implement, commit on feature branch, create PR, merge, install to ~/, and cut a GitHub release
argument-hint: "[docs/YYYY-MM-DD-update.md] [version]"
user-invokable: true
effort: high
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "WebSearch", "WebFetch", "Bash(git *)", "Bash(gh *)", "Bash(./install.sh *)", "Bash(ls *)", "Bash(sort *)", "Bash(tail *)", "Bash(diff *)", "Bash(find *)", "Bash(python3 *)", "Bash(grep *)"]
---

# update-release

Arguments: `$ARGUMENTS`

## Pre-flight: Environment Snapshot

Before doing anything else, capture the current local state. This is ground truth — never assume from changelog alone.

```bash
# ECC versions locally installed
ls ~/.claude/plugins/cache/everything-claude-code/everything-claude-code/ 2>/dev/null | sort -V

# Current template ECC version
grep "ECC_PLUGIN_ROOT" template/.claude/settings.json | head -1

# Latest release tag
gh release list --limit 1
```

Record:
- `LOCAL_ECC_LATEST` — highest installed version (e.g. `1.10.0`)
- `CURRENT_ECC_IN_SETTINGS` — current ECC_PLUGIN_ROOT value in `template/.claude/settings.json`
- `CURRENT_RELEASE` — latest GitHub release tag (e.g. `v0.28.0`)

If `LOCAL_ECC_LATEST` is empty → ECC is not installed locally. Skip all ECC version changes entirely.

---

## Procedure

### 0. Prepare the update document

**If `$ARGUMENTS` points to an existing file** — skip generation, go to step 1.

**If the file does not exist (or no argument given)** — generate it:

#### 0-a. Research (cast wide)

Fetch from ALL of the following sources:

1. **Claude Code changelog** — search `"Claude Code changelog site:docs.anthropic.com"` and fetch the page. Capture every entry newer than `CURRENT_RELEASE`.
2. **ECC plugin releases** — fetch `https://github.com/affaan-m/everything-claude-code/releases`. Record latest version and release notes.
3. **Claude Code GitHub releases** — fetch `https://github.com/anthropics/claude-code/releases` if accessible, for any items not in the docs changelog.

For each changelog entry, collect ALL of:
- New/changed settings keys and their types/defaults
- New/changed environment variables
- New/changed hook events or hook input fields
- New/changed CLI flags or slash commands
- Model ID changes or new model names
- Agent/skill count changes
- Deprecated or removed features
- Bug fixes that affect documented behavior

#### 0-b. Inventory current template state (read every file)

Read ALL of the following files before writing the update doc. Do not rely on memory — read each file now:

```
template/.claude/settings.json
template/.claude/rules/ecc/common/hooks.md
template/.claude/rules/ecc/common/performance.md
template/.claude/rules/ecc/common/agents.md
template/.claude/rules/ecc/common/development-workflow.md
template/CLAUDE.md
template/AGENTS.md
README.md
template/.github/copilot-instructions.md
```

For each file, note which sections would be affected by each researched change.

#### 0-c. ECC version triage rule (CRITICAL)

If changelog mentions a new ECC version:
- **NOT installed locally** → mark ⚪ スキップ: "ECC X.Y.Z not installed locally — install.sh auto-detects from disk, updating the template to an uninstalled version will break hooks"
- **Installed locally** → mark 🔴 必須, update `ECC_PLUGIN_ROOT` in `template/.claude/settings.json`

#### 0-d. Write `docs/YYYY-MM-DD-update.md`

```markdown
# VibeCording Update — YYYY-MM-DD

## 変更点サマリー
<brief summary>

## 環境スナップショット
- Local ECC installed: <LOCAL_ECC_LATEST>
- Template ECC version: <CURRENT_ECC_IN_SETTINGS>
- Current release: <CURRENT_RELEASE>

## 品質分析サマリー
<output from step 0.5 — condensed>

## トリアージ済みアクションリスト

### 🔴 必須
- [ ] #N: <change> — `<target file>`

### 🟡 推奨
- [ ] #N: <change> — `<target file(s)>`

### ⚪ スキップ
- #N: <change> — 理由: <reason>

## 変更詳細
<per-item details with before/after>
```

---

### 0.5. Deep Quality Analysis

**This step is mandatory.** Before finalizing any triage decision, evaluate each candidate change through all four lenses below. Record the findings in the update doc under `## 品質分析サマリー`. This analysis may upgrade or downgrade items from the initial triage.

#### Lens 1 — Applicability（テンプレートとしての適合性）

Ask: *Is this change meaningful for a configuration template repo, not a running application?*

- Settings keys: will template users actually benefit from knowing or setting this?
- Hook input fields: do users write custom hooks that read this field?
- Env vars: is this user-configurable or purely an internal runtime detail?
- CLI flags: is this something a developer invokes interactively?

Score each item: **High / Medium / Low / Skip**
→ **Low / Skip**: downgrade to ⚪

#### Lens 2 — Cross-file Consistency（横断的一貫性）

Ask: *If we document this in one file, are there other template files that also need updating?*

Check all combinations:
- Adding to `hooks.md` → does `performance.md` or `CLAUDE.md` reference the same concept?
- Adding to README settings table → does `CLAUDE.md` Important Notes also need a line?
- Adding to `performance.md` → does `development-workflow.md` reference it?
- Changing a setting value → does `settings.json` itself need changing, not just docs?

For each item, list ALL files that need a consistent update. Add companion files as additional targets in the triage list.

#### Lens 3 — Risk Assessment（導入リスク）

Ask: *Could applying this change break existing users who copy the template?*

- **Low**: documentation-only, additive, no existing behavior changed
- **Medium**: changes a default value or recommended setting
- **High**: removes something, changes hook behavior, or relies on a CC version that users may not have

→ **High risk**: add `> ⚠️ 導入前に確認:` note to the update doc explaining the impact. Consider downgrading to ⚪ スキップ if mitigation is unclear.

#### Lens 4 — Completeness（適用完全性）

Ask: *Is this change being applied fully, or only partially?*

- Are there related items in the same changelog entry that were initially overlooked?
- Is the before/after diff covering all occurrences in all template files?
- Will the change be consistent between `template/` (source) and `~/.claude/` (after running `install.sh`)?
- Does the change exist in template but NOT in README, or vice versa?

→ Incomplete items: add companion tasks to 🟡 list.

**After all four lenses**, revise the triage:
- Downgrade 🔴/🟡 → ⚪ if Applicability is Skip or Risk is High with no mitigation
- Upgrade 🟡 → 🔴 if already partially applied (Completeness)
- Add new 🟡 items surfaced by Lens 2 or Lens 4

---

### 1. Parse the update document

Read the update doc and identify all 🔴/🟡/⚪ items (post-analysis).

For each 🔴/🟡 item, run a no-op check with Grep before editing:
- Already present verbatim → mark ⚪ スキップ with reason "already applied"
- Partially present → scope the change to the missing portion only

---

### 2. Implement changes

Apply each 🔴 and 🟡 item. For each:
1. Read the target file
2. Apply the minimal diff
3. Confirm syntactic correctness (valid JSON for settings files; well-formed Markdown for docs)
4. Apply companion file changes identified in Lens 2 in the same pass

---

### 3. Determine next version

If `[version]` argument is provided, use it.
Otherwise: read `CURRENT_RELEASE` → bump minor (e.g. `v0.28.0` → `v0.29.0`).

---

### 4. Feature branch, commit, and PR (MANDATORY — never push directly to main)

Always work on a dedicated feature branch:

```bash
BRANCH="update/$(date +%Y-%m-%d)"
git checkout -b "$BRANCH"
git add <changed files including docs/YYYY-MM-DD-update.md>
git commit -m "feat: <summary from update doc>"
git push -u origin "$BRANCH"
gh pr create \
  --title "<version> - <short summary>" \
  --body "<PR body: change list, quality analysis summary, skipped items, environment snapshot>"
```

Output the PR URL and ask the user to review.

---

### 5. Merge (BLOCKING — wait for user confirmation)

After the user confirms the PR looks good:

```bash
gh pr merge --merge --delete-branch
git checkout main
git pull
```

If `gh pr merge` fails due to branch protection rules, instruct the user to merge via the GitHub UI and wait for explicit confirmation before proceeding to step 6.

---

### 6. Post-merge install and validation (BLOCKING)

```bash
./install.sh ~
```

**Immediately validate:**

1. Capture `ECC version: X.Y.Z (auto-detected)` from the install output
2. Verify `ECC_PLUGIN_ROOT` exists on disk:
   ```bash
   ECC_PATH=$(python3 -c "import json; d=json.load(open('$HOME/.claude/settings.json')); print(d['env']['ECC_PLUGIN_ROOT'])")
   echo "ECC_PLUGIN_ROOT: $ECC_PATH"
   ls "$ECC_PATH" > /dev/null 2>&1 && echo "PATH_EXISTS ✓" || echo "PATH_NOT_FOUND ✗"
   ```

**Validation gate:**
- `PATH_NOT_FOUND ✗` → **STOP**. Do not create a release. Report the missing path and available local versions. Fix `template/.claude/settings.json`, create a new branch, and repeat from step 4.
- `PATH_EXISTS ✓` → proceed.

---

### 7. Create GitHub release

Only after validation passes:

```bash
gh release create <version> \
  --title "<version> - <short title>" \
  --notes "<release notes>"
```

Release notes format:
- H2: theme of the release
- Sections per change area (Updated / New / Fixed / Skipped)
- Table for counts/comparisons where applicable
- `**Full Changelog**` link at the bottom

---

### 8. Update project memory

Update the project memory at:
`~/.claude/projects/-Users-shoya-sue-Public-shoya-sue-VibeCordingJsons/memory/project_vibecording.md`

Update:
- `description` date field to today
- Release history table: add the new release, keep the 3 most recent entries
- Local environment state section: reflect new ECC version and installed settings version
- Remove any stale open-PR entries

---

### 9. Final report

Output a summary table:

| Step | Result |
|------|--------|
| Environment | ECC local `<version>` vs template `<version>` |
| Items analyzed | N total (🔴 M applied, 🟡 K applied, ⚪ J skipped) |
| Files changed | List |
| Skipped items | List with reasons |
| PR | URL |
| Merge | ✓ merged |
| Install validation | ECC path ✓ or ✗ |
| Release | URL |
| Memory updated | ✓ |
