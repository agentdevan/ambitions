+++
initiative = "intelligence-quality-safety-evaluation"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

The intelligence evaluation foundation is a local-first, claim-bound evidence
system, not a second product runtime and not a scoring service. It runs named
evaluation cases against immutable dependency snapshots, preserves typed
evidence and adjudications, and derives one of three verdicts for a specific
claim: `pass`, `needs_revision`, or `insufficient_evidence`. A hard-invariant
failure always fails the affected claim. Unrelated quality results cannot
average it away.

The implementation has three deliberate planes:

1. **Evaluation domain and runner.** Pure `Sendable` value types, validators,
   deterministic evaluators, suite partitioning, verdict derivation, and
   dependency invalidation live under a new
   `Core/LocalRuntimeOS/IntelligenceEvaluation` owner. They read typed snapshots
   and evaluation fixtures; they never write Goals, Steps, schedules,
   Capabilities, source truth, or external operations.
2. **Evidence storage and development inspection.** Shared licensed or synthetic
   cases are repository fixtures. Runs over private local data remain in a
   protected, evaluation-specific local store. Development and review builds
   can inspect exact bindings, evidence, disagreements, limitations, and
   invalidation. This store never becomes a hidden source of personalization.
3. **Owning-surface evidence handoffs.** The evaluation foundation can project a
   minimal readiness/limitation value to an owning feature and its existing
   Trust/source inspection surfaces. The projection has no mutation method and
   is not a user-facing dashboard or universal score.

The first vertical case is `EVAL-FUTURE-ASTRONAUT-PIVOT-001`. It exercises the
entire future closed-loop contract using only synthetic/licensed inputs and
typed test doubles. Production-source coverage, real model behavior,
direct-user usefulness, and release readiness remain explicit missing evidence
until their actual dependencies exist.

## User flows

### Flow 1 — Register and validate an evaluation suite

1. A developer or reviewer selects a committed suite manifest.
2. The registry decodes it, validates stable identifiers and schema versions,
   and rejects duplicate case or claim identities.
3. Each case declares its exact feature/version/claim, applicable requirements,
   evidence methods, hard invariants, dependencies, coverage partition, and
   expected limitations.
4. The dependency resolver records every applicable binding and records
   `unavailable`, `unknown`, or `not_applicable` explicitly.
5. If a required binding is absent, unsupported, rights-ineligible, or stale for
   the declared claim, the case is `not_ready`; it does not start optimistically.

### Flow 2 — Run deterministic contract and source-grounding cases

1. The runner creates an immutable run request and dependency snapshot.
2. It selects the declared coverage partition and evaluates cases in stable
   identifier order with a bounded concurrency limit.
3. Deterministic evaluators produce typed observations; they do not directly
   issue verdicts outside their declared dimension.
4. The invariant evaluator checks privacy, authority, grounding, typed-owner,
   deletion, fallback, severe-bias, and invalidated-evidence laws first.
5. Other evaluators record dimensional measures and limitations. A missing
   evaluator produces `insufficient_evidence`, never a default pass.
6. The verdict engine derives claim-specific results and persists the immutable
   run, findings, evidence references, coverage, and dependency binding.
7. Cancellation preserves completed case evidence as a partial run, identifies
   unexecuted cases, and cannot produce `pass` for the incomplete partition.

### Flow 3 — Adjudicate factual, accessibility, expert, or model-assisted evidence

1. A case requiring judgment enters `awaiting_adjudication` after automated
   evidence collection.
2. Each reviewer records an independent typed finding with method, applicable
   rubric, source/model identity, and limitations.
3. Disagreement is shown without overwriting either finding.
4. An authorized adjudicator may resolve the disagreement with a rationale, or
   leave the result `insufficient_evidence`.
5. A model-assisted evaluator is always labeled, version-bound, and calibrated.
   It cannot adjudicate its own produced output alone and cannot be sole proof
   for factual truth, privacy, rights, authority, or readiness.

### Flow 4 — Inspect a run and its claim ceiling

1. Devan opens the evaluation inspector from a development/review entry point.
2. The suite list shows claim-specific verdicts, invalidation, partial status,
   and coverage—not an aggregate score.
