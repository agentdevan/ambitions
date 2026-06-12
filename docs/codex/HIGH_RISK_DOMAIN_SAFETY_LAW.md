# High Risk Domain Safety Law

Status: Active PLOS M00 governance law
Issue: AMB-643 / PLOS-007
Parent: AMB-608 / PLOS-M00
Authority posture: Supporting PLOS law subordinate to `docs/truth/*`
Runtime implementation proof: none
Safety implementation proof: none

This law defines high-risk domain safety boundaries for future PLOS execution. It does not implement high-risk packs, safety classifiers, crisis flows, jurisdiction logic, sharing UI, source packs, or runtime behavior.

## Core Law

Disclaimers alone are insufficient.

High-risk domains require runtime gates that classify risk, check source authority, apply jurisdiction and eligibility where relevant, enforce professional-boundary or blocked modes, and preserve privacy/share redaction.

Ambitions must not turn unsafe, regulated, crisis, legal, medical, financial, minor/student, or sensitive private goals into ordinary productivity Steps merely because the UI includes a disclaimer.

## Existing Authority Anchors

AMB-643 inspected current docs and source before installing this law. Existing anchors include:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
  - local-first, privacy-safe, inspectable product behavior is required; R2 must not receive private user data; high-risk private context cannot be casually externalized.
- `docs/truth/RELEASE_TRUTH.md`
  - privacy/legal/App Review/release readiness are not proven.
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSafetyTriageModels.swift`
  - source-present safety triage includes illegal/harmful, crisis/self-harm, harm to others, stalking/harassment, fraud/evasion, dangerous health/fitness, regulated professional domain, impossible timeline, minor age sensitive, privacy sensitive, source sensitive, source review, professional boundary, crisis support, unsafe blocked, and local-first boundary checks.
- `Native/Ambitions/Domain/AmbitionsOSPrivacySafetyModels.swift`
  - source-present privacy safety models classify sensitive areas, external projection blocks, redaction, privacy receipts, and unsafe states.
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
  - Source Atlas risk classes include legal/civic, financial, health/medical, crisis/safety, minor/student data, professional boundary, deadline-sensitive, and sensitive private.
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
  - pack store quarantines revoked, contradicted, unsupported schema, hash mismatch, and invalid high-risk packs.
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
  - high-risk classes require guarded behavior and cannot bypass review through local draft or starter wording.
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
  - private user data cannot be moved to R2 or a hosted personal backend.

These anchors are existing-first context only. They do not prove high-risk safety implementation.

## High-Risk Domains

High-risk domains include:

- health and medical
- legal and civic
- financial
- crisis and safety
- regulated goods
- cannabis
- minors and student data
- sensitive private goals
- immigration
- education eligibility
- certification eligibility
- stalking, harassment, fraud, evasion, exploitation, coercion, and harm to others
- dangerous fitness, medication, treatment, or recovery behavior

This list is a minimum. Future source or product work may classify additional domains as high-risk.

## Required Routing

Future high-risk PLOS behavior must route through:

| Gate | Requirement |
|---|---|
| risk classification | Identify risk class before pathing, scheduling, sharing, or source-pack eligibility. |
| jurisdiction applicability | Identify jurisdiction, age, school, professional, legal, medical, travel, or eligibility context when relevant. |
| source authority | Require current eligible source or degrade to source-needed/review-required/blocked. |
| professional-boundary mode | Keep regulated or professional domains inside scoped, non-professional-advice support unless reviewed. |
| blocked unsafe mode | Block unsafe, crisis, illegal, harmful, exploitative, stalking, harassment, fraud, or evasion behavior. |
| share redaction | Apply default redactions and block raw sensitive projection. |
| receipt/failure state | Record what was blocked, routed, reviewed, or safely degraded. |

Any implementation that skips these gates and relies on disclaimer copy is Red.

## Allowed Modes

Allowed high-risk modes:

- source-needed
- jurisdiction-needed
- review-required
- professional-boundary scaffold
- crisis support redirect
- unsafe blocked
- privacy review
- local-only private plan
- source-stale review
- clarification needed
- starter guidance only for low-risk bounded behavior

Disallowed modes:

- unreviewed authoritative medical/legal/financial instruction
- crisis routed to productivity
- unsafe behavior converted into a Step
- regulated professional advice without boundary
- jurisdiction-free legal/civic/eligibility action
- raw sensitive share/export
- R2 storage of private high-risk user context
- "disclaimer only" approval

## Green Enforcement

Any future PLOS issue that claims high-risk safety, legal/civic, medical, financial, crisis/safety, regulated goods, cannabis, minors/student data, jurisdiction, source authority for high-risk domains, or high-risk sharing Green must reference this law before Green.

Green requires:

- a live `AMB-*` issue identifier
- existing-first inspection of safety, privacy, source, jurisdiction, sharing, receipt, and runtime ownership
- explicit risk class
- source authority or source-needed/review-required/blocked state
- jurisdiction applicability where relevant
- professional-boundary or blocked unsafe mode where relevant
- share redaction and local data boundary when projection is in scope
- receipt or safe failure state
- no privacy/legal/release/App Review claim without current proof

Yellow is allowed when this law is installed but future high-risk classifier, source pack, jurisdiction, crisis flow, professional-boundary, redaction, or runtime proof remains owned. Red is required for disclaimer-only safety, unsafe operationalization, crisis-to-productivity routing, private data in R2, raw sensitive sharing, jurisdiction overclaim, legal/privacy/release overclaim, PLOS label Linear access, or phase-order violation.

## Cross-Links

- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `docs/codex/SHARING_AND_PROGRESS_STORY_LAW.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`
- `docs/codex/LIFE_CONSEQUENCE_REFLOW_LAW.md`

Future phase owners:

- AMB-625 / PLOS-M18 must use this law before High-risk safety, legality, and jurisdiction Green.
- AMB-613 / PLOS-M05 and AMB-614 / PLOS-M06 must use this law for high-risk Source Atlas packs.
- AMB-629 / PLOS-M20 must use this law for high-risk sharing and progress stories.

## Non-Claims

AMB-643 does not claim:

- safety classifier implementation
- high-risk domain pack implementation
- jurisdiction logic implementation
- crisis support implementation
- professional-boundary runtime behavior
- sharing redaction implementation
- privacy/legal approval
- App Review readiness
- release readiness
- runtime feature implementation
- app source change
- PLOS-M00 completion
- PLOS-M01 or later execution
