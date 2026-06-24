# SCG-007 Repair Trains

Issue: `AMB-1290 / SCG-007`
Branch: `main`
Generated: `2026-06-24T01:24:55+00:00`
Status: `Green - planning artifacts only`

This artifact converts SCG-001 through SCG-006 evidence into dependency-ordered repair trains. It does not start SCG-007A, does not start SCG-008, does not repair production code, does not mark any flow/file Green, and does not claim senior-readiness.

## Summary

- Repair trains: `13`
- Root causes mapped: `10`
- Root causes unmapped: `0`
- SCG-007A required before SCG-008: `yes`
- Known-issues updates in SCG-007: `0`
- Production behavior changed: `no`
- SCG-BG-001: `preserved resolved`

## Dependency Order

1. `SCG-007A` - Control-plane schema and stale-review hardening gate
2. `SCG-007B` - Ownership/layer unknowns and inventory hygiene
3. `SCG-007C` - Runtime action, proof, mutation, and undo contract hardening
4. `SCG-007D` - Capture global composer save, keyboard, proposal, and receipt hardening
5. `SCG-007E` - Goals creation to Today Start here coupling hardening
6. `SCG-007F` - Time Life Calendar mutation, Today recompute, and permission fallback hardening
7. `SCG-007G` - Search and inspection local Find / Act / Inspect proof hardening
8. `SCG-007H` - Surface/root UI copy and forbidden-language exposure hardening
9. `SCG-007I` - SwiftUI composition, shell geometry, and design-token hardening
10. `SCG-007J` - Accessibility and static interaction proof hardening
11. `SCG-007K` - Privacy, local-first, offline/no-account, and diagnostics proof hardening
12. `SCG-007L` - Test-strength and 16-flow behavior-proof closure
13. `SCG-007M` - Visual/device proof readiness gate

## Train Matrix

| Order | Train | Severity | Root causes | Depends on | Blocks | Affected flows |
|---:|---|---|---|---|---|---|
| 1 | `SCG-007A` Control-plane schema and stale-review hardening gate | B3 | RC-SCG006-008 | none | SCG-007B, SCG-007C, SCG-007D, SCG-007E, SCG-007F, SCG-007G, SCG-007H, SCG-007I, SCG-007J, SCG-007K, SCG-007L, SCG-007M | SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16 |
| 2 | `SCG-007B` Ownership/layer unknowns and inventory hygiene | B3 | RC-SCG006-008 | SCG-007A | SCG-007C, SCG-007D, SCG-007E, SCG-007F, SCG-007G, SCG-007H, SCG-007I, SCG-007J, SCG-007K, SCG-007L, SCG-007M | SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16 |
| 3 | `SCG-007C` Runtime action, proof, mutation, and undo contract hardening | B3 | RC-SCG006-001, RC-SCG006-004, RC-SCG006-007 | SCG-007A, SCG-007B | SCG-007D, SCG-007E, SCG-007F, SCG-007G, SCG-007L, SCG-007M | SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16 |
| 4 | `SCG-007D` Capture global composer save, keyboard, proposal, and receipt hardening | B4 | RC-SCG006-002, RC-SCG006-001, RC-SCG006-010 | SCG-007A, SCG-007B, SCG-007C | SCG-007L, SCG-007M | SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F12, SCG006-F01, SCG006-F02, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16 |
| 5 | `SCG-007E` Goals creation to Today Start here coupling hardening | B3 | RC-SCG006-003, RC-SCG006-004, RC-SCG006-001 | SCG-007A, SCG-007B, SCG-007C | SCG-007L, SCG-007M | SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F13, SCG006-F08, SCG006-F09, SCG006-F14, SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F15, SCG006-F16 |
| 6 | `SCG-007F` Time Life Calendar mutation, Today recompute, and permission fallback hardening | B3 | RC-SCG006-005, RC-SCG006-007, RC-SCG006-009, RC-SCG006-001 | SCG-007A, SCG-007B, SCG-007C | SCG-007L, SCG-007M | SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F14, SCG006-F16, SCG006-F08, SCG006-F15, SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F12, SCG006-F13 |
| 7 | `SCG-007G` Search and inspection local Find / Act / Inspect proof hardening | B3 | RC-SCG006-006, RC-SCG006-007, RC-SCG006-009, RC-SCG006-001 | SCG-007A, SCG-007B, SCG-007C | SCG-007L, SCG-007M | SCG006-F12, SCG006-F13, SCG006-F08, SCG006-F10, SCG006-F11, SCG006-F14, SCG006-F15, SCG006-F16, SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F09 |
| 8 | `SCG-007H` Surface/root UI copy and forbidden-language exposure hardening | B4 | RC-SCG006-010, RC-SCG006-001 | SCG-007A, SCG-007B | SCG-007I, SCG-007J, SCG-007M | SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F16, SCG006-F15 |
| 9 | `SCG-007I` SwiftUI composition, shell geometry, and design-token hardening | B4 | RC-SCG006-010, RC-SCG006-001 | SCG-007A, SCG-007B, SCG-007H | SCG-007J, SCG-007M | SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F16, SCG006-F15 |
| 10 | `SCG-007J` Accessibility and static interaction proof hardening | B4 | RC-SCG006-010, RC-SCG006-001 | SCG-007A, SCG-007B, SCG-007H, SCG-007I | SCG-007M | SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F16, SCG006-F15 |
| 11 | `SCG-007K` Privacy, local-first, offline/no-account, and diagnostics proof hardening | B3 | RC-SCG006-009, RC-SCG006-001 | SCG-007A, SCG-007B | SCG-007L, SCG-007M | SCG006-F15, SCG006-F16, SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14 |
| 12 | `SCG-007L` Test-strength and 16-flow behavior-proof closure | B4 | RC-SCG006-001, RC-SCG006-002, RC-SCG006-003, RC-SCG006-004, RC-SCG006-005, RC-SCG006-006, RC-SCG006-007, RC-SCG006-008, RC-SCG006-009, RC-SCG006-010 | SCG-007A, SCG-007B, SCG-007C, SCG-007D, SCG-007E, SCG-007F, SCG-007G, SCG-007K | SCG-007M | SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16 |
| 13 | `SCG-007M` Visual/device proof readiness gate | B4 | RC-SCG006-001, RC-SCG006-010 | SCG-007A, SCG-007B, SCG-007C, SCG-007D, SCG-007E, SCG-007F, SCG-007G, SCG-007H, SCG-007I, SCG-007J, SCG-007K, SCG-007L | SCG-008 | SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16 |

