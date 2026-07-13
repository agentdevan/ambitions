+++
spec_id = "STANDARD-SWIFTUI-DESIGN-SYSTEM"
title = "SwiftUI and Design System"
kind = "standard"
status = "normative"
owner_domain = "standard-swiftui-design-system"
canon_revision = 1
profile = "standard-v1"
owns_concepts = [
  "engineering.frontend.view-responsibility",
  "engineering.frontend.presentation-state",
  "engineering.frontend.exhaustive-state",
  "engineering.frontend.component-contract",
  "engineering.frontend.layout",
  "engineering.frontend.navigation",
  "engineering.frontend.body-purity",
  "engineering.frontend.abstraction",
  "engineering.frontend.preview-matrix",
  "engineering.frontend.assets",
  "engineering.design.tokens",
  "engineering.design.token-domains",
  "engineering.design.theme-completeness",
  "engineering.design.change-control",
  "engineering.design.constant-audit",
  "engineering.design.component-maturity",
  "engineering.design.positive-target",
  "standard.typography.copy-budget",
  "standard.spacing-corners.semantic-rhythm",
  "standard.interaction.native-equivalence",
  "standard.visual.package-readiness",
  "standard.visual.independent-review",
  "standard.interaction.tap",
  "standard.interaction.long-press",
  "standard.interaction.swipe",
  "standard.interaction.drag",
  "standard.interaction.focus",
  "standard.interaction.dismissal",
]
inherits = ["PLATFORM-NATIVE-IPHONE-001", "LAW-IA-PLAIN-LANGUAGE-001"]
depends_on = ["CONSTITUTION", "STANDARD-ACCESSIBILITY"]
source_owners = ["Native/Ambitions/DesignSystem/", "Native/Ambitions/Interaction/", "Native/Ambitions/Rendering/", "Native/Ambitions/Stage/", "Native/Ambitions/Quality/"]
+++

# SwiftUI and Design System

This shadow standard owns reusable presentation engineering and semantic design primitives, not product-specific first viewports or surface behavior.

## FRONTEND-001 — Views render and emit intent
- **Concept:** `engineering.frontend.view-responsibility`
- **Modality:** `MUST`
- **Scope:** SwiftUI Views
- **Status:** `normative`
- **Verification:** `AUDIT-VIEW-RESPONSIBILITY-001`
- **Supersedes:** none

Views MUST render projection or presentation state and emit intents; they MUST NOT own canonical persistence, network, planning, recurrence, replay, or external writes.

## FRONTEND-002 — Presentation-state ownership
- **Concept:** `engineering.frontend.presentation-state`
- **Modality:** `MUST`
- **Scope:** SwiftUI state
- **Status:** `normative`
- **Verification:** `AUDIT-PRESENTATION-STATE-001`
- **Supersedes:** none

Ephemeral, dependency, coordination, and canonical rendered state MUST use distinct appropriate owners; Views MUST NOT duplicate mutable canonical state.

Views MUST NOT contain duplicated mutable canonical state.

Mutable collections MUST NOT use index-based identity.

## FRONTEND-003 — Exhaustive state representation
- **Concept:** `engineering.frontend.exhaustive-state`
- **Modality:** `MUST`
- **Scope:** Surfaces, details, sheets, rows, grids, and overlays
- **Status:** `normative`
- **Verification:** `TEST-EXHAUSTIVE-UI-STATE-001`
- **Supersedes:** none

Presented features MUST use exhaustive state models that prevent impossible combinations and expose resting, loading, transition, empty, degraded, failure, and recovery states.

Known values MAY be shown as object state.

Flagship surfaces, details, sheets, rows, grids, and overlays MUST use exhaustive state models rather than unrelated Boolean combinations that permit impossible UI.

Every surface and object MUST specify and render.

## FRONTEND-004 — Shared component contracts
- **Concept:** `engineering.frontend.component-contract`
- **Modality:** `MUST`
- **Scope:** Shared UI components
- **Status:** `normative`
- **Verification:** `AUDIT-COMPONENT-CONTRACT-001`
- **Supersedes:** none

Shared components MUST declare semantics, input, states, accessibility, layout, Dynamic Type, reduced effects, actions, forbidden uses, and proof baseline.

Every shared component MUST document semantic purpose, input model, supported states, accessibility, layout, Dynamic Type, motion, tap targets, forbidden uses, and screenshot baseline.

