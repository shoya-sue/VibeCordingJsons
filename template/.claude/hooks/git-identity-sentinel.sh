#!/usr/bin/env bash
# git-identity-sentinel.sh — SessionStart guard (detection only).
#
# Warns loudly (as SessionStart context) if the GLOBAL git identity looks
# like a test/CI/placeholder value — a signature that ~/.gitconfig was
# clobbered by a leaking test harness (see guard-git-identity.sh).
#
# This complements the PreToolUse guard: the PreToolUse hook stops Claude
# from writing a bad identity directly, but it cannot see a `git config
# --global` that runs *inside* a subprocess Claude launched (e.g. `npm test`
# of a third-party package with unisolated HOME). This sentinel catches such
# indirect/external clobbers at the next session start so they never silently
# persist across commits.
#
# Detection ONLY. Never mutates git config — restoring identity is the
# user's decision.
set -uo pipefail

name="$(git config --global --get user.name 2>/dev/null || true)"
email="$(git config --global --get user.email 2>/dev/null || true)"

bad=0
case "$email" in
  test@test.com|*@example.com|*@test.com|your@email.com|noreply@example.com) bad=1 ;;
esac
case "$name" in
  "Test User"|"Test"|"Your Name"|"CI"|"ci"|"github-actions"*|"Unknown") bad=1 ;;
esac

if [ "$bad" = "1" ]; then
  echo "## ⚠️ git identity 警告（自動検知）"
  echo ""
  echo "GLOBAL git identity がテスト/プレースホルダ値になっています:"
  echo ""
  echo "- \`user.name\`  = \"${name}\""
  echo "- \`user.email\` = \"${email}\""
  echo ""
  echo "これはテストハーネス等による \`~/.gitconfig\` 汚染の兆候です。**このままコミットすると著者名が誤って記録されます。**"
  echo "コミット前に正しい identity へ戻してください（例: \`git config --global user.name \"<自分の名前>\"\` / \`git config --global user.email \"<自分のメール>\"\` をユーザー自身がターミナルで実行）。"
fi
exit 0
