> Supporting note: This file supports Ambitions primitive-invention governance. It does not override `docs/truth/*`, live source, current validation logs, or release proof.

# Ambitions Primitive Invention Registry

Status: Active supporting governance
Scope: New visual, interaction, layout, motion, accessibility, and proof primitives proposed after the Active Runtime UI Reconstruction train
Owner posture: Registry template, not implementation proof

## Purpose

This registry prevents Codex or human contributors from inventing parallel UI primitives when an existing Ambitions primitive or canonical owner should be extended.

Every proposed primitive must answer:

- Which active product object needs this primitive?
- Which existing primitive was inspected first?
- Why extension is insufficient?
- Which top-level surface owns the first use?
- What accessibility fallback ships with it?
- What proof artifact will make the primitive inspectable?

## Registry Template

Use this table for every proposed primitive before source work begins.

| Field | Required entry |
|---|---|
| Primitive ID | Stable short name, for example `reality-meridian-source-band` |
| Status | Proposed, approved for prototype, promoted, rejected, retired |
| Owner surface | Today, Goals, Time, Motion, You, or Global Capture |
| Product object | Reality Meridian, Direction Atlas, LifeShape Field, Motion Current, Personal Runtime, Atmosphere Composer, or named drill-down object |
| Existing owners inspected | Source paths and docs consulted before invention |
| Missing capability | Concrete gap that cannot be solved by extending an existing primitive |
| Anti-card reason | Why this avoids a top-level pile-of-panels or generic metric-board pattern |
| Runtime path | SourceRecord, Receipt, ReplayTrace, or You inspection connection |
| Accessibility fallback | VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, Differentiate Without Color, tap-target handling |
| Proof artifact | Screenshot, focused test, source audit, manual note, or report path required for promotion |
| Promotion issue | Linear issue ID that may promote it beyond prototype |
| Rollback path | Exact source/docs paths to revert if the primitive fails gates |

## Current Registry

| Primitive ID | Status | Owner surface | Product object | Promotion issue | Notes |
|---|---|---|---|---|---|
| surface-object-frame | Proposed | Global | Surface primary object | AMB-607 | Replaces active AppCard/HeroCard/root panel-pile structures recorded by AMB-566. |
| proof-receipt-lane | Proposed | Today / Goals / Motion | Receipt / proof path | AMB-607 | Replaces repeated proof/status panels, chips, and section clusters recorded by AMB-566. |
| life-shape-control-band | Proposed | Time | LifeShape Field | AMB-607 | Replaces Time day-card, contour button, material row, and local rounded-geometry structures recorded by AMB-566. |
| motion-current-thread | Proposed | Motion | Motion Current | AMB-607 | Replaces Motion node-card/list structures when they behave like generic containers instead of proof/re-entry paths. |
| personal-runtime-group | Proposed | You | Personal Runtime | AMB-607 | Replaces repeated You detail cards, local rounded overlays, grouped panel clusters, and settings-adjacent containers recorded by AMB-566. |
| capture-route-ribbon | Proposed | Global Capture | Atmosphere Composer | AMB-607 | Replaces Capture route cards and draft-route local containers with a route-reveal/correction primitive. |
| source-trust-strip | Proposed | Global | Source / Trust Seam | AMB-607 | Replaces repeated chip/pill/source rows with an inline source/trust inspection primitive. |
| accessibility-fallback-contract | Proposed | Global | Primitive accessibility fallback | AMB-570 | Shared Dynamic Type, Reduce Motion, Reduce Transparency, and Increase Contrast fallback contract for new primitives. |
| today-object-stage | Promoted | Today | Reality Meridian / Start Here | AMB-572 | Replaces Today first-viewport panel, tile, chip, and source-strip chrome with a full-bleed object stage and inline source/trust relationship. |

## Primitive Semantic Token Extensions

| Token ID | Installed primitive | Behavior use | Accessibility / contrast implication | Issue |
|---|---|---|---|---|
| `primitive.source` | `SourceTrustReceiptStrip` | Current source and freshness labels. | Paired with source text and symbol labels; color is not the only state channel. | AMB-571 |
| `primitive.sourceAttention` | `SourceTrustReceiptStrip` | Source states that require attention before reuse. | Paired with stale or blocked labels and role symbols. | AMB-571 |
| `primitive.privacyBoundary` | `SourceTrustReceiptStrip` | Private or protected trust boundary labels. | Paired with privacy/trust copy and lock or shield symbols. | AMB-571 |
| `primitive.receipt` | `SourceTrustReceiptStrip` | Receipt path and proof-available labels. | Paired with receipt copy and document symbols. | AMB-571 |
| `primitive.accessibilityFallbackSurface` | `AmbitionsPrimitiveAccessibilityFallbackModifier` | Opaque primitive surface when Reduce Transparency is active. | Preserves contrast when transparency is reduced. | AMB-571 |
| `primitive.accessibilityContrastStroke` | `AmbitionsPrimitiveAccessibilityFallbackModifier` | Explicit primitive border when Increase Contrast is active. | Strengthens boundaries for increased contrast without adding a new surface. | AMB-571 |

