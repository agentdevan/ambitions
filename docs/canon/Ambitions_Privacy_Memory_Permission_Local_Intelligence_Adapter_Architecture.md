# Ambitions Privacy Memory Permission Local Intelligence Adapter Architecture
<!-- markdownlint-disable MD013 -->

Status: HPS09 source truth / docs-privacy intelligence architecture. No production Swift implementation.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade

## Purpose

Privacy / Memory Permission and the Local Intelligence Adapter define how
Ambitions should protect sensitive life context before any future local
extraction, classification, source review, recommendation, memory recall, LDI,
or AOS behavior uses deeper context.

The architecture answers:

> What may Ambitions remember, infer, classify, project, ask, or mutate, and
> what must stay private, hidden, local-only, or review-bound?

HPS09 is architecture only. It does not implement memory permission runtime,
local model runtime, extraction, classification, tool calling, persistence,
schema, sync, cloud, analytics, UI, external-surface behavior, or model
invocation.

## Product Boundary

Privacy and local intelligence must remain:

- local-first in posture
- deterministic-first
- permission-aware
- sensitive-area aware
- source/freshness labeled
- user-reviewable
- correctable and rejectable
- external-surface redacted
- performance/battery bounded
- safe without model availability

They must not become:

- hidden memory creation
- hidden tool calling
- hidden mutation
- model-required core behavior
- hosted user-data processing
- raw sensitive external projection
- professional advice
- release/platform readiness claim
- a sixth tab
- a broad assistant surface

## Memory Permission Object Families

| Object family | Purpose | Default posture |
|---|---|---|
| `MemoryPermissionEntry` | User permission for a memory, source, area, or inference. | Reviewable and private. |
| `SensitiveAreaClass` | A domain where stricter privacy applies. | Private by default. |
| `InferencePermission` | Whether inferred context may be proposed, shown, remembered, or rejected. | Not fact until reviewed. |
| `ProjectionPermission` | Whether content may appear in Today, Goals, Capture, Plan, You, or external surfaces. | Most restrictive wins. |
| `ExtractionBoundary` | What local parsing/classification may read and emit. | Data minimization first. |
| `ToolApprovalBoundary` | Whether a tool/action may run or prepare a proposal. | User approval before consequence. |
| `LocalAdapterPolicy` | Which deterministic or optional local adapter tier may be used. | Deterministic fallback required. |
| `PrivacyReceipt` | Record of permission, correction, rejection, hide, forget, or projection decisions. | User-owned. |

## Required Privacy Fields

Every memory, inference, extraction, recommendation, source claim, dream
handling output, proof link, or projection that may use sensitive life context
must carry:

- `id`
- `privacyClass`
- `sensitiveAreaClasses`
- `memoryPermissionState`
- `inferenceState`
- `sourceState`
- `freshnessState`
- `reviewState`
- `projectionPermission`
- `externalSurfacePolicy`
- `toolApprovalState`
- `localAdapterPolicy`
- `fallbackState`
- `performanceBudgetState`
- `batteryBudgetState`
- `receipts`
- `correctionPath`
- `deletionPath`

## Permission States

Memory permission states:

- `remember`
- `private`
- `hide`
- `askLater`
- `reject`
- `forget`
- `correct`
- `stale`
- `sourceBacked`
- `inferredNeedsReview`
- `localOnly`
- `externalBlocked`
- `deletePending`

Inferred memories, classifications, sources, requirements, recommendations, or
dream handling outputs are never facts until reviewed where risk requires it.

## Sensitive Area Classes

Sensitive areas include:

- medical
- legal
- financial
- immigration
- education
- career-sensitive
- identity
- family
- relationship
- minors/student data
- location
- public reputation
- safety/crisis
- political or civic
- third-party personal data
- private attachments or screenshots

Sensitive areas require stricter review, redaction, logging restrictions, and
external-surface blocks by default.

## External-Surface Redaction

External surfaces include widgets, notifications, Live Activities, App Intents,
Shortcuts, Spotlight, logs, diagnostics, previews, exports, and future handoff
surfaces.

Projection rules:

- raw sensitive content is blocked by default
- summaries must be redacted and non-specific
- inferred content must not be projected externally as fact
- private attachments, third-party names, location, minors, and regulated
  contexts require explicit review
- logs, analytics, crash reports, and diagnostics must not include private
  content
- exports require user review and redaction preview

## Deterministic Fallback

Core correctness must work without model availability.

Tier ladder:

- `tier0Deterministic`: rule-based parsing, typed state, source/proof labels,
  and user review.
