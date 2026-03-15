---
name: dependency-audit
description: 依存パッケージの脆弱性・EOL・メジャーアップデートをチェック
user-invokable: true
allowed-tools: ["Read", "Glob", "Grep", "Bash(npm audit *)", "Bash(npx *)", "Bash(cargo audit *)", "Bash(pip-audit *)", "Bash(go list *)", "Bash(govulncheck *)", "Bash(gh issue *)"]
---

# dependency-audit

プロジェクトの依存パッケージを監査してください。

## 手順

1. プロジェクトのエコシステムを検出
2. 脆弱性チェックを実行
3. 結果を分類・レポート
4. Critical / Warning は Issue 起票を提案

## エコシステム検出と実行

### Node.js
```bash
# package.json / package-lock.json が存在する場合
npm audit --json 2>/dev/null | jq '.vulnerabilities | to_entries[] | {name: .key, severity: .value.severity, range: .value.range}'
```

### Rust
```bash
# Cargo.toml が存在する場合
cargo audit --json 2>/dev/null
```

### Python
```bash
# pyproject.toml / requirements.txt が存在する場合
pip-audit --format=json 2>/dev/null
```

### Go
```bash
# go.mod が存在する場合
govulncheck ./... 2>/dev/null
```

## レポート形式

```markdown
## 依存関係監査レポート（YYYY-MM-DD）

### 🔴 Critical（即対応）
- **package@version** — CVE-XXXX-XXXX（説明）
  - 修正バージョン: x.y.z
  - 影響: RCE / データ漏洩 等

### 🟡 Warning（計画的に対応）
- **package@version** — メジャーアップデート利用可能（current → latest）
  - 破壊的変更の有無: あり / なし

### ℹ️ Info
- **package@version** — マイナーアップデート利用可能
- **package@version** — EOL まで残り N ヶ月

### サマリー
- 検査パッケージ数: N
- Critical: N / Warning: N / Info: N
```

## create-issue 連携

Critical または Warning の項目が見つかった場合：
1. ユーザーに Issue 起票を提案する
2. 承認されたら `/create-issue` スキルを使用して起票する
3. ラベル: `security`（脆弱性）/ `tech-debt`（EOL・アップデート）

## 注意事項

- 監査ツールが未インストールの場合はインストール方法を案内する
- `npm audit` の exit code 非ゼロは脆弱性検出を意味する（エラーではない）
- プライベートレジストリを使用している場合は認証が必要な旨を伝える
