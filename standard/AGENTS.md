# Project Name

## Overview

<!-- Describe your project in 1-2 lines -->

## Tech Stack

<!-- List technologies used -->
<!-- e.g., TypeScript, React, Node.js, PostgreSQL -->

## Project Structure

```text
src/
├── components/    # UI components
├── pages/         # Pages
├── utils/         # Utilities
└── types/         # Type definitions
```

## Commands

```bash
# Start dev server
npm run dev

# Run tests
npm test

# Build
npm run build
```

## AI Agent Usage Policy (Standard)

This project uses AI agents in **everyday development mode**.

### Tool Selection

| Purpose | Tool |
|---------|------|
| Code review and exploration | Copilot CLI / Claude Code |
| Complex refactoring | Claude Code |
| GitHub Issues and PRs | Copilot CLI |
| Test execution and fixes | Claude Code |

### Allowed Operations

- Read and edit source code, tests, and documentation
- `git add` / `git commit` (push requires confirmation)
- `npm install` / test execution
- GitHub operations via MCP tools

### Prohibited Operations

- `git push --force`
- `rm -rf`
- Reading or writing secrets / API keys
- Direct deployment to production

## Coding Conventions

- Commit messages follow Conventional Commits format (`feat:`, `fix:`, `chore:`, etc.)
- Tests first (TDD)

## Notes

- Always verify with `git diff` before committing changes
- Break large changes into small, incremental steps
- When specifications are unclear, ask via Issue or PR comments rather than guessing
