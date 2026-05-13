---
name: code-reviewer
description: User-level model override for everything-claude-code:code-reviewer — upgraded to opus for deeper review quality. Use after writing or modifying code, before committing.
model: opus
---

This file is a user-level model override for the `everything-claude-code` plugin's `code-reviewer` agent.
Behavior, system prompt, and tools are inherited from the plugin definition; only `model` is overridden here.

**Why opus:** code review benefits substantially from deeper reasoning — subtle logic bugs, missing
edge cases, and architecture smells are easier to spot with Opus 4.7's `xhigh` thinking budget.