## FRONTEND-005 — Native layout law
- **Concept:** `engineering.frontend.layout`
- **Modality:** `MUST`
- **Scope:** Presented layouts
- **Status:** `normative`
- **Verification:** `PROOF-LAYOUT-MATRIX-001`
- **Supersedes:** none

Owning specifications MUST define supported devices, orientation, safe areas, keyboard and scroll ownership, sheets, readable widths, text expansion, and large-content behavior using SwiftUI-native behavior by default.

## FRONTEND-006 — Navigation identity
- **Concept:** `engineering.frontend.navigation`
- **Modality:** `MUST`
- **Scope:** Routes and presentation
- **Status:** `normative`
- **Verification:** `TEST-NAVIGATION-IDENTITY-001`
- **Supersedes:** none

Routes MUST have stable identity, deep-link and restoration behavior, focus return, and missing/deleted/conflict/degraded outcomes.

## FRONTEND-007 — Body purity
- **Concept:** `engineering.frontend.body-purity`
- **Modality:** `MUST NOT`
- **Scope:** SwiftUI body evaluation
- **Status:** `normative`
- **Verification:** `AUDIT-BODY-PURITY-001`
- **Supersedes:** none

SwiftUI `body` MUST NOT perform material sorting, recurrence, graph planning, file access, hashing, database queries, or network work.

## FRONTEND-008 — Semantic abstraction threshold
- **Concept:** `engineering.frontend.abstraction`
- **Modality:** `MUST`
- **Scope:** Shared abstractions
- **Status:** `normative`
- **Verification:** `REVIEW-ABSTRACTION-SEMANTICS-001`
- **Supersedes:** none

Shared abstraction MUST follow shared semantics, state, accessibility, and lifecycle rather than visual similarity alone.

## FRONTEND-009 — Preview matrix
- **Concept:** `engineering.frontend.preview-matrix`
- **Modality:** `MUST`
- **Scope:** Flagship surfaces and stable shared components
- **Status:** `normative`
- **Verification:** `PROOF-PREVIEW-MATRIX-001`
- **Supersedes:** none

Previews MUST cover representative empty, populated, dense, error/recovery, denied, offline/stale, long localized, light/dark, contrast, transparency, accessibility text, and supported-device states.

## FRONTEND-010 — Asset governance
- **Concept:** `engineering.frontend.assets`
- **Modality:** `MUST`
- **Scope:** Icons and images
- **Status:** `normative`
- **Verification:** `AUDIT-ASSET-GOVERNANCE-001`
- **Supersedes:** none

Semantically correct SF Symbols are preferred. Custom assets MUST define ownership, scaling, color space, accessibility, caching, and dark/OLED behavior; rasterized text is forbidden.

Asset governance MUST prefer SF Symbols where semantically correct.

Asset governance MUST use semantic SF Symbols or approved custom glyphs.

Assets MUST NOT use nonsemantic decorative icons.

Root icons MUST remain recognizable without labels and expose labels to accessibility/long press.

## DESIGN-001 — Semantic token hierarchy
- **Concept:** `engineering.design.tokens`
- **Modality:** `MUST`
- **Scope:** Production presentation source
- **Status:** `normative`
- **Verification:** `AUDIT-SEMANTIC-TOKENS-001`
- **Supersedes:** none

The design system MUST separate primitive from semantic tokens, and product source MUST consume semantic tokens outside token implementation.

Ambitions material MUST be restrained, layered, and semantic.

Materials MUST communicate hierarchy and state without fake glass, excessive borders, glow, decorative sci-fi HUD treatment, or web-card chrome.

## DESIGN-002 — Complete token domains
- **Concept:** `engineering.design.token-domains`
- **Modality:** `MUST`
- **Scope:** Design-system vocabulary
- **Status:** `normative`
- **Verification:** `AUDIT-TOKEN-DOMAINS-001`
- **Supersedes:** none

Tokens MUST cover color, typography, spacing, size, corners, borders, material, depth, motion, haptics, focus, status, and accessibility variants.

Canonical token domains MUST cover color, typography, spacing, sizing, corner treatment, border, material, depth and lighting, motion, haptics, focus, destructive, warning and success states, and accessibility variants.

