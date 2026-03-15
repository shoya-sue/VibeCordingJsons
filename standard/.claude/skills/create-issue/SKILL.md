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
2. 適切なラベルを選定する（`bug` / `enhancement` / `tech-debt` / `security`）
3. 既存 Issue と重複していないか `gh issue list -s open` で確認
4. Issue 本文を構成する
5. `gh issue create` で起票する（実行前にユーザーに確認）

## 注意事項

- Issue 作成前に必ずユーザーの確認を取ること
- シークレットやセンシティブ情報を Issue 本文に含めない
