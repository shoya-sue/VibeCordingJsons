# ClaudeCode Settings Examples

このドキュメントでは、様々なシナリオに応じた設定例を紹介します。

## シナリオ1: Webアプリケーション開発

```json
{
  "description": "Web Application Development - React + Node.js",
  "allowedTools": [
    "view", "grep", "glob", "edit", "create",
    "bash", "web_fetch", "web_search",
    "report_progress", "code_review", "codeql_checker", "gh-advisory-database",
    "github-mcp-server-get_file_contents",
    "github-mcp-server-search_code",
    "github-mcp-server-list_pull_requests",
    "github-mcp-server-pull_request_read"
  ],
  "disallowedTools": [
    "write_bash", "read_bash", "stop_bash"
  ],
  "toolRestrictions": {
    "bash": {
      "allowedCommands": [
        "npm install", "npm ci", "npm run dev", "npm run build", "npm test",
        "npx", "git status", "git diff", "git log"
      ]
    }
  }
}
```

## シナリオ2: Python データサイエンスプロジェクト

```json
{
  "description": "Data Science Project - Python + Jupyter",
  "allowedTools": [
    "view", "grep", "glob", "edit", "create",
    "bash", "web_fetch", "web_search",
    "report_progress", "code_review", "gh-advisory-database"
  ],
  "toolRestrictions": {
    "bash": {
      "allowedCommands": [
        "pip install", "pip install -r requirements.txt",
        "python -m", "pytest", "jupyter", "python"
      ]
    },
    "edit": {
      "maxFileSize": 5000000
    }
  }
}
```

## シナリオ3: CI/CD監視・デバッグ

```json
{
  "description": "CI/CD Monitoring and Debugging",
  "allowedTools": [
    "view", "grep", "glob",
    "github-mcp-server-actions_list",
    "github-mcp-server-actions_get",
    "github-mcp-server-get_job_logs",
    "github-mcp-server-list_workflows",
    "github-mcp-server-get_workflow_run"
  ],
  "disallowedTools": [
    "edit", "create", "bash"
  ]
}
```

## シナリオ4: セキュリティ監査

```json
{
  "description": "Security Audit Configuration",
  "allowedTools": [
    "view", "grep", "glob",
    "codeql_checker", "gh-advisory-database",
    "github-mcp-server-list_code_scanning_alerts",
    "github-mcp-server-get_code_scanning_alert",
    "github-mcp-server-list_secret_scanning_alerts",
    "github-mcp-server-get_secret_scanning_alert"
  ],
  "disallowedTools": [
    "edit", "create", "bash", "write_bash", "read_bash"
  ]
}
```

## シナリオ5: UIテスト自動化

```json
{
  "description": "UI Test Automation with Playwright",
  "allowedTools": [
    "view", "grep", "edit", "create",
    "bash",
    "playwright-browser_navigate",
    "playwright-browser_click",
    "playwright-browser_type",
    "playwright-browser_fill_form",
    "playwright-browser_snapshot",
    "playwright-browser_take_screenshot",
    "playwright-browser_wait_for",
    "report_progress"
  ],
  "toolRestrictions": {
    "browser": {
      "allowedDomains": ["localhost", "127.0.0.1", "*.example.com"],
      "maxTabs": 5
    }
  }
}
```

## シナリオ6: マルチエージェント開発チーム

```json
{
  "description": "Multi-Agent Development Team",
  "allowedTools": [
    "task", "view", "grep", "glob", "edit", "create",
    "bash", "report_progress", "code_review", "codeql_checker"
  ],
  "toolRestrictions": {
    "task": {
      "allowedAgentTypes": ["explore", "task", "general-purpose"],
      "maxConcurrent": 5
    }
  }
}
```

## 設定の組み合わせ方法

### 方法1: ファイルマージ（手動）

```bash
# ベース設定をコピー
cp configs/standard/settings.json .claude/settings.json

# MCP設定を手動で追加
# エディタで .claude/settings.json を開き、
# configs/mcp/github-readonly.json の allowedTools を追加
```

### 方法2: jqコマンドでマージ

```bash
# jqを使用して複数の設定をマージ
jq -s '.[0] * .[1]' \
  configs/standard/settings.json \
  configs/mcp/github-readonly.json \
  > .claude/settings.json
```

### 方法3: プログラムで統合

```python
import json

# 複数の設定を読み込み
with open('configs/standard/settings.json') as f:
    base = json.load(f)
with open('configs/mcp/github-readonly.json') as f:
    mcp = json.load(f)

# allowedToolsをマージ
combined_tools = list(set(base['allowedTools'] + mcp['allowedTools']))
base['allowedTools'] = sorted(combined_tools)

# 保存
with open('.claude/settings.json', 'w') as f:
    json.dump(base, f, indent=2, ensure_ascii=False)
```

## ベストプラクティス

1. **段階的な権限追加**: 最初はStandard設定から始め、必要に応じて権限を追加
2. **環境別設定**: 開発環境、本番環境で異なる設定を使用
3. **バージョン管理**: `.claude/settings.json`をGitで管理し、チームで共有
4. **定期的な見直し**: プロジェクトの成熟に応じて設定を見直す
5. **ドキュメント化**: なぜその権限が必要かをREADMEに記載

## トラブルシューティング

### Q: 設定が反映されない
A: Claude Codeを再起動し、`.claude/settings.json`がプロジェクトルートに配置されているか確認

### Q: 特定のツールだけ許可したい
A: `allowedTools`に必要なツールのみをリストアップ

### Q: MCP設定が動作しない
A: MCP サーバーが起動しているか、認証情報が正しく設定されているか確認