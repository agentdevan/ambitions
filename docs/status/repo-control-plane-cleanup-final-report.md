# Repo Control-Plane Cleanup Final Report

Status: Phase 0 Green with accepted Yellow items
Date: 2026-05-10
Scope: Phase 0 preflight only

## Executive Status

Phase 0 completed after pulling the latest `origin/main` state.

The repo now contains the required `docs/truth/*` authority package, and the primary front doors route through it. Phase 0B and later cleanup phases were not started because the requested run said to begin with Phase 0 only.

Accepted Yellow items:

- The worktree was already dirty before this pass, including modified app/source files and untracked screenshot audit material. This pass did not touch app runtime/source files.
- `docs/audits/tracked-files.txt` still contains historical paths for deleted provider skills. Current status docs already record the provider deletion, so this is a stale inventory item for a later cleanup ledger pass.
- Large train/control-plane files exist and should be classified through existing override policy before any rewrite, move, archive, or delete action.
- The local Ambitions Repo MCP still reports an older source-truth stack that does not include `docs/truth/*`; MCP output was treated as a repo-derived aid, not authority.

## Pull / Repo State

- Branch: `main`
- Starting HEAD: `d21f9dfc1eac2a2f907c15359e5cae14055696d0`
- Updated HEAD: `3b8fdc3d38a5cdce3001c8d6f1af9f2b5b317128`
- Upstream status after pull: `0 0` for `HEAD...origin/main`
- Pull result: fast-forward from `origin/main`
- Working tree after pull: dirty from pre-existing app/source changes and untracked audit/report paths

Pre-existing dirty paths observed and intentionally not touched:

- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/Ambitions/Features/Captures/CaptureAtmosphereComposer.swift`
- `Native/Ambitions/Features/Captures/CapturesScreen.swift`
- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/Ambitions/Features/Plan/PlanScreen.swift`
- `Native/Ambitions/Features/Profile/ProfileRootSurface.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Sources/Components/PersonalSystemCenterPrimitives.swift`
- `docs/audits/screenshots/`

## Mandatory Read-Order Files

All required Phase 0 read-order files exist in the post-pull checkout:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `README.md`
- `docs/README.md`
- `AGENTS.md`
- `.codex/README.md`
- `docs/codex/CODEX_OS_INDEX.md`
- `docs/status/current-implementation-map.md`
- `docs/status/release-evidence-packet.md`
- `docs/status/cleanup-decision-register.md`
- `docs/status/codex-agents-skill-inventory.md`
- `docs/status/reference-dependency-scan-cleanup-plan.md`
- `docs/status/quarantine-archive-folder-plan.md`
- `docs/status/large-doc-classification-overrides.md`
- `docs/status/historical-header-pass-audit.md`
- `.codex/manifests/skills-routing-map.yml`

## Front Door Check

Checked:

- `README.md`
- `docs/README.md`
- `AGENTS.md`
- `.codex/README.md`
- `docs/codex/CODEX_OS_INDEX.md`

Finding:

- These front doors exist.
- They route active authority to `docs/truth/README.md` and the truth files.
- They state that they are not implementation proof, validation proof, or release proof.
- They preserve `docs/truth/*` as the conflict winner.

Phase 0 front-door gate: Green.

## Provider / Backend Preflight

Active provider skill path checks:

- `.agents/skills/supabase/`: absent
- `.agents/skills/supabase-postgres-best-practices/`: absent
- `scripts/t07c-provider-skill-quarantine-move.sh`: absent

Stale provider inventory check:

- `docs/audits/tracked-files.txt` still lists deleted provider skill paths.
- `docs/status/cleanup-decision-register.md` records `.agents/skills/supabase/` and `.agents/skills/supabase-postgres-best-practices/` as deleted from active skill paths.
- `docs/status/codex-agents-skill-inventory.md` records the same provider deletion and says not to recreate without explicit approval.
- `.codex/manifests/skills-routing-map.yml` lists both provider roots as forbidden skill roots.

Provider/backend gate: Green for active path deletion, Yellow for stale historical inventory cleanup.

## Batch Train / Train-State Visibility

Visible active state and current-run files include:

- `.codex/state/active-batch.yml`
- `.codex/state/active-repair.yml`
- `.codex/state/hard-red-ledger.md`
- `.codex/state/yellow-ledger.md`
- `.codex/state/repair-ledger.md`
- `.codex/reports/current-batch-train-state.md`
- `.codex/reports/current-run-state.md`

