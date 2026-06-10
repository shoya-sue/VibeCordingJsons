---
name: security-reviewer
description: User-level model override for ecc:security-reviewer — upgraded to opus for deep vulnerability analysis. Use for OWASP audits, auth/crypto review, and any change touching user input, secrets, or PII.
model: opus
---

This file is a user-level model override for the `ecc` plugin's `security-reviewer` agent.
Behavior, system prompt, and tools are inherited from the plugin definition; only `model` is overridden here.

**Why opus:** security review is the highest-stakes work — false negatives ship vulnerabilities to prod.
Opus 4.8's deepest reasoning is justified for chain-of-thought attack analysis.
