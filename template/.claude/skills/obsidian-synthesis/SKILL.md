---
name: obsidian-synthesis
description: Daily synthesis of Obsidian vault — reads INBOX captures, surfaces connections across notes, generates dated insight note
user-invokable: true
allowed-tools: ["ToolSearch", "Read", "Write", "Edit", "Bash", "mcp__obsidian__read-note", "mcp__obsidian__search-vault", "mcp__obsidian__create-note", "mcp__obsidian__edit-note", "mcp__obsidian__create-directory", "mcp__obsidian__list-available-vaults"]
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

Call ToolSearch to load Obsidian MCP tool schemas:
```
ToolSearch(query: "select:mcp__obsidian__create-note,mcp__obsidian__search-vault,mcp__obsidian__read-note,mcp__obsidian__edit-note,mcp__obsidian__list-available-vaults,mcp__obsidian__create-directory,mcp__obsidian__move-note")
```

### 2. Read Context

Read CLAUDE.md to load current project context:
```
Read("/Users/shoya-sue/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/CLAUDE.md")
```

### 3. Read INBOX

Read INBOX.md for unprocessed captures:
```
mcp__obsidian__read-note(vault: "Obsidian", path: "INBOX.md")
```

### 4. Scan Recent Activity

Find notes modified in the last 48 hours:
```bash
find "/Users/shoya-sue/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian" \
  -name "*.md" \
  -newer "/Users/shoya-sue/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/INBOX.md" \
  -not -path "*/.obsidian/*" \
  -not -path "*/アーカイブ/*" \
  -not -name "CLAUDE.md" \
  2>/dev/null | sort
```

Or use timestamp-based search:
```bash
find "/Users/shoya-sue/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian" \
  -name "*.md" \
  -mtime -2 \
  -not -path "*/.obsidian/*" \
  2>/dev/null | sort
```

Read top 5-10 recently modified notes using mcp__obsidian__read-note.

### 5. Generate Synthesis

Analyze all gathered content and generate a synthesis with these sections:

```markdown
# Daily Synthesis — YYYY-MM-DD

## Captures to Process
[INBOX items and suggested destinations]

## Emerging Patterns
[Themes or patterns appearing across multiple notes]

## Cross-Domain Connections
[Links between seemingly unrelated captures/notes]

## Questions Worth Exploring
[Open questions surfaced by the synthesis]

## Recommended Actions
[1-3 concrete next steps]
```

### 6. Write Synthesis Note

Create the dated synthesis note:
```
mcp__obsidian__create-note(
  vault: "Obsidian",
  path: "Claude Code/Daily Synthesis/YYYY-MM-DD.md",
  content: <generated synthesis>
)
```

### 7. Process INBOX

For each INBOX item, either:
a. Move to appropriate folder (if clear destination)
b. Leave with a `[→ processed: YYYY-MM-DD]` marker

Update INBOX.md:
```
mcp__obsidian__edit-note(vault: "Obsidian", path: "INBOX.md", ...)
```

## Output

- Synthesis note at `Claude Code/Daily Synthesis/YYYY-MM-DD.md`
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
