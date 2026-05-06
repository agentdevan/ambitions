# Ambitions Human Progress Graph API Architecture
<!-- markdownlint-disable MD013 -->

Status: HPS02 source truth / docs-domain architecture. No production Swift implementation.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade

## Purpose

The Human Progress Graph is the internal substrate that connects the user's
life threads, commitments, goals, requirements, proof, sources, time, pivots,
identity, open loops, and privacy states.

It is not a visible graph surface by default. It exists so Today, Goals,
Capture, Plan, You, AOS, LDI, Source Atlas, and future proof/source systems can
share stable meaning without widening the app.

## Product Boundary

The graph must preserve the locked top-level app:

- Today
- Goals
- Capture
- Plan
- You

The graph must not create:

- a sixth tab
- an all-life control surface
- a quantified-self score
- a social graph
- a school/workforce product
- a public credential network
- a hosted user-data service
- a source-certification authority

## Core Node Families

| Node family | Purpose | Default privacy posture |
|---|---|---|
| `LifeThread` | A durable life area, role, relationship, direction, or context. | Private by default. |
| `Commitment` | A promise, obligation, recurring responsibility, or planned action. | Private unless explicitly externalized. |
| `OpenLoop` | Unresolved capture, waiting item, parked idea, or unfinished concern. | Private and reviewable. |
| `GoalPath` | A goal, path, milestone, alternate path, or one-step goal. | Private with proof/source folds. |
| `Requirement` | A source-bound requirement, prerequisite, deadline, rule, or constraint. | Source-labeled; never official without source proof. |
| `Proof` | User-owned evidence that something happened or supports a requirement. | User-controlled and export-aware. |
| `SourceClaim` | A claim from Source Atlas, user source, local record, or inference. | Freshness and claim-state required. |
| `TimeCapacity` | Available capacity, protected time, pressure, energy, or schedule fit. | Private; external projection redacted. |
| `Pivot` | A change in direction, route, priority, or strategy. | Reviewable with option-value receipt. |
| `IdentityDirection` | User-stated values, direction, preferences, and self-knowledge. | Sensitive by default. |
| `PrivacyPermission` | Consent, hide, remember, reject, forget, correct, and source visibility state. | Explicit and revocable. |
| `Receipt` | A reviewable record of closure, mutation, recovery, proof, or refusal. | Private unless user exports. |

## Core Edge Families

| Edge family | Meaning |
|---|---|
| `supports` | One node helps another become more plausible or actionable. |
| `proves` | Proof supports a requirement, goal, closure, or source claim. |
| `dependsOn` | A path, action, or recommendation depends on another node. |
| `conflictsWith` | Two commitments, requirements, or constraints cannot both hold cleanly. |
| `supersedes` | A newer source, commitment, plan, or decision replaces an older one. |
| `transfersTo` | Proof, option value, or prior work transfers to a new path. |
| `blockedBy` | A path or action is blocked by a requirement, source issue, or capacity fact. |
| `sourcedFrom` | A node or edge is grounded in a source, receipt, or user statement. |
| `verifiedBy` | A proof or claim has explicit supporting evidence. |
| `hiddenFrom` | A node is intentionally hidden from a surface or external projection. |
| `scheduledWithin` | A commitment or step fits inside a time/capacity window. |
| `stillCountsToward` | Work still contributes after a pivot, pause, or route change. |

## Required State Fields

Every graph node and edge that can affect a recommendation, proof, path, or
external projection must carry these fields or an explicit reason they are not
applicable:

- `id`
- `family`
- `title`
- `privacyClass`
- `sourceState`
- `freshnessState`
- `reviewState`
- `createdAt`
- `updatedAt`
- `receipts`

## Privacy Classes

- `private`: visible only inside the app by default.
- `sensitive`: collapsed or hidden unless the user opens the detail.
- `externalRedacted`: safe summary only for widgets, notifications, App
  Intents, Live Activities, exports, or handoffs.
- `shareableByUser`: user-approved export or external handoff.
- `deletePending`: hidden from recommendation and projection until resolved.

## Source States

- `userStated`
- `userConfirmed`
- `sourceBacked`
- `sourceNeeded`
- `inferredReviewRequired`
- `importedReviewRequired`
- `unsupported`
- `disputed`
- `revoked`
- `unknown`

No source state may be promoted to official/current without Source Atlas or an
equivalent source-proof path.

## Freshness States

- `current`
- `reviewSoon`
- `stale`
- `staleCritical`
- `sourceChanged`
- `notApplicable`
- `unknown`

High-risk `staleCritical` requirements must not drive current-path or Start
Here behavior without a source-needed fallback.

## Review States

- `ready`
- `needsUserReview`
- `needsSourceReview`
- `needsPrivacyReview`
- `needsCorrection`
- `hiddenByUser`
- `rejectedByUser`
- `deletedByUser`

## API Contract Families

These are architecture contracts, not implemented Swift APIs in HPS02.

### Graph Read API

Purpose: load graph slices for a bounded surface.

Required inputs:

- surface owner
- requested node families
- privacy scope
- source/freshness policy
- time window where relevant

Required output:

- nodes
- edges
- privacy redactions
- source/freshness warnings
- receipt references
- unsupported-claim notes

### Graph Mutation Proposal API

Purpose: produce a reviewable proposed graph change.

Required inputs:

- proposed nodes/edges
- source evidence
- privacy impact
- affected commitments
- rollback path

Required output:

- proposal summary
- changed nodes/edges
- required user confirmation
- receipts to write if accepted
- rejected unsafe changes

Silent graph mutation is forbidden.

### Graph Receipt API

Purpose: attach proof, closure, review, correction, rejection, or rollback
receipts to graph facts.

Required output:

- receipt id
- affected nodes/edges
- source/proof link
- privacy class
- changed fact summary
- rollback or correction path

### Graph Projection API

Purpose: provide surface-safe projections for Today, Goals, Capture, Plan, You,
and external surfaces.

Projection rules:

- Today receives only the current decision slice and source/freshness warnings.
- Goals receives path/proof/option-value slices.
- Capture receives placement/open-loop/source-review slices.
- Plan receives time/capacity/reflow slices.
- You receives privacy, memory, proof, source, correction, and export controls.
- External surfaces receive redacted summaries only.

## AOS Inheritance

AOS02 and later graph work must inherit this architecture. AOS may implement
typed models and services later, but HPS02 does not claim runtime behavior,
persistence, migration, on-device intelligence, source packs, or model logic.

## Source Atlas Inheritance

Any graph node or edge based on real-world requirements, source packs, URLs,
PDFs, images, copied text, OCR, or official/current source claims must use
Source Atlas source/freshness/claim states or fall back to `sourceNeeded`.

## No-Claim Boundary

This document does not implement the graph, certify source truth, create a
database schema, add sync/cloud/account behavior, add hosted AI, prove release
readiness, prove App Store readiness, prove physical-device behavior, or claim
public accessibility conformance.
