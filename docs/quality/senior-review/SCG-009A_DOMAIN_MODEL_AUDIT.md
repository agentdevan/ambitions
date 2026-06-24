# SCG-009A Domain Model Audit and Canon Gap Map

Status: Audit/control artifact for AMB-1302 / SCG-009A
Scope: Domain model audit only; no production Swift edits
Requested baseline SHA: `9bf3fe320bdfb283e9edda678c29442ec939041e`
Observed run-start SHA on clean `main`: `a1574b59b545804b5dc40f67c7bbf55dda838bf7`
Branch: `main`

## Executive Verdict

Audit status: Yellow audit/control complete.

Status ceiling: Green is allowed only for completeness of this audit/control artifact and validation of the audit files. Runtime Green, Visual Green, Release Green, senior-readiness, app release-ready, owner acceptance, and SCG-009 implementation complete are not claimed.

SCG-009B can begin after AMB-1302 closeout with bounded scope only. The audit found canonical `Core/Domain` owner files for all ten required objects, but it also found domain-to-behavior gaps that need either explicit accepted-Yellow classification or focused repair: `GoalThread` is mostly computed/projection-derived rather than clearly persisted as a first-class thread record; `UserSystemProfile` is an inspectable summary shape without `Codable`/persistence proof; and `ClosureOutcome` remains a known mutation/proof candidate under `SCG-004-004`.

SCG-009C can begin after SCG-009B, or after SCG-009B explicitly closes with no production domain repair required. Several required flows already have focused behavior tests, but the proof matrix is uneven and still includes file-existence, source-string, mock-only, and release-unproven seams.

No blocker prevents the next repair child from starting. The repair blocker is scope discipline: do not widen into UI, visual proof, release readiness, SCG-010, or production redesign.

Highest scoped severity remains B3 audit/control risk. No B0/B1/B2 production defect was produced by this audit.

## Inputs Inspected

