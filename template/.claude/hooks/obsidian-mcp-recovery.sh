#!/bin/bash
# Obsidian MCP auto-recovery hook (native Local REST API & MCP Server, HTTP 27123)
# Fires on PostToolUseFailure for mcp__obsidian__* tools.
# 失敗の最頻原因はスキーマ未ロード → ToolSearch で再ロードを案内する。

cat <<'EOF'
OBSIDIAN_MCP_RECOVERY: mcp__obsidian__* ツール呼び出しが失敗しました。

考えられる原因:
  1. ツールスキーマがまだロードされていない (deferred tool)
  2. Obsidian アプリが起動していない / native MCP が無効 (HTTP 27123 /mcp/ unreachable)
  3. OBSIDIAN_API_KEY が未 export → Bearer ヘッダが空で 401 (~/.zshrc の export を確認)
  4. Local REST API & MCP Server plugin が disable

対応:

(A) スキーマ未ロードならまず ToolSearch で再ロード:

ToolSearch(query: "select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_append,mcp__obsidian__vault_patch,mcp__obsidian__vault_list,mcp__obsidian__vault_delete,mcp__obsidian__vault_move,mcp__obsidian__vault_get_document_map,mcp__obsidian__search_query,mcp__obsidian__search_simple,mcp__obsidian__tag_list,mcp__obsidian__command_list,mcp__obsidian__command_execute,mcp__obsidian__open_file,mcp__obsidian__active_file_get_path,mcp__obsidian__periodic_note_get_path")

(B) 接続不良なら healthcheck を手動で実行:

$HOME/.claude/hooks/obsidian-mcp-healthcheck.sh

(C) 復旧不能なら Write/Edit に一時フォールバック (ユーザーに 1 行宣言してから)。
EOF
