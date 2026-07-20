---
artifact_id: CEBR-01-CODEX-MANUAL
artifact_kind: design-and-technical-manual
status: research-design
normative: false
authority: none
implementation_authorized: false
parent_candidate: CHLB-01
technical_nucleus: CEBR-01
repository: agentdevan/ambitions
repository_revision: 7dbf554876c686e62525a85d762fec04b67a4af4
canon_revision: 1
canon_authority_state: active
canon_content_sha: a1c987a4e753f42a852e0558b5e201cd1168e4b08e5deb9286b341dfbaaaea13
created: 2026-07-19
---

# CEBR-01: Certified Executable Branch Reconciliation
## Fully Developed Design Document and Technical Manual for Codex Consumption

> **Request-only artifact.** This manual is non-normative and cannot authorize tracked changes, canon amendments, validation claims, proof, merge, or release. Before any implementation work, Codex must run the active-canon audit, obtain a bounded canon pack, and obtain current `task start` authorization. `docs/canon/` remains the sole normative repository authority.

## 1. Purpose

CEBR-01 is the technical nucleus of **CHLB-01, the Constitution-Governed Homeostatic Life Branch Runtime**. It defines a local runtime mechanism that:

1. Maintains one active executable personal-state branch as a semantic delta over a revisioned canonical graph.
2. Maintains an operational viability certificate that determines whether the branch may remain active.
3. Responds to fact, policy, authority, or operating-condition revisions by invalidating only causally dependent certificate components and branch effects.
4. Materializes complete candidate branches from lightweight contingency policies only when needed.
5. Derives candidate branches from materially distinct correction sets rather than cosmetic schedule variations.
6. Promotes the user-selected branch through one parent semantic transaction while preserving prior-branch reasoning, Receipts, replay, and compensation lineage.

This manual is written for future Codex execution. It is a design contract, not an implementation instruction or source of repository authority.

## 2. Governing repository constraints

At repository revision `7dbf554876c686e62525a85d762fec04b67a4af4`, the active manifest declares `authority_state = "active"`; generated handoff files explicitly state that `docs/canon/` is the sole normative repository authority. The current Private Life Runtime requires typed command validation, deterministic local simulation, atomic local commit, projection invalidation or materialization, truthful Receipts, replay, rollback, and external effects only after local commitment. Scheduling law requires honest capacity, explicit infeasibility, inspectable reflow, protected boundaries, user control, and deterministic change sets.

Codex must preserve these boundaries:

- **No fifth root.** CEBR appears through Today, Goals, Time, You, Capture, Trust, and History.
- **No duplicate canonical object authority.** A branch is a delta and decision container, not a replacement Goal, Goal Path, Step, Schedule Placement, Recovery Thread, Receipt, or History store.
- **No model authority.** A local model may propose law interpretations, correction-set narratives, or summaries. Deterministic code owns certificate construction, validation, branch state, authority, command compilation, commit, replay, and rollback.
- **No direct writes.** Surfaces, projections, models, App Intents, and external adapters may propose Commands only.
- **No silent material change.** Candidate branches remain non-durable until user selection and revalidation.
- **No universal life score.** Branch recommendation is lexicographic and reasoned, not a hidden weighted score claiming to measure the person.
- **No remote private-graph authority.** Core behavior remains offline, local, deterministic, replayable, and inspectable.

## 3. Design thesis

CEBR solves a runtime problem, not merely a planning problem.

Conventional planning systems typically generate a plan, schedule, or scenario. When reality changes, they re-run planning, repair a plan, or generate another disposable option. The technical deficiencies are:

- The system cannot identify which parts of the current arrangement were valid because of the changed condition.
- Unrelated state is frequently recomputed or moved.
- Alternative plans are not complete operational states.
- A selected alternative is applied through fragmented mutations whose causal unity exists only in presentation code.
- The prior plan's decision-time basis is lost or reconstructed after the fact.
- Systems persist complete alternate futures or regenerate everything on demand, creating storage, computation, or instability costs.

CEBR introduces a branch, certificate, dependency index, latent contingency, correction-set materializer, and parent promotion transaction as one mechanism.

## 4. Core invariants

1. Exactly one branch may hold `activeLocal` or `active` status for one canonical personal-state graph.
2. A branch never becomes a second source of truth; it references a base graph revision and owns only a typed semantic delta and branch-specific evidence.
3. A candidate branch cannot mutate canonical state.
4. A branch cannot be called feasible without a valid, current, machine-evaluable viability certificate.
5. Certificate evaluation is deterministic for equivalent canonical inputs, policy revision, clock, seed, and authority state.
6. A revision invalidates only certificate components and branch operations reachable through declared dependencies, unless a declared full-rebuild condition applies.
7. Candidate branches must correspond to materially distinct correction sets for the same conflict core.
8. Cosmetic time-placement variants must be suppressed.
9. User selection must create one parent `SelectLifeBranchCommand` and one causal promotion lineage.
10. Recipient-owned effects remain proposals; external effects remain durable outbox intents; neither is falsely represented as locally completed.
11. The prior active branch, certificate, accepted reasoning, and Receipt lineage remain historically inspectable after promotion.
12. A generative model cannot certify, select, or commit a branch.
13. A deleted or corrected influence cannot silently reappear as an undeclared branch input.
14. Material local effects require materiality evaluation even when no network effect exists.
15. Failure preserves the last coherent committed branch and accepted local intent.

