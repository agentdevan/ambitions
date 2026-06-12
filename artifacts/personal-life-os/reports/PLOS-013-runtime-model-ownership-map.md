# PLOS-013 Runtime Model Ownership Map

Status: Green for AMB-649 mapping scope; Yellow for named future implementation and proof limits
Linear issue: AMB-649
Parent issue: AMB-609
Program phase: PLOS-M01 live runtime truth map
Updated: 2026-06-12
Branch: main

## Closeout Header

- PLOS child closeout: yes
- Linear issue: AMB-649
- Parent issue: AMB-609
- Green/Yellow/Red status: Green for source-backed runtime model ownership mapping; Yellow for missing/future PLOS model owners, absent top-level `tests` path in the literal required search, local-only/default sync posture, and unproven runtime behavior.
- Pushed to main: pending at report creation
- Push hash: pending at report creation
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: no
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none
- Yellow limits: several PLOS nouns are model-only, projection-only, fixture-backed, missing, or future-owned; CloudKit continuity is source-present but runtime defaults remain local-only; no build, app test, screenshot, accessibility, performance, privacy/legal, release, TestFlight, or App Store proof is claimed.
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-649 commit, push, and Linear closeout, continue AMB-650 only.

## Scope

AMB-649 maps existing domain, runtime, service, persistence, and model ownership for the PLOS runtime object graph. It does not create models, rename types, migrate persistence, add CloudKit schema, implement Source Atlas Factory, implement Step Elasticity, implement schedule install, implement reflow, implement sharing/progress story, run UIQL, or execute PLOS-M02+.

Existing-first proof artifacts:

- `artifacts/personal-life-os/validation/PLOS-013-runtime-model-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-013-runtime-model-owner-files.txt`
- `artifacts/personal-life-os/validation/PLOS-013-required-runtime-model-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-013-required-runtime-model-search-stderr.txt`
- `artifacts/personal-life-os/validation/PLOS-013-required-runtime-model-search-exit-code.txt`

The literal required search over `Native Sources tests docs` produced evidence plus a non-zero exit because this repo has `Native/AmbitionsTests` rather than a top-level `tests` directory. The adapted search includes `Native/AmbitionsTests` and is the broader evidence log for test ownership. This is Yellow validation adaptation, not a Red blocker.

## Runtime Model Owner Table

