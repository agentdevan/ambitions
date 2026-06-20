# Final Canon Architecture Inventory Gate Expansion

Status: Red for final-tree parity; Yellow as an enforcement slice.

Baseline SHA: `847805a2d8c8bfa422314802f24054290573e7ce`

Scope completed:

- Added `scripts/ambitions-architecture-inventory.py`.
- Expanded `scripts/ambitions-quality-gate.py` to consume the inventory.
- Added script self-tests for the inventory and quality gate enforcement.
- Did not edit `docs/truth`.
- Did not create canonical placeholder source files.
- Did not move production ownership in this slice.

Final-tree parity result:

- `python3 scripts/ambitions-architecture-inventory.py`
- Result: Red.
- Canonical required files: `224`
- Implemented canonical files: `42`
- Missing canonical files: `182`
- Obsolete-owner entries: `493`
- Blocking entries: `675`

Quality gate result:

- `python3 scripts/ambitions-quality-gate.py --max-per-gate 20`
- Result: Red.
- Findings: `748`
- Bounded JSON gates from `python3 scripts/ambitions-quality-gate.py --json`: `final-tree-inventory`, `time-rendering`, `transitional-ownership`.

Tests run:

- `python3 scripts/ambitions-architecture-inventory.py --self-test`
- `python3 scripts/ambitions-quality-gate.py --self-test`
- `python3 scripts/ambitions-architecture-inventory.py`
- `python3 scripts/ambitions-quality-gate.py --max-per-gate 20`
- `python3 scripts/ambitions-quality-gate.py --json`
- `python3 scripts/ambitions-architecture-inventory.py --json`
- `git diff --check`

Tests not run:

- Xcode build/test was not run for this enforcement-only slice because no production Swift app source changed.
- Screenshot/accessibility proof was not run because no UI behavior changed.

Remaining missing paths:

- Full list is machine-readable from `python3 scripts/ambitions-architecture-inventory.py --json`.
- First blockers include `App/AmbitionsRootScene.swift`, `App/AmbitionsStageHost.swift`, `Stage/AmbitionsStage.swift`, `Stage/StageAction.swift`, `Stage/StageReducer.swift`, and canonical `Core`, `Projection`, `Language`, `Trust`, `Interaction`, `Rendering`, `DesignSystem`, `Surfaces`, `Composer`, `Scenarios`, `Diagnostics`, and `Quality` files.

Remaining obsolete paths:

- Full list is machine-readable from `python3 scripts/ambitions-architecture-inventory.py --json`.
- Current obsolete-owner groups include non-final production ownership under `Native/Ambitions/Domain`, `Native/Ambitions/Runtime`, `Native/Ambitions/Services`, `Native/Ambitions/UI`, `Native/Ambitions/Persistence`, `Native/Ambitions/ExternalSnapshots`, `Native/Ambitions/AppIntents`, `Native/Ambitions/Integrations`, `Native/Ambitions/Notifications`, and source files with transitional ownership terms.

Known risks:

- The expanded gate intentionally makes the repo Red until real final-tree ownership migration is performed.
- Some transitional-term hits may be legitimate domain words and need migration-time review, not blanket text deletion.
- The inventory detects path and ownership status; it does not prove product completeness.

Rollback plan:

- Revert this slice to restore the previous partial quality gate.

Next bounded train:

- Migrate App and Stage root ownership: `AmbitionsRootScene`, `AmbitionsStageHost`, `AmbitionsStage`, `AmbitionsSurface`, `StageState`, `StageAction`, `StageReducer`, `StageStore`, `StageRoute`, `StageOverlay`, and chrome/safe-area policy owners, then delete or rewrite old root owners that remain.
