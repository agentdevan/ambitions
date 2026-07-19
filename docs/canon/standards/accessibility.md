+++
spec_id = "STANDARD-ACCESSIBILITY"
title = "Accessibility"
kind = "standard"
status = "normative"
owner_domain = "standard-accessibility"
canon_revision = 1
profile = "standard-v1"
owns_concepts = [
  "accessibility.semantic-equivalence.application",
  "accessibility.reading-focus",
  "accessibility.dynamic-type",
  "accessibility.reduced-effects",
  "accessibility.input-equivalence",
  "accessibility.status-errors",
  "accessibility.proof-matrix",
  "standard.acceptance.accessibility",
]
inherits = ["ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001", "PLATFORM-NATIVE-IPHONE-001"]
depends_on = ["CONSTITUTION"]
source_owners = ["Native/Ambitions/Interaction/Accessibility/", "Native/Ambitions/DesignSystem/", "Native/Ambitions/Stage/", "Native/Ambitions/Rendering/", "Native/Ambitions/Surfaces/", "Native/Ambitions/Composer/", "Native/Ambitions/Quality/Accessibility/"]
+++

# Accessibility

This shadow standard defines cross-cutting semantic equivalence. It does not certify accessibility conformance.

## A11Y-002 — Equivalent identity, state, value, action, and consequence
- **Concept:** `accessibility.semantic-equivalence.application`
- **Modality:** `MUST`
- **Scope:** Every perceivable and actionable product state
- **Status:** `normative`
- **Verification:** `PROOF-A11Y-SEMANTIC-EQUIVALENCE-001`
- **Supersedes:** none

Accessibility presentation MUST communicate the same object identity, state, value, available action, material consequence, privacy meaning, and completion result as the visual presentation.

Goal Path MUST expose node order, current position, state, rationale, and actions without requiring horizontal visual interpretation.

Spatial or visual systems MUST expose equivalent semantics and actions.

## A11Y-READING-FOCUS-001 — Deterministic reading and focus
- **Concept:** `accessibility.reading-focus`
- **Modality:** `MUST`
- **Scope:** Navigation, overlays, updates, errors, and recovery
- **Status:** `normative`
- **Verification:** `TEST-A11Y-READING-FOCUS-001`
- **Supersedes:** none

Reading order, headings, rotor grouping, announcements, modal containment, and focus restoration MUST be deterministic and return the user to the initiating context.

VoiceOver MUST expose labels, values, hints, actions, and a predictable reading order.

Root VoiceOver order MUST proceed from title to context, primary object, primary action, remaining objects, and root navigation.

## A11Y-DYNAMIC-TYPE-001 — Dynamic Type without hidden meaning
- **Concept:** `accessibility.dynamic-type`
- **Modality:** `MUST`
- **Scope:** User-facing text and actions
- **Status:** `normative`
- **Verification:** `PROOF-A11Y-DYNAMIC-TYPE-001`
- **Supersedes:** none

Text and controls MUST reflow through supported accessibility sizes without clipping, overlap, meaning loss, or unreachable critical actions.

Dynamic Type MUST remain usable at every supported size without hiding meaning.

Root composition MAY become scrollable at large sizes.

## A11Y-REDUCED-EFFECTS-001 — Reduced effects preserve state
- **Concept:** `accessibility.reduced-effects`
- **Modality:** `MUST`
- **Scope:** Motion, transparency, contrast, differentiation, and haptics
- **Status:** `normative`
- **Verification:** `PROOF-A11Y-REDUCED-EFFECTS-001`
- **Supersedes:** none

Reduce Motion and Reduce Transparency alternatives MUST preserve spatial/state comprehension; contrast and non-color cues MUST preserve semantics without requiring haptics or animation.

Motion MUST NOT be decorative proof of sophistication.

Haptics MUST NOT become noisy or substitute for visual, audible, or accessibility feedback.

Reduced-effects validation MUST cover contrast.

State meaning MUST NOT rely on color alone.

Reduce Motion MUST use crossfades and focus-preserving transitions.

Reduce Transparency MUST use opaque semantic surfaces.

Increase Contrast MUST strengthen boundaries and text contrast.

Differentiate Without Color evidence MUST show that shapes, lines, symbols, and labels preserve state.

