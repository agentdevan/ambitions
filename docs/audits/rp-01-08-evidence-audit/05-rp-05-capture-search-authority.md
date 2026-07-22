<!-- markdownlint-disable MD013 MD060 -->

# RP-05 — Capture and Search Authority

Audit base: `main` at `29872755f705f6bd8e276aeac86dcf376ac5f0d8` on 2026-07-22.

## Executive verdict

`PARTIALLY_SUPPORTED`. Capture can accept text, produce a deterministic local proposal, commit a bounded quick-capture path through local authority, and perform one durable Capture-to-Goal handoff. Most post-capture routing and cross-root mutation paths remain explicitly unproven. Search can find and open local repository-backed results with deterministic ranking and limited inspection, but its active UI does not implement the provisional Find / Understand / Act journey: it offers navigation, not material action proposals; natural-language understanding is token/keyword-based; provenance and freshness labels are largely derived by result kind; failures collapse to an empty result; and Search/Capture session inputs are not durably restored.

The authority boundary itself is compatible with the visual program: Search should remain non-mutating and transfer consequence to canonical owners, while Capture may own confirmed creation and bounded handoff. The protected journeys require runtime and UX reconciliation before they can be rendered as supported behavior.

Primary dispositions: `VISUAL_DIRECTION_SURVIVES`, `TARGETED_VISUAL_REFINEMENT_REQUIRED`, `ARCHITECTURE_DECISION_REQUIRED`, `UX_BLUEPRINT_DECISION_REQUIRED`, `RUNTIME_CAPABILITY_REQUIRED`, `RECONSTRUCTION_PLAN_ACTION_REQUIRED`.

## Scope and authoritative sources

This packet audits Capture invocation, draft/input, interpretation, clarification, consequences, commitment, settlement, offline/external entry, and restoration; and Search indexing, object coverage, Find / Understand / Act, provenance, freshness, history, mutation transfer, offline behavior, and restoration.

Live source and the current mutation registry are implementation authority. Current canon is used only to identify the intended owner-routed boundary. Attached Campaigns 03, 07, 09, and 11 and the locked closure decisions are provisional visual authority, not capability evidence.

The audit coordinator’s targeted XCTest batch failed before execution with `FAILURE_CLASS=simulator_boot_failure` and `EXECUTED_TESTS=0`. Test names are inspection evidence only; no behavior claim is based on that batch.

## Current authority flows

```text
Capture text
  -> deterministic local extraction
  -> placement proposal (Accept / Change / Cancel)
  -> bounded quick-capture command authority
  -> committed capture event + projection materialization + receipt
  -> optional owner handoff
       proven: bounded Capture-to-Goal handoff
       unproven: most other routing / scheduling / archive paths

Search query
  -> local repository reads
  -> deterministic LocalSearchIndex ranking
  -> local result list
  -> Open / limited Inspect
  -> route to owning destination
  -> no material action commit in active Search UI
```

## Capture capability matrix

