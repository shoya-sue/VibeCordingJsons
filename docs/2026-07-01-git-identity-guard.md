# Git Identity Guard — 2026-07-01

## インシデント概要

2026-06-30 19:19:05、ユーザーのグローバル `~/.gitconfig` が丸ごと再生成され、
`[user]` の identity が **`Test User <test@test.com>`** に差し替わった。以降のコミットが
誤った著者名で記録され、**お客さん案件でも同様に発火**した。

物理証拠:
- `stat` で **birth = mtime = ctime が同一** → in-place 編集ではなく再生成
- LFS フィルタ・1Password 署名鍵・`commit.gpgsign` は**温存**、`[user]` のみ差し替え
  → ファイル丸ごと上書きではなく **`git config --global user.name/user.email` 2 コマンド**が実行された痕跡（lockfile→rename で inode 新規化 = birth 更新も説明できる）

## 調査結果（根本原因）

3 並列サブエージェント + 全システム横断検索の結論:

| 観点 | 結論 |
|------|------|
| ECC コミット済み実行コード | `git config --global user.name/email "Test User"` は **0 件**。ECC 内の `Test User` は skill ドキュメントの fixture 例のみ |
| ECC テストスイート | HOME/`GIT_CONFIG_GLOBAL` 隔離は概ね良好（try/finally cleanup 852+）。ただし `tests/run-all.js` が子プロセスに `HOME`/`GIT_CONFIG_GLOBAL` を**削除せず継承**、`opencode-tools.test.js` は `git config` に `env` を渡さない → **隔離リークの理論的経路が存在** |
| ECC 出荷スクリプト | 唯一の `git config --global` は `install-global-git-hooks.sh` の **`core.hooksPath`**（identity ではない）。他に `CLAUDE_RULES_DIR`/`HOME` 由来の書き込み先可変・merge-json の basename-only 判定などの間接リスクあり |

**断定**: ECC の出荷コードが直接 identity を書いた証拠はない。真因は「テストハーネス/CI のデフォルト ID（`Test User`/`test@test.com` は典型値）が、HOME 隔離不足の経路を通ってグローバル `~/.gitconfig` に書き込まれた」クラスの事故。→ **犯人特定に依存せず、このクラス全体を封じる防御**を導入する。

## 導入した多層防御（このリポジトリのテンプレに同梱）

すべて `template/.claude/` に配置し、`install.sh` で全案件へ配布される。グローバル
`~/.claude/` にも同時適用済み（即時保護）。

### 1. PreToolUse ガード hook — `guard-git-identity.sh`

- matcher `Bash`。コマンド文字列を解析（flag 順・空白に頑健）し、以下を **exit 2 でブロック**:
  - `git config` かつ (`--global` または `--system`) かつ `user.name`/`user.email`
  - `git config` かつ テスト/プレースホルダ identity（`Test User` / `test@test.com` / `your@email.com` 等）
- Claude 本体・subagent の両方に適用。ユーザーは `!` bang コマンドで手動実行可能（ガードを通らない）。

### 2. settings.json 宣言的 deny / ask（バックアップ）

```jsonc
"deny": [
  "Bash(git config --global user.name *)",
  "Bash(git config --global user.email *)",
  "Bash(git config --system user.name *)",
  "Bash(git config --system user.email *)",
  "Bash(git config --global --replace-all user.* *)"
],
"ask": [
  "Bash(git config --global core.hooksPath *)",   // ECC codex setup 等は確認付き
  "Bash(git config --system *)"
]
```

> arg-glob マッチは脆弱（flag 順・空白・env 前置で回避されうる）ため、堅牢な **hook (1) を主軸**、deny は宣言的シグナル兼バックアップ。

### 3. SessionStart センチネル hook — `git-identity-sentinel.sh`

- グローバル identity がテスト/CI/プレースホルダ値（`Test User`/`test@test.com`/`*@example.com` 等）なら**起動時に警告**（検知のみ・自動変更はしない）。
- **hook (1) の死角を補完**: Claude が起動した `npm test` 等の**サブプロセス内**での `git config --global`（HOME 未隔離）はツール層から見えない。センチネルは次回セッション開始時に汚染を検知し、誤った著者でコミットが続くのを防ぐ。

## 影響・非破壊性

- hook イベント数は不変（既存 `PreToolUse`/`SessionStart` 内への追加）→ `check-counts.sh` の `configured hooks = 10` は変わらず ✓
- 通常の開発フロー（`--local` identity、`git status`、`git config --global core.hooksPath`、`npm test`）はブロックされないことを負テストで確認済み
- `settings.json` は JSON 妥当性検証済み・テンプレ/グローバル両方に適用

## 関連

- 事故発生・修正: 別セッションで `~/.gitconfig` の identity は正規値へ復元済み（本 PR は identity 復元には触れない）
- テンプレ配布物: `template/.claude/hooks/guard-git-identity.sh`, `template/.claude/hooks/git-identity-sentinel.sh`, `template/.claude/settings.json`, `template/AGENTS.md`, `template/CLAUDE.md`