- Truth and operating authority: `AGENTS.md`, `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `docs/truth/CODEX_PROCESS_TRUTH.md`, plus supporting truth/read-order files.
- SCG source basis: `REPAIR_TRAINS.json`, `REPAIR_TRAINS.md`, `ROOT_CAUSE_MAP.json`, `AUTOMATED_FINDINGS.json`, `SENIOR_CODE_REVIEW_LEDGER.json`, `FLOW_TRACE_AUDIT.json`, `KNOWN_ISSUES_SYNC_REPORT.json`.
- Known-issues mapping: `docs/qa/KNOWN_ISSUES.md`, `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`.
- Linear context: AMB-1302, AMB-1303, AMB-1304, AMB-1292.
- Allowed source/test paths only under `Core/Domain`, `Core/Runtime`, `Core/Persistence`, `Core/Permissions`, `Projection/SurfaceLenses`, `Projection/Mutations`, and scoped test folders.

## Finding IDs Mapped

| Finding | Severity | Audit disposition |
|---|---:|---|
| `SCG-004-001` ArchitectureBoundaryAudit | B3 | Canonical domain files are correctly under `Core/Domain`, but senior ledger still carries broader unknown ownership/layer risk. |
| `SCG-004-003` LayerImportAudit | B3 | No new import repair in this child. Downstream owner trains must keep UI dependencies out of Core and persistence dependencies behind repositories/projections. |
| `SCG-004-011` TestStrengthAudit | B3 | Required flows still mix behavior tests with file-existence, source-string, and mock-only tests. |
| `SCG-004-004` RuntimeMutationProofAudit | B3 | `ClosureOutcome` and mutation-adjacent paths require typed proof/receipt/undo review before runtime claims. |
| `SCG-004-010` PrivacyLocalFirstAudit | B3 | Offline/no-account and local-first posture is source-present but not release-proven. |

Fixture-only detector IDs such as `SCG-004-913` were treated as support evidence only and not promoted into production defects.

## Root Cause IDs Mapped

| Root cause | Audit mapping |
|---|---|
| `RC-SCG006-001` | Current runtime/device proof is still missing for traced flows. |
| `RC-SCG006-004` | Today Start/Close/Move mutation links are partial and proof-pending. |
| `RC-SCG006-005` | Time mutation and Today recompute have focused tests but remain runtime/device proof-pending. |
| `RC-SCG006-007` | Undo is uneven across closure, destructive, and runtime flows. |
| `RC-SCG006-008` | SCG governance unknowns remain input risk and are not repaired here. |
| `RC-SCG006-009` | Offline/no-account and local-first posture is source-present but release proof is absent. |

## Domain Canon Gap Map

| Object | Current canon fit | Gap disposition |
|---|---|---|
| Step | Canonical `Core/Domain/Step.swift` exists. Step is `Codable`, `Sendable`, `Equatable`, `Identifiable`, persists through `StepRecord`, and is used by Goals/Today/Time runtime and projection paths. | Behavior proof exists for some Step creation, completion, placement, and projection seams, but SCG-009C still needs flow-specific before/action/after tests for close, move, undo, and offline behavior. |
| GoalThread | Canonical `Core/Domain/GoalThread.swift` exists and preserves stable unique `goalIDs`. Goal thread projection is produced from loaded Goals through `GoalsFeatureService` / `LifeAreaAtlasProjector`. | First-class persistence is not obvious as a dedicated thread record/repository. SCG-009B should decide whether computed thread hierarchy is the intended canonical owner or add/route a persisted thread seam with migration assessment. |
| LifeArea | Canonical `LifeArea.swift`, `LifeAreaModels.swift`, and `LifeAreaSummary.swift` exist. Life Areas have canonical domain definitions and atlas/summary projections. | Mostly source-present and projection-present. SCG-009C should upgrade behavior proof for GoalThread-to-LifeArea-to-Today coupling; no production repair is recommended unless SCG-009B proves customization/persistence must be first-class now. |
| RealityWindow | Canonical `RealityWindow.swift` exists. It models local-only window state, calendar-derived privacy, duration, protected/flexible/open semantics, and is used by permissions/time projections. | Time and permission tests cover some denied/manual fallback and protected-window seams. Runtime/device proof remains absent; SCG-009C should keep permission-denied behavior tests focused. |
| CapacityShape | Canonical `CapacityShape.swift` exists. `CapacityEstimate.shape` derives `CapacityShape`; runtime `RuntimeSnapshot`, PressureEngine, BufferEngine, and Time projections consume it. | Behavior tests cover pressure/buffer derivation. Offline/no-account and release proof are not established by this model; no SCG-009B production repair recommended unless downstream tests expose a missing clock/capacity seam. |
| CaptureIntake | Canonical `CaptureIntake.swift` exists. It maps from `Capture`, normalizes routes/intents, keeps privacy classification, and marks low-confidence review states. | Capture save/projection tests exist, but full composer/receipt/device proof and typed Capture-to-domain receipt behavior remain Yellow. SCG-009C should prove save/route/receipt persistence without source-string claims. |
| ClosureOutcome | Canonical `ClosureOutcome.swift` exists and maps closure states to user-facing outcomes and `ProofEvent.Kind`. Senior ledger marks it Yellow under mutation-proof audit. | SCG-009B should either classify it as non-mutating option taxonomy or route it into typed proof/receipt/undo contracts for closure mutation. SCG-009C should add before/action/after closure proof around real persisted Step state. |
| ProofEvent | Canonical `ProofEvent.swift` exists. It maps from `Proof`, normalizes source/summary, exposes `isUsableForRecommendation`, and feeds `ProofLedger`. | ProofLedger/runtime snapshot source is present, and trust/history persistence exists, but flow-specific proof artifacts are not release/runtime-proven. SCG-009C should verify proof IDs across close/capture/undo paths. |
| RecoveryState | Canonical `RecoveryState.swift` exists. It maps from `RecoveryThread`, normalizes proof references, and feeds `RuntimeSnapshot.needsReview`. | Runtime recovery source is present. Behavior proof for recovery after close/move/time correction is partial; SCG-009C should test visible recovery and undo/correction availability where flows claim it. |
| UserSystemProfile | Canonical `UserSystemProfile.swift` exists as `Sendable`, `Equatable`, `Identifiable` summary/inspection shape. You projections also expose policy/trust/local controls. | Not `Codable` and no dedicated persistence relationship was found in scoped paths. SCG-009B should decide whether it is intentionally derived projection state or should become a serializable domain profile with local persistence/reset/export boundaries. |

## Source Ownership Table

| Object | Canonical owner | Live files | Persisted model relationship | Runtime relationship | Projection relationship | Current tests | Missing proof | Known-issue mapping | Recommended owner train |
|---|---|---|---|---|---|---|---|---|---|
| Step | `Core/Domain` | `Step.swift` | `StepRecord`; goal repository maps `Step` to/from records. | Goal services, Time mutation, runtime command/mutation paths. | Today, Goals, Time lenses and mutation projections. | `CoreDomainCanonicalOwnershipTests`, `GoalCreationServiceTests`, `TodayCommandHandlerTests`, `TimeTodayCouplingTests`. | Full close/move/undo/offline before-action-after proof. | `AMB-ISSUE-0004`, `0005`, `1001`-`1007`, `1401`. | SCG-009C, with SCG-009B only if model shape gap appears. |
| GoalThread | `Core/Domain` | `GoalThread.swift` | No dedicated scoped `GoalThreadRecord` found; computed from Goal/plan graph. | Pressure/load and LifeArea atlas use goal-thread hierarchy. | Goals atlas, Today Start Here goal-thread summary. | `CoreDomainCanonicalOwnershipTests`, `AmbitionGraphModelsTests`, Goals overview tests. | Persistence/authority decision for first-class thread continuity. | `AMB-ISSUE-1301`-`1304`, `1309`, `0004`, `0005`. | SCG-009B. |
| LifeArea | `Core/Domain` | `LifeArea.swift`, `LifeAreaModels.swift`, `LifeAreaSummary.swift` | Derived from canonical definitions and Goal domain/life graph; no dedicated area preference store found in scoped paths. | `LifeAreaAtlasProjector`, `OneStepGoalProjector`, North Star grouping. | Goals Life Area Atlas, You organization references. | `CoreDomainCanonicalOwnershipTests`, `GoalsOverviewBoardTests`, domain model tests. | Behavior proof for area/thread/Today continuity and local customization boundaries. | Goals rows `1301`-`1304`, `1309`. | SCG-009C unless persistence/customization is proven required by SCG-009B. |
| RealityWindow | `Core/Domain` | `RealityWindow.swift` | No direct record found; derived from calendar/Time/runtime state and snapshot/ledger paths. | Calendar permission/service derives busy windows; Time projections use windows. | Time Life Calendar and Today recompute seams. | `CoreDomainCanonicalOwnershipTests`, Time projection/coupling tests, Calendar contract tests. | Device/runtime permission-denied and protected-window proof. | Time rows `0009`, `0501`-`0507`, `0913`, `1401`-`1404`. | SCG-009C. |
| CapacityShape | `Core/Domain` | `CapacityShape.swift` | Persisted indirectly through runtime snapshot ledger where snapshots are recorded. | `RuntimeSnapshot`, PressureEngine, BufferEngine. | Time lens, LifeShape projections. | `CoreDomainCanonicalOwnershipTests`, `PressureEngineTests`, `BufferEngineTests`, Time tests. | Offline/no-account and current runtime proof; not model presence. | `AMB-ISSUE-0014`, Time rows. | SCG-009C. |
| CaptureIntake | `Core/Domain` | `CaptureIntake.swift` | Capture persists through `CaptureRecord`; `CaptureIntake` itself appears derived from `Capture`. | CaptureService route/review behavior. | Capture route preview, Goals/Capture handoff. | `CoreDomainCanonicalOwnershipTests`, `CaptureViewModelTests`, `CaptureServiceTests`. | Save receipt/proof and full composer runtime proof. | `AMB-ISSUE-0003`, `0008`, `0012`, `1101`-`1107`. | SCG-009C, with SCG-009B if a persisted intake record is required. |
| ClosureOutcome | `Core/Domain` | `ClosureOutcome.swift` | Closure/receipt records exist in trust/action history, not as this option object. | ClosureEngine and closure stage mutation consume outcome semantics. | Today closure sheet state and mutation projection. | `CoreDomainCanonicalOwnershipTests`, Today command/closure-related tests. | Typed proof/receipt/undo classification and persisted Step before/action/after proof. | `AMB-ISSUE-0004`, `0005`, `1001`-`1007`, proof rows. | SCG-009B then SCG-009C. |
| ProofEvent | `Core/Domain` | `ProofEvent.swift` | Proof and event/receipt records exist; `ProofLedger` consumes `ProofEvent`. | `ProofLedger`, `RuntimeSnapshot`. | Trust/You/history projections and mutation proof seams. | `CoreDomainCanonicalOwnershipTests`, trust/history persistence tests. | Proof ID continuity across each required mutation flow. | `AMB-ISSUE-0014`, `1801`, `1802`. | SCG-009C. |
| RecoveryState | `Core/Domain` | `RecoveryState.swift` | Derived from `RecoveryThread`; runtime snapshots can persist via ledger. | `RuntimeSnapshot.needsReview`, RecoveryEngine. | Time/Today recovery projections. | `CoreDomainCanonicalOwnershipTests`, runtime recovery tests. | Recovery visible-state proof after close/move/time correction. | `AMB-ISSUE-0004`, `0009`, proof rows. | SCG-009C. |
| UserSystemProfile | `Core/Domain` | `UserSystemProfile.swift` | No dedicated scoped persistence relationship found; summary appears projection-derived. | OpenCapacity uses planning defaults; You projections expose policy/trust settings separately. | You policy/trust/dashboard projections. | `CoreDomainCanonicalOwnershipTests`. | Codable/local persistence/reset/export/account-boundary proof. | `AMB-ISSUE-0014`, `0807`, `1801`, `1802`; You remediation rows by relation. | SCG-009B for authority decision, then SCG-009C if behavior proof is added. |

## Behavior-Proof Seam Map

| Flow | Current source path | Current test evidence | Proof class | Required proof for SCG-009B / SCG-009C | Known issues |
|---|---|---|---|---|---|
| `SCG006-F03` Capture save | `CaptureService`, `CaptureIntake`, `SwiftDataCaptureRepository`, Capture projection/view model | `CaptureViewModelTests`, `CaptureServiceTests`, `CaptureRuntimeReceiptTests` | Behavior proof plus remaining mock/source-only and device gaps | Prove local save, receipt/proof ID, route review, and no root Capture/tab in a focused behavior log; device proof remains outside SCG-009C unless separately scoped. | `AMB-ISSUE-0003`, `0008`, `0012`, `1101`-`1107` |
| `SCG006-F05` Create goal | Goals service/unit of work, Goal/Step persistence, Capture-to-Goal promotion | `GoalCreationServiceTests`, `CreateGoalViewModelTests`, Goals shell tests | Behavior proof for local unit-of-work; visual/device proof missing | Keep create-goal behavior tests; add domain-thread assertion only if SCG-009B changes GoalThread authority. | `AMB-ISSUE-1301`-`1304`, `1309` |
| `SCG006-F06` Goal thread feeds Today | Goals repository, `GoalsFeatureService` thread hierarchy, `RepositoryBackedTodayService`, `TodayLens` | `TodayFreshGoalVisibilityTests`, Today/Goals projection tests | Behavior proof partial | Prove persisted GoalThread/Step input changes Today Start Here after refresh, with no file/string-only assertions. | `AMB-ISSUE-0004`, `0005`, `1001`-`1007`, `1301`-`1304`, `1309` |
| `SCG006-F08` Close step | `ClosureOutcome`, `ClosureEngine`, `ClosureStageMutation`, Today command/action handler | Today command tests; closure primitive/source trace | Behavior proof partial; closure option taxonomy still mutation-proof Yellow | Before/action/after persisted Step state, event ledger, proof/receipt, visible mutation, and undo availability for closure outcomes. | `AMB-ISSUE-0004`, `0005`, `1001`-`1007`, `0014`, `0807`, `1801`, `1802` |
| `SCG006-F09` Move step | `TimeMutation`, Today recompute, Today/Time projections | `TimeTodayCouplingTests`, `TimeFieldMutationCoordinatorTests`, Today tests | Behavior proof partial | Real Step move/place path with Today recompute, receipt/undo, and no fake placement. | Today rows plus Time rows `0009`, `0501`-`0507`, `0913`, `1401`-`1404` |
| `SCG006-F10` Protect window | `RealityWindow`, `ProtectedBoundary`, `TimeMutation`, Calendar/Time permissions | `TimeTodayCouplingTests`, schedule/protection tests | Behavior proof partial | Protected-window mutation with affected window avoided by Today, receipt/undo, and denied-permission fallback. | Time rows `0009`, `0501`-`0507`, `0913`, `1401`-`1404` |
| `SCG006-F11` Time correction recomputes Today | `TimeMutation`, `TodayLens.recomputeAfterTimeMutation`, LifeShape projection | `TimeTodayCouplingTests` covers needsMoreTime, notUsable, keepClear, makeTodayLighter, addBuffer | Behavior proof partial | Keep deterministic clock/source; prove correction changes Today recommendation and receipt path. | Time rows `0009`, `0501`-`0507`, `0913`, `1401`-`1404` |
| `SCG006-F14` Undo | `MutationUndo`, `TimeFieldMutationCoordinator`, closure mutation undo availability | Time mutation coordinator tests; You memory controls; source trace | Behavior proof partial; uneven across owners | Uniform undo/correction matrix for Time, closure, Capture route changes, and blocked destructive flows. | `AMB-ISSUE-0014`, `0807`, `1801`, `1802` |
| `SCG006-F15` Offline/no account | Local repositories/runtime/source posture, privacy boundaries | Local-only/privacy tests exist but SCG flow says not release-run; Release Truth forbids claim | Source-present / release-unproven | Offline/no-account launch/use tests with network/account absent and request-shape proof for network-capable candidates. | `AMB-ISSUE-0014` |
| `SCG006-F16` Permission denied fallback | `PermissionState`, `CalendarPermission`, Time projection denied states | Core permissions tests, Calendar reminder flow tests, Time denied scenarios | Behavior proof partial / manual proof missing | Permission-denied runtime test that proves local fallback and no surprise system write/read prompt. | `AMB-ISSUE-0014`, `0807`, `1801`, `1802` |

## Test-Strength Disposition

| Test area | Disposition | Notes |
|---|---|---|
| `CoreDomainCanonicalOwnershipTests` | File-existence proof plus lightweight value-contract behavior | Useful as ownership guard, but not sufficient for SCG-009 behavior claims. |
| `GoalCreationServiceTests` | Behavior proof | Exercises goal creation, SwiftData unit-of-work receipts, rollback, draft/materialization, and Step persistence. |
| `CaptureServiceTests` | Behavior proof | Exercises capture creation, route changes, promotion to goal, rollback, and ledger events. |
| `CaptureViewModelTests` | Behavior proof with some projection/copy assertions | Good for route preview and save behavior; still not runtime/device proof. |
| `TodayCommandHandlerTests` | Behavior proof | Exercises complete/quick-log command records, event ledger, blocked missing target, and no-mutation navigation. |
| `TimeTodayCouplingTests` | Behavior proof | Exercises place/protect/correct Time mutations and Today recompute. |
| `TimeProjectionServiceTests` denied calendar cases | Behavior proof for projection fallback | Proves denied/manual fallback in service-level tests; not device/manual accessibility proof. |
| SCG flagged test candidates from `SCG-004-011` | Source-string, file-existence, or mock-only risk | Must be downgraded or supplemented before claiming behavior. |
| Runtime/device/offline proof | Missing or release-unproven | Release Truth says offline/no-account, runtime/device, visual, accessibility, and release readiness are not proven. |

## Known-Issues Dedupe Table

No duplicate known-issues rows were created. Findings map to existing rows:

| Area | Existing rows |
|---|---|
| Proof/accessibility/release | `AMB-ISSUE-0014`, `AMB-ISSUE-0807`, `AMB-ISSUE-1801`, `AMB-ISSUE-1802` |
| Capture | `AMB-ISSUE-0003`, `AMB-ISSUE-0008`, `AMB-ISSUE-0012`, `AMB-ISSUE-1101`-`AMB-ISSUE-1107` |
| Today/closure | `AMB-ISSUE-0004`, `AMB-ISSUE-0005`, `AMB-ISSUE-1001`-`AMB-ISSUE-1007` |
| Goals | `AMB-ISSUE-1301`-`AMB-ISSUE-1304`, `AMB-ISSUE-1309` |
| Time | `AMB-ISSUE-0009`, `AMB-ISSUE-0501`-`AMB-ISSUE-0507`, `AMB-ISSUE-0913`, `AMB-ISSUE-1401`-`AMB-ISSUE-1404` |
| Related QA remediation references, not duplicates | `AMB-1192`, `AMB-1193`, `AMB-1186`, `AMB-1188`, `AMB-1197`, `AMB-1199` |

## SCG-009B Repair Recommendations

| Finding/root cause | Object/flow | Severity | Allowed paths | Forbidden paths | Required validation | Required proof | Rollback scope |
|---|---|---:|---|---|---|---|---|
| `SCG-004-004`, `RC-SCG006-004`, `RC-SCG006-007` | `ClosureOutcome`, `SCG006-F08`, `SCG006-F14` | B3 | `Core/Domain`, `Core/Runtime`, `Projection/Mutations`, focused tests | UI/visual/shell, project/package/privacy manifest paths | Architecture inventory, quality gate, test-strength audit, focused closure tests | Typed proof/receipt/undo contract tied to persisted Step state | Revert domain/runtime/projection/test changes together |
| `SCG-004-001`, `SCG-004-011`, `RC-SCG006-004` | `GoalThread`, `SCG006-F06` | B3 | `Core/Domain`, `Core/Persistence`, `Core/Runtime`, `Projection/SurfaceLenses`, focused Goals/Today tests | Surfaces UI, app redesign, visual queue | Architecture inventory, quality gate, focused domain/persistence tests | Decision record or implementation proving computed vs persisted GoalThread authority | Revert thread authority/persistence/projection/test changes together |
| `SCG-004-010`, `RC-SCG006-009` | `UserSystemProfile`, `SCG006-F15` | B3 | `Core/Domain`, `Core/Persistence`, `Core/Permissions`, `Projection/SurfaceLenses`, focused You/privacy tests | Account-required core, R2 private data, cloud/LLM | Privacy/local-first tests, quality gate, test-strength audit | Codable/local persistence or explicit derived-only classification; no private graph request-shape proof if network-capable paths are touched | Revert profile/domain/persistence/test changes together |

## SCG-009C Repair Recommendations

| Finding/root cause | Object/flow | Severity | Allowed paths | Forbidden paths | Required validation | Required proof | Rollback scope |
|---|---|---:|---|---|---|---|---|
| `SCG-004-011`, `RC-SCG006-001` | All required flows | B3 | `Native/AmbitionsTests/Domain`, `Runtime`, `Persistence`, `Today`, `Time`, `Goals`, `Capture`; minimal allowed seams only if proven by failing behavior test | Broad production repair, UI/visual/shell/redesign/release work | Focused behavior selectors plus required scripts | Behavior proof replacing or supplementing source-string/file-existence checks | Revert tests and any minimal seams together |
| `SCG-004-004`, `RC-SCG006-004`, `RC-SCG006-005`, `RC-SCG006-007` | Close/move/protect/correct/undo | B3 | `Projection/Mutations`, `Core/Runtime`, `Core/Persistence`, focused tests | Visual proof queue, Shell/Stage unless separately scoped | Time/Today/Runtime focused tests, quality gate | Before/action/after mutation, receipt, proof artifact ID, undo/fallback assertion | Revert mutation/test changes together |
| `SCG-004-010`, `RC-SCG006-009` | Offline/no-account, permission denied fallback | B3 | `Core/Permissions`, `Core/Persistence`, focused runtime/privacy tests | Account-required behavior, R2 private data, privacy manifest edits | Privacy/local-first tests, denied-permission tests, required scripts | Network/account disabled proof, request-shape proof, local fallback proof | Revert permission/privacy test or seam changes together |

## Architecture Tree Closeout

Final Architecture Tree section inspected: yes.

Canonical owners touched by this audit: no production owners changed. Audit inspected `Core/Domain`, `Core/Runtime`, `Core/Persistence`, `Core/Permissions`, `Projection/SurfaceLenses`, `Projection/Mutations`, and `Quality` evidence.

Files moved or created: created this audit artifact only.

Old/non-canonical paths removed: none.

Compatibility shims left behind: none introduced.

Yellow architecture debt remaining: broader SCG ownership/import unknowns remain from `SCG-004-001` and `SCG-004-003`; `GoalThread` first-class persistence/authority needs SCG-009B decision.

Next repair train if debt remains: AMB-1303 / SCG-009B, followed by AMB-1304 / SCG-009C.

No "equivalent" folder/path interpretation was used.

## Validation

Required validation commands for closeout:

```bash
python3 scripts/ambitions-architecture-inventory.py
python3 scripts/ambitions-quality-gate.py
python3 scripts/ambitions-test-strength-audit.py
python3 scripts/ambitions-senior-code-audit.py --json
git diff --check
git status --short --branch
```

Validation results:

| Command | Result | Notes |
|---|---|---|
| `python3 scripts/ambitions-architecture-inventory.py` | Pass | `GREEN final-tree parity achieved`; 224 required files, 224 implemented, 0 blocking entries. |
| `python3 scripts/ambitions-quality-gate.py` | Pass | `GREEN all strict quality gates passed`; 1 changed path, the audit artifact. |
| `python3 scripts/ambitions-test-strength-audit.py` | Pass | `ambitions-test-strength-audit GREEN`. |
| `python3 scripts/ambitions-senior-code-audit.py --json` | Failed/capped | Exited 1. The audit ran and reproduced SCG-004 repo findings/fixtures, but reported scope-guard failures against prior SCG-004 baseline state. Generated `AUTOMATED_FINDINGS` files were restored because this child is not allowed to update SCG-004 artifacts. No Runtime Green, Visual Green, Release Green, or senior-readiness claim is made from this command. |
| `git diff --check` | Pass | No whitespace errors in the scoped audit diff. |
| `git status --short --branch` | Pass | Clean except `docs/quality/senior-review/SCG-009A_DOMAIN_MODEL_AUDIT.md` before commit. |

## Closeout Fields

Status: Yellow audit/control complete.

Status ceiling: Audit/control only. The artifact is complete, but the train remains honest Yellow because senior-code-audit is capped by existing SCG findings/scope-guard output and because no runtime/device/release/owner proof is in scope.

Baseline SHA: requested `9bf3fe320bdfb283e9edda678c29442ec939041e`; observed run-start `a1574b59b545804b5dc40f67c7bbf55dda838bf7`.

Final SHA: assigned by the audit commit; record exact SHA in Linear/final closeout.

Files changed: `docs/quality/senior-review/SCG-009A_DOMAIN_MODEL_AUDIT.md`.

Domain objects audited: Step, GoalThread, LifeArea, RealityWindow, CapacityShape, CaptureIntake, ClosureOutcome, ProofEvent, RecoveryState, UserSystemProfile.

Behavior seams mapped: `SCG006-F03`, `F05`, `F06`, `F08`, `F09`, `F10`, `F11`, `F14`, `F15`, `F16`.

Known-issues rows touched: none modified; existing rows mapped as above.

SCG-009B / SCG-009C readiness decision: SCG-009B may begin after this audit closeout; SCG-009C should wait for SCG-009B unless SCG-009B closes no-repair-required.

Validation run: architecture inventory pass; quality gate pass; test-strength audit pass; senior-code-audit ran and failed/capped; diff check pass; status check pass.

Validation failed/capped: `python3 scripts/ambitions-senior-code-audit.py --json` exited 1 with existing SCG-004 repo findings and scope-guard failures; treated as Yellow/capped input, not as SCG-009A production repair.

Linear updates: pending commit/push.

Remaining gaps: domain authority decisions for GoalThread/UserSystemProfile, typed closure proof/receipt/undo classification, behavior-proof upgrades, offline/no-account proof, permission-denied proof, device/runtime/manual proof outside this train.

Rollback plan: revert the audit artifact commit. No production rollback required.
