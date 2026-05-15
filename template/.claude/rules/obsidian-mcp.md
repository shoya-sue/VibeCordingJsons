# Obsidian Vault Writing Rules

> **2026-05-15 採用構成**: vault への書き込みは **Obsidian MCP (cyanheads/obsidian-mcp-server + Local REST API plugin) を主軸**にする。Write/Edit はフォールバック。
>
> 主軸ツール: `mcp__obsidian__obsidian_*` (12 ツール、特に `obsidian_patch_note` で heading/block/frontmatter 単位の surgical edit が可能)。
> セットアップ詳細: vault の `30_knowledge/claude-code/obsidian-mcp-cyanheads-setup.md`
>
> **2026-05-13 〜 2026-05-15 朝の経緯** (歴史記録):
> - 一時期 `StevenStavrakis/obsidian-mcp v1.0.6` を採用していたが、以下 2 件の既知バグで撤去:
>   - ConnectionMonitor が 70 秒無操作で silent close ([Issue #37](https://github.com/StevenStavrakis/obsidian-mcp/issues/37))
>   - `edit-note` の `z.discriminatedUnion` が `zodToJsonSchema` で空 properties になり Claude が引数を組めない ([Issue #48](https://github.com/StevenStavrakis/obsidian-mcp/issues/48))
>   - 全ツール `vault` 引数必須の UX 設計欠陥
> - 2026-05-15 夕方に **cyanheads + Local REST API plugin** で再採用に方針転換。Obsidian Community Plugin Store 登録 plugin を経由するため「半公式」レベルの信頼性。
> - 誤った仮説 (全部否定済): Obsidian アプリ「Settings → Command line interface」を ON にすれば直る (Issue #36 未実装) / `mcp-rest` プラグイン (別系統) を入れれば直る / iCloud sync の問題 (`.icloud` placeholder 0 個で無罪)
>
> 詳細経緯: vault の `30_knowledge/claude-code/obsidian-mcp-v1.0.6-trap.md`

## Vault Paths

| 用途 | パス | Env |
|---|---|---|
| メイン vault（既存 iCloud） | `${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/` | `$OBSIDIAN_VAULT` |
| 構造化 wiki vault（claude-obsidian） | `${HOME}/Public/shoya-sue/claude-obsidian/`（任意・ユーザ環境次第） | — |

メイン vault は Sessions/プロジェクト/横断テーマ等の日常知識用。  
wiki vault は Karpathy 風 LLM Wiki（concepts/entities/sources/.raw）で、claude-obsidian プラグインの `/wiki`, `/save`, `/autoresearch`, `/canvas` で操作する（プラグイン未インストールならスキップ）。

## Writing Strategy (4 経路、優先順位順)

| 優先 | 経路 | 何で書くか | いつ使うか |
|------|------|------------|-----------|
| 1 | **Obsidian MCP** (`mcp__obsidian__obsidian_*`) | cyanheads ツール 12 個 | **デフォルト**。vault 内すべての read/write/edit。surgical edit (heading/block/frontmatter 単位) に対応 |
| 2 | `Write` / `Edit` ツール直接 | 標準ツール | MCP healthcheck が ✗ を返す状況、または MCP がカバーしないファイル形式 (画像・大バイナリ等)。**フォールバック時は一行宣言してから** |
| 3 | claude-obsidian プラグイン slash command (`/wiki`, `/save`, `/autoresearch`, `/canvas`) | Obsidian アプリ内 | wiki vault で wiki/index.md・concepts/・entities/ などを構造化追記するとき |
| 4 | Hook script `>>` append | bash | `obsidian-session-end.sh` 等の自動化用。エージェントから直接シェルで append しない |

**サイレント・フォールバック禁止**: ツールが失敗した場合は理由を一行宣言してから次経路へ。

### MCP ツール選択ガイド (経路 1)

| 用途 | ツール | 補足 |
|------|--------|------|
| ノートを新規作成 / 完全上書き | `obsidian_write_note` | `overwrite: true` で上書き、デフォルトは衝突回避 |
| 既存ノート末尾に追記 | `obsidian_append_to_note` | section 引数で heading 末尾にも |
| heading/block/frontmatter にピンポイント編集 | `obsidian_patch_note` | append / prepend / replace、document-map で target を先に確認 |
| body 内 find-and-replace | `obsidian_replace_in_note` | regex 可、複数 replacement の順次適用 |
| frontmatter フィールド操作 | `obsidian_manage_frontmatter` | YAML 構造を壊さない |
| tag 追加/削除 | `obsidian_manage_tags` | vault 全 tag は `obsidian_list_tags` |
| 構造把握 | `obsidian_get_note (format=document-map)` | heading / block / frontmatter field 一覧 |
| 横断検索 | `obsidian_search_notes (mode=dataview)` | DQL クエリで複雑条件 |

### MCP 経路の事前確認

書き込み前に SessionStart hook の healthcheck 出力 (`## Obsidian MCP & auto-memory healthcheck`) を確認:

- `✓ (5/5 OK)` → 経路 1 を使う
- `⚠` がある → 該当項目を fix するか、ユーザーに 1 行宣言して経路 2 に fallback

`PostToolUseFailure` で `mcp__obsidian__*` が失敗したら `~/.claude/hooks/obsidian-mcp-recovery.sh` が ToolSearch でのスキーマ再ロード手順を案内する。

### Write/Edit 直接書き込みの注意 (経路 2)

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

- ❌ healthcheck で MCP が ✓ なのに Write/Edit を選ぶ — MCP が surgical edit を提供しているのに使わないのは劣化
- ❌ healthcheck で ✗ が出ているのに MCP ツールを呼んで失敗を繰り返す — recovery hook の指示に従う
- ❌ サイレントなツール切替（ユーザーへの宣言なし）
- ❌ Vault 外への書き込み
- ❌ 旧 `StevenStavrakis/obsidian-mcp` 系のツール名 (`mcp__obsidian__list-available-vaults`, `read-note`, `edit-note` 等) を呼ぶ — 現運用は cyanheads (`obsidian_get_note`, `obsidian_write_note`, `obsidian_patch_note` 等) なので存在しない
- ❌ 大量バッチ（> 5 連続）の `Write` 呼び出し — `obsidian_patch_note` を使うか INBOX.md に列挙

詳細な経緯と判断記録は vault の  
`30_knowledge/claude-code/obsidian-mcp-cyanheads-setup.md` (採用構成) と  
`30_knowledge/claude-code/obsidian-mcp-v1.0.6-trap.md` (撤去判断の歴史) を参照。
