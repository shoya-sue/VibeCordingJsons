---
name: generate-changelog
description: git log / PR 履歴から Conventional Commits ベースの CHANGELOG を生成する。タグ範囲を指定して使用。
user-invokable: true
---

# Generate Changelog — CHANGELOG 生成スキル

Conventional Commits に基づいてコミット履歴を分類し、CHANGELOG を生成するスキルです。

## いつ使うか

- 「v1.2.0 以降の CHANGELOG を作って」
- 「リリースノートを生成して」
- 「今回のリリースに含まれる変更を一覧にして」

## 作業手順

### Step 1: 対象範囲の特定

```bash
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
git log ${LATEST_TAG}..HEAD --oneline --no-merges
```

### Step 2: コミット分類

| プレフィックス | カテゴリ |
|---------------|---------|
| `feat:` | Features |
| `fix:` | Bug Fixes |
| `docs:` | Documentation |
| `perf:` | Performance |
| `BREAKING CHANGE:` | Breaking Changes |
| その他 | Maintenance |

### Step 3: CHANGELOG 生成

Keep a Changelog 形式で出力。PR 番号がある場合はリンクを付与。

## 注意事項

- マージコミットは除外する（`--no-merges`）
- Breaking Changes は最上部に配置する
