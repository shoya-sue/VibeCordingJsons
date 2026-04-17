---
description: Guidelines for when to use Agent Teams vs single agent
---

# Team Coordination Rules

## When to Use Teams (3+ independent changes)

- Frontend + backend changes that can proceed in parallel
- Multiple independent modules need simultaneous updates
- Research phase + implementation phase can overlap
- Large refactoring spanning 5+ files across different domains

## When NOT to Use Teams

- Single-file changes or edits within 1-2 related files
- Sequential tasks where each step depends on the previous
- Simple bug fixes with a clear root cause
- Documentation-only updates

## Team Composition

- **Team lead**: coordinates, assigns tasks, reviews results
- **Workers**: 2-4 agents max (diminishing returns beyond 4)
- Use `isolation: "worktree"` for agents that write conflicting files
- Prefer `run_in_background: true` for independent research tasks
