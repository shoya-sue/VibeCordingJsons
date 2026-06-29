---
name: update-release
description: VibeCordingJsons 専用のリリース運用 skill。Claude Code / ECC の最新変更を調査し、更新が必要かを判定 → 必要なら実装 → feature branch で commit/PR/merge → install.sh で検証 → GitHub release を発行し、context・memory・Obsidian の 3 面へ反映する。プロジェクトローカル（このリポジトリでのみ利用可、グローバル/テンプレ配布しない）。
argument-hint: "[docs/YYYY-MM-DD-update.md] [version]"
user-invokable: true
effort: xhigh
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "WebSearch", "WebFetch", "Bash(git *)", "Bash(gh *)", "Bash(./install.sh *)", "Bash(bash *)", "Bash(ls *)", "Bash(sort *)", "Bash(tail *)", "Bash(diff *)", "Bash(find *)", "Bash(python3 *)", "Bash(grep *)", "mcp__obsidian__vault_read", "mcp__obsidian__vault_append", "mcp__obsidian__vault_patch", "mcp__obsidian__vault_get_document_map", "mcp__obsidian__search_simple"]
---

# update-release

Arguments: `$ARGUMENTS`

> **このスキルはプロジェクトローカル**です（`VibeCordingJsons/.claude/skills/update-release/`）。VibeCordingJsons リポジトリのメンテ専用で、グローバル `~/.claude/skills/` にもテンプレート `template/.claude/skills/` にも置きません（end-user プロジェクトには無関係なため）。リポジトリ root で作業しているときだけ `/update-release` が利用できます。

> **このスキルの核心原則 — 1 リリース = 3 面の同時更新**
> どのリリースも、変更を必ず次の **3 つの面**へ伝播させて初めて完了です。どれか 1 つでも欠けたら未完了とみなします:
>
> | 面 | 実体 | 更新方法 |
> |----|------|----------|
> | **context** | リポジトリの「生きた指示」= `template/CLAUDE.md` / `template/AGENTS.md` / `README.md`（必要なら root `CLAUDE.md` / `AGENTS.md`） | Step 2 の実装で編集 |
> | **memory** | `~/.claude/projects/-Users-shoya-sue-Public-shoya-sue-VibeCordingJsons/memory/project_vibecording.md`（このディレクトリは **symlink → Obsidian `90_artifacts/claude-code/memory/VibeCordingJsons/`** なので vault に自動ミラーされる） | Step 8 |
> | **obsidian** | project note `20_projects/shoya-sue/VibeCordingJsons.md`（手動運用ノート。memory ミラーとは別物） | Step 9 |

## Pre-flight: 状態把握 → 更新要否判定

最初に必ずローカルの現状を取得する。これが ground truth で、changelog だけで判断しない。

```bash
# ECC versions locally installed (ECC 2.0.0 で plugin が everything-claude-code → ecc にリネーム。
# 新 `ecc` ディレクトリと legacy `everything-claude-code` ディレクトリの両方を見る)
ls ~/.claude/plugins/cache/everything-claude-code/ecc/ 2>/dev/null | sort -V
ls ~/.claude/plugins/cache/everything-claude-code/everything-claude-code/ 2>/dev/null | sort -V

# Current template ECC version
grep "ECC_PLUGIN_ROOT" template/.claude/settings.json | head -1

# Latest release tag
gh release list --limit 1

# Latest Claude Code version (changelog の最新エントリ)
gh release list -R anthropics/claude-code --limit 1
```

記録する:
- `LOCAL_ECC_LATEST` — ローカルにインストール済みの最高 ECC バージョン（例 `2.0.0`）
- `CURRENT_ECC_IN_SETTINGS` — `template/.claude/settings.json` の現在の `ECC_PLUGIN_ROOT` 値
- `CURRENT_RELEASE` — 最新 GitHub release タグ（例 `v0.62.0`）
- `LATEST_CC` — 最新 Claude Code バージョン

`LOCAL_ECC_LATEST` が空 → ECC がローカル未インストール。ECC バージョン変更は一切スキップ。

