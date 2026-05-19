---
name: obsidian-synthesis
description: Daily synthesis of Obsidian vault — reads INBOX captures, surfaces connections across notes, generates dated insight note
user-invokable: true
allowed-tools: ["ToolSearch", "Read", "Write", "Edit", "Bash", "mcp__obsidian__obsidian_get_note", "mcp__obsidian__obsidian_search_notes", "mcp__obsidian__obsidian_write_note", "mcp__obsidian__obsidian_append_to_note", "mcp__obsidian__obsidian_patch_note", "mcp__obsidian__obsidian_replace_in_note", "mcp__obsidian__obsidian_list_notes", "mcp__obsidian__obsidian_manage_frontmatter", "mcp__obsidian__obsidian_manage_tags"]
effort: high
---

# Obsidian Daily Synthesis

## Purpose

Proactively review recent Obsidian vault activity and generate a synthesis note that surfaces:
- Missed connections between captures and existing knowledge
- Emerging patterns across domains
- Questions worth exploring
- Actionable next steps

## Execution Steps

### 1. Load MCP Schemas (MANDATORY FIRST STEP)

Call ToolSearch to load cyanheads Obsidian MCP tool schemas:
```
ToolSearch(query: "select:mcp__obsidian__obsidian_get_note,mcp__obsidian__obsidian_search_notes,mcp__obsidian__obsidian_write_note,mcp__obsidian__obsidian_append_to_note,mcp__obsidian__obsidian_patch_note,mcp__obsidian__obsidian_replace_in_note,mcp__obsidian__obsidian_list_notes")
```

### 2. Read Context

Read CLAUDE.md to load current project context:
```
mcp__obsidian__obsidian_get_note(filePath: "CLAUDE.md")
```

### 3. Read INBOX

Read INBOX.md for unprocessed captures:
```
mcp__obsidian__obsidian_get_note(filePath: "INBOX.md")
```

### 4. Scan Recent Activity

Find notes modified in the last 48 hours under PARA folders (exclude system folders and legacy archives):
```bash
find "$OBSIDIAN_VAULT" \
  -name "*.md" \
  -mtime -2 \
  -not -path "*/.obsidian/*" \
  -not -path "*/.trash/*" \
  -not -path "*/.backup/*" \
  -not -path "*/08 - ARCHIVE/*" \
  -not -path "*/_legacy_para/*" \
  -not -name "CLAUDE.md" \
  2>/dev/null | sort
```

Read top 5–10 recently modified notes using `mcp__obsidian__obsidian_get_note` (filePath is relative to vault root, e.g. `20_projects/<owner>/<repo>.md`).

For broader semantic search across PARA folders use:
```
mcp__obsidian__obsidian_search_notes(mode: "dataview", query: "...")
```

### 5. Generate Synthesis

Analyze all gathered content and generate a synthesis with these sections:

```markdown
# Daily Synthesis — YYYY-MM-DD

## Captures to Process
[INBOX items and suggested destinations — use PARA folder mapping from ~/.claude/rules/obsidian-mcp.md]

## Emerging Patterns
[Themes or patterns appearing across multiple notes]

## Cross-Domain Connections
[Links between seemingly unrelated captures/notes — use [[wikilinks]]]

## Questions Worth Exploring
[Open questions surfaced by the synthesis]

## Recommended Actions
[1-3 concrete next steps]
```

Frontmatter for the synthesis note:
```yaml
---
created: YYYY-MM-DD
tags: [claude-code, synthesis, daily]
---
```

Include `[[30_knowledge/claude-code/INDEX]]` and `[[HOME]]` as wikilinks so the note is graph-connected.

### 6. Write Synthesis Note

Create the dated synthesis note (PARA path: `30_knowledge/claude-code/daily-synthesis/YYYY-MM-DD.md`):
```
mcp__obsidian__obsidian_write_note(
  filePath: "30_knowledge/claude-code/daily-synthesis/YYYY-MM-DD.md",
  content: <generated synthesis with frontmatter>,
  overwrite: false
)
```

### 7. Process INBOX

For each INBOX item, either:
a. Suggest destination per `~/.claude/rules/obsidian-mcp.md` Content → Folder Mapping (20_projects/, 30_knowledge/, 40_learning/, 50_decisions/, 60_wishes/)
b. Leave with a `[→ processed: YYYY-MM-DD]` marker

Update INBOX.md via surgical patch (avoid full-file rewrite):
```
mcp__obsidian__obsidian_patch_note(
  filePath: "INBOX.md",
  operation: "append",
  targetType: "document",
  content: "<processed marker or moved-to note>"
)
```

For find-and-replace within INBOX:
```
mcp__obsidian__obsidian_replace_in_note(
  filePath: "INBOX.md",
  replacements: [{search: "...", replace: "..."}]
)
```

## Output

- Synthesis note at `30_knowledge/claude-code/daily-synthesis/YYYY-MM-DD.md`
- Updated INBOX.md with processed markers or cleared items
- Summary of key insights presented to user

## Invocation

```
/obsidian-synthesis
```

Or with date override:
```
/obsidian-synthesis 2026-05-10
```
