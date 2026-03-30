# Project Name

## Overview

<!-- Describe your project here -->

## Tech Stack

<!-- List technologies used -->

## Project Structure

```text
src/           # Application source
tests/         # All tests (unit, integration, e2e)
docs/          # Documentation
scripts/       # Build and deploy scripts
.claude/       # Skills, agents, rules
```

## Conventions

- Naming: see `rules/code-style.md` (language-idiomatic)
- Commits: Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`)
- Tests: separated from production code in `tests/`

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

- `/model opusplan` — Auto-switch: Opus for planning, Sonnet for execution
- `/effort low|medium|high` — Set thinking level. `/effort auto` to reset
- `/memory` — Manage auto-memory
- `/loop 5m check deploy` — Repeat a prompt on schedule
- `/plan <description>` — Start plan mode
- `/compact <summary>` — Compact context with focused summary

## Important Notes

- `.env.production` is read-prohibited (deny list)
- Agent Teams enabled (`teammateMode: auto`)
- All 21 hook events wired — see `settings.json`
- Auto-memory enabled → `.claude/memory/`
- Subagent usage does not count against billing — delegate aggressively
- `gh` CLI for all GitHub operations, never raw `api.github.com`
- Opus 4.6 output limit: 64k tokens (configurable via `CLAUDE_CODE_MAX_OUTPUT_TOKENS`)
