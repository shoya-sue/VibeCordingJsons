---
name: sync-memory
description: Check Copilot CLI memory sync status for this project
user-invokable: true
allowed-tools: ["Bash(ls *)", "Bash(echo *)", "Bash(test *)"]
---

# sync-memory

> **v0.13.0 以降: 手動実行は不要です。**
>
> `install.sh full ~` を実行済みであれば、プロジェクトに `cd` するだけで
> Copilot CLI がこのプロジェクトのメモリを自動的に読み込みます。

## 仕組み

`~/.github/claude-projects` が `~/.claude/projects/` へのグローバルシンボリックリンクになっており、
`~/.zshrc` の `_update_copilot_dirs` precmd hook が `cd` のたびに以下を実行しています:

1. 現在の `$PWD` からプロジェクトハッシュを計算
2. `~/.github/claude-projects/<hash>/memory/` が存在するか確認
3. 存在する場合、`COPILOT_CUSTOM_INSTRUCTIONS_DIRS` に自動追加

## 現在の同期状態を確認する

```bash
# COPILOT_CUSTOM_INSTRUCTIONS_DIRS の現在値を確認
echo $COPILOT_CUSTOM_INSTRUCTIONS_DIRS

# このプロジェクトのメモリが含まれているか確認
HASH=$(echo "$PWD" | sed 's|/|-|g; s|\.|-|g')
ls "$HOME/.github/claude-projects/${HASH}/memory/" 2>/dev/null && echo "✓ メモリ同期済み" || echo "✗ このプロジェクトにはまだ Claude メモリがありません"
```

## セットアップが必要な場合

```bash
# install.sh を再実行してシンボリックリンクを設定する
./install.sh full ~

# zshrc を再読み込み
source ~/.zshrc
```