3. The run detail exposes non-private inputs, exact dependency bindings,
   evaluator methods, evidence, findings, reviewer disagreement, missing
   coverage, and limitations.
4. Source and model evidence link to their existing local inspection record
   where permitted. Private payloads are represented by typed redacted
   descriptors and fingerprints, never raw content in shared artifacts.
5. An invalidated historical result remains inspectable with the dependency
   change that invalidated it and the replacement run, if one exists.

### Flow 5 — Hand evidence to an owning user surface

1. An owning feature requests a projection for its exact feature version and
   claim.
2. The read-only client returns separate readiness, evidence type, source,
   uncertainty, limitation, and control descriptors.
3. The feature presents only the evidence relevant to its existing reason,
   source, uncertainty, correction, or Trust experience.
4. No evaluation verdict accepts a proposal, confirms a mutation, creates a
   Goal, changes Time, or performs an external action.
5. If the projection is absent, stale, invalidated, or insufficient, the owning
   feature truthfully limits its claim and preserves its deterministic fallback.

### Flow 6 — Invalidate evidence after a dependency change

1. A model, prompt, guardrail, source pack, source claim, policy, schema, app,
   canon requirement, locale, or operating-system binding changes.
2. The invalidation planner queries the reverse dependency index and identifies
   affected evidence and verdicts.
3. It records an immutable invalidation event; historical results remain.
4. Change management receives a read-only impact set and recommended rerun
   partitions. It may not waive hard failures through this interface.
5. Reruns create new run identities and delta evidence. They never modify the
   earlier run in place.

### Flow 7 — Run and delete a private local case

1. A user or developer explicitly elects to run a supported evaluation against
   local private state.
2. The case manifest declares local-only input classes and forbids remote/model
   evaluators unless the future approved model boundary permits them.
3. Raw private values remain in memory or the protected private case store;
   shared outputs receive only permitted redacted descriptors.
4. The inspector can delete the private case, its artifacts, cached payloads,
   and derived indices. Historical shared suite results are unaffected.
5. Any verdict depending on deleted evidence becomes invalidated. Deletion
   cannot leave a hidden influence path into product behavior.

### Flow 8 — Attach direct-user validation evidence

1. A separately approved study protocol supplies a consent/retention contract,
   task version, participant coverage statement, measures, observations, and
   deletion rules.
2. The evaluation foundation stores only the approved de-identified study
   artifact or local pointer, not an unrestricted private life graph.
3. The verdict engine checks that the evidence matches the exact interaction
   and usefulness claim.
4. Recruitment count, acceptance, engagement, or completion alone cannot pass
   usefulness. Missing consent or task binding yields `insufficient_evidence`.

## States and recovery

### Suite and case states

| State | Meaning | Visible recovery |
|---|---|---|
| `registered` | Manifest decoded but dependencies not resolved | Resolve dependencies |
| `not_ready` | Required binding, evaluator, rights state, or fixture is absent/invalid | Inspect missing inputs; no run starts |
| `ready` | Required bindings are present for the selected partition | Run partition |
| `running` | Immutable snapshot is executing | Cancel safely or wait |
| `partial` | Some cases completed; cancellation or runner failure left explicit gaps | Resume as a new run or rerun partition |
| `awaiting_adjudication` | Automated evidence exists but required human/expert judgment is missing | Record independent review |
| `disputed` | Required adjudicators disagree | Preserve both; adjudicate or remain insufficient |
| `completed` | All selected cases reached a terminal evidence state | Inspect verdicts |
| `invalidated` | A bound dependency changed or evidence was deleted/revoked | Inspect cause and run affected partition |
| `superseded` | A later completed run replaces the active applicability of this run | Compare lineage; history remains |

### Claim verdicts

- `pass`: every mandatory invariant and required evidence type for the exact
  claim passed, with no missing mandatory coverage.
- `needs_revision`: at least one hard invariant or required quality condition
  failed. Findings name the owning feature and affected claim.