## 5. Conceptual architecture

```text
Canonical Personal State Graph
        |
        +--> Active Life Branch Store
        |       |- semantic delta
        |       |- base graph revision
        |       `- branch lineage
        |
        +--> Branch Viability Certificate Engine
        |       |- policy constraints
        |       |- operating conditions
        |       |- authority state
        |       |- capacity / scheduling fit
        |       `- certificate fingerprint
        |
Revision Event --> Certificate Dependency Index --> Impact Cone
                                                |
                                                +--> Incremental Recertification
                                                |
                                                `--> Conflict Core
                                                       |
Latent Contingencies --> Correction-Set Generator --> Candidate Materializer
                                                       |
                                                       +--> Certificate each candidate
                                                       +--> Semantic deduplication
                                                       `--> Recommendation policy
                                                                  |
                                                             User selection
                                                                  |
                                                       Branch Promotion Coordinator
                                                       |- revalidation
                                                       |- parent transaction
                                                       |- child object mutations
                                                       |- shared proposals
                                                       |- external outbox intents
                                                       `- Receipt / replay / rollback
```

## 6. Component boundaries

### 6.1 Branch value model

**Responsibility:** Stable value types for branches, deltas, certificates, conditions, contingencies, conflicts, corrections, promotion requests, and lineage.

**Candidate source area:** `Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/Branching/` or a current canon-routed equivalent.

**Must not:** Persist unrelated canonical object copies or own mutation authority.

### 6.2 Branch certificate engine

**Responsibility:** Build and incrementally recompute branch certificates from current canonical facts, accepted policies, operating envelopes, and authority conditions.

**Candidate source area:** `Core/LocalRuntimeOS/Planning/Branching/` plus Scheduling integrations.

**Must not:** Generate presentation copy as a substitute for machine evaluation.

### 6.3 Dependency index

**Responsibility:** Map revisioned source facts and policies to certificate components and branch delta operations.

**Candidate source area:** `Planning/Branching/` or `Projections/` if derived and rebuildable.

**Must not:** Become canonical life-state authority.

### 6.4 Conflict and correction engine

**Responsibility:** Identify a bounded conflict core, enumerate relaxable conditions, produce policy-distinct correction sets, and suppress semantic duplicates.

**Must not:** Hide sacrifices, waive hard laws, or generate unlimited alternatives.

### 6.5 Candidate materializer

**Responsibility:** Compile a latent contingency and correction set against current canonical state into a candidate branch delta and certificate.

**Must not:** Commit any candidate.

### 6.6 Recommendation policy

**Responsibility:** Order certified branches using explicit lexicographic precedence and produce an inspectable recommendation reason.

**Must not:** Use an opaque universal life score.

### 6.7 Branch promotion coordinator

**Responsibility:** Revalidate a selected candidate, prepare one parent semantic transaction, atomically commit user-owned effects, create recipient-owned proposals, queue external effects, issue Receipts, and preserve lineage.

**Candidate source area:** `Core/LocalRuntimeOS/Transactions/` and `Commands/`.

### 6.8 Branch inspection projection

**Responsibility:** Provide plain-language, privacy-safe branch comparison and decision lineage to Time, Today, Goals, You, Trust, and History.

**Must not:** Mutate state or expose internal graph machinery as the product center.

## 7. Provisional type system

All names in this section are provisional and non-normative. Codex must resolve final naming against a current canon pack before editing.

```swift
enum LifeBranchStatus: String, Codable, Sendable, CaseIterable {
    case materializing
    case candidateFeasible
    case candidateFragile
    case candidateBlocked
    case candidateInfeasible
    case selected
    case stale
    case committing
    case activeLocal
    case active
    case superseded
    case rolledBack
    case expired
}

enum BranchCertificateStatus: String, Codable, Sendable, CaseIterable {
    case building
    case valid
    case fragile
    case blocked
    case invalid
    case stale
    case superseded
}

enum BranchDeltaOperationKind: String, Codable, Sendable, CaseIterable {
    case activateGoal
    case pauseGoal
    case endGoal
    case selectGoalPath
    case supersedeGoalPath
    case createStep
    case reviseStep
    case deferStep
    case placeStep
    case movePlacement
    case resizePlacement
    case removePlacement
    case protectTime
    case reviseRecoveryThread
    case createReviewCondition
    case createSharedProposal
    case revokePendingProposal
}

