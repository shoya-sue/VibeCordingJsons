# GitHub Copilot CLI — Full Configuration

## Philosophy

This project uses **full-featured mode** for GitHub Copilot CLI.
Fleet parallel execution, Agent Teams, Skills, and Agents are all enabled.

## Agent Usage Policy

| Task Type | Agent | Reason |
|-----------|-------|--------|
| Codebase exploration | `explore` (Haiku) | Fast, cheap, parallel-safe |
| Test/build/lint execution | `task` (Haiku) | Isolate verbose output |
| Code review | `code-review` | Dedicated prompt optimization |
| Complex multi-step tasks | `general-purpose` (Sonnet) | High-quality reasoning |
| Custom review | `code-reviewer` agent | High S/N review |
| Test execution/fixing | `test-runner` agent | TDD support |
| GitHub workflow | `github-workflow` agent | Issue-to-PR pipeline |
| Code explanation | `code-explorer` agent | Detailed analysis |

### Fleet Mode

Use `/fleet` for independent parallel tasks:
- Simultaneous multi-file refactoring
- Parallel test execution across services

### Plan Mode

Switch to Plan mode with `Shift+Tab` before starting complex tasks.

## Claude Code Integration

| Copilot CLI Strengths | Claude Code Strengths |
|----------------------|----------------------|
| GitHub Issues/PR ops | Large-scale refactoring |
| Fleet parallel agents | Complex debug sessions |
| MCP server tools | Interactive code design |
| Quick fixes & snippets | Architecture design |

## Subagent Delegation Rules (Global)

> **This rule applies to ALL skills with highest priority.**

When executing skills, the main agent MUST:

1. **Never write code directly** — delegate all file edits to subagents
2. **Always delegate to subagent** — launch `general-purpose` subagent via `task` tool
3. **Forward results verbatim** — do not summarize or modify subagent output

## Skills Guide

- **explain-code** — Explain code structure and logic
- **code-reviewer** — Quality/security/performance review
- **fix-issue** — Read GitHub Issue, apply fix
- **review-pr** — Pull Request code review
- **test-runner** — Test execution, failure analysis, fixing
- **create-issue** — Create GitHub Issues
- **generate-changelog** — Generate CHANGELOG from git history
- **dependency-audit** — Audit dependencies for vulnerabilities

## Custom Agents

- `code-reviewer` — Read-only, high-precision review
- `test-runner` — TDD support, failure analysis
- `github-workflow` — Issue-to-PR pipeline management
- `code-explorer` — Codebase detailed explanation

## GitHub Operations

- Always use `gh` CLI for GitHub API operations
- Never use `curl` to api.github.com directly
- Use `gh api` only as a last resort

## Coding Conventions

- Commit messages: **Conventional Commits** format (`feat:`, `fix:`, `chore:`, etc.)
- Naming: camelCase (JS/TS), snake_case (Python/Rust/Go), kebab-case (files)
- Test-first development (TDD)
- Minimal changes to achieve the goal (surgical edits)

## Security Rules

- `.env.production` is read-prohibited
- `kubectl delete namespace/node` is forbidden
- `terraform apply` requires manual confirmation
- Never commit secrets to code
- Never push directly to production

## Prompt Best Practices (GitHub Official)

1. **Break complex tasks down** — one prompt, one task
2. **Be specific** — provide input/output examples
3. **Provide context** — reference files with `@`
4. **Use feedback** — rephrase unsatisfactory responses
5. **Select models** — use `/model` for task-appropriate model
6. **Guide Copilot** — specify roles to improve answer quality
