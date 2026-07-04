# CODEX_PROCESS_TRUTH.md

Status: Active Codex operating truth  
Scope: Codex read order, planning, autonomy, repair loops, gates, claim discipline, cleanup rules, and final reporting  
Applies to: All Codex/AI work in the Ambitions repo  
Owner posture: Operational authority, not product design and not implementation proof  
Effective rule: Codex may be autonomous only inside evidence-bound, truth-file-bound, user-approved limits.

## Codex digest
- Read when: Codex is planning, editing, validating, reporting, cleaning docs, updating gates, or deciding claim/status language.
- Owns: Codex operating behavior, evidence-bound autonomy, validation/reporting discipline, cleanup rules, and hard Red process stops.
- Does not own: product/design doctrine, implementation proof, release proof, or retention policy when those files are stricter.
- Hard red: skipping truth/source inspection, hiding failures, broad unscoped edits, stale-canon revival, tests that hide failures, proof overclaims, or Visual/Release Green self-certification.
- Proof/closeout impact: reports must be scoped, evidence-backed, and explicit about validation not run.

---

## 1. Purpose and Authority

This file defines how Codex must operate in the Ambitions repo.

Codex must prevent:

- reviving obsolete canon
- treating Motion as a root destination
- treating Capture as a root destination
- drifting into generic UI
- implementing from old docs
- claiming unproven work
- skipping validation
- broad-editing the repo without a plan
- adding hosted AI/cloud LLM dependencies
- treating the LocalRuntimeOS target architecture as already implemented
- bypassing the Command -> Event -> Projection -> Receipt -> Replay law for new meaningful runtime mutations
- turning Ambitions Account work into private life graph backend work
- sending private user data to R2/Source Atlas
- treating batch docs as release proof
- hiding failures
- overclaiming completion
- presenting aspirational architecture or doctrine as current implementation
- adding new architecture nouns before deleting or collapsing duplicate authority
- exposing runtime lore as product UI depth

Codex must follow this file for repo inspection, implementation, docs work, validation, repair loops, cleanup, release reporting, and final status reports.

---

## 2. Active Product Law Codex Must Preserve

Codex must preserve this root product law:

```text
Persistent surfaces: Today / Goals / Time / You
Global composer: Capture
Behavior layer: Motion
Trust layer: Proof / Source / Privacy / History / Receipts
```

Codex must also preserve Ambitions' supreme product mission lens:

```text
Ambitions is a private Personal Life OS for contextual life orchestration.
Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning
```

Codex must treat:

- Capture as global composer/overlay, not root destination.
- Motion as Stage/Motion behavior, not root destination.
- Plan/Profile/Captures/Pulse/Motion-tab/Capture-tab references as compatibility debt or historical context unless a scoped migration issue says otherwise.
- Ambitions Account as optional launch identity/entitlement infrastructure when scoped.
- The offline core app value as mandatory with no account and no network dependency.
- Ambitions Account work as forbidden from storing or syncing the private life graph unless future canon explicitly approves user-owned sync.
- R2/Source Atlas as public/reference/freshness infrastructure only.
- R2 is not a user-data backend and must never receive, store, infer, personalize from, or transmit private user life data.
- Hosted AI services, external/cloud LLMs, and cloud model APIs as excluded from core architecture and not core app runtime dependencies.
- New backend/runtime authority belongs under `Core/LocalRuntimeOS/` and must preserve the `Command -> Event -> Projection -> Receipt -> Replay` target law.
- Current Boundary source under `Core/LocalRuntimeOS/Boundary/`, Commands source under `Core/LocalRuntimeOS/Commands/`, the Transactions foundation under `Core/LocalRuntimeOS/Transactions/`, the EventJournal foundation under `Core/LocalRuntimeOS/EventJournal/`, the Projections foundation under `Core/LocalRuntimeOS/Projections/`, the Storage foundation under `Core/LocalRuntimeOS/Storage/`, the ObjectState foundation under `Core/LocalRuntimeOS/ObjectState/`, the PrivateLifeRuntimeKernel foundation under `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/`, the PlanningEngine foundation under `Core/LocalRuntimeOS/PlanningEngine/`, the TimeEngine foundation under `Core/LocalRuntimeOS/TimeEngine/`, the CaptureRouteGraph foundation under `Core/LocalRuntimeOS/CaptureRouteGraph/`, the TrustSystem foundation under `Core/LocalRuntimeOS/TrustSystem/`, the SearchRecall foundation under `Core/LocalRuntimeOS/SearchRecall/`, the SideEffectSystem foundation under `Core/LocalRuntimeOS/SideEffectSystem/`, the SyncContinuity foundation under `Core/LocalRuntimeOS/SyncContinuity/`, the SourceAtlas foundation under `Core/LocalRuntimeOS/SourceAtlas/`, the PrivacySecurity foundation under `Core/LocalRuntimeOS/PrivacySecurity/`, the MigrationRepair foundation under `Core/LocalRuntimeOS/MigrationRepair/`, and the Diagnostics foundation under `Core/LocalRuntimeOS/Diagnostics/` are source-present starts of the LocalRuntimeOS migration. Remaining `Core/Runtime/`, `Core/Persistence/`, and legacy projection-owner source is implementation scaffolding unless future source proof migrates or proves the responsibility under `Core/LocalRuntimeOS/`.

