# Program Registry v2

Status: Active Codex OS v2 registry
Authority: Active process registry, subordinate to `docs/truth/*`

This is the single active program registry. It extends the existing Codex OS and does not create a parallel OS. Goal Mode is default for new Ambitions autonomous work. The historical runner is used only when an active issue explicitly requests it.

## UIQL - Flagship UI Quality Lockdown

- Program: UIQL
- Name: Flagship UI Quality Lockdown
- Status: active-ready
- Owner: Product/Design + iOS Frontend
- Active Linear project if known: Ambitions Flagship UI Quality Lockdown
- Allowed scope: UI quality governance, visual/accessibility proof process, copy/anatomy/shell scans
- Forbidden scope: Runtime work, dependencies, release claims
- Goal file: artifacts/ui-quality-lockdown/UIQL_GOAL.md
- Run-state file: artifacts/ui-quality-lockdown/UIQL-run-state.md
- Skill path: .agents/skills/uiql-quality-lockdown/SKILL.md
- Scripts: uiql-preflight.sh; uiql-mini-regression.sh; program-preflight uiql
- Reviewer board: visual/accessibility + spec + repo hygiene
- Hard Red gates: Product Yellow; Capture tab; Plan/Pulse active top-level; screenshot path as proof
- Allowed Yellow types: Tooling gaps and manual/device proof gaps
- Goal Mode policy: Goal Mode default; main only; no runner header
- Next runnable gate: UIQL-001 preflight
- Repair/reframe: extend this entry; do not create a second registry or duplicate adapter.
- Rollback/failure: stop and repair registry conflicts before execution.
- Linear closeout: cite program, issue, push hash, validation, proof paths, non-claims, and next gate.

## PLOS - Personal Life OS Runtime Master Build

- Program: PLOS
- Name: Personal Life OS Runtime Master Build
- Status: active-ready
- Owner: Runtime/Product Architecture
- Active Linear project if known: unknown
- Allowed scope: Private Life Runtime phase gates and golden-slice proof governance
- Forbidden scope: Runtime expansion before M00/M01/M10; cloud LLM core path; private data in R2
- Goal file: artifacts/plos-runtime/PLOS_GOAL.md
- Run-state file: artifacts/plos-runtime/PLOS-run-state.md
- Skill path: .agents/skills/plos-runtime-master-build/SKILL.md
- Scripts: plos-preflight.sh; plos-phase-gate.sh; program-phase-gate plos
- Reviewer board: privacy/local-first + architecture + QA + release believability
- Hard Red gates: Cloud LLM core; private data in R2; high-risk path without review
- Allowed Yellow types: Phase not reached or external proof unavailable
- Goal Mode policy: Goal Mode default; phase-by-phase
- Next runnable gate: PLOS-M00 governance
- Repair/reframe: extend this entry; do not create a second registry or duplicate adapter.
- Rollback/failure: stop and repair registry conflicts before execution.
- Linear closeout: cite program, issue, push hash, validation, proof paths, non-claims, and next gate.

## SAF - Source Atlas Factory

- Program: SAF
- Name: Source Atlas Factory
- Status: active-ready
- Owner: Source Atlas/Runtime Data Boundary
- Active Linear project if known: unknown
- Allowed scope: Wrap/govern existing Source Atlas scripts/tools/runtime and pack/seed gates
- Forbidden scope: Duplicate Source Atlas implementation; private user data in R2
- Goal file: artifacts/source-atlas-factory/SAF_GOAL.md
- Run-state file: artifacts/source-atlas-factory/SAF-run-state.md
- Skill path: .agents/skills/source-atlas-factory/SKILL.md
- Scripts: saf-preflight.sh; saf-pack-gate.sh; program-preflight source-atlas
- Reviewer board: source-atlas + privacy/local-first + QA
- Hard Red gates: Runtime-eligible pack without source/freshness/revocation
- Allowed Yellow types: Missing pack proof or external release receipt
- Goal Mode policy: Goal Mode default; source-atlas alias supported
- Next runnable gate: SAF-M00 preflight
- Repair/reframe: extend this entry; do not create a second registry or duplicate adapter.
- Rollback/failure: stop and repair registry conflicts before execution.
- Linear closeout: cite program, issue, push hash, validation, proof paths, non-claims, and next gate.

## PRIVACY - Data Boundary / Local-First / CloudKit / R2

- Program: PRIVACY
- Name: Data Boundary / Local-First / CloudKit / R2
- Status: registry-ready
- Owner: Privacy/Architecture
- Active Linear project if known: unknown
- Allowed scope: Privacy boundary audits, local-first proof, CloudKit/R2 classification
- Forbidden scope: Legal approval claims, telemetry, dependency installs
- Goal file: artifacts/privacy/PRIVACY_GOAL.md
- Run-state file: artifacts/privacy/PRIVACY-run-state.md
- Skill path: .agents/skills/ambitions-privacy-local-first/SKILL.md
- Scripts: program-preflight privacy
- Reviewer board: privacy/local-first + release believability
- Hard Red gates: Personal backend, telemetry, cloud LLM core, R2 personal data
- Allowed Yellow types: Manual legal/privacy signoff unavailable
- Goal Mode policy: Goal Mode default
- Next runnable gate: Install dedicated adapter when active issue opens
- Repair/reframe: extend this entry; do not create a second registry or duplicate adapter.
- Rollback/failure: stop and repair registry conflicts before execution.
- Linear closeout: cite program, issue, push hash, validation, proof paths, non-claims, and next gate.

## QA - Certification Gauntlets

