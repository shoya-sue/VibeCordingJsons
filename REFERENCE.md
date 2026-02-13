# ClaudeCode Settings JSONs - リファレンス

このドキュメントは、設定ファイルの詳細な技術情報、使用例、貢献ガイドをまとめたリファレンスです。

## 目次

1. [設定ファイル詳細](#設定ファイル詳細)
2. [使用例・シナリオ](#使用例シナリオ)
3. [ツールリファレンス](#ツールリファレンス)
4. [貢献ガイド](#貢献ガイド)

---

## 設定ファイル詳細

### セキュリティレベル別設定

#### Basic（基本設定）
- **ファイル**: `configs/basic/settings.json`
- **セキュリティレベル**: 最高
- **用途**: 未信頼コードのレビュー、高セキュリティ環境
- **許可ツール**: `view`, `grep`, `glob`, `list_bash`
- **主な制限**: 読み取り専用、ファイル変更不可、コマンド実行不可
- **推奨環境**: セキュリティ最優先のプロジェクト

#### Standard（標準設定）
- **ファイル**: `configs/standard/settings.json`
- **セキュリティレベル**: 中
- **用途**: 通常の開発プロジェクト（推奨）
- **許可ツール**: ファイル操作、Git、npm/pip等のビルドツール、GitHub MCP（読み取り）
- **主な制限**: 破壊的コマンド（rm -rf、sudo等）は拒否
- **推奨環境**: ほとんどの開発プロジェクト

#### Advanced（上級設定）
- **ファイル**: `configs/advanced/settings.json`
- **セキュリティレベル**: 低
- **用途**: 完全に信頼できる環境
- **許可ツール**: ほぼ全ての操作が可能
- **主な制限**: システム破壊的なコマンドのみ拒否
- **推奨環境**: 経験豊富な開発者、完全信頼環境

### MCP統合設定

#### GitHub Readonly
- **ファイル**: `configs/mcp/github-readonly.json`
- **機能**: GitHub API読み取り専用アクセス
- **ツール**: リポジトリ探索、コード検索、PR/Issue閲覧
- **必要な権限**: GitHub token (read)

#### GitHub Actions
- **ファイル**: `configs/mcp/github-actions.json`
- **機能**: CI/CDワークフロー監視
- **ツール**: ワークフロー実行状況、ジョブログ取得
- **必要な権限**: GitHub token (actions:read)

#### GitHub Security
- **ファイル**: `configs/mcp/github-security.json`
- **機能**: セキュリティスキャン結果の閲覧
- **ツール**: Code Scanning、Secret Scanningアラート
- **必要な権限**: GitHub token (security_events:read)

#### Browser Automation
- **ファイル**: `configs/mcp/browser-automation.json`
- **機能**: Playwright経由のブラウザ操作
- **ツール**: UI テスト、Webスクレイピング
- **制限**: JavaScript実行制限、ファイルアップロード制限

### Skills設定

#### Skill Development
- **ファイル**: `configs/skills/skill-development.json`
- **用途**: Claude Code Skillsの開発
- **機能**: スキル構造の強制、コードレビュー必須
- **制限**: 開発操作のみ、実行は別設定で

#### Skill Execution
- **ファイル**: `configs/skills/skill-execution.json`
- **用途**: 承認済みSkillsの実行
- **機能**: 分離実行環境、リソース制限
- **制限**: ファイル変更不可、読み取りと実行のみ

### Agent/Team設定

#### Team Coordination
- **ファイル**: `configs/agent-team/team-coordination.json`
- **用途**: マルチエージェント協調開発
- **機能**: 並列実行、タスク委譲、進捗レポート
- **特徴**: 最大10エージェント、3つの専門ロール

#### Explorer Agent
- **ファイル**: `configs/agent-team/explorer-agent.json`
- **ロール**: コードベース探索
- **モデル**: Claude 3.5 Haiku（高速）
- **機能**: 読み取り専用、高速検索・分析
- **制限**: ファイル変更不可、コマンド実行不可

#### Builder Agent
- **ファイル**: `configs/agent-team/builder-agent.json`
- **ロール**: ビルド・テスト実行
- **モデル**: Claude 3.5 Haiku（高速）
- **機能**: コマンド実行、主要エコシステム対応
- **制限**: ファイル編集不可、コマンド実行のみ

#### Coder Agent
- **ファイル**: `configs/agent-team/coder-agent.json`
- **ロール**: コード開発・修正
- **モデル**: Claude 3.5 Sonnet（高品質）
- **機能**: フルファイル編集、セキュリティスキャン統合
- **制限**: インタラクティブBash無効

---

## 使用例・シナリオ

### シナリオ1: Webアプリケーション開発

**状況**: React + Node.jsプロジェクト

**推奨設定**:
```bash
cp configs/standard/settings.json .claude/settings.json
```

**カスタマイズ例**:
```json
{
  "allowedTools": [
    "view", "grep", "glob", "edit", "create",
    "bash", "web_fetch", "web_search",
    "report_progress", "code_review", "codeql_checker"
  ],
  "toolRestrictions": {
    "bash": {
      "allowedCommands": [
        "npm install", "npm run dev", "npm test",
        "git status", "git diff"
      ]
    }
  }
}
```

### シナリオ2: Python データサイエンス

**状況**: Jupyter Notebook + pandas/numpy

**推奨設定**:
```bash
cp configs/standard/settings.json .claude/settings.json
```

**追加設定**:
```json
{
  "toolRestrictions": {
    "bash": {
      "allowedCommands": [
        "pip install", "python -m", "pytest", "jupyter"
      ]
    },
    "edit": {
      "maxFileSize": 5000000
    }
  }
}
```

### シナリオ3: CI/CD監視・デバッグ

**状況**: GitHub Actionsのデバッグ

**推奨設定**:
```bash
# 基本設定 + Actions設定をマージ
jq -s '.[0] * .[1]' \
  configs/basic/settings.json \
  configs/mcp/github-actions.json \
  > .claude/settings.json
```

### シナリオ4: セキュリティ監査

**状況**: コードの脆弱性チェック

**推奨設定**:
```bash
cp configs/basic/settings.json .claude/settings.json
# github-security.jsonの内容を手動でマージ
```

**必須ツール**:
- `codeql_checker`
- `gh-advisory-database`
- `github-mcp-server-list_code_scanning_alerts`

### シナリオ5: UIテスト自動化

**状況**: Playwrightでのブラウザテスト

**推奨設定**:
```bash
# 標準設定 + ブラウザ自動化
jq -s '.[0] * .[1]' \
  configs/standard/settings.json \
  configs/mcp/browser-automation.json \
  > .claude/settings.json
```

### シナリオ6: マルチエージェント開発

**状況**: 大規模プロジェクトでの協調開発

**推奨設定**:
```bash
cp configs/agent-team/team-coordination.json .claude/settings.json
```

または個別エージェント:
```bash
# 探索専用
cp configs/agent-team/explorer-agent.json .claude/settings.json

# ビルド専用
cp configs/agent-team/builder-agent.json .claude/settings.json

# コーディング専用
cp configs/agent-team/coder-agent.json .claude/settings.json
```

---

## ツールリファレンス

### ファイル操作ツール

#### 読み取り系
- **view** - ファイルとディレクトリの表示
- **grep** - ファイル内容の検索（ripgrep）
- **glob** - ファイル名パターンマッチング

#### 編集系
- **edit** - ファイルの文字列置換
- **create** - 新規ファイル作成

### コマンド実行ツール

#### 基本実行
- **bash** - Bashコマンド実行（同期/非同期）
- **list_bash** - アクティブなBashセッション一覧

#### インタラクティブ実行
- **write_bash** - Bashセッションへ入力送信
- **read_bash** - Bashセッションから出力読み取り
- **stop_bash** - Bashセッション停止

### Web関連ツール

#### 情報取得
- **web_fetch** - URLからコンテンツ取得
- **web_search** - AI搭載Web検索

#### ブラウザ自動化（Playwright）
主要ツール:
- `playwright-browser_navigate` - ページ遷移
- `playwright-browser_click` - クリック
- `playwright-browser_type` - テキスト入力
- `playwright-browser_fill_form` - フォーム入力
- `playwright-browser_snapshot` - スナップショット
- `playwright-browser_take_screenshot` - スクリーンショット

### GitHub MCP ツール

#### リポジトリ操作
- `github-mcp-server-get_file_contents` - ファイル内容取得
- `github-mcp-server-list_commits` - コミット一覧
- `github-mcp-server-search_code` - コード検索

#### Pull Request/Issue
- `github-mcp-server-list_pull_requests` - PR一覧
- `github-mcp-server-pull_request_read` - PR詳細
- `github-mcp-server-list_issues` - Issue一覧
- `github-mcp-server-issue_read` - Issue詳細

#### GitHub Actions
- `github-mcp-server-actions_list` - ワークフロー一覧
- `github-mcp-server-actions_get` - ワークフロー詳細
- `github-mcp-server-get_job_logs` - ジョブログ取得

#### セキュリティ
- `github-mcp-server-list_code_scanning_alerts` - コードスキャンアラート
- `github-mcp-server-list_secret_scanning_alerts` - シークレットスキャンアラート

### プロジェクト管理ツール

- **report_progress** - 進捗レポートとコミット/プッシュ
- **code_review** - 自動コードレビュー要求
- **codeql_checker** - CodeQLセキュリティスキャン
- **gh-advisory-database** - 依存関係脆弱性チェック

### エージェント管理ツール

- **task** - 専門エージェントの起動
  - `explore` - 探索特化エージェント
  - `task` - コマンド実行エージェント
  - `general-purpose` - 汎用エージェント

### ツールの危険度レベル

| レベル | ツール例 | 説明 |
|--------|---------|------|
| 🟢 安全 | view, grep, glob | 読み取り専用 |
| 🟡 注意 | edit, create, bash（制限付き） | 制限付き変更 |
| 🟠 警告 | bash（全コマンド）, write_bash | 高権限 |
| 🔴 危険 | rm -rf, sudo等の破壊的コマンド | システム変更 |

---

## 貢献ガイド

### 新しい設定パターンの追加

新しいユースケースに対応する設定を追加する場合：

1. **適切なディレクトリを選択または新規作成**
   - `configs/basic/`, `configs/standard/`, `configs/advanced/` - セキュリティレベル別
   - `configs/mcp/` - MCP統合設定
   - `configs/skills/` - Skills関連
   - `configs/agent-team/` - Agent/Team設定

2. **JSON設定ファイルを作成**
   - 必須フィールド: `description`, `allowedTools`
   - 推奨フィールド: `disallowedTools`, `toolRestrictions`, `notes`
   - schema.jsonに準拠すること

3. **設定ファイルの例**:
```json
{
  "description": "明確な説明",
  "allowedTools": ["tool1", "tool2"],
  "disallowedTools": ["tool3"],
  "toolRestrictions": {
    "tool1": {
      "maxFileSize": 1000000
    }
  },
  "notes": [
    "この設定の目的",
    "使用上の注意点"
  ]
}
```

### JSONフォーマット規約

- インデント: 2スペース
- UTF-8エンコーディング
- 末尾にカンマなし
- プロパティ名は英語（descriptionとnotesの値は日本語可）

### セキュリティガイドライン

1. **最小権限の原則**: デフォルトで必要最小限の権限のみ付与
2. **明示的な拒否**: 危険なツールは明示的に拒否
3. **制限の文書化**: toolRestrictionsで詳細な制限を設定
4. **コメント追加**: notesフィールドでセキュリティ考慮事項を説明

### プルリクエストガイドライン

PRを作成する前に：

- [ ] JSON構文が正しいことを確認（`jq`や`jsonlint`でチェック）
- [ ] schema.jsonに準拠していることを確認
- [ ] 既存の設定と重複していないか確認
- [ ] ドキュメント（README.md）を更新

PRの説明に含めること：

- 変更内容（何を追加/変更したか）
- 目的（なぜこの変更が必要か）
- 使用例（どのように使うか）
- セキュリティへの影響
- テスト結果

### 設定の分類基準

- **Basic**: 読み取り専用、ファイル変更不可、コマンド実行不可
- **Standard**: 一般的な開発に必要な権限、制限付きファイル編集
- **Advanced**: ほぼ全ての権限、信頼できる環境のみ

### JSONスキーマ

`schema.json`で定義されている構造：

```json
{
  "description": "string (必須)",
  "allowedTools": ["array of strings (必須)"],
  "disallowedTools": ["array of strings"],
  "toolRestrictions": {
    "toolName": {
      "allowedCommands": ["array"],
      "disallowedCommands": ["array"],
      "maxFileSize": "number",
      "executionTimeout": "number"
    }
  },
  "notes": ["array of strings"]
}
```

---

## 関連リソース

- [Claude Code公式ドキュメント](https://code.claude.com/docs) - Claude Codeの公式マニュアル
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) - MCPの仕様とドキュメント
- [Claude Code Skills Guide](https://gist.github.com/alirezarezvani/a0f6e0a984d4a4adc4842bbe124c5935) - Skillsの開発パターンと実践ガイド

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)を参照してください。
