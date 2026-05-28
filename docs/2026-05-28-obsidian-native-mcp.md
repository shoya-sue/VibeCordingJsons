# Obsidian MCP migration — native HTTP (2026-05-28)

## 変更点サマリー

Obsidian MCP を **cyanheads/obsidian-mcp-server (stdio Node ラッパ)** から **Local REST API & MCP Server プラグイン内蔵の native MCP (HTTP)** へ移行。プラグインが v4.1.0 で MCP を内蔵したため、中間 Node プロセス・global npm 依存・nvm パス決め打ちを除去できる。

## 接続構成

- **URL**: `http://127.0.0.1:27123/mcp/`（loopback 平文 HTTP）
- HTTPS 27124 は self-signed cert を Node が拒否する (`DEPTH_ZERO_SELF_SIGNED_CERT`) ため不採用
- **認証**: `~/.zshrc` で macOS Keychain (`obsidian-mcp-api-key`) から `OBSIDIAN_API_KEY` を export → `.mcp.json` headers `Bearer ${OBSIDIAN_API_KEY}` で env 展開（平文トークンを config に置かない）
- **ツール**: `mcp__obsidian__vault_*`（16 個）。`vault_patch` で surgical edit、`vault_get_document_map` で構造把握、`search_query`/`search_simple` で検索

## 変更ファイル

| ファイル | 変更 |
|---|---|
| `template/.mcp.json` | obsidian エントリを stdio(cyanheads) → `type:http` 27123 + `Bearer ${OBSIDIAN_API_KEY}` |
| `template/.claude/rules/obsidian-mcp.md` | ツール名 `obsidian_*`→`vault_*`、接続/認証ルール更新。旧構成・移行経緯の記述は削除（rule は現行状態のみ保持） |
| `template/.claude/hooks/obsidian-mcp-healthcheck.sh` | チェックを native `/mcp/`(27123) + `~/.zshrc` export 確認に刷新 |
| `template/.claude/hooks/obsidian-mcp-recovery.sh` | ToolSearch 再ロード対象を `vault_*` に更新 |
| `install.sh` | (1) `~/.claude.json` への MCP 登録で http サーバーの `headers` を保持（従来は脱落し 401 の原因）、(2) Obsidian pre-flight を native 化（cyanheads binary チェック廃止、27123 疎通チェック追加）、(3) zshrc bridge に `OBSIDIAN_API_KEY` export ブロックを冪等追加 |

## 反映タイミング

env 展開のため、`OBSIDIAN_API_KEY` を export した shell から起動した次回 claude セッションで有効。確認は SessionStart healthcheck が `✓ (5/5 OK)` か、ツールが `mcp__obsidian__vault_*` で見えるか。