## Seeded Primitive Entries From AMB-566

### surface-object-frame

Replaces:

- Active AppCard/HeroCard/root panel-pile structures in Today, Goals, Time, You, Capture, Insights, and LaunchGate paths recorded by AMB-566.

Not a card because:

- It must wrap a named Ambitions product object, not a detached content block.
- It must expose source, receipt, or runtime inspection seams when the object makes a recommendation or proof claim.
- It cannot be stacked as equal-weight root modules.

Accessibility:

- VoiceOver names the object and primary state before supporting metadata.
- Dynamic Type keeps the object title, primary action, and trust path before secondary detail.
- Reduce Motion and Increase Contrast fallbacks must preserve object boundaries without motion-only or low-contrast meaning.
- Tap targets must meet the 44 pt minimum.

Rollback:

- Remove the registry row and any source introduced under AMB-607 or later promotion issues.
- Revert to existing source paths listed in the AMB-566 raw scan artifacts.

### proof-receipt-lane

Replaces:

- Repeated proof/status panels, receipt chips, section clusters, and status rows in Today, Goals, Motion, and shared component paths recorded by AMB-566.

Not a card because:

- It is a horizontal or inline proof relationship, not an isolated status block.
- It connects proof, receipt, source, and recovery state to an owning product object.
- It cannot present progress as a generic metric tile.

Accessibility:

- VoiceOver reads proof source, state, and available receipt action in order.
- Dynamic Type may wrap into rows but must preserve proof/source/action order.
- Reduce Motion fallback uses static state text.
- Differentiate Without Color must expose state through text or symbols.

Rollback:

- Remove the registry row and any promoted proof lane source.
- Restore prior proof/status source only through the owning issue rollback.

### life-shape-control-band

Replaces:

- Time day-card, contour button, material row, rounded-geometry, and root-stack structures recorded by AMB-566.

Not a card because:

- It represents LifeShape Field control and capacity state, not a detached day or schedule block.
- It must show availability, protected time, pressure, or shaping action as one Time object relationship.
- It cannot collapse Time into a calendar-copy layout.

Accessibility:

- VoiceOver names horizon, protected/open time, pressure, and shaping action.
- Dynamic Type preserves the selected horizon and primary shaping action.
- Reduce Motion fallback uses static before/after state.
- Increase Contrast strengthens boundaries around selected state.

Rollback:

- Remove the registry row and any Time primitive source introduced by the promotion issue.
- Restore previous Time source only through the scoped rollback path.

### motion-current-thread

Replaces:

- Motion node-card/list structures and shadowed proof containers recorded by AMB-566 when they behave like generic containers.

Not a card because:

- It represents proof movement, recovery, re-entry, and inspection continuity.
- It is ordered by user-owned progress/recovery relationship, not by generic activity grouping.
- It avoids points, reward-counter, and productivity-recap framing.

Accessibility:

- VoiceOver names current proof state, source, recovery, and re-entry action.
- Dynamic Type preserves proof state and re-entry before supporting detail.
- Reduce Motion fallback uses static progression labels.
- Increase Contrast avoids glow-only or color-only state.

Rollback:

- Remove the registry row and any Motion primitive source introduced by the promotion issue.
- Restore prior Motion source only through owner-approved rollback.

### personal-runtime-group

Replaces:

- Repeated You detail cards, local rounded overlays, grouped panel clusters, and settings-adjacent containers recorded by AMB-566.

Not a card because:

- It is a grouped Personal Runtime governance control, not a marketing-style block or equal-weight content panel.
- It must connect what Ambitions knows, reset/delete controls, receipts, defaults, and trust settings.
- It uses native grouped navigation behavior where appropriate.

Accessibility:

- VoiceOver names group purpose, current state, and available controls.
- Dynamic Type preserves grouped navigation order.
- Reduce Motion uses native disclosure state rather than motion-only meaning.
- Tap targets must remain reachable in grouped rows.

Rollback:

