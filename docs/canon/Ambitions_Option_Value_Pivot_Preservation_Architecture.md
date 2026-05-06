# Ambitions Option Value Pivot Preservation Architecture
<!-- markdownlint-disable MD013 -->

Status: HPS07 source truth / docs-domain architecture. No production Swift implementation.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade

## Purpose

Option Value and Pivot Preservation define how Ambitions should preserve the
meaning, proof, sources, requirements, and user dignity of prior work when a
goal, dream, path, role, or life direction changes.

The system should help the user answer:

> What does this still count toward?

HPS07 is architecture only. It does not implement option-value runtime, path
mutation, recommendation ranking, persistence, schema, sync, cloud, AI runtime,
Goals UI, Plan UI, LDI runtime, export, or external handoff behavior.

## Product Boundary

Option Value must remain:

- user-owned
- source-bound
- proof-aware
- requirement-aware
- privacy-aware
- reversible
- non-shaming
- uncertainty-labeled
- reviewable before mutation

Option Value must not become:

- proof inflation
- hidden goal mutation
- career or education certainty
- professional advice
- eligibility or outcome guarantee
- public credential behavior
- engagement pressure
- a sixth tab
- a broad alternate-path command surface

## Option Value Object Families

| Object family | Purpose | Default posture |
|---|---|---|
| `OptionValueEntry` | A record that prior work may support a current, adjacent, parked, or future path. | Reviewable and private. |
| `PathTransfer` | A proposed transfer from source path to target path. | Requires proof/source/requirement overlap. |
| `TransferProofLink` | Proof that may support the transfer. | HPS03 proof states inherited. |
| `RequirementOverlap` | Shared, adjacent, missing, stale, conflicting, or unknown requirement relationship. | Source-needed unless reviewed. |
| `AdjacentPathSignal` | Evidence that another path may preserve value. | Not a recommendation until HPS06 gates pass. |
| `NorthStarContinuity` | The stable meaning, identity, or direction preserved across changed paths. | User-reviewed and non-deterministic. |
| `ParkedDream` | A dream or direction saved without current execution pressure. | Dignified and revivable. |
| `RevivalPrompt` | A future review prompt for parked or paused work. | User-controlled. |
| `StillCountsReceipt` | A receipt that records what counted, what changed, and what remains uncertain. | Private proof until shared/exported by user. |
| `PivotReviewReceipt` | A receipt that records accepted, rejected, deferred, or corrected transfer decisions. | No silent mutation. |

## Option Value Fields

Every option-value object that may affect Goals, Plan, Today, You, AOS, LDI,
recommendations, proof, source review, or export must carry:

- `id`
- `sourcePathId`
- `targetPathId`
- `optionValueFamily`
- `transferState`
- `requirementOverlapState`
- `proofTransferState`
- `sourceState`
- `freshnessState`
- `uncertaintyState`
- `privacyClass`
- `riskBoundary`
- `northStarContinuity`
- `userReviewState`
- `mutationPermissionState`
- `receipts`
- `correctionPath`

## Transfer States

Option value uses qualitative states. It must not become a score, rank,
percentage, or promise of acceptance.

- `directlyReusable`
- `partiallyReusable`
- `supportsNarrative`
- `inspirationOnly`
- `needsSourceReview`
- `needsMoreProof`
- `needsRequirementReview`
- `stale`
- `conflicting`
- `notTransferable`
- `unknown`

No transfer state may claim official eligibility, admissions likelihood,
employment outcome, licensing satisfaction, financial result, legal outcome,
medical suitability, or professional acceptance.

## Requirement And Proof Overlap

A transfer may be considered only when Ambitions can show:

- source path
- target path
- overlapping requirement or missing requirement
- proof objects involved
- source and freshness state
- uncertainty state
- privacy impact
- user review state
- safer fallback if transfer is not valid

Allowed overlap states:

- `sameRequirement`
- `adjacentRequirement`
- `supportingSkill`
- `supportingProof`
- `narrativeOnly`
- `sourceNeeded`
- `freshnessNeeded`
- `humanReviewNeeded`
- `conflicting`
- `notApplicable`
- `unknown`

Prior proof transfers only when requirement, source, and evidence overlap
support the transfer. Ambitions must preserve unsupported or uncertain value as
reviewable context, not as a claim.

## Path Transfer Matrix

The path transfer matrix compares a source path and target path without
changing either path automatically.

Required rows:

- shared requirements
- missing requirements
- stale requirements
- conflicting requirements
- reusable proof
- partial proof
- narrative support
- privacy risk
- capacity/time fit
- professional-boundary risk
- user decision needed

Required outputs:

