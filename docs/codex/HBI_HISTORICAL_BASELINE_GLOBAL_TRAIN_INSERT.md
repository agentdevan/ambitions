# HBI Historical Baseline Global Train Insert

Status: Active global batch train insert
Date: 2026-05-13
Branch: main

HBI is active Ambitions global-train scope.

Purpose:
- Add a first-class Historical Baseline / Current State train.
- Make Codex pick up the work through the Ambitions runner.
- Prevent the train from being treated as a side proposal.

Required first prompt:

`prompts/batches/HBI00-HISTORICAL-BASELINE-ACTIVE-TRAIN-01.md`

Required first command:

```bash
scripts/ambitions-codex-train.sh HBI00 prompts/batches/HBI00-HISTORICAL-BASELINE-ACTIVE-TRAIN-01.md
```

Routing:
- HBI00 installs active authority, queue entries, validators, and proof scaffolding.
- HBI01+ implement source, evidence, review, confidence, current-state, runtime-inspection, export, and release-evidence work in scoped batches.
- HBI must not claim production completion until source, tests, and proof artifacts exist.

Placement:
- HBI is active before any final market-leading, release-readiness, or product-completeness claim.
- HBI may run after current data-control and intelligence-boundary prerequisites, or earlier as docs/control-plane setup when no production source files are touched.

Hard stops:
- No direct Codex execution unless explicitly bypassed by the user.
- No source crawling behavior.
- No automatic active-goal creation from imports.
- No cloud AI dependency in core Historical Baseline behavior.
- No release, privacy, accessibility, sync, App Store, or device claim without current proof.