enum ViabilityConditionKind: String, Codable, Sendable, CaseIterable {
    case canonicalFact
    case provisionalFact
    case forecast
    case capacity
    case temporalConstraint
    case dependency
    case policyConstraint
    case operatingEnvelope
    case authority
    case privacy
    case externalAvailability
    case waiver
}

enum ConditionStrength: String, Codable, Sendable {
    case hard
    case defeasible
    case preferred
    case informational
}

enum ConditionEvaluationState: String, Codable, Sendable {
    case satisfied
    case tolerated
    case uncertain
    case contradicted
    case expired
    case unavailable
    case blocked
}

enum BranchReversibility: String, Codable, Sendable {
    case easilyReversible
    case reversibleWithCost
    case reversibleBeforeExternalEffect
    case compensatable
    case irreversible
}
```

### 7.1 `LifeBranch`

```swift
struct LifeBranch: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let parentBranchID: String?
    let baseGraphRevision: String
    let horizon: ClosedRange<Date>
    let trigger: BranchTrigger
    let policyFamily: BranchPolicyFamily
    let governingPolicyRevision: String
    let lawIDs: [String]
    let waiverIDs: [String]
    let deltaSet: BranchDeltaSet
    let certificateID: String
    let authorityPartition: BranchAuthorityPartition
    let reviewCondition: BranchReviewCondition
    let reversibility: BranchReversibility
    let status: LifeBranchStatus
    let createdAt: Date
    let expiresAt: Date?
    let lineage: BranchLineageReference
}
```

**Validation rules:**

- `baseGraphRevision` must identify an available canonical revision.
- `deltaSet.operations` must be stably ordered and duplicate-free.
- `candidate*` states cannot be canonical mutation sources.
- `activeLocal` and `active` require a committed parent promotion Receipt.
- `active` requires all branch-defining authority conditions resolved.

### 7.2 `BranchDeltaOperation`

```swift
struct BranchDeltaOperation: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: BranchDeltaOperationKind
    let objectKind: String
    let objectID: String
    let expectedObjectRevision: String?
    let payload: Data
    let humanConsequence: String
    let protectedInvariantIDs: [String]
    let dependencyIDs: [String]
    let authorityOwnerID: String
    let materiality: BranchMateriality
    let reversibility: BranchReversibility
    let stableOrder: Int
}
```

The payload must use typed domain payloads in production. `Data` is shown only to keep this manual compact; Codex must not implement an untyped blob boundary.

### 7.3 `BranchViabilityCertificate`

```swift
struct BranchViabilityCertificate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let branchID: String
    let baseGraphRevision: String
    let evaluatedAt: Date
    let horizon: ClosedRange<Date>
    let factRevisionIDs: [String]
    let conditionResults: [ViabilityConditionResult]
    let lawSatisfaction: [LawSatisfactionResult]
    let operatingEnvelopeResults: [OperatingEnvelopeResult]
    let authorityResult: BranchAuthorityResult
    let capacityResult: BranchCapacityResult
    let protectedInvariantResults: [ProtectedInvariantResult]
    let robustness: BranchRobustness
    let unresolvedQuestionIDs: [String]
    let conflictCore: BranchConflictCore?
    let invalidationConditions: [CertificateInvalidationCondition]
    let status: BranchCertificateStatus
    let confidence: RecommendationConfidence
    let fingerprint: String
}
```

**Operational rule:** A certificate is not an explanation artifact. Its status gates whether a branch may remain active or be promoted.

### 7.4 `CertificateDependency`

```swift
struct CertificateDependency: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceRevisionID: String
    let targetKind: TargetKind
    let targetID: String
    let relation: Relation
    let hard: Bool
}
```

`targetKind` includes certificate condition, envelope result, delta operation, authority effect, review condition, and branch status.

### 7.5 `BranchContingencyPolicy`

```swift
struct BranchContingencyPolicy: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let triggerPredicate: ContingencyTriggerPredicate
    let policyFamily: BranchPolicyFamily
    let correctionPrecedence: [CorrectionCategory]
    let protectedInvariantIDs: [String]
    let allowedDegradationLadderIDs: [String]
    let disallowedEffectKinds: [String]
    let validityInterval: ClosedRange<Date>?
    let enabled: Bool
}
```

Contingencies are lightweight policy templates. They do not contain complete future object copies.

### 7.6 `BranchConflictCore`

```swift
struct BranchConflictCore: Codable, Sendable, Equatable, Hashable {
    let conditionIDs: [String]
    let fixedConditionIDs: [String]
    let relaxableConditionIDs: [String]
    let minimality: ConflictCoreMinimality
    let explanation: String
}
```

The initial implementation may use a sufficient conflict core rather than a mathematically minimal core, but the product must not describe it as minimal unless proven.

### 7.7 `BranchCorrectionSet`

```swift
struct BranchCorrectionSet: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let conflictCoreID: String
    let policyFamily: BranchPolicyFamily
    let relaxations: [BranchRelaxation]
    let requiredAuthority: BranchAuthorityPartition
    let protectedInvariantIDs: [String]
    let sacrificedInvariantIDs: [String]
    let expectedDeltaKinds: [BranchDeltaOperationKind]
    let semanticFingerprint: String
}
```

### 7.8 `BranchPromotionTransaction`

```swift
struct BranchPromotionTransaction: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let selectedBranchID: String
    let priorActiveBranchID: String
    let expectedBaseGraphRevision: String
    let expectedCertificateFingerprint: String
    let readSet: [RevisionedReadReference]
    let writeSet: [BranchDeltaOperation]
    let meaningSet: [HumanConsequenceRecord]
    let authoritySet: BranchAuthorityPartition
    let childProposalIDs: [String]
    let externalEffectIntentIDs: [String]
    let rollbackPlanID: String
    let policyRevision: String
    let recordedSeed: UInt64
}
```

## 8. Stable identity and canonical encoding

- IDs must be stable and content-independent where the entity has lifecycle identity.
- Fingerprints must use canonical ordering, normalized strings, stable enum raw values, explicit schema versions, and a repository-approved SHA-256 helper.
- Never rely on Swift `hashValue` for persisted fingerprints.
- Collections used for deterministic decisions must be stably sorted before evaluation and encoding.
- Equivalent input order must produce equivalent branch, certificate, correction, and promotion fingerprints.
- Every persisted type must carry a schema version or be embedded in a versioned envelope.

## 9. Branch certificate algorithm

```text
BUILD_CERTIFICATE(branch, canonicalState, policyState, authorityState, clock, seed):
  assert branch.baseGraphRevision exists
  readSet <- resolve all references used by branch delta and governing policies
  conditions <- build revisioned viability conditions from readSet
  conditionResults <- evaluate conditions in stable order
  lawResults <- evaluate hard, defeasible, preferred, and waived policies
  envelopeResults <- evaluate operating envelopes with hysteresis
  authorityResult <- evaluate user-owned, recipient-owned, joint, and external effects
  capacityResult <- call canonical Scheduling/Capacity owner without mutation
  invariantResults <- verify protected invariants
  conflictCore <- derive sufficient conflict core when hard failures exist
  robustness <- compute structured margin, never a universal life score
  status <- derive valid / fragile / blocked / invalid
  invalidationConditions <- record source revision and trigger conditions
  fingerprint <- canonical hash of all machine-relevant fields
  return certificate
