# Object OS Primitives

Status: Active supporting canon
Parent: docs/codex/AMBITIONS_OBJECT_OS_CANON.md
Runtime impact in this batch: None

## Purpose

This file defines reusable Ambitions Object OS primitives. Future runtime work should build with these primitives instead of inventing disconnected cards, lists, sheets, or one-off visual components.

## Primitive families

1. Object identity primitives
2. Object state primitives
3. Action / commitment primitives
4. Proof / receipt primitives
5. Trust / source primitives
6. Recovery primitives
7. Simulation / reflow primitives
8. Personal Runtime primitives
9. Native surface primitives
10. QA / fixture primitives

## 1. Object identity primitives

### ObjectHeader

Shows the object identity, type, state, and current relevance.

Required elements:

- object title
- object type
- state label
- optional Ambition Graph path
- optional trust/source status
- optional receipt count

### ObjectPath

Shows where an object lives in the hierarchy.

Example:

Identity Direction -> Life Area -> Ambition -> Goal Thread -> Commitment -> Step

### ObjectStateBadge

A quiet native badge, not a gamified score.

States include:

- active
- open
- waiting
- blocked
- moved
- shortened
- still counts
- closed with proof
- needs recovery
- source needed
- source stale
- low confidence
- protected
- simulation pending

### ObjectOrigin

Shows provenance:

- capture
- manual entry
- source import
- recommendation
- reflow
- reflection
- external native surface

## 2. Object state primitives

### StateRail

A compact state spine for a single object.

Use for:

- Action Slip lifecycle
- Active Commitment lifecycle
- Recovery Thread lifecycle
- Source Trust lifecycle
- Proof lifecycle

### StateTransitionRow

Shows a before/after transition:

- previous state
- new state
- why it changed
- receipt link
- undo availability

### ObjectAgingIndicator

Used for sources, proof, commitments, and recommendations.

States:

- fresh
- aging
- stale
- contradicted
- archived
- unknown

## 3. Action / commitment primitives

### ActionSlip

Review-before-commit primitive.

Contains:

- action candidate
- why it matters
- time fit
- proof opportunity
- source/proof basis
- risk if delayed
- closure options
- start/revise/dismiss

### ActionSlipTray

Persistent tray for pending action review.

Should be reachable from Today, Goals, Capture, Time, and native surfaces when an action candidate exists.

### ActiveCommitmentChip

Compact live commitment affordance for Continuity Dock, widgets, or Live Activity handoff.

### ClosureControlCluster

Closure actions:

- Completed
- Still Counts
- Moved
- Skipped / Not Needed
- Blocked
- Waiting
- Needs Recovery
- Needs Review

### CommitmentStateMachineView

Visualizes commitment states without shame or overdue framing.

## 4. Proof / receipt primitives

### ProofTrace

A visible link from object to proof.

### ProofOpportunity

Shows that the current action is likely to create durable proof.

### ProofTransferPreview

Used before pivot/delete/archive.

Shows:

- proof that survives
- proof that moves
- proof that becomes stale
- proof that is deleted
- proof needing review

### ReceiptPeek

Small confirmation after meaningful action.

Examples:

- Still Counts recorded
- Proof preserved
- Recovery thread created
- Learning signal reset
- Source marked stale

### ReceiptRow

Persistent ledger item in Proof Vault.

### ProofVaultFilterBar

Filters:

- all
- open
- proof-rich
- stale
- transferred
- contradicted
- needs review
- recovery-linked
- deleted/archived

## 5. Trust / source primitives

### TrustSeam

Reusable explanation affordance.

Questions:

- Why this?
- What changed?
- What source?
- What proof?
- What can I control?

### SourceAnchor

Compact source/proof/freshness marker.

### SourceNeededCallout

Used when Ambitions lacks enough proof/source support.

Actions:

- Add source
- Use provisional
- Skip for now

### WhyNotNowSheet

Explains suppressed recommendations.

Reasons:

- not enough time
- wrong context
- source stale
- proof missing
- blocked dependency
- recovery is higher priority
- protected time

## 6. Recovery primitives

### RecoveryRibbon

Visible cross-surface cue that recovery is active.

### LastHonestPointAnchor

Anchor for recovery state.

Shows:

- last meaningful proof
- last commitment
- last attempt
- smallest re-entry step

### RecoveryThreadCard

Not a generic card stack; use as a structured object detail block inside Recovery Thread Detail.

### StillCountsSheet

First-class closure flow for partial progress.

Required fields:

- what still counts
- what proof exists
- what changed
- next honest re-entry

## 7. Simulation / reflow primitives

### SimulationSheet

Preview before major change.

Contains:

- proposed change
- before/after
- affected objects
- proof transfer
- risk
- undo support
- confirm/cancel

### ReflowDecisionFold

Consent-based reflow view.

Shows:

- what moved
- why
- what still counts
- what proof survives
- what needs confirmation

### UndoTimeline

Sequential undo history for reversible actions.

### LifeShapeDelta

Visual comparison of time/capacity/pressure before and after a change.

## 8. Personal Runtime primitives

### LearningSignalRow

Shows local learning signal and controls.

Fields:

- signal description
- source
- last used
- affected recommendations
- enabled/disabled
- delete/reset

### LearningReceipt

Receipt for local adaptation.

### PersonalRuntimeInspector

Composite panel for You.

### OSDoctorSection

Diagnostic section for:

- data health
- stale sources
- blocked commitments
- missing proof
- learning controls
- privacy posture

## 9. Native surface primitives

### NativeSurfaceToken

Represents external surface eligibility.

Surfaces:

- widget
- Live Activity
- App Intent
- Share Extension
- Spotlight
- Control Center
- Action Button

### WidgetObjectSummary

Compact object state for widget.

### LiveCommitmentActivityState

Local ActivityKit state for active commitment.

### AppIntentReceiptBridge

Ensures App Intent action records command/event and receipt.

### ShareExtensionIntakeEnvelope

Normalizes share extension inputs into Meaning Router candidates.

## 10. QA / fixture primitives

### FounderQAOverlay

Debug-only overlay for object state and proof path.

### FixtureIdentityTag

Tags a preview/fixture with:

- surface
- object type
- state
- proof condition
- source condition
- accessibility condition

### VisualGrammarProbe

Debug overlay showing which visual grammar tokens are active.

## Object detail standard

Every object detail should use this rough order:

1. ObjectHeader
2. ObjectPath
3. current state
4. primary action
5. trust/proof/source seam
6. history/receipts
7. controls/correction/undo
8. native surface eligibility
9. accessibility summary if in QA mode

## Primitive anti-patterns

Do not build:

- arbitrary card stacks
- disconnected explanation widgets
- one-off modal sheets for each feature
- generic progress rings
- productivity scores
- hidden AI confidence percentages
- UI where motion carries essential information without static fallback

## Claims not made

This primitive canon does not implement runtime UI or claim visual completion.