## SCG-007A - Control-plane schema and stale-review hardening gate

Problem: SCG inputs remain Yellow because the review-ledger schema is missing and stale-review hardening is not yet enforced before production repair.

- Severity: `B3` `{'B0': 0, 'B1': 0, 'B2': 0, 'B3': 1, 'B4': 0}`
- Root causes addressed: RC-SCG006-008
- Related findings: SCG-004-012
- Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16
- Affected files/layers: Docs, Legacy/Unknown, Quality, SCG control plane
- Blocked by trains: none
- Blocks trains: SCG-007B, SCG-007C, SCG-007D, SCG-007E, SCG-007F, SCG-007G, SCG-007H, SCG-007I, SCG-007J, SCG-007K, SCG-007L, SCG-007M
- Known-issues sync: Required before SCG-008; add known-issues rows only for real Red/B0/B1/B2, otherwise record no new rows.
- Rollback: Revert schema/control-plane artifacts; no production rollback required.

Allowed source paths:
- `docs/quality/senior-review/schemas/`
- `docs/quality/senior-review/`
- `scripts/ambitions-senior-code-audit.py`
- `docs/qa/KNOWN_ISSUES.md only if B0/B1/B2 or dedupe sync requires it`

Forbidden source paths:
- `Native/`
- `Sources/`
- `Packages/`
- `AppUI/`
- `project.yml`
- `Package.swift`
- `Ambitions.xcodeproj/`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`

Scope boundaries:
- Control-plane schema/staleness and known-issues sync only.
- Do not repair production behavior.
- Do not start SCG-008.

Required outputs/tests/proof:
- Output: review_ledger.schema.json or explicit accepted-Yellow waiver
- Output: stale-review gate evidence
- Output: known-issues sync/dedupe report preserving SCG-BG-001 resolved
- Test: JSON/schema validation
- Test: senior audit rerun
- Test: production path diff guard
- Proof: schema validation logs
- Proof: sync/dedupe report
- Proof: path guard output

Visual/device/accessibility/privacy proof:
- visual: not applicable
- device: not applicable
- accessibility: not applicable
- privacy: confirm no runtime privacy behavior changed

Closeout criteria:
- Green: All train-scoped outputs, tests, proof artifacts, known-issues sync, rollback notes, and forbidden-path guards pass. Green is train-scoped only and does not claim senior-readiness, Visual Green, Release Green, Release readiness, app readiness, or unscoped flow/file Green.
- Yellow: Scope is bounded and evidence-backed, but current proof remains missing, manual/device/accessibility proof is absent, or accepted architecture/proof debt is explicitly carried forward with a named next train.
- Red: Any real B0/B1/B2 appears, production behavior changes outside scope, Motion/Capture root drift is introduced, private-life/local-first law is violated, validation cannot run honestly, or status claims exceed proof.

## SCG-007B - Ownership/layer unknowns and inventory hygiene

Problem: Unknown ownership/layer classifications and Yellow inventory risks make downstream production repair unsafe.

- Severity: `B3` `{'B0': 0, 'B1': 0, 'B2': 0, 'B3': 1, 'B4': 0}`
- Root causes addressed: RC-SCG006-008
- Related findings: SCG-004-001, SCG-004-002, SCG-004-003
- Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16
- Affected files/layers: Docs, Legacy/Unknown, Quality, SCG control plane
- Blocked by trains: SCG-007A
- Blocks trains: SCG-007C, SCG-007D, SCG-007E, SCG-007F, SCG-007G, SCG-007H, SCG-007I, SCG-007J, SCG-007K, SCG-007L, SCG-007M
- Known-issues sync: Update KNOWN_ISSUES only if ownership review discovers real Red/B0/B1/B2.
- Rollback: Revert refreshed inventory/ownership files.

Allowed source paths:
- `docs/quality/senior-review/FILE_INVENTORY.*`
- `docs/quality/senior-review/OWNERSHIP_MAP.yaml`
- `docs/quality/senior-review/SENIOR_CODE_REVIEW_*`
- `retained inventory/audit scripts when scoped`

Forbidden source paths:
- `Native/`
- `Sources/`
- `Packages/`
- `AppUI/`
- `project.yml`
- `Package.swift`
- `Ambitions.xcodeproj/`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`

Scope boundaries:
- Classify ownership and layer risks only.
- Do not move or edit production source.
- Do not mark file Green without current owner/proof evidence.

Required outputs/tests/proof:
- Output: refreshed ownership map
- Output: unknown disposition table
- Output: inventory hygiene summary
- Output: ledger update preserving proof limits
- Test: inventory JSON validation
- Test: OWNERSHIP_MAP YAML parse
- Test: senior audit rerun
- Proof: before/after Unknown and Yellow counts
- Proof: sampled owner evidence
- Proof: path guard output

Visual/device/accessibility/privacy proof:
- visual: not applicable
- device: not applicable
- accessibility: not applicable
- privacy: confirm no runtime privacy behavior changed

Closeout criteria:
- Green: All train-scoped outputs, tests, proof artifacts, known-issues sync, rollback notes, and forbidden-path guards pass. Green is train-scoped only and does not claim senior-readiness, Visual Green, Release Green, Release readiness, app readiness, or unscoped flow/file Green.
- Yellow: Scope is bounded and evidence-backed, but current proof remains missing, manual/device/accessibility proof is absent, or accepted architecture/proof debt is explicitly carried forward with a named next train.
- Red: Any real B0/B1/B2 appears, production behavior changes outside scope, Motion/Capture root drift is introduced, private-life/local-first law is violated, validation cannot run honestly, or status claims exceed proof.

