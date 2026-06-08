---
name: obsidian-promotion
description: Obsidian auto-captures の自動昇格 — Stop hook が貯めた未処理キャプチャを PARA 恒久知識へ MCP 経由で promotion
allowed-tools: ["ToolSearch", "Read", "Write", "Edit", "Bash", "mcp__obsidian__vault_read", "mcp__obsidian__vault_write", "mcp__obsidian__vault_append", "mcp__obsidian__vault_patch", "mcp__obsidian__vault_list", "mcp__obsidian__vault_get_document_map", "mcp__obsidian__search_query", "mcp__obsidian__search_simple", "mcp__obsidian__tag_list"]
effort: high
---

Obsidian Vault の **未処理 auto-captures を恒久知識へ昇格**してください。

`obsidian-auto-capture.sh`（Stop hook）が `90_artifacts/claude-code/auto-captures/YYYY-MM.md` に
貯めた `<!-- 未処理 -->` エントリを、`~/.claude/rules/obsidian-mcp.md` の Content → Folder Mapping に
従って themes / 環境設定 / decisions / projects / learning へ移し、元エントリのマーカーを
`<!-- promoted: YYYY-MM-DD → <dest> -->` に置換します（capture 自体は provenance として残す）。

## 実行前チェック（timing guard）

現在時刻を `date '+%H:%M'` で確認し、10:00〜12:00 の範囲外なら処理をスキップして以下のみ出力:
「auto-capture promotion スキップ — 実行時刻が対象範囲外です（{実行時刻}）。次回の平日 10:00 に実行されます。」

## 前提

書き込みは `~/.claude/rules/obsidian-mcp.md` の経路 1（`mcp__obsidian__vault_*`）を主軸にする。
SessionStart healthcheck（`## Obsidian MCP & auto-memory healthcheck`）が `⚠`/`✗` の場合のみ
一行宣言してから `Read`/`Write`/`Edit` に fallback する。

## 実行手順

### STEP 1: MCP スキーマをロード

```
ToolSearch(query: "select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_append,mcp__obsidian__vault_patch,mcp__obsidian__vault_list,mcp__obsidian__vault_get_document_map,mcp__obsidian__search_query,mcp__obsidian__search_simple")
```

### STEP 2: 当月の auto-captures を読む

```
mcp__obsidian__vault_read(path: "90_artifacts/claude-code/auto-captures/$(date +%Y-%m).md")
```

`<!-- 未処理 -->` マーカーが付いた全エントリを収集する。`<!-- promoted: ... -->` /
`<!-- SKIP ... -->` は処理済みなのでスキップ。先月分に未処理が残っていれば前月ファイルも読む。

### STEP 3: 重複チェック（Search Before Write）

各候補について昇格先に既出でないか確認してから書く（重複防止）:
```
mcp__obsidian__search_query(...)   # or search_simple / grep
```

### STEP 4: PARA 宛先へ昇格

`~/.claude/rules/obsidian-mcp.md` のマッピングに従う:

| カテゴリ | 宛先 | ツール |
|---|---|---|
| トラブルシュート | `30_knowledge/claude-code/themes/トラブルシュート集.md` | `vault_append` / `vault_patch` |
| feedback | `30_knowledge/claude-code/themes/feedback集約.md` | `vault_append` / `vault_patch` |
| 環境設定 | `30_knowledge/claude-code/環境設定.md` | `vault_patch` |
| MCP変更 | `30_knowledge/claude-code/themes/MCPサーバー全リスト.md` | `vault_patch` |
| 設計判断 (ADR) | `50_decisions/<YYYY-MM-DD>-<title>.md` | `vault_write` |
| 実装マイルストーン | `20_projects/<owner>/<repo>.md` | `vault_append` |
| 学び | `40_learning/<topic>.md` | `vault_write` / `vault_append` |

各昇格ノートには **必ず 1 つ以上の `[[wikilink]]`** を含める（graph 孤立防止）。
判定が ambiguous なエントリは `00_inbox/undecided-YYYY-MM.md` へ退避し、INBOX には残さない。

### STEP 5: マーカーを置換

昇格できた各エントリは auto-captures 内のマーカーを置換する:
```
<!-- 未処理 -->  →  <!-- promoted: YYYY-MM-DD → <destination path> -->
```
元の capture 本文は **削除しない**（provenance）。マーカー置換は対象ブロックを
`vault_get_document_map` で確認してから `vault_patch`（operation: "replace"）で行う。

### STEP 6: サマリ出力

昇格件数・宛先内訳・undecided 退避件数・SKIP 件数をサマリ出力する。

## 安全制約

- auto-captures の capture 本文は削除しない（マーカーのみ置換）
- iCloud Sync があるため **1 ファイルずつ順番に** 書き込む（並列書き込みしない）
- `attachments/` / `.obsidian/` / `.backup/` / `.trash/` は操作対象外
- 既に `<!-- promoted: ... -->` / `<!-- SKIP ... -->` のエントリは再処理しない（冪等）
- Vault 外への書き込み禁止

## 登録方法（scheduled task として動かす）

このファイルは scheduled task の **定義** です。実際に定期実行するには `/schedule` で
routine を登録してください（例: 平日 10:00 にこの skill を実行）。手動で回す場合は
`/obsidian-synthesis` が同等の promotion ステップ（Step 6）を内包しています。

関連: [[30_knowledge/claude-code/INDEX]] / `~/.claude/rules/obsidian-mcp.md`
