---
name: sync-memory
description: Link this project's Claude memory to .github/claude-memory for Copilot CLI access
user-invokable: true
allowed-tools: ["Bash(ln *)", "Bash(ls *)", "Bash(mkdir *)", "Bash(grep *)", "Read"]
---

# sync-memory

このプロジェクトの Claude メモリを `.github/claude-memory` にシンボリックリンクし、
Copilot CLI からも同一メモリを参照できるようにする。

Claude Code が使えない状況（障害・セッション上限）でも、
`gh copilot suggest` や `gh copilot explain` がプロジェクトのコンテキストを引き継げる。

## 手順

1. 現在のプロジェクトパスを確認する

```bash
echo "$PWD"
```

2. Claude のプロジェクトハッシュを計算する（パスの `/` と `.` を `-` に変換）

```bash
echo "$PWD" | sed 's|/|-|g; s|\.|-|g'
```

3. メモリディレクトリの存在を確認する

```bash
HASH=$(echo "$PWD" | sed 's|/|-|g; s|\.|-|g')
ls "$HOME/.claude/projects/${HASH}/memory/" 2>/dev/null || echo "NOT FOUND"
```

メモリが見つからない場合は、プロジェクト名で検索する:

```bash
ls "$HOME/.claude/projects/" | grep "$(basename "$PWD")"
```

4. シンボリックリンクを作成する

```bash
HASH=$(echo "$PWD" | sed 's|/|-|g; s|\.|-|g')
MEMORY_DIR="$HOME/.claude/projects/${HASH}/memory"
mkdir -p "$PWD/.github"
ln -sf "$MEMORY_DIR" "$PWD/.github/claude-memory"
echo "Linked: $PWD/.github/claude-memory -> $MEMORY_DIR"
```

5. `.gitignore` に追記する（コミット対象外にする）

```bash
if [[ -f "$PWD/.gitignore" ]] && ! grep -qF '.github/claude-memory' "$PWD/.gitignore"; then
  echo '.github/claude-memory' >> "$PWD/.gitignore"
  echo "Added .github/claude-memory to .gitignore"
fi
```

6. リンクされたメモリファイルを表示して完了を確認する

```bash
ls -la "$PWD/.github/claude-memory/"
```

## 完了後の使い方

```bash
# Copilot CLI でプロジェクトコンテキストを参照
gh copilot suggest "このプロジェクトの最新リリースバージョンは？"
gh copilot explain "前回のセッションで発生したエラーは何でしたか？"
```

`COPILOT_CUSTOM_INSTRUCTIONS_DIRS` に `.github/claude-memory` が含まれていれば
（`install.sh full ~` 実行後の `~/.zshrc` 設定による自動設定）、
そのディレクトリ配下のメモリファイルが自動的に Copilot CLI に渡される。