---

## 3. Truth Hierarchy and Conflict Resolution

Active truth hierarchy:

1. `docs/truth/CODEX_START_HERE.md` — routing/digest aid only, subordinate to substantive truth files.
2. `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md` — supreme product mission, app purpose, primary function, core loop, and anti-drift lens.
3. `docs/truth/PRODUCT_DESIGN_TRUTH.md` — product/design authority.
4. `docs/truth/PRODUCT_ORIGIN_TRUTH.md` — origin/problem framing authority when present.
5. `docs/truth/PRODUCT_MOAT_TRUTH.md` — moat and anti-commodity authority.
6. `docs/truth/PRODUCT_EXPERIENCE_CANON.md` — product-experience behavior, feature behavior, scenario gates, and actionability authority.
7. `docs/truth/IMPLEMENTATION_TRUTH.md` — source implementation authority.
8. `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md` — rendered-product acceptance and split-status authority.
9. `docs/truth/RELEASE_TRUTH.md` — validation/release/proof authority.
10. `docs/truth/CODEX_PROCESS_TRUTH.md` — Codex operating authority.
11. `docs/truth/HISTORICAL_POLICY.md` — repo retention and stale-file deletion authority.
12. `AGENTS.md` — front-door agent contract.
13. Current source, tests, scripts, logs, proof artifacts, `project.yml`, and `Package.swift`.

Conflict rules:

- Product mission, app purpose, primary function, and end-goal conflict: `PRIVATE_LIFE_ORCHESTRATION_TRUTH.md` wins.
- Product/design, root IA, surfaces, privacy/product law, visual/product canon, and Final Architecture Tree conflict: `PRODUCT_DESIGN_TRUTH.md` wins, read through `PRIVATE_LIFE_ORCHESTRATION_TRUTH.md` for mission and primary function.
- Origin/problem framing conflict: `PRODUCT_ORIGIN_TRUTH.md` wins only for origin doctrine and remains subordinate to supreme product mission, product/design, moat, and product-experience law.
- Product-experience behavior conflict: `PRODUCT_EXPERIENCE_CANON.md` wins unless supreme product mission, root IA/privacy/product identity, or moat guardrails are at issue.
- Implementation/source conflict: `IMPLEMENTATION_TRUTH.md` plus live source wins.
- Rendered acceptance conflict: `IMPLEMENTATION_ACCEPTANCE_TRUTH.md` wins for split status, visual proof limits, and product-object acceptance unless release proof is stricter.
- Release/readiness conflict: `RELEASE_TRUTH.md` plus current proof wins.
- Codex routing conflict: substantive truth files and current user/issue instructions win over `CODEX_START_HERE.md`.
- Historical artifacts lose unless explicitly promoted by a truth file.
- Docs-only plans never prove implementation.

---

## 4. Codex Mission

Codex’s mission in Ambitions is to behave like a controlled senior engineering team:

```text
Read truth first.
Inspect source.
Plan narrowly.
Patch deliberately.
Validate honestly.
Repair with evidence.
Stop on hard Red.
Report without overclaiming.
```

Codex must optimize for:

- source truth
- product truth
- local-first architecture
- offline core behavior
- optional account identity/entitlement boundaries
- R2/Source Atlas public-reference boundaries
- native iPhone quality
- testability
- accessibility
- performance
- privacy
- repo cleanliness
- reversible changes
- truthful claims

