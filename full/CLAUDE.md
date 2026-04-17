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

- Naming: see `rules/ecc/common/coding-style.md` + language-specific rules
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
- `/effort low|medium|high|xhigh|max` — Set thinking level. `/effort auto` to reset
- `/memory` — Manage auto-memory
- `/loop 5m check deploy` — Repeat a prompt on schedule
- `/plan <description>` — Start plan mode
- `/compact <summary>` — Compact context with focused summary
- `/powerup` — インタラクティブな学習レッスンを起動
- `/reload-plugins` — プラグインスキルを再起動なしで再読み込み
- `/team-onboarding` — チームメイト向けのランプアップガイドを生成
- `/proactive` — `/loop` のエイリアス（プロアクティブなループ実行）
- `/recap` — 離席後のセッションサマリーを手動表示

## Important Notes

- `.env.production` is read-prohibited (deny list)
- Agent Teams enabled (`teammateMode: auto`)
- ECC hooks: session continuity (SessionStart/Stop/SessionEnd), --no-verify guard (PreToolUse), compact quality (PreCompact)
- Auto-memory enabled → `.claude/memory/`
- Subagent usage does not count against billing — delegate aggressively
- `gh` CLI for all GitHub operations, never raw `api.github.com`
- Opus 4.6 output limit: 64k tokens (configurable via `CLAUDE_CODE_MAX_OUTPUT_TOKENS`)
- **Requires** `everything-claude-code` plugin for agents and skills
- Rules: `ecc/common/` (10) + language-specific rules (9 languages × 5 = 45)