## SCG-007C - Runtime action, proof, mutation, and undo contract hardening

Problem: Mutation, proof receipt, accessible state change, and undo are uneven across Today, closure, Time, Capture route changes, and destructive controls.

- Severity: `B3` `{'B0': 0, 'B1': 0, 'B2': 0, 'B3': 3, 'B4': 0}`
- Root causes addressed: RC-SCG006-001, RC-SCG006-004, RC-SCG006-007
- Related findings: SCG-004-004
- Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16
- Affected files/layers: Stage, Composer/Capture, Surfaces/Today, Surfaces/Goals, Surfaces/Time, Trust, Core/Persistence, Core/Permissions, Interaction, Projection/SurfaceLenses, Core/Runtime ClosureEngine, EventLedger, Projection/Mutations, Trust/Receipt, You memory controls
- Blocked by trains: SCG-007A, SCG-007B
- Blocks trains: SCG-007D, SCG-007E, SCG-007F, SCG-007G, SCG-007L, SCG-007M
- Known-issues sync: Update rows only for real B0/B1/B2; otherwise keep Yellow until flow proof.
- Rollback: Revert runtime contract files and tests together.

Allowed source paths:
- `Native/Ambitions/Core/Runtime/`
- `Native/Ambitions/Projection/Mutations/`
- `Native/Ambitions/Trust/`
- `Native/Ambitions/Interaction/`
- `Native/Ambitions/Surfaces/Today/`
- `Native/AmbitionsTests/`

