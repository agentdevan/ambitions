# UFP implementation tasks

All paths are planned targets and must be rebased to final bytes before edit.
The sole operational ledger is
`/Users/devan/.codex/output/Ambitions_Maximum_Polish_Program/PROGRAM.json`.

## UFP-0 — Consolidate program controls

### 1. UFP-0.1 Consolidate authority, lifecycle, ledger, and workflow controls

- Files: sole outside-repository ledger; this packet; `project.yml`; `Packages/AmbitionsPresentation/Package.swift`.
- Depends on: approved Design.
- Acceptance: ledger records exact UFP-0…UFP-8 meaning, independent approvals, canonical boundary, and zero-legacy contract; no repo ledger exists.
- Tests/proof: tracker schema/check and repository shadow-ledger/reference check.
- Frontend: affected — REQ-001, REQ-002, REQ-003; Visual gate: not-required (program controls only).

### 2. UFP-0.2 Establish final-byte component, target, and legacy controls

- Files: `project.yml`, `Packages/AmbitionsPresentation/Package.swift`, `Native/Ambitions/`, `Native/AmbitionsNativeFoundryHost/`, `Packages/AmbitionsPresentation/Sources/`; ledger artifacts only.
- Depends on: UFP-0.1.
- Acceptance: controls distinguish canonical candidates, Foundry, production, tests, extensions, previews, assets, wrappers, and legacy without promoting anything.
- Tests/proof: final-byte path/import/target manifest and Foundry production-edge scan.
- Frontend: affected — REQ-004, REQ-010, REQ-015; Visual gate: not-required (control baseline only).

## UFP-1 — Finish primary directions

### 3. UFP-1.1 Retain Today R04 D-129 as primary-direction evidence

- Files: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/Today*`, Foundry host/tests, ledger evidence links.
- Depends on: UFP-0.2.
- Acceptance: Today R04 D-129 remains bounded approved direction; its proof ceiling is not expanded to runtime, cutover, device, or release.
- Tests/proof: current fixture state/unit/UI/accessibility evidence and owner-decision linkage.
- Frontend: affected — REQ-005, REQ-006, REQ-016, REQ-017; Visual gate: approved (bounded Today direction only).

### 4. UFP-1.2 Complete Time as the next primary direction

- Files: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/Time*`, `Native/AmbitionsNativeFoundryHost/TimeNativeFoundryHost.swift`, associated tests/evidence.
- Depends on: UFP-1.1.
- Acceptance: Time completes current research, audit, exploration, five passes, P01–P15, and one owner-review direction while retaining native/local-state truth.
- Tests/proof: fixture/unit/UI, Dynamic Type/VoiceOver/RTL/contrast variants, explicit owner decision/proof ceiling.
- Frontend: affected — REQ-005, REQ-006, REQ-007, REQ-016, REQ-017; Visual gate: required.

## UFP-2 — Complete fixture coverage

### 5. UFP-2.1 Define and close the 47-screen/system-surface matrix

- Files: Foundry fixture contracts, all Foundry surface fixtures/hosts/tests, sole-ledger coverage artifact.
- Depends on: UFP-1.2.
- Acceptance: exactly 47 screens/system surfaces have accountable typical, dense, very-dense, Light, Dark, keyboard, localization, RTL, accessibility, failure, and restoration coverage where applicable.
- Tests/proof: coverage schema/count check and deterministic fixture-key test matrix.
- Frontend: affected — REQ-005, REQ-014, REQ-016, REQ-017; Visual gate: required.

### 6. UFP-2.2 Render and review the full matrix without source promotion

