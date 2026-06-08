---
name: obsidian-synthesis
description: Daily synthesis of Obsidian vault — reads INBOX captures, promotes unprocessed auto-captures, surfaces connections across notes, generates dated insight note
user-invokable: true
allowed-tools: ["ToolSearch", "Read", "Write", "Edit", "Bash", "mcp__obsidian__vault_read", "mcp__obsidian__vault_write", "mcp__obsidian__vault_append", "mcp__obsidian__vault_patch", "mcp__obsidian__vault_list", "mcp__obsidian__vault_get_document_map", "mcp__obsidian__search_query", "mcp__obsidian__search_simple", "mcp__obsidian__tag_list"]
effort: high
---

# Obsidian Daily Synthesis

## Purpose

Proactively review recent Obsidian vault activity and generate a synthesis note that surfaces:
- Missed connections between captures and existing knowledge
- Emerging patterns across domains
- Questions worth exploring
- Actionable next steps

It also **promotes unprocessed auto-captures** (the `<!-- 未処理 -->` entries written by the
`obsidian-auto-capture.sh` Stop hook) into their proper PARA destinations, so raw capture
material does not pile up indefinitely.

> Writes follow `~/.claude/rules/obsidian-mcp.md` (path 1 = `mcp__obsidian__vault_*`). The native
> server is the **Local REST API & MCP Server** plugin (HTTP `127.0.0.1:27123/mcp/`), whose tools
> are `vault_*` / `search_*` / `tag_list` — NOT the legacy `obsidian_*` names.

## Execution Steps

### 1. Load MCP Schemas (MANDATORY FIRST STEP)

Load the native Obsidian MCP tool schemas. These are deferred tools, so they must be fetched
before they can be called:
```
ToolSearch(query: "select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_append,mcp__obsidian__vault_patch,mcp__obsidian__vault_list,mcp__obsidian__vault_get_document_map,mcp__obsidian__search_query,mcp__obsidian__search_simple,mcp__obsidian__tag_list")
```

If the SessionStart healthcheck (`## Obsidian MCP & auto-memory healthcheck`) shows `⚠`/`✗`,
declare one line that you are falling back to `Read`/`Write`/`Edit` on the vault path, then proceed.

### 2. Read Context

Read CLAUDE.md to load current project context (path is relative to vault root):
```
mcp__obsidian__vault_read(path: "CLAUDE.md")
```

### 3. Read INBOX

Read INBOX.md for unprocessed captures:
```
mcp__obsidian__vault_read(path: "INBOX.md")
```

### 4. Read Unprocessed Auto-captures

Read the current month's auto-capture file and collect every entry still marked
`<!-- 未処理 -->` (these are promotion candidates extracted by the Stop hook):
```
mcp__obsidian__vault_read(path: "90_artifacts/claude-code/auto-captures/$(date +%Y-%m).md")
```

### 5. Scan Recent Activity

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

Read the top 5–10 recently modified notes with `mcp__obsidian__vault_read` (path relative to
vault root, e.g. `20_projects/<owner>/<repo>.md`). To inspect a note's structure before a
surgical edit, use `mcp__obsidian__vault_get_document_map`.

For broader search across PARA folders use:
```
mcp__obsidian__search_query(...)   # JsonLogic — complex conditions
mcp__obsidian__search_simple(...)  # plain full-text (Obsidian search)
```

### 6. Promote Unprocessed Auto-captures

For each `<!-- 未処理 -->` entry from Step 4, route it per the Content → Folder Mapping in
`~/.claude/rules/obsidian-mcp.md`:

| Capture category | Destination | Tool |
|---|---|---|
| トラブルシュート | `30_knowledge/claude-code/themes/トラブルシュート集.md` | `vault_append` / `vault_patch` |
| feedback | `30_knowledge/claude-code/themes/feedback集約.md` | `vault_append` / `vault_patch` |
| 環境設定 | `30_knowledge/claude-code/環境設定.md` | `vault_patch` |
| MCP変更 | `30_knowledge/claude-code/themes/MCPサーバー全リスト.md` | `vault_patch` |
| 設計判断 (ADR) | `50_decisions/<YYYY-MM-DD>-<title>.md` | `vault_write` |
| 実装マイルストーン | `20_projects/<owner>/<repo>.md` | `vault_append` |
| 学び | `40_learning/<topic>.md` | `vault_write` / `vault_append` |

Append to an existing note:
```
mcp__obsidian__vault_append(path: "30_knowledge/claude-code/themes/トラブルシュート集.md", content: "...")
```

Surgical edit (under a specific heading / frontmatter):
```
mcp__obsidian__vault_patch(path: "...", operation: "append", targetType: "heading", target: "...", content: "...")
```

Always carry at least one `[[wikilink]]` into the promoted note (see Step 8). After a capture is
promoted, mark it processed in the auto-capture file by replacing its marker via `vault_patch`
(read the block first with `vault_get_document_map` if needed):
```
# 未処理 → promoted
<!-- promoted: YYYY-MM-DD → <destination path> -->
```
Do **not** delete the original capture entry; only flip the marker (provenance).

### 7. Generate Synthesis

Analyze all gathered content and generate a synthesis with these sections:

```markdown
# Daily Synthesis — YYYY-MM-DD

## Captures Promoted
[Auto-captures promoted this run and where they went]

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

### 8. Wikilinks (MANDATORY)

Every note written MUST contain at least one `[[wikilink]]` to an existing vault note so it is
graph-connected. For the synthesis note include `[[30_knowledge/claude-code/INDEX]]` and `[[HOME]]`.

### 9. Write Synthesis Note

Create the dated synthesis note (PARA path: `30_knowledge/claude-code/daily-synthesis/YYYY-MM-DD.md`):
```
mcp__obsidian__vault_write(
  path: "30_knowledge/claude-code/daily-synthesis/YYYY-MM-DD.md",
  content: <generated synthesis with frontmatter>
)
```

### 10. Process INBOX

For each INBOX item, either:
a. Promote to the destination per `~/.claude/rules/obsidian-mcp.md` Content → Folder Mapping
   (20_projects/, 30_knowledge/, 40_learning/, 50_decisions/, 60_wishes/), or
b. Leave it with a `[→ processed: YYYY-MM-DD]` marker.

Update INBOX.md via surgical patch (avoid full-file rewrite):
```
mcp__obsidian__vault_patch(
  path: "INBOX.md",
  operation: "append",
  targetType: "heading",
  target: "<section>",
  content: "<processed marker or moved-to note>"
)
```

There is no dedicated find-and-replace tool — to edit an existing line, read the section with
`vault_read` / `vault_get_document_map`, then `vault_patch` (operation: "replace") that target.

## Output

- Synthesis note at `30_knowledge/claude-code/daily-synthesis/YYYY-MM-DD.md`
- Auto-captures promoted to their PARA destinations, markers flipped to `<!-- promoted: ... -->`
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
