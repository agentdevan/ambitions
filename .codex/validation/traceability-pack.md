# Traceability Pack

## Purpose

Verify that Ambitions implementation, canon, tests, and release claims remain connected.

## Commands

```zsh
rg -n "Canon|primitive|surface|validation|release claim|implemented|tested" docs/codex docs/canon docs/audits
rg -n "accessibilityIdentifier|\\.accessibilityIdentifier|XCUIApplication" Native AmbitionsUITests 2>/dev/null || true
```

## Expected Evidence

- Batch maps to canon, primitive, surface, files, tests, and validation.
- Release wording uses the correct claim state.
- Tests reference stable user promises.

## Failure Interpretation

Missing traceability is a handoff/documentation failure. Misstated release status is a release gate failure.

## Escalation

Escalate to Release Manager and TPM for any release-ready claim without evidence.