### 更新要否の判定

- `CURRENT_RELEASE` が既にカバーしている Claude Code バージョンと `LATEST_CC` を比較する。
- 新しいエントリが**ある** → 通常フロー（Step 0 以降）へ。
- 新しいエントリが**ない**（既に最新をカバー済み） → それでも **0変更カバレッジ記録リリースを出す**（バージョン追跡の連続性維持のため。Step 0.5 で「適用ゼロ」を 5 レンズで検証し、doc-only リリースとして記録する）。**勝手に early-exit しない。**

---

## Procedure

### 0. Prepare the update document

**If `$ARGUMENTS` points to an existing file** — skip generation, go to step 1.

**If the file does not exist (or no argument given)** — generate it:

#### 0-a. Research (cast wide)

> **Tooling (avoids permission prompts):** Use the `WebFetch` tool for doc/HTML pages and the `gh` CLI (`gh api`, `gh release view`, `gh search`) for GitHub data. **Never `curl`/`wget` to api.github.com or any URL** — `Bash(curl *)` is on the `ask` list and forces a manual prompt every time, while `WebFetch(*)` and `Bash(gh *)` are allowlisted and run silently. When delegating this research to a subagent, repeat this directive in the subagent prompt (subagents otherwise default to `curl`).

Fetch from ALL of the following sources:

1. **Claude Code changelog** — `WebFetch` `https://docs.anthropic.com/en/docs/claude-code/changelog` (or `https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md`). Capture every entry newer than `CURRENT_RELEASE`.
2. **ECC plugin releases** — `gh release list -R affaan-m/everything-claude-code` then `gh release view <tag> -R affaan-m/everything-claude-code`. Record latest version and release notes.
3. **Claude Code GitHub releases** — `gh release list -R anthropics/claude-code` / `gh api repos/anthropics/claude-code/releases` for any items not in the docs changelog. 欠番バージョン（例: 2.1.180）は `gh release view vX.Y.Z` が `release not found` を返すので確認しておく。

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
- Latest Claude Code: <LATEST_CC>

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

**This step is mandatory.** Before finalizing any triage decision, evaluate each candidate change through all five lenses below. Record the findings in the update doc under `## 品質分析サマリー`. This analysis may upgrade or downgrade items from the initial triage.

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

#### Lens 5 — Breaking-change Audit（出荷 config への破壊的変更監査）

Ask: *Does this changelog item change matching / permission / parsing semantics in a way that could break the template's OWN shipped config — not just add a doc-worthy knob?*

A changelog entry that **tightens or changes how an existing knob is interpreted** (hook `matcher` evaluation, permission-rule matching, glob vs regex, exact vs substring, parser strictness) is not merely a doc item — it can **silently break config the template already ships**. Audit the shipped files, never only the docs.

**Trigger** this audit when an item's wording includes: hook `matcher` semantics, permission-rule matching, `mcp__*` tool-name matching, glob/regex, exact/substring, or any "now X-matches instead of Y-matches" phrasing.

Steps:
1. Enumerate every affected construct the template ships. For hook matchers, run `python3` over `template/.claude/settings.json` and list every `hooks[*][*].matcher`.
2. For each, decide whether the new semantics change its match set. Record the verdict (壊れる / 壊れない) with the reason in the update doc under a `## 破壊的変更チェック` heading.
3. If anything breaks, fix the shipped config in the **same PR** (upgrade to 🔴) — never ship a doc note describing a knob the template itself mis-uses.
4. Run `bash scripts/check-counts.sh` after any settings.json matcher edit — it now also asserts no hook matcher uses a bare `__*` glob (must be exact-string or proper `.*` regex).

Reference — official 3 evaluation modes (mirrored in `hooks.md`): `"*"`/`""`/omitted = match-all; only `[A-Za-z0-9_ ,|]` = exact string (or `|`/`,` list); any other char = JS regex (unanchored). All tools of a server = `mcp__<server>__.*` (regex), never bare `mcp__<server>__*`.