```

### Full-rebuild conditions

Incremental evaluation must fall back to a full certificate rebuild when:

- The branch schema version changes.
- A policy compiler version changes incompatibly.
- The dependency index is missing or corrupt.
- A cycle cannot be resolved safely.
- A canonical migration changes object identity or revision semantics.
- The impact cone exceeds a calibrated bound.

## 10. Revision handling and incremental invalidation

```text
HANDLE_REVISION_EVENT(event):
  affectedDependencyIDs <- dependencyIndex.lookup(event.revisionedSourceID)
  impactCone <- traverse downstream dependencies in stable order
  if impactCone is empty:
      append no-impact inspection result
      return existing certificate unchanged
  invalidate impacted certificate components
  recalculate impacted components from current canonical state
  merge recalculated components with unchanged valid components
  rebuild certificate fingerprint
  if certificate remains valid or fragile:
      persist replacement certificate and lineage
  else:
      trigger bounded candidate materialization
```

### Cycle handling

- Strongly connected dependency components must be identified.
- Acyclic components evaluate topologically.
- Cyclic components require a bounded fixed-point evaluator with a deterministic iteration cap.
- Failure to converge yields `blocked`, not fabricated validity.

## 11. Conflict-core and correction-set generation

```text
DERIVE_CORRECTION_SETS(failedCertificate, activeBranch, contingencies):
  core <- derive sufficient or minimal conflict core
  fixed <- non-relaxable conditions, non-waivable laws, external facts, authority boundaries
  relaxable <- user-waivable or degradable conditions
  templates <- eligible contingencies + built-in bounded policy families
  for each template in stable precedence:
      corrections <- template.proposeCorrections(core, relaxable)
      if corrections preserve fixed conditions and declared invariants:
          normalize corrections
          create correction set with policy label and semantic fingerprint
  suppress correction sets with equivalent protected/sacrificed semantics
  return at most configured product maximum