## DESIGN-003 — Theme completeness
- **Concept:** `engineering.design.theme-completeness`
- **Modality:** `MUST`
- **Scope:** Every supported theme
- **Status:** `normative`
- **Verification:** `PROOF-THEME-MATRIX-001`
- **Supersedes:** none

Themes MUST preserve semantic meaning across light, dark, increased contrast, Reduce Transparency, and relevant accessibility mappings.

All themes MUST support OLED-dark, standard dark, light, and system appearance.

Custom and photo themes MUST receive local contrast treatment.

## DESIGN-004 — Token change control
- **Concept:** `engineering.design.change-control`
- **Modality:** `MUST`
- **Scope:** Semantic-token changes
- **Status:** `normative`
- **Verification:** `REVIEW-TOKEN-IMPACT-001`
- **Supersedes:** none

A semantic-token change MUST include impact inventory, screenshot coverage, relevant accessibility review, migration/deprecation, and rollback.

## DESIGN-005 — Ad hoc constant audit
- **Concept:** `engineering.design.constant-audit`
- **Modality:** `MUST`
- **Scope:** Production SwiftUI
- **Status:** `normative`
- **Verification:** `AUDIT-UI-CONSTANTS-001`
- **Supersedes:** none

Production source MUST NOT introduce local visual or interaction constants where an approved semantic token owns the meaning.

Production SwiftUI MUST be audited for unapproved local colors, font sizes, spacing, radius, shadows, materials, animations, and haptics when semantic tokens exist.

## DESIGN-006 — Component maturity
- **Concept:** `engineering.design.component-maturity`
- **Modality:** `MUST`
- **Scope:** Reusable design-system components
- **Status:** `normative`
- **Verification:** `AUDIT-COMPONENT-MATURITY-001`
- **Supersedes:** none

Component maturity MUST be explicit; Stable requires one owner, documentation, previews, accessibility, tests, screenshot baselines, and token compliance.

## DESIGN-007 — Positive visual targets
- **Concept:** `engineering.design.positive-target`
- **Modality:** `MUST`
- **Scope:** Flagship surfaces
- **Status:** `normative`
- **Verification:** `PROOF-POSITIVE-VISUAL-TARGET-001`
- **Supersedes:** none

Visual package, review, surface-specific geometry, hierarchy, viewport, and implementation-evidence behavior MUST remain in their exact child contracts; this aggregate MUST only coordinate those dependencies and their shared claim ceiling.

## STANDARD-TYPOGRAPHY-001 — Semantic typography and copy budget
- **Concept:** `standard.typography.copy-budget`
- **Modality:** `MUST`
- **Scope:** First viewports and shared components
- **Status:** `normative`
- **Verification:** `PROOF-TYPOGRAPHY-COPY-BUDGET-001`
- **Supersedes:** none

Typography MUST use semantic roles, reflow at accessibility sizes, preserve hierarchy without fixed-height clipping, and keep first-viewport copy within the owning surface's approved information budget.

Typography review MUST fail when screenshot or direct Figma inspection shows a semantic typography violation.

## STANDARD-SPACING-CORNERS-001 — Semantic rhythm
- **Concept:** `standard.spacing-corners.semantic-rhythm`
- **Modality:** `MUST`
- **Scope:** Spacing and corner treatment
- **Status:** `normative`
- **Verification:** `PROOF-SEMANTIC-RHYTHM-001`
- **Supersedes:** none

Spacing and corner treatment MUST express grouping, containment, hierarchy, and action semantics through approved tokens rather than decorative inconsistency.

## STD-INTERACTION-NATIVE-EQUIVALENCE-001 — Native interaction equivalence
- **Concept:** `standard.interaction.native-equivalence`
- **Modality:** `MUST`
- **Scope:** Tap, long press, swipe, keyboard/focus, dismissal, haptics, and motion
- **Status:** `normative`
- **Verification:** `TEST-INTERACTION-EQUIVALENCE-001`
- **Supersedes:** none

Native interaction equivalence MUST be implemented through the separate tap, long-press, swipe, drag, focus, dismissal, keyboard, reduced-effects, and state-continuity contracts without collapsing independently verifiable behavior.

## STANDARD-VISUAL-PACKAGE-001 — Visual package readiness

- **Concept:** `standard.visual.package-readiness`
- **Modality:** `MUST`
- **Scope:** Approved visual packages
- **Status:** `normative`
- **Verification:** `REVIEW-VISUAL-PACKAGE-001`
- **Supersedes:** none

