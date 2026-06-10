---
name: docs-lookup
description: User-level model override for ecc:docs-lookup — downgrades to haiku for fast Context7-backed library/API documentation retrieval.
model: haiku
---

This file is a user-level model override for the `ecc` plugin's `docs-lookup` agent.
Behavior, system prompt, and tools are inherited from the plugin definition; only `model` is overridden here.

**Why haiku:** docs lookup is a retrieval + summarization task. The expensive thinking happens
in the calling agent, not here — haiku handles the lookup hop efficiently.
