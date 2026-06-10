---
name: code-explorer
description: User-level model override for ecc:code-explorer — downgrades to haiku for fast codebase mapping. Use for breadth-first surveys, file-pattern lookups, and "where is X defined" questions.
model: haiku
---

This file is a user-level model override for the `ecc` plugin's `code-explorer` agent.
Behavior, system prompt, and tools are inherited from the plugin definition; only `model` is overridden here.

**Why haiku:** code mapping is a wide, shallow task — speed and breadth matter more than depth.
For deep semantic analysis switch to `code-reviewer` (opus) instead.
