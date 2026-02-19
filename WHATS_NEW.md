# 新機能：高度なカスタマイズオプション

## 概要

このプルリクエストでは、ClaudeCodeの`.claude/settings.json`において、**コマンド許可リスト以外にカスタマイズ可能な設定オプション**の最新情報を追加しました。

## ⚠️ 重要：既存設定との互換性

**新しいオプションは既存の設定と完全に互換性があります！**

- ✅ **既存の設定ファイルに追加可能**: `allowedTools`、`disallowedTools`、`toolRestrictions`と一緒に使えます
- ✅ **段階的な導入が可能**: 必要なオプションだけを既存設定に追加できます
- ✅ **マージして使用可能**: `jq`コマンドで既存設定と新しいオプションを組み合わせられます

### 既存設定との組み合わせ例

```bash
# 既存のstandard設定に新しいオプションを追加
jq -s '.[0] * .[1]' \
  configs/standard/settings.json \
  configs/examples/hooks-focused.json \
  > .claude/settings.json
```

実例は `configs/examples/combined-standard-advanced.json` を参照してください。

## 追加された主要な設定オプション

### 1. 権限管理（Permissions）
ファイルアクセスとコマンド実行を細かく制御できます。

```json
{
  "permissions": {
    "allow": ["Read(./src/**)", "Bash(npm run *)"],
    "deny": ["Read(**/.env*)", "Bash(rm -rf *)"],
    "ask": ["Write(./package.json)"],
    "defaultMode": "ask"
  }
}
```

**特徴**:
- `allow`: 許可するアクション
- `deny`: 拒否するアクション（優先度高）
- `ask`: 確認が必要なアクション
- `defaultMode`: 未定義アクションのデフォルト動作

### 2. 環境変数（Environment Variables）
すべてのツール実行時に使用される環境変数を設定できます。

```json
{
  "env": {
    "NODE_ENV": "development",
    "DEBUG": "app:*"
  }
}
```

### 3. モデル設定（LLM Configuration）
使用するClaudeモデルと動作をカスタマイズできます。

```json
{
  "llm": {
    "model": "claude-sonnet-4-20250514",
    "temperature": 0.3,
    "maxTokens": 4096
  }
}
```

**利用可能なモデル**:
- `claude-sonnet-4-20250514`: バランス型（推奨）
- `claude-3-opus-20260101`: 高品質・低速
- `claude-3-5-haiku-20250120`: 高速・低コスト

### 4. 実行設定（Execution）
コマンド実行のタイムアウトと並列数を制御できます。

```json
{
  "execution": {
    "timeout": 300,
    "maxConcurrent": 5
  }
}
```

### 5. リソース制限（Limits）
グローバルなリソース制限を設定できます。

```json
{
  "limits": {
    "maxFileSize": 5242880,
    "maxResults": 100,
    "maxMemory": 2048
  }
}
```

### 6. フック（Hooks）
セッションライフサイクルのイベントにコマンドを紐付けられます。

```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "git status --short",
        "matcher": "startup"
      }
    ]
  }
}
```

**利用可能なフック**:
- `SessionStart`: セッション開始時
- `SessionEnd`: セッション終了時
- `BeforeEdit`: ファイル編集前
- `AfterEdit`: ファイル編集後

### 7. カスタムエージェント（Custom Agents）
専門タスク用のエージェントを定義できます。

```json
{
  "agents": [
    {
      "name": "test-runner",
      "path": "./agents/test-runner.json",
      "model": "claude-3-5-haiku-20250120",
      "permissions": {
        "allow": ["Bash(npm test)"]
      }
    }
  ]
}
```

### 8. その他の設定
- `plugins`: 有効にするプラグインの指定
- `theme`: UIテーマ（light/dark/auto）
- `verbose`: 詳細な出力の有効化

## 新規追加ファイル

### ドキュメント
- `ADVANCED_CUSTOMIZATION.md`: 詳細な高度カスタマイズガイド（日本語）
  - 各オプションの詳細説明
  - 実用例
  - ベストプラクティス
  - トラブルシューティング

### サンプル設定ファイル（configs/examples/）
1. `advanced-options.json`: 全オプションを網羅したサンプル
2. `permissions-focused.json`: 権限管理に特化した例
3. `hooks-focused.json`: フック機能を活用した自動化例
4. `agents-focused.json`: カスタムエージェントの使用例

## 使い方

### 高度なカスタマイズを学ぶ
```bash
# 詳細ガイドを読む
cat ADVANCED_CUSTOMIZATION.md
```

### サンプル設定を試す
```bash
# 全オプション網羅版をコピー
cp configs/examples/advanced-options.json .claude/settings.json

# 権限管理に特化した設定をコピー
cp configs/examples/permissions-focused.json .claude/settings.json

# フック機能を活用した設定をコピー
cp configs/examples/hooks-focused.json .claude/settings.json

# カスタムエージェント設定をコピー
cp configs/examples/agents-focused.json .claude/settings.json
```

### 既存設定に追加
既存の設定ファイルに新しいオプションを追加する場合：

```bash
# jqコマンドでマージ
jq -s '.[0] * .[1]' \
  .claude/settings.json \
  configs/examples/permissions-focused.json \
  > .claude/settings.new.json

# 確認後、置き換え
mv .claude/settings.new.json .claude/settings.json
```

## 設定の階層（優先順位）

ClaudeCodeは以下の順序で設定を適用します（上が優先）：

1. **Managed（管理）**: 組織のIT部門が管理
2. **CLI引数**: コマンドライン引数
3. **Local**: `.claude/settings.local.json`（個人設定、gitignore推奨）
4. **Project**: `.claude/settings.json`（チーム共有、Gitで管理）
5. **User**: `~/.claude/settings.json`（全プロジェクト共通）

## スキーマ検証

設定ファイルの先頭に`$schema`を追加すると、エディタで自動補完と検証が有効になります：

```json
{
  "$schema": "https://raw.githubusercontent.com/shoya-sue/ClaudeCodeJsons/main/schema.json",
  ...
}
```

## ベストプラクティス

### セキュリティ
- ✅ 最小権限の原則：必要最低限の権限のみ付与
- ✅ 明示的な拒否：危険な操作は明示的に拒否
- ❌ 秘密情報を直接記述しない：環境変数参照を使用

### バージョン管理
- ✅ Gitにコミット：`.claude/settings.json`
- ❌ Gitignoreに追加：`.claude/settings.local.json`

### パフォーマンス
- 探索・調査：`claude-3-5-haiku-20250120`（高速）
- コード生成：`claude-sonnet-4-20250514`（高品質）

## トラブルシューティング

### 設定が反映されない
1. ClaudeCodeを再起動
2. JSON構文エラーがないか確認：`python3 -m json.tool .claude/settings.json`
3. ファイルパスを確認（プロジェクトルートに`.claude/settings.json`があるか）

### 権限エラーが出る
1. `permissions.allow`に必要なアクションを追加
2. `permissions.deny`で誤って拒否していないか確認
3. `defaultMode`を`"ask"`に設定して対話的に確認

## 参考リンク

- 詳細ガイド: [ADVANCED_CUSTOMIZATION.md](ADVANCED_CUSTOMIZATION.md)
- リファレンス: [REFERENCE.md](REFERENCE.md)
- JSONスキーマ: [schema.json](schema.json)

---

**更新日**: 2026-02-13