| Domain object | Existing type/path | Owner module | Live runtime use | Persistence | Sync implications | Source authority implications | Privacy class | Performance/indexing implication | Related tests | Related docs | Phase owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Goal | `Goal`, `GoalDraft`, `GoalPlan`, `PlanSection`, `Step` in `Native/Ambitions/Domain/GoalEngine/GoalEngineContracts.swift`; `GoalRecord`, `GoalDraftRecord`, `GoalPlanRecord`, `StepRecord` in `Native/Ambitions/Persistence/SwiftDataModels.swift`. | Domain/GoalEngine plus Persistence. | Live. Goals, Today, Time, learning, receipts, and repositories consume these models. | SwiftData records and `GoalRepository`, `GoalDraftRepository`, unit-of-work protocols. | CloudKit record family includes `goal`, but runtime default sync capability is local-only. | Source Atlas can inform future paths but Goal remains user-private local graph. | Private user life data. | Repository-backed query and projection paths need indexing discipline before broad runtime scaling. | `GoalEnginePlannerTests`, `GoalEngineOrchestratorTests`, `GoalCreationServiceTests`, Goals tests. | PLOS runtime law, Any Goal Solution Loop law, product design truth. | M07, M10, M12, M13. |
| GoalIntent | `GoalIntent`, `GoalIntentDayCompilerInput`, `GoalIntentDayCompilerOutput` in `Native/Ambitions/Domain/GoalEngine/GoalIntentCompilerModels.swift`. | Domain/GoalEngine. | Model-only to partially live bridge. `GoalDraft` and `GoalCompiledPath` can build intent compiler input/output; not proven as fully productized Any Goal runtime. | No direct SwiftData record; compiler receipts can be adapted to `ActionReceiptHistoryRecord`. | Compiler outputs are local-only unless future sync explicitly stores derived artifacts. | Must distinguish user intent from Source Atlas public reference material. | Private user intent and context. | Compiler fan-out can become hot path; M13 must preserve traceability and bounded output. | `GoalIntentCompilerModelsTests`, `GoalIntentCompilerReceiptPersistenceAdapterTests`, runtime bridge tests. | Any Goal Solution Loop law, Program Execution Contract. | M07, M13. |
| GoalPath | `GoalCompiledPath`, `GoalCompiledPathCandidate`, `GoalCompiledPathStage`, `GoalCompiledPathCompilerCore` in `Native/Ambitions/Domain/GoalEngine/GoalPathCompilerModels.swift`. | Domain/GoalEngine and services. | Model-only to service-backed path compilation. | No standalone path table proven; path output may be embedded in goal/plan projections. | Future sync must avoid treating speculative paths as canonical user commitments. | Source-backed paths require Source Atlas eligibility and source receipts. | Private planning data with possible public source references. | Path lattice expansion needs bounded candidates and conflict review. | `GoalPathCompilerModelsTests`, `GoalPathCompilerServiceTests`, `AmbitionsOSGoalPathCompilerModelsTests`. | Source Atlas Authority law, Seed-Based Planning law. | M12, M13. |
| PathOption | No literal `PathOption` type found. Closest owners are `GoalCompiledPathCandidate`, branches, tradeoffs, and alternate-path receipt models. | Missing literal; Domain/GoalEngine closest current owner. | Missing as named PLOS object. | None proven. | Future synced path alternatives must be explicit and non-canonical until chosen. | Must preserve source/freshness/uncertainty on each option. | Private planning data. | Needs candidate cap, ranking trace, and explanation indexing. | Goal path compiler tests cover related candidate behavior. | Multi-Path Lattice phase gate. | M12. |
| Step | `Step`, `StepActionability`, `StepLifecycleState` in `GoalEngineContracts.swift`; `StepRecord` in `SwiftDataModels.swift`; Today and Goals services consume step models. | Domain/GoalEngine, Persistence, Today, Goals. | Live. | SwiftData `StepRecord` and goal plan persistence. | CloudKit record family includes `step`; current runtime default remains local-only. | Step source authority must be explicit before source-backed recommended-step Green. | Private execution data. | Today selection and Step Quality Firewall need bounded candidate and proof indexes. | `StepCandidateFieldModelsTests`, Today tests, GoalEngine tests. | Step Elasticity law, Step Quality Firewall gate. | M09, M13, M14. |
| CompiledStep | `CompiledStep`, `CompiledStepReceipt`, `GoalIntentDayCompilerOutput` in `GoalIntentCompilerModels.swift`. | Domain/GoalEngine. | Model-only to runtime bridge. `SourceAtlasStepCandidateFieldBridge` can emit compiler output and receipts. | No direct compiled-step persistence; receipt adapter maps output to action receipt history. | Derived compiler output should be replayable before any future sync. | Compiled steps require source provenance and local context boundaries. | Private derived recommendation data. | Compiler output should stay bounded and replay-traceable. | `GoalIntentCompilerModelsTests`, `GoalIntentCompilerReceiptPersistenceAdapterTests`, Source Atlas runtime bridge tests. | Any Goal Solution Loop law, Seed-Based Planning law. | M13. |
| StepCandidate | `StepCandidate`, `StepCandidateField`, `StepCandidateRejectionRecord`, `CandidateRankingTrace` in `StepCandidateFieldModels.swift`; `StepCandidateFieldGenerator`; `SourceAtlasStepCandidateFieldBridge`. | Domain/GoalEngine and Runtime. | Runtime-shaped, partially live. Generator and bridge tests prove behavior; production Today handoff is not Green here. | No direct SwiftData record proven; traces and receipts can be ledgered later. | Candidate fields should remain local-only unless future proof stores redacted derived state. | Candidate provenance includes Source Atlas, personalization, replay, and local factors. | Private recommendation and fit data. | High fan-out/ranking path; M09/M13/M14 must cap and index traces. | `StepCandidateFieldGeneratorTests`, `StepCandidateFieldModelsTests`, Source Atlas bridge gauntlets. | Step Quality Firewall, Seed-Based Planning, Step Elasticity law. | M09, M13, M14. |
| ElasticStep / variant | No literal `ElasticStep` type found. Existing variant owner is `StepCandidateKind` and candidate minimum/shorter/lower-energy helpers. | Domain/GoalEngine closest current owner. | Missing as named model; variant behavior is partial/model-only. | None proven. | Future elastic mutations require receipts before sync. | Elasticity cannot override source/safety/proof/deadline constraints. | Private execution adaptation data. | Mutation impact and alternate-form search must be bounded. | `StepCandidateFieldModelsTests`, `StepCandidateFieldGeneratorTests`; no ElasticStep-specific suite found. | Step Elasticity Runtime Law. | M14. |
| Schedule install | `ScheduledAmbitionsBlock`, `ScheduledBlockWriteIntent` in `RealityModels.swift`; `LocalScheduleBlockRepository`; Time feature schedule projections. | Domain/Reality, Services, Time. | Partial/live context and local block model; schedule install kernel not Green. | Local schedule repository and app state/service records; no schedule-install migration. | Future installed blocks may sync only with user-owned iCloud proof. | Schedule source must distinguish calendar/native context from Ambitions writes. | Highly sensitive schedule data. | Needs conflict indexes and write-intent audit trail. | `TimeFeatureServiceTests`, `CalendarRealityServiceTests`, `IOS26CalendarP0ContractHarnessTests`. | Life Consequence Reflow law, Local Data Cloud Boundary law. | M15. |
| Calendar/native context | `CalendarPermissionState`, `CalendarDerivedContext`, EventKit integration service, Time calendar-aware service. | Domain/Reality, Integrations/CalendarReminders, Time. | Partial/live optional context. | Calendar-derived context is service/projection-owned; app persistence is local. | Cloud sync not implied; EventKit is native source context, not Ambitions backend. | Native calendar source must be permissioned, revocable, and source-labeled. | Sensitive schedule/location/life context. | Calendar scans must be bounded and permission-aware. | `CalendarRealityServiceTests`, `EventKitIntegrationServiceTests`, Time tests. | Native Context Mesh phase, Local Data Cloud Boundary law. | M08, M15. |
| Source Atlas pack | `SourceAtlasPack`, `SourceAtlasPackManifest`, `SourceAtlasPackValidator`, `SourceAtlasPackFactoryLite`, `SourceAtlasStore`. | Domain/SourceAtlas and supporting tooling. | Compiled domain models/tooling; production Source Atlas Factory not Green. | Store supports cached/bundled/last-known-good payload selection; no production R2 path proven. | Future R2 packs are public-reference-only; no private user data. | Primary public source authority model with freshness, revocation, risk, review, and eligibility. | Public reference data unless combined with private user context. | Pack validation, cache quarantine, and query indexes required before scale. | Source Atlas pack/factory/store/query tests. | Source Atlas Authority law, SAF hardening plan. | M04, M05, M06. |
| Source Atlas seed | `SourceAtlasStepCandidateSeedTrace`, starter guidance, capability path composition, source atlas bridge seed traces. | Domain/SourceAtlas, Runtime bridge. | Model/bridge-shaped; not production pack foundry Green. | No seed persistence proven. | Public reusable seeds may distribute through R2 after release receipt; user mini-packs stay local-only. | Seeds must be reusable, source-bound, and not hardcoded private finished steps. | Public reference or local-only user-private depending origin. | Needs coverage-demand and seed-gap indexing. | Source Atlas bridge gauntlets, capability path tests. | Seed-Based Planning law. | M05, M13. |
| Source record | `SourceAtlasSourceRecord`, `SourceAtlasStoreSourceState`, `AmbitionsOSLivingDreamSourceClaimReference`. | Domain/SourceAtlas. | Model/tooling live; production source freshness runtime not Green. | Source records live inside packs/payloads; no user-private source store proven. | Public source records can distribute; private source captures cannot. | Canonical authority carrier for source kind, URL, publisher, freshness, and risk. | Public source metadata unless user-private context is attached. | Source lookup and freshness filtering need indexes. | Source Atlas pack/source container/importer tests. | Source Atlas Authority law. | M06. |
| Claim/requirement | `SourceAtlasClaim`, `SourceAtlasRequirement`, Living Dream source claim and requirement graph models. | Domain/SourceAtlas and AmbitionsOS law models. | Model/tooling; eligibility not production Green. | Pack payload and graph records, not app-wide runtime store proven. | Future sync/R2 must preserve public/private boundary and revocation. | Claims and requirements are the source authority mesh. | Public reference or sensitive domain-specific reference data. | Conflict/freshness/review indexing is required. | Source Atlas claim candidate/extractor/review/requirement tests. | Source Atlas Authority law, High Risk Domain Safety law. | M06, M18. |
| Proof | `ProgressEvidence`, `Proof`, `ProofReference`, `ProofResourceGraphProjection`, `ActionReceiptProofLedgerEntry`. | Domain/GoalEngine, Domain/Proof, Persistence. | Partial/live. Goals and receipts use proof/evidence; full proof transfer/replay not Green. | `ProgressEvidenceRepository`, proof graph records, action receipt proof ledger. | CloudKit record family includes `proof`; runtime default remains local-only. | Proof can reference source authority but must not leak private user context. | Private proof/progress data. | Proof graph and transfer indexes are required before large history. | `ProofResourceGraphModelsTests`, Goals proof tests, LocalOnlyProofHarnessTests. | Trust UI Disclosure law, PLOS proof artifact contract. | M16, M17. |
| Receipt | `ActionReceipt`, `ActionReceiptHistoryRecord`, `CompiledStepReceipt`, `SourceAtlasBridgeReceipt`, `CaptureRuntimeReceipt`. | Domain receipts, Runtime bridge, Persistence. | Live/partial. Action receipts and history repositories exist; distributed receipt taxonomy needs later consolidation. | `ActionReceiptHistoryRepository`, `SwiftDataActionReceiptHistoryRepository`, compiler adapter. | CloudKit record family includes `receipt`; current default local-only. | Receipts must bind source, mutation, privacy, rollback, and replay where applicable. | Private action and audit data. | Receipt search/history projections need indexing and retention policy. | `ActionClosureReceiptModelsTests`, `ActionReceiptHistoryRepositoryTests`, Source Atlas replay tests. | Trust UI Disclosure law, Program Execution Contract. | M17. |
| ReplayTrace | `ReplayableDecisionTrace`, `SourceAtlasRuntimeBridgeReplay`, `LedgerReplayModels`, `RuntimeSnapshotLedgerRepository`. | Runtime and Domain ledger/replay. | Partial/model and runtime-shaped. Replay tests exist; full product replay UI not Green. | Runtime snapshot ledger and event ledger repositories. | Replay data is private and should sync only with explicit user-owned proof. | Replay must retain source, boundary, privacy, and local-only facts. | Highly sensitive decision trace. | Replay storage can grow quickly; snapshot bounds/indexes required. | `ReplayableDecisionTraceTests`, `SourceAtlasRuntimeBridgeReplayTests`, `LedgerReplayModelsTests`. | Trust UI Disclosure law, Local Data Cloud Boundary law. | M17, M24, M26. |
| Closure/completion | Action closure receipt models, Today closure flows, `ProgressEvidence`, feedback events, event ledger. | Today, Goals, Domain receipts, Persistence. | Partial/live. Today closure UI and evidence/feedback repositories exist. | Progress evidence, feedback events, action receipts, event ledger. | Closure/proof sync is future-owned and private. | Completion claims require receipts and proof freshness where source-backed. | Private behavior/progress data. | Closure history and evidence query indexes needed for scale. | Today tests, `ActionClosureReceiptModelsTests`, Goal feedback tests. | Product design truth, Trust UI Disclosure law. | M16, M17. |
| Reflow / consequence | `ReflowReason`, `ReflowOption`, `ReflowOpportunity`, Step impact simulation, reschedule engine concepts. | Domain product canon, Reschedule, Time. | Model-only/partial. Reflow engine is not Green. | No reflow persistence owner proven beyond receipts/ledger candidates. | Reflow mutations must be receipted before any sync. | Reflow source changes must preserve source authority and user confirmation rules. | Private cross-goal and schedule data. | Consequence simulation must be bounded and explainable. | Quiet reflow primitive tests, reschedule-related tests; no full PLOS reflow engine test. | Life Consequence Reflow law. | M16. |
| Goal treaty | No literal production Goal Treaty model found. Closest current source is `TimeTreatyState` in Time UI models plus governance law. | Missing literal; Time surface projection closest current owner. | Missing as runtime model. | None proven. | Future treaty state would be sensitive and local/user-owned. | Treaty constraints must not be inferred as source facts. | Private capacity/priority constraints. | Needs conflict and active-goal portfolio indexes. | Time tests; no Goal Treaty runtime suite found. | Life Consequence Reflow law. | M16. |
| Sharing | Shared external snapshots, Share Extension/local intake support, external action/import services, shared-life coordination service. | ExternalSnapshots, Share Extension, Services, You. | Partial external-surface/local handoff; Progress Story sharing missing. | Shared app group snapshots and local captures; not hosted sharing. | Sharing must be user-initiated, local/redacted, and not default cloud/social. | Share eligibility depends on source authority and privacy-safe projection. | Redacted projection only; private by default. | Export/projection paths need redaction and size bounds. | External surface/share tests, SharedLifeCoordinationServiceTests. | Sharing and Progress Story law. | M20, M24. |
| Year recap | No `YearRecap` type found. Time has year horizon labels and North Star one-year framing only. | Missing as PLOS runtime object. | Missing. | None proven. | Future recap exports/sync must be opt-in and redacted. | Recap claims need proof/source lineage. | Private longitudinal life/proof data. | Requires history/proof rollup indexes. | No Year Recap-specific tests found. | Sharing and Progress Story law. | M21. |
| Local learning | `LearningAnticipationSnapshot`, `GoalLearningSummary`, `LearnedStepInsight`, `LearningAnticipationService`, `GoalEnergyLearningService`, Memory Lens learning facets. | Domain/Learning, Services, App/MemoryLens. | Partial/live local deterministic learning. | Evidence, feedback, teaching signals, app state repositories. | Learning data is local/private; sync is opt-in future proof only. | Learning should explain source signals and allow reset/control. | Sensitive behavioral pattern data. | Needs bounded windows, decay, and resettable indexes. | `LearningAnticipationServiceTests`, `GoalEnergyLearningServiceTests`, `MemoryLensServiceTests`. | Product design truth, Local Data Cloud Boundary law. | M22. |
| CloudKit sync | `SyncCapabilityContracts`, `CloudKitContinuityModels`, `CloudKitContinuityClient`, `LocalOnlySyncCapability`, `LocalFirstCloudKitContinuitySyncCoordinator`. | Persistence. | Source-present model/capability. Runtime factory defaults to local-only capability. | Portable envelopes, ledger, outbox, conflict review, in-memory outbox support. | User-owned iCloud/CloudKit only after explicit implementation proof; no R2/private backend. | Sync must preserve local-first and source/privacy classifications. | Private user data if enabled; local-only by default. | Outbox/conflict indexes and diagnostics required before production claims. | `SyncCapabilityTests`, `CloudKitContinuityFoundationTests`, `PortableSnapshotServiceTests`. | Local Data Cloud Boundary law. | M02, M23, M24. |
| User profile/settings | `YouDashboard`, `YouTrustCenterState`, `SettingsItem`, `YouSystemCenterState`, `YouFeatureService`. | Domain/You, Features/You. | Live. | Preferences, app state, trust history, source knowledge projections. | Sync is future-owned and user-controlled. | User controls source, trust, automation, local data, history. | Private profile/preferences/trust controls. | Needs stable grouped navigation and query projections. | `YouFeatureServiceTests`, personal system center tests. | Product design truth, Trust UI Disclosure law. | M08, M17, M22. |
| Privacy/local data controls | `AmbitionsOSPrivacySafetyPolicy`, `AmbitionsOSPrivacyReceipt`, protected storage reports, portable snapshot contracts, local-only sync diagnostics. | Domain privacy/safety, Persistence, You. | Model/live policy and diagnostics. | Local persistence, portable snapshot/export/restore, privacy receipts. | Cloud/R2 boundaries are policy-gated; CloudKit not release-proven. | Privacy class gates all source, share, sync, export, high-risk, and replay work. | Private/sensitive by default. | Export/delete/snapshot paths need audit and size bounds. | Privacy/safety model tests, protected storage report tests, portable restore tests. | Local Data Cloud Boundary law, High Risk Domain Safety law. | M02, M18, M24. |