- `insufficient_evidence`: no disqualifying failure is asserted, but required
  inputs, coverage, adjudication, runtime/device proof, model proof, expert
  proof, accessibility proof, or direct-user evidence is absent or inapplicable.

`pass` is never inferred from an empty suite, unavailable evaluator, skipped
case, expired source, unbound model, or partial run. `not_applicable` is a
dependency/dimension applicability state, not a verdict and not a pass.

### Failure and recovery rules

- **Decode/schema failure:** quarantine only the malformed manifest, report its
  path and supported schema, and continue validating independent manifests.
- **Duplicate identity:** reject the conflicting cases before execution; never
  choose a winner by file order.
- **Runner crash or cancellation:** persist a partial record atomically; abandon
  in-flight temporary artifacts; rerun under a new identity.
- **Source unavailable/stale/conflicting:** keep the exact state and last-known
  source binding, restrict current claims, and offer a later rerun.
- **Model unavailable/refusal/context limit/invalid output:** retain the raw
  response only inside the permitted local retention boundary, record the typed
  failure, and exercise the deterministic fallback. Never fabricate a model
  result.
- **Adjudicator disagreement:** show both results and rationale; do not silently
  average or select one. An unresolved mandatory disagreement is insufficient.
- **Private-egress canary:** stop the affected run, quarantine its transient
  artifacts, record a hard privacy failure without reproducing the secret, and
  require explicit remediation before rerun.
- **Disk full or protected-data unavailable:** leave the prior store consistent,
  report that evidence was not durably recorded, and do not issue a verdict.
- **Index corruption:** rebuild reverse-dependency and search indices from
  immutable run records; indices never own evidence.
- **Deletion interruption:** use a tombstoned deletion transaction; resume on
  next launch until payload, cache, and index removal complete. Dependent
  verdicts become invalid immediately.
- **External test indeterminate:** preserve the external operation state and
  require reconciliation; never retry blindly or label success.

## Frontend experience specification

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: Use only the visible meaning, actions, limits, and recovery language resolved by User flows and States and recovery; localization must preserve every non-claim.
- Accessibility: Use native semantic containers and controls with the exact reading order, reflow, assistive actions, focus, announcements, non-color status, and reduced-effects behavior defined below.
- Visual proof: Before the frontend task starts, render one production-intended SwiftUI fixture in one representative viewport, record protected characteristics, and obtain owner approval. Runtime navigation/state, screenshot, accessibility, and named-device proof remain separately required.
- Visual gate: required
- Experience authority: Task 7 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Ownership and affected components

The future implementation introduces these owners; exact files are fixed during
grooming and listed in the implementation plan.

| Owner | Responsibility | Explicit non-responsibility |
|---|---|---|
| `IntelligenceEvaluationModels` | Stable identities, dependency bindings, coverage, evidence, findings, adjudication, invalidation, verdicts | Product mutations or source truth |
| `IntelligenceEvaluationManifestLoader` | Decode and schema-check committed suite/case manifests | Deciding product readiness |
| `IntelligenceEvaluationRegistry` | Uniqueness, requirement mapping, evaluator registration, suite partitions | Running tests or changing manifests |
| `IntelligenceEvaluationRunner` actor | Immutable run snapshot, bounded scheduling, cancellation, partial completion | Canonical runtime commands |
| `IntelligenceEvaluationInvariantEvaluator` | Non-negotiable privacy, authority, grounding, deletion, fallback, severe-bias checks | Weighted quality scoring |
| `IntelligenceEvaluationVerdictEngine` | Claim-specific terminal verdict from typed evidence | Release or merge approval |
| `IntelligenceEvaluationInvalidationPlanner` | Reverse dependency impact and supersession plan | Updating dependencies |
| `IntelligenceEvaluationRepository` | Atomic local run/evidence/adjudication/invalidation persistence | Canonical Goals/Time/Capability storage |
| `IntelligenceEvaluationInspectionProjection` | Redacted development/review and Trust handoffs | New root surface or dashboard |
| `IntelligenceEvaluationCLI` | CI/developer suite execution and machine-readable reports | Reading private app stores by default |