Codex must not optimize for appearing done, broad diff volume, speculative implementation, old-canon compliance, visual gimmicks, cloud shortcuts, deleting complexity without extraction, or release claims without proof.

Architecture simplification posture:

```text
law over lore
deep runtime, boring UI
delete before naming
Green requires linked evidence
```

Codex must preserve stable product/runtime/privacy/proof law, reduce private architecture mythology, keep root UI in plain native life-object terms, and avoid new broad nouns unless the scoped work deletes, collapses, or replaces duplicate authority. Proof automation outranks prose: current checks, logs, proof packets, and accepted artifacts set the claim ceiling. A status claim may be Green only when the exact claim has current linked evidence.

AMB-1658 remediation governance rules:

- No new architecture nouns without deletion, collapse, or replacement of duplicate authority in the same scoped train.
- No new mutation, storage, receipt, replay, side-effect, migration, repair, privacy, sync, projection-materialization, or diagnostics authority outside `Core/LocalRuntimeOS/`.
- No new Source Atlas scope before an ADR allowlists the changed file and Source Atlas boundary audits pass for the changed scope.
- No new `+02`, `+03`, or `+04` split files.
- No new broad `Models.swift` files.
- No touched production Swift file may exceed the hard line cap without scoped deletion, collapse, or extraction proof.
- No package extraction, package splitting, or package-boundary movement as cleanup theater.
- Adapters cannot mutate canonical state.
- Prefer feature-local projection over central `Projection/SurfaceLenses` additions when canon allows.
- SwiftUI-native implementation is the default; custom Stage, UIKit, or rendering machinery requires product-law and Apple-source justification.

Architecture remediation and cleanup trains must run:

```bash
python3 scripts/ambitions-remediation-governance-check.py
```

The remediation governance check must report root LOC, largest production Swift
files, naming counts, suffix-split counts, Source Atlas file counts, and
hard-cap file counts. These reports are baseline evidence only; they do not
turn existing Yellow debt Green.

For branch or PR validation:

```bash
python3 scripts/ambitions-remediation-governance-check.py --base origin/main
```

Accepted Yellow is forbidden for incomplete required remediation scope. If an
issue requires source changes, deletion/quarantine, runtime enforcement,
direct-write removal, command/rejection receipt behavior, migration proof,
projection safety, or executable tests, the issue must remain `In Progress`,
move to `Needs Repair`, or wait in `Ready For Review` until implementation and
proof exist. A docs-only leaf may close within docs-only scope, but it cannot
close a source/runtime parent whose acceptance requires actual code, tests,
deletion, migration, or device/release proof.

Required scope rule: if the issue says guarantee, end, remove, delete, route,
prove, block, cannot, must, or no path, documenting the gap is not enough.

M02 Runtime Strangler is not Green until legacy runtime authority is removed or
adapter/test-only, persistence direct writes are removed or blocked, external
adapters route through command/rejection receipts, and executable proof exists.
Until then, M02 can only be described as partially remediated and must block
downstream Green claims.

Every remediation parent Feature closeout must include:

- status: Green, Yellow, or Red for the exact parent scope
- validation run
- validation not run with the reason
- proof artifacts, or an explicit empty list when none were produced
- known risks and residual Yellow/Red gaps
- exact next Linear follow-up for every residual gap
- rollback plan

If required validation, proof artifacts, owner review, or approvals are absent,
the parent closeout must be Yellow or Red for that claim, not Green. Release,
device, accessibility, privacy/legal, TestFlight, App Store, account, R2,
production CloudKit, and production readiness claims are forbidden without
current artifacts and required approvals.

---

## 5. Planning and Patch Discipline

Before editing, Codex must read truth files, inspect live source, identify task type, define narrow scope, list likely touched files, list validation commands, identify rollback, identify hard-red risks, and classify the claim being made with the truth-claim taxonomy in `CODEX_START_HERE.md`: Implemented Green, Implemented Yellow, Partial, Aspirational, Deprecated, Blocked, or Unknown. Every nontrivial issue, plan, and closeout must state how it preserves or improves `Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning`, or explicitly state that the work is narrow repo health, security, build, or cleanup work that does not affect product mission. Closeouts should include the canonical Private Life Orchestration closeout phrase from `PRIVATE_LIFE_ORCHESTRATION_TRUTH.md` or an equivalent scoped statement. For work touching Life Capital, goal pathing, Future Steps, continuous adjustment, onboarding, reviews, Source Atlas composition, proof/progress transfer, automation, notifications, or scenario gates, Codex must also map the intended behavior to `PRODUCT_EXPERIENCE_CANON.md` and report which scenario gates are Existing, Partial, Missing, or Unknown.

