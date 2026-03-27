# Project Name

## Overview

<!-- Describe your project here -->

## Tech Stack

<!-- List technologies used -->

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
├── integration/   # Integration tests
└── e2e/           # E2E tests (Playwright)
docs/              # Documentation
scripts/           # Build and deploy scripts
.claude/
├── skills/        # Custom skill definitions
├── agents/        # Custom agent definitions
└── rules/         # Coding rules
```

## Conventions

- Naming: camelCase (JS/TS), snake_case (Python/Rust/Go), kebab-case (files)
- Tests go in `tests/` (separated from production code)
- Commit messages: Conventional Commits format (`feat:`, `fix:`, `docs:`, `chore:`)
- Docker images defined in `Dockerfile`

## Commands

```bash
npm test              # Run tests
npm run lint          # Lint
npm run build         # Build
docker compose up     # Start local environment
make deploy-staging   # Deploy to staging
```

## Infrastructure

<!-- Describe infrastructure here -->
- `terraform plan` is allowed; `terraform apply` requires manual confirmation
- `kubectl delete namespace/node` is forbidden

## Slash Commands

- `/model opusplan` — Auto-switch: Opus for planning, Sonnet for execution (cost optimized)
- `/effort low|medium|high` — Set model thinking level. `/effort auto` to reset
- `/memory` — Manage auto-memory (view/edit/delete)
- `/loop 5m check deploy` — Repeat a prompt on schedule
- `/plan fix the auth bug` — Start plan mode with description
- `/branch` — Fork current conversation into a new branch
- `/color` — Set prompt bar color (multi-session identification)
- `/simplify` — Simplify code
- `/batch` — Execute multiple tasks at once
- `/context` — Show context optimization suggestions
- `/copy N` — Copy Nth assistant response to clipboard (`w` key for file output)

## Important Notes

- `.env.production` is read-prohibited (controlled via settings.json deny list)
- Agent Teams enabled — multiple agents can work in parallel
- Hooks record command logs and file changes (all 21 events supported)
- MCP Elicitation supported — MCP servers can request structured input during tasks
- Auto-memory enabled — Claude saves useful context to `.claude/memory/`
- Opus 4.6 output token limit: 64k (max 128k). Control via `CLAUDE_CODE_MAX_OUTPUT_TOKENS`
- HTTP hooks supported — `type: "http"` POSTs JSON to external URLs
- Agent tool `resume` parameter is deprecated → use `SendMessage({to: agentId})`
- Subagent usage does not count against billing — delegate aggressively
