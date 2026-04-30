# Accessibility QA Pack

## Purpose

Validate accessibility-sensitive changes.

## Commands

```bash
scripts/build-local.sh || true
rg -n "accessibilityIdentifier|accessibilityLabel|accessibilityHint|accessibilityValue" Native Sources AppUI || true
```

## Evidence

Identifiers, labels, Dynamic Type/Reduce Motion notes, manual proof status.
