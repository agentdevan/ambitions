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
- Current RuntimeBoundary source under `Core/LocalRuntimeOS/RuntimeBoundary/`, command-spine source under `Core/LocalRuntimeOS/CommandSpine/`, the `RuntimeMutation` bridge under `Core/LocalRuntimeOS/TransactionKernel/`, the EventJournal foundation under `Core/LocalRuntimeOS/EventJournal/`, the ProjectionEngine foundation under `Core/LocalRuntimeOS/ProjectionEngine/`, the Storage foundation under `Core/LocalRuntimeOS/Storage/`, the ObjectState foundation under `Core/LocalRuntimeOS/ObjectState/`, the PrivateLifeRuntimeKernel foundation under `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/`, the PlanningEngine foundation under `Core/LocalRuntimeOS/PlanningEngine/`, the TimeEngine foundation under `Core/LocalRuntimeOS/TimeEngine/`, the CaptureRouteGraph foundation under `Core/LocalRuntimeOS/CaptureRouteGraph/`, the SideEffectSystem foundation under `Core/LocalRuntimeOS/SideEffectSystem/`, the SyncContinuity foundation under `Core/LocalRuntimeOS/SyncContinuity/`, the PrivacySecurity foundation under `Core/LocalRuntimeOS/PrivacySecurity/`, the MigrationRepair foundation under `Core/LocalRuntimeOS/MigrationRepair/`, the Diagnostics foundation under `Core/LocalRuntimeOS/Diagnostics/`, and the SearchRecall foundation under `Core/LocalRuntimeOS/SearchRecall/` are source-present starts of the LocalRuntimeOS migration. Remaining `Core/Runtime/`, `Core/Persistence/`, and legacy projection-owner source is implementation scaffolding unless future source proof migrates or proves the responsibility under `Core/LocalRuntimeOS/`.

---

## 3. Truth Hierarchy and Conflict Resolution

Active truth hierarchy:

1. `docs/truth/CODEX_START_HERE.md` — routing/digest aid only, subordinate to substantive truth files.
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md` — product/design authority.
3. `docs/truth/PRODUCT_ORIGIN_TRUTH.md` — origin/problem framing authority when present.
4. `docs/truth/PRODUCT_MOAT_TRUTH.md` — moat and anti-commodity authority.
5. `docs/truth/PRODUCT_EXPERIENCE_CANON.md` — product-experience behavior, feature behavior, scenario gates, and actionability authority.
6. `docs/truth/IMPLEMENTATION_TRUTH.md` — source implementation authority.
7. `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md` — rendered-product acceptance and split-status authority.
8. `docs/truth/RELEASE_TRUTH.md` — validation/release/proof authority.
9. `docs/truth/CODEX_PROCESS_TRUTH.md` — Codex operating authority.
10. `docs/truth/HISTORICAL_POLICY.md` — repo retention and stale-file deletion authority.
11. `AGENTS.md` — front-door agent contract.
12. Current source, tests, scripts, logs, proof artifacts, `project.yml`, and `Package.swift`.

Conflict rules:

- Product/design conflict: `PRODUCT_DESIGN_TRUTH.md` wins.
- Origin/problem framing conflict: `PRODUCT_ORIGIN_TRUTH.md` wins only for origin doctrine and remains subordinate to product/design, moat, and product-experience law.
- Product-experience behavior conflict: `PRODUCT_EXPERIENCE_CANON.md` wins unless root IA/privacy/product identity or moat guardrails are at issue.
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

---

## 5. Planning and Patch Discipline

Before editing, Codex must read truth files, inspect live source, identify task type, define narrow scope, list likely touched files, list validation commands, identify rollback, and identify hard-red risks. For work touching Life Capital, goal pathing, Future Steps, continuous adjustment, onboarding, reviews, Source Atlas composition, proof/progress transfer, automation, notifications, or scenario gates, Codex must also map the intended behavior to `PRODUCT_EXPERIENCE_CANON.md` and report which scenario gates are Existing, Partial, Missing, or Unknown.

For LocalRuntimeOS, backend/runtime architecture, mutation, persistence substrate, projection, replay, side-effect, capture intake, privacy boundary, Source Atlas runtime boundary, search/recall, sync continuity, migration, repair, or diagnostics work, Codex must start from Linear `AMB-1544` and the active leaf. As of 2026-06-30, `AMB-1545` is canon/process tracking only, `AMB-1546` covers the first command/transaction source move, `AMB-1547` covers the EventJournal foundation, `AMB-1548` covers the ProjectionEngine foundation, `AMB-1549` covers the Storage foundation and SwiftData object-store ownership move, `AMB-1553` covers the RuntimeBoundary foundation and moved local-only/privacy/source-atlas boundary ownership, `AMB-1554` covers the ObjectState foundation and AppState store adapter proof, `AMB-1555` covers the PrivateLifeRuntimeKernel ownership move and typed-signal foundation, `AMB-1556` covers the PlanningEngine ownership move with moved planning, StepCandidateField, and StepCandidateField generator/Source Atlas bridge files plus focused planning and simulation-gauntlet tests, `AMB-1557` covers the TimeEngine ownership move with moved protected/priority placement policies, local temporal graph/store/recurrence/conflict/placement/recovery engines, Time placement coordinator consumption, and focused protected placement, conflict, recurrence, and persistence tests, `AMB-1558` covers the CaptureRouteGraph foundation with moved route graph ownership, durable intake before classification, draft/direct lookup indexes, attachment checksum/quarantine, correction ledger, promotion transactions, and focused capture route/integration tests, `AMB-1560` covers the SearchRecall foundation with moved local search index ownership and focused Find / Act / Inspect, provenance, privacy, action validation, local semantic ranking, and projection-fed rebuild tests, `AMB-1561` covers the first SideEffectSystem foundation with moved side-effect ledger ownership and focused outbox tests, `AMB-1562` covers the first SyncContinuity foundation with moved SyncCapability/CloudKit continuity/LivingPlan continuity ownership and focused continuity-boundary tests, `AMB-1564` covers the first PrivacySecurity foundation with moved storage privacy boundary ownership and focused redaction/egress/export/local-auth/vault tests, `AMB-1565` covers the first MigrationRepair foundation with focused schema-ledger/planner/dry-run/rollback/quarantine tests, and `AMB-1566` covers the first Diagnostics foundation with redacted local-backend inspectors and performance-budget diagnostics. Later bounded leaves must continue through the full `Core/LocalRuntimeOS/` subtree coverage ledger rather than treating the initial leaves as implementation completion.

Codex must not broad-edit without scope, rewrite major canon unless explicitly authorized, mutate app behavior during docs/governance tasks unless scoped, create new runtime dependencies without approval, silently accept stale tests/scripts as active truth, or bulk update snapshots/proof artifacts to hide failures.

---

## 6. Validation and Proof Discipline

Codex must follow `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`.

Do not write one unqualified `Green`. Use Source Green, Runtime Green, Interaction Green, Visual Green, Release Green, Ready for Visual Review, Yellow, or Red.

Codex may not self-certify Visual Green or Release Green. For visual/product-surface work, Codex may prepare source, tests, screenshots, target comparison, and proof packets, then move the work to Ready for Visual Review at most.

A Green claim requires proof appropriate to scope:

- Docs/process: truth-file diff, authority scan, forbidden-claim scan when applicable.
- Swift source: build, focused tests where practical, and affected ownership proof.
- UI: screenshot or not-run reason, Dynamic Type, VoiceOver, Reduce Motion, and safe-area proof notes.
- SwiftData/persistence: migration/default-value safety and rollback/data proof.
- Release: release truth plus current build/test/device/signing proof.

No Codex report may claim build, device, release, privacy, account, R2, accessibility, performance, TestFlight, App Store, or production readiness without current evidence.

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
- source changes cannot be validated honestly
- tests are updated to hide failures instead of validating truth
- generated reports are treated as release proof
- screenshot paths or source-string tests are treated as visual acceptance
- Codex self-certifies Visual Green or Release Green
- new meaningful runtime mutation authority is added outside `Core/LocalRuntimeOS/CommandSpine/`, `TransactionKernel/`, `EventJournal/`, `ProjectionEngine/`, `Storage/`, and receipt/replay semantics without explicit scoped Yellow debt and a named follow-up issue

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