## Current Discovered Model Graph

```text
Capture / GoalDraft / existing goals
  to GoalIntent
  to GoalCompiledPath / GoalCompiledPathCandidate
  to GoalIntentDayCompilerInput
  to CompiledStep + CompiledStepReceipt
  to StepCandidateField / StepCandidate / CandidateRankingTrace
  to GoalPlan / PlanSection / Step
  to Today recommended-step and closure surfaces
  to ProgressEvidence / GoalFeedbackEvent / EventLedger
  to ActionReceipt / ActionReceiptHistory / ProofReference
  to ReplayableDecisionTrace / RuntimeSnapshotLedger
  to Goals proof, Motion proof projection, You trust/history

SourceAtlasPack / SourceAtlasSourceRecord / SourceAtlasClaim / SourceAtlasRequirement
  to SourceAtlasStore cached-or-bundled payload selection
  to SourceAtlasIntentMatch / pack selection
  to SourceAtlasStepCandidateFieldBridge
  to StepCandidateField and SourceAtlasBridgeReceipt

CalendarDerivedContext / ScheduledAmbitionsBlock / LocalScheduleBlockRepository
  to Time dashboard and Today capacity context
  to future schedule install and reflow receipts

LearningAnticipationSnapshot / GoalEnergyLearning / MemoryLens
  to local fit signals and future recommendation compounding

SwiftData local repositories
  are current user-data persistence owner
  with CloudKit continuity models present but runtime default local-only
```

