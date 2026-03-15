---
name: generate-changelog
description: git log / PR 履歴から Conventional Commits ベースの CHANGELOG を生成
argument-hint: "<from-ref>..<to-ref>"
user-invokable: true
allowed-tools: ["Read", "Write", "Edit", "Glob", "Bash(git log *)", "Bash(git tag *)", "Bash(git describe *)", "Bash(gh pr list *)"]
---

# generate-changelog

`$ARGUMENTS` の範囲で CHANGELOG を生成してください。引数がない場合は最新タグ〜HEAD を対象とします。

## 手順

1. `git describe --tags --abbrev=0` で最新タグを取得
2. `git log ${TAG}..HEAD --oneline --no-merges` でコミット一覧を取得
3. Conventional Commits のプレフィックスで分類（feat / fix / docs / chore 等）
4. Keep a Changelog 形式で CHANGELOG.md に書き出し

## 注意事項

- マージコミットは除外する
- Breaking Changes は最上部に配置する
- PR 番号がある場合はリンクを付与する