The models and deterministic logic live in
`Native/Ambitions/Core/LocalRuntimeOS/IntelligenceEvaluation/` so they share the
runtime's typed, replayable, local-first boundary. Repository fixtures and the
CLI live under `tools/intelligence-evaluation/`. Product-facing inspection reuses
`Native/Ambitions/Trust/` and a development-only route rather than creating a
fifth root. Existing feature modules access only a read client defined in
`Core/LocalRuntimeOS/Boundary/Clients/`.

### Core data contracts

All records are `Codable`, `Sendable`, `Equatable`, stable-ID value types with an
explicit schema version. Raw strings are normalized at construction. Unknown
enum cases fail closed at decode until a migration supports them.

- `IntelligenceEvaluationSuite`: ID, schema, title, feature families, partition
  IDs, case IDs, rubric bindings, owner, and fixture release.
- `IntelligenceEvaluationCase`: ID, exact product claim, feature/version,
  requirements, dimensions, hard invariants, dependency requirements,
  evaluator methods, expected evidence, coverage descriptors, privacy class,
  and limitations.
- `IntelligenceEvaluationDependencyBinding`: typed kind; stable identity;
  exact version/hash/release; source claim/freshness/rights/jurisdiction where
  applicable; availability state; captured time; and applicability rationale.
- `IntelligenceEvaluationRun`: ID, suite/case/partition IDs, start/end, immutable
  dependency snapshot hash, executor version, lifecycle state, completed and
  skipped case IDs, cancellation/failure, and predecessor/successor IDs.
- `IntelligenceEvaluationEvidence`: ID, evidence type, producing method,
  dimension, applicable requirement, artifact reference/fingerprint, privacy
  class, collection environment, result, limitations, and retention class.
- `IntelligenceEvaluationFinding`: ID, severity, hard-invariant flag, affected
  claim, observed/expected state, evidence IDs, owner, and required revision.
- `IntelligenceEvaluationAdjudication`: independent reviewer/evaluator identity,
  surface, method/rubric/version, verdict, rationale, disagreement state, and
  evidence bindings. Personal identity is not required for automated fixtures.
- `IntelligenceEvaluationCoverage`: exercised and missing requirements,
  dimensions, source families, jurisdictions, locales, devices, operating
  systems, models, corpus releases, and study tasks.
- `IntelligenceEvaluationVerdict`: exact claim binding, terminal result, hard
  failures, evidence IDs, coverage, limitations, invalidation state, and claim
  ceiling.
- `IntelligenceEvaluationInvalidation`: changed/deleted dependency, affected
  records, reason, time, replacement run, and preserved lineage.

IDs are opaque and stable. A deterministic `runKey` may prevent accidental
duplicate execution for the same request, but every intentional rerun receives
a new run ID and links to its predecessor. Hashes prove byte/version binding;
they never imply correctness, authority, or secrecy.

### Typed interfaces

```swift
protocol IntelligenceEvaluationCaseLoading: Sendable {
    func loadSuite(id: IntelligenceEvaluationSuiteID) async throws
        -> IntelligenceEvaluationSuiteBundle
}

protocol IntelligenceEvaluationDependencyResolving: Sendable {
    func resolve(_ requirements: [IntelligenceEvaluationDependencyRequirement]) async
        -> IntelligenceEvaluationDependencySnapshot
}

protocol IntelligenceEvaluationMethod: Sendable {
    var descriptor: IntelligenceEvaluationMethodDescriptor { get }
    func evaluate(_ input: IntelligenceEvaluationInput) async
        -> IntelligenceEvaluationMethodResult
}

protocol IntelligenceEvaluationRunning: Sendable {
    func run(_ request: IntelligenceEvaluationRunRequest) async throws
        -> IntelligenceEvaluationRunID
    func cancel(runID: IntelligenceEvaluationRunID) async
}

protocol IntelligenceEvaluationRepository: Sendable {
    func begin(_ run: IntelligenceEvaluationRun) async throws
    func append(_ batch: IntelligenceEvaluationEvidenceBatch) async throws
    func complete(_ result: IntelligenceEvaluationRunResult) async throws
    func records(_ query: IntelligenceEvaluationQuery) async throws
        -> IntelligenceEvaluationRecordPage
    func deletePrivateCase(_ id: IntelligenceEvaluationCaseID) async throws
        -> IntelligenceEvaluationDeletionReceipt
}

protocol IntelligenceEvaluationReadClient: Sendable {
    func projection(for binding: IntelligenceFeatureClaimBinding) async
        -> IntelligenceEvaluationEvidenceProjection
}
```

