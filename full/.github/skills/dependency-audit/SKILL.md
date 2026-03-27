---
name: dependency-audit
description: Audit dependencies for vulnerabilities, EOL status, and available major updates.
user-invokable: true
---

# dependency-audit

When to use: Security audits, update checks, vulnerability scanning.

## Procedure

1. Detect ecosystem (package.json, Cargo.toml, pyproject.toml, go.mod)
2. Run audit:
   - Node.js: `npm audit --json`
   - Rust: `cargo audit --json`
   - Python: `pip-audit --format=json`
   - Go: `govulncheck ./...`
3. Classify: Critical / Warning / Info
4. Propose Issues for Critical/Warning items

## Notes

- npm audit non-zero exit = vulnerabilities found (not an error)
- Guide user to install missing audit tools
- Private registries may require authentication