## A11Y-INPUT-EQUIVALENCE-001 — No gesture-only command
- **Concept:** `accessibility.input-equivalence`
- **Modality:** `MUST`
- **Scope:** Touch, keyboard, Switch Control, Voice Control, and assistive actions
- **Status:** `normative`
- **Verification:** `TEST-A11Y-INPUT-EQUIVALENCE-001`
- **Supersedes:** none

Every material action MUST have a labeled, reachable, non-gesture-only path with adequate target size and plain consequence.

Every spatial interaction MUST have semantic and reduced-motion equivalence.

Long press MUST reveal a label and accessibility-friendly description and MUST NOT be required for access.

A nonvisual chronological equivalent MUST support complete inspection without horizontal gesture dependence.

Jump controls MUST expose Start / Now / Next / Finish.

Every command MUST support applicable Switch Control, Voice Control, hardware keyboard and focus access, native dictation, and minimum hit targets.

Every gesture capability MUST expose a non-gesture equivalent.

## A11Y-STATUS-ERRORS-001 — Status and errors remain perceivable
- **Concept:** `accessibility.status-errors`
- **Modality:** `MUST`
- **Scope:** Loading, progress, validation, degraded, failure, recovery, and completion
- **Status:** `normative`
- **Verification:** `TEST-A11Y-STATUS-ERRORS-001`
- **Supersedes:** none

State changes MUST expose semantic status, next action, retry/cancel behavior, and safe focus without relying only on color, placement, animation, or timing.

## A11Y-PROOF-MATRIX-001 — Accessibility evidence matrix
- **Concept:** `accessibility.proof-matrix`
- **Modality:** `MUST`
- **Scope:** Acceptance evidence
- **Status:** `normative`
- **Verification:** `AUDIT-A11Y-PROOF-MATRIX-001`
- **Supersedes:** none

Accessibility acceptance MUST bind exact commit, device/OS, content/state fixtures, VoiceOver order/actions, Dynamic Type, reduced effects, contrast, keyboard/input, localization, failures, and known gaps.

Product and IA accessibility acceptance MUST require preview matrices, VoiceOver scripts, motion alternatives, screenshot proof, large-text layouts, tap-target audits, reduced-effects checks, contrast, haptic alternatives, and proof artifacts.

Accessibility evidence MUST NOT impede comprehension of the underlying product state.

Accessibility MUST be a product acceptance requirement, not a later compliance pass.

Accessibility evidence MUST verify semantic token use.

Accessibility MUST be a release requirement, not an annotation.

Product truth MUST require accessibility and flagship visual quality, but release truth requires proof.

Automated accessibility checks MUST NOT be treated as sufficient proof on their own.

## STANDARD-ACCEPTANCE-ACCESSIBILITY-001 — Accessibility Green requires independent evidence
- **Concept:** `standard.acceptance.accessibility`
- **Modality:** `MUST NOT`
- **Scope:** Accessibility readiness claims
- **Status:** `normative`
- **Verification:** `REVIEW-A11Y-CLAIM-CEILING-001`
- **Supersedes:** none

Canon, source presence, unit tests, or screenshots alone MUST NOT be reported as Accessibility Green; current exact-scope evidence and required independent review are mandatory.

Accessibility acceptance MUST independently verify VoiceOver order and actions.

<!-- canon-section: purpose -->
Preserve equivalent meaning, control, recovery, and trust for disabled users.
<!-- canon-section: scope -->
Applies across app, surfaces, objects, journeys, systems, extensions, copy, and proof while exact behavior remains locally owned.
<!-- canon-section: requirements -->
The requirements above are conjunctive for the affected scope.
<!-- canon-section: exceptions -->
Unsupported behavior requires an explicit blocker and accessible alternative; silent omission is forbidden.
<!-- canon-section: verification -->
Use semantic tests, assistive-technology inspection, device matrices, screenshots/video where useful, and independent review.
<!-- canon-section: source-ownership -->
Target owners are `Interaction/Accessibility/`, `DesignSystem/`, each presenting owner, and `Quality/Accessibility/`;
<!-- canon-section: proof -->
Exact-commit evidence includes assistive-technology transcripts, focus/order/action results, Dynamic Type and reduced-effect matrices, device/OS, fixtures, findings, reviewer, and artifacts.
<!-- canon-section: amendment-impact -->
Amendments identify affected semantics, assistive technologies, surfaces, actions, focus, tests, devices, visuals, privacy, performance, proof, claim ceiling, and rollback.