After resume, interruption, or context compaction, Codex must rehydrate the
active task before acting: newest user-visible instruction wins over summaries,
memory, stale Linear state, and earlier task variants. Re-run repo orientation,
inspect the current diff, run the relevant local guard for the active task, and
refresh tracker state for any issue being claimed or mutated. If the compacted
summary points to an older task than the newest user request, stop that older
task and follow the newest request.

For LocalRuntimeOS, backend/runtime architecture, mutation, persistence substrate, projection, replay, trust/receipt/proof/history, side-effect, capture intake, privacy boundary, Source Atlas runtime boundary, search/recall, sync continuity, migration, repair, or diagnostics work, Codex must start from Linear `AMB-1544` and the active leaf. As of 2026-06-30, `AMB-1545` is canon/process tracking only, `AMB-1546` covers the first command source move, `AMB-1567` covers the Transactions foundation with validated transaction preparation, event/projection-backed commit receipts, idempotency replay, rollback plans, and conflict detection, `AMB-1547` covers the EventJournal foundation, `AMB-1548` covers the Projections foundation, `AMB-1549` covers the Storage foundation and SwiftData object-store ownership move, `AMB-1553` covers the Boundary foundation and moved local-only/privacy/source-atlas boundary ownership, `AMB-1554` covers the ObjectState foundation and AppState store adapter proof, `AMB-1555` covers the PrivateLifeRuntimeKernel ownership move and typed-signal foundation, `AMB-1556` covers the PlanningEngine ownership move with moved planning, StepCandidateField, and StepCandidateField generator/Source Atlas bridge files plus focused planning and simulation-gauntlet tests, `AMB-1557` covers the TimeEngine ownership move with moved protected/priority placement policies, local temporal graph/store/recurrence/conflict/placement/recovery engines, Time placement coordinator consumption, and focused protected placement, conflict, recurrence, and persistence tests, `AMB-1558` covers the CaptureRouteGraph foundation with moved route graph ownership, durable intake before classification, draft/direct lookup indexes, attachment checksum/quarantine, correction ledger, promotion transactions, and focused capture route/integration tests, `AMB-1559` covers the TrustSystem foundation with moved event ledger, action receipt, proof ledger, source record, tombstone, replay, history, audit, undo, and trust repository ownership, `AMB-1560` covers the SearchRecall foundation with moved local search index ownership and focused Find / Act / Inspect, provenance, privacy, action validation, local semantic ranking, and projection-fed rebuild tests, `AMB-1561` covers the first SideEffectSystem foundation with moved side-effect ledger ownership and focused outbox tests, `AMB-1562` covers the first SyncContinuity foundation with moved SyncCapability/CloudKit continuity/LivingPlan continuity ownership and focused continuity-boundary tests, `AMB-1563` covers the SourceAtlas foundation with moved Source Atlas model/cache/runtime ownership and focused public-pack compiler/firewall/manifest/freshness/cache/projection tests, `AMB-1564` covers the first PrivacySecurity foundation with moved storage privacy boundary ownership and focused redaction/egress/export/local-auth/vault tests, `AMB-1565` covers the first MigrationRepair foundation with focused schema-ledger/planner/dry-run/rollback/quarantine tests, and `AMB-1566` covers the first Diagnostics foundation with redacted local-backend inspectors and performance-budget diagnostics. Later bounded leaves must continue through the full `Core/LocalRuntimeOS/` subtree coverage ledger rather than treating the initial leaves as implementation completion.

`AMB-1568` covers the Commands journal/receipt/replay extraction with source-present command envelope, compiler, authorizer, idempotency key, durable journal, reducer, receipt factory, replay adapter, app-container journal wiring, and focused tests for append-before-mutation, replay, denial, reducer output, typed receipts, Today command routing, and journal-failure blocking. It remains bounded proof and must not be treated as full LocalRuntimeOS completion.

