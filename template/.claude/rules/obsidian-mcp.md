# Obsidian Vault Writing Rules

> **2026-05-13 更新**: `obsidian-mcp` パッケージは長時間応答なし・スキーマ遅延などのバグで運用不能と判断。
> 単一経路に統一: **Write/Edit 直接書き込みを主軸**とし、構造化 wiki vault では `claude-obsidian` プラグインの slash command を併用する。MCP server `obsidian` は使用しない。

## Vault Paths

| 用途 | パス | Env |
|---|---|---|
| メイン vault（既存 iCloud） | `${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/` | `$OBSIDIAN_VAULT` |
| 構造化 wiki vault（claude-obsidian） | `${HOME}/Public/shoya-sue/claude-obsidian/`（任意・ユーザ環境次第） | — |

メイン vault は Sessions/プロジェクト/横断テーマ等の日常知識用。  
wiki vault は Karpathy 風 LLM Wiki（concepts/entities/sources/.raw）で、claude-obsidian プラグインの `/wiki`, `/save`, `/autoresearch`, `/canvas` で操作する（プラグイン未インストールならスキップ）。

## Writing Strategy (3 経路、用途で選択)

| 経路 | 何で書くか | いつ使うか |
|---|---|---|
| 1 | `Write` / `Edit` ツール直接 | **デフォルト**。あらゆる Obsidian 書き込み。Vault path に対する settings.json の `allow` で許可済み |
| 2 | claude-obsidian プラグイン slash command (`/wiki`, `/save`, `/autoresearch`, `/canvas`) | wiki vault で wiki/index.md・concepts/・entities/ などを構造化追記するとき |
| 3 | Hook script `>>` append | `obsidian-session-end.sh` 等の自動化用。エージェントから直接シェルで append しない |

**サイレント・フォールバック禁止**: ツールが失敗した場合は理由を一行宣言してから次経路へ。

### 経路選択の判断基準

- **メイン vault の `Claude Code/`, `開発/`, `学習/`, `INBOX.md`** → **Write/Edit**
- **wiki vault の `wiki/` 配下に体系的に追加**（自動リサーチ、エンティティ登録など）→ **claude-obsidian slash command**
- **セッション終了・コンパクション・サブエージェント完了の自動ログ** → **Hook script**（既存）

### Write/Edit 直接書き込みの注意

- 既存ノートの **全置換** は慎重に。原則 append/prepend。replace が必要なときは Edit の `old_string`/`new_string` で局所置換
- 大量バッチ（> 5 ノート連続作成）は INBOX.md に列挙してから人/エージェントが順次処理
- Vault 外への書き込み禁止
- 書き込み後に **graph view で孤立しない** ように Step 3 の [[wikilink]] ルールを守る

## Writing Protocol (MANDATORY)

Every write to Obsidian MUST follow this sequence:

### Step 1: Search Before Write

Before creating or editing any note, search for related existing notes:

```bash
# メイン vault
grep -ril "<topic keywords>" "$OBSIDIAN_VAULT/Claude Code/" "$OBSIDIAN_VAULT/開発/" 2>/dev/null

# wiki vault（任意）
grep -ril "<topic keywords>" "${HOME}/Public/shoya-sue/claude-obsidian/wiki/" 2>/dev/null
```

広範な探索が必要な場合は Explore subagent（haiku モデル）に委任する。  
This prevents duplication and reveals notes that should receive [[wikilinks]].

### Step 2: Determine Target Folder

Use the Content → Folder Mapping table below to decide where content belongs.

### Step 3: Write with [[Wikilinks]]

**Every note MUST contain at least one [[wikilink]] to an existing vault note.**

Wikilinks that graph-connect content (メイン vault):
- `[[Claude Code/INDEX]]` — always link new Claude Code notes here
- `[[Claude Code/プロジェクト/shoya-sue/VibeCordingJsons]]` — link from project-related notes
- `[[Claude Code/横断テーマ/MCPサーバー全リスト]]` — link from MCP-related notes
- `[[Claude Code/横断テーマ/トラブルシュート集]]` — link from troubleshooting notes
- `[[Claude Code/横断テーマ/feedback集約]]` — link from feedback/preference notes
- `[[Claude Code/環境設定]]` — link from environment/config notes
- `[[HOME]]` — only for top-level MOC notes

wiki vault では `[[wiki/index]]` または親概念ノートにリンクする。

Leaf notes that have NO links are invisible in graph view — always add at least one.

### Step 4: Add Frontmatter

```markdown
---
created: YYYY-MM-DD
tags: [claude-code, <topic-tag>]
---
```

### Step 5: Update INDEX or parent MOC if creating a new note

After creating a new note in `Claude Code/`, add a link to it in `Claude Code/INDEX.md` (Edit tool で append).  
wiki vault では `wiki/index.md` に append。

## Content → Folder Mapping

| Content Type | Target Path | Action |
|---|---|---|
| Project architecture, decisions | `Claude Code/プロジェクト/<owner>/<repo>.md` | EDIT (existing) |
| New project notes (other repos) | `Claude Code/プロジェクト/<owner>/<repo>.md` | CREATE |
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
| Structured wiki concepts (wiki vault) | `wiki/concepts/<topic>.md` | claude-obsidian `/wiki` |
| Named entities (wiki vault) | `wiki/entities/<entity>.md` | claude-obsidian `/wiki` |
| Research sources (wiki vault) | `wiki/sources/<source>.md` | claude-obsidian `/save` or `/autoresearch` |

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

## When to Use Which Tool

| Goal | Tool |
|---|---|
| Find related notes before writing | `grep -ril` / Explore subagent |
| Read an existing note | `Read` |
| Create a new note | `Write` |
| Add content to existing note | `Edit` (append/局所置換) |
| Rename / move a note | `Bash` (`mv`) — Vault path 限定 |
| Structured wiki ingest (claude-obsidian vault のみ) | `/wiki` slash command |
| Save URL or article (claude-obsidian vault のみ) | `/save` slash command |
| Auto research (claude-obsidian vault のみ) | `/autoresearch` slash command |
| Canvas drawing (claude-obsidian vault のみ) | `/canvas` slash command |

## Anti-Patterns

- ❌ `mcp__obsidian__*` ツールを呼ぶ — server は撤去済み、`InputValidationError` になる
- ❌ MCP の応答待ちで何分も詰まる — ToolSearch でロード試行も不要
- ❌ サイレントなツール切替（ユーザーへの宣言なし）
- ❌ Vault 外への書き込み
- ❌ 大量バッチ（> 5 連続）の `Write` 呼び出し

詳細な経緯と判断記録は vault の  
`Claude Code/横断テーマ/Obsidian書き込み多重化方針.md` を参照。
