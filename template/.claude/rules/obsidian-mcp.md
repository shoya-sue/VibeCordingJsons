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

## Note Format

When creating notes via `mcp__obsidian__create-note`, use this frontmatter:

```markdown
---
created: YYYY-MM-DD
tags: [tag1, tag2]
---

# Title

Content here.
```

## Folder Structure

| Folder | Purpose |
|--------|---------|
| `INBOX.md` | Quick capture, processed by Claude |
| `開発/` | Development notes |
| `学習/` | Learning notes |
| `投資/` | Investment notes |
| `ライフ/` | Lifestyle notes |
| `健康/` | Health notes |
| `ノウハウ/` | How-to / knowledge base |
| `やりたいこと/` | Goals and wishlist |
| `エンタメ/` | Entertainment |
| `Claude Code/` | Claude Code knowledge base |
| `*/アーカイブ/` | Archived notes per folder |

## When to Use Which Tool

- **Reading vault structure**: `mcp__obsidian__search-vault`
- **Reading a note**: `mcp__obsidian__read-note`
- **Creating a note**: `mcp__obsidian__create-note` (NOT `Write` tool)
- **Editing existing**: `mcp__obsidian__edit-note`
- **Moving notes**: `mcp__obsidian__move-note`
- **Adding tags**: `mcp__obsidian__add-tags`

## DO NOT use `Write` tool for vault notes

Using `Write` directly bypasses Obsidian's internal indexing and may corrupt vault state. Always use MCP tools.