- Files: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/`, Foundry host/UI tests, fixture artifacts.
- Depends on: UFP-2.1.
- Acceptance: all 47 entries render deterministically with cross-root return; gaps are recorded rather than silently excluded.
- Tests/proof: host journeys, screenshot geometry/copy comparisons, accessibility transformation matrix, coverage review.
- Frontend: affected — REQ-004, REQ-005, REQ-014, REQ-017; Visual gate: required.

## UFP-3 — Unified system and grammar

### 7. UFP-3.1 Derive shared design-system and cross-root grammar

- Files: approved fixture candidates in Contracts/Foundation/UI planning paths, Foundry fixtures, ledger grammar artifacts.
- Depends on: UFP-2.2.
- Acceptance: shared components derive only from repeated approved consumer semantics, state, accessibility, and lifecycle; native substrate/hard-kill rules persist.
- Tests/proof: consumer-to-grammar traceability, semantic/accessibility/motion/asset policy review.
- Frontend: affected — REQ-007, REQ-008, REQ-009, REQ-016, REQ-017; Visual gate: required.

### 8. UFP-3.2 Gain owner approval for unified design system and grammar

- Files: UFP-3 grammar artifact, full matrix evidence, sole-ledger decision.
- Depends on: UFP-3.1.
- Acceptance: owner approves one system/grammar direction; no component-level approval is claimed as complete-frontend approval.
- Tests/proof: hard-kill/taste review, cross-root evidence review, explicit owner decision/proof ceiling.
- Frontend: affected — REQ-005, REQ-007, REQ-008, REQ-016; Visual gate: required.

## UFP-4 — Canonical component source

### 9. UFP-4.1 Assign one disposition to every component

- Files: UFP-0 inventory and all source/asset/target/wrapper paths; ledger disposition artifact.
- Depends on: UFP-3.2.
- Acceptance: every in-scope component is exactly `promote`, `rebuild`, `fixture-only`, `historical`, or `delete`, with owner, replacement, dependency, proof, and delete/retention condition.
- Tests/proof: one-of schema, final-byte source/asset/target reconciliation, owner disposition review.
- Frontend: affected — REQ-008, REQ-010, REQ-011, REQ-015; Visual gate: approved.

### 10. UFP-4.2 Establish canonical Contracts/Foundation/UI source

- Files: `Packages/AmbitionsPresentation/Package.swift`, `Sources/AmbitionsPresentationContracts/FlagshipContracts.swift`, `Sources/AmbitionsFlagshipFoundation/FlagshipSemanticTokens.swift`, `Sources/AmbitionsFlagshipUI/FlagshipShell.swift` or approved replacements.
- Depends on: UFP-4.1.
- Acceptance: one canonical UI source follows Contracts/Foundation/UI rules; Foundry and production adapters render it without Foundry/runtime/legacy-design-system UI imports.
- Tests/proof: package build/test, public API/Sendable review, import-cycle and forbidden-edge scans.
- Frontend: affected — REQ-004, REQ-007, REQ-008, REQ-010; Visual gate: approved.

## UFP-5 — Complete fixture frontend

### 11. UFP-5.1 Complete canonical fixture frontend through synthetic adapters

- Files: UFP-4 canonical source, Foundry synthetic adapters/hosts/tests, all 47 fixture entries.
- Depends on: UFP-4.2.
- Acceptance: Foundry renders source-identical canonical UI through synthetic adapters for each matrix screen/state; production wiring and redesign remain absent.
- Tests/proof: source-identity/import scan and full fixture matrix/unit/UI/accessibility evidence.
- Frontend: affected — REQ-004, REQ-005, REQ-010, REQ-014, REQ-017; Visual gate: required.

### 12. UFP-5.2 Obtain complete fixture-frontend owner approval

- Files: full fixture frontend evidence and ledger approval fields/artifacts.
- Depends on: UFP-5.1.
- Acceptance: owner explicitly approves the entire fixture-driven frontend and `approvals.frontend_design` is true; runtime integration remains independently unapproved until its own gate.
- Tests/proof: final matrix review, explicit approval, `frontend-complete` tracker gate.
- Frontend: affected — REQ-005, REQ-016, REQ-017; Visual gate: required.

## UFP-6 — Runtime integration

### 13. UFP-6.1 Runtime-integrate Today first

- Files: UFP-4 canonical source, Today app/runtime/projection/composition paths identified from final bytes, focused tests.
- Depends on: UFP-5.2 and independent runtime-integration approval.
- Acceptance: Today consumes real local projections and typed intents; persistence, replay, idempotency, revisions, receipts, recovery, and restoration remain runtime-owned.
- Tests/proof: unit/integration/UI, migration/replay/restore, privacy/offline, Simulator visual, physical-device sample.
- Frontend: affected — REQ-010, REQ-012, REQ-013, REQ-014, REQ-016, REQ-017; Visual gate: required.

### 14. UFP-6.2 Runtime-integrate remaining production vertical slices

- Files: canonical source plus final-byte owners for Goals, Time, You, Search, Capture, shell, receipts, recovery, extensions/previews, `Native/Ambitions/Surfaces/`, `Composer/`, and `Core/LocalRuntimeOS/`.
- Depends on: UFP-6.1.
- Acceptance: all routes use canonical views and real runtime adapters without duplicate route/state/mutation authority or Foundry/legacy UI ownership.
- Tests/proof: per-surface integration/UI/accessibility/privacy/recovery/restoration tests and physical-device samples.
- Frontend: affected — REQ-007, REQ-010, REQ-012, REQ-013, REQ-014, REQ-016, REQ-017; Visual gate: required.

## UFP-7 — Atomic cutover and zero legacy

### 15. UFP-7.1 Perform atomic cutover and delete all legacy frontend

- Files: every UFP-4 `delete` row—legacy source/components, dependencies, package products/targets, XcodeGen entries, assets, wrappers, routes, previews, UI tests, flags, test helpers, resources, and live references; retained research/evidence excluded.
- Depends on: UFP-6.2 plus production-cutover and legacy-deletion approvals.
- Acceptance: one cutover occurs; final bytes show zero legacy frontend files, dependencies, targets, assets, wrappers, routes, previews, UI tests, flags, or live references; no dual renderer ships.
- Tests/proof: no-reference scans, target/package/asset resolution, clean builds/tests, replacement parity, rollback rehearsal, `cutover` tracker gate.
- Frontend: affected — REQ-015, REQ-018; Visual gate: required.

## UFP-8 — Release closure

### 16. UFP-8.1 Close physical-device, accessibility, performance, privacy, localization, migration, and release proof

- Files: final production app/extension/package configuration, localization catalogs, migration/replay tests, privacy artifacts, performance/device evidence, ledger release artifacts.
- Depends on: UFP-7.1.
- Acceptance: physical-device/manual accessibility/performance/privacy/energy/localization/migration evidence is complete, zero-legacy proof remains valid, and owner explicitly approves release.
- Tests/proof: release archive, physical-iPhone final run, assistive-tech matrix, performance/energy observation, privacy/migration validation, `release` tracker gate.
- Frontend: affected — REQ-016, REQ-017, REQ-018; Visual gate: required.