There is intentionally no `approve`, `release`, `acceptProposal`,
`executeCommand`, `writeGoal`, `writeSchedule`, or `performExternalAction`
method. Change management consumes an immutable impact/report DTO through its
own future boundary.

### Execution and data flow

```text
committed suite manifest + typed fixture
              |
              v
 manifest loader -> registry -> dependency resolver
                                |
                                v
                      immutable run snapshot
                                |
                                v
                    runner actor / methods
                      |       |       |
                      v       v       v
                 evidence  findings  adjudication pending
                      \       |       /
                       verdict engine
                             |
             +---------------+----------------+
             v                                v
 protected evaluation repository     redacted run report
             |                                |
      inspection projection       CLI / CI / review artifact
             |
 owning feature's existing source/reason/Trust presentation
```

Product runtime snapshots are read through existing typed clients or synthetic
fixtures. The runner never opens SwiftData containers directly when an owning
repository/client exists. A case may use an in-memory isolated store to exercise
mutations, but it cannot point at the user's live canonical store for a
destructive test. Evaluation output returns through a read-only evidence
projection and cannot enter the command executor.

### Persistence and migration

Shared manifests, rubrics, and synthetic/licensed fixtures are versioned
repository files. They contain no private user data. The app-side repository
uses a separate protected directory beneath the active runtime generation with:

- an append-only run/evidence log;
- content-addressed local artifacts with privacy and retention metadata;
- rebuildable suite, claim, dependency, and invalidation indices;
- deletion tombstones and receipts;
- a schema ledger independent of canonical entity schemas.

Private evaluation payloads use the strongest supported file-protection class,
remain excluded from backup/export unless explicitly selected under a future
approved contract, and are not synchronized. The record keeps fingerprints and
redacted descriptors only where deletion lineage requires them; it must not keep
recoverable private content after deletion.

Initial implementation creates schema v1 and therefore requires no migration
from a prior evaluation store. It must still prove: unsupported future schemas
fail closed; interrupted creation rolls back; index rebuilding is deterministic;
private deletion resumes; and a future migration can run through the existing
backup/dry-run/repair ownership rather than ad hoc on launch.

### Concurrency, replay, and determinism

- `IntelligenceEvaluationRunner` is an actor and is the single owner of run
  lifecycle transitions.
- Registry and fixture snapshots are immutable for a run. A source refresh or
  model update during execution affects only a later run.
- Cases execute in stable ID order with a configurable bounded task group.
  Evidence order is canonicalized before hashing and verdict derivation.
- Repository batches are idempotent by `(runID, caseID, methodID, attempt)` and
  commit atomically. Duplicate delivery cannot duplicate evidence.
- Deterministic methods receive an injected clock and seed. Their exact inputs
  and outputs are replayable.
- External model responses, expert judgments, and user-study observations are
  captured evidence, not claimed deterministic replay. Re-evaluation creates a
  new evidence item and preserves the earlier one.
- Cancellation is cooperative; completed batches remain valid but a partial run
  cannot pass a complete-suite claim.
- The reverse dependency index is rebuilt from records and never drives a
  mutation. Invalidation append operations are idempotent.

### Source, model, and evaluator boundaries

- Source-grounding methods consume versioned Source Atlas public claims and
  rights/freshness metadata. They do not fetch arbitrary URLs during verdict
  derivation.
- Production corpus, jurisdiction, opportunity, and provider claims remain
  insufficient until their owning initiatives supply eligible packs.
- A future model adapter exposes only a typed evaluation method. The foundation
  records model/prompt/guardrail/context bindings and refuses unbound output.
- Model output remains evidence or proposal input. Deterministic validators and
  typed owners remain authoritative.
