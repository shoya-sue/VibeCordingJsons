---
name: create-issue
description: 発見した問題・改善案を GitHub Issue として起票する。Issue URL または番号を指定して使用。
user-invokable: true
---

# Create Issue — GitHub Issue 起票スキル

コードレビューやデバッグ中に発見した問題を GitHub Issue として記録するスキルです。

## いつ使うか

- 「この問題を Issue にしておいて」
- 「N+1 クエリの改善を Issue で管理したい」
- 「セキュリティ問題を起票して」

## 作業手順

### Step 1: 既存 Issue との重複確認

```bash
gh issue list -s open --search "[キーワード]"
```

### Step 2: 問題の詳細整理

- ファイル位置（`git blame` で特定）
- 影響範囲
- 再現手順（バグの場合）

### Step 3: ラベル選定

| 状況 | ラベル |
|------|--------|
| 動作不良 | `bug` |
| 新機能・改善 | `enhancement` |
| 負債解消 | `tech-debt` |
| 脆弱性 | `security` |

### Step 4: Issue 作成

```bash
gh issue create \
  --title "[プレフィックス]: タイトル" \
  --label "ラベル" \
  --body "Issue 本文"
```

## 注意事項

- Issue 作成前に必ずユーザーの確認を取ること
- シークレットやセンシティブ情報を Issue 本文に含めない
