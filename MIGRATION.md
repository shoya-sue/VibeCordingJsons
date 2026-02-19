# 🔄 シンプル化について

## 変更内容（2026-02-13）

設定ファイルの構造をシンプルにしました。**選択肢を3つだけ**にして、迷わないようにしました。

## 新しい構造

```
configs/
├── basic-optimized.json       # 📖 読み取り専用
├── standard-optimized.json    # 👨‍💻 通常の開発（推奨）
├── advanced-optimized.json    # 🚀 フル機能
├── add-ons/                   # 追加機能（必要な人だけ）
└── legacy/                    # 過去の設定（非推奨）
```

## 移行ガイド

### 既存ユーザーの方へ

以前の設定を使っている場合：

| 以前使っていた設定 | 新しい推奨設定 |
|------------------|--------------|
| `configs/basic/settings.json` | `configs/basic-optimized.json` |
| `configs/standard/settings.json` | `configs/standard-optimized.json` |
| `configs/advanced/settings.json` | `configs/advanced-optimized.json` |
| `configs/optimized/*` | `configs/*-optimized.json` |

**推奨アクション：**
```bash
# 新しい標準設定に切り替え
cp configs/standard-optimized.json .claude/settings.json
```

### 過去の設定ファイル

以下は`configs/legacy/`に移動しました（新規利用は非推奨）：
- `basic/settings.json`
- `standard/settings.json`
- `advanced/settings.json`
- `examples/` ディレクトリ全体

### 追加機能（add-ons）

特殊な機能は`configs/add-ons/`に整理：
- `mcp/` - GitHub API、ブラウザ自動化等
- `skills/` - Claude Code Skills
- `agent-team/` - マルチエージェント開発

## なぜシンプル化したのか？

ユーザーから「パターンが多すぎて何を使えば良いかわからない」というフィードバックをいただきました。

**以前：** 20個以上の設定ファイル、複数のディレクトリ、複雑な選択肢
**今：** 3つの主要設定ファイル、必要なときだけadd-onsを使用

## 質問がある場合

- 基本的な使い方：[README.md](README.md)
- 詳細な設定：[ADVANCED_CUSTOMIZATION.md](ADVANCED_CUSTOMIZATION.md)
- リファレンス：[REFERENCE.md](REFERENCE.md)