- transfer summary
- unsupported-claim notes
- source-review needs
- proof-review needs
- privacy-review needs
- next safest review action
- receipt to write if accepted
- rejected unsafe transfers

## Adjacent Path Detection

Adjacent path detection may suggest reviewable possibilities only when:

- source path and target path are named
- shared proof or requirement overlap is visible
- uncertainty and missing sources are labeled
- privacy class allows the target surface
- the suggestion remains optional
- no professional or regulated-path certainty is implied

Adjacent path detection must degrade to source review, proof review, or user
reflection when evidence is weak.

## North Star Continuity

North Star continuity preserves meaning across a pivot without declaring the
new path correct.

It may record:

- user-stated direction
- repeated themes
- identity or values language
- proof that supports the direction
- paths that still fit
- paths that no longer fit
- review questions

It must not infer identity as fact, force continuity, shame changed direction,
or imply that any path is the user's destined path.

## Dream Parking And Revival

Parking a dream means preserving option value without current execution
pressure.

Dream parking must support:

- why it is parked
- what still counts
- proof and sources preserved
- review date or ask-later state
- privacy class
- revival trigger
- user correction or deletion

Revival prompts must be gentle, optional, and source/proof aware. They must not
reopen a rejected, unsafe, private, stale, or overloaded path without review.

## Still Counts Receipts

A Still Counts receipt records real progress when the planned action changed,
shrank, moved, paused, or became a different kind of proof.

Minimum receipt fields:

- what happened
- what changed
- what still counts
- linked proof
- linked requirement or path
- source/freshness state
- transfer state
- privacy class
- user confirmation
- next review action

Still Counts must not fake completion. It preserves evidence, dignity, and
future usefulness.

## Mutation Permission

Option Value may propose changes, but it must not silently mutate:

- goals
- paths
- commitments
- plans
- proof mappings
- requirement states
- source claims
- privacy state
- external exports

Allowed mutation states:

- `reviewOnly`
- `userApproved`
- `userRejected`
- `deferred`
- `needsSourceReview`
- `needsProofReview`
- `needsHumanReview`
- `blockedByPrivacy`
- `blockedByConflict`

## API Contract Families

These are architecture contracts, not implemented Swift APIs in HPS07.

### Option Value Read API

Purpose: load reviewable option-value context for a goal, path, dream,
proof object, source, or user review surface.

Required output:

- option-value entries
- source and target paths
- transfer states
- proof links
- requirement overlap
- privacy labels
- uncertainty labels
- correction paths

### Path Transfer Proposal API

Purpose: propose a proof, requirement, or path transfer without applying it.

Required output:

- source path
- target path
- proposed transfer state
- proof and requirement evidence
- missing source/proof notes
- privacy impact
- mutation permission needed
- rejected unsafe transfers

### North Star Continuity API

Purpose: preserve user-reviewed meaning across path changes.

Required output:

- continuity summary
- user-stated direction
- proof/source support
- uncertainty notes
- review questions
- paths preserved, parked, or rejected

### Pivot Receipt API

Purpose: write receipts after the user confirms, rejects, parks, revives, or
corrects an option-value decision.

Required output:

- receipt id
- affected paths and proof
- decision state
- what still counts
- what does not yet count
- privacy/correction state
- next review action

## Surface Projection

Projection rules:

- Today may receive only one small review or Still Counts prompt when it helps
  the current day.
- Goals may show path transfer, proof overlap, and review states inside the
  owning goal path.
- Capture may route a possible pivot as a placed fragment, not as an automatic
  new goal.
- Plan may show capacity and timing implications without calendar certainty or
  hidden rescheduling.
- You may show privacy, correction, export, deletion, and review controls.
- LDI may use this contract to preserve meaning without validating unsafe or
  impossible literal plans.
- External surfaces receive redacted summaries only.

## Regression Oracle

Future option-value implementation must be tested against:

- career pivot where prior proof partly transfers
- education path where source requirements are stale
- dream parked without shame
- dream revived after capacity improves
- hobby becomes professional path with source review needed
- professional path becomes personal path with dignity preserved
- conflicting requirement blocks transfer
- private proof cannot be projected externally
- user rejects a transfer and it stays rejected
- Still Counts proof is saved without fake completion
- North Star continuity is user-reviewed, not inferred as fact
- no available adjacent path produces a gentle no-known-option state

## No-Claim Boundary

This document does not implement option-value runtime, path mutation,
recommendation behavior, LDI runtime, AOS runtime, model behavior,
personalization, persistence, schema, sync, cloud, analytics, UI, external
projection behavior, export behavior, professional advice, legal/privacy
compliance, App Store readiness, TestFlight readiness, release readiness,
physical-device behavior, public accessibility conformance, or acquisition
outcome.