## Target PLOS Model Graph Overlay

```text
Existing Goal / GoalIntent / GoalCompiledPath
  extension points:
    M12 Multi-Path Lattice owns named PathOption / branch option maturity
    M13 Step Graph Compiler owns compiled-step to candidate to step graph maturity
    M14 Step Elasticity owns ElasticStep forms, mutation impact, and receipts

Existing SourceAtlasPack / SourceRecord / Claim / Requirement
  extension points:
    M04 R2 public-reference distribution
    M05 Pack / Seed Foundry
    M06 Source Authority Mesh
    M18 high-risk source/safety gates

Existing Schedule / Calendar / Time models
  extension points:
    M08 Native Context Mesh permission explainers
    M15 Schedule Install Kernel
    M16 Life Consequence / Goal Treaty reflow

Existing Receipt / Proof / Replay / Ledger models
  extension points:
    M16 proof-preserving consequence mutation
    M17 trust-light UI and deep drill-down replay
    M24 diagnostics, export, and data lifecycle
    M26 certification gauntlets

Existing local learning / You controls / privacy policy
  extension points:
    M22 local compounding recommendations
    M23 CloudKit sync hardening
    M24 export, support, diagnostics

Missing or future-only:
  PathOption as named runtime object
  ElasticStep as named runtime object
  Goal Treaty as runtime model
  Progress Story sharing system
  Year Recap runtime model
```

