# Ambitions Verified Proof Ledger Portability Architecture
<!-- markdownlint-disable MD013 -->

Status: HPS03 source truth / docs-domain architecture. No production Swift implementation.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade

## Purpose

The Verified Proof Ledger defines how Ambitions should represent user-owned
evidence of progress, closure, source support, and portability without turning
proof into a score, social credential, public verification network, or external
authority.

Proof exists to help the user answer:

> What happened, what does it support, what still counts, and what can I safely
> carry forward?

HPS03 is architecture only. It does not implement a ledger store, export
pipeline, verifier workflow, public credential, marketplace, schema, sync,
cloud account, or UI.

## Product Boundary

The proof ledger must remain an internal trust substrate for:

- Today closure and recovery
- Goals path evidence
- Capture placement receipts
- Plan reflow and commitment-fit receipts
- You privacy, correction, export, and trust review
- AOS proof and source kernels
- LDI requirement/proof bridges

The proof ledger must not become:

- a trophy shelf
- a ranked output or quantified performance grade
- an activity feed
- a public credential profile
- a verifier marketplace
- a school, workforce, or institution product
- a hosted evidence vault
- a proof API product
- a release-readiness or compliance claim

## Proof Object Families

| Object family | Purpose | Default posture |
|---|---|---|
| `ProgressProof` | Evidence that the user did, made, decided, learned, completed, or preserved something. | Private and user-owned. |
| `ClosureProof` | Evidence produced by Action Closure, Still Counts, recovery, blocked, waiting, moved, or review outcomes. | Private with correction path. |
| `RequirementProof` | Evidence mapped to a source-bound requirement, prerequisite, deadline, or eligibility condition. | Source-labeled and reviewable. |
| `SourceProof` | Evidence that a requirement or claim came from a source and carries freshness/claim state. | Source Atlas inherited. |
| `TransferProof` | Evidence that prior work still counts toward a pivot, adjacent path, or alternate option. | Reviewable with option-value receipt. |
| `VerifierReceipt` | Future architecture record that a person or institution may have reviewed proof. | No verifier product in HPS03. |
| `CorrectionReceipt` | Record that proof was corrected, rejected, revoked, hidden, or deleted by the user. | User-control first. |
| `ExportReceipt` | Record that a proof package was prepared or handed off under user control. | Redacted by default. |

## Proof State Fields

Every proof object that may affect a recommendation, path, requirement,
external projection, or export must carry:

- `id`
- `proofFamily`
- `title`
- `summary`
- `privacyClass`
- `sourceState`
- `freshnessState`
- `reviewState`
- `strengthState`
- `portabilityState`
- `createdAt`
- `updatedAt`
- `linkedGraphNodes`
- `linkedRequirements`
- `receipts`
- `correctionPath`

## Proof Strength States

Proof strength is qualitative. It must not become a score, percentage, rank, or
public grade.

- `userStated`
- `locallyRecorded`
- `sourceLinked`
- `sourceMatched`
- `thirdPartyReviewed`
- `requirementSatisfiedPendingReview`
- `insufficient`
- `conflicting`
- `revoked`
- `unknown`

No proof state may be promoted to official, externally valid, institutionally
accepted, or professionally verified without explicit source and human/process
evidence outside HPS03.

## Portability States

- `localOnly`: proof remains inside Ambitions.
- `exportReadyRedacted`: a user-reviewable redacted summary can be prepared.
- `exportReadyFull`: a user-reviewable full export can be prepared.
- `requiresSourceReview`: source/freshness/claim review must happen first.
- `requiresPrivacyReview`: sensitive detail must be reviewed or redacted first.
- `requiresHumanReview`: human/legal/institutional review is required.
- `blockedByRevocation`: proof has been revoked or disputed.
- `deletePending`: proof is hidden from projections until deletion resolves.

## Proof-To-Requirement Mapping

Requirement proof must preserve:

- requirement identifier
- source claim identifier
- source/freshness state
- proof object identifier
- evidence summary
- requirement satisfaction posture
- uncertainty or conflict note
- review owner
- correction or revocation path

Allowed satisfaction postures:

- `supportsRequirement`
- `partiallySupportsRequirement`
- `needsMoreEvidence`
- `needsFreshSource`
- `needsHumanReview`
- `conflictsWithRequirement`
- `notApplicable`
- `unknown`

Ambitions must not claim that a requirement is officially satisfied unless a
future scoped implementation has source evidence, user confirmation, and any
required human/institutional review.

## Privacy And Redaction

Proof is sensitive by default when it can expose life context, identity,
health, finances, education, career, relationships, location, minors,
attachments, screenshots, documents, sources, or third-party names.

External projection rules:

- widgets, notifications, App Intents, Live Activities, and handoffs receive
  redacted summaries by default
- logs, analytics, crash reports, and diagnostics must not include proof
  content
- exports must require user review
- sensitive proof must carry correction, hide, revoke, and delete paths
- proof attached to minors, student data, health, legal, financial, or
  professional contexts requires stricter review

## Portability Package Contract

A future proof export package must be user-reviewed and must separate:

- manifest
- redaction summary
- proof summaries
- source references
- requirement mappings
- receipt history
- correction/revocation notes
- excluded sensitive details
- unsupported or stale claims

HPS03 does not define a file format or implement export. It defines the minimum
truth fields later export/import work must preserve.

## Future Verifier Boundary

Future verifier roles may include the user, parent, teacher, counselor,
manager, coach, institution, or external reviewer.

HPS03 does not implement:

- verifier accounts
- multi-user roles
- institutional workflows
- public credentials
- badges
- marketplace behavior
- official validation
- employment, admissions, licensing, legal, medical, financial, or compliance
  proof

Any future verifier flow must be opt-in, source-labeled, revocable,
privacy-reviewed, and legally reviewed before external use.

## API Contract Families

These are architecture contracts, not implemented Swift APIs in HPS03.

### Proof Read API

Purpose: load bounded proof slices for a surface or graph query.

Required inputs:

- surface owner
- proof families
- privacy scope
- source/freshness policy
- portability policy

Required output:

- proof summaries
- linked graph nodes and requirements
- privacy redactions
- source/freshness warnings
- correction/revocation state
- unsupported-claim notes

### Proof Proposal API

Purpose: propose a new proof, mapping, correction, revocation, or transfer.

Required output:

- proposed proof summary
- source and requirement links
- privacy impact
- user confirmation needed
- receipts to write if accepted
- rejected unsafe changes

Silent proof creation, promotion, export, or externalization is forbidden.

### Proof Portability API

Purpose: prepare a user-reviewable proof package or explain why export is not
safe yet.

Required output:

- portability state
- redaction preview
- included proof summaries
- excluded sensitive details
- stale/source-needed warnings
- correction/revocation notes
- user confirmation requirement

### Proof Receipt API

Purpose: attach closure, source, transfer, correction, revocation, privacy, or
export receipts to proof objects and graph nodes.

Required output:

- receipt id
- affected proof objects
- affected graph nodes
- changed fact summary
- privacy class
- rollback or correction path

## HPS And AOS Inheritance

AOS12, AOS13, AOS14, LDI08, LDI14, Source Atlas, and later export/import work
must inherit this proof architecture where proof affects requirements,
recommendations, source claims, dream paths, pivots, or external handoff.

## No-Claim Boundary

This document does not implement proof storage, proof export, verifier flows,
public credentials, legal compliance, privacy compliance, source certification,
institutional validation, App Store readiness, TestFlight readiness, release
readiness, physical-device behavior, or public accessibility conformance.