A visual package MUST bind stable external identity, coverage, states, accessibility variants, critique, reviewer, and disposition before it can govern a scoped visual target.

## STANDARD-VISUAL-REVIEW-001 — Independent visual review

- **Concept:** `standard.visual.independent-review`
- **Modality:** `MUST`
- **Scope:** Visual review
- **Status:** `normative`
- **Verification:** `REVIEW-VISUAL-INDEPENDENT-001`
- **Supersedes:** none

Visual review MUST compare current rendered evidence with approved authority and record independent findings and the exact claim ceiling.

## STD-INTERACTION-TAP-001 — Tap equivalence

- **Concept:** `standard.interaction.tap`
- **Modality:** `MUST`
- **Scope:** Tap actions
- **Status:** `normative`
- **Verification:** `A11Y-INTERACTION-TAP-001`
- **Supersedes:** none

Every tap action MUST have a named semantic control, deterministic result, and accessible focus outcome.

## STD-INTERACTION-LONG-PRESS-001 — Long-press equivalence

- **Concept:** `standard.interaction.long-press`
- **Modality:** `MUST`
- **Scope:** Long-press actions
- **Status:** `normative`
- **Verification:** `A11Y-INTERACTION-LONG-PRESS-001`
- **Supersedes:** none

Long-press actions MUST have an explicit discoverable and accessibility-equivalent alternative.

## STD-INTERACTION-SWIPE-001 — Swipe equivalence

- **Concept:** `standard.interaction.swipe`
- **Modality:** `MUST`
- **Scope:** Swipe actions
- **Status:** `normative`
- **Verification:** `A11Y-INTERACTION-SWIPE-001`
- **Supersedes:** none

Swipe actions MUST have visible or custom-action equivalents with the same validation, consequence, and recovery.

## STD-INTERACTION-DRAG-001 — Drag equivalence

- **Concept:** `standard.interaction.drag`
- **Modality:** `MUST`
- **Scope:** Drag and resize
- **Status:** `normative`
- **Verification:** `A11Y-INTERACTION-DRAG-001`
- **Supersedes:** none

Drag and resize MUST have typed named-edit alternatives with equivalent preview, confirmation, conflict handling, and Receipt behavior.

## STD-INTERACTION-FOCUS-001 — Focus continuity

- **Concept:** `standard.interaction.focus`
- **Modality:** `MUST`
- **Scope:** Focus-based interaction
- **Status:** `normative`
- **Verification:** `A11Y-INTERACTION-FOCUS-001`
- **Supersedes:** none

Focus-driven interaction MUST preserve semantic order, selection, announcement, and return context across presentation changes.

## STD-INTERACTION-DISMISSAL-001 — Dismissal continuity

- **Concept:** `standard.interaction.dismissal`
- **Modality:** `MUST`
- **Scope:** Sheet and overlay dismissal
- **Status:** `normative`
- **Verification:** `A11Y-INTERACTION-DISMISSAL-001`
- **Supersedes:** none

Dismissal MUST preserve validated user intent, restore the originating context and focus, and never report an uncommitted action as durable.

## Completeness contract

<!-- canon-section: purpose -->
Define reusable SwiftUI, component, token, asset, and interaction engineering law.
<!-- canon-section: scope -->
Applies cross-cutting presentation-wide; exact surface/object/journey behavior and visual node authority remain with their owners.
<!-- canon-section: requirements -->
The requirements consolidate useful Articles 29–30 and accepted cross-cutting v3 presentation standards.
<!-- canon-section: exceptions -->
Custom rendering or interaction requires an explicit owner, native-alternative analysis, accessibility and performance proof, failure behavior, removal plan, and amendment.
<!-- canon-section: verification -->
Verify with static audits, previews, interaction tests, screenshot matrices, accessibility matrices, and independent target-versus-actual review.
<!-- canon-section: source-ownership -->
Target owners are `DesignSystem/`, `Interaction/`, `Rendering/`, thin `Stage/`, exact surface owners, and `Quality/`.
<!-- canon-section: proof -->
This file is not Visual Green, accessibility proof, device proof, or implementation parity.
<!-- canon-section: amendment-impact -->
Amendments list affected tokens, components, surfaces, visuals, accessibility states, tests, performance, source owners, migrations, proof, claim ceiling, and rollback.
