# Codex Quality System Script Map
<!-- markdownlint-disable MD013 -->

Status: Active CQS script map
Date: 2026-05-05

All CQS scripts are advisory by default. Set `CQS_STRICT=1` to make a matching
scan exit nonzero. Scripts must not delete, rewrite, stage, commit, or mutate
production files.

| Script | Purpose |
| --- | --- |
| `scripts/cqs-prompt-built-smell-scan.sh` | Generic names, TODO/FIXME/stub residue, unsupported AI copy, overused helpers/managers/coordinators. |
| `scripts/cqs-architecture-boundary-scan.sh` | Domain/view/service dependency direction, preview leakage, mega-files, shared primitive sprawl. |
| `scripts/cqs-product-drift-scan.sh` | Dashboard, habit, streak, inbox, notes, chatbot, AI confidence, calendar clone, productivity score. |
| `scripts/cqs-privacy-security-claim-scan.sh` | Secrets, sensitive logging, unsupported privacy/legal/release claims, required-reason and manifest references. |
| `scripts/cqs-accessibility-motion-scan.sh` | Accessibility labels, color-only states, motion-only states, Reduce Motion gaps. |
| `scripts/cqs-preview-coverage-scan.sh` | Preview/screenshot coverage for normal, loading, empty, private, stale, blocked, recovery, overloaded, Reduced Motion, Dynamic Type states. |
| `scripts/cqs-performance-budget-scan.sh` | Expensive effects, broad animation loops, nested scroll risks, observers, widget/Live Activity update abuse. |

Run relevant scripts after focused build/test validation and before commit for
implementation batches. Docs-only batches may run the docs-relevant subset.
