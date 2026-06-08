# 2026-06-08 Context management: drop the 1M auto-compact override

## 背景

`template/.claude/settings.json` の `env` に長らく `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000` を入れていた。これは upstream バグ [anthropics/claude-code#43989](https://github.com/anthropics/claude-code/issues/43989)（v2.1.92 以降、**1M context モードで自動圧縮の閾値が 400K に誤縮小**する regression。2026-06-08 時点で OPEN/未修正）の workaround で、**1M アクセスを持つ利用者向け**だった。

## 問題

このワークアラウンドは **1M context モード前提**。標準 200K ウィンドウの利用者（`s1mAccessCache.hasAccess=false`、利用ログに `[1m]` 接尾辞なし）に適用すると、CC が「ウィンドウは 1M」と誤認するのに実モデルは 200K しか受け付けないため、**自動圧縮が実上限の前に発火しない**。「コンテキストが圧縮されなくなった」体感の原因。

## 変更

- `template/.claude/settings.json`: `CLAUDE_CODE_AUTO_COMPACT_WINDOW` を **削除**（CC ネイティブの自動圧縮閾値に委ねる）。
- `template/.claude/rules/ecc/common/performance.md`: Context Window Management 節を Anthropic 公式 "effective context engineering" の能動ハイジーン方針に刷新（`/context`・`/compact`・`/clear`・`/goal`・subagent 委任・状態外部化）。`AUTO_COMPACT_WINDOW` は **1M-only の opt-in workaround** と明記。

## 1M モード利用者向け（opt-in）

`/model claude-opus-4-8[1m]` 等で実際に 1M を使い、#43989 に当たる場合のみ、`~/.claude/settings.json` の `env` に手動で復活させる:

```json
"CLAUDE_CODE_AUTO_COMPACT_WINDOW": "1000000"
```

## ベストプラクティス（要点）

コンテキストは最大化せず **"smallest set of high-signal tokens"**。利用率は `/context` で監視（~40% から劣化、60% 超で要注意）、区切りで `/compact <焦点>`、タスク切替で `/clear`、長期タスクは `/goal`、重い探索は subagent 委任、恒久状態は外部化。Opus 4.8 の effort は `high` 既定でスイープ。

## 検証

- CC v2.1.168 / #43989 OPEN を再確認。
- `./install.sh ~` で `~/.claude/settings.json` から override 削除を配備。
- 利用者は `/context` で分母（実ウィンドウ）と Auto-compact window 行を確認。
