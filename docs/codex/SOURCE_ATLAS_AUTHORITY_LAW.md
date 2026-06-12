# Source Atlas Authority Law

Status: Active PLOS M00 governance law
Issue: AMB-639 / PLOS-003
Parent: AMB-608 / PLOS-M00
Authority posture: Supporting PLOS law subordinate to `docs/truth/*`
Runtime implementation proof: none

This law defines Source Atlas as always-running source authority for PLOS execution. It does not implement source freshness, change existing Source Atlas models, alter R2 distribution, add pack payloads, or rename existing types. If this law conflicts with active truth files, the truth files win and this law must be repaired before any dependent issue closes Green.

## Core Law

Source Atlas is operational architecture, not a static content library.

During PLOS runtime work, Source Atlas must continuously answer:

- what source truth is available
- whether that source truth is current
- whether the source has been changed, contradicted, or revoked
- which jurisdiction, age, eligibility, risk, and review conditions apply
- whether a path can drive a Recommended step
- whether a path can be installed into schedule
- whether a path can be shared
- whether the user should see a compressed state instead of raw internal machinery

Source Atlas can provide reusable source, claim, requirement, proof, projection, path, and starter guidance. It must not become a store of finished exact-user plans, a generic content shelf, or a hidden source of unreviewed authority.

## Existing Model Anchors

AMB-639 inspected current source before installing this law. Existing seams include:

- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
  - `SourceAtlasPackKind`
  - `SourceAtlasSourceKind`
  - `SourceAtlasClaimState`
  - `SourceAtlasFreshnessState`
  - `SourceAtlasRiskClass`
  - `SourceAtlasValidationIssue`
  - `SourceAtlasRequirementSourceState`
  - `SourceAtlasRequirementReviewState`
  - `SourceAtlasStarterItem`
  - `canDriveCurrentRecommendation`
- `Native/Ambitions/Domain/SourceAtlasFreshnessBrokerModels.swift`
  - freshness manifest, pack hash/signature, changed claim IDs, rollback pointers, and local update receipt concepts
- `Native/Ambitions/Domain/SourceAtlasUserMiniPackBuilderModels.swift`
  - user mini-pack local-only/value-model boundary
  - user-provided source records
  - local proof, review-required, and blocked mini-pack eligibility
- `Native/Ambitions/Domain/SourceAtlasIntentMatchModels.swift`
  - source-needed, unsupported, runtime-blocked, high-risk, and review-required match outcomes
- `Native/Ambitions/Runtime/SourceAtlasStepCandidateFieldBridge.swift`
  - Source Atlas seed traces, source record IDs, claim IDs, freshness warnings, and sensitive context redactions
- `Native/AmbitionsTests/**/SourceAtlas*.swift`
  - existing Source Atlas model, store, bridge, coverage, importer, offline fallback, and privacy tests
- `scripts/sa-*.sh` and `tools/source-atlas/**`
  - existing Source Atlas validation and pack/tooling surface that future phases must extend before duplicating

These anchors are existing-first context. They are not a claim that AMB-639 implements or validates runtime behavior.

## Authority Responsibilities

Source Atlas authority covers these responsibilities:

| Responsibility | Law |
|---|---|
| Source truth | Claims that affect runtime behavior must bind to source records, local proof, or an explicit source-needed state. |
| Source freshness | Runtime eligibility depends on freshness, review date, expiration, changed claims, and stale/revoked handling. |
| Source revocation | Revoked sources cannot drive Recommended step, schedule install, share eligibility, or official-current claims. |
| Source contradiction | Contradicted claims require review or blocked behavior; they must not silently downgrade into current source. |
| Jurisdiction applicability | Legal, school, age, travel, health, financial, certification, and rule-bound paths require jurisdiction and eligibility context. |
| Risk class | High-risk, irreversible, safety, legal, financial, medical, minor, professional, and deadline-sensitive classes require guarded behavior. |
| Review state | Review-required or blocked states cannot drive runtime Green until review is approved or a safe lower-authority mode is explicit. |
| Source-needed state | Missing, unknown, stale, or unapproved source creates source-needed behavior instead of invented authority. |
| Runtime eligibility | Only eligible source states may drive Recommended step, schedule install, or runtime expansion. |
| Share eligibility | Sharing requires public-safe source authority and privacy-safe projection; user-private context is not shareable by default. |

