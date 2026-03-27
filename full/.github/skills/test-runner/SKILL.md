---
name: test-runner
description: Run tests, analyze failures, and apply fixes. Supports Jest, Vitest, pytest, cargo test, go test.
user-invokable: true
---

# test-runner

When to use: Test execution, failure debugging, coverage improvement.

## Step 1: Framework Detection

Check for package.json (Jest/Vitest), pyproject.toml (pytest), Cargo.toml, go.mod.

## Step 2: Execute Tests

```bash
npm test -- --passWithNoTests 2>&1 | tail -50
python -m pytest -v 2>&1 | tail -50
cargo test 2>&1 | tail -50
go test ./... 2>&1 | tail -50
```

## Step 3: Failure Analysis

1. **Production code bug** → Fix production code
2. **Test code bug** → Update test for spec changes
3. **Environment issue** → Check configuration
4. **Flaky test** → Investigate non-determinism

## TDD Pattern (AAA)

```typescript
it('should [expected behavior]', () => {
  // Arrange — setup
  // Act — execute
  // Assert — verify
});
```