- `tier1LocalClassifier`: optional small local classifiers for low-risk
  routing after deterministic fallback exists.
- `tier2PlatformLocalAdapter`: future platform-local model adapter, gated by
  availability, privacy, performance, and user review.
- `tier3DownloadableLocalAdapter`: future optional adapter only after explicit
  approval and proof.
- `tierBlocked`: hosted, bundled, or unreviewed model path is blocked.

No model tier may be required for capture, review, source labels, privacy
controls, correction, deletion, export, or safe fallback.

## Structured Extraction Boundary

Local extraction may propose structured fields only when it preserves:

- source text boundary
- extracted field
- confidence-free evidence posture
- privacy class
- sensitive area classes
- source/freshness label
- user review need
- rejection/correction path
- no hidden mutation

Extraction must degrade to user clarification when privacy, source, safety, or
freshness is uncertain.

## Tool Calling Approval

Tool calling means any action that could change app state, route content,
prepare export, write calendar/reminder data, create proof, change privacy
state, refresh source packs, invoke a model, or project externally.

Approval states:

- `notAllowed`
- `reviewOnly`
- `prepareProposal`
- `userApproved`
- `userRejected`
- `requiresSourceReview`
- `requiresPrivacyReview`
- `requiresHumanReview`
- `blockedBySensitivity`
- `blockedByFallback`

No tool may mutate commitments, goals, plans, proof, requirements, sources,
privacy state, exports, notifications, widgets, or external surfaces without a
user-reviewed proposal and receipt.

## Performance And Battery Boundary

Any future local adapter must define:

- launch impact
- foreground interaction budget
- background work budget
- memory budget
- battery posture
- thermal posture
- cancellation behavior
- cache policy
- deterministic fallback
- unsupported-device behavior

No model call may run on app launch by default. Background processing must not
scan private life context without explicit scope and user-value proof.

## API Contract Families

These are architecture contracts, not implemented Swift APIs in HPS09.

### Memory Permission Read API

Purpose: load permission, privacy, source, freshness, and projection posture
for a bounded object or surface.

Required output:

- permission entries
- sensitive area classes
- projection policy
- correction/deletion paths
- receipts

### Permission Proposal API

Purpose: propose remember, hide, reject, forget, correct, or projection changes
without applying them silently.

Required output:

- proposed permission change
- affected objects
- privacy impact
- external-surface impact
- user approval requirement
- receipt to write if accepted

### Local Adapter Evaluation API

Purpose: decide whether deterministic behavior, optional local classifier, or
future local adapter is allowed.

Required output:

- adapter tier
- fallback state
- source/privacy/safety posture
- performance and battery posture
- unsupported-device behavior
- blocked model paths

### Structured Extraction API

Purpose: produce reviewable structured fields from local input without
creating facts or mutations.

Required output:

- extracted fields
- source snippet boundary
- privacy class
- sensitive area labels
- review state
- rejection/correction path

### Tool Approval API

Purpose: gate consequential actions before any mutation, export, projection, or
adapter invocation.

Required output:

- tool intent
- affected objects
- approval state
- privacy/source/freshness impact
- fallback
- receipt requirement

## Surface Projection

Projection rules:

- Today receives only redacted, action-safe summaries.
- Goals receives path privacy, proof privacy, source state, and review controls
  inside the owning goal.
- Capture receives extraction proposals and privacy labels before placement.
- Plan receives capacity and commitment privacy boundaries without hidden
  calendar writes.
- You owns memory permissions, sensitive areas, correction, deletion, export,
  adapter settings, and trust receipts.
- External surfaces receive redacted summaries only.

## Regression Oracle

Future implementation must be tested against:

- inferred memory rejected before becoming fact
- private goal blocked from widget projection
- sensitive attachment excluded from logs and exports until reviewed
- minor/student data remains most-restrictive
- crisis-coded input avoids normal routing
- deterministic fallback works with no model availability
- unsupported device does not lose core behavior
- local adapter cancelled without mutation
- stale source blocks extraction promotion
- tool proposal rejected without side effects
- hidden mutation attempt is blocked
- high battery/thermal posture disables adapter
- export shows redaction preview
- delete pending hides from projections

## No-Claim Boundary

This document does not implement memory permission runtime, local intelligence
runtime, extraction, classification, model behavior, tool calling,
personalization, persistence, schema, sync, cloud, analytics, UI, external
projection behavior, export behavior, professional advice, legal/privacy
compliance, App Store readiness, TestFlight readiness, release readiness,
physical-device behavior, public accessibility conformance, or acquisition
outcome.
