<!-- markdownlint-disable MD013 -->

# SwiftUI Primitive Contracts

Status: Active Codex execution-excellence contract  
Date updated: 2026-05-10  
Authority: Subordinate to `docs/truth/*` and live source

This file maps Ambitions SwiftUI primitives to validation expectations. It is
not source proof and does not approve refactors or new app behavior.

## 1. Primitive Contract Rule

Before Codex changes a SwiftUI surface, it must identify the primary object
and primitive contract. A primitive is not complete because it renders once; it
must preserve state, source, interaction, accessibility, motion, and proof
behavior appropriate to its role.

## 2. Primitive Table

| Primitive | Responsibility | Required states | Accessibility obligations | Preview/test expectation | Visual proof |
| --- | --- | --- | --- | --- | --- |
| Reality Meridian | Today current-state spine and orientation | empty, normal, pressure, waiting, blocked, recovery, receipt | semantic day summary, non-color-only state, reachable primary action | state fixtures and focused tests for projection when source changes | screenshot for normal plus disrupted state when UI changes |
| Start Here Surface | single grounded next action | available, unavailable, low confidence, source stale, recovery | clear action label, reason/source path, Dynamic Type fit | preview fixtures and copy scan | screenshot before claim of visual quality |
| Constellation Atlas | Goals direction and equal-weight relationship view | empty, populated, filtered, detail selected, proof present | grouped goal summaries, no visual-only node meaning | source/test evidence for relationship changes | screenshot if layout or state changes |
| Atmosphere Composer | Capture intake and route reveal | empty input, draft, classified, needs place, placed, failed safely | keyboard/VoiceOver path, non-shaming fallback | input/routing tests when behavior changes | screenshot if composer layout changes |
| LifeShape Field | Time capacity and horizon state | day/week/month/year, open, protected, pressure, stale source | readable horizon control, Reduce Motion equivalent, no color-only capacity | projection tests and fixtures when source changes | screenshot for touched horizon/state |
| User System Profile | You controls, trust, defaults, privacy | default, edited, disabled, reset, export/import where scoped | grouped controls, clear destructive affordances, touch targets | tests for control semantics when source changes | screenshot when layout changes |
| Trust Seam | why/source/control explanation | source available, source missing, user override, automation blocked | source label, reason, control, reset/disable path | source and copy checks | screenshot only when visual seam changes |
| Receipt Surface | proof of meaningful action | created, archived, superseded, unavailable | receipt summary and timestamp/source semantics | receipt tests when behavior changes | screenshot when visual receipt changes |
| Continuity Dock / Context Crown | persistent context and return path | active, inactive, stale, interrupted | no badge-only meaning, reachable return path | navigation tests when source changes | screenshot when shell context changes |

## 3. File Responsibility Expectations

SwiftUI patches must state:

- owner feature path
- shared component path if any
- domain/service model dependency
- preview fixture path if any
- test path if any
- compatibility seam touched, if any

If a primitive lacks fixtures or tests, Codex must report that as a gap rather
than claiming completion.

## 4. Preview Requirements

Preview-backed evidence should include:

- at least one happy path
- at least one non-ideal state
- Dynamic Type or size-class stress when layout is touched
- Reduce Motion note when motion is touched

Preview rendering is supporting evidence only. It does not prove runtime
behavior, simulator behavior, or release readiness.

## 5. State Contract Requirements

Every primary primitive must preserve:

- loading/empty state
- source unavailable or stale state when data depends on a source
- blocked/waiting/recovery state when action can be interrupted
- receipt/proof state when action changes user data
- no fake certainty when recommendation or fit is uncertain

## 6. Accessibility Contract Requirements

Every primitive change must check:

- VoiceOver summary and order
- Dynamic Type clipping
- Reduce Motion equivalent
- touch target size
- visible focus/selection affordance
- no color-only meaning
- non-shaming copy

## 7. Red Conditions

Stop if:

- a primary object becomes a generic card stack
- a gesture is required with no visible alternative
- visual state has no nonvisual equivalent
- compatibility names are promoted to active user-facing IA
- source changes lack owner files/tests/rollback

## 8. Phase 4 Gate Result

Phase 4 result: Green.

Validation:

- docs-only primitive contract artifact
- no SwiftUI/source files touched
- no visual, accessibility, performance, or runtime proof claimed