- Program: QA
- Name: Certification Gauntlets
- Status: registry-ready
- Owner: QA/Release
- Active Linear project if known: unknown
- Allowed scope: Validation lanes and gauntlet proof
- Forbidden scope: Release claims, silent baseline updates
- Goal file: artifacts/qa/QA_GOAL.md
- Run-state file: artifacts/qa/QA-run-state.md
- Skill path: .agents/skills/ambitions-ios-quality-gate/SKILL.md
- Scripts: program-preflight qa
- Reviewer board: QA/validation + release believability
- Hard Red gates: Fully tested/release-ready without logs
- Allowed Yellow types: Device/human proof unavailable
- Goal Mode policy: Goal Mode default
- Next runnable gate: Install dedicated adapter when active issue opens
- Repair/reframe: extend this entry; do not create a second registry or duplicate adapter.
- Rollback/failure: stop and repair registry conflicts before execution.
- Linear closeout: cite program, issue, push hash, validation, proof paths, non-claims, and next gate.

## REPO-HYGIENE - Architecture / Sprawl / Cleanup

- Program: REPO-HYGIENE
- Name: Architecture / Sprawl / Cleanup
- Status: registry-ready
- Owner: Repo Governance
- Active Linear project if known: unknown
- Allowed scope: Duplicate authority cleanup, stale classification, path-limited rollback
- Forbidden scope: Deleting history without extraction, broad reset
- Goal file: artifacts/repo-hygiene/REPO-HYGIENE_GOAL.md
- Run-state file: artifacts/repo-hygiene/REPO-HYGIENE-run-state.md
- Skill path: .agents/skills/ambitions-repo-hygiene-rollback/SKILL.md
- Scripts: program-preflight repo-hygiene
- Reviewer board: repo hygiene + architecture/sprawl
- Hard Red gates: Unapproved destructive cleanup; active truth deletion
- Allowed Yellow types: Historical cleanup deferred
- Goal Mode policy: Goal Mode default
- Next runnable gate: Install dedicated adapter when active issue opens
- Repair/reframe: extend this entry; do not create a second registry or duplicate adapter.
- Rollback/failure: stop and repair registry conflicts before execution.
- Linear closeout: cite program, issue, push hash, validation, proof paths, non-claims, and next gate.

## RELEASE - TestFlight / App Review / Evidence

- Program: RELEASE
- Name: TestFlight / App Review / Evidence
- Status: registry-ready
- Owner: Release/QA
- Active Linear project if known: unknown
- Allowed scope: Release evidence firewall and App Review checklist
- Forbidden scope: App Store/TestFlight readiness claims without proof
- Goal file: artifacts/release/RELEASE_GOAL.md
- Run-state file: artifacts/release/RELEASE-run-state.md
- Skill path: .agents/skills/ambitions-release-proof-honesty/SKILL.md
- Scripts: program-preflight release
- Reviewer board: release believability + QA
- Hard Red gates: Release/device/accessibility claims without evidence
- Allowed Yellow types: Human/device/legal proof unavailable
- Goal Mode policy: Goal Mode default
- Next runnable gate: Install dedicated adapter when active issue opens
- Repair/reframe: extend this entry; do not create a second registry or duplicate adapter.
- Rollback/failure: stop and repair registry conflicts before execution.
- Linear closeout: cite program, issue, push hash, validation, proof paths, non-claims, and next gate.

## DESIGN - Product Strategy / Market Definition

- Program: DESIGN
- Name: Product Strategy / Market Definition
- Status: registry-ready
- Owner: Product/Design
- Active Linear project if known: unknown
- Allowed scope: Category framing, anti-drift, product truth governance
- Forbidden scope: Implementation claims and UI feature work without source scope
- Goal file: artifacts/design/DESIGN_GOAL.md
- Run-state file: artifacts/design/DESIGN-run-state.md
- Skill path: .agents/skills/ambitions-source-truth-authority/SKILL.md
- Scripts: program-preflight design
- Reviewer board: spec compliance + visual/accessibility
- Hard Red gates: Commodity category collapse; chatbot/dashboard/calendar/task framing
- Allowed Yellow types: Market positioning needs human review
- Goal Mode policy: Goal Mode default
- Next runnable gate: Install dedicated adapter when active issue opens
- Repair/reframe: extend this entry; do not create a second registry or duplicate adapter.
- Rollback/failure: stop and repair registry conflicts before execution.
- Linear closeout: cite program, issue, push hash, validation, proof paths, non-claims, and next gate.

## CODEX-OS - Program Execution Platform Governance

- Program: CODEX-OS
- Name: Program Execution Platform Governance
- Status: active-ready
- Owner: Codex Process
- Active Linear project if known: AMB-CODEX-OS-V2
- Allowed scope: Goal Mode standards, registry, run-state/proof/script/Linear/reviewer governance
- Forbidden scope: App source changes, runner deletion, release claims
- Goal file: artifacts/codex-os-v2/AMB-CODEX-OS-V2_GOAL.md
- Run-state file: artifacts/codex-os-v2/AMB-CODEX-OS-V2-run-state.md
- Skill path: .agents/skills/ambitions-reviewer-board/SKILL.md
- Scripts: program-preflight codex-os-v2; program-proof-index codex-os-v2
- Reviewer board: all reviewer roles
- Hard Red gates: Parallel OS; runner as active default; app-source mutation; fake Green
- Allowed Yellow types: Existing validator/doctor drift
- Goal Mode policy: Goal Mode default; runner legacy
- Next runnable gate: AMB-CODEX-OS-V2-013 red-team audit
- Repair/reframe: extend this entry; do not create a second registry or duplicate adapter.
- Rollback/failure: stop and repair registry conflicts before execution.
- Linear closeout: cite program, issue, push hash, validation, proof paths, non-claims, and next gate.
