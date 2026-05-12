# Obsidian MCP Usage

## Critical: Schema Loading Required

`mcp__obsidian__*` tools are **deferred** — schemas reset on every session restart.

**BEFORE using any `mcp__obsidian__` tool, ALWAYS call ToolSearch first:**

```
ToolSearch(query: "select:mcp__obsidian__create-note,mcp__obsidian__search-vault,mcp__obsidian__read-note,mcp__obsidian__edit-note,mcp__obsidian__list-available-vaults,mcp__obsidian__create-directory,mcp__obsidian__move-note,mcp__obsidian__delete-note,mcp__obsidian__add-tags,mcp__obsidian__remove-tags,mcp__obsidian__rename-tag")
```

This is mandatory. Skipping ToolSearch → `InputValidationError`. Do NOT use `Write` tool to bypass this — proper MCP usage preserves Obsidian vault rules.

## Vault Path

```
/Users/shoya-sue/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/
```

Env var: `$OBSIDIAN_VAULT`

## Writing Protocol (MANDATORY)

Every write to Obsidian MUST follow this sequence:

### Step 1: Search Before Write

Before creating or editing any note, search for related existing notes:

```
mcp__obsidian__search-vault(query: "<topic keywords>")
```

This prevents duplication and reveals notes that should receive [[wikilinks]].

### Step 2: Determine Target Folder

Use the Content → Folder Mapping table below to decide where content belongs.

### Step 3: Write with [[Wikilinks]]

**Every note MUST contain at least one [[wikilink]] to an existing vault note.**

Wikilinks that graph-connect content:
- `[[Claude Code/INDEX]]` — always link new Claude Code notes here
- `[[Claude Code/プロジェクト/shoya-sue/VibeCordingJsons]]` — link from project-related notes
- `[[Claude Code/横断テーマ/MCPサーバー全リスト]]` — link from MCP-related notes
- `[[Claude Code/横断テーマ/トラブルシュート集]]` — link from troubleshooting notes
- `[[Claude Code/横断テーマ/feedback集約]]` — link from feedback/preference notes
- `[[Claude Code/環境設定]]` — link from environment/config notes
- `[[HOME]]` — only for top-level MOC notes

Leaf notes that have NO links are invisible in graph view — always add at least one.

### Step 4: Add Frontmatter

```markdown
---
created: YYYY-MM-DD
tags: [claude-code, <topic-tag>]
---
```

### Step 5: Update INDEX or parent MOC if creating a new note

After creating a new note in `Claude Code/`, add a link to it in `Claude Code/INDEX.md`.

## Content → Folder Mapping

| Content Type | Target Path | Action |
|---|---|---|
| Project architecture, decisions | `Claude Code/プロジェクト/shoya-sue/VibeCordingJsons.md` | EDIT (existing) |
| New project notes (other repos) | `Claude Code/プロジェクト/shoya-sue/<project>.md` | CREATE |
| Troubleshooting solutions | `Claude Code/横断テーマ/トラブルシュート集.md` | EDIT (append) |
| Feedback / preferences | `Claude Code/横断テーマ/feedback集約.md` | EDIT (append) |
| MCP server changes | `Claude Code/横断テーマ/MCPサーバー全リスト.md` | EDIT |
| New how-to knowledge | `Claude Code/ノウハウ/<topic>.md` | CREATE |
| Environment / config changes | `Claude Code/環境設定.md` | EDIT |
| Session logs | `Claude Code/Sessions/YYYY-MM.md` | APPEND (via hook) |
| Dev ideas / experiments | `開発/<topic>.md` | CREATE |
| Learning notes | `学習/<topic>.md` | CREATE |
| Goals / wishlist | `やりたいこと/<topic>.md` | CREATE |
| Quick capture | `INBOX.md` | APPEND, then process |

## Tag Taxonomy

Use these established tags (lowercase, hyphenated):

| Tag | When to Use |
|---|---|
| `claude-code` | All Claude Code related notes |
| `session-log` | Session log entries |
| `mcp` | MCP server / tool notes |
| `settings` | Configuration / settings changes |
| `troubleshooting` | Problem → solution entries |
| `feedback` | Preferences and corrections |
| `project` | Project-specific notes |
| `workflow` | Process / workflow improvements |
| `architecture` | Design decisions |
| `install` | Installation / setup |

## Knowledge Promotion: When to Write to Obsidian

**DO write to Obsidian** when the information:
- Represents a permanent decision or architecture choice
- Is a non-obvious insight that would take time to rediscover
- Is a troubleshooting solution to a problem that may recur
- Changes the environment in a way others (or future Claude) should know
- Is a project milestone or release

**DO NOT write to Obsidian** for:
- Transient task state (in-progress work)
- Information already in git log / commit messages
- Ephemeral debugging outputs
- Content that only makes sense in this session's context
- Raw Claude Code internal memory format (those go in `.claude/memory/`, not Obsidian)

## DO NOT use `Write` tool for vault notes

Using `Write` directly bypasses Obsidian's internal indexing and may corrupt vault state. Always use MCP tools.

## When to Use Which Tool

| Goal | Tool |
|---|---|
| Find related notes before writing | `mcp__obsidian__search-vault` |
| Read an existing note | `mcp__obsidian__read-note` |
| Create a new note | `mcp__obsidian__create-note` |
| Add content to existing note | `mcp__obsidian__edit-note` |
| Reorganize notes | `mcp__obsidian__move-note` |
| Add tags | `mcp__obsidian__add-tags` |
| Create a folder | `mcp__obsidian__create-directory` |
