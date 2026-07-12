+++
spec_id = "GLOBAL-CAPTURE"
title = "Capture"
kind = "global"
status = "normative"
owner_domain = "global-capture"
canon_revision = 1
profile = "surface-v1"
owns_concepts = [
  "global.capture.identity",
  "global.capture.keyboard",
  "global.capture.saved-for-later",
  "global.capture.draft-recovery",
  "global.capture.proposal-flow",
  "global.capture.visual-authority",
]
inherits = [
  "LAW-IA-NONROOT-001",
  "OBJECT-SAVED-FOR-LATER-001",
  "CONTROL-MATERIAL-CONFIRMATION-001",
  "LAW-LOCAL-AUTHORITY-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION", "APP-PERMISSIONS"]
source_owners = [
  "Native/Ambitions/Composer/Capture/",
  "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/",
  "Native/Ambitions/Core/LocalRuntimeOS/Commands/",
  "Native/Ambitions/Core/LocalRuntimeOS/Inspection/",
  "Native/Ambitions/Quality/",
]
+++

# Capture

Capture uses `surface-v1` because it presents a full-screen, user-operated composer with first-viewport, presentation, state, accessibility, and visual contracts. It remains a global overlay, not a root or tab. This shadow target does not prove current behavior.

## SPEC-GLOBAL-CAPTURE-IDENTITY-001 — Global durable composer

- **Concept:** `global.capture.identity`
- **Modality:** `MUST`
- **Scope:** Capture presentation and intake boundary
- **Status:** `normative`
- **Verification:** `SCENARIO-CAPTURE-IDENTITY-001`
- **Supersedes:** none

Capture MUST be a global full-screen composer that preserves intent, allows or infers type, previews material consequences, and routes accepted objects to canonical owners. It MUST NOT become a root, tab, half-sheet quick box, inbox, category wall, chatbot, notes feed, or permanent floating control.

## SPEC-GLOBAL-CAPTURE-KEYBOARD-001 — Composer remains primary with keyboard present

- **Concept:** `global.capture.keyboard`
- **Modality:** `MUST`
- **Scope:** Keyboard, dictation, attachment, and focus presentation
- **Status:** `normative`
- **Verification:** `PROOF-CAPTURE-KEYBOARD-001`
- **Supersedes:** none

Keyboard presentation MUST preserve the text field, visible type override, primary save/continue action, attachment access, cancellation, validation feedback, and safe-area clearance without shrinking Capture into a utility sheet. Hardware keyboard, dictation, Switch Control, and VoiceOver actions provide equivalent entry and focus behavior.

## SPEC-GLOBAL-CAPTURE-SAVED-FOR-LATER-001 — Unresolved state, never destination

- **Concept:** `global.capture.saved-for-later`
- **Modality:** `MUST`
- **Scope:** Durable unresolved intake
- **Status:** `normative`
- **Verification:** `SCENARIO-CAPTURE-SAVED-LATER-001`
- **Supersedes:** none

Saved for Later MUST remain a durable, searchable, locally recoverable unresolved state with explicit promotion. It MUST NOT become a Capture inbox, root, Today backlog, or persistent destination. Only explicit scheduling/promotion or one earned fit suggestion may bring it into active execution.

## SPEC-GLOBAL-CAPTURE-DRAFT-RECOVERY-001 — Original input survives every branch

- **Concept:** `global.capture.draft-recovery`
- **Modality:** `MUST`
- **Scope:** Interruption, crash, denial, attachment, validation, routing, and discard
- **Status:** `normative`
- **Verification:** `SCENARIO-CAPTURE-DRAFT-RECOVERY-001`
- **Supersedes:** none

The original Capture Draft MUST survive navigation away, app interruption, crash, permission denial, attachment failure, validation failure, and routing failure. Recovery restores text, type choice, metadata, attachment states, proposal state, prior context, and focus. Explicit discard confirmation is required; no failure may destroy original input.

## SPEC-GLOBAL-CAPTURE-PROPOSAL-FLOW-001 — Adaptive complexity without interrogation

- **Concept:** `global.capture.proposal-flow`
- **Modality:** `MUST`
- **Scope:** Classification, metadata, placement, conflict, confirmation, and receipt
- **Status:** `normative`
- **Verification:** `SCENARIO-CAPTURE-PROPOSAL-001`
- **Supersedes:** none

Simple input MUST save quickly. Complexity introduces only the required type/destination, metadata, schedule proposal, conflict check, confirmation, and receipt steps. Classification is visible, editable, deterministic, and local for core paths. Material interpretation or placement never commits silently; alternatives remain available without an interrogation wizard.

## SPEC-GLOBAL-CAPTURE-VISUAL-AUTHORITY-001 — Approved Capture package, separate implementation proof

- **Concept:** `global.capture.visual-authority`
- **Modality:** `MUST`
- **Scope:** Full-screen composer visual authority
- **Status:** `normative`
- **Verification:** `PROOF-CAPTURE-VISUAL-MAPPING-001`
- **Supersedes:** none

Visual review MUST reference stable external IDs and separate approved package authority from implementation proof. Owner-approved VSP-05 package `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:217:93` is the Capture visual target. Its Yellow approval does not prove draft recovery, mutation behavior, SwiftUI parity, accessibility, device behavior, runtime behavior, Visual Green, or release status.

## Completeness contract

<!-- canon-section: purpose-user-question -->
Capture answers how to place meaningful input somewhere safe, understand only necessary consequences, and turn accepted intent into a real canonical object without losing the original.

<!-- canon-section: entry-exit -->
Entry comes from integrated shell create, contextual creation, Share/deep link, or draft recovery. Dismissal returns to exact root/depth/focus; successful save returns with confirmation and route option; unresolved save remains reachable without a destination.