| Capability | Capability status | Repository finding | Evidence |
|---|---|---|---|
| Root-independent shell invocation | `PARTIALLY_SUPPORTED` | A shell command router overload exists, but shell-level restart/external lineage remains registry-unproven. | E05-01, E05-02 |
| Text entry | `SUPPORTED` | Capture composer owns editable `draftText` and proposal presentation. | E05-02 |
| Dictation | `PLANNED_NOT_IMPLEMENTED` | `voice` appears in staged-input models, while UI tests assert no dictation button and no production capture control was found. | E05-03 |
| Image/attachment intake | `PARTIALLY_SUPPORTED` | Durable intake/vault types exist; the mutation registry marks attachment file writes and share/import paths unproven. | E05-01, E05-03 |
| Share extension / App Intent entry | `PARTIALLY_SUPPORTED` | Source and extension paths exist, but registry rows are unproven for terminated-app lifecycle/reconciliation. | E05-01, E05-03 |
| Draft identity | `PARTIALLY_SUPPORTED` | View model creates a draft ID, but it is in-memory view-model state. | E05-02 |
| Draft persistence / resume | `ABSENT` | Active composer state uses stored properties with no durable draft-store binding in this path. | E05-02, E05-11 |
| Deterministic interpretation | `PARTIALLY_SUPPORTED` | Keyword lists and regular expressions classify activity, time, recurrence, location, and equipment. | E05-04 |
| Open-ended natural-language understanding | `ABSENT` | No semantic model/intent parser beyond deterministic patterns was found in the active extraction path. | E05-04 |
| Clarification | `PARTIALLY_SUPPORTED` | AM/PM ambiguity and proposal destination changes can require confirmation; arbitrary ambiguity dialogue is absent. | E05-04, E05-05 |
| Source-linked correction | `PARTIALLY_SUPPORTED` | “Why this placement” and destination correction exist; durable correction history is not proven for Capture. | E05-05, E05-01 |
| Object/relationship identification | `PARTIALLY_SUPPORTED` | Smart attachment/proposal types identify suggested destinations and Goal linkage; forced canonical consolidation is not established. | E05-05 |
| Timing extraction | `PARTIALLY_SUPPORTED` | Relative-day, weekday, recurrence, and simple clock patterns are parsed. | E05-04 |
| Conflict detection before commit | `ABSENT` | Active Capture proposal has ambiguity/confirmation, not a multi-domain conflict result. | E05-04, E05-05 |
| Consequence generation | `PARTIALLY_SUPPORTED` | Proposal shows destination/object/time fit/goal/local status, but not cross-root scope consequences. | E05-05 |
| Direct local creation commit | `PARTIALLY_SUPPORTED` | Quick Capture authority/materialization is bounded and registry-proven only at the semantic snapshot layer. | E05-01, E05-06 |
| Prepare for another owner | `PARTIALLY_SUPPORTED` | Planning idea representation exists; scheduling explicitly remains unimplemented. | E05-06 |
| Cross-root mutations | `PARTIALLY_SUPPORTED` | Capture-to-Goal handoff is durable; most attachment, Time, archive, waiting, optional, and conversion paths are unproven. | E05-01 |
| Several related operations | `PARTIALLY_SUPPORTED` | One atomic Capture-to-Goal transition exists; no generic multi-owner operation group exists. | E05-01 |
| Preserve unaffected interpretation after correction | `UNKNOWN` | Proposal state can change destination, but no durable multi-field correction/retry proof was established. | E05-05 |
| Partial settlement | `ABSENT` | Command/receipt state has no per-scope settlement model. | E05-07 |
| Receipt | `PARTIALLY_SUPPORTED` | Bounded committed Capture paths emit runtime receipts; broad routing coverage remains unproven. | E05-01, E05-06 |
| Undo | `PLANNED_NOT_IMPLEMENTED` | No Capture-specific executable inverse path is registry-proven. | E05-01 |
| Offline core creation | `PARTIALLY_SUPPORTED` | Active stores and interpretation are local; broad route/attachment parity remains unproven. | E05-01, E05-12 |
| Exact-context return | `ABSENT` | Draft/focus/keyboard/stage restoration is not durably represented. | E05-02, E05-11 |

## Capture stage support matrix

| Provisional stage | Capability status | Current support | Gap |
|---|---|---|---|
| Express | `PARTIALLY_SUPPORTED` | Text works; source models name voice/image/share. | Voice/image controls and durable draft resume are not production-proven. |
| Meaning | `PARTIALLY_SUPPORTED` | Deterministic keyword/regex extraction and route proposal. | No broad semantic understanding, identity consolidation, or causal explanation. |
| Clarification / Review | `PARTIALLY_SUPPORTED` | Accept, change destination, cancel, AM/PM confirmation, “Why this placement.” | No general multi-question clarification, conflict resolution, or scope preview. |
| Commitment | `PARTIALLY_SUPPORTED` | Bounded quick Capture and Capture-to-Goal authority. | Most Capture routing/mutation rows remain unproven; scheduling is explicitly absent. |
| Settlement | `PARTIALLY_SUPPORTED` | Bounded runtime receipt and result. | No partial settlement, durable Capture Undo, or exact return. |

## Search capability matrix

