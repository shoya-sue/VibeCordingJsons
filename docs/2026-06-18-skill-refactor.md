# VibeCording Update — 2026-06-18 (update-release skill リファクタ)

> Claude Code バージョン対応ではなく、リポジトリのメンテツール（`update-release` skill）自体の構造改善。Issue #108、v0.64.0。

## 変更点サマリー

`update-release` skill を **プロジェクトローカル化**し、リリースが **context / memory / Obsidian の 3 面**を更新すべきという原則を明文化した。

## 背景（解決した問題）

1. **二重配置 + グローバル常駐**: `template/.claude/skills/`（install.sh で全プロジェクトに配布）と `~/.claude/skills/`（グローバル）に同一内容で存在。VibeCordingJsons 専用のメンテツールなのに、無関係な end-user プロジェクトへ配布され、全セッションでグローバル常駐していた。プロジェクトローカル版は無かった。
2. **Obsidian 更新が属人的**: project note `20_projects/shoya-sue/VibeCordingJsons.md` は毎リリース手動更新されていたが skill 手順に無かった。
3. **3 面伝播が暗黙**: context / memory / obsidian の同時更新が明文化されていなかった。
4. **状態把握→要否判定が弱かった**。

## 決定（ユーザー承認）

| 論点 | 決定 |
|------|------|
| 配置 | **プロジェクトローカルのみ**（`VibeCordingJsons/.claude/skills/update-release/`）。template / グローバルから削除 |
| Obsidian | project note 更新を**明示ステップ化**（`mcp__obsidian__vault_*` を allowed-tools に追加）。memory symlink による `90_artifacts/.../memory/` 自動ミラーは追記不要と明記 |
| 0 変更時 | **カバレッジ記録リリースを出す**（現状維持、early-exit しない） |

## 変更内容

### 追加
- `.claude/skills/update-release/SKILL.md` — プロジェクトローカル版。主な改訂:
  - 冒頭に「**1 リリース = 3 面（context / memory / obsidian）の同時更新**」原則テーブル
  - Pre-flight を「状態把握 → 更新要否判定」に再構成（0 変更でもカバレッジ記録リリース、early-exit 禁止を明記）
  - Step 9「Update Obsidian project note」を新設（`vault_get_document_map` → `vault_patch` 手順、healthcheck ✗ 時の Read/Edit フォールバック明記）
  - Step 8（memory）に symlink 自動ミラーの注記
  - allowed-tools に `mcp__obsidian__vault_*`（read/append/patch/get_document_map/search_simple）と `Bash(bash *)`（check-counts.sh 用）を追加

### 削除
- `template/.claude/skills/update-release/`（template から除外 → end-user に配布しない）
- グローバル `~/.claude/skills/update-release/`（リポジトリ外、別途削除）

### 連動修正（template local skills 11 → 10）
- `template/AGENTS.md` — skill リスト（11→10、update-release 除去）
- `template/README.md` — Skills (Claude) 行（11→10）
- `README.md` — ツリー図（update-release 行削除）+ 「11 local skills」→「10 local skills」
- `scripts/check-counts.sh` — `EXP_SKILLS` 11 → 10

## 検証

- `bash scripts/check-counts.sh` → ✓ counts consistent（local skills 10）
- ECC 2.0.0 据え置き、`settings.json` 挙動変更なし
- end-user テンプレートからは update-release が消えるのみ（他 skill・機能に影響なし）