```

Initial policy families:

1. `preserveContinuity`
2. `concentrateTemporarily`
3. `reduceOrDeferScope`
4. `noHonestFit`

## 12. Candidate materialization

```text
MATERIALIZE_CANDIDATE(correctionSet, activeBranch, canonicalState):
  apply corrections to a branch overlay only
  compile typed branch delta operations
  reject any operation that attempts direct canonical mutation
  compute affected object references
  compute authority partition
  build candidate certificate
  derive plain-language protects / sacrifices / assumes / authority / review summary
  return candidate branch
```

### Semantic duplicate suppression

Candidates are semantic duplicates when they have equivalent:

- Policy family
- Protected invariants
- Sacrificed or waived invariants
- Goal and Path lifecycle effects
- Authority effects
- Review condition
- Reversibility class

Different timeslots alone do not create a distinct branch.

## 13. Recommendation policy

Use lexicographic precedence:

1. Privacy and authority invariants
2. Non-waivable hard policies
3. Accepted safety and recovery protections
4. Fixed external commitments
5. Explicitly protected human functions
6. User-declared branch objective
7. Reversibility
8. Minimal disruption
9. Soft preferences
10. Schedule aesthetics

The recommendation output must include selected and rejected reasons. A numeric score may support tie-breaking internally, but no global score may be presented as the reason.

## 14. Branch promotion sequence

```text
SELECT_BRANCH(branchID, expectedCertificateFingerprint):
  load candidate and certificate
  re-read current canonical revisions
  reject stale base revision or stale certificate
  rebuild or revalidate certificate
  compute material confirmation scope
  prepare parent BranchPromotionTransaction
  atomically commit:
      branch-promotion Event
      user-owned canonical object changes
      projection invalidations
      prior-branch supersession link
      Receipt / History / rollback metadata
      recipient-owned proposal records
      external-effect outbox intents
  materialize projections
  set branch activeLocal when local commit is complete
  reconcile proposals and external effects independently
  set branch active only when branch-defining pending conditions resolve
```

### Rejection cases

- Base revision changed.
- Candidate certificate no longer matches.
- Required authority is unavailable.
- A hard law fails without an allowed waiver.
- A protected invariant fails.
- Branch delta contains an unsupported mutation owner.
- Transaction evidence cannot be made complete.

Rejection commits no requested object mutation.

## 15. Events and Commands

Provisional commands:

- `RequestLifeBranchMaterializationCommand` — read-only simulation request; no canonical life mutation.
- `SelectLifeBranchCommand` — parent semantic mutation.
- `ExpireLifeBranchCommand` — technical lifecycle maintenance where preauthorized.
- `RollbackLifeBranchPromotionCommand` — user-requested reversal or compensation.

Provisional events:

- `LifeBranchMaterialized` — research history or derived record; not necessarily a canonical life Event.
- `LifeBranchSelected`
- `LifeBranchPromoted`
- `LifeBranchSuperseded`
- `LifeBranchPromotionRejected`
- `LifeBranchRollbackApplied`
- `BranchCertificateReplaced`

Codex must decide which are canonical Events, derived records, Receipts, or History projections only after current canon routing. Do not proliferate events merely because the names exist here.

## 16. Persistence model

Recommended storage posture:

- Canonical personal state remains in existing object/event owners.
- Candidate branch values are bounded and may be ephemeral or persisted with expiration for interruption recovery.
- Active branch identity, base revision, accepted certificate, and lineage are durable.
- Branch deltas are persisted as typed operations or event references, not full graph snapshots.
- Dependency indexes are derived and rebuildable unless performance evidence justifies durable indexing.
- Certificates are immutable after issuance; replacement creates a new certificate linked to the prior one.
- Promotion lineage is durable and append-only.

## 17. Privacy and authority

- Branch simulation operates on local private graph data.
- Diagnostic traces contain IDs, categories, states, and fingerprints, not private values.
- Recipient-owned effects must use minimum necessary disclosure.
- A branch may be `activeLocal` while shared proposals or external effects remain unresolved.
- Another person’s calendar visibility does not grant responsibility authority.
- No branch may use a sensitive influence outside its declared purpose license.
- No branch may send private branch context to hosted AI or backend profiling.

## 18. Concurrency and actor isolation

- Certificate building and candidate simulation should run off the main actor.
- Canonical graph revisions must be read through a consistent snapshot or revisioned read set.
- Promotion uses the existing transaction coordinator and expected-version checks.
- Materialization requests are cancellable.
- Multiple requests for the same trigger and base revision must deduplicate by idempotency key.
- A new material revision invalidates older candidates and cancels or marks stale in-flight work.
- UI projections consume immutable branch snapshots.

## 19. Failure and recovery matrix

| Failure | Required behavior |
|---|---|
| Missing dependency index | Full certificate rebuild or blocked inspection; never assume valid. |
| Stale base revision | Mark candidate stale and require regeneration or revalidation. |
| Contradictory facts | Certificate becomes blocked or invalid with explicit conflict. |
| Dependency cycle fails to converge | Block branch; preserve active committed branch. |
| No correction set | Return `noHonestFit`; do not manufacture an option. |
| Every candidate infeasible | Preserve current state and show conflict core. |
| Recipient authority unresolved | Candidate is blocked or activeLocal after selection, never fully active. |
| External write failure | Preserve accepted local branch; expose reconciliation and rollback options. |
| Projection failure after commit | Preserve committed authority; rebuild projections from durable state. |
| Crash during promotion | Resume from durable transaction phase without duplicate mutation. |
| Model unavailable | Use deterministic policies and existing contingency templates. |
| Certificate corrupt | Quarantine, rebuild, and block promotion. |
| Performance bound exceeded | Cancel materialization and fall back to a bounded simplified explanation. |

## 20. Technical effects to measure

CEBR should not claim benefits without measured evidence. The prototype must measure:

- Count and proportion of objects recomputed after a localized revision.
- Count of unrelated objects changed compared with full replanning.
- Branch churn after small revisions.
- Candidate materialization time.
- Incremental recertification time.
- Full certificate rebuild time.
- Memory and storage relative to fully persisted alternate futures.
- Deterministic replay equivalence.
- Transaction consistency across Goals, Paths, Steps, Time, Recovery, and History.
- Number of manual repairs after branch selection.
- Correctness of stale-candidate rejection.
- Correctness of shared and external effect partitioning.

No numeric target is authorized until performance calibration defines device, OS, build, graph scale, horizon, recurrence scale, warm/cold state, percentile, energy, memory, and storage criteria.

## 21. Codex candidate file map

These are candidate placements only. A current canon pack may route differently.

```text
Native/Ambitions/Core/LocalRuntimeOS/
  PrivateLifeRuntimeKernel/Branching/
    LifeBranchModels.swift
    BranchViabilityCertificate.swift
    BranchLineageModels.swift
  Planning/Branching/
    BranchCertificateEngine.swift
    BranchDependencyIndex.swift
    BranchImpactConeService.swift
    BranchConflictCoreService.swift
    BranchCorrectionSetGenerator.swift
    BranchCandidateMaterializer.swift
    BranchSemanticDeduplicator.swift
    BranchRecommendationPolicy.swift
  Commands/
    SelectLifeBranchCommand.swift
    BranchCommandValidation.swift
  Transactions/Branching/
    BranchPromotionCoordinator.swift
    BranchPromotionRollback.swift
  EventJournal/Branching/
    BranchDomainEvents.swift
  Projections/Branching/
    ActiveBranchProjection.swift
    BranchComparisonProjection.swift
  Inspection/Branching/
    BranchInspectionService.swift
    BranchDecisionTraceProjection.swift
