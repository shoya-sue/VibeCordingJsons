# Obsidian MCP Usage

## Critical: Schema Loading Required

`mcp__obsidian__*` tools are **deferred** — schemas reset on every session restart.

**BEFORE using any `mcp__obsidian__` tool, ALWAYS call ToolSearch first:**

```
ToolSearch(query: "select:mcp__obsidian__create-note,mcp__obsidian__search-vault,mcp__obsidian__read-note,mcp__obsidian__edit-note,mcp__obsidian__list-available-vaults,mcp__obsidian__create-directory,mcp__obsidian__move-note,mcp__obsidian__delete-note,mcp__obsidian__add-tags,mcp__obsidian__remove-tags,mcp__obsidian__rename-tag")
```

This is mandatory for Tier 1. Skipping ToolSearch → `InputValidationError`.

## Tiered Write Strategy (MCP-first, sanctioned fallback)

MCP は実運用で不安定（スキーマ遅延、ランタイム失敗、単一 Vault 縛り）。完全停止を避けるため 3 経路を持つ。

| Tier | 経路 | いつ使うか |
|---|---|---|
| 1 | `mcp__obsidian__*`（MCP） | **デフォルト**。対話的書き込み・検索。スキーマを ToolSearch でロードしてから呼ぶ |
| 2 | `Write` / `Edit` ツール直接書き込み | **Tier 1 が失敗または応答待ちで詰まったときの sanctioned フォールバック**。Vault path 限定（settings.json で許可済み） |
| 3 | Hook script `>>` append | `obsidian-session-end.sh` 等の自動化用。エージェントから直接シェルで append しない |

### Tier 2 を使う条件（全てを満たすこと）

1. Tier 1（MCP）を試して失敗または明確に詰まった（タイムアウト、ツール拒否、スキーマ未ロードでリトライ不可）
2. 書き込み先が `$OBSIDIAN_VAULT/**` 内
3. **Step 1-5（Search→Folder→Wikilink→Frontmatter→INDEX更新）は MCP 経路と同じく必須**。直接書き込みは「経路」が変わるだけで、Vault のルールは同じく守る
4. 直接書き込み後、後追いで MCP 経由 search-vault を 1 回呼んで反映確認するのが望ましい（必須ではない）

### Tier 2 で禁止される操作

- 既存ノートの **replace**（全置換）— append/prepend のみ。replace が必要なら MCP 復旧を待つ
- 大量バッチ書き込み（> 5 ノート連続）— Vault index 破損リスク。INBOX.md に列挙して MCP 経由で順次処理
- Vault 外への書き込み（自明だが念のため）

### Tier 2 を選んだら明示する

エージェントはユーザーに「Tier 2（直接 Write）で書き込みます。理由: <MCP がこう失敗した>」と一行宣言してから書く。サイレント・フォールバックは禁止。

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

## `Write`/`Edit` 直接書き込みポリシー

- **デフォルトは MCP 経由**（Tier 1）。Obsidian の内部 index が安定するため
- Tier 2（直接 Write/Edit）は上記「Tiered Write Strategy」の条件下でのみ許可
- 大規模置換やフォルダ移動が必要な場合は Tier 1 復旧を待つ — 直接 Write での replace は禁止
- 詳細は `Claude Code/横断テーマ/Obsidian書き込み多重化方針.md` を参照

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
