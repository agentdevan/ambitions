# Ambitions Commitment Memory Searchable Life Recall Architecture
<!-- markdownlint-disable MD013 -->

Status: HPS05 source truth / docs-domain architecture. No production Swift implementation.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade

## Purpose

Commitment Memory and Searchable Life Recall define how Ambitions should help
the user remember promises, obligations, errands, birthdays, follow-ups,
parked projects, abandoned loops, identity direction, and sensitive life
context without becoming a monitoring system, diary-style product, broad
lookup database, or hidden memory engine.

The product stance is:

> The app should hold the user's life safely underneath the system and show only
> what matters now.

HPS05 is architecture only. It does not implement durable memory storage, a
search index, embeddings, model memory, sync, account, cloud, background
indexing, notification recall, or UI.

## Product Boundary

Memory and recall must remain private, reviewable, correctable, and quiet.

They must not become:

- a life database surface
- a diary product
- a notes product
- an activity feed
- hidden personalization
- passive monitoring
- family/admin software
- school or workforce tracking
- a conversational memory wrapper
- a quantified-self system
- a hosted user-data service

## Memory Object Families

| Object family | Purpose | Default posture |
|---|---|---|
| `ConfirmedCommitmentMemory` | User-confirmed promise, responsibility, follow-up, recurring obligation, or waiting item. | Private and actionable. |
| `InferredCommitmentCandidate` | Possible commitment detected from capture, proof, source, or context. | Needs review; never fact. |
| `OpenLoopMemory` | Parked idea, unresolved capture, unanswered question, or unfinished concern. | Private and reviewable. |
| `RelationshipMemory` | User-confirmed people/context detail that affects promises or care. | Sensitive by default. |
| `IdentityDirectionMemory` | User-stated values, preferences, ambitions, and direction. | Sensitive and correctable. |
| `SourceBackedMemory` | Memory grounded in Source Atlas, proof, import, or user-provided source. | Source/freshness labeled. |
| `RecallQueryReceipt` | Record that a recall was shown, hidden, corrected, rejected, or deleted. | Private by default. |
| `ForgetCorrectionReceipt` | Record of user hide, forget, correct, reject, restore, or delete choice. | User-control first. |

## Memory State Fields

Every memory that may affect a recommendation, recall result, external
projection, or export must carry:

- `id`
- `memoryFamily`
- `title`
- `summary`
- `privacyClass`
- `confirmationState`
- `sourceState`
- `freshnessState`
- `reviewState`
- `recallPermissionState`
- `sensitivityState`
- `createdAt`
- `updatedAt`
- `lastReviewedAt`
- `linkedGraphNodes`
- `receipts`
- `correctionPath`
- `deletionPath`

## Confirmation States

- `userConfirmed`
- `userStated`
- `sourceBacked`
- `inferredNeedsReview`
- `importedNeedsReview`
- `suggestedNeedsReview`
- `rejectedByUser`
- `hiddenByUser`
- `forgottenByUser`
- `deletedByUser`
- `unknown`

Inferred, imported, and suggested memories must not drive recommendations as
facts until reviewed.

## Recall Permission States

- `availableForNow`
- `availableForReviewOnly`
- `hiddenFromToday`
- `hiddenFromExternalSurfaces`
- `askBeforeUsing`
- `doNotUseForRecommendations`
- `forgetRequested`
- `deletePending`
- `deleted`

Sensitive recall defaults to review-only until the user confirms otherwise.

## Sensitivity States

- `ordinary`
- `relationshipSensitive`
- `healthSensitive`
- `financialSensitive`
- `legalSensitive`
- `educationSensitive`
- `careerSensitive`
- `minorOrStudentSensitive`
- `locationSensitive`
- `identitySensitive`
- `thirdPartySensitive`
- `unknownSensitive`

Sensitive memories must collapse or hide by default on external surfaces and in
summary projections.

## Searchable Recall Contract

Searchable recall is not a general database view. It is a bounded retrieval
contract that answers specific user or system questions with source, freshness,
privacy, and review context.

Allowed recall intents:

- remind me what I promised
- find the proof/source for this path
- show what is still open
- show what changed
- show what still counts
- show why this recommendation appeared
- show what Ambitions remembers and how to correct it

Forbidden recall behavior:

- browsing all life memory by default
- exposing sensitive recall externally
- silently using inferred memories as facts
- ranking the user's life
- surfacing private memories as engagement hooks
- using recall to pressure or shame the user

## API Contract Families

These are architecture contracts, not implemented Swift APIs in HPS05.

### Memory Read API

Purpose: load bounded memory slices for Today, Goals, Capture, Plan, You, AOS,
LDI, or Source Atlas review.

Required output:

- memory summaries
- confirmation labels
- source/freshness labels
- privacy redactions
- correction/deletion paths
- unsupported or inferred notes

### Memory Proposal API

Purpose: propose a new memory, correction, rejection, hide, forget, restore, or
deletion.

Required output:

- proposed memory or change summary
- source/proof links
- privacy impact
- affected recommendations or commitments
- user confirmation requirement
- receipts to write if accepted

Silent memory creation, promotion, recall, or externalization is forbidden.

### Recall Query API

Purpose: answer a bounded recall question without exposing more life context
than needed.

Required output:

- query intent
- matched memories
- redactions
- source/freshness/review labels
- confidence-free uncertainty note
- correction/deletion controls
- no-result or source-needed fallback

### Memory Projection API

Purpose: project memory safely into product surfaces.

Projection rules:

- Today receives only currently relevant confirmed/reviewable memory.
- Goals receives path/proof/source/option-value memory.
- Capture receives open-loop and placement-review memory.
- Plan receives commitment/time-fit memory without hidden rescheduling.
- You receives full review, correction, export, hide, forget, and delete
  controls.
- External surfaces receive redacted summaries only.

## Privacy And Deletion Boundary

Memory must be user-owned. Every sensitive memory needs a visible path to
correct, reject, hide, forget, or delete. Delete-pending memory must not drive
recommendations, external projections, or future recall.

HPS05 does not implement deletion/export behavior. It defines the minimum
architecture later implementation must preserve.

## AOS And LDI Inheritance

AOS05, AOS10, AOS17, AOS20, AOS22, LDI10, LDI13, LDI15, Found Life, and You
trust surfaces must inherit this memory and recall architecture when they touch
commitments, open loops, personalization, dream context, or sensitive life
memory.

## No-Claim Boundary

This document does not implement durable memory, search, embeddings, AI memory,
sync, cloud, account behavior, background indexing, external recall, export,
delete, professional advice, legal/privacy compliance, App Store readiness,
TestFlight readiness, release readiness, physical-device behavior, or public
accessibility conformance.
