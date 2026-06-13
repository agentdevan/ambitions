# Goal Shape Fingerprint Model

Status: AMB-694 / PLOS-072 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane model for deterministic Any Goal fingerprinting and replay linkage.

This artifact defines `GoalShapeFingerprint`, the deterministic replay key produced after AMB-755 `GoalIntentGeometry` and before later path selection, Step compilation, reflow, coverage arrival unlocks, or replay comparison. It ensures identical canonical inputs produce identical routing fingerprints while materially different user states, source states, capability evidence, or privacy boundaries produce different fingerprints.

This is not Swift implementation, fingerprint generator implementation, validator automation, executable fixture corpus, runtime pathing, UI, source pack content, R2 transport, privacy/legal approval, release readiness, accessibility proof, device proof, performance proof, or security certification.

## Existing Source Ownership

AMB-694 inspected these existing owners before adding this contract:

- `artifacts/personal-life-os/any-goal/GOAL_INTENT_GEOMETRY_MODEL.md`
- `artifacts/personal-life-os/any-goal/GOAL_INTENT_GEOMETRY_MODEL.json`
- `artifacts/personal-life-os/any-goal/ANY_GOAL_OPERATING_MODE_MODEL.md`
- `Native/Ambitions/Runtime/PersonalizationFactorLedgerBuilder.swift`
- `Native/Ambitions/Domain/PersonalizationFactorLedgerModels.swift`
- `Native/Ambitions/Runtime/SourceAtlasRuntimeBridgeReplay.swift`
- `Native/Ambitions/Runtime/StepCandidateFieldGenerator.swift`
- `Native/Ambitions/Runtime/ReplayableDecisionTraceModels.swift`
- `Native/Ambitions/Domain/RuntimeSnapshotLedgerModels.swift`
- `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `docs/codex/PERSONAL_LIFE_OS_RUNTIME_LAW.md`

These are ownership anchors and dependency inputs. They are not evidence that `GoalShapeFingerprint` is implemented in app runtime.

## Model Role

`GoalShapeFingerprint` is a local deterministic digest contract for the canonical, privacy-bounded shape of a goal route.

Required invariant:

The fingerprint must be generated only from AMB-755 allowed fingerprint inputs and local version identifiers. It must never contain or derive from raw private goal text, exact schedules, private proof detail, unredacted collaborator names, raw source-needed narratives, secrets, credentials, or support data.

## Required Fields

| Field | Requirement | Red stop |
|---|---|---|
| `fingerprintId` | Stable local id for the canonical fingerprint record. | ID includes raw goal text or private context. |
| `schemaVersion` | Version of the fingerprint contract. | Version omitted, making replay ambiguous. |
| `geometryRef` | Reference to the local `GoalIntentGeometry` record. | Fingerprint bypasses geometry. |
| `geometryDigest` | Digest of allowed geometry fields only. | Digest includes raw private text or hidden assumptions. |
| `operatingMode` | AMB-692 mode id that scoped the route. | Fingerprint ignores operating mode. |
| `goalState` | Goal state from GoalStateAssessment. | Goal state is inferred after Step generation. |
| `domain` | Broad domain family. | Unknown domain becomes generic plan fingerprint. |
| `specificDomain` | Optional narrower domain when explicit or source-supported. | Narrow domain is stereotype-derived. |
| `deadlineSemantics` | Hard deadline, target date, season, rolling window, no-date exploration, recurring maintenance, or unknown. | Hard deadline and aspiration date hash the same. |
| `ambiguityState` | Clear or missing/unsafe-to-infer state. | Ambiguous and clear goals hash the same. |
| `riskClass` | Safety, jurisdiction, and reversibility posture. | High-risk and low-risk goals hash the same. |
| `jurisdictionPosture` | Not-needed, needed, known, unknown, blocked, or review-needed. | Jurisdiction-needed is dropped. |
| `sourcePosture` | Ready, partial, source-needed, review-needed, stale, revoked, contradicted, jurisdiction-needed, local-only-private, or blocked. | Non-ready source hashes as ready. |
| `selectedPackSetFingerprint` | Local digest of selected public Source Atlas pack ids/versions when applicable. | Pack changes do not change replay key. |
| `capabilityContextBranch` | Local evidence branch from AMB-755. | Same raw goal across different local evidence hashes the same. |
| `localContextVersion` | Local version pointer for personalization slots, never raw values. | Raw schedule/profile/proof values enter fingerprint. |
| `privacyClass` | local-only, local-user-context, public-source-reference, abstract-gap, or blocked. | Privacy boundary changes do not change fingerprint. |
| `replayComparisonPolicy` | Rules for same-input replay, changed-input fork, and blocked-input replay refusal. | Replay silently reuses a stale or unsafe route. |
| `audit` | Local receipt metadata for inputs, excluded fields, digest version, and no-claim status. | No trace for fingerprint construction. |

## Determinism Rules

- Same canonical inputs, same schema version, same source pack set, same local context version, and same privacy class must produce the same fingerprint.
- Any material change to operating mode, domain, goal state, deadline semantics, ambiguity, risk, jurisdiction, source posture, selected pack set, capability branch, local context version, or privacy class must produce a new fingerprint or a replay comparison fork.
- Fingerprints are local replay keys, not public analytics ids.
- A fingerprint may include digests of allowed canonical fields, but it may not include raw user text or raw private context.
- Changed fingerprints must explain whether the route changed because of user correction, source change, capability evidence, context version, deadline/risk change, or privacy boundary.

## GoalIntentGeometry Linkage

AMB-755 owns the allowed input boundary. `GoalShapeFingerprint` may consume only:

- domain and specific domain
- goal state
- deadline semantics
- ambiguity state
- risk class and jurisdiction posture
- source posture
- capability context branch
- operating mode
- privacy class

`GoalShapeFingerprint` must reject raw private goal text, exact schedule, private proof detail, private location or identifiers, unredacted collaborator names, raw source-needed narrative, and secret or credential data.

## Replay Linkage

`GoalShapeFingerprint` must become a future input to replay and comparison owners:

- M10 Golden vertical slice replay proof
- M12 Multi-Path Lattice path selection
- M13 Step Graph Compiler determinism
- M16 Life Consequence / Cross-Goal Reflow comparison
- M26 certification gauntlets

Replay cannot claim Green until future owners prove executable generation, storage, comparison, and user-visible receipt behavior.

## Same-Goal / Different-Person Fixture Linkage

AMB-694 defines fingerprint obligations for the later M07 fixture corpus:

- at least 50 raw goal fixtures
- at least five same-goal/different-person fixture families
- proof that identical canonical inputs produce identical fingerprints
- proof that materially different capability branches, source posture, deadline semantics, risk class, or local context version produce different fingerprints
- proof that beginner, practiced, expert-tracking, collaborative-supported, high-risk, jurisdiction-needed, source-needed, coverage-demand, unsupported, and unsafe-blocked variants do not collapse into one generic fingerprint
- proof that no fingerprint material contains raw private goal text

AMB-694 does not create the executable corpus. Later M07 owners must implement it before claiming routing validator Green.

## Red Conditions

- fingerprint includes raw private goal text or private context
- fingerprint can be computed before GoalIntentGeometry
- same canonical input produces nondeterministic fingerprints
- materially different local user states produce the same route fingerprint
- source-ready and source-needed states hash the same
- high-risk and ordinary low-risk states hash the same
- hard deadline and aspiration date hash the same
- selected pack set changes do not change or fork the fingerprint
- replay silently reuses a stale or unsafe route
- fingerprint is treated as public analytics, telemetry, R2 key, or cross-user identifier

## Downstream Consumers

- AMB-695 / PLOS-073 clarification engine
- AMB-696 / PLOS-074 source-needed local scaffold
- AMB-697 / PLOS-075 Coverage Demand Queue
- AMB-698 / PLOS-076 optional anonymous abstract coverage request
- AMB-699 / PLOS-077 fresh coverage arrival detection
- AMB-700 / PLOS-078 unsupported/unsafe modes
- AMB-701 / PLOS-079 high-risk guarded routing
- AMB-617 / PLOS-M10 Golden vertical slice runtime consumption
- AMB-619 / PLOS-M12 Multi-Path Lattice
- AMB-620 / PLOS-M13 Step Graph Compiler
- AMB-623 / PLOS-M16 Life Consequence / Cross-Goal Reflow Engine
- AMB-635 / PLOS-M26 certification gauntlets

## Non-Claims

This artifact does not claim app source change, Swift implementation, fingerprint generator implementation, validator automation, executable fixture corpus, runtime path selection, generated Step behavior, replay implementation, source pack creation, R2 write, coverage request transport, runtime eligibility computation, UI implementation, accessibility proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, device proof, measured performance proof, security certification, AMB-695/PLOS-073 execution, AMB-617/M10 runtime consumption, AMB-635/M26 production certification, or AMB-615 parent completion.