- A judge model cannot evaluate its own output as the sole result and cannot be
  the sole method for truth, privacy, rights, authority, or readiness.
- Prompt/source injection cases must treat all public text and generated text as
  data. They cannot route commands or tool calls around the owning boundary.

### External effects

The default runner injects a non-production external-operation test double. A
case may exercise preparation, preview, confirmation, local commit, external
attempt, reconciliation, retry, compensation, operator-required, and
indeterminate states. Production credentials and endpoints are unavailable to
the suite. Any future provider integration must add a separately approved test
account/tenant contract, a kill switch, idempotency scope, cleanup/compensation,
and an explicit opt-in suite partition before a real effect can occur.

### Observability and private-data separation

Evaluation emits structured local counters and durations by suite/case/method,
plus redacted failure codes, dependency fingerprints, and claim verdicts. It
does not emit prompts, Goal text, schedule contents, source excerpts containing
private annotations, participant responses, filenames derived from user text,
or personal embeddings. Debug descriptions call the same redactor as persisted
reports. A seeded secret canary must be checked across logs, artifacts, crash
material, screenshots, caches, CLI output, and evaluator payloads.

No remote telemetry is required for invalidation. Public dependency metadata or
an app upgrade may trigger a local comparison against stored bindings. Private
results remain on device unless the user explicitly exports a reviewed artifact
under a future contract.

### Canon handoff

Implementation grooming names a future new
`docs/canon/specifications/systems/intelligence-evaluation.md` owner and narrow
traceability updates to validation, Source Atlas, Private Life Runtime, privacy,
Trust, Goals, and Time specifications. Those edits are implementation work only
after separate canon review. This Design does not change canon, and current
canon wins any conflict.

## Privacy and accessibility

### Privacy and security controls

- Fixture manifests declare `public_licensed`, `synthetic_shared`,
  `deidentified_study`, or `private_local` data class. Mixed or unclassified
  cases fail closed.
- Shared fixtures are reviewed for licensing, redistribution, provenance, and
  reidentification risk before repository inclusion.
- Private local cases require explicit invocation and show the data categories,
  evaluators, retention, and deletion behavior before running.
- Remote methods receive an allow-listed minimized DTO, never a raw private
  graph. Until the private model runtime is approved, private-local cases cannot
  invoke remote methods at all.
- Artifact names use opaque IDs. Reports redact payloads before formatting, so
  a later logger cannot accidentally capture raw values.
- Evaluation repositories are excluded from ordinary source-pack export and
  cloud continuity. A future export requires itemized preview and confirmation.
- Delete/reset covers inputs, outputs, evaluator caches, local embeddings,
  screenshots, logs under evaluation ownership, indices, and future influence.
  A receipt lists removed categories without reproducing content.
- Threat verification covers prompt injection, tool injection, citation swaps,
  stale/poisoned sources, schema-valid semantic violations, private egress,
  evaluator self-grading, counterfactual discrimination, orphaned derived
  influence, and blind external retry.

### Accessibility and comprehensibility

The development inspector and owning-surface evidence projection use native
semantic controls and existing Ambitions visual language. They must support:

- VoiceOver names, values, traits, headings, rotor order, and actions for suite,
  case, verdict, evidence type, limitation, disagreement, and invalidation;
- Dynamic Type through accessibility sizes without truncating the claim,
  source, uncertainty, or recovery action;
- reduced motion with no meaning dependent on animated deltas;
- localization-safe ordering and full spoken expansion of internal status
  codes;
- keyboard/switch/voice-control focus and activation for inspection filters,
  disclosure groups, comparison, delete, and rerun;
- redundant text/icon/state treatment so pass/failure/insufficient/invalidated
  never depends on color alone;
- plain-language summaries separated from exact technical evidence, with raw
  identifiers available through a deliberate detail disclosure rather than the
  primary reading order.

Generated prose cannot be the only source of a required control, verdict,
reason, limitation, or recovery step. If a summary is unavailable or invalid,
typed fallback copy remains complete.

## Requirement traceability

