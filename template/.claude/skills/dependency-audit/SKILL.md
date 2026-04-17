---
name: dependency-audit
description: Audit dependencies for vulnerabilities, EOL, and major updates
user-invokable: true
allowed-tools: ["Read", "Glob", "Grep", "Bash(npm audit *)", "Bash(npx *)", "Bash(cargo audit *)", "Bash(pip-audit *)", "Bash(go list *)", "Bash(govulncheck *)", "Bash(gh issue *)"]
---

# dependency-audit

Audit project dependencies for security and update status.

## Procedure

1. Detect ecosystem (package.json, Cargo.toml, pyproject.toml, go.mod)
2. Run appropriate audit tool
3. Classify results by severity
4. Propose GitHub Issues for Critical/Warning items

## Audit Commands

- **Node.js**: `npm audit --json`
- **Rust**: `cargo audit --json`
- **Python**: `pip-audit --format=json`
- **Go**: `govulncheck ./...`

## Report Format

- **Critical** — CVE with fix version, requires immediate action
- **Warning** — Major update available, plan upgrade
- **Info** — Minor updates, EOL timeline

## Notes

- Guide user to install missing audit tools
- `npm audit` non-zero exit = vulnerabilities found (not an error)
