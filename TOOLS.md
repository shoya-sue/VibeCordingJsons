# Tool Categories Reference

ClaudeCodeで使用可能なツールのカテゴリ別リファレンスです。

## ファイル操作ツール

### 読み取り系
- `view` - ファイルとディレクトリの表示
- `grep` - ファイル内容の検索（ripgrep）
- `glob` - ファイル名パターンマッチング

### 編集系
- `edit` - ファイルの文字列置換
- `create` - 新規ファイル作成

## コマンド実行ツール

### 基本実行
- `bash` - Bashコマンド実行（同期/非同期）
- `list_bash` - アクティブなBashセッション一覧

### インタラクティブ実行
- `write_bash` - Bashセッションへ入力送信
- `read_bash` - Bashセッションから出力読み取り
- `stop_bash` - Bashセッション停止

## Web関連ツール

### 情報取得
- `web_fetch` - URLからコンテンツ取得
- `web_search` - AI搭載Web検索

### ブラウザ自動化（Playwright）
- `playwright-browser_navigate` - ページ遷移
- `playwright-browser_click` - クリック
- `playwright-browser_type` - テキスト入力
- `playwright-browser_fill_form` - フォーム入力
- `playwright-browser_snapshot` - アクセシビリティスナップショット
- `playwright-browser_take_screenshot` - スクリーンショット
- `playwright-browser_wait_for` - 要素待機
- `playwright-browser_hover` - ホバー
- `playwright-browser_select_option` - ドロップダウン選択
- `playwright-browser_evaluate` - JavaScript実行
- `playwright-browser_tabs` - タブ管理
- `playwright-browser_drag` - ドラッグ&ドロップ
- `playwright-browser_file_upload` - ファイルアップロード
- `playwright-browser_handle_dialog` - ダイアログ処理
- `playwright-browser_press_key` - キー入力

## GitHub MCP ツール

### リポジトリ操作
- `github-mcp-server-get_file_contents` - ファイル内容取得
- `github-mcp-server-list_commits` - コミット一覧
- `github-mcp-server-get_commit` - コミット詳細
- `github-mcp-server-list_branches` - ブランチ一覧
- `github-mcp-server-list_tags` - タグ一覧
- `github-mcp-server-get_tag` - タグ詳細

### Pull Request
- `github-mcp-server-list_pull_requests` - PR一覧
- `github-mcp-server-pull_request_read` - PR詳細
- `github-mcp-server-search_pull_requests` - PR検索

### Issue
- `github-mcp-server-list_issues` - Issue一覧
- `github-mcp-server-issue_read` - Issue詳細
- `github-mcp-server-search_issues` - Issue検索

### 検索
- `github-mcp-server-search_code` - コード検索
- `github-mcp-server-search_repositories` - リポジトリ検索
- `github-mcp-server-search_users` - ユーザー検索

### Release
- `github-mcp-server-list_releases` - リリース一覧
- `github-mcp-server-get_latest_release` - 最新リリース
- `github-mcp-server-get_release_by_tag` - タグ指定リリース

### GitHub Actions
- `github-mcp-server-actions_list` - ワークフロー一覧
- `github-mcp-server-actions_get` - ワークフロー詳細
- `github-mcp-server-get_job_logs` - ジョブログ取得
- `github-mcp-server-get_workflow_run_usage` - ワークフロー使用状況
- `github-mcp-server-get_workflow_run_logs_url` - ログURL取得

### セキュリティ
- `github-mcp-server-list_code_scanning_alerts` - コードスキャンアラート一覧
- `github-mcp-server-get_code_scanning_alert` - コードスキャンアラート詳細
- `github-mcp-server-list_secret_scanning_alerts` - シークレットスキャンアラート一覧
- `github-mcp-server-get_secret_scanning_alert` - シークレットスキャンアラート詳細
- `github-mcp-server-get_label` - ラベル取得
- `github-mcp-server-list_issue_types` - Issue タイプ一覧

## プロジェクト管理ツール

### 進捗管理
- `report_progress` - 進捗レポートとコミット/プッシュ

### コードレビュー
- `code_review` - 自動コードレビュー要求
- `codeql_checker` - CodeQLセキュリティスキャン
- `gh-advisory-database` - GitHub依存関係脆弱性チェック

## エージェント管理ツール

### サブエージェント
- `task` - 専門エージェントの起動
  - `explore` - 探索特化エージェント
  - `task` - コマンド実行エージェント
  - `general-purpose` - 汎用エージェント

## ツールの危険度レベル

### 🟢 安全（読み取り専用）
- `view`, `grep`, `glob`
- `list_bash`
- `web_fetch`（信頼できるドメインのみ）
- GitHub MCP読み取り系

### 🟡 注意（制限付き変更）
- `edit`, `create`（ファイルサイズ制限）
- `bash`（許可コマンドのみ）
- `web_search`
- `task`（エージェント制限）

### 🟠 警告（高権限）
- `bash`（全コマンド）
- `write_bash`, `read_bash`, `stop_bash`
- `playwright-browser_evaluate`
- GitHub Actions操作

### 🔴 危険（システム変更）
- `bash`（破壊的コマンド: rm -rf, sudo等）
- `playwright-browser_file_upload`
- 任意のJavaScript実行

## セキュリティレベル別推奨ツールセット

### Basic（最小権限）
```json
["view", "grep", "glob", "list_bash"]
```

### Standard（推奨）
```json
[
  "view", "grep", "glob", "edit", "create",
  "bash", "web_fetch", "web_search",
  "report_progress", "code_review", "codeql_checker",
  "github-mcp-server-get_file_contents",
  "github-mcp-server-search_code",
  "github-mcp-server-list_pull_requests"
]
```

### Advanced（全権限）
```json
[
  // 基本的に全てのツールを許可
  // disallowedTools で明示的に危険なもののみ拒否
]
```

## ツール選択のガイドライン

1. **最小権限から開始**: 必要なツールのみ許可
2. **段階的に追加**: 必要に応じて権限を拡大
3. **明示的な拒否**: 危険なツールは明示的に拒否
4. **制限の設定**: toolRestrictionsで詳細制御
5. **定期的な見直し**: 使用していない権限は削除

## 関連ドキュメント

- 設定例: `EXAMPLES.md`
- 全設定一覧: `INDEX.md`
- クイックスタート: `QUICKSTART.md`