## Conflict Map

| Conflict area | Current finding | Boundary / resolution owner |
|---|---|---|
| Duplicate Goal models | `Goal`, `GoalDraft`, `GoalPlan`, SwiftData records, feature projections, Source Atlas goal-shaped claims, and AmbitionGraph proof records coexist. `Goal` in GoalEngine is the canonical runtime domain model; projections and proof records are not replacement owners. | Preserve canonical GoalEngine/Persistence ownership. M12/M13 may extend path/step graph behavior without adding a parallel Goal model. |
| Duplicate Step models | `Step`, `CompiledStep`, `StepCandidate`, `StepOccurrence`, `StepRecord`, and projection/test fixtures represent different lifecycle stages. Treating them interchangeably would create false Green. | M13 must define compiler stage boundaries; M14 owns ElasticStep variants; AMB-651 should classify fixture/test-only step artifacts. |
| Duplicate receipt/proof models | `ActionReceipt`, `CompiledStepReceipt`, `SourceAtlasBridgeReceipt`, `CaptureRuntimeReceipt`, `Proof`, `ProofReference`, proof ledger entries, and runtime snapshot/replay records have distinct owners. | M17 owns user-facing trust/receipt/replay consolidation; M24 owns export/diagnostic boundaries. |
| Duplicate source/claim models | Source Atlas pack claims/requirements, Living Dream source claim graphs, Knowledge ingestion claims, import candidates, and review models exist. They are not all runtime-eligible source truth. | M06 owns Source Authority Mesh and eligibility states; M18 owns high-risk boundaries. |
| Parallel sync/local store | SwiftData/local repositories are current user-data persistence owner. CloudKit continuity models/client/coordinator exist, but runtime factory defaults to `LocalOnlySyncCapability`. | M02/M23 must prove sync behavior before any CloudKit Green. No private user data in R2. |
| Runtime-vs-fixture duplicates | Source Atlas coverage runtime fixtures, Motion fixture projections, preview fixtures, and test harnesses can look runtime-shaped. | AMB-651 production-vs-fixture classification must separate fixture/test/script artifacts from production runtime. |

