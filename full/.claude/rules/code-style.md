---
description: Code style conventions applied across all languages
paths:
  - "src/**"
  - "tests/**"
---

# Code Style Rules

- Variables/functions: camelCase (JavaScript/TypeScript), snake_case (Python/Rust/Go)
- File names: kebab-case (e.g., `user-profile.ts`, `data-loader.py`)
- Comments explain "why", not "what" — let the code express intent
- One responsibility per function; consider splitting above 50 lines
- Extract magic numbers to named constants
- Error messages must be specific (e.g., "Failed to connect to database: connection refused")
