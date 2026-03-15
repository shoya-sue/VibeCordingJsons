---
name: create-issue
description: 発見した問題・改善案を GitHub Issue として起票する
argument-hint: "<title>"
user-invokable: true
allowed-tools: ["Bash(gh issue *)", "Bash(git log *)", "Bash(git blame *)", "Read", "Glob", "Grep"]
---

# create-issue

`$ARGUMENTS` の内容で GitHub Issue を作成してください。

## 手順

1. 問題の詳細を整理する（ファイル位置、再現手順、影響範囲）
2. 適切なラベルを選定する
3. Issue 本文を構成する
4. `gh issue create` で起票する（実行前にユーザーに確認）

## ラベル選定ガイド

| 状況 | ラベル |
|------|--------|
| 動作不良・クラッシュ | `bug` |
| 新機能・改善案 | `enhancement` |
| リファクタリング・負債解消 | `tech-debt` |
| 脆弱性・認証漏れ | `security` |

## Issue テンプレート

```markdown
## 概要
<!-- 1-2行で問題を説明 -->

## 詳細
- **ファイル**: `path/to/file.ts:L42`
- **影響範囲**: <!-- 影響するコンポーネント・機能 -->

## 再現手順（バグの場合）
1. ...
2. ...

## 期待する動作
<!-- あるべき姿 -->

## 優先度提案
<!-- High / Medium / Low と根拠 -->
```

## 注意事項

- Issue 作成前に必ずユーザーの確認を取ること
- 既存の Issue と重複していないか `gh issue list -s open` で確認する
- シークレットやセンシティブ情報を Issue 本文に含めない