## Yellow Follow-Ups

- AMB-650 owns stale/duplicate map follow-up for old, preview, duplicate, or drifted model surfaces.
- AMB-651 owns production-vs-fixture/test/script classification for runtime-shaped fixtures and tests.
- M12 owns named PathOption maturity.
- M13 owns Step Graph Compiler stage boundaries and compiled-step/candidate lifecycle.
- M14 owns named ElasticStep or equivalent variant runtime proof.
- M15 owns schedule install persistence and write-intent behavior.
- M16 owns reflow, consequence, and Goal Treaty runtime models.
- M17 owns trust-light receipt/proof/replay disclosure and UI proof.
- M20 owns Progress Story sharing, redaction, and proof-bound export.
- M21 owns Year Recap runtime/proof rollups.
- M22 owns local compounding recommendation controls and resettable learning.
- M23 owns CloudKit/iCloud sync hardening.
- M24 owns diagnostics, data export, support, and lifecycle proof.

## Validation

Commands run for AMB-649:

- `git status --short --branch --ahead-behind`
- `git pull --ff-only`
- Linear issue fetch for `AMB-609`
- Linear issue fetch for `AMB-649`
- `rg -n "struct .*Goal|class .*Goal|enum .*Goal|GoalIntent|Step|CompiledStep|StepCandidate|Path|Schedule|Receipt|Replay|Proof|SourceRecord|SourceAtlas|Learning|Memory|Sync|CloudKit|Share|Completion|Milestone|Reflow|Timeline|Calendar" Native Sources tests docs --glob "*.swift" --glob "*.md" > artifacts/personal-life-os/validation/PLOS-013-required-runtime-model-search-log.txt 2> artifacts/personal-life-os/validation/PLOS-013-required-runtime-model-search-stderr.txt`
- `rg -n "struct .*Goal|class .*Goal|enum .*Goal|GoalIntent|Step|CompiledStep|StepCandidate|Path|Schedule|Receipt|Replay|Proof|SourceRecord|SourceAtlas|Learning|Memory|Sync|CloudKit|Share|Completion|Milestone|Reflow|Timeline|Calendar" Native Sources Native/AmbitionsTests docs --glob "*.swift" --glob "*.md" > artifacts/personal-life-os/validation/PLOS-013-runtime-model-search-log.txt`
- `find Native Sources -maxdepth 5 -type f | rg -i "domain|runtime|service|model|store|repository|manager|sync|receipt|proof|goal|step|source|share" > artifacts/personal-life-os/validation/PLOS-013-runtime-model-owner-files.txt`
- Focused source inspection over GoalEngine, StepCandidate, Source Atlas, receipts, proof, replay, Reality/Calendar, CloudKit continuity, sync capability, learning, You, privacy, sharing/external surfaces, and related tests.