| Capability | Capability status | Repository finding | Evidence |
|---|---|---|---|
| Search host | `SUPPORTED` | Shell Memory Lens overlay and query field exist. | E05-08 |
| Full-screen temporary iPhone presentation | `CONTRADICTED` | Active Search uses a sheet with 560-point and large detents. | E05-11 |
| Local index/search | `PARTIALLY_SUPPORTED` | Production boot creates an FTS store, while the active Memory Lens UI reads repositories and ranks an in-memory `LocalSearchIndex`. | E05-09, E05-12 |
| Searchable domains | `PARTIALLY_SUPPORTED` | Goals, actionable steps, captures, evidence/proof, feedback/recent change, teaching/learning, synthetic Time and settings. | E05-09 |
| Canonical identity consolidation | `PARTIALLY_SUPPORTED` | Results carry IDs and owner destinations; synthetic Time/settings rows and parallel FTS/repository paths weaken a single canonical index claim. | E05-09, E05-10 |
| Deterministic Find | `SUPPORTED` | Repository results are transformed and ranked locally. | E05-09 |
| Natural-language interpretation | `PARTIALLY_SUPPORTED` | Search tokenizes/ranks text; no active intent grammar or grounded answer synthesis was found. | E05-09 |
| Ranking explanation | `PARTIALLY_SUPPORTED` | FTS contract exposes matched terms/ranking signals; active Memory Lens shows contextual explanations, but not one verified provenance path. | E05-09, E05-10 |
| Provenance | `PARTIALLY_SUPPORTED` | FTS result contract carries event/object/source provenance; active results derive source evidence by result kind. | E05-09, E05-10 |
| Freshness | `PARTIALLY_SUPPORTED` | Results carry timestamps, but trust decay is assigned by kind and synthetic entries do not establish source verification time. | E05-09 |
| Current versus historical truth | `PARTIALLY_SUPPORTED` | Feedback/teaching/proof/receipt result kinds exist; no arbitrary historical-state comparison. | E05-09 |
| Uncertainty | `PARTIALLY_SUPPORTED` | Direct/inferred confidence labels exist, but no grounded uncertainty explanation for a natural-language answer. | E05-09 |
| Conflict | `ABSENT` | Search results do not expose a typed conflict state or conflict resolution action. | E05-08, E05-09 |
| Navigation / transfer to owner | `SUPPORTED` | Results route to owning destination; accessibility text explicitly says opening does not change saved data. | E05-08, E05-10 |
| Local material action | `ABSENT` | Search action contract contains only `open` and `inspect`; active UI routes results. | E05-08, E05-10 |
| Owner-routed action preparation | `PLANNED_NOT_IMPLEMENTED` | Canon requires it, but active UI has no material action proposal. | E05-08, E05-10, E05-13 |
| Durable Receipt discovery | `PARTIALLY_SUPPORTED` | Receipt is a result kind, but active repository coverage and universal receipt linkage are not proven. | E05-09 |
| Causal explanation | `PARTIALLY_SUPPORTED` | Why-now/learning/recent-change summaries exist; no general causal state-diff engine. | E05-09 |
| Offline local results | `PARTIALLY_SUPPORTED` | Reads local repositories and deterministic ranking; full index-health/rebuild/fallback behavior is not exposed. | E05-09, E05-12 |
| Query persistence/restoration | `ABSENT` | Query/results/status are SwiftUI `@State`; overlay query is loaded for presentation but no durable store is wired. | E05-11 |
| Failure disclosure | `CONTRADICTED` | Repository read errors return `[]`, which the UI reports as no local match. | E05-08, E05-09 |

## Find / Understand / Act support matrix

| Layer | Capability status | Finding | Visual implication |
|---|---|---|---|
| Find | `SUPPORTED` | Deterministic local retrieval and owner routing exist. | `VISUAL_DIRECTION_SURVIVES`. |
| Understand | `PARTIALLY_SUPPORTED` | Results carry static/derived explanation, confidence, source-kind, and context labels; no grounded answer or historical causal comparison. | `TARGETED_VISUAL_REFINEMENT_REQUIRED`, `RUNTIME_CAPABILITY_REQUIRED`. |
| Act | `ABSENT` in active Search UI | Only Open and Inspect are modeled; no material proposal, owner revalidation, confirmation, or settlement returns to Search. | `ARCHITECTURE_DECISION_REQUIRED`, `UX_BLUEPRINT_DECISION_REQUIRED`. |

## Search versus Capture authority boundary

