---
name: comment-analyzer
description: User-level model override for ecc:comment-analyzer — downgrades to haiku. Use for stale-comment detection, TODO sweeps, and comment-quality audits.
model: haiku
---

This file is a user-level model override for the `ecc` plugin's `comment-analyzer` agent.
Behavior, system prompt, and tools are inherited from the plugin definition; only `model` is overridden here.

**Why haiku:** comment auditing is a string-pattern task. Haiku is sufficient and significantly cheaper.
