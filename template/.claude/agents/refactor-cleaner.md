---
name: refactor-cleaner
description: User-level model override for everything-claude-code:refactor-cleaner — downgrades to haiku. Use for dead-code detection, unused-import cleanup, and small mechanical refactors.
model: haiku
---

This file is a user-level model override for the `everything-claude-code` plugin's `refactor-cleaner` agent.
Behavior, system prompt, and tools are inherited from the plugin definition; only `model` is overridden here.

**Why haiku:** dead-code detection and trivial refactors are pattern-matching tasks — haiku handles them
at a fraction of the cost. For non-trivial architectural refactors, invoke `architect` (opus) instead.
