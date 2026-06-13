# Source Atlas Risk / Jurisdiction Classification

Status: Green for AMB-682 / PLOS-056 risk and jurisdiction classification documentation scope; Yellow for classifier implementation, jurisdiction resolver implementation, schema migration, release tooling, pack publication, runtime guarded-mode enforcement, runtime eligibility proof, live R2 promotion, privacy/legal approval, release readiness, device proof, accessibility proof, and measured performance proof.
Updated: 2026-06-13 America/New_York
Owning issue: AMB-682 / PLOS-056
Parent issue: AMB-613 / PLOS-M05

## Boundary

This artifact defines how Source Atlas packs, seeds, claims, and requirements receive risk and jurisdiction classifications during authoring and validation so downstream gates can fail closed.

It does not implement a classifier, jurisdiction resolver, guarded runtime mode, schema migration, pack publication, Cloudflare/R2 setup, credential creation, live R2 writes, runtime eligibility, or runtime pack consumption.

Risk and jurisdiction classification is upstream Source Atlas metadata. It is not legal, medical, financial, educational, certification, safety, or professional advice.

## Classification Axes

Every pack, seed, source-backed claim, and projected requirement must carry explicit classification output for:

| Axis | Required values / behavior |
|---|---|
| `risk_class` | `low_risk_skill`, `hobby`, `sport_rules`, `career_context`, `education_eligibility`, `certification_eligibility`, `legal_civic`, `financial`, `health_medical`, `crisis_safety`, `minor_student_data`, `professional_boundary`, `deadline_sensitive`, `sensitive_private`, or `unknown` before review. |
| `review_requirement` | `none`, `requested`, `required`, `approved`, or `blocked`; high-risk, unknown, jurisdiction-sensitive, stale-critical, contradicted, revoked, private/public, or professional-boundary material cannot skip review. |
| `jurisdiction_scope` | `global`, `country`, `region`, `state_province`, `city_local`, `institution`, `program`, `employer`, `league`, `school`, `platform`, `travel_context`, or `unknown`. |
| `age_school_context` | `adult_general`, `minor_possible`, `minor_confirmed`, `student_record`, `school_policy`, or `unknown`. |
| `professional_context` | `not_regulated`, `regulated_possible`, `regulated_confirmed`, `license_or_certification_required`, `professional_boundary_required`, or `unknown`. |
| `deadline_sensitivity` | `none`, `soft`, `hard`, `eligibility_deadline`, `legal_deadline`, `financial_deadline`, `health_or_safety_window`, or `unknown`. |
| `source_authority_requirement` | source authority class and freshness cadence required before current use; high-risk and jurisdiction-sensitive material needs current eligible source or review/blocked routing. |
| `private_data_sensitivity` | public-source-only, local-only private, redacted-only, forbidden-publication, or unknown. |
| `goal_intent_geometry_risk_overlay` | risk and jurisdiction modifiers for time horizon, deadline pressure, dependency pattern, proof requirement, capacity shape, location/resource constraints, and reflow impact. |
| `step_physics_safety_overlay` | classification modifiers for minimum useful Step size, stretch shape, recovery-safe variant, blocked-state condition, duration range, energy profile, and proof/recovery expectations. |

`unknown` is a blocking value for current recommendation or release eligibility unless a future active issue explicitly defines a safe degraded mode and proves it.

## Output Contract

Authoring and validation must produce these outputs before downstream gates:

- pack-level risk class and jurisdiction envelope
- seed-level risk class and applicability envelope
- claim-level risk class, source authority requirement, freshness cadence, jurisdiction envelope, and private-data sensitivity
- requirement-level `SourceAtlasRequirementRiskState`, `SourceAtlasRequirementReviewState`, source state, and freshness state
- reviewer decision id, reviewer state, and reason when review is required
- guarded routing reason for high-risk, unknown, professional-boundary, jurisdiction-needed, source-needed, stale-critical, contradicted, revoked, or private-data states
- downstream gate ids that consumed the classification
- release-receipt reference only when later release tooling proves the pack can leave validation
- Goal Intent Geometry risk overlay and Step physics safety overlay before later seed-generation or Step Quality gates consume classification

Classification is not optional for high-risk or jurisdiction-sensitive material. Missing classification routes to review-needed or blocked.

## Moat Maturity Alignment

AMB-682 contributes the jurisdiction-overlay and risk-classification portion of the current Source Atlas moat maturity pass.

It preserves these parent-level M05 requirements without implementing them:

- compiler-grade Source Atlas substrate must preserve risk, jurisdiction, source-needed, proof, recovery, contradiction, and revocation signals as structured metadata
- Goal Intent Geometry in seeds must include risk class, jurisdiction need, proof requirement, capacity shape, dependency pressure, and reflow impact when those fields affect safe use
- Step physics metadata must preserve blocked-state conditions, recovery-safe variants, minimum useful Step size, and proof/review expectations for downstream Step Quality gates
- user-local personalization slots remain local and cannot become public Source Atlas/R2 classification truth
- computed runtime eligibility remains blocked until source binding, freshness, revocation, review/risk/jurisdiction, release receipt, rollback, and Step Quality gates all pass in future owning issues

AMB-682 does not activate R2 staging, upload canaries, compute runtime eligibility, or make packs runtime-consumable. AMB-973 owns live Cloudflare R2 staging activation for M05; AMB-617 / PLOS-M10 owns runtime consumption; AMB-635 / PLOS-M26 owns production certification.

## Risk Rules

