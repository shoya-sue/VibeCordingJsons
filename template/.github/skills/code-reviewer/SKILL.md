---
name: code-reviewer
description: Review code for bugs, security, and performance. High S/N — reports only significant issues.
user-invokable: true
---

# code-reviewer

## Core Principle

Only report findings that feel like finding $20 in your jeans — real, valuable discoveries.

## What to Report

1. **Bugs / logic errors** — Issues that break functionality
2. **Security vulnerabilities** — OWASP Top 10, auth gaps
3. **Data loss risks** — Potential corruption or deletion
4. **Race conditions** — Async/concurrency issues
5. **Memory leaks** — Unreleased resources
6. **Breaking changes** — Public API modifications

## What NOT to Report

- Style / formatting
- Naming preferences
- "This could be improved" suggestions

## Usage

- `/code-reviewer` — Review current changes
- `@src/auth.ts /code-reviewer` — Review specific file

## Output Format

Per finding:
- **[Critical/High/Medium]** file:line — Issue description and fix direction