As of `AMB-1599`, the checked-in `docs/qa/local-runtime-proof/current-local-runtime-proof.json` and `docs/qa/local-runtime-proof/current-local-runtime-proof.md` artifacts record LocalRuntimeProof Gate Green for `20` semantic/fail-closed LRO-100 checklist items and `0` blockers, including live SQLite event authority, command/event reconciliation, fail-closed commit policy, transaction-coordinator ownership, projection/search read gates, sanitized external-surface reads, PrivacySecurity and Source Atlas/R2 boundaries, SyncContinuity non-authority, durable Capture intake, side-effect receipt gating, TrustSystem lineage, mutation-context boundaries, RuntimeDoctor local drift repair previews, mutation-bypass scan, feature-service classification, and Known Issues/truth/CI proof-ceiling evidence. It remains source/runtime-gate proof only: do not report device, visual, release, privacy/legal, TestFlight, App Store, production R2, production CloudKit, or product-completion claims from it.

Codex must not broad-edit without scope, rewrite major canon unless explicitly authorized, mutate app behavior during docs/governance tasks unless scoped, create new runtime dependencies without approval, silently accept stale tests/scripts as active truth, or bulk update snapshots/proof artifacts to hide failures.

---

## 6. Validation and Proof Discipline

Codex must follow `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`.

Do not write one unqualified `Green`. Use Source Green, Runtime Green, Interaction Green, Visual Green, Release Green, Ready for Visual Review, Yellow, or Red.

Codex may not self-certify Visual Green or Release Green. For visual/product-surface work, Codex may prepare source, tests, screenshots, target comparison, and proof packets, then move the work to Ready for Visual Review at most.

A Green claim requires linked current evidence artifacts appropriate to scope:

- Docs/process: truth-file diff, authority scan, forbidden-claim scan when applicable.
- Swift source: build, focused tests where practical, and affected ownership proof.
- UI: screenshot or not-run reason, Dynamic Type, VoiceOver, Reduce Motion, and safe-area proof notes.
- SwiftData/persistence: migration/default-value safety and rollback/data proof.
- Release: release truth plus current build/test/device/signing proof.

No Codex report may claim build, device, release, privacy, account, R2, accessibility, performance, TestFlight, App Store, or production readiness without current evidence.

For LocalRuntimeOS completion claims, Codex must run `scripts/ambitions-local-runtime-proof.py` in addition to architecture inventory and focused runtime tests. A passing final-tree inventory proves source parity only; it does not prove app-wide command-only mutation, event replay, projection consumption, side-effect outbox enforcement, privacy boundary enforcement, or LocalRuntimeProof Green.

---

## 7. Hard Red Conditions

Stop and report Red when:

- current product law is ambiguous or contradicted
- Motion is reintroduced as a root destination
- Capture is reintroduced as a root destination
- stale five-surface IA with Motion as a root destination is promoted as current or active
- account sign-in becomes required for core offline use
- private life graph backend behavior appears
- R2 receives or stores private user context
- hosted AI/cloud LLMs become core runtime dependencies
- work cannot explain its relationship to Private Life Orchestration unless it is narrow repo health, security, build, or cleanup work
- source changes cannot be validated honestly
- tests are updated to hide failures instead of validating truth
- generated reports are treated as release proof
- screenshot paths or source-string tests are treated as visual acceptance
- Codex self-certifies Visual Green or Release Green
- new meaningful runtime mutation authority is added outside `Core/LocalRuntimeOS/Commands/`, `Transactions/`, `EventJournal/`, `Projections/`, `Storage/`, and receipt/replay semantics without explicit scoped Yellow debt and a named follow-up issue

---

## 8. Local Output and Retention Policy

Codex may generate local validation output during active work, but generated state is ignored by default and is not retained as history.

Current policy:

- Do not add tracked prompts, trains, Codex run-state, old artifacts, proof matrices, or generated logs.
- Keep local validation output under ignored local paths unless the current task explicitly requires a compact retained proof file.
- Old proof is not App Store proof.
- One commit per Green work slice is preferred when the user requests sequential train work.
- Commit cleanup separately from feature/source work when a cleanup pass precedes implementation.

This is process authority only. It does not prove implementation, release readiness, account behavior, R2 behavior, privacy compliance, or accessibility compliance.
