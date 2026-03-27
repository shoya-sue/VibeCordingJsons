---
name: explain-code
description: Explain code structure, logic, and dependencies in detail
user-invokable: true
---

# explain-code

When to use: Understanding unfamiliar code, algorithm explanations, dependency insights.

## Step 1: Capture Context

```bash
find . -type f -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.rs" | head -30
```

## Step 2: Read and Analyze

Perspectives to cover:
1. **Purpose** — What this code does
2. **Input/Output** — Arguments, return values, side effects
3. **Algorithm** — Processing flow
4. **Design decisions** — Why this approach
5. **Dependencies** — External modules and APIs

## Output Format

```markdown
## Overview
[1-2 line summary]

## Detailed Explanation
[Step-by-step analysis]

## Key Points
- [Important observations]

## Related Files
- [List of connected files]
```

Respond in the user's language (default: Japanese). Use `@filename` to add files to context.
