---
name: generate-changelog
description: git log / PR 履歴から Conventional Commits ベースの CHANGELOG を生成
argument-hint: "<from-ref>..<to-ref>"
user-invokable: true
allowed-tools: ["Read", "Write", "Edit", "Glob", "Bash(git log *)", "Bash(git tag *)", "Bash(git describe *)", "Bash(gh pr list *)", "Bash(gh release *)"]
---

# generate-changelog

`$ARGUMENTS` の範囲で CHANGELOG を生成してください。引数がない場合は最新タグ〜HEAD を対象とします。

## 手順

1. 対象範囲の特定
2. コミットの分類
3. CHANGELOG の生成
4. ファイルへの書き出し

## 対象範囲の特定

```bash
# 最新タグを取得
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# 引数がなければ最新タグ〜HEAD
if [ -z "$LATEST_TAG" ]; then
  RANGE="HEAD"
else
  RANGE="${LATEST_TAG}..HEAD"
fi

# コミット一覧
git log ${RANGE} --oneline --no-merges
```

## 分類ルール（Conventional Commits）

| プレフィックス | カテゴリ |
|---------------|---------|
| `feat:` | Features |
| `fix:` | Bug Fixes |
| `docs:` | Documentation |
| `perf:` | Performance |
| `refactor:` | Refactoring |
| `test:` | Tests |
| `chore:` `ci:` `build:` | Maintenance |
| `BREAKING CHANGE:` / `!:` | Breaking Changes |

## 出力形式（Keep a Changelog）

```markdown
## [Unreleased] - YYYY-MM-DD

### Breaking Changes
- ...

### Features
- feat: 説明 (#PR番号)

### Bug Fixes
- fix: 説明 (#PR番号)

### Documentation
- docs: 説明

### Maintenance
- chore: 説明
```

## 注意事項

- PR 番号がある場合はリンクを付与する
- Breaking Changes は最上部に配置する
- マージコミットは除外する（`--no-merges`）