| Risk class | Required route |
|---|---|
| `low_risk_skill`, `hobby`, `sport_rules`, `career_context` | May proceed only if source/freshness/duplicate/contradiction/private-data gates also pass. |
| `education_eligibility`, `certification_eligibility` | Strict review; current source and jurisdiction/institution/program scope required. |
| `legal_civic`, `financial`, `health_medical` | Strict review; not professional advice; jurisdiction and source authority required before current use. |
| `crisis_safety` | Block ordinary productivity routing; future high-risk owner must define safe crisis handling. |
| `minor_student_data` | Strict review, local/private boundary, and school/minor context required; no public Source Atlas publication of private student data. |
| `professional_boundary` | Professional-boundary mode required; no authoritative professional instruction without future proof. |
| `deadline_sensitive` | Current source, deadline source, and explicit stale-critical behavior required. |
| `sensitive_private` | Local-only or redacted-only routing; never public R2/source-pack truth. |
| `unknown` | Review-needed or blocked; cannot drive current recommendation. |

Existing `SourceAtlasRiskClass.requiresStrictReview` is the current Swift source anchor for high-risk review defaults. Existing `SourceAtlasRequirementRiskState.blocksCurrentProjection` blocks `high` and `unknown` from current projection.

## Jurisdiction Rules

Jurisdiction classification must be explicit when rules, eligibility, deadlines, costs, permissions, safety posture, or required sources vary by:

- country, region, state/province, city/local authority, or travel context
- school, institution, program, employer, certifier, licensing body, league, platform, or marketplace
- age/minor/student status
- legal, civic, financial, health, certification, or professional scope
- source publication date, effective date, revoked date, or deadline

Unknown jurisdiction routes to `jurisdiction_needed`, review-needed, or blocked. It must not silently default to the user's current location, a US-only assumption, a global claim, or a generic productivity Step.

## Downstream Gate Behavior

Downstream gates must fail closed when:

- a source-backed high-risk claim has `reviewRequired == false`
- risk is `high` or `unknown`
- review is `required`, `requested`, or `blocked`
- jurisdiction is unknown where jurisdiction affects applicability
- source is stale, contradicted, revoked, source-needed, unsupported, or unknown
- source freshness is stale or unknown
- private/local user material is required to validate a public Source Atlas claim
- a duplicate merge or freshness scan would erase risk or jurisdiction differences

Existing `SourceAtlasRequirement.canDriveCurrentRecommendation` already requires current official/current source, current freshness, approved review, and non-high/non-unknown risk. AMB-682 preserves that behavior as source evidence and does not claim runtime enforcement beyond what source already contains.

## Failure Handling

Use review-needed, jurisdiction-needed, source-needed, professional-boundary, blocked, stale-critical, contradicted, revoked, quarantine, or local-only routing when:

- risk class cannot be determined
- jurisdiction envelope cannot be determined
- source authority is insufficient for the risk class
- source freshness is stale or unknown for high-risk or deadline-sensitive content
- claims conflict across jurisdictions or institutions
- reviewer decision is missing, expired, contradicted, or revoked
- a pack attempts to publish sensitive private, minor/student, or local proof material
- downstream release/runtime gates cannot consume classification output

Prefer blocked/review-needed over false safe classification.

## Existing Source Anchors

AMB-682 inspected these anchors:

- `SourceAtlasRiskClass` includes low-risk, education, certification, legal/civic, financial, health/medical, crisis/safety, minor/student, professional-boundary, deadline-sensitive, and sensitive-private classes.
- `SourceAtlasRiskClass.requiresStrictReview` requires strict review for education, certification, legal/civic, financial, health/medical, crisis/safety, minor/student, professional-boundary, deadline-sensitive, and sensitive-private classes.
- `SourceAtlasValidationIssue.highRiskClaimWithoutReview` records invalid high-risk claims that lack review.
- `SourceAtlasRequirementRiskState.blocksCurrentProjection` blocks high or unknown risk from current projection.
- `SourceAtlasRequirementReviewState.blocksCurrentProjection` blocks required, requested, and blocked review states.
- `SourceAtlasRequirement.canDriveCurrentRecommendation` requires approved review, current source, current freshness, and non-high/non-unknown risk.
- `docs/codex/HIGH_RISK_DOMAIN_SAFETY_LAW.md` requires risk classification, jurisdiction applicability, source authority, professional-boundary or blocked modes, share redaction, and receipt/failure states.
- AMB-679 defines source hash binding, AMB-680 defines duplicate preservation, and AMB-681 defines contradiction/freshness failure routing.

These anchors are source/control-plane evidence only. AMB-682 does not claim classifier implementation, jurisdiction runtime logic, or guarded runtime mode exists.

## Scaling Hotspots

Future implementation should bound:

- jurisdiction matrix growth across regions, institutions, programs, and source authorities
- review queue growth for high-risk and unknown classifications
- cross-pack recomputation when source risk or jurisdiction changes
- high-risk freshness cadence churn
- duplicate/contradiction interactions that preserve jurisdiction and risk differences
- local/private sensitivity checks before public-source publication
- reviewer decision retention and revocation lookup cost

No measured performance, storage, network, CPU, or battery proof is claimed by AMB-682.

## Non-Claims

This artifact does not implement risk classifiers, jurisdiction resolvers, guarded runtime mode, runtime safety enforcement, schema migration, validators, release tooling, pack publication, Cloudflare/R2 setup, credential creation, live R2 writes, runtime fetch/cache/quarantine, runtime eligibility, runtime pack consumption, privacy/legal approval, legal/medical/financial advice, release readiness, device proof, accessibility proof, security certification, or measured performance proof.
