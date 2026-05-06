# Ambitions Source Truth Requirement Graph Architecture
<!-- markdownlint-disable MD013 -->

Status: HPS04 source truth / docs-domain architecture. No production Swift implementation.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade

## Purpose

The Source Truth and Requirement Graph architecture defines how Ambitions should
represent source-backed requirements, eligibility conditions, deadlines, rules,
constraints, conflicts, uncertainty, and review paths without becoming an
official requirement database or professional advisor.

HPS04 exists so Goals, LDI, AOS, Source Atlas, proof, recommendations, and
external handoffs can reason about requirements with source/freshness/claim
truth instead of vibes.

HPS04 is architecture only. It does not implement source packs, scraping, OCR,
PDF or URL import, source downloads, source refresh, claim extraction,
requirement runtime, database schema, sync, account, hosted service, AI
runtime, or UI.

## Product Boundary

The requirement graph must remain an internal trust substrate for:

- Goal Path requirements
- Living Dream requirement discovery
- Source Atlas source/freshness inheritance
- Start Here source warnings
- proof-to-requirement mapping
- option value and path transfer
- You trust, correction, export, and source review

The requirement graph must not become:

- an official career, education, medical, legal, financial, licensing, or
  compliance authority
- a school or workforce product
- a source marketplace
- a public recommendation engine
- a professional advice product
- a hosted source database
- an external API product
- a certainty machine for eligibility or outcomes

## Requirement Object Families

| Object family | Purpose | Default posture |
|---|---|---|
| `Requirement` | A prerequisite, rule, eligibility condition, document need, deadline, constraint, or proof need. | Source-needed unless confirmed. |
| `RequirementSet` | A grouped set of requirements for a goal, path, dream, institution, program, role, or process. | Reviewable and source-labeled. |
| `SourceClaim` | A statement from Source Atlas, user source, copied source, document, or inference. | Claim-state and freshness required. |
| `JurisdictionBoundary` | Geography, institution, program, employer, age, role, time, or policy scope. | Never assumed globally valid. |
| `ConflictClaim` | A conflict between sources, dates, requirements, or proof interpretations. | Needs review. |
| `FreshnessSignal` | Evidence that a source or requirement may be current, stale, changed, unknown, or superseded. | Reviewable. |
| `RequirementProofNeed` | Proof expected to support or satisfy a requirement. | Mapped to HPS03 proof states. |
| `RequirementReviewReceipt` | Record of user review, source review, correction, rejection, or rollback. | Private by default. |

## Requirement State Fields

Every requirement that may affect a path, recommendation, proof mapping,
external projection, or export must carry:

- `id`
- `requirementFamily`
- `title`
- `scope`
- `sourceClaimIds`
- `jurisdictionBoundary`
- `claimState`
- `sourceQualityState`
- `freshnessState`
- `uncertaintyState`
- `reviewState`
- `proofNeedState`
- `privacyClass`
- `createdAt`
- `updatedAt`
- `receipts`
- `correctionPath`

## Claim States

- `officialSourceBacked`
- `semiOfficialSourceBacked`
- `expertSourceBacked`
- `communitySourceBacked`
- `userConfirmed`
- `userStated`
- `importedNeedsReview`
- `inferredNeedsReview`
- `sourceNeeded`
- `stale`
- `changed`
- `conflicting`
- `disputed`
- `unsupported`
- `revoked`
- `unknown`

No requirement may be treated as official, current, satisfied, or safe to act
on without source/freshness evidence and any required user or human review.

## Source Quality States

- `official`
- `institutional`
- `government`
- `professionalBody`
- `primaryDocument`
- `secondaryReference`
- `expertInterpretation`
- `community`
- `userProvided`
- `modelInferred`
- `unknown`

`modelInferred`, `community`, `secondaryReference`, and `unknown` states cannot
promote a requirement to official without a stronger source path.

## Freshness And Uncertainty

Freshness states inherit from HPS02:

- `current`
- `reviewSoon`
- `stale`
- `staleCritical`
- `sourceChanged`
- `notApplicable`
- `unknown`

Uncertainty states:

- `low`
- `medium`
- `high`
- `conflictingSources`
- `scopeAmbiguous`
- `deadlineAmbiguous`
- `eligibilityAmbiguous`
- `requiresHumanReview`
- `unknown`

High uncertainty must degrade recommendations into source-review or
human-review paths rather than confident action.

## Requirement Edge Families

| Edge family | Meaning |
|---|---|
| `requiresProof` | A requirement needs proof before it can be treated as supported. |
| `dependsOnRequirement` | A requirement depends on another requirement. |
| `blocksPath` | A requirement blocks a path until reviewed or satisfied. |
| `unlocksPath` | A reviewed requirement can open or clarify a path. |
| `supersedesRequirement` | A newer source replaces an older requirement. |
| `conflictsWithRequirement` | Two requirements cannot both hold cleanly. |
| `appliesWithin` | A requirement applies only inside a jurisdiction, institution, role, or time window. |
| `sourcedFrom` | A requirement or edge is grounded in a source claim. |
| `supportedByProof` | Proof supports a requirement under HPS03 proof states. |
| `needsReviewBeforeAction` | A requirement must not drive current action without review. |

## Source Conflict Behavior

When sources conflict, Ambitions must:

- preserve both claims
- label the conflict
- keep source/freshness details visible in review surfaces
- avoid choosing a winner silently
- block official/current/satisfied claims
- propose a source-review or human-review next step
- write a review receipt if the user corrects, rejects, or resolves the claim

## Recommendation Boundary

Recommendations may use requirement graph facts only when:

- source state is acceptable for the risk level
- freshness is current or explicitly reviewed
- uncertainty is low enough for the suggestion
- privacy rules permit projection
- proof needs are clear
- the fallback path is safe

If those conditions fail, the recommendation must become a source-review,
human-review, or proof-needed step rather than a confident action.

## API Contract Families

These are architecture contracts, not implemented Swift APIs in HPS04.

### Requirement Read API

Purpose: load scoped requirements for a goal, dream, path, proof, source, or
surface.

Required output:

- requirement summaries
- source claims
- freshness and uncertainty labels
- proof needs
- conflicts
- review requirements
- unsupported-claim notes

### Requirement Proposal API

Purpose: propose a new requirement, source claim, conflict, correction, or
supersession.

Required output:

- proposed requirement summary
- source evidence
- uncertainty and jurisdiction scope
- affected paths/proof
- user/human review required
- receipts to write if accepted
- rejected unsafe changes

Silent requirement creation, promotion, supersession, or officialization is
forbidden.

### Requirement Conflict API

Purpose: classify source, freshness, deadline, jurisdiction, proof, or
eligibility conflicts.

Required output:

- conflict type
- affected requirements
- affected paths/proof
- source comparison
- safest fallback
- review owner

### Requirement Projection API

Purpose: expose safe requirement summaries to Today, Goals, Capture, Plan, You,
AOS, LDI, and external surfaces.

Projection rules:

- Today receives only source-review or proof-needed next-step summaries.
- Goals receives path requirement, proof need, conflict, and option-value
  summaries.
- Capture receives source-needed and placement-review summaries.
- Plan receives deadline/capacity constraints without calendar certainty.
- You receives source, correction, privacy, export, and review controls.
- External surfaces receive redacted, non-sensitive, non-official summaries.

## Source Atlas Inheritance

Any real-world requirement based on source packs, URLs, PDFs, images, copied
text, OCR, documents, rules, deadlines, or official/current source claims must
inherit Source Atlas source/freshness/claim states or fall back to
`sourceNeeded`.

## No-Claim Boundary

This document does not implement source truth runtime, Source Atlas ingestion,
requirement extraction, source freshness checks, requirement storage, official
requirement validation, professional advice, legal/privacy compliance, App
Store readiness, TestFlight readiness, release readiness, physical-device
behavior, or public accessibility conformance.