Native/Ambitions/Surfaces/Time/
  Projection/BranchComparison...
Native/Ambitions/Surfaces/Today/
  Projection/ActiveBranchConsequence...
Native/Ambitions/Surfaces/You/
  Projection/PersonalLawInspection...
Native/Ambitions/Quality/
  Scenarios/CEBR...
```

Do not create a top-level `LifeBranchEngine` authority parallel to the Private Life Runtime.

## 22. Test strategy

### 22.1 Model tests

- Stable encoding and fingerprinting
- Duplicate normalization
- State-transition legality
- Schema decoding and migration
- Semantic duplicate detection
- Authority partitioning

### 22.2 Certificate tests

- Valid branch
- Fragile branch
- Blocked authority
- Hard-law violation
- Preferred-policy sacrifice
- Waiver application and expiry
- Stale fact
- Missing fact
- Contradictory fact
- Full rebuild equivalence

### 22.3 Impact-cone tests

- Unrelated revision produces no impact
- Single dependency invalidates one condition and one operation
- Multi-hop impact
- Cycle handling
- Dependency deletion
- Index rebuild
- Stable traversal order

### 22.4 Conflict and correction tests

- Sufficient conflict core
- Minimal core where supported
- Fixed versus relaxable conditions
- Distinct correction families
- No duplicate timeslot-only branch
- No honest fit
- Bounded candidate count

### 22.5 Promotion tests

- Stale selection rejection
- Atomic user-owned mutations
- Shared proposal child remains pending
- External intent queued after local commit
- Parent Receipt and child lineage
- Projection rebuild
- Replay equivalence
- Rollback before external effect
- Compensation after external effect
- Crash at every phase
- Duplicate command idempotency

### 22.6 End-to-end scenario

Use the promotion + pregnancy + wedding + baby preparation + Ambitions continuity fixture described in the invention disclosure. Execute unrelated revision, dependent revision, temporary waiver, candidate materialization, selection, external failure, and rollback.

## 23. Acceptance gates

CEBR design is implemented only when evidence establishes:

1. One active branch and no duplicate canonical authority.
2. Operational certificate gating active status and promotion.
3. Incremental invalidation changes only the correct impact cone.
4. Full rebuild and incremental rebuild are replay-equivalent.
5. Candidate branches arise from distinct correction sets.
6. Timeslot-only duplicates are suppressed.
7. `noHonestFit` is supported.
8. Branch promotion is one parent transaction with complete Receipt lineage.
9. Shared and external effects are truthfully partitioned.
10. Prior branch and certificate remain inspectable.
11. Deterministic replay reproduces the same accepted state.
12. Accessibility presents materially equivalent branch decisions.
13. Performance is bounded on a calibrated iPhone target.

## 24. Research prototype work packages

These are design decompositions, not authorized tasks.

1. **CEBR-A: Value model and deterministic encoding**
2. **CEBR-B: Certificate engine on fixture data**
3. **CEBR-C: Dependency index and impact cone**
4. **CEBR-D: Conflict core and correction sets**
5. **CEBR-E: Candidate branch materialization and deduplication**
6. **CEBR-F: Read-only branch comparison projection**
7. **CEBR-G: Parent promotion transaction**
8. **CEBR-H: Replay, rollback, and external reconciliation**
9. **CEBR-I: Accessibility and proof scenarios**
10. **CEBR-J: Performance calibration and kill evaluation**

Codex must not execute these work packages until a current task authorization resolves exact scope, requirement IDs, files, validation, proof, rollback, and claim ceiling.

## 25. Non-goals

- Lifetime outcome prediction
- Happiness scoring
- Clinical inference
- Automatic binding law from behavior
- Continuous maintenance of several full alternate lives
- Cloud-hosted personal-state authority
- Autonomous branch commitment
- Arbitrary third-party app observation
- A fifth root or intelligence dashboard
- A universal policy language
- A general multi-user synchronization protocol
- Patent claim drafting by Codex

## 26. Codex operating procedure

Before any tracked work:

1. Confirm repository head and working-tree state.
2. Run `python3 scripts/ambitions-canon.py audit`.
3. Generate a bounded canon pack for the exact authorized CEBR scope.
4. Obtain current `task start` authorization.
5. Read only routed normative law and live evidence.
6. Use test-driven development for every bounded behavior.
7. Preserve existing source owners; do not create parallel authority.
8. Run exact validation and proof required by the task envelope.
9. Run exact-diff `task finalize` before commit or review.
10. Never claim implementation, Visual Green, accessibility conformance, performance, or release readiness beyond current evidence.

## 27. Open design questions

- Is `LifeBranch` a durable runtime record, a domain object, or a versioned decision record with a projection? The default recommendation is a durable runtime decision record, not a user-facing canonical root object.
- Which Personal Life Law subset belongs in the first CEBR prototype? The minimum is hard constraint, preference, permission, review requirement, and one-time waiver.
- Is the conflict core required to be mathematically minimal? The first implementation should use a truthful sufficient core and reserve “minimal” for proven algorithms.
- Should candidate certificates persist? Persist only when needed for interruption recovery, selection, or proof; otherwise use bounded ephemeral values.
- How are branch deltas encoded? Prefer typed operation enums and payloads aligned with existing domain Commands.
- How are cross-domain dependencies indexed without a universal ontology? Use stable typed references and narrow declared relations.
- When does `activeLocal` become `active`? Only when every effect required by the branch’s viability claim resolves.
- Which branch effects are branch-defining versus optional? The certificate must state this explicitly.

## 28. Traceability to current repository seeds

| CEBR need | Current seed | Current gap |
|---|---|---|
| Alternative semantic candidates | Goal Path candidate model | Goal-scoped, not whole-life branch |
| Changed-reality detection | Time reality reflow projection | Heuristic reason and local actions |
| Repair vocabulary | Protect, shrink, split, move, defer, drop, recover | Not composed into complete candidate deltas |
| Recovery lineage | Recovery Thread | Not branch-bound |
| Decision factors | Personalization Factor Ledger | No branch certificate |
| Decision replay | Replayable Decision Trace | No branch promotion decision family |
| Simulation and commit law | Private Life Runtime canon | No branch command or event family |
| Infeasibility | Scheduling canon | No branch conflict core / correction families |

## 29. References

- **R1.** USPTO, MPEP § 904, Search. https://www.uspto.gov/web/offices/pac/mpep/s904.html
- **R2.** USPTO, MPEP § 2131, Anticipation. https://www.uspto.gov/web/offices/pac/mpep/s2131.html
- **R3.** USPTO, MPEP § 2141, Obviousness. https://www.uspto.gov/web/offices/pac/mpep/s2141.html
- **R4.** USPTO, MPEP § 2106, Patent Subject Matter Eligibility. https://www.uspto.gov/web/offices/pac/mpep/s2106.html
- **R5.** Cooperative Patent Classification, Scheme and Definitions, current 2026.05 release. https://www.cooperativepatentclassification.org/cpcSchemeAndDefinitions
- **R6.** US 12,175,536 B2, Automatic life planning and execution based on personal goals. https://patents.google.com/patent/US12175536B2/en
- **R7.** US 2016/0321935 A1, Participant outcomes, goal management and optimization. https://patents.google.com/patent/US20160321935A1/en
- **R8.** US 7,967,731 B2, System and method for motivating users to improve their wellness. https://patents.google.com/patent/US7967731B2/en
- **R9.** US 11,276,041 / US 2017/0154315, Scheduling using potential calendars. https://patents.justia.com/patent/11276041
- **R10.** US 8,346,590 / US 2011/0184772, Automatically schedule and re-schedule meetings through search interface. https://patents.google.com/patent/US20110184772A1/en
- **R11.** US 4,817,018 A, Electronic calendaring with automatic assignment of alternates. https://patents.google.com/patent/US4817018A/en
- **R12.** J. de Kleer, An Assumption-Based TMS, AAAI-86. https://vvvvw.aaai.org/Library/AAAI/1986/aaai86-003.php
- **R13.** Landmark-Based Plan Distance Measures for Diverse Planning. https://ojs.aaai.org/index.php/ICAPS/article/view/13625
- **R14.** Plan Repair and Stability in Automated Planning. https://ojs.aaai.org/index.php/ICAPS/article/view/19815
- **R15.** H. Garcia-Molina and K. Salem, Sagas, ACM SIGMOD 1987. https://doi.org/10.1145/38713.38742
- **R16.** NIST SP 800-162, Guide to Attribute Based Access Control. https://www.nist.gov/publications/guide-attribute-based-access-control-abac-definition-and-considerations
- **R17.** USPTO Patent Public Search and preliminary search resources. https://www.uspto.gov/patents/search
- **R18.** USPTO CPC definition for G06F, including G06F 9/466 transaction processing. https://www.uspto.gov/web/patents/classification/cpc/html/defG06F.html

## 30. Repository evidence

- **C1.** `docs/canon/MANIFEST.toml` at `7dbf554876c686e62525a85d762fec04b67a4af4` — Active canon manifest; authority_state=active; compiler 0.2.0.
- **C2.** `docs/canon/CONSTITUTION.md` at `7dbf554876c686e62525a85d762fec04b67a4af4` — Product mission, user control, integrated orchestration, non-commodity center, local runtime moat.
- **C3.** `docs/canon/specifications/systems/private-life-runtime.md` at `7dbf554876c686e62525a85d762fec04b67a4af4` — Typed Command, local deterministic simulation, atomic mutation, Receipt, replay, external-after-local ordering.
- **C4.** `docs/canon/specifications/systems/scheduling-and-capacity.md` at `7dbf554876c686e62525a85d762fec04b67a4af4` — Capacity, fit, reflow, infeasibility, deterministic change sets, confirmation, rollback.
- **C5.** `Native/Ambitions/Core/Domain/GoalEngine/GoalPathCompilerModels.swift` at `7dbf554876c686e62525a85d762fec04b67a4af4` — Goal-level candidates, assumptions, dependencies, branches, risks, readiness, blocking reasons.
- **C6.** `Native/Ambitions/Surfaces/Time/Projection/TimeRealityReflowProjection.swift` at `7dbf554876c686e62525a85d762fec04b67a4af4` — Current changed-reality detection and local repair vocabulary.
- **C7.** `Native/Ambitions/Core/Domain/AmbitionGraphRecoveryThread.swift` at `7dbf554876c686e62525a85d762fec04b67a4af4` — Recovery Thread, last honest point, Proof preservation, re-entry, Receipt.
- **C8.** `Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/PersonalizationFactorLedger.swift` at `7dbf554876c686e62525a85d762fec04b67a4af4` — Decision factors, freshness, permission, sensitivity, selected/rejected candidates, replay fingerprint.
- **C9.** `Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/ReplayableDecisionTrace.swift` at `7dbf554876c686e62525a85d762fec04b67a4af4` — Local decision replay, source audit, context, contradictions, controls, uncertainty, Receipt state.
- **C10.** `docs/canon/generated/CODEX_START_HERE.md` at `7dbf554876c686e62525a85d762fec04b67a4af4` — Codex governance flow: audit, bounded pack, task-start authorization, exact-diff finalize.
- **C11.** `docs/canon/generated/CHATGPT_CODEX_HANDOFF.md` at `7dbf554876c686e62525a85d762fec04b67a4af4` — Request-only handoff; cannot authorize edits, proof, merge, or canon.
