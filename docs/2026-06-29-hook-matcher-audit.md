# VibeCording Develop — 2026-06-29 — hook matcher 監査の標準化

## 背景

v0.73.0（Claude Code 2.1.195）で、2.1.195 の「ハイフン付き hook matcher 部分一致→完全一致」変更を検証する過程で、テンプレ出荷の hook matcher `mcp__obsidian__*` が公式正規形でない（bare glob、regex 偶然一致で動作）ことが判明し `mcp__obsidian__.*` に是正した（#A）。

この develop サイクルでは、その単発修正を **再発防止できる「標準」へ昇格**させる。新しい Claude Code バージョンは無い（2.1.195 が最新）ため、CC カバレッジではなく**プロセス/ガード/ドキュメントの標準化**が対象。

## 全体監査の結果

リポジトリ内の全 `settings*.json` / `.codex/hooks.json` の hook matcher を機械監査:

| ファイル | matcher | 判定 |
|---|---|---|
| `template/.claude/settings.json` | `Bash` / `Write\|Edit` / `mcp__obsidian__.*` | 全て idiomatic ✓ |
| `.claude/settings.local.json` | （hook matcher 無し） | — |
| `template/.codex/hooks.json` | `*` | match-all（公式で正当）✓ |

→ **#A 以外に非idiomatic/破壊リスクのある matcher は無し**。テンプレは現状クリーン。

## 成果物（3 件）

### ① ドキュメント権威化 — `template/.claude/rules/ecc/common/hooks.md`
公式の **matcher 評価 3 モード表**（match-all / exact-string / JS regex）を events テーブル直後に追加。`mcp__<server>__.*` が正規形であること、bare glob `mcp__<server>__*` が「regex `_*` で偶然部分一致するが非推奨」であることを明文化。既存の comma/pipe gotcha（v2.1.191）とハイフン完全一致（v2.1.195）注記はその下に再配置。

### ② 機械ガード — `scripts/check-counts.sh`
`template/.claude/settings.json` の全 hook matcher を走査し、**bare glob（`*` を含むが match-all でも `.*` regex でもない）を検出したら fail** するガードを追加。`#A` の再発を release 前の `check-counts.sh` で自動検出する。
- 負テスト済み: `mcp__obsidian__*` を注入 → `NON-IDIOMATIC HOOK MATCHER` で fail、`.*` 復元で pass。

### ③ プロセス標準化 — `.claude/skills/update-release/SKILL.md`
Step 0.5 の品質分析に **Lens 5 — Breaking-change Audit（出荷 config への破壊的変更監査）** を追加。changelog 項目が matching/permission/parsing セマンティクスを変える場合、ドキュメントだけでなく**出荷 config 自体が壊れないか**を必ず監査し、壊れるなら同一 PR で 🔴 修正する標準手順を明記。4 レンズ → 5 レンズに更新（0変更カバレッジ検証の記述も同期）。

## リスク / 完全性

- Risk: Low（ドキュメント追加 + テスト済みガード + skill 手順追記。settings.json の matcher 実体は v0.73.0 で既に `.*` 化済みで本サイクルでは不変）。
- Completeness: hooks.md（権威）↔ check-counts.sh（強制）↔ update-release skill（プロセス）の 3 点が相互参照し、監査が one-off でなく恒久ループになる。
- counts 不変（`check-counts.sh` ✓ 10/55/10/7）。ECC 2.0.0 据え置き。