- Remove the registry row and any You primitive source introduced by the promotion issue.
- Restore prior You source only through scoped rollback.

### capture-route-ribbon

Replaces:

- Capture route cards, draft-route local containers, route preview panels, and correction-control clusters recorded by AMB-566.

Not a card because:

- It is an activated route-reveal and correction primitive inside the Atmosphere Composer flow.
- It connects input, route reason, uncertainty, correction, and receipt behavior.
- It is not a persistent global utility or standalone intake block.

Accessibility:

- VoiceOver names input purpose, suggested route, reason, uncertainty, correction choices, and save action.
- Dynamic Type keeps route reason and correction choices before secondary metadata.
- Reduce Motion fallback avoids animated-only route reveal.
- Keyboard path must reach correction and save actions.

Rollback:

- Remove the registry row and any Capture route primitive source introduced by the promotion issue.
- Restore prior Capture route source only through scoped rollback.

### source-trust-strip

Replaces:

- Repeated chip/pill/source rows and trust labels recorded by AMB-566 when they duplicate source/trust behavior across surfaces.

Not a card because:

- It is an inline inspection seam attached to an owning object.
- It exposes source, receipt, replay, or You inspection affordances without creating a separate block.
- It remains compact and subordinate to the primary object.

Accessibility:

- VoiceOver reads source label, freshness state, receipt availability, and inspection action.
- Dynamic Type can wrap but must keep source and action paired.
- Reduce Motion has no motion-only meaning.
- Differentiate Without Color exposes freshness/state through labels.

Rollback:

- Remove the registry row and any shared source/trust primitive source introduced by the promotion issue.
- Revert surface-specific usage through the owning issue rollback.

### accessibility-fallback-contract

Replaces:

- One-off fallback notes or implicit accessibility behavior inside new primitive source.
- Generic workaround UI that does not name Dynamic Type, Reduce Motion, Reduce Transparency, and Increase Contrast behavior.

Not a card because:

- It is a primitive contract and modifier attached to the owning primitive, not a visible container or standalone panel.
- It records fallback behavior for the primary object that already owns the interface.
- It stays attached to the owning primitive instead of creating a separate review surface.

Accessibility:

- VoiceOver receives a deterministic hint from the active fallback profile.
- Dynamic Type can add spacing and preserve source/object/action order.
- Reduce Motion disables animation transactions for the primitive scope.
- Reduce Transparency can replace translucent material with an opaque semantic fill.
- Increase Contrast can strengthen explicit borders and text/symbol meaning.
- Differentiate Without Color remains the owning primitive's responsibility through text and symbol labels.

Rollback:

- Remove the registry row and AMB-570 source/test additions.
- Remove `AmbitionsPrimitiveAccessibilityFallbackProfile` usage from any later primitive that adopts it, or revert the adopting issue.

### today-object-stage

Replaces:

- Today first-viewport time-band panel, topology tile grid, fit/duration capsules, and source/trust strip item chrome recorded by the AMB-572 object-stage pass.

Not a card because:

- It is the Reality Meridian / Start Here product object itself, not a detached content block.
- Source, freshness, receipt, and privacy are rendered as an inline relationship attached to Start Here.
- The first viewport keeps one primary execution object with a time spine and primary action instead of stacking equal-weight panels.

Accessibility:

- VoiceOver reads Reality Meridian, Start here, source, freshness, receipt, privacy, and the primary action in order.
- Dynamic Type stacks the source/trust line without changing source, receipt, or action order.
- Reduce Motion keeps the current-time relation static and avoids motion-only meaning.
- Increase Contrast and Differentiate Without Color use text and symbols rather than filled mini-containers as the only state channel.

Proof artifact:

- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-572-today-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-object-stage-amb-572.png`

Rollback:

- Revert the AMB-572 commit to restore the prior Today first-viewport source strip and local capsule treatment.
- Remove the AMB-572 report and screenshot artifact if only the proof packet needs rollback.

## Non-Negotiable Checks

- Do not create a primitive because a screen looks plain.
- Do not create a new owner when an existing primitive can be extended.
- Do not use decorative celestial, gradient, glass, particle, or card-like structure as the reason to invent.
- Do not bypass `docs/truth/PRODUCT_DESIGN_TRUTH.md` one-primary-object discipline.
- Do not claim a primitive is promoted until proof exists and the promotion protocol passes.

## Required Closeout For Primitive Proposals

Any primitive proposal issue must close with:

- Existing owners inspected
- Proposed owner path
- Accessibility fallback
- Proof artifact path
- Promotion status
- Rollback note
- No-readiness-claim boundary