| Boundary | Current evidence | Capability status | Required reconciliation |
|---|---|---|---|
| Search retrieves/ranks | Local repository/FTS contracts. | `SUPPORTED` for deterministic local Find. | Consolidate active index/provenance ownership. |
| Search explains | Derived result-kind labels and explanations. | `PARTIALLY_SUPPORTED`. | Define grounded evidence/freshness/uncertainty contract. |
| Search creates/mutates | No material Search action in active contract. | `ABSENT`. | Preserve non-authority; decide owner-routed proposal and return contract. |
| Search hands creation to Capture | Empty state can seed “Capture this.” | `PARTIALLY_SUPPORTED`. | Prove draft/query transfer and cancellation return. |
| Capture prepares | Proposal and planning idea representation. | `PARTIALLY_SUPPORTED`. | Define canonical owner acceptance for each route. |
| Capture authorizes creation | Bounded quick Capture path. | `PARTIALLY_SUPPORTED`. | Extend row-specific authority proof before broad visual promise. |
| Owning root commits | Proven for only selected owner paths. | `PARTIALLY_SUPPORTED`. | Owner validation/confirmation/Receipt must be explicit. |
| Settlement returns globally | No generic exact-context return/partial settlement. | `ABSENT`. | Define restoration and settlement transfer protocol. |

The current and canonical boundary does **not** support making Search a mutation owner. The visual program survives if “Act” means a proposal or transfer that commits inside the canonical owner. Whether the owner is shown in place, via handoff, or through another presentation is an `UX_BLUEPRINT_DECISION_REQUIRED` question, not an audit decision.

## Natural-language, provenance, freshness, and history limits

- Capture interpretation is deterministic keyword/regex processing [E05-04]. This supports transparent bounded extraction, not open-ended understanding.
- Search ranking is deterministic local text matching over assembled repository results [E05-09]. It does not establish question answering, intent recognition, or semantic retrieval across every domain.
- Search `sourceEvidence`, confidence, and trust-decay values are switched by result kind [E05-09]. These labels are useful UI metadata but do not prove source verification or freshness.
- FTS result contracts carry event/object provenance [E05-10], while the active Memory Lens path searches repositories [E05-09]. Architecture must select or reconcile the canonical search projection path.
- Historical result kinds exist, but arbitrary historical comparison and causal explanation are `PLANNED_NOT_IMPLEMENTED`.

## Offline and permission behavior

| Concern | Capability status | Finding |
|---|---|---|
| Local Capture text/proposal | `SUPPORTED` | No network dependency in active extraction/proposal code. |
| Local Capture commit | `PARTIALLY_SUPPORTED` | Bounded authority path is local; broad route coverage unproven. |
| Local Search Find | `SUPPORTED` | Active service reads local repositories and ranks locally. |
| Optional network/AI fallback | `ABSENT` | No hosted semantic service in active Capture/Search paths. |
| Attachment permissions/failures | `PARTIALLY_SUPPORTED` | Intake/vault types exist, but production lifecycle proof is unproven. |
| Voice/speech permission | `ABSENT` for Capture UI | No dictation control in active Capture UI. |
| External-entry retry/reconciliation | `PLANNED_NOT_IMPLEMENTED` | Share/App Intent registry rows remain unproven. |

## Visual-assumption comparison

