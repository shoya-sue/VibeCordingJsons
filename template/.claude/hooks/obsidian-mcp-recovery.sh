#!/bin/bash
# Obsidian MCP auto-recovery hook
# Fires on PostToolUseFailure for mcp__obsidian__* tools

echo "OBSIDIAN_MCP_RECOVERY: mcp__obsidian__* ツールが失敗しました。"
echo "スキーマ未ロードの可能性が高いです。"
echo ""
echo "次のToolSearchを実行してからリトライしてください:"
echo 'ToolSearch(query: "select:mcp__obsidian__list-available-vaults,mcp__obsidian__create-note,mcp__obsidian__read-note,mcp__obsidian__edit-note,mcp__obsidian__search-vault,mcp__obsidian__create-directory,mcp__obsidian__move-note,mcp__obsidian__delete-note,mcp__obsidian__add-tags,mcp__obsidian__remove-tags,mcp__obsidian__rename-tag")'
