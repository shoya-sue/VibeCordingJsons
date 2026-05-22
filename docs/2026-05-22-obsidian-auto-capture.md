# VibeCording Update — 2026-05-22 (Obsidian Auto-Capture)

## 変更点サマリー

Stop hook で Haiku 4.5 が自動発動し、セッション transcript から **promotion 候補**（トラブルシュート / feedback / 環境設定 / MCP 変更）を抽出して `90_artifacts/claude-code/auto-captures/YYYY-MM.md` に append する仕組みを追加。あわせて token 節約のため `CLAUDE_CODE_SUBAGENT_MODEL: haiku` を追加。

ユーザーは「Obsidian」と指示する必要なく、普通にプロンプトで作業を終えるだけで自動発動する。

## 環境スナップショット

- Local ECC installed: 1.10.0
- Template ECC version: 1.10.0 (in sync)
- Current release: v0.43.0
- Next version: v0.44.0
- Local Claude Code: v2.1.148

## Plan A 訂正の経緯

事前調査で提案した `CLAUDE_CODE_AUTOCOMPACT_PCT_OVERRIDE: 75` は **Vault の `30_knowledge/claude-code/token-cost-optimization.md`（2026-05-14 検証済）** の以下記述により撤回:

> `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` は Opus 4.7 では `Math.min` clamp で実質効かず、低い値は逆効果。4.7 環境では別 env var `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000` が真の workaround（既設定済）。

→ Plan A は `CLAUDE_CODE_SUBAGENT_MODEL: haiku` のみ追加。

## Auto-capture 設計の経緯

Vault MCP 接続で実態確認した結果:

| 観察 | 設計への影響 |
|---|---|
| `INBOX.md` は人間専用（shoya-sue 明言） | auto-capture は INBOX に書かない |
| `themes/feedback集約.md` 等は curated（H2 で構造化、人＋Sonnet 編集） | auto-capture は themes/ に書かない |
| `50_decisions/` は ADR 23 件、全て人間判断 | auto-capture は decisions/ に書かない |
| `90_artifacts/claude-code/sessions/YYYY-MM.md` は既に生ログ自動 append | 生ログは既存 hook のまま、抽出は別レイヤー |
| `30_knowledge/claude-code/memory/Public/feedback-haiku-batch-quality.md` 存在 | Haiku 大量自動処理に対する shoya-sue の懸念既知。本フックは 1 セッション 1 回 + 候補出すだけなので OK |

→ 新規 Claude 専有領域 `90_artifacts/claude-code/auto-captures/YYYY-MM.md` に append、promotion は手動 or `/obsidian-synthesis`。

## モデル選定の経緯

shoya-sue の「Obsidian 蓄積は Haiku」案に対する Claude 見解（採用）:

| フェーズ | モデル | 根拠 |
|---|---|---|
| Step 1: 抽出（transcript → auto-captures/） | **Haiku 4.5** | 低リスク append-only、本フックは候補出すだけ |
| Step 2: 昇格（auto-captures/ → themes/memory） | **Sonnet** (`/obsidian-synthesis`) | curated themes 品質維持、cross-reference 判断あり |
| Step 3: ADR 起草（50_decisions/） | **Sonnet + 人間レビュー** | 既存 23 件は全て人間判断、auto-capture 対象外 |

## 再帰防止

`claude --bare` フラグを使用。これにより:
- hooks スキップ（Stop hook の再帰呼び出しなし）
- LSP / plugins / CLAUDE.md / auto-memory / background prefetches スキップ
- Haiku 4.5 純粋呼び出しのみ
- `--max-budget-usd 0.10` で安全キャップ

## 変更内容

### 🔴 必須（実装済）

- [x] `template/.claude/settings.json`:
  - `env.CLAUDE_CODE_SUBAGENT_MODEL: "haiku"` 追加
  - `hooks.Stop` に `obsidian-auto-capture.sh` エントリ追加（既存 `obsidian-session-end.sh` の後段）
- [x] `template/.claude/hooks/obsidian-auto-capture.sh` 新規作成（実行権限付き）
- [x] `template/.claude/rules/obsidian-mcp.md` に「Auto-capture Layer (Stop hook, 2026-05-22 追加)」セクション追記
- [x] Vault `90_artifacts/claude-code/auto-captures/INDEX.md` 初期化（Obsidian MCP 経由）
- [x] Vault `90_artifacts/index.md` に auto-captures/ へのリンク追記

## 動作仕様

```
shoya-sue がプロンプト送信 → 通常作業 → セッション終了
   ↓
Stop hook 連鎖
   ├─ ECC session-end.js  (既存)
   ├─ obsidian-session-end.sh  (既存、生ログ → sessions/YYYY-MM.md)
   └─ obsidian-auto-capture.sh  (新規)
         ↓ 前提チェック
         │  - $OBSIDIAN_VAULT 存在
         │  - jq, claude CLI 存在
         │  - transcript 5KB 以上（trivial スキップ）
         ↓
         claude --bare --model claude-haiku-4-5 -p "<抽出 prompt>"
            (transcript JSONL を stdin で渡す)
         ↓
         結果が "SKIP" 以外なら
         → 90_artifacts/claude-code/auto-captures/YYYY-MM.md に append
```

## 動作確認方法

1. `./install.sh ~` で hook を deploy
2. 任意のプロジェクトで Claude Code セッションを 1 回実行（5KB 以上の transcript 生成）
3. セッション終了後、数分以内に `$OBSIDIAN_VAULT/90_artifacts/claude-code/auto-captures/2026-05.md` 確認
4. 該当なしセッションは何も append されない（no-op）

## Skip 条件（意図的）

| 条件 | 理由 |
|---|---|
| `claude` CLI 不在 | 環境依存、サイレント no-op |
| `jq` 不在 | 入力 JSON parse 不可、サイレント no-op |
| `$OBSIDIAN_VAULT` 不在 | iCloud 未同期マシン等 |
| transcript < 5KB | trivial セッション、抽出対象なし |
| 90 秒タイムアウト | 異常な巨大 transcript の暴走防止 |
| Haiku が "SKIP" 出力 | 抽出対象なし、append しない |
| `--max-budget-usd 0.10` 超過 | コスト暴走防止 |

## 関連 Vault ノート

- [[90_artifacts/claude-code/auto-captures/INDEX]] — 本機能の MOC
- [[30_knowledge/claude-code/themes/Obsidian書き込み多重化方針]] — 4 経路 + auto-capture layer
- [[30_knowledge/claude-code/token-cost-optimization.md]] — Plan A 訂正の根拠
- [[30_knowledge/claude-code/memory/Public/feedback-haiku-batch-quality]] — Haiku 大量処理懸念（本フックは 1 セッション 1 回なので該当せず）

## Sources

- [Claude Code Changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- `claude --help` v2.1.148（`--bare`, `--max-budget-usd`, `--no-session-persistence` 確認）
