# ClaudeCode 設定の高度なカスタマイズオプション

このドキュメントでは、`.claude/settings.json`でコマンド許可リスト以外にカスタマイズ可能な設定オプションの最新情報を提供します。

## 目次

1. [設定ファイルの階層とスコープ](#設定ファイルの階層とスコープ)
2. [権限管理（Permissions）](#権限管理permissions)
3. [環境変数（Environment Variables）](#環境変数environment-variables)
4. [モデル設定（LLM Configuration）](#モデル設定llm-configuration)
5. [実行設定（Execution）](#実行設定execution)
6. [リソース制限（Limits）](#リソース制限limits)
7. [フック（Hooks）](#フックhooks)
8. [カスタムエージェント（Custom Agents）](#カスタムエージェントcustom-agents)
9. [プラグイン（Plugins）](#プラグインplugins)
10. [テーマとUI設定](#テーマとui設定)
11. [完全な設定例](#完全な設定例)

---

## 設定ファイルの階層とスコープ

ClaudeCodeは複数のスコープで設定を管理します。優先順位は以下の通り：

| スコープ | ファイルパス | 優先度 | 説明 |
|---------|------------|--------|------|
| **Managed（管理）** | システム依存 | 最高 | 組織のIT部門が管理する設定 |
| **CLI引数** | コマンドライン | 高 | セッション固有の一時的な設定 |
| **Local（ローカル）** | `.claude/settings.local.json` | 中高 | マシン固有の設定（gitignoreに追加） |
| **Project（プロジェクト）** | `.claude/settings.json` | 中 | チーム共有設定（Gitで管理） |
| **User（ユーザー）** | `~/.claude/settings.json` | 低 | 全プロジェクトで共通の個人設定 |

### 使い分けのポイント

- **Project設定**: チームで共有したい設定（許可ツール、プロジェクト固有の制限）
- **Local設定**: 個人環境固有の設定（APIキー、ローカルパス）
- **User設定**: すべてのプロジェクトで使う個人の好み（テーマ、モデル選択）

---

## 権限管理（Permissions）

`permissions`オブジェクトを使用して、ファイルアクセスやコマンド実行を細かく制御できます。

### 基本構造

```json
{
  "permissions": {
    "allow": [
      "Read(./src/**)",
      "Write(./src/**)",
      "Bash(npm run *)",
      "Bash(git status)",
      "Bash(git diff)"
    ],
    "deny": [
      "Read(**/.env*)",
      "Read(**/secrets/**)",
      "Write(**/node_modules/**)",
      "Bash(rm -rf *)",
      "Bash(sudo *)"
    ],
    "ask": [
      "Bash(npm install *)",
      "Write(./package.json)"
    ],
    "defaultMode": "ask"
  }
}
```

### パターンの書き方

- `Read(パス)`: ファイル読み取り権限
- `Write(パス)`: ファイル書き込み権限
- `Bash(コマンド)`: コマンド実行権限
- `*`: 任意の文字列（単一ディレクトリレベル）
- `**`: 任意のパス（複数ディレクトリレベル）

### defaultMode オプション

- `"acceptEdits"`: 許可されていないアクションを自動承認
- `"ask"`: ユーザーに確認を求める（推奨）
- `"reject"`: 許可されていないアクションを自動拒否

### 実用例

#### セキュアな開発環境
```json
{
  "permissions": {
    "allow": [
      "Read(./src/**)",
      "Read(./tests/**)",
      "Write(./src/**)",
      "Bash(npm test)",
      "Bash(npm run lint)"
    ],
    "deny": [
      "Read(**/.env*)",
      "Read(**/config/secrets.*)",
      "Bash(npm install)",
      "Bash(rm *)"
    ],
    "defaultMode": "ask"
  }
}
```

---

## 環境変数（Environment Variables）

`env`オブジェクトで、すべてのツール実行時に使用される環境変数を設定できます。

### 基本構造

```json
{
  "env": {
    "NODE_ENV": "development",
    "DEBUG": "app:*",
    "API_BASE_URL": "https://api.example.com",
    "LOG_LEVEL": "info"
  }
}
```

### 秘密情報の扱い

秘密情報は環境変数に直接記述せず、参照を使用します：

```json
{
  "env": {
    "API_KEY": "${secrets.API_KEY}",
    "DATABASE_URL": "${secrets.DATABASE_URL}"
  }
}
```

### 優先順位

1. シェルでエクスポートされた環境変数（最優先）
2. `settings.json`の`env`オブジェクト
3. システムデフォルト

---

## モデル設定（LLM Configuration）

`llm`オブジェクトで使用するClaudeモデルや動作を制御できます。

### 基本構造

```json
{
  "llm": {
    "model": "claude-sonnet-4-20250514",
    "temperature": 0.7,
    "maxTokens": 4096
  }
}
```

### 利用可能なモデル（2026年2月時点）

- `claude-sonnet-4-20250514`: 最新のSonnetモデル（バランス型）
- `claude-3-opus-20260101`: 高品質、低速
- `claude-3-5-haiku-20250120`: 高速、低コスト

### パラメータ

- **model**: 使用するClaudeモデル名
- **temperature**: 0.0（決定的）〜 1.0（創造的）
- **maxTokens**: レスポンスの最大トークン数

### 用途別推奨設定

#### コード生成（高精度）
```json
{
  "llm": {
    "model": "claude-sonnet-4-20250514",
    "temperature": 0.3,
    "maxTokens": 8192
  }
}
```

#### 探索・調査（高速）
```json
{
  "llm": {
    "model": "claude-3-5-haiku-20250120",
    "temperature": 0.5,
    "maxTokens": 2048
  }
}
```

---

## 実行設定（Execution）

`execution`オブジェクトでコマンド実行の動作を制御できます。

### 基本構造

```json
{
  "execution": {
    "timeout": 300,
    "maxConcurrent": 5
  }
}
```

### パラメータ

- **timeout**: コマンド実行のタイムアウト（秒）
- **maxConcurrent**: 同時実行可能な操作数

### 用途別推奨設定

#### 長時間ビルド対応
```json
{
  "execution": {
    "timeout": 1800,
    "maxConcurrent": 2
  }
}
```

#### 高速テスト環境
```json
{
  "execution": {
    "timeout": 60,
    "maxConcurrent": 10
  }
}
```

---

## リソース制限（Limits）

`limits`オブジェクトでグローバルなリソース制限を設定できます。

### 基本構造

```json
{
  "limits": {
    "maxFileSize": 5242880,
    "maxResults": 100,
    "maxMemory": 2048
  }
}
```

### パラメータ

- **maxFileSize**: 読み書き可能な最大ファイルサイズ（バイト）
- **maxResults**: 検索操作で返す最大結果数
- **maxMemory**: 最大メモリ使用量（MB）

### 実用例

#### 大規模ファイル対応
```json
{
  "limits": {
    "maxFileSize": 10485760,
    "maxResults": 500
  }
}
```

#### 軽量・高速設定
```json
{
  "limits": {
    "maxFileSize": 1048576,
    "maxResults": 50,
    "maxMemory": 512
  }
}
```

---

## フック（Hooks）

`hooks`オブジェクトでセッションライフサイクルのイベントにコマンドを紐付けられます。

### 基本構造

```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "git status --short",
        "matcher": "startup"
      }
    ],
    "BeforeEdit": [
      {
        "type": "command",
        "command": "npm run lint"
      }
    ]
  }
}
```

### 利用可能なフックイベント

- **SessionStart**: セッション開始時
- **SessionEnd**: セッション終了時
- **BeforeEdit**: ファイル編集前
- **AfterEdit**: ファイル編集後

### matcher オプション

- `"startup"`: 初回起動時のみ
- `"resume"`: セッション再開時のみ
- `"compact"`: コンパクトモード時のみ

### 実用例

#### Git状態の自動表示
```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "echo '## Git Status' && git status --short && echo '## Recent Commits' && git log --oneline -5"
      }
    ]
  }
}
```

#### 編集前の自動フォーマット
```json
{
  "hooks": {
    "BeforeEdit": [
      {
        "type": "command",
        "command": "npm run format:check"
      }
    ]
  }
}
```

---

## カスタムエージェント（Custom Agents）

`agents`配列でカスタムエージェントを定義できます。

### 基本構造

```json
{
  "agents": [
    {
      "name": "test-runner",
      "path": "./agents/test-runner.json",
      "model": "claude-3-5-haiku-20250120",
      "permissions": {
        "allow": ["Bash(npm test)", "Read(./tests/**)"]
      }
    },
    {
      "name": "code-reviewer",
      "path": "./agents/code-reviewer.json",
      "model": "claude-sonnet-4-20250514",
      "permissions": {
        "allow": ["Read(./src/**)", "Read(./docs/**)"],
        "deny": ["Write(**/*)", "Bash(**)"]
      }
    }
  ]
}
```

### エージェント設定ファイル例

`./agents/test-runner.json`:
```json
{
  "description": "Automated test execution agent",
  "role": "Test execution and reporting",
  "allowedTools": ["bash", "view", "grep"],
  "toolRestrictions": {
    "bash": {
      "allowedCommands": [
        "npm test",
        "npm run test:unit",
        "npm run test:integration"
      ]
    }
  }
}
```

---

## プラグイン（Plugins）

`plugins`配列で有効にするプラグインを指定できます。

### 基本構造

```json
{
  "plugins": [
    "prettier",
    "eslint",
    "typescript",
    "jest"
  ]
}
```

### 一般的なプラグイン

- **prettier**: コードフォーマッタ統合
- **eslint**: JavaScript/TypeScript Linter統合
- **typescript**: TypeScript言語サーバー統合
- **jest**: テストランナー統合
- **docker**: Docker操作サポート

---

## テーマとUI設定

### 基本構造

```json
{
  "theme": "dark",
  "verbose": true
}
```

### パラメータ

- **theme**: `"light"`, `"dark"`, `"auto"`（システム設定に従う）
- **verbose**: 詳細な出力を有効化（デバッグ時に便利）

---

## 完全な設定例

### 例1: セキュアなWeb開発環境

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "description": "Secure web development configuration",
  "allowedTools": [
    "view", "grep", "glob", "edit", "create",
    "bash", "report_progress", "code_review"
  ],
  "permissions": {
    "allow": [
      "Read(./src/**)",
      "Read(./public/**)",
      "Write(./src/**)",
      "Bash(npm run dev)",
      "Bash(npm test)",
      "Bash(npm run build)",
      "Bash(git status)",
      "Bash(git diff)"
    ],
    "deny": [
      "Read(**/.env*)",
      "Read(**/secrets/**)",
      "Write(**/node_modules/**)",
      "Bash(npm install *)",
      "Bash(rm -rf *)"
    ],
    "defaultMode": "ask"
  },
  "env": {
    "NODE_ENV": "development",
    "DEBUG": "app:*"
  },
  "llm": {
    "model": "claude-sonnet-4-20250514",
    "temperature": 0.3
  },
  "execution": {
    "timeout": 300
  },
  "limits": {
    "maxFileSize": 5242880,
    "maxResults": 100
  },
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "git status --short"
      }
    ]
  },
  "theme": "dark",
  "notes": [
    "セキュアなWeb開発環境設定",
    "機密ファイルへのアクセスは拒否",
    "package.jsonの変更は確認が必要"
  ]
}
```

### 例2: データサイエンス環境

```json
{
  "description": "Python data science configuration",
  "allowedTools": [
    "view", "grep", "glob", "edit", "create", "bash"
  ],
  "permissions": {
    "allow": [
      "Read(./notebooks/**)",
      "Read(./data/**)",
      "Write(./notebooks/**)",
      "Write(./output/**)",
      "Bash(python -m *)",
      "Bash(jupyter *)",
      "Bash(pip list)"
    ],
    "deny": [
      "Read(**/.env*)",
      "Bash(pip install *)",
      "Bash(rm -rf *)"
    ],
    "defaultMode": "ask"
  },
  "env": {
    "PYTHONPATH": "./src",
    "JUPYTER_CONFIG_DIR": "./.jupyter"
  },
  "llm": {
    "model": "claude-sonnet-4-20250514",
    "temperature": 0.5
  },
  "limits": {
    "maxFileSize": 10485760
  },
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "python --version && pip list | grep -E '(pandas|numpy|scikit-learn)'"
      }
    ]
  }
}
```

### 例3: マルチエージェント開発

```json
{
  "description": "Multi-agent development environment",
  "allowedTools": [
    "view", "grep", "glob", "edit", "create", "bash", "task"
  ],
  "agents": [
    {
      "name": "explorer",
      "path": "./agents/explorer.json",
      "model": "claude-3-5-haiku-20250120",
      "permissions": {
        "allow": ["Read(**/*)", "Bash(grep *)", "Bash(find *)"],
        "deny": ["Write(**/*)", "Bash(rm *)"]
      }
    },
    {
      "name": "builder",
      "path": "./agents/builder.json",
      "model": "claude-3-5-haiku-20250120",
      "permissions": {
        "allow": ["Bash(npm *)", "Bash(cargo *)", "Read(./*)"],
        "deny": ["Write(**/*)", "Bash(npm install)"]
      }
    },
    {
      "name": "coder",
      "path": "./agents/coder.json",
      "model": "claude-sonnet-4-20250514",
      "permissions": {
        "allow": ["Read(./src/**)", "Write(./src/**)", "Bash(git *)"],
        "deny": ["Bash(rm *)"]
      }
    }
  ],
  "llm": {
    "model": "claude-sonnet-4-20250514"
  },
  "execution": {
    "timeout": 600,
    "maxConcurrent": 3
  }
}
```

---

## ベストプラクティス

### 1. セキュリティ

- ❌ **やってはいけない**: 秘密情報を設定ファイルに直接記述
- ✅ **推奨**: 環境変数参照を使用し、実際の値は`.env`ファイルで管理

### 2. バージョン管理

- ✅ **Gitにコミット**: `.claude/settings.json`（チーム共有設定）
- ❌ **Gitignoreに追加**: `.claude/settings.local.json`（個人設定）

### 3. 権限設定

- ✅ **最小権限の原則**: 必要最低限の権限のみ付与
- ✅ **明示的な拒否**: 危険な操作は明示的に拒否
- ✅ **段階的な許可**: 開発段階に応じて権限を調整

### 4. スキーマ検証

設定ファイルの先頭に`$schema`を追加することで、エディタでの自動補完と検証が有効になります：

```json
{
  "$schema": "https://raw.githubusercontent.com/shoya-sue/ClaudeCodeJsons/main/schema.json",
  ...
}
```

---

## トラブルシューティング

### 設定が反映されない

1. ClaudeCodeを再起動
2. 設定ファイルのパスを確認（`.claude/settings.json`がプロジェクトルートにあるか）
3. JSON構文エラーがないかチェック（`jq . .claude/settings.json`）

### 権限エラーが出る

1. `permissions.allow`に必要なアクションを追加
2. `permissions.deny`で誤って拒否していないか確認
3. `defaultMode`を`"ask"`に設定して対話的に確認

### フックが動作しない

1. `matcher`設定が正しいか確認
2. コマンドが実行可能か確認（`bash`で直接実行してテスト）
3. `.claude/settings.local.json`で上書きされていないか確認

---

## 参考リンク

- [Claude Code 公式ドキュメント](https://code.claude.com/docs/en/settings)
- [ClaudeCode Settings リファレンス](https://claudefa.st/blog/guide/settings-reference)
- [GitHub: claude-code-settings examples](https://github.com/anthropics/claude-code/tree/main/examples/settings)

---

## 更新履歴

- 2026-02-13: 初版作成（最新の設定オプションを網羅）
