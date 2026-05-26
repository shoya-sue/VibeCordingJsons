# VibeCording Update — 2026-05-26 (consolidation cycle)

## 変更点サマリー

`v0.45.0` リリース後に判明した設定の散らばりと Obsidian MCP 接続不良を解消した二連リリース。`v0.45.1` で project-local 設定を撤去し `~/.claude/` に集約、`v0.45.2` で `template/.mcp.json` の deepwiki エントリにある HTTP transport 指定漏れを修正。

## 環境スナップショット
- Local ECC installed: 1.10.0
- Template ECC version: 1.10.0
- Previous release: v0.45.0
- Releases cut: v0.45.1, v0.45.2, v0.45.3 (this docs update)

## v0.45.1 — chore: remove project-local `.claude/` and `.mcp.json`

**PR**: #82 / commit `ef6f599`

### 撤去対象

| ファイル | 撤去理由 |
|---|---|
| `/.claude/settings.json` (repo-local) | 旧 StevenStavrakis obsidian-mcp ツール名 (`read-note`, `edit-note`, `create-note`, `list-available-vaults` 等 11 件) の dead allow リスト。現運用 cyanheads ではアンダースコア区切り (`obsidian_get_note` 等) なので存在しないツールを allow していた |
| `/.claude/settings.local.json` (repo-local) | 二重スラッシュタイポ (`Read(//Users/...)`) + 完了済み ad-hoc Bash 許可の蓄積汚れ |
| `/.mcp.json` (repo-local) | `~/.claude.json` user スコープと `github` エンドポイントが競合 → `claude mcp list` で scope conflict warning。OAuth トークンが分散する副作用も |
| `/.claude/worktrees/angry-kare-6f5bce` | 2 週間前の死 worktree (main 差分ゼロ, untracked は `.codex/` のみ, upstream gone) |
| `~/.mcp.json` (ホーム直下、project スコープ扱い) | `template/.mcp.json` 経由で配備されていたゴーストファイル。同じ MCP 定義を user スコープと重複保持 |

### 残存

`template/.claude/` と `template/.mcp.json` は配布物 (install.sh で他プロジェクトへ deploy するもの) なので無変更。

### 結果

`claude mcp list` の warning 3 件 (deepwiki broken / github scope conflict / 同上) のうち、後 2 件が消失。

## 真因: Local REST API plugin の disable

v0.45.1 作業の前段で発覚: `mcp__obsidian__obsidian_list_notes` 等の MCP ツール呼び出しが全て `Error: fetch failed (failed after 4 attempts)` で失敗していた。

**罠**: `claude mcp list` は `obsidian: ... - ✓ Connected` と表示するが、これは stdio で `obsidian-mcp-server` プロセスが起動して MCP handshake を完了したという意味のみ。その先の HTTPS 27124 (Obsidian app の REST API) には到達していなかった。

**実証**:
```
nc -zv 127.0.0.1 27124  →  Connection refused
nc -zv 127.0.0.1 27123  →  Connection refused
lsof -iTCP:27124        →  (出力ゼロ)
community-plugins.json  →  []  (Local REST API が有効化リストに存在しない)
```

vault `.obsidian/plugins/obsidian-local-rest-api/` フォルダと `data.json` (port: 27124, insecurePort: 27123) は存在していたので、Obsidian app 内のコミュニティプラグイン画面で **トグル OFF** になっていただけ。有効化して即解決。

## v0.45.2 — fix: template `.mcp.json` deepwiki missing `type:http`

**PR**: #83 / commit `9028b4d`

### 症状

`install.sh` を走らせるたびに `claude mcp list` 末尾の MCP Config Diagnostics に warning が復活:

```
[Warning] (/Users/shoya-sue/.mcp.json) [deepwiki] mcpServers.deepwiki: Skipped — invalid MCP server config for "deepwiki": command: expected string, received undefined
```

### 原因

`template/.mcp.json` の deepwiki エントリが下記の形:

```jsonc
"deepwiki": {
  "url": "https://mcp.deepwiki.com/mcp"
}
```

`type` が未指定だと Claude Code は stdio (command) 想定 → 必須の `command` が undefined で schema validation 失敗。`~/.claude.json` の user スコープでは `"type": "http"` 付きで稼働していたが、template だけ古い書式のまま残っていた。

### 修正

```diff
 "deepwiki": {
+  "type": "http",
   "url": "https://mcp.deepwiki.com/mcp"
 }
```

### 教訓

- stdio MCP: `command` + `args`
- HTTP MCP: `type: "http"` + `url`
- SSE MCP: `type: "sse"` + `url`
- `type` 省略時は stdio 想定 → URL ベースのサーバーは必ず明示

## v0.45.3 — docs: MCP list 修正 + Obsidian ノウハウ蓄積 (this update)

### 修正

| ファイル | 修正 |
|---|---|
| `template/README.md` | `What's Included` テーブルの `MCP Servers` 行に `obsidian` を追加 (5 個 → 6 個) |
| `template/AGENTS.md` | 同じく `Features` セクションの MCP 列挙を `5 MCP servers` → `6 MCP servers` + obsidian 追加 |
| `docs/2026-05-26-consolidation-update.md` (新規) | この更新ノート |

### Obsidian 蓄積

| 蓄積先 | 内容 |
|---|---|
| `30_knowledge/claude-code/themes/トラブルシュート集.md` | Local REST API plugin disable の罠 (3 段の接続層を区別、復旧手順、SessionStart healthcheck の役割) |
| `30_knowledge/claude-code/themes/MCPサーバー全リスト.md` | deepwiki `type:http` 要件、stdio/HTTP/SSE の型指定ルール |
| `20_projects/shoya-sue/VibeCordingJsons.md` | v0.45.1 + v0.45.2 リリース履歴、撤去対象一覧、確認結果 |

## 検証結果

すべての変更後、`install.sh ~` 実行 → 下記を確認:

- `claude mcp list`: 11/11 MCP servers ✓ Connected, MCP Config Diagnostics warning **ゼロ**
- `~/.claude/hooks/obsidian-mcp-healthcheck.sh`: **5/5 OK** (obsidian-mcp-server, OBSIDIAN_API_KEY, Local REST API plugin, Obsidian app reachable, auto-memory symlink)
- `mcp__obsidian__obsidian_list_notes`: vault PARA フォルダ構造を正常返却

## Lens 1 — Applicability (3 件)

| Change | Score | 判定 |
|---|---|---|
| project-local `.claude/` + `.mcp.json` 撤去 | High | install のたびに warning 復活していたので根本対応 |
| `template/.mcp.json` deepwiki `type:http` | High | install.sh が再 deploy するため template に直さないと意味なし |
| `template/README.md` + `AGENTS.md` MCP 列挙 obsidian 追加 | Medium | 配布物の正確性、template/.mcp.json と整合 |

## Lens 2 — Cross-file Consistency

- `template/.mcp.json` (実定義 6 個) ↔ `template/README.md` (列挙 6 個) ↔ `template/AGENTS.md` (列挙 6 個) で揃った
- `~/.claude.json` user スコープ deepwiki (`type:http`) ↔ `template/.mcp.json` deepwiki (`type:http`) で揃った
- `30_knowledge/claude-code/themes/MCPサーバー全リスト.md` の VibeCordingJsons プロジェクトレベルセクションも整合状態 (撤去履歴に新エントリは不要、トラブルシュートには追記済)
