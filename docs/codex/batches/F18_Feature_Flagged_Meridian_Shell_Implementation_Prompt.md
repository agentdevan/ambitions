# F18 Feature-Flagged Meridian Shell Implementation Prompt

Status: Blocked until F17 Green
Train: F17-F30 FAANG Handoff Completion Train

Only run if F17 produced a Green architecture and ownership plan.

Scope:

- implement Meridian shell behind a feature flag or reversible configuration
- preserve native fallback navigation
- preserve top-level destination access
- preserve accessibility
- do not remove existing routes unless F17 explicitly allowed it
- no broad product behavior changes

Validate:

```bash
scripts/build-local.sh
scripts/batch-train-gate-check.sh || true
scripts/swiftui-architecture-scan.sh || true
git diff --check
```

Add focused shell/route tests required by the F17 report. Stop Yellow/Red if route parity, fallback, accessibility, or validation is ambiguous.