Ambitions Repo MCP reported:

- Current batch: `PK13 Restore Rollback`
- Next eligible batch: `PK14 Durable Command/Event Ledger`
- Previous batch: `PK12 Staged Portable Import Dry Run`
- Previous result: `Green`
- Train: `Global full-stack execution`
- EFC overlay active: true

MCP caveat:

- The MCP `get_source_truth_stack` output still names the older front-door stack and does not include `docs/truth/*`. Treat this as a tooling freshness gap for later cleanup, not as authority.

## Discovered Train Families

The `docs/codex/batch-trains/` directory contains visible train files for these families:

- AOS
- CQS
- CS
- DAV
- EB
- EFC
- F03.5
- F04-F30 family trains
- FCP
- FET
- FL
- HPS
- LDI
- ME
- PD
- PFC
- PK
- PX
- REC
- RHC
- SA
- SI
- SIG

Additional global/model/tooling train/control-plane files are visible under `docs/codex/`, `.codex/state/`, `.codex/reports/`, `.codex/manifests/`, `.codex/templates/`, `.codex/context-packs/`, `.codex/skills/`, `scripts/`, and `tools/mcp/`.

No train family was fully classified in Phase 0. That belongs to Phase 0B and Phase 4.

## Nested AGENTS Visibility

Visible `AGENTS.md` overlays:

- `AGENTS.md`
- `docs/AGENTS.md`
- `Native/Ambitions/App/AGENTS.md`
- `Native/Ambitions/Domain/AGENTS.md`
- `Native/Ambitions/Features/AGENTS.md`

No nested overlay was modified in Phase 0.

## Work Intentionally Not Done

Not run in Phase 0:

- Phase 0B operating-system component discovery
- Phase 1 Codex Operating System creation
- archive/delete/move operations
- app source edits
- SwiftUI redesign or runtime behavior changes
- `xcodegen generate`
- Xcode build/test
- source validation
- markdown/link checker
- docs QA script

## Validation Run

Commands/tools run:

- `git status --short --branch`
- `git rev-parse --abbrev-ref HEAD`
- `git rev-parse HEAD`
- `git fetch origin --prune`
- `git rev-list --left-right --count HEAD...origin/main`
- `git pull --ff-only`
- required-file existence checks
- front-door truth-routing search with `rg`
- provider path checks
- provider stale-reference checks in `docs/audits/tracked-files.txt`
- train/control-plane file listing with `find` and `rg`
- nested `AGENTS.md` discovery with `find`
- Ambitions Repo MCP: `get_source_truth_stack`
- Ambitions Repo MCP: `summarize_repo_posture`
- Ambitions Repo MCP: `get_efc_overlay_status`
- Ambitions Repo MCP: `get_active_batch`

## Validation Not Run

- `scripts/run-doc-qa.sh`
- markdown link check
- Xcode build/test
- simulator validation
- archive validation
- MCP self-tests
- app accessibility/performance/privacy validation

## Hard Claims Not Made

This report does not claim:

- app implementation completion
- app build success
- test success
- release readiness
- TestFlight readiness
- App Store readiness
- physical-device validation
- accessibility conformance
- performance proof
- legal/privacy approval
- hosted CI proof

## Phase 0 Gate Result

Phase 0 result: Green with accepted Yellow items.

Green basis:

- Latest `origin/main` was pulled by fast-forward.
- Required truth files exist.
- Required front doors route to `docs/truth/*`.
- Current provider skill roots are absent from active `.agents/skills/` paths.
- Current cleanup/status docs record provider deletion.

Accepted Yellow basis:

- Dirty app/source files pre-existed and were not touched.
- Stale provider references remain in `docs/audits/tracked-files.txt`.
- Large control-plane/train files require later override-aware classification.
- MCP source-truth-stack output lags the new `docs/truth/*` hierarchy.

## Next Exact Prompt

```text
Continue the Ambitions repo-control-plane cleanup with Phase 0B only.
Use the post-pull repo state at HEAD 3b8fdc3d38a5cdce3001c8d6f1af9f2b5b317128.
Preserve the pre-existing dirty app/source files and do not implement app features.
Classify Codex OS component families across authority, state, skills, trains, gates, tools, evidence, and resume material.
Do not continue to Phase 1 unless Phase 0B is Green or accepted Yellow with reason.
```