**After all five lenses**, revise the triage:
- Downgrade 🔴/🟡 → ⚪ if Applicability is Skip or Risk is High with no mitigation
- Upgrade 🟡 → 🔴 if already partially applied (Completeness) or if Lens 5 finds the shipped config breaks
- Add new 🟡 items surfaced by Lens 2, Lens 4, or Lens 5

---

### 1. Parse the update document

Read the update doc and identify all 🔴/🟡/⚪ items (post-analysis).

For each 🔴/🟡 item, run a no-op check with Grep before editing:
- Already present verbatim → mark ⚪ スキップ with reason "already applied"
- Partially present → scope the change to the missing portion only

---

### 2. Implement changes（= context 面の更新）

Apply each 🔴 and 🟡 item. For each:
1. Read the target file
2. Apply the minimal diff
3. Confirm syntactic correctness (valid JSON for settings files; well-formed Markdown for docs)
4. Apply companion file changes identified in Lens 2 in the same pass

After editing, if any change touched counts (skills/rules/languages/hooks/MCP servers/agents) or install commands, run `bash scripts/check-counts.sh` — it asserts documented counts match the filesystem and that stale tier/`install.sh full` strings have not reappeared. Fix any drift it reports before committing.

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

Default は user の確認待ち。ただし user が同一ターンで明示的に「go / merge / proceed」と承認している場合はそのまま進めてよい。

After confirmation:

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
- Sections per change area (Added / Updated / Fixed / Skipped / Unchanged)
- Table for counts/comparisons where applicable
- `**Full Changelog**` link at the bottom

---

### 8. Update memory（= memory 面の更新）

Update the project memory at:
`~/.claude/projects/-Users-shoya-sue-Public-shoya-sue-VibeCordingJsons/memory/project_vibecording.md`

Update:
- `description` date field to today
- Release history table: add the new release, keep the 3 most recent entries
- Local environment state section: reflect new ECC version and installed settings version
- Remove any stale open-PR entries

Also update `MEMORY.md`'s one-line pointer for this project if its hook/summary changed.

> このディレクトリは Obsidian `90_artifacts/claude-code/memory/VibeCordingJsons/` への **symlink** なので、ここへの書き込みは vault に自動ミラーされる。手動 Obsidian write は不要。

---

### 9. Update Obsidian project note（= obsidian 面の更新）

memory ミラー（Step 8）とは別に、**手動運用の project note** を更新する:
`20_projects/shoya-sue/VibeCordingJsons.md`（`$OBSIDIAN_VAULT` 配下）

手順（`obsidian-mcp.md` の Writing Protocol に従う）:
1. SessionStart healthcheck の `## Obsidian MCP & auto-memory healthcheck` が `✓ (5/5 OK)` であることを確認。`⚠`/`✗` があれば 1 行宣言して `Read`/`Edit` フォールバック。
2. `mcp__obsidian__vault_get_document_map` で project note の構造を把握し、リリース履歴セクションを特定。
3. `mcp__obsidian__vault_patch`（operation=prepend/append, targetType=heading）で新リリースエントリを追記:
   - バージョン・日付・1 行サマリー（カバーした Claude Code バージョン / 適用件数 / ECC 状態）
   - 0変更カバレッジ記録リリースの場合はその旨を明記
4. frontmatter の `updated` 等の日付フィールドがあれば今日の日付に `vault_patch`（targetType=frontmatter）。
5. 既存の `[[wikilink]]`（例 `[[30_knowledge/claude-code/INDEX]]`）が孤立しないよう、追記内容にも必要なら link を含める。

> Obsidian MCP が使えない環境（healthcheck ✗）では、理由を 1 行宣言してから `Read`/`Edit` で `$OBSIDIAN_VAULT/20_projects/shoya-sue/VibeCordingJsons.md` を直接編集する（サイレント・フォールバック禁止）。

---

### 10. Final report

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
| context updated | ✓ (files) |
| memory updated | ✓ |
| obsidian updated | ✓ (project note) |
