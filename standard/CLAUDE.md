# Project Name

## Overview

<!-- Describe your project here -->

## Tech Stack

<!-- List technologies used -->
<!-- e.g., TypeScript, React, Node.js, PostgreSQL -->

## Project Structure

```text
src/
├── components/    # UI components
├── pages/         # Pages
├── services/      # API clients, business logic
├── utils/         # Utilities
└── types/         # Type definitions
tests/
├── unit/          # Unit tests
└── integration/   # Integration tests
docs/              # Documentation
```

## Conventions

- Naming: see `rules/code-style.md` (language-idiomatic)
- Tests go in `tests/` (separated from production code)
- Commit messages: Conventional Commits format

## Commands

```bash
npm test          # Run tests
npm run lint      # Lint
npm run build     # Build
```

## Slash Commands

- `/model opusplan` — Auto-switch: Opus for planning, Sonnet for execution
- `/effort low|medium|high` — Set thinking level. `/effort auto` to reset
- `/memory` — Manage auto-memory
- `/plan` — Start plan mode (also Shift+Tab)
- `/compact <summary>` — Compact context with focused summary

## Important Notes

- Store API keys in `.env` (not git-tracked)
- Only `src/`, `tests/`, `docs/` are editable by Claude Code
- Force-push is prohibited
