# VibeCording Update — 2026-06-24 (env 表 公式 default 監査)

## 背景

v0.68.0（Claude Code 2.1.187 対応）の検証中、README env 表の「Recommended」列が**公式由来ではなくテンプレ作者の経験則**であり、一部が**公式 default と矛盾**していることが判明した。特に `BASH_MAX_TIMEOUT_MS` は README Recommended `120000-300000` が公式 default `600000` と食い違い、実 settings.json（`600000`）の方が公式準拠だった（README の方が誤り）。

「最も正しいと判断される設定として更新する」方針に基づき、`claude-code-guide` subagent で公式 docs を一次情報として各 env var の default を裏取りし、README env 表を是正した。

## 公式裏取り結果（一次情報: code.claude.com/docs）

| 変数 | 公式 default | 出典 | README 旧 | settings.json 実値 |
|------|------------|------|----------|------------------|
| `BASH_MAX_TIMEOUT_MS` | **600000**（10分、明記） | env-vars | `120000-300000` ❌ | `600000` ✓ |
| `BASH_DEFAULT_TIMEOUT_MS` | **120000**（2分、明記） | env-vars | （行なし） | 未設定 |
| `MAX_MCP_OUTPUT_TOKENS` | **25000**（明記） | mcp | `10000-25000` | `25000` ✓ |
| `ENABLE_TOOL_SEARCH` | **default 有効**（明記） | mcp | `auto` | 未設定 |
| `MCP_TIMEOUT` | 公式 default 記載なし | mcp（名のみ） | `10000-15000` | `30000` |
| `MCP_TOOL_TIMEOUT` | unset 時 事実上無制限（約28h 相当） | mcp | `120000` | 未設定 |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 公式 docs 未記載 | — | `64000` | `64000` |
| `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` | 公式 docs 未記載 | — | `5000` | — |

## 是正内容（README env 表のみ・settings.json 不変）

- 列ヘッダー `Recommended` → `Value`、表上に「値列の出所」注記を追加（数値系=公式 default、フラグ系=テンプレ推奨値の区別を明示）。
- `BASH_MAX_TIMEOUT_MS`: `120000-300000` → **`600000`（公式 default）**。実 settings.json と一致。
- `MAX_MCP_OUTPUT_TOKENS`: `10000-25000` → **`25000`（公式 default）**。
- `BASH_DEFAULT_TIMEOUT_MS`: **行を新規追加**（公式 default 120000、テンプレ未設定）。
- `MCP_TIMEOUT` / `CLAUDE_CODE_MAX_OUTPUT_TOKENS` / `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS`: Description に「公式 default 記載なし（テンプレ値）」を明記。
- `MCP_TOOL_TIMEOUT`: 「unset 時 default は事実上無制限、明示で上限を課す」と公式挙動を明記、テンプレ未設定を明示。
- `ENABLE_TOOL_SEARCH`: 「公式 default で有効」を明記。

## settings.json を変更しない理由

実 settings.json env 値は**すべて公式 default 一致 or 意図的なテンプレ選択**で、是正対象は README 記述のみ:

- `BASH_MAX_TIMEOUT_MS:600000` = 公式 default 一致
- `MAX_MCP_OUTPUT_TOKENS:25000` = 公式 default 一致
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS:64000` = 意図的（Opus 4.8 は 128k cap だが保守的に 64k）
- `MCP_TIMEOUT:30000` = 公式 default 不明のため妥当値を維持（30 秒）

## 検証

- `bash scripts/check-counts.sh` → ✓ counts consistent（env 表は count 非該当）
- 公式裏取りは `claude-code-guide` subagent が WebFetch で実施（curl 不使用）