Forbidden source paths:
- `AppUI/`
- `Packages/ unless scoped`
- `project.yml unless scoped`
- `Package.swift`
- `Ambitions.xcodeproj/`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`

Scope boundaries:
- Repair only typed mutation/proof/undo contracts for identified flows.
- No visual restyling.
- Flow Green waits for flow proof.

Required outputs/tests/proof:
- Output: mutation path inventory
- Output: typed proof/receipt/undo contract repairs
- Output: safe fallback behavior
- Test: TodayCommandHandlerTests
- Test: TimeFieldMutationCoordinatorTests
- Test: ClosureRecoveryPrimitiveFamilyTests
- Test: new undo contract tests
- Proof: receipt/proof IDs
- Proof: before/action/after logs
- Proof: rollback notes

Visual/device/accessibility/privacy proof:
- visual: screenshots only when needed to show visible mutation; no Visual Green
- device: deferred to flow/visual proof unless scoped
- accessibility: accessible announcement/state tests required
- privacy: no private data leaves local runtime

Closeout criteria:
- Green: All train-scoped outputs, tests, proof artifacts, known-issues sync, rollback notes, and forbidden-path guards pass. Green is train-scoped only and does not claim senior-readiness, Visual Green, Release Green, Release readiness, app readiness, or unscoped flow/file Green.
- Yellow: Scope is bounded and evidence-backed, but current proof remains missing, manual/device/accessibility proof is absent, or accepted architecture/proof debt is explicitly carried forward with a named next train.
- Red: Any real B0/B1/B2 appears, production behavior changes outside scope, Motion/Capture root drift is introduced, private-life/local-first law is violated, validation cannot run honestly, or status claims exceed proof.

## SCG-007D - Capture global composer save, keyboard, proposal, and receipt hardening

Problem: Capture local save exists in source but remains Yellow for full-screen composer, keyboard focus, proposal/correction, receipt, and device proof.

- Severity: `B4` `{'B0': 0, 'B1': 0, 'B2': 0, 'B3': 2, 'B4': 1}`
- Root causes addressed: RC-SCG006-002, RC-SCG006-001, RC-SCG006-010
- Related findings: SCG-004-004, SCG-004-005, SCG-004-006, SCG-004-008, SCG-004-011, SCG-004-013
- Affected flows: SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F12, SCG006-F01, SCG006-F02, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16
- Affected files/layers: Composer/Capture, Stage overlay, AppShellActivatedCaptureSeam, Core/Runtime CaptureService, Stage, Surfaces/Today, Surfaces/Goals, Surfaces/Time, Trust, Core/Persistence, Core/Permissions, Surfaces/You, Stage/Chrome, DesignSystem
- Blocked by trains: SCG-007A, SCG-007B, SCG-007C
- Blocks trains: SCG-007L, SCG-007M
- Known-issues sync: Reconcile Capture rows; do not close without proof matrix.
- Rollback: Revert Capture/Stage overlay/tests as one scoped set.

Allowed source paths:
- `Native/Ambitions/Composer/Capture/`
- `Native/Ambitions/Stage/`
- `Native/Ambitions/App/Shell*`
- `Native/Ambitions/Core/Runtime/*Capture*`
- `Native/AmbitionsTests/`

Forbidden source paths:
- `Surfaces/Capture/`
- `root Capture tab/routing`
- `Package.swift`
- `Ambitions.xcodeproj/`
- `PrivacyInfo.xcprivacy unless scoped`

Scope boundaries:
- Keep Capture global composer only.
- Repair save/proposal/receipt/keyboard paths only.
- Do not broaden into other surface repairs except handoff assertions.

Required outputs/tests/proof:
- Output: full-screen composer state-machine proof
- Output: local save receipt path
- Output: route correction fallback
- Output: keyboard/focus accessibility behavior
- Test: CaptureViewModelTests
- Test: CaptureRuntimeReceiptTests
- Test: ShellCommandRouterTests
- Test: UI test for blank/focused/proposal/receipt
- Proof: blank/focused/proposal/receipt/correction screenshots
- Proof: test logs
- Proof: known-issues reconciliation

Visual/device/accessibility/privacy proof:
- visual: reviewable screenshots required; no self-certified Visual Green
- device: device or simulator screenshots tied to commit
- accessibility: VoiceOver labels/actions and keyboard fallback
- privacy: local-only/no account or network dependency

Closeout criteria:
- Green: All train-scoped outputs, tests, proof artifacts, known-issues sync, rollback notes, and forbidden-path guards pass. Green is train-scoped only and does not claim senior-readiness, Visual Green, Release Green, Release readiness, app readiness, or unscoped flow/file Green.
- Yellow: Scope is bounded and evidence-backed, but current proof remains missing, manual/device/accessibility proof is absent, or accepted architecture/proof debt is explicitly carried forward with a named next train.
- Red: Any real B0/B1/B2 appears, production behavior changes outside scope, Motion/Capture root drift is introduced, private-life/local-first law is violated, validation cannot run honestly, or status claims exceed proof.

## SCG-007E - Goals creation to Today Start here coupling hardening

Problem: Goal creation to Today feed has focused source/tests, but the runtime/device path from create goal to Recommended step/Start here remains Yellow.

- Severity: `B3` `{'B0': 0, 'B1': 0, 'B2': 0, 'B3': 3, 'B4': 0}`
- Root causes addressed: RC-SCG006-003, RC-SCG006-004, RC-SCG006-001
- Related findings: SCG-004-004, SCG-004-005, SCG-004-011, SCG-004-013
- Affected flows: SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F13, SCG006-F08, SCG006-F09, SCG006-F14, SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F15, SCG006-F16
- Affected files/layers: Surfaces/Goals, Projection/SurfaceLenses, Surfaces/Today, Core/Persistence, Interaction, Core/Runtime ClosureEngine, EventLedger, Stage, Composer/Capture, Surfaces/Time, Trust, Core/Permissions
- Blocked by trains: SCG-007A, SCG-007B, SCG-007C
- Blocks trains: SCG-007L, SCG-007M
- Known-issues sync: Reconcile Goals/Today rows; keep Yellow if visual/device/accessibility proof remains missing.
- Rollback: Revert Goals/Today/runtime tests together.

Allowed source paths:
- `Native/Ambitions/Surfaces/Goals/`
- `Native/Ambitions/Surfaces/Today/`
- `Native/Ambitions/Projection/SurfaceLenses/`
- `Native/Ambitions/Core/Persistence/`
- `Native/AmbitionsTests/`

Forbidden source paths:
- `Surfaces/Capture as top-level`
- `Motion root surface paths`
- `project.yml unless needed`
- `Ambitions.xcodeproj/`

Scope boundaries:
- Repair Create Goal, Goal Detail route, Today feed, and Start here coupling only.
- No broad Goals redesign.
- No Green claim until current runtime proof.

Required outputs/tests/proof:
- Output: create goal runtime path
- Output: Goal detail route evidence
- Output: Today feed recompute evidence
- Output: Goals plus no-crash proof
- Test: CreateGoalViewModelTests
- Test: GoalsShellIntegrationTests
- Test: TodayFreshGoalVisibilityTests
- Test: focused UI route-depth test
- Proof: current flow capture
- Proof: focused logs
- Proof: known-issues reconciliation

Visual/device/accessibility/privacy proof:
- visual: functional screenshots only unless paired with visual train
- device: current proof before closing device rows
- accessibility: Start here/Open step/Start now semantics
- privacy: local persistence only

Closeout criteria:
- Green: All train-scoped outputs, tests, proof artifacts, known-issues sync, rollback notes, and forbidden-path guards pass. Green is train-scoped only and does not claim senior-readiness, Visual Green, Release Green, Release readiness, app readiness, or unscoped flow/file Green.
- Yellow: Scope is bounded and evidence-backed, but current proof remains missing, manual/device/accessibility proof is absent, or accepted architecture/proof debt is explicitly carried forward with a named next train.
- Red: Any real B0/B1/B2 appears, production behavior changes outside scope, Motion/Capture root drift is introduced, private-life/local-first law is violated, validation cannot run honestly, or status claims exceed proof.

## SCG-007F - Time Life Calendar mutation, Today recompute, and permission fallback hardening

Problem: Time remains Yellow for visible placement/protection, injected-clock correctness, Today recompute, permission-denied fallback, and device proof.

- Severity: `B3` `{'B0': 0, 'B1': 0, 'B2': 0, 'B3': 4, 'B4': 0}`
- Root causes addressed: RC-SCG006-005, RC-SCG006-007, RC-SCG006-009, RC-SCG006-001
- Related findings: SCG-004-004, SCG-004-007, SCG-004-010, SCG-004-011, SCG-004-013
- Affected flows: SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F14, SCG006-F16, SCG006-F08, SCG006-F15, SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F12, SCG006-F13
- Affected files/layers: Surfaces/Time, Projection/Mutations, Projection/SurfaceLenses/TodayLens, Core/Runtime ScheduleInstallKernel, Core/Permissions, Core/Runtime ClosureEngine, Trust/Receipt, You memory controls, AppContainerFactory, Core/Persistence, Core/Runtime, Privacy boundary, Stage, Composer/Capture, Surfaces/Today, Surfaces/Goals, Trust
- Blocked by trains: SCG-007A, SCG-007B, SCG-007C
- Blocks trains: SCG-007L, SCG-007M
- Known-issues sync: Reconcile Time rows; keep Yellow if proof is simulator-only or manual accessibility proof absent.
- Rollback: Revert Time/projection/tests together.

Allowed source paths:
- `Native/Ambitions/Surfaces/Time/`
- `Native/Ambitions/Projection/Mutations/`
- `Native/Ambitions/Projection/SurfaceLenses/TodayLens*`
- `Native/Ambitions/Core/Time/`
- `Native/Ambitions/Core/Permissions/`
- `Native/AmbitionsTests/`

Forbidden source paths:
- `external calendar sync as required core behavior`
- `cloud scheduling`
- `Package.swift unless scoped`
- `PrivacyInfo.xcprivacy unless scoped`

Scope boundaries:
- Repair Time placement/protection/correction and Today recompute only.
- No external calendar/cloud sync dependency.
- Permission-denied fallback must be safe and honest.

Required outputs/tests/proof:
- Output: injected-clock cleanup
- Output: real-step-only mutation proof
- Output: Today recompute evidence
- Output: permission-denied fallback evidence
- Test: TimeTodayCouplingTests
- Test: TimeFieldMutationCoordinatorTests
- Test: injected-clock regression tests
- Test: permission-denied fallback tests
- Proof: Time mutation screenshots/video
- Proof: accessibility announcement evidence
- Proof: focused logs

Visual/device/accessibility/privacy proof:
- visual: Time mutation screenshots required; no Visual Green
- device: current proof before closing device rows
- accessibility: VoiceOver values/actions and Reduce Motion fallback
- privacy: no personal calendar upload or private graph path

Closeout criteria:
- Green: All train-scoped outputs, tests, proof artifacts, known-issues sync, rollback notes, and forbidden-path guards pass. Green is train-scoped only and does not claim senior-readiness, Visual Green, Release Green, Release readiness, app readiness, or unscoped flow/file Green.
- Yellow: Scope is bounded and evidence-backed, but current proof remains missing, manual/device/accessibility proof is absent, or accepted architecture/proof debt is explicitly carried forward with a named next train.
- Red: Any real B0/B1/B2 appears, production behavior changes outside scope, Motion/Capture root drift is introduced, private-life/local-first law is violated, validation cannot run honestly, or status claims exceed proof.

## SCG-007G - Search and inspection local Find / Act / Inspect proof hardening

Problem: Search and inspection are local-source-backed but lack current route/device proof for finding, acting, inspecting, and local-only trust boundaries.

- Severity: `B3` `{'B0': 0, 'B1': 0, 'B2': 0, 'B3': 4, 'B4': 0}`
- Root causes addressed: RC-SCG006-006, RC-SCG006-007, RC-SCG006-009, RC-SCG006-001
- Related findings: SCG-004-004, SCG-004-010, SCG-004-011, SCG-004-013
- Affected flows: SCG006-F12, SCG006-F13, SCG006-F08, SCG006-F10, SCG006-F11, SCG006-F14, SCG006-F15, SCG006-F16, SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F09
- Affected files/layers: Core/Runtime MemoryLensService, Stage overlays, ShellCommandRouter, Trust, Projection/Mutations, Core/Runtime ClosureEngine, Trust/Receipt, You memory controls, AppContainerFactory, Core/Persistence, Core/Runtime, Core/Permissions, Privacy boundary, Stage, Composer/Capture, Surfaces/Today, Surfaces/Goals, Surfaces/Time
- Blocked by trains: SCG-007A, SCG-007B, SCG-007C
- Blocks trains: SCG-007L, SCG-007M
- Known-issues sync: Reconcile Search rows; do not close without runtime/device evidence.
- Rollback: Revert Search/Trust/router changes and tests together.

Allowed source paths:
- `Native/Ambitions/Core/Runtime/MemoryLensService*`
- `Native/Ambitions/Stage/`
- `Native/Ambitions/App/ShellCommandRouter*`
- `Native/Ambitions/Trust/`
- `Native/AmbitionsTests/`

Forbidden source paths:
- `cloud search`
- `hosted LLM search`
- `private graph upload`
- `persistent Search root tab`
- `Ambitions.xcodeproj/`

Scope boundaries:
- Repair Search overlay route, result action, inspection handoff, and local-only proof only.
- Do not add network search or chatbot behavior.
- Do not turn Search into a root surface.

Required outputs/tests/proof:
- Output: local index route proof
- Output: typed result action proof
- Output: inspection handoff proof
- Output: privacy/local-only assertion
- Test: MemoryLensServiceTests
- Test: ShellCommandRouterTests
- Test: focused Search overlay UI tests
- Proof: Search overlay screenshots/video
- Proof: route-depth evidence
- Proof: local-index/privacy evidence

Visual/device/accessibility/privacy proof:
- visual: Search screenshots required; no Visual Green
- device: current overlay/result proof
- accessibility: VoiceOver route/result semantics
- privacy: no network/LLM/private data upload

Closeout criteria:
- Green: All train-scoped outputs, tests, proof artifacts, known-issues sync, rollback notes, and forbidden-path guards pass. Green is train-scoped only and does not claim senior-readiness, Visual Green, Release Green, Release readiness, app readiness, or unscoped flow/file Green.
- Yellow: Scope is bounded and evidence-backed, but current proof remains missing, manual/device/accessibility proof is absent, or accepted architecture/proof debt is explicitly carried forward with a named next train.
- Red: Any real B0/B1/B2 appears, production behavior changes outside scope, Motion/Capture root drift is introduced, private-life/local-first law is violated, validation cannot run honestly, or status claims exceed proof.

## SCG-007H - Surface/root UI copy and forbidden-language exposure hardening

Problem: Forbidden/internal language candidates must be gated before root UI release-readiness or visual proof can be accepted.

- Severity: `B4` `{'B0': 0, 'B1': 0, 'B2': 0, 'B3': 1, 'B4': 1}`
- Root causes addressed: RC-SCG006-010, RC-SCG006-001
- Related findings: SCG-004-006
- Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F16, SCG006-F15
- Affected files/layers: Composer/Capture, Surfaces/Goals, Surfaces/You, Stage/Chrome, DesignSystem, Stage, Surfaces/Today, Surfaces/Time, Trust, Core/Persistence, Core/Permissions
- Blocked by trains: SCG-007A, SCG-007B
- Blocks trains: SCG-007I, SCG-007J, SCG-007M
- Known-issues sync: Update AMB-ISSUE-0010 only with scan plus screenshot evidence.
- Rollback: Revert copy/language changes and tests.

Allowed source paths:
- `Native/Ambitions/Language/`
- `Native/Ambitions/Projection/SurfaceLenses/`
- `Native/Ambitions/Surfaces/`
- `Native/Ambitions/Stage/Motion/`
- `Native/AmbitionsTests/`

Forbidden source paths:
- `new root Motion surface`
- `new Capture tab`
- `broad copy rewrite outside flagged files`
- `Package.swift`
- `Ambitions.xcodeproj/`

Scope boundaries:
- Remove/gate only evidence-backed forbidden/internal user-facing copy.
- Use locked language: Start here, Recommended step, Step, Start now, Open step.
- Do not rewrite product canon.

Required outputs/tests/proof:
- Output: forbidden-language scan evidence
- Output: copy policy tests
- Output: known-issues reconciliation for AMB-ISSUE-0010
- Test: ForbiddenLanguageAudit
- Test: surface copy policy tests
- Test: rendered UI assertions when visible
- Proof: scan output
- Proof: before/after string diff summary
- Proof: screenshots if visible root copy changed

Visual/device/accessibility/privacy proof:
- visual: required for visible copy changes
- device: not sufficient alone; scan required
- accessibility: VoiceOver labels use locked language
- privacy: not applicable unless privacy copy touched

Closeout criteria:
- Green: All train-scoped outputs, tests, proof artifacts, known-issues sync, rollback notes, and forbidden-path guards pass. Green is train-scoped only and does not claim senior-readiness, Visual Green, Release Green, Release readiness, app readiness, or unscoped flow/file Green.
- Yellow: Scope is bounded and evidence-backed, but current proof remains missing, manual/device/accessibility proof is absent, or accepted architecture/proof debt is explicitly carried forward with a named next train.
- Red: Any real B0/B1/B2 appears, production behavior changes outside scope, Motion/Capture root drift is introduced, private-life/local-first law is violated, validation cannot run honestly, or status claims exceed proof.

## SCG-007I - SwiftUI composition, shell geometry, and design-token hardening

Problem: Visible SwiftUI composition and shell/safe-area findings remain Yellow, including report/card/list/dashboard anatomy and chrome safe-area risks.

- Severity: `B4` `{'B0': 0, 'B1': 0, 'B2': 0, 'B3': 1, 'B4': 1}`
- Root causes addressed: RC-SCG006-010, RC-SCG006-001
- Related findings: SCG-004-005, SCG-004-009
- Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F16, SCG006-F15
- Affected files/layers: Composer/Capture, Surfaces/Goals, Surfaces/You, Stage/Chrome, DesignSystem, Stage, Surfaces/Today, Surfaces/Time, Trust, Core/Persistence, Core/Permissions
- Blocked by trains: SCG-007A, SCG-007B, SCG-007H
- Blocks trains: SCG-007J, SCG-007M
- Known-issues sync: Reconcile shell/visual rows only with reviewable screenshots; keep Yellow without device/accessibility proof.
- Rollback: Revert SwiftUI composition and test changes as one slice.

Allowed source paths:
- `Native/Ambitions/Composer/Capture/CaptureContinuityLine.swift`
- `Native/Ambitions/Surfaces/Goals/`
- `Native/Ambitions/Surfaces/You/`
- `Native/Ambitions/Stage/Chrome/`
- `Native/Ambitions/DesignSystem/`
- `Native/AmbitionsTests/`
- `Native/AmbitionsUITests/`

Forbidden source paths:
- `new material system`
- `new root shell`
- `duplicated chrome owner`
- `generated Xcode project/workspace`
- `Package.swift unless scoped`

Scope boundaries:
- Repair only flagged composition/shell geometry risks.
- Do not create duplicate material systems/root shells/dashboard anatomy.
- Do not claim Visual Green.

Required outputs/tests/proof:
- Output: composition refactor or accepted-Yellow disposition
- Output: StageSafeAreaPolicy shell proof
- Output: design-token hardening for touched visible files
- Test: rendered hierarchy/frame tests
- Test: safe-area/dock overlap tests
- Test: design token/static audit where available
- Proof: reviewable screenshots
- Proof: target-versus-actual critique
- Proof: safe-area frame evidence
- Proof: audit output

Visual/device/accessibility/privacy proof:
- visual: screenshots and critique required; no self-certified Visual Green
- device: device proof before closing shell visual rows
- accessibility: semantic mirrors and tap target notes
- privacy: not applicable unless diagnostics/private content appears

Closeout criteria:
- Green: All train-scoped outputs, tests, proof artifacts, known-issues sync, rollback notes, and forbidden-path guards pass. Green is train-scoped only and does not claim senior-readiness, Visual Green, Release Green, Release readiness, app readiness, or unscoped flow/file Green.
- Yellow: Scope is bounded and evidence-backed, but current proof remains missing, manual/device/accessibility proof is absent, or accepted architecture/proof debt is explicitly carried forward with a named next train.
- Red: Any real B0/B1/B2 appears, production behavior changes outside scope, Motion/Capture root drift is introduced, private-life/local-first law is violated, validation cannot run honestly, or status claims exceed proof.

## SCG-007J - Accessibility and static interaction proof hardening

Problem: Accessibility/static proof must precede device-proof or readiness claims.

- Severity: `B4` `{'B0': 0, 'B1': 0, 'B2': 0, 'B3': 1, 'B4': 1}`
- Root causes addressed: RC-SCG006-010, RC-SCG006-001
- Related findings: SCG-004-008, SCG-004-011, SCG-004-013
- Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F16, SCG006-F15
- Affected files/layers: Composer/Capture, Surfaces/Goals, Surfaces/You, Stage/Chrome, DesignSystem, Stage, Surfaces/Today, Surfaces/Time, Trust, Core/Persistence, Core/Permissions
- Blocked by trains: SCG-007A, SCG-007B, SCG-007H, SCG-007I
- Blocks trains: SCG-007M
- Known-issues sync: Keep accessibility rows Yellow unless current manual/device evidence exists.
- Rollback: Revert accessibility/source/test changes; do not leave fake labels on dead controls.

Allowed source paths:
- `Native/Ambitions/DesignSystem/Accessibility/`
- `Native/Ambitions/Surfaces/You/YouScreen+02-YouRootDetailSheet.swift`
- `Native/Ambitions/Surfaces/`
- `Native/Ambitions/Composer/Capture/`
- `Native/AmbitionsUITests/`
- `Native/AmbitionsTests/`

Forbidden source paths:
- `cosmetic-only labels hiding behavior gaps`
- `Visual Green without independent review`
- `Ambitions.xcodeproj/`

Scope boundaries:
- Repair static accessibility semantics and interaction proof only.
- Dynamic Type/VoiceOver/Reduce Motion/Reduce Transparency/Increase Contrast/tap target notes required where touched.
- Do not claim full accessibility conformance without manual/current proof.

Required outputs/tests/proof:
- Output: accessibility marker repairs
- Output: semantic mirror tests
- Output: Dynamic Type/Reduce Motion/Contrast checklist
- Test: accessibility unit/UI tests
- Test: rendered hierarchy tests
- Test: senior audit accessibility rerun
- Proof: accessibility audit output
- Proof: manual proof notes or not-run reasons
- Proof: screenshots for text-fit/tap-target changes

Visual/device/accessibility/privacy proof:
- visual: support screenshots for text-fit/tap-target risks
- device: manual/device proof before row closure
- accessibility: core output
- privacy: not applicable unless labels expose private content

Closeout criteria:
- Green: All train-scoped outputs, tests, proof artifacts, known-issues sync, rollback notes, and forbidden-path guards pass. Green is train-scoped only and does not claim senior-readiness, Visual Green, Release Green, Release readiness, app readiness, or unscoped flow/file Green.
- Yellow: Scope is bounded and evidence-backed, but current proof remains missing, manual/device/accessibility proof is absent, or accepted architecture/proof debt is explicitly carried forward with a named next train.
- Red: Any real B0/B1/B2 appears, production behavior changes outside scope, Motion/Capture root drift is introduced, private-life/local-first law is violated, validation cannot run honestly, or status claims exceed proof.

## SCG-007K - Privacy, local-first, offline/no-account, and diagnostics proof hardening

Problem: Offline/no-account and local-first posture is source-present but not release-proven; privacy/network/cloud markers need scoped proof.

- Severity: `B3` `{'B0': 0, 'B1': 0, 'B2': 0, 'B3': 2, 'B4': 0}`
- Root causes addressed: RC-SCG006-009, RC-SCG006-001
- Related findings: SCG-004-010
- Affected flows: SCG006-F15, SCG006-F16, SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14
- Affected files/layers: AppContainerFactory, Core/Persistence, Core/Runtime, Core/Permissions, Privacy boundary, Stage, Composer/Capture, Surfaces/Today, Surfaces/Goals, Surfaces/Time, Trust
- Blocked by trains: SCG-007A, SCG-007B
- Blocks trains: SCG-007L, SCG-007M
- Known-issues sync: Update only if B0/B1/B2 discovered; otherwise record Yellow proof gaps.
- Rollback: Revert privacy/local-first changes; confirm no persisted data side effects.

Allowed source paths:
- `Native/Ambitions/App/AppContainerFactory.swift`
- `Native/Ambitions/Core/Persistence/`
- `Native/Ambitions/Core/Runtime/`
- `Native/Ambitions/Core/Permissions/`
- `Native/Ambitions/Diagnostics/`
- `Native/AmbitionsTests/`

Forbidden source paths:
- `hosted private life graph backend`
- `cloud LLM/core hosted AI dependency`
- `R2/private user data upload`
- `account-required core flow`
- `PrivacyInfo.xcprivacy unless reviewed with privacy scope`

Scope boundaries:
- Prove offline/no-account/local-only behavior and diagnostics redaction only.
- Do not implement account/sync/R2/cloud behavior unless future scoped issue authorizes it.
- Do not claim privacy/legal approval.

Required outputs/tests/proof:
- Output: offline launch/use proof
- Output: account-absent core flow proof
- Output: request-shape review
- Output: diagnostics redaction assertions
- Test: offline/no-account tests
- Test: privacy boundary/request-shape tests
- Test: permission-denied fallback tests
- Test: diagnostics redaction tests
- Proof: network-disabled run evidence
- Proof: account-absent proof
- Proof: privacy boundary scan
- Proof: permission-denied evidence

Visual/device/accessibility/privacy proof:
- visual: only permission fallback UI screenshots if relevant
- device: network/account disabled proof
- accessibility: permission-denied fallback accessible state
- privacy: core output; legal approval not claimed

Closeout criteria:
- Green: All train-scoped outputs, tests, proof artifacts, known-issues sync, rollback notes, and forbidden-path guards pass. Green is train-scoped only and does not claim senior-readiness, Visual Green, Release Green, Release readiness, app readiness, or unscoped flow/file Green.
- Yellow: Scope is bounded and evidence-backed, but current proof remains missing, manual/device/accessibility proof is absent, or accepted architecture/proof debt is explicitly carried forward with a named next train.
- Red: Any real B0/B1/B2 appears, production behavior changes outside scope, Motion/Capture root drift is introduced, private-life/local-first law is violated, validation cannot run honestly, or status claims exceed proof.

## SCG-007L - Test-strength and 16-flow behavior-proof closure

Problem: All 16 SCG-006 flows remain Yellow because behavior proof is incomplete and weak tests overuse file/string presence.

- Severity: `B4` `{'B0': 0, 'B1': 0, 'B2': 0, 'B3': 9, 'B4': 1}`
- Root causes addressed: RC-SCG006-001, RC-SCG006-002, RC-SCG006-003, RC-SCG006-004, RC-SCG006-005, RC-SCG006-006, RC-SCG006-007, RC-SCG006-008, RC-SCG006-009, RC-SCG006-010
- Related findings: SCG-004-011, SCG-004-013
- Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16
- Affected files/layers: Stage, Composer/Capture, Surfaces/Today, Surfaces/Goals, Surfaces/Time, Trust, Core/Persistence, Core/Permissions, Stage overlay, AppShellActivatedCaptureSeam, Core/Runtime CaptureService, Projection/SurfaceLenses, Interaction, Core/Runtime ClosureEngine, EventLedger, Projection/Mutations, Projection/SurfaceLenses/TodayLens, Core/Runtime ScheduleInstallKernel, Core/Runtime MemoryLensService, Stage overlays, ShellCommandRouter, Trust/Receipt, You memory controls, Docs, Legacy/Unknown, Quality, SCG control plane, AppContainerFactory, Core/Runtime, Privacy boundary, Surfaces/You, Stage/Chrome, DesignSystem
- Blocked by trains: SCG-007A, SCG-007B, SCG-007C, SCG-007D, SCG-007E, SCG-007F, SCG-007G, SCG-007K
- Blocks trains: SCG-007M
- Known-issues sync: Known-issues sync must happen before SCG-008; close rows only with row-specific proof.
- Rollback: Revert tests/proof artifacts; production rollback only if separately scoped hooks touched.

Allowed source paths:
- `Native/AmbitionsTests/`
- `Native/AmbitionsUITests/`
- `docs/quality/senior-review/FLOW_TRACE_AUDIT.*`
- `docs/quality/senior-review/ROOT_CAUSE_MAP.*`
- `docs/qa/KNOWN_ISSUES.md`

Forbidden source paths:
- `production source except separately scoped upstream repair`
- `generated project/workspace`
- `privacy manifests unless privacy scope opened`

Scope boundaries:
- Replace weak proof with behavior proof for F01-F16 only.
- Do not repair production behavior inside this proof train unless a minimal hook is explicitly scoped.
- Flow Green requires behavior proof, not source-string tests.

Required outputs/tests/proof:
- Output: behavior-proof test matrix for F01-F16
- Output: updated flow audit/root cause map preserving Yellow where proof missing
- Output: known-issues reconciliation
- Test: flow-specific UI/runtime tests for all 16 flows
- Test: screenshot/frame assertions where visible behavior is asserted
- Proof: test logs tied to commit
- Proof: flow matrix evidence paths
- Proof: before/action/after mutation evidence

Visual/device/accessibility/privacy proof:
- visual: screenshots where visible behavior asserted; no Visual Green self-certification
- device: device proof required before closing device rows
- accessibility: state proof for every interactive flow
- privacy: offline/no-account proof for F15/F16

Closeout criteria:
- Green: All train-scoped outputs, tests, proof artifacts, known-issues sync, rollback notes, and forbidden-path guards pass. Green is train-scoped only and does not claim senior-readiness, Visual Green, Release Green, Release readiness, app readiness, or unscoped flow/file Green.
- Yellow: Scope is bounded and evidence-backed, but current proof remains missing, manual/device/accessibility proof is absent, or accepted architecture/proof debt is explicitly carried forward with a named next train.
- Red: Any real B0/B1/B2 appears, production behavior changes outside scope, Motion/Capture root drift is introduced, private-life/local-first law is violated, validation cannot run honestly, or status claims exceed proof.

## SCG-007M - Visual/device proof readiness gate

Problem: Visual/device proof remains Yellow/Red; screenshots alone are not proof and Codex cannot self-certify Visual Green or Release Green.

- Severity: `B4` `{'B0': 0, 'B1': 0, 'B2': 0, 'B3': 1, 'B4': 1}`
- Root causes addressed: RC-SCG006-001, RC-SCG006-010
- Related findings: SCG-004-013
- Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16
- Affected files/layers: Stage, Composer/Capture, Surfaces/Today, Surfaces/Goals, Surfaces/Time, Trust, Core/Persistence, Core/Permissions, Surfaces/You, Stage/Chrome, DesignSystem
- Blocked by trains: SCG-007A, SCG-007B, SCG-007C, SCG-007D, SCG-007E, SCG-007F, SCG-007G, SCG-007H, SCG-007I, SCG-007J, SCG-007K, SCG-007L
- Blocks trains: SCG-008
- Known-issues sync: Final sync/dedupe before SCG-008. No row closure from screenshot paths alone.
- Rollback: Revert proof harness changes and mark evidence invalid if target commit changes.

Allowed source paths:
- `docs/qa/evidence/`
- `docs/quality/senior-review/`
- `docs/qa/KNOWN_ISSUES.md`
- `Native/AmbitionsUITests/ only if proof harness is scoped`

Forbidden source paths:
- `production UI/source repairs unless a new scoped repair issue opens`
- `Visual Green/Release Green claims by Codex alone`
- `generated project/workspace`

Scope boundaries:
- Collect/evaluate visual/device proof only after upstream runtime, copy, accessibility, privacy, and behavior-proof gates.
- Do not self-certify Visual Green or Release Green.
- Do not start SCG-008 until known-issues sync/dedupe is complete.

Required outputs/tests/proof:
- Output: visual/device proof matrix
- Output: target-versus-actual critiques
- Output: accessibility/device proof index
- Output: Ready for Visual Review or Yellow/Red closeout
- Test: UI proof harness
- Test: screenshot/frame hierarchy assertions
- Test: Dynamic Type/Reduce Motion/Increase Contrast checks
- Test: real-device checklist where available
- Proof: reviewable screenshots/videos
- Proof: manifest tied to commit
- Proof: manual reviewer notes/owner acceptance if claiming Visual Green
- Proof: known-issues reconciliation

Visual/device/accessibility/privacy proof:
- visual: core output; must be reviewable and evaluated
- device: required for device claims
- accessibility: must reference SCG-007J before device/readiness claims
- privacy: must reference SCG-007K before local-first/offline claims

Closeout criteria:
- Green: All train-scoped outputs, tests, proof artifacts, known-issues sync, rollback notes, and forbidden-path guards pass. Green is train-scoped only and does not claim senior-readiness, Visual Green, Release Green, Release readiness, app readiness, or unscoped flow/file Green.
- Yellow: Scope is bounded and evidence-backed, but current proof remains missing, manual/device/accessibility proof is absent, or accepted architecture/proof debt is explicitly carried forward with a named next train.
- Red: Any real B0/B1/B2 appears, production behavior changes outside scope, Motion/Capture root drift is introduced, private-life/local-first law is violated, validation cannot run honestly, or status claims exceed proof.
