+++
spec_id = "GLOBAL-MOTION"
title = "Motion"
kind = "global"
status = "normative"
owner_domain = "global-motion"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "global.motion.responsibility",
  "global.motion.state-continuity",
  "global.motion.accessibility",
]
inherits = [
  "LAW-IA-NONROOT-001",
  "CONST-RUNTIME-MUTATION-001",
  "CONTROL-UNDO-RECOVERY-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION"]
source_owners = [
  "Native/Ambitions/Stage/Motion/",
  "Native/Ambitions/Interaction/",
  "Native/Ambitions/DesignSystem/",
  "Native/Ambitions/Quality/",
]
+++

# Motion

Motion uses `system-v1` because it is cross-surface state-continuity behavior, not a presented destination or content surface. It may animate a real transition, but it never owns canonical data, a tab, a route, or a fifth root.

## SPEC-GLOBAL-MOTION-RESPONSIBILITY-001 — Behavior, never destination

- **Concept:** `global.motion.responsibility`
- **Modality:** `MUST`
- **Scope:** Stage and cross-surface motion behavior
- **Status:** `normative`
- **Verification:** `AUDIT-MOTION-NONROOT-001`
- **Supersedes:** none

Motion MUST communicate object continuity, accepted mutation, route depth, schedule adjustment consequence, start, completion, blockage, recovery, re-entry, time shift, undo, and protected-boundary preservation. It MUST NOT become a root, route, activity feed, analytics surface, score, streak, XP system, dashboard, or independent source of truth.

## SPEC-GLOBAL-MOTION-STATE-CONTINUITY-001 — Animation follows durable state

- **Concept:** `global.motion.state-continuity`
- **Modality:** `MUST`
- **Scope:** Selection, navigation, mutation, preview, commit, rejection, undo, and restoration
- **Status:** `normative`
- **Verification:** `SCENARIO-MOTION-CONTINUITY-001`
- **Supersedes:** none

Motion MUST derive from typed route and product-state transitions. Preview is visibly distinct from committed state; acceptance follows durable commit; rejection returns to the prior state; external pending/failure remains truthful; undo restores prior meaning. Animation completion cannot create success, mutate state, or hide a failure.

Motion MUST use object transforms when object identity persists and MUST use native push or sheet presentation when navigation or presentation depth changes.

## SPEC-GLOBAL-MOTION-ACCESSIBILITY-001 — Semantic and reduced alternatives are complete

- **Concept:** `global.motion.accessibility`
- **Modality:** `MUST`
- **Scope:** Every animated or spatial continuity cue
- **Status:** `normative`
- **Verification:** `A11Y-MOTION-EQUIVALENCE-001`
- **Supersedes:** none

Every motion cue MUST have equivalent state text, VoiceOver announcement where useful, predictable focus, non-color encoding, and Reduce Motion behavior. Drag, resize, path travel, ghost preview, object transform, and schedule movement MUST have explicit non-spatial controls and verbal consequence summaries. Haptics may reinforce but never carry meaning alone.

Selected VSP-09 rubric `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:92:2` is the cross-surface accessibility, motion, haptics, contrast, transparency, focus, and static-equivalent design authority.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Motion owns transition policy and semantic continuity under `Stage/Motion/`. It does not own root IA, routes, object state, commands, receipts, projections, content, visual authority packages, or proof of successful mutation.

<!-- canon-section: inputs-outputs -->
Inputs are typed prior/next route states, validated preview/commit/rejection/undo state, object identity continuity, user accessibility settings, focus target, and semantic transition intent. Outputs are bounded visual/haptic/audible transition instructions plus semantic announcements and deterministic focus; never canonical data.

<!-- canon-section: authority-boundary -->
Surface and global specs define product state; Stage defines presentation containment; Interaction/DesignSystem supply approved primitives; runtime receipts establish durable success. Motion consumes those facts and cannot reinterpret product law, bypass confirmation, or invent completion.

<!-- canon-section: data-classification -->
Motion uses ephemeral local identifiers and redacted semantic state. Debug traces exclude private titles, proof, schedules, attachments, rationale, and behavior context by default. Motion performs no egress and stores no private graph copy.

<!-- canon-section: state-model -->
The motion record separates intent, source/target semantic state, preview/committed/rejected/undo phase, duration class, interruptibility, reduced-motion substitute, haptic class, announcement, focus target, and completion/cancellation result. A missing semantic substitute is invalid.

<!-- canon-section: failure-recovery -->
Interrupted or failed animation resolves immediately to the current durable product state, restores a valid focus target, and issues the correct semantic announcement. It never rolls back or commits product state by itself. Repeated transitions coalesce deterministically; stale transitions are cancelled.

<!-- canon-section: local-network-boundary -->
All motion policy and substitutes operate locally without account/network. Network or external-write state may select a truthful pending/failure transition but cannot block interaction or delay durable local presentation.

<!-- canon-section: determinism -->
Transition selection is a pure mapping from typed semantic state and accessibility environment to bounded presentation instructions.
Given the same typed state transition, route depth, accessibility settings, interaction velocity class, and policy revision, Motion produces the same transition family, substitute, haptic, announcement, and focus outcome. It contains no autonomous recommendation or server-driven behavior.

<!-- canon-section: observability -->
Proof traces expose transition ID, semantic source/target state, preview/commit phase, reduced-motion selection, cancellation/coalescing, duration, dropped frames, announcement, and focus result with private payloads redacted. Traces do not prove the underlying mutation.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Stage/Motion/` owns transition continuity; `Interaction/` owns gesture/haptic policy; `DesignSystem/` owns semantic primitives; `Quality/` owns motion/accessibility/performance proof. No `Surfaces/Motion/` owner or compatibility location is permitted.

<!-- canon-section: tests-proof -->
Tests cover every semantic transition family, preview/commit/reject/undo, interruption/coalescing, restoration, external pending/failure, no-motion and reduced-motion substitutes, VoiceOver announcements, focus, haptic alternatives, non-color encoding, spatial-action alternatives, screenshots/video/traces, device frame pacing, and proof that animation never mutates data. Stable rubric ID `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:92:2` supplies design acceptance authority only.

<!-- canon-section: performance-resource-constraints -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
Motion transition selection, coalescing, interruption, static substitution, focus, and announcement work MUST remain bounded and cancellable, perform no disk or network I/O, use no polling or autonomous background loop, and resolve immediately to durable semantic state when presentation is interrupted. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. The implementation must define and test a performance-budget record declaring device floor, OS, build configuration, representative transition data scale, warm/cold state, measurement tool, percentile/maximum, named display refresh target, frame/energy measures, and regression threshold.
