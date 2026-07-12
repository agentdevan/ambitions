+++
spec_id = "APP-SHELL"
title = "App Shell"
kind = "app"
status = "normative"
owner_domain = "app-shell"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "app.shell.failure-recovery",
  "app.shell.first-viewport",
  "app.shell.global-actions",
  "app.shell.root-navigation",
  "app.shell.state",
]
inherits = [
  "LAW-SHELL-STAGE-001",
  "CONST-IA-ROOT-001",
  "LAW-IA-NONROOT-001",
  "IA-PLAIN-BRANDED-NAMING-001",
  "PLATFORM-NATIVE-IPHONE-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
  "CONST-PROOF-EVIDENCE-001",
]
depends_on = ["CONSTITUTION"]
source_owners = [
  "Native/Ambitions/App/",
  "Native/Ambitions/Stage/",
  "Native/Ambitions/DesignSystem/StagePrimitives/",
  "Native/Ambitions/Quality/",
]
+++

# App Shell

This shadow specification defines intended app-shell composition. It refines the Constitution without becoming active authority, and it makes no claim that the current shell, runtime, accessibility behavior, or rendered product satisfies these requirements.

## SPEC-APP-SHELL-ROOT-NAVIGATION-001 — Root-depth shell ownership

- **Concept:** `app.shell.root-navigation`
- **Modality:** `MUST`
- **Scope:** Shell chrome at root depth and while leaving root depth
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SHELL-ROOT-001`, `SCENARIO-APP-SHELL-DEPTH-002`
- **Supersedes:** none

The shell MUST render one root-dock instance for the persistent roots declared by `CONST-IA-ROOT-001`. It must not redefine, rename, reorder by inference, or add to that constitutional set. The dock is present only at root depth and leaves when the route enters a drilldown, full-screen Capture, deep inspection, or a deep Time state whose owning specification requires immersive presentation. Native back behavior and edge-swipe return remain available at drilldown depth.

The default root treatment is icon-only. Plain accessible labels remain available to assistive technology and may become visible only for onboarding, long-press disclosure, or an evidence-backed comprehension fallback. Long press is never the only way to learn or activate a root.

## SPEC-APP-SHELL-GLOBAL-ACTIONS-001 — Integrated global-action access

- **Concept:** `app.shell.global-actions`
- **Modality:** `MUST`
- **Scope:** Shell access points for global Capture and Search
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SHELL-GLOBAL-ACTIONS-001`, `AUDIT-APP-SHELL-DUPLICATE-CONTROL-001`
- **Supersedes:** none

The shell MUST provide integrated, context-appropriate access to the constitutionally non-root global systems. It MUST NOT create an additional dock position, persistent floating button, duplicate first-viewport control, or alternate mutation owner. The global system specifications own their behavior and data; the shell owns only entry, presentation handoff, return context, focus transfer, and duplicate-control prevention.

## SPEC-APP-SHELL-FIRST-VIEWPORT-001 — Product object dominates shell chrome

- **Concept:** `app.shell.first-viewport`
- **Modality:** `MUST`
- **Scope:** Every root first viewport
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SHELL-FIRST-VIEWPORT-001`, `PROOF-APP-SHELL-HIERARCHY-001`
- **Supersedes:** none

The shell MUST reserve system safe areas for status, compact contextual actions, the active surface, and root navigation while leaving the active surface's primary product object visually and semantically dominant. Atmosphere may extend full-screen; readable content and controls remain safe. Shell material must feel integrated rather than boxed, bordered, detached, or layered over the product object. No shell action may obscure actionable content.

## APP-SHELL-STATE-001 — Shell state follows route state

- **Concept:** `app.shell.state`
- **Modality:** `MUST`
- **Scope:** Root, drilldown, overlay, inspection, restoration, and unavailable-route states
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SHELL-STATE-001`, `SCENARIO-APP-SHELL-RESTORE-001`
- **Supersedes:** none

Shell state MUST be derived from the current route and presentation depth. It distinguishes root, drilldown, full-screen overlay, compact modal, deep inspection, restoration, and unavailable-route states. It preserves the prior root and return focus while a non-root presentation is active. A shell transition cannot mutate canonical product data; accepted product actions remain subject to the constitutional runtime sequence.

## APP-SHELL-FAILURE-001 — Shell failure preserves a usable local root