| Provisional assumption | Capability status | Disposition | Direction IDs |
|---|---|---|---|
| Adaptive Meaning Fold phases remain distinguishable | `PARTIALLY_SUPPORTED` | `VISUAL_DIRECTION_SURVIVES`, `TARGETED_VISUAL_REFINEMENT_REQUIRED` | AVF-CAPTURE-S07-R00 |
| Capture understands arbitrary natural expression | `ABSENT` | `RUNTIME_CAPABILITY_REQUIRED`; withhold unsupported interpretations | AVF-CAPTURE-S07-R00, AVF-COHERENCE-S07-R00 |
| Capture commits coordinated cross-root changes | `PARTIALLY_SUPPORTED` | `ARCHITECTURE_DECISION_REQUIRED`, `RECONSTRUCTION_PLAN_ACTION_REQUIRED` | AVF-CAPTURE-S07-R00, AVF-RECOVERY-S07-R00 |
| Capture reports partial settlement | `ABSENT` | `RUNTIME_CAPABILITY_REQUIRED` | AVF-CAPTURE-S07-R00, AVF-RECOVERY-S07-R00 |
| Search is one Find / Understand / Act command field | `PARTIALLY_SUPPORTED` | `VISUAL_DIRECTION_SURVIVES`, `NEW_VISUAL_BRANCH_MAY_BE_REQUIRED` if architecture selects handoff-only behavior | AVF-SEARCH-D07-R00 |
| Search acts without becoming mutation authority | `PLANNED_NOT_IMPLEMENTED` | `ARCHITECTURE_DECISION_REQUIRED`, `UX_BLUEPRINT_DECISION_REQUIRED` | AVF-SEARCH-D07-R00, AVF-COHERENCE-S07-R00 |
| Search exposes reliable provenance/freshness/history | `PARTIALLY_SUPPORTED` | `TARGETED_VISUAL_REFINEMENT_REQUIRED`, `RUNTIME_CAPABILITY_REQUIRED` | AVF-SEARCH-D07-R00, AVF-RECOVERY-S07-R00 |
| Search failure is distinct from no result | `CONTRADICTED` | `UNSUPPORTED_VISUAL_BEHAVIOR_REMOVE` until error contract exists | AVF-SEARCH-D07-R00, AVF-RECOVERY-S07-R00 |
| Exact Capture/Search context returns after dismissal/interruption | `ABSENT` | `RUNTIME_CAPABILITY_REQUIRED`, `UX_BLUEPRINT_DECISION_REQUIRED` | AVF-CAPTURE-S07-R00, AVF-SEARCH-D07-R00 |

## Critical contradictions

1. The selected Search direction promises Find / Understand / Act, while active Search exposes Open/Inspect only [E05-08, E05-10].
2. Search promises trustworthy recovery, but repository failures collapse to an empty list and appear as “No local result matched” [E05-08, E05-09].
3. Capture visually implies coordinated cross-root settlement, while the registry proves one bounded Goal handoff and marks most other routes unproven [E05-01].
4. Staged voice/image/share types can be rendered as capability inventory, but type presence and preview projection do not prove active intake controls [E05-03].
5. Full-screen temporary Search is locked provisional intent; current presentation is a detented sheet [E05-11].
6. Exact-context return is promised, but Capture draft and Search query state are not durably restored [E05-02, E05-11].

## Required decisions

| Authority | Decision required |
|---|---|
| Devan | Whether Search “Act” must feel in-place or may visibly transfer to an owning root while preserving the selected visual identity. |
| Architecture | Select/reconcile the canonical active Search projection: FTS authority, repository aggregation, or an explicitly layered model. |
| Architecture | Define a typed global action-transfer envelope with canonical object ID, owner, current revision, preview, confirmation, result, Receipt, and return context. |
| Runtime | Define Capture multi-operation grouping and partial-settlement representation, or explicitly constrain Capture to one owner per commit. |
| Runtime | Add truthful Search error/index-health/freshness states and owner-routed action preparation. |
| UX Blueprint | Define unsupported/ambiguous Capture interpretation, correction preservation, failure/no-result distinction, and return-from-owner behavior. |
| Reconstruction planning | Remove or migrate direct Capture service mutations only after equivalent owner-authority/replay proof exists. |
| Accessibility/platform planning | Define focus restoration for Search/Capture handoff and interruption; current state persistence cannot guarantee it. |

## Unsupported provisional assumptions

- Full-screen Search is implemented: `CONTRADICTED`; current sheet geometry must not be documented as the locked behavior.
- Capture dictation and image input are active because staged-input cases exist: `CONTRADICTED`; keep explicitly provisional.
- Capture can schedule a Time-owned planning idea: `ABSENT`; source explicitly says scheduling is not implemented.
- Search can execute material actions: `ABSENT`; current actions are Open/Inspect.
- Search distinguishes failure from no result: `CONTRADICTED`; current error path returns `[]`.
- Search has authoritative freshness/provenance across all results: `PARTIALLY_SUPPORTED`; refine labels to source-backed facts.
- Capture/Search can always restore exact draft/query/focus context: `ABSENT`; requires runtime/restoration work.
- Cross-root partial settlement is available: `ABSENT`; keep provisional or omit.

## Reconstruction implications

