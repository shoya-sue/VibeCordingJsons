# VibeCording Update — 2026-06-08 (Obsidian 蓄積体制の修復・強化)

## 変更点サマリー

Obsidian への知識蓄積体制を調査した結果、**MCP 経由で書き込む唯一の能動的経路である
`obsidian-synthesis` skill が、旧 MCP サーバー（cyanheads 系）のツール名 `obsidian_*` を参照したまま
取り残されており、現行の native MCP（Local REST API & MCP Server、`vault_*` 系）では実行すると
MCP 書き込みが全滅する状態**だったことが判明。これを修復し、あわせて自動キャプチャの抽出範囲拡張と
自動昇格 scheduled task を追加する。

自動キャプチャ層（session log / auto-capture / memory symlink）が MCP を使わずファイル追記・symlink で
書く設計は **意図的で正しい**（Obsidian 非起動時もサイレント失敗せず確実に残る）ため変更しない。
MCP は「能動的な synthesis / promotion」経路で使う、という二層構造を今回正しく繋ぎ直した。

## 環境スナップショット

- Current release: **v0.51.0**（2026-06-08）→ 本リリースで **v0.52.0**
- Local ECC = Template ECC: 1.10.0 ✓（今回 ECC 変更なし）
- 対象は Obsidian 連携の skill / hook / rule / scheduled-task / install.sh のみ（settings.json・CC バージョン同期は対象外）

## トリアージ済みアクションリスト

### 🔴 必須（バグ修正）

- [x] **G1**: `obsidian-synthesis` skill の MCP ツール名を現行 native MCP に全置換
  — `template/.claude/skills/obsidian-synthesis/SKILL.md`
  - `allowed-tools` / `ToolSearch` select / 本文の全 `mcp__obsidian__obsidian_*` 呼び出しを
    `vault_read` / `vault_write` / `vault_append` / `vault_patch` / `vault_list` /
    `vault_get_document_map` / `search_query` / `search_simple` / `tag_list` に置換（stale 参照 0）
  - 未処理 auto-captures の昇格ステップ（Step 4・6）を skill 本体に追加
- [x] **G1b**: `obsidian-mcp-healthcheck.sh` の存在しない案内ノート参照を修正
  — `template/.claude/hooks/obsidian-mcp-healthcheck.sh`
  - `30_knowledge/claude-code/obsidian-mcp-cyanheads-setup.md`（旧 MCP、未作成）→ `~/.claude/rules/obsidian-mcp.md`

### 🟡 推奨（機能拡張）

- [x] **G2**: auto-capture の抽出カテゴリを 4 → 7 に拡張
  — `template/.claude/hooks/obsidian-auto-capture.sh`
  - 追加: **設計判断(ADR) / 実装マイルストーン / 学び**。昇格先 wikilink に
    `[[50_decisions/index]]` `[[20_projects/index]]` `[[40_learning/index]]` を追加
  - 抽出基準（再発見コストの高い情報を優先、作業ログ・git log 追跡可能分は除外）を明文化
  - rules doc を実装に整合（誤記 `--bare 必須` を削除 → 実体は OAuth・`--bare` 不使用・env ガード再帰防止）
    — `template/.claude/rules/obsidian-mcp.md`
- [x] **G3**: 自動昇格 scheduled task を新規追加
  — `template/.claude/scheduled-tasks/obsidian-promotion/SKILL.md`（新規）
  - timing guard → 未処理 capture を PARA 宛先へ MCP 昇格 → マーカーを `<!-- promoted: ... -->` へ置換
    （capture 本文は provenance として残す、iCloud 配慮で逐次書き込み、冪等）
  - `install.sh` の copy ループに `scheduled-tasks` を追加 — `install.sh`

### ⚪ スキップ

- **G4**: セッション中 MCP 書き込みの強制（hook/skill による enforce）— ユーザー判断で今回見送り
- 自動キャプチャ層の MCP 化 — 意図的にファイル追記のままとする（信頼性優先、Obsidian 非起動でも残る）

## 品質分析（4 レンズ要約）

- **適合性**: G1 はテンプレ利用者の MCP 蓄積経路を実際に壊していたバグの修正（High）。G2/G3 は「対応内容のほぼ全てを蓄積」という運用ゴールへの直接的な拡張（Medium-High）
- **横断一貫性**: skill / scheduled-task の使用ツール名と `obsidian-mcp.md` の正典ツール表が一致。3 skill/doc で stale `obsidian_*` ゼロを確認
- **リスク**: 全変更が markdown / bash 文字列 / install.sh の copy ループ追加に限定。`bash -n` 通過、heredoc 破損なし、`cp -r` は既存 scheduled-task 定義の上書きのみ（想定挙動）
- **完全性**: template == global の 5 ファイル完全一致を diff で確認。グローバル設定は即時修復済み

## 検証

- `install.sh` / 両 hook の `bash -n` 構文チェック通過
- template と `~/.claude/` の対象 5 ファイル diff なし（完全同期）
- stale `obsidian_*` / `cyanheads` 参照ゼロを grep 確認

---

関連: [[20_projects/shoya-sue/VibeCordingJsons]] / [[30_knowledge/claude-code/themes/Obsidian書き込み多重化方針]]