- **Concept:** `app.shell.failure-recovery`
- **Modality:** `MUST`
- **Scope:** Shell composition, route-presentation, focus, and chrome failures
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-SHELL-FAILURE-001`, `SCENARIO-APP-SHELL-FOCUS-RECOVERY-001`
- **Supersedes:** none

When shell composition or route presentation fails, the app MUST preserve or recover to the nearest valid local state without fabricating success or discarding accepted input. Recovery prefers the current valid root and its preserved state, then a deterministic root anchor. The failure presentation states what remains available, offers a retry or safe return when meaningful, restores focus, and never exposes a blank, duplicate, or unreachable shell.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
The shell is responsible for root-depth chrome, safe-area composition, contextual global-system entry, presentation containment, return context, and focus handoff. It is not responsible for constitutional root IA, surface content, Capture/Search behavior, object mutation, privacy policy, or current implementation status.

<!-- canon-section: inputs-outputs -->
Inputs are the current route, presentation depth, active-surface chrome contract, safe-area environment, accessibility environment, and recoverable prior focus. Outputs are one composed shell state, visible chrome policy, presentation handoff, and deterministic return/focus target; no output is canonical product data.

<!-- canon-section: authority-boundary -->
`LAW-SHELL-STAGE-001` and the constitutional IA laws remain authoritative for Stage and root ownership. This file refines shell composition only, references the root set rather than restating it, and delegates all global-system and surface behavior to their owning specifications.

<!-- canon-section: data-classification -->
Shell route and focus state are local operational metadata. Shell chrome must not surface private object titles, proof, source, receipt, account, permission, or diagnostic details unless the active owning view explicitly authorizes that disclosure for the current context.

<!-- canon-section: state-model -->
The shell record separates route depth, presentation ownership, return, and focus.

The required shell states are root, drilldown, full-screen overlay, compact modal, deep inspection, restoration, and unavailable route. Transitions retain one active presentation owner and one valid return path; duplicate shell, crown, dock, or global-action ownership is invalid.

<!-- canon-section: failure-recovery -->
Composition, route, or focus failure retains accepted local state, offers retry or safe return, and restores a valid root anchor without fake success. Draft and mutation recovery belong to their owning systems and must not be silently cleared by shell recovery.

<!-- canon-section: local-network-boundary -->
Root switching, shell presentation, Capture/Search entry, dismissal, and recovery remain available without sign-in or network. Network state may affect content owned by another system; it never gates the shell itself.

<!-- canon-section: determinism -->
Given the same valid route, presentation depth, active-surface contract, and accessibility environment, the shell produces the same ownership, visibility, dismissal, and focus policy. Presentation heuristics may not invent a root or duplicate a global action.

<!-- canon-section: observability -->
Scoped proof must be able to inspect route depth, active presentation owner, dock visibility, global-action ownership, return route, focus target, and recovery result without recording private content. Observability requirements do not assert that current diagnostics already provide this evidence.

<!-- canon-section: source-ownership -->
Stable implementation routing is `App/` for app assembly and route intake, `Stage/` for shell and presentation ownership, semantic Stage primitives for shared chrome, and `Quality/` for shell proof. The listed paths are implementation mappings, not proof that the behavior is complete.

<!-- canon-section: tests-proof -->
Required proof covers root-only dock visibility, no extra root/global control, native drilldown return, preserved return context, focus restoration, safe-area behavior, VoiceOver labels/actions/order, Dynamic Type, Reduce Motion, Reduce Transparency, contrast, and failure recovery. Current passing evidence is required before any scoped Green claim.

<!-- canon-section: performance-resource-constraints -->
On the oldest supported physical iPhone in an optimized build, measured across 200 root, drilldown, overlay, and dismissal transitions with all four constitutional roots, depth up to 20, and three simultaneous presentation classes, shell policy evaluation MUST complete within 8 ms at P95 and accepted root-switch dispatch within 50 ms at P95. The first stable product frame after dispatch MUST arrive within 100 ms at P95, with no main-thread stall above 50 ms. The 200-transition run MUST add no more than 5 MiB resident memory, perform zero synchronous disk I/O and zero network calls on the interaction path, and leave no duplicate presentation owner. Shell state uses no polling or autonomous background work. Current device, frame, latency, memory, and energy proof is not claimed.