- Preserve the non-mutating Search boundary; add typed owner handoff rather than a generic Search write path.
- Establish one canonical Search projection and prove index rebuild, privacy filtering, freshness, stable ID routing, and failure distinction.
- Route each Capture mutation through a named owner and expand the registry only with atomic/restart/replay tests.
- Bind draft/query/session restoration to durable or scene-restorable state before exact-return visuals are claimed.
- Add explicit capability gates for voice, image, attachments, external entry, owner actions, Receipt, Undo, and partial settlement.
- Do not delete legacy/direct paths until parity evidence exists; current registry is the migration risk map.

## Evidence appendix

| ID | Claim and capability status | Source, symbol, stable lines | Authority / currency | Verification and result | Confidence / remaining uncertainty | Directions |
|---|---|---|---|---|---|---|
| E05-01 | Capture mutation authority is mixed: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift`, lines 38-40, 151-206, 290-320, 352-403, 493-511. | Current source-owned proof registry. | `python3 scripts/ambitions-runtime-direct-write-audit.py --json` returned green registry coverage with 50 unproven production write-path rows; Capture-to-Goal is durable, most Capture/external rows unproven. | High for classification; fresh tests did not execute. | AVF-CAPTURE-S07-R00, AVF-RECOVERY-S07-R00. |
| E05-02 | Capture draft and authority entry are view-model-local/mixed: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Composer/Capture/CaptureViewModel.swift`, draft fields lines 73-94; proposal lines 121-156; direct/service and command-router save paths lines 158-236; post-save actions lines 238-340. | Current production UI/model source. | `rg -n "draftText\|commandRouter\|createQuickCapture\|routeToTime\|attachToGoal" ...` confirmed in-memory draft and parallel paths. | High for structure; no runtime execution. | AVF-CAPTURE-S07-R00. |
| E05-03 | Voice/image/share inventory does not prove active capability: `PLANNED_NOT_IMPLEMENTED` / `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/Domain/CaptureModels.swift`, `CaptureSourceType` lines 3-10 and `CaptureStagedInputKind` lines 142-170; `Native/AmbitionsUITests/CaptureComposerUITests.swift`, lines 23 and 73; registry lines 290-316, 407-413. | Current domain/test/registry source. | `rg` found staged kinds and UI assertions that dictation button does not exist; share/App Intent/attachment writes are registry-unproven. | High for current UI absence; attachment backend may support bounded internal cases not surfaced in active composer. | AVF-CAPTURE-S07-R00. |
| E05-04 | Capture understanding is deterministic and bounded: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/Domain/CaptureSemanticExtraction.swift`, lines 3-47, 51-68, 71-132, 135-180. | Current production domain source. | Source inspection found keyword arrays and regular expressions for activity/time/recurrence/location/equipment, including AM/PM clarification. | High. No broader interpreter was found in the active path. | AVF-CAPTURE-S07-R00, AVF-COHERENCE-S07-R00. |
| E05-05 | Capture proposal/review exists: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Composer/Capture/CaptureProposalStage.swift`, lines 4-35, 56-76, 79-139, 142-170. | Current UI source. | Source inspection found destination/object/time/goal/local-status summary, correction choices, “Why this placement,” Accept, Cancel. | High for source; no rendered/runtime proof. | AVF-CAPTURE-S07-R00. |
| E05-06 | Quick Capture authority exists but scheduling remains absent: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor+CaptureCommands.swift`, `executeQuickCapture` lines 4-63, materialization lines 65-135, routing lines 152-325; line 321 explicitly states scheduling is not implemented. | Current production executor source. | Source inspection confirmed bounded authority/materialization and planning representation without schedule commit. | High for source. | AVF-CAPTURE-S07-R00, AVF-TIME-S07-R00. |
| E05-07 | Capture partial settlement is absent: `ABSENT`. | `Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandResult.swift`, `AmbitionsCommandExecutionStatus`, lines 5-14. | Current shared result source. | `rg` for partial/uncertain scope settlement terms returned no source/test matches. | High for shared runtime representation. | AVF-CAPTURE-S07-R00, AVF-RECOVERY-S07-R00. |
| E05-08 | Active Search is local navigation/inspect only: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Stage/Overlays/QuietCommandMemoryLensOverlay.swift`, query lines 41-63, result action lines 118-189, refresh lines 192-210. | Current production UI source. | Source inspection found local query, route-on-select, “without changing saved data,” and no mutation control. | High for active UI. | AVF-SEARCH-D07-R00. |
| E05-09 | Active Search aggregates local repositories with derived trust labels and hides failures: `PARTIALLY_SUPPORTED`. | `Native/Ambitions/Core/LocalRuntimeOS/Search/MemoryLensService.swift`, result fields/derived labels lines 180-300; repository search/ranking lines 302-378. | Current production service source. | Source inspection found goals/steps/captures/evidence/feedback/teaching plus synthetic Time/settings; errors return `[]`. | High. Synthetic result construction and exact source freshness remain uncertain. | AVF-SEARCH-D07-R00, AVF-RECOVERY-S07-R00. |
| E05-10 | Search action contract supports Open/Inspect, not material Act: `ABSENT` for active Act. | `Native/Ambitions/Core/LocalRuntimeOS/Search/FindActInspectContract.swift`, `SearchActionKind` lines 100-103, result/provenance lines 136-235, owner destinations lines 264-280. | Current search contract source. | Source inspection found only `.open` and `.inspect`; no material action kind. | High. Future/other owner commands do not establish active Search Act. | AVF-SEARCH-D07-R00, AVF-COHERENCE-S07-R00. |
| E05-11 | Search is detented and session state is not durable: `CONTRADICTED` / `ABSENT`. | `Native/Ambitions/Stage/Overlays/QuietCommandSheetView.swift`, `@State` lines 11-15, `.presentationDetents` line 31, query loading lines 34-43; Capture view-model draft lines 73-94. | Current UI source. | Source inspection found sheet detents and transient SwiftUI/view-model state; no durable binding in these paths. | High for current implementation; scene-level restoration elsewhere could restore only broader shell state. | AVF-CAPTURE-S07-R00, AVF-SEARCH-D07-R00. |
| E05-12 | Production persistence is local and supplies SwiftData, SQLite event/projection, FTS, and file journal: `SUPPORTED` as storage substrate. | `Native/Ambitions/App/Bootstrap/PersistenceBootstrap.swift`, lines 3-54, 57-95, 97-118. | Current production bootstrap source; DEBUG seeding clearly separated. | Source inspection confirmed live local stores and DEBUG-only seed policy. | High for composition; feature behavior remains bounded by registry. | AVF-CAPTURE-S07-R00, AVF-SEARCH-D07-R00. |
| E05-13 | Canon requires owner-routed Search action and Capture-local commit: `PLANNED_NOT_IMPLEMENTED` where source is missing. | `docs/canon/specifications/journeys/search-find-act-inspect.md`, requirement at line 19 and commit-boundary section; `docs/canon/specifications/journeys/capture-to-placement.md`, requirement at line 57 and commit-boundary section. | Current canonical specification; authoritative target, non-authoritative for implementation. | `python3 scripts/ambitions-canon.py query "receipt undo search capture offline recovery"` returned both requirements and source-owner paths. | High for intended contract; not implementation proof. | AVF-CAPTURE-S07-R00, AVF-SEARCH-D07-R00. |
| E05-14 | Relevant tests exist but current execution is `UNKNOWN`. | `Native/AmbitionsTests/Runtime/P1FLocalSearchFoundationTests.swift`, tests lines 5, 108, 129; `Native/AmbitionsTests/LocalRuntimeOS/Transactions/RuntimeAtomicCommitTests.swift`, tests lines 5-264; `Native/AmbitionsTests/LocalRuntimeOS/Commands/CaptureGoalHandoffOwnerWriteTests.swift`, tests lines 5-270. | Current test source only. | `rg -n "func test" ...` enumerated local Search/reload and Capture authority/replay tests. Coordinator batch failed at simulator boot; zero tests executed. | High that tests exist; `UNKNOWN` current pass/fail. | AVF-CAPTURE-S07-R00, AVF-SEARCH-D07-R00. |

## Contradiction and unsupported-claim review

- No staged-input type is treated as active UI behavior.
- No test name is treated as a passing result.
- Search Open/Inspect is not relabeled as material Act.
- Canonical journeys are target contracts, not runtime proof.
- The provisional four-phase Capture and Find/Understand/Act structures are preserved without silently weakening their protected intent.