<!-- canon-section: routes-presentation -->
Capture is full-screen non-root presentation. Type/detail/proposal/review stages remain inside one recoverable composer flow. Permission and attachment pickers are contextual system presentations; canonical object detail opens only after accepted save.

<!-- canon-section: displayed-objects -->
The draft, text, visible type, attachments, metadata, destination, schedule proposal, alternatives, conflict/consequence summary, confirmation state, and save result are presented. Internal classifier/runtime structures remain hidden.

<!-- canon-section: resting-states -->
The composer state machine identifies content, interpretation, attachment, proposal, confirmation, persistence, and recovery phases.
Required states are blank, composing, typed, attachment-ready, proposal-ready, confirmation-required, Saved for Later, saved, recovered, and explicit-discard review.

<!-- canon-section: loading-transitional -->
Dictation, scan/import, attachment processing, classification, fit proposal, validation, routing, save, and restoration expose bounded progress/cancellation while preserving draft text and prior valid state.

<!-- canon-section: empty-degraded -->
Blank is useful and never an interrogation. Denied permission, offline, failed attachment, ambiguous type, invalid metadata, conflict, partial routing, and degraded store preserve input and offer edit, remove/replace attachment, retry, save unresolved, export, or cancel safely.

<!-- canon-section: commands-actions -->
The action set maps each visible control to a typed composer or canonical-owner command.
Enter, dictate, attach, choose type, edit metadata, review proposal, choose alternative, confirm consequence, save, Save for Later, retry, remove/replace attachment, discard, and undo use explicit actions. No gesture or spatial arrangement is required.

<!-- canon-section: durable-effects -->
Durable state separates draft persistence, accepted object mutation, attachment result, unresolved promotion, and receipt history.
Draft persistence precedes optional processing. Accepted save routes one validated command to the canonical owner and yields event, projections, receipt, replay, and attachment result. Saved for Later retains unresolved identity and promotion history.

<!-- canon-section: failure-rollback -->
Validation or routing rejection leaves the draft intact. Partial attachment or external failure records per-part status. Retry is idempotent; undo reverses safe accepted creation through canonical history; discard is explicit and never inferred from dismissal.

<!-- canon-section: offline -->
Local capability covers composition, classification, persistence, routing, receipt creation, and replay.
Text, deterministic core classification, type override, draft recovery, Saved for Later, local attachments, canonical local save, receipt, and replay work without account/network. Optional reference assistance can fail without blocking save.

<!-- canon-section: privacy-data-classification -->
Drafts, text, attachments, inferred type, context, constraints, and proposals are private local data. Camera/Photos/Files/voice permissions are contextual. No draft/private context goes to Account, R2, Source Atlas, or hosted AI; export/share is explicit and previewed.

<!-- canon-section: accessibility-reading-order -->
VoiceOver orders close/context, composer, type, attachments, proposal/consequences, alternatives, primary action, and recovery. Every attachment and proposal state has label/value/actions; validation focus moves to the exact issue; keyboard/dictation and non-spatial actions have parity.

<!-- canon-section: dynamic-type -->
Composer, type, attachments, consequences, and actions reflow vertically above keyboard with scroll-to-focus and no obscured input, clipped consequence, or hidden dismissal.

<!-- canon-section: reduce-motion -->
Stage transitions, classification changes, attachment progress, and proposal expansion use immediate state changes or restrained fades while retaining announcements and focus.

<!-- canon-section: reduce-transparency -->
Composer materials become opaque semantic surfaces with equivalent hierarchy, keyboard separation, attachment state, validation, and contrast.

<!-- canon-section: copy-state-language -->
Composer vocabulary names the object, proposal, consequence, persistence choice, and recovery action directly.
Use Capture, Goal, Step, Reminder, Event, Proof, Note, Save for Later, Review, and Undo. Avoid chatbot prompts, AI confidence, runtime language, shame, or false saved-success copy.

<!-- canon-section: visual-authority -->
The named package controls geometry, hierarchy, composition, states, and adaptive layout.
Stable package ID `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:217:93` supplies approved Capture design authority. Draft/runtime behavior, source rendering, accessibility/device evidence, implementation parity, and release proof remain separate.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Composer/Capture/` owns presentation; `Core/LocalRuntimeOS/CaptureRouting/` owns durable intake/classification/routing; `Commands/` owns accepted mutation; `Inspection/` owns receipts/history; `Quality/` owns proof. Current compliance is unclaimed.

<!-- canon-section: tests -->
Tests cover simple/complex proposals, type correction, draft persistence across every failure, Saved for Later reachability/promotion, attachment per-part failure, conflict confirmation, idempotent save, undo/replay, offline, privacy denial, keyboard/focus, VoiceOver actions/order, Dynamic Type, reduced effects, contrast, and return context.

<!-- canon-section: proof -->
Required proof includes crash/interruption recovery, attachment/permission failure fixtures, command/receipt/replay logs, screenshot and keyboard matrices, accessibility scripts, privacy-boundary evidence, scoped visual approval, exact commands/exits, and rollback. No proof is inferred from this file.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
Capture draft restoration, classification, proposal, attachment streaming, and local save acknowledgement MUST remain bounded and cancellable, use bounded media buffers, perform no core-path network gating or interaction-path synchronous disk I/O, use no polling or unbounded background loop, and preserve original input under resource pressure. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. Implementation authorization requires an owner-approved performance-registry record declaring device floor, OS, build configuration, representative draft/attachment/proposal data scale, warm/cold state, measurement tool, percentile/maximum, memory and storage-pressure measures, and regression threshold. Current performance and physical-device proof remain absent.
