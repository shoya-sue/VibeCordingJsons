#!/bin/bash
# Quick setup script for ClaudeCode settings

set -e

echo "ClaudeCode Settings Quick Setup"
echo "================================"
echo ""

# Check if .claude directory exists
if [ ! -d ".claude" ]; then
    echo "Creating .claude directory..."
    mkdir -p .claude
fi

echo "Select a configuration preset:"
echo "1) Basic (read-only, minimal permissions)"
echo "2) Standard (recommended for most projects)"
echo "3) Advanced (full permissions, trusted environments)"
echo "4) Custom (select from templates)"
echo ""

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo "Copying Basic configuration..."
        cp configs/basic/settings.json .claude/settings.json
        ;;
    2)
        echo "Copying Standard configuration..."
        cp configs/standard/settings.json .claude/settings.json
        ;;
    3)
        echo "Copying Advanced configuration..."
        cp configs/advanced/settings.json .claude/settings.json
        ;;
    4)
        echo ""
        echo "Available templates:"
        echo "- templates/project-template.json"
        echo ""
        echo "Additional configurations in:"
        echo "- configs/mcp/"
        echo "- configs/skills/"
        echo "- configs/agent-team/"
        echo ""
        read -p "Enter template path: " template_path
        cp "$template_path" .claude/settings.json
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "✓ Configuration file created: .claude/settings.json"
echo ""
echo "Next steps:"
echo "1. Review and customize .claude/settings.json for your needs"
echo "2. Restart Claude Code to apply the new settings"
echo "3. Check EXAMPLES.md for usage examples"
echo ""
echo "For more information, see README.md"