| Scope requirement | Design decisions | Primary verification |
|---|---|---|
| `REQ-001` | Stable suite/case/run/evidence/finding/adjudication/verdict IDs; exact feature/version/claim and claim ceiling | Model validation, fixture identity, overclaim rejection |
| `REQ-002` | Immutable typed dependency snapshot with explicit unavailable/unknown/not-applicable states | Dependency resolver matrix and snapshot hashing |
| `REQ-003` | Typed evidence categories and separate coverage; no cross-type satisfaction | Verdict-engine evidence-type tests |
| `REQ-004` | Dimensional findings; no aggregate score; invariant-first derivation | API/static audit and mixed-result fixtures |
| `REQ-005` | Dedicated invariant evaluator whose failures force `needs_revision` | One adversarial fixture per named invariant |
| `REQ-006` | Source-claim/release/freshness/rights/jurisdiction/conflict binding and entailment adjudication | Supported, decorative, stale, conflicting, fabricated citation cases |
| `REQ-007` | Read-only evaluation clients and absence of command/mutation interfaces; typed semantic validation | Compile-time ownership and mutation-negative tests |
| `REQ-008` | Classified fixtures, local protected repository, minimized DTOs, opaque filenames, shared redactor/canary | Privacy/egress/storage/log/cache/screenshots suite |
| `REQ-009` | Correction delta, isolation cases, invalidation on delete/reset, resumable deletion receipts | Correction/counterfactual/delete/reset integration tests |
| `REQ-010` | Counterfactual/slice evidence, explicit legitimate-difference causes, aspiration-preservation invariant | Slice and opportunity-preservation fixtures plus expert review |
| `REQ-011` | Explicit dependency/failure states, deterministic fallback, no-pass-on-skip/partial rules | Offline/stale/conflict/model/tool/permission/provider failure matrix |
| `REQ-012` | Reverse dependency index, immutable invalidation, new-ID reruns, historical lineage | Dependency change and supersession tests |
| `REQ-013` | Versioned evaluator descriptor, calibration binding, no self/sole-judge rules | Missing-version, uncalibrated, self-judge, sole-method negative cases |
| `REQ-014` | Separately approved study artifact contract and exact task/claim binding | Study-schema validation and claim-ceiling cases |
| `REQ-015` | Native semantic inspector, typed fallback copy, complete accessibility matrix | Unit, snapshot, simulator, assistive-technology, device evidence |
| `REQ-016` | Non-production external-operation adapter by default; explicit state-machine cases; separate provider test contract | Test-double state matrix and zero-production-effect audit |
| `REQ-017` | Coverage object, missing coverage visibility, insufficient verdict, no empty/skip pass | Empty/partial/partition/unsupported matrix |
| `REQ-018` | Redacted inspector, read-only feature projection, immutable change-management DTO | Projection privacy and mutation-authority tests |

## Verification design

### Automated domain and contract proof

- Decode/round-trip every domain model and reject malformed schemas, empty IDs,
  duplicate identities, unknown evidence types, illegal state transitions, and
  broader-than-case claim reuse.
- Prove every `REQ-###` is present in at least one committed case and every case
  declares expected evidence and limitations.
- Exercise all terminal verdicts, partial/adjudication/invalidation states, every
  named hard invariant, and the rule that no aggregate score exists.
- Prove deterministic ordering, injected clock/seed use, dependency snapshot
  hashing, stable report bytes, idempotent batches, cancellation, and rerun
  lineage.
- Run citation-entailment, stale/conflict/currentness, rights, jurisdiction,
  unsupported-detail, invented-ID, injection, and semantic-validation cases.
- Prove correction isolation, delete/reset influence removal, counterfactual
  opportunity preservation, honest fallback, and model-evaluator limits.

### Persistence, migration, and recovery proof

- Fresh-store creation, file protection, backup/export exclusions, atomic
  batches, crash recovery, disk-full behavior, index rebuild, unsupported schema
  rejection, resumable private deletion, deletion receipts, and no residual
  cache/index influence.
- Initial schema has no user-data migration. Verification must explicitly record
  legacy migration as `not_applicable`, while proving the v1 schema ledger and
  future migration/repair handoff.