## Internal Source States

Internal states may be numerous because runtime and validation need precision. They must compress before ordinary user-facing display.

| Internal state | Meaning | Runtime eligibility |
|---|---|---|
| official-current | Official or approved source, current freshness, approved review, applicable envelope, and acceptable risk. | Eligible for Recommended step and schedule install when all envelope checks pass. |
| current-not-official | Current source exists but is not official or approved as official. | May support explanation or low-risk guidance; cannot claim official authority. |
| maintainer-curated | Curated by Ambitions or trusted maintainers with recorded provenance. | Eligible only if freshness, review, risk, and envelope pass. |
| user-provided | User supplied the material. | Local/private context only unless reviewed and explicitly promoted; not public source truth. |
| local-proof-only | Locally verified by user proof or local receipt, without public source authority. | Can shape local execution when safe; not official source truth or share authority. |
| starter-guidance-only | Safe starter guidance exists without full source-backed pathing. | Can produce explicitly bounded starter behavior, not full source-backed Green. |
| source-needed | Source/pathing coverage is absent, incomplete, unapproved, or unknown. | Cannot drive authoritative runtime behavior. |
| review-required | Source, risk, jurisdiction, or extraction requires review. | Cannot drive Green until review passes or scoped low-authority behavior is explicit. |
| jurisdiction-needed | Applicability depends on location, age, school, professional, legal, medical, travel, certification, or rule context. | Cannot drive schedule install or authoritative pathing until jurisdiction is known. |
| stale | Freshness has expired or cannot support current planning. | Blocked for current recommendation until refreshed or degraded. |
| source-changed | A source or claim changed since the runtime last used it. | Requires re-evaluation before runtime eligibility. |
| contradicted | Claims conflict with current source, another source, or local proof. | Blocked until resolved. |
| revoked | Source, claim, pack, or eligibility has been revoked. | Blocked and must roll back or degrade. |
| blocked | Risk, review, safety, privacy, or policy blocks runtime action. | Not eligible. |
| unknown | State is absent or cannot be determined. | Not eligible for source-backed behavior. |

## User-Facing Compressed States

Users should not see dozens of raw states at rest. PLOS UI and copy should compress internal source authority into clear states:

| User-facing state | Internal sources | User meaning |
|---|---|---|
| Ready | official-current or otherwise eligible current authority | Ambitions can use this source/path for the scoped action. |
| Needs source | source-needed, unknown, missing coverage | Ambitions needs source/pathing before treating this as source-backed. |
| Needs review | review-required, high-risk review, extraction review, jurisdiction-needed | Ambitions needs a check before planning or sharing. |
| Tighter now | source-changed, stale refreshed to stricter requirements, eligibility narrowed | A source change narrowed the safe path. |
| Affects another goal | cross-goal consequence, source conflict, proof or schedule collision | This path has consequences elsewhere in the user's life system. |
| Deadline at risk | deadline-sensitive source/risk/freshness state affects timing | Time reality threatens safe execution. |
| Not safe to plan | blocked, contradicted, revoked, unsafe, high-risk unreviewed | Ambitions cannot safely plan this path as requested. |
| Fresh path available | source-needed, stale, or unsupported gap resolved by validated fresh source | New validated source/pathing can be considered. |

Compressed states are product semantics, not shipped copy. Future UI work must still pass the active Product Design Truth, accessibility expectations, and scoped issue gates.

## Applicability Envelope

Every source, claim, pack, seed, path overlay, proof map, or share projection that can affect runtime behavior needs an applicability envelope:

- effective date
- review date
- expiration or freshness date
- jurisdiction
- age and eligibility conditions
- risk class
- source hash
- source or pack version
- review state
- allowed runtime actions
- allowed share actions
- revocation or rollback pointer when applicable

Missing envelope data must degrade to source-needed, review-required, jurisdiction-needed, or unknown. It must not be silently treated as current.

## Runtime Eligibility Rule

Only eligible states can drive Recommended step or schedule install.

Eligible means:

- source state is official-current or otherwise explicitly eligible for the scoped runtime action
- freshness is current enough for the risk class
- review state is approved or not required for the scoped low-risk behavior
- jurisdiction and age/eligibility conditions are satisfied when applicable
- source hash/version is known when the claim depends on public source authority
- no contradiction, revocation, blocked state, or unresolved source change is present
- the action is allowed by the applicability envelope

If any of those checks fail, PLOS must use source-needed, needs-review, starter-guidance-only, local-proof-only, jurisdiction-needed, high-risk guarded, or blocked behavior as appropriate. It must not call the result source-backed Green.

## Integration Points

This law binds later PLOS phases and adjacent laws:

- Any Goal Solution Loop: goal intake must route source-needed, jurisdiction-needed, high-risk, coverage-demand, and unsupported states without fake pathing.
- Seed-Based Planning: seeds must retain source authority, freshness, envelope, and eligibility metadata through runtime composition.
- Step Quality Firewall: generic, unsafe, stale, source-weak, uninspectable, or hardcoded finished Steps must be rejected or degraded.
- Step Elasticity: shrink, defer, replace, split, or recovery behavior must respect source authority and expiration.
- Life Consequence Reflow: source changes that affect another goal must surface as cross-goal consequence, not hidden reranking.
- High-Risk Safety: high-risk classes require guarded behavior and cannot bypass review through local draft or starter wording.
- Sharing: share eligibility requires public-safe source projection and must exclude private user context by default.

## Green Enforcement

Any future PLOS issue that claims Source Atlas authority, source-backed pathing, source freshness, pack eligibility, seed availability, sharing eligibility, or official-current behavior must reference this law before Green.

Green requires:

- a live `AMB-*` issue identifier
- existing-first Source Atlas inspection
- explicit internal source state and compressed user-facing state when source state is user-visible
- applicability envelope coverage for runtime-affecting source claims
- proof that only eligible states drive Recommended step or schedule install
- clear separation between source truth and user mini-pack/local-only personalization
- no private user data in R2 or public Source Atlas objects
- no runtime implementation claim without live source and validation proof

Yellow is allowed when the law/report is correct but future source mapping, pack proof, freshness proof, review proof, or implementation proof remains owned. Red is required for static-library framing, finished hardcoded Step packs as the main unit, missing source-needed/review/stale/revoked states, raw internal-state overload in UI, user mini-pack/source truth conflation, PLOS label Linear access, or phase-order violation.

## Cross-Links

Primary authority:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `AGENTS.md`

PLOS law authority:

- `docs/codex/PERSONAL_LIFE_OS_RUNTIME_LAW.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `docs/codex/SEED_BASED_PLANNING_LAW.md`
- `artifacts/plos-runtime/PLOS_PHASE_GATES.md`
- `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.md`

Source Atlas support authority:

- `artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md`
- `artifacts/source-atlas-factory/SAF_GOAL.md`
- `artifacts/source-atlas-factory/SAF-run-state.md`
- `.agents/skills/source-atlas-factory/SKILL.md`
- `scripts/sa-*.sh`
- `tools/source-atlas/**`

Proof for this law installation:

- `artifacts/personal-life-os/reports/PLOS-003-source-atlas-seed-laws-report.md`

## Non-Claims

This file does not prove:

- Source Atlas runtime implementation
- source freshness implementation
- pack creation or production pack readiness
- R2 distribution readiness
- share implementation
- app source behavior
- source migration completion
- release readiness
- TestFlight or App Store readiness
- accessibility verification
- privacy or legal approval
- performance validation
- device validation
- owner approval
