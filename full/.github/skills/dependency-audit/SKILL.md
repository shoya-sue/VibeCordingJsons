---
name: dependency-audit
description: 依存パッケージの脆弱性・EOL・メジャーアップデートをチェックし、レポートを生成する。
user-invokable: true
---

# Dependency Audit — 依存関係監査スキル

プロジェクトの依存パッケージを監査し、脆弱性・EOL・アップデート情報をレポートするスキルです。

## いつ使うか

- 「依存関係の脆弱性をチェックして」
- 「パッケージのアップデートがないか確認して」
- 「セキュリティ監査を実行して」

## 作業手順

### Step 1: エコシステム検出

```bash
ls package.json Cargo.toml pyproject.toml go.mod 2>/dev/null
```

### Step 2: 監査実行

| エコシステム | コマンド |
|-------------|---------|
| Node.js | `npm audit --json` |
| Rust | `cargo audit --json` |
| Python | `pip-audit --format=json` |
| Go | `govulncheck ./...` |

### Step 3: レポート生成

- 🔴 Critical: 即対応（CVE、RCE 等）
- 🟡 Warning: 計画的対応（メジャーアップデート等）
- ℹ️ Info: マイナーアップデート、EOL 情報

### Step 4: Issue 連携

Critical / Warning の項目はユーザー確認の上、`/create-issue` で起票を提案。

## 注意事項

- 監査ツールが未インストールの場合はインストール方法を案内する
- `npm audit` の exit code 非ゼロはエラーではなく脆弱性検出を意味する
