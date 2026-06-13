# Source Atlas Seed Family Generation Rules

Status: Green for AMB-683 / PLOS-057 seed family generation rules documentation scope; Yellow for generator implementation, schema migration, release tooling, pack publication, computed runtime eligibility, runtime Step composition, live R2 promotion, privacy/legal approval, release readiness, device proof, accessibility proof, and measured performance proof.
Updated: 2026-06-13 America/New_York
Owning issue: AMB-683 / PLOS-057
Parent issue: AMB-613 / PLOS-M05

## Boundary

This artifact defines generation rules for starter, proof, replacement, recovery, and elasticity seed families.

It does not implement a generator, change Swift models, migrate schema, publish packs, provision Cloudflare/R2, create credentials, perform live R2 writes, compute runtime eligibility, or compose runtime Steps.

Generation rules describe how a future foundry tool may derive reusable source-backed seed drafts from source-bound claims, requirements, risk/jurisdiction metadata, contradiction/freshness state, proof maps, Goal Intent Geometry overlays, and Step physics overlays. The output remains public-reference Source Atlas structure only. It must not include private user goals, captures, schedules, receipts, proof, files, health/location data, identifiers, inferred priorities, or private life context.

All generated families default to `not_eligible` for runtime use until later active issues prove source binding, freshness, revocation, review/risk/jurisdiction, release receipt, rollback, Step Quality, no-hardcoded-Step, and runtime consumption gates.

## Required Inputs

Each generated seed draft must be derived only from source-approved inputs:

- source records with immutable source identity and hashes
- source-backed claims and requirements with exact source references
- freshness, revocation, contradiction, duplicate, and supersession states
- risk class, jurisdiction envelope, review state, and reviewer owner where needed
- proof candidate, proof strength, proof privacy class, correction hooks, and revocation hooks
- Goal Intent Geometry overlays for goal intent, path role, coverage gap, unsupported state, or local-personalization slot
- Step physics overlays for duration, energy, attention, mobility, location/access, deadline, prerequisite, consequence, and blocked-state envelope
- Coverage Demand Queue output for missing source, missing proof, missing jurisdiction, unsupported path, or ambiguous family routing

A seed draft is Red if the future generator must infer source coverage from private user data, uncited assumptions, popularity, generic productivity heuristics, or a cached runtime plan.

## Family Generation Rules

| Family | Generation trigger | Required output | Must not do |
|---|---|---|---|
| `starter_family` | A source-bound path has enough authority for a safe first action but not enough for a full path. | starter-only label, source ids, blocked/full-path distinction, minimum useful action, proof/source gaps, risk/jurisdiction state, no-final-schedule flag. | Present as full plan authority, mark completion path solved, or store exact user schedule. |
| `proof_family` | A claim, requirement, certification, receipt, correction, revocation, or local observation needs evidence before pathing can be trusted. | proof candidate, proof strength, source/claim ids, privacy class, correction hooks, revocation hooks, proof-needed wording, source-truth certification rule. | Store private proof, claim proof completion, certify source truth without official source-bound proof, or publish user evidence to R2. |
| `replacement_family` | Original path is blocked, stale, contradicted, unsafe, jurisdiction-mismatched, capacity-incompatible, unavailable, or no longer source-current. | replacement reason, preserved source/risk/jurisdiction/freshness state, rollback/review link, consequence and proof impact, non-silent-swap receipt requirement. | Swap source authority, weaken proof/safety constraints, hide the original block, or treat convenience as authority. |
| `recovery_family` | Real life interrupted execution: missed day, fatigue, changed source, failed prerequisite, proof gap, schedule conflict, or post-block re-entry. | recovery reason, non-shame copy posture, re-entry envelope, source/proof/freshness deltas, reflow/receipt expectation, local personalization slot boundary. | Frame recovery as failure, erase missed consequences, skip source review, or mutate future path silently. |
| `elasticity_family` | A Step or path needs shrink, extend, defer, split, merge, rescope, deadline protection, or resource-light variation. | mutation type, duration/energy/deadline envelope, source/risk/jurisdiction/proof impact, split/merge lineage, receipt requirement, Step Quality preflight hook. | Mutate material scope without receipt, break source traceability, drop proof lineage, or convert elasticity into generic task resizing. |

## Differentiation Rules

Generation must keep the families sharply separated:

- Starter seeds answer "what can begin safely now"; they do not answer "what completes the goal."
- Proof seeds answer "what evidence is needed"; they do not store or satisfy that evidence.
- Replacement seeds answer "what alternate route preserves authority"; they do not hide the blocked route.
- Recovery seeds answer "how to re-enter without shame or lost proof"; they do not erase the interruption.
- Elasticity seeds answer "how the shape changes"; they do not change source, risk, deadline, or proof obligations silently.

When a candidate satisfies multiple families, generate the narrowest authoritative family and record secondary roles as coverage needs. Ambiguous family classification routes to `review_needed` or Coverage Demand Queue, not to a weak general-purpose seed.

## Coverage Roles

Seed families cover different gaps:

- `starter_family`: entry gap when source coverage supports a first safe action but full path coverage is incomplete.
- `proof_family`: trust gap when source truth, user-provided proof, certification, correction, or revocation evidence is needed.
- `replacement_family`: blocked-path gap when the current route is no longer available, safe, current, or compatible.
- `recovery_family`: continuity gap after interruption, missed execution, fatigue, changed reality, or source change.
- `elasticity_family`: scale and fit gap when timing, energy, attention, deadline, location, or path size changes.

Coverage is not a claim of runtime eligibility. Generated seed coverage records what a future runtime may inspect after later gates pass.

## Moat Maturity Alignment

AMB-683 contributes the seed-generation semantics portion of the current Source Atlas moat maturity pass:

- compiler-grade Source Atlas substrate: generation consumes source-bound claims, requirements, review state, contradiction state, and proof maps as typed inputs rather than loose prose.
- Goal Intent Geometry: generated seeds preserve goal intent, path role, unsupported state, source-needed state, and user-local personalization slot boundaries.
- Step physics: generated seeds carry duration, energy, deadline, prerequisite, consequence, mobility, attention, and blocked-state envelopes for later Step Quality owners.
- proof primitives: proof seeds preserve `sourceEvidence`, `localObservation`, `userProvided`, `correctionArtifact`, `revocationArtifact`, and proof strength without claiming proof completion.
- recovery vectors: recovery seeds make interruption, source-change, missed-day, fatigue, and post-block re-entry explicit and non-shaming.
- Coverage Demand Queue: unsupported, ambiguous, jurisdiction-needed, proof-needed, source-needed, and private-data candidates route to demand items instead of weak seeds.
- computed runtime eligibility: remains future-owned and default `not_eligible`; AMB-683 only names the inputs later computation must require.

AMB-683 does not activate R2 staging, upload canaries, compute runtime eligibility, or make packs runtime-consumable. AMB-973 owns live Cloudflare R2 staging activation for M05; AMB-617 / PLOS-M10 owns runtime consumption; AMB-635 / PLOS-M26 owns production certification.

## Failure Handling

Future generation must fail closed:

- Missing source binding: route to `source_needed`; do not generate source-backed seed.
- Missing proof: generate only proof-needed structure or route to Coverage Demand Queue.
- Ambiguous family: route to `review_needed`; do not create a generic hybrid seed.
- Private user material: route to local-only user mini-pack or local personalization slot; never public Source Atlas/R2.
- High or unknown risk: preserve risk state and review requirement; do not generate current-path authority.
- Jurisdiction unknown where applicability varies: route to jurisdiction-needed or blocked.
- Stale, contradicted, revoked, or superseded source: block current-family generation and route to replacement, recovery, review, rollback, or source-needed state.
- Duplicate variant: merge only when source, risk, jurisdiction, freshness, proof, and role are equivalent; otherwise preserve distinct variants or review.
- Combinatorial explosion: cap variants by source authority, family priority, risk, deadline, and Step Quality relevance; defer low-evidence permutations.

## Existing Source Anchors

AMB-683 inspected these anchors:

- `artifacts/source-atlas-factory/SOURCE_ATLAS_PACK_SEED_FOUNDRY_PIPELINE.md` defines generation as pipeline stage 4 and keeps public-reference seed output separate from runtime use.
- `artifacts/source-atlas-factory/SOURCE_ATLAS_REUSABLE_SEED_TAXONOMY.md` defines seed classes, family grouping, required traits, and default `not_eligible` runtime state.
- `artifacts/source-atlas-factory/SOURCE_ATLAS_RISK_JURISDICTION_CLASSIFICATION.md` defines risk and jurisdiction overlays that generated seeds must preserve.
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift` defines `SourceAtlasStarterItem`, `SourceAtlasProofCandidate`, `SourceAtlasProofStrength`, and `SourceAtlasProofMapEntry` source/proof helper boundaries.
- `docs/codex/SEED_BASED_PLANNING_LAW.md`, `docs/codex/STEP_ELASTICITY_RUNTIME_LAW.md`, and `docs/codex/LIFE_CONSEQUENCE_REFLOW_LAW.md` define the hardcoded-Step, elasticity, recovery, and receipt boundaries future generation must preserve.

These anchors are source/control-plane evidence only. AMB-683 does not claim generator implementation, runtime Step composition, or runtime pack consumption exists.

## Scaling Hotspots

Future implementation should bound:

- family fan-out across starter/proof/replacement/recovery/elasticity variants
- proof-map fan-out across claims, requirements, and jurisdictions
- risk/jurisdiction variant multiplication
- local personalization slot explosion
- duplicate replacement and elasticity candidates
- Step Quality preflight cost
- Coverage Demand Queue size and review latency

No measured performance, storage, network, CPU, or battery proof is claimed by AMB-683.

## Non-Claims

This artifact does not implement seed generation, generator CLI/API, schema changes, validators, scanners, release tooling, pack publication, Cloudflare/R2 setup, credential creation, live R2 writes, canary objects, runtime fetch/cache/quarantine, computed runtime eligibility, runtime Step composition, app source changes, privacy/legal approval, release readiness, device proof, accessibility proof, measured performance proof, AMB-973 execution, AMB-617 runtime consumption, AMB-635 production certification, or AMB-613 parent completion.