### Privacy and security proof

- Seed unique canaries through every permitted input class and assert zero
  appearance in remote requests, logs, reports, diagnostics, crash payloads,
  filenames, screenshots, caches, model-judge inputs, and shared artifacts.
- Static ownership checks ensure the evaluation module imports no canonical
  command executor or production external credentials.
- Threat fixtures cover direct/indirect prompt injection, tool injection,
  poisoned claims, citation swaps, semantic schema attacks, evaluator
  self-grading, private cache residue, reidentification, and blind retry.
- A local network-denial test proves deterministic evaluation and inspection
  remain useful offline.

### Runtime and integration proof

- Run `EVAL-FUTURE-ASTRONAUT-PIVOT-001` end to end against isolated in-memory
  owners and synthetic Source Atlas packs.
- Verify recommendation -> provisional Goal -> path -> schedule -> correction
  -> localized resimulation -> pivot evidence without accepting any proposal or
  mutating the live store.
- Validate Source Atlas, Recommendation Mutation Lab, Planning, Scheduling,
  Private Life Runtime, Trust, privacy, external-operation test doubles, and
  change-management DTO seams independently.
- Exact model-specific, production-source, provider-production, and direct-user
  results are `not_applicable` or `insufficient_evidence` in the foundation
  release; the report must show that ceiling.

### Accessibility and rendered-device proof

- Unit checks for semantic labels, values, traits, focus order, redundant state
  meaning, localization keys, and typed fallback copy.
- Snapshot/preview matrix for empty, ready, running, partial, awaiting review,
  disputed, pass, needs revision, insufficient, invalidated, deleted, long-copy,
  and dense evidence states across supported text sizes and color schemes.
- Simulator interaction using VoiceOver-equivalent accessibility inspection,
  Dynamic Type, reduced motion, keyboard/switch/voice-control focus, and
  localization stress.
- At least one supported physical iPhone run proving protected-data transitions,
  delete/resume behavior, performance, and actual accessibility reading order.
  Simulator screenshots are not physical-device evidence.

### Performance and resource proof

- Record fixture count, dependency count, evidence count, artifact bytes, peak
  memory, wall-clock time, and cancellation latency for small, launch-floor, and
  stress partitions.
- Set budgets from measured baseline during implementation; no unmeasured number
  is invented here. Hard-invariant partitions must remain runnable locally on a
  supported launch-floor device.
- Verify bounded concurrency, streaming report generation, paged inspection,
  index rebuild, and deletion do not block the main actor.

### Build and repository validation

- Regenerate the Xcode project from `project.yml` after adding files; never edit
  generated project state directly.
- Run changed-scope Code Quality workflow equivalents, focused tests, the full
  Ambitions unit suite, canon check after future canon edits, `git diff --check`,
  SwiftLint, static analysis, and secrets scanning.
- CLI fixtures and Swift domain fixtures must share a schema conformance test so
  the development tool cannot pass inputs the app rejects.
- Verification reports list exact commands, launched/executed/pass counts, and
  separate source, build, simulator, device, accessibility, privacy, and
  direct-user evidence ceilings.

## Open decisions

No unresolved product decision remains. Implementation grooming may choose
concrete serialization and index libraries only within the following closed
constraints: local protected storage, stable versioned records, rebuildable
indices, no remote private telemetry, no aggregate score, no mutation authority,
and explicit insufficient/invalidation states. A need to violate one of those
constraints must return to Scope rather than being resolved in code.

## Review and approval

Review verdict: **PASS**. The Design was reviewed against every approved Scope
requirement and for complete user and recovery flows, single domain ownership,
typed handoffs, data flow, persistence and future migration, concurrency,
replay, deletion, public/private separation, model and source boundaries,
external effects, non-leaking observability, accessibility, and proportionate
verification. The review found no blocking contradiction, missing requirement
mapping, or unresolved product decision.

Devan delegated approval authority for this documentation program. This Design
was approved under that authority on 2026-08-04. Approval authorizes
implementation grooming only; it does not claim implementation, runtime proof,
canon adoption, merge, deployment, or release readiness.