Validation to run before commit closeout:

- `git diff --check`
- `git diff --cached --check`
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json`
- `scripts/codex/program-preflight.sh plos`
- `scripts/codex/program-phase-gate.sh plos M01`
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-013-runtime-model-ownership-map.md`
- `bash scripts/codex/program-proof-index.sh plos`

Not run:

- Build/test/screenshot/accessibility/performance validation was not run because AMB-649 is a read-only model ownership mapping/proof artifact child and no app source, project, UI, runtime, or test source files were changed. No release, UI, accessibility, privacy/legal, performance, or runtime behavior claim is made.

## Verdict

Green for AMB-649 scope: the required runtime model domains are mapped from live source; canonical owners, missing/future model owners, persistence/sync/privacy/source implications, related tests/docs, and conflict areas are identified so later PLOS issues can reference this map instead of rediscovering basics.

Yellow limits remain: top-level `tests` is absent and required search stderr records that adaptation; PathOption, ElasticStep, Goal Treaty, Progress Story, and Year Recap are missing or future-owned; Source Atlas Factory, schedule install, reflow, CloudKit sync, sharing, proof replay, and local compounding are not implementation Green; AMB-651 still owns production-vs-fixture/test/script classification; build/test/screenshot/accessibility/performance/privacy/legal/release proof is not claimed.

Red blockers: none.
