#!/bin/bash
# Obsidian MCP auto-recovery hook (cyanheads server v3.x 対応)
# Fires on PostToolUseFailure for mcp__obsidian__* tools.
# 失敗の最頻原因はスキーマ未ロード → ToolSearch で再ロードを案内する。

cat <<'EOF'
OBSIDIAN_MCP_RECOVERY: mcp__obsidian__* ツール呼び出しが失敗しました。

考えられる原因:
  1. ツールスキーマがまだロードされていない (deferred tool)
  2. Obsidian アプリが起動していない (HTTPS 27124 unreachable)
  3. macOS Keychain に OBSIDIAN_API_KEY がない
  4. Local REST API plugin が disable

対応:

(A) スキーマ未ロードならまず ToolSearch で再ロード:

ToolSearch(query: "select:mcp__obsidian__obsidian_get_note,mcp__obsidian__obsidian_list_notes,mcp__obsidian__obsidian_search_notes,mcp__obsidian__obsidian_write_note,mcp__obsidian__obsidian_append_to_note,mcp__obsidian__obsidian_patch_note,mcp__obsidian__obsidian_replace_in_note,mcp__obsidian__obsidian_manage_frontmatter,mcp__obsidian__obsidian_manage_tags,mcp__obsidian__obsidian_list_tags,mcp__obsidian__obsidian_delete_note,mcp__obsidian__obsidian_open_in_ui")

(B) 接続不良なら healthcheck を手動で実行:

$HOME/.claude/hooks/obsidian-mcp-healthcheck.sh

(C) 復旧不能なら Write/Edit に一時フォールバック (ユーザーに 1 行宣言してから)。
EOF
