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
| personal-runtime-group | Promoted | You | Personal Runtime / User System Profile | AMB-576 | Replaces detached You profile hero, generic settings wall, operator-style root overview, rounded per-row card stack, and stale unreachable generic containers with the You object-stage/control group. |
| capture-route-ribbon | Promoted | Global Capture | Atmosphere Composer | AMB-577 | Replaces Capture route cards, composer panels, category-like capture buckets, first-run card shell, and draft-route local containers with an Atmosphere Composer stage primitive. |
| closure-recovery-family | Promoted | Global action-state | Closure / Recovery | AMB-578 | Replaces active generic closure panels, recovery panels, rounded recovery cards, closure outcome cards, receipt preview cards, and closure tray chrome with shared Closure / Recovery line-stage primitives. |
| quiet-reflow-family | Promoted | Global action-state | Quiet Reflow / Receipt | AMB-579 | Replaces active generic reflow panels, rounded reflow option cards, before-after preview cards, impact preview cards, and receipt preview cards with shared Quiet Reflow line-stage primitives. |
| capture-routing-family | Promoted | Global Capture | Capture Routing / Receipt | AMB-580 | Replaces activated Capture routing panels, route category grids, route proof pills, rounded route option cards, unsupported certainty labels, and chat-transcript-like shells with shared Capture Routing line-stage primitives. |
| source-trust-strip | Proposed | Global | Source / Trust Seam | AMB-607 | Replaces repeated chip/pill/source rows with an inline source/trust inspection primitive. |
| accessibility-fallback-contract | Proposed | Global | Primitive accessibility fallback | AMB-570 | Shared Dynamic Type, Reduce Motion, Reduce Transparency, and Increase Contrast fallback contract for new primitives. |
| today-object-stage | Promoted | Today | Reality Meridian / Start Here | AMB-572 | Replaces Today first-viewport panel, tile, chip, and source-strip chrome with a full-bleed object stage and inline source/trust relationship. |
| time-object-stage | Promoted | Time | LifeShape Field | AMB-573 | Replaces active Time horizon chip, rounded canvas, capacity panel, source pill, and reflow panel chrome with a full-bleed LifeShape object stage. |
| horizon-capacity-family | Promoted | Time | Horizon / Capacity | AMB-581 | Replaces active Time horizon chip controls, capacity statement panel, source/receipt pills, and continuity pills with shared Horizon / Capacity line-stage primitives; dormant card helpers remain unreachable from the active Time body. |
| proof-relationship-trace-family | Promoted | Today / Goals / Motion | Proof / Relationship / Trace | AMB-582 | Replaces active Motion trace chips, Motion source/proof/receipt rows, Goals review-trail cards, and Goals receipt cards with shared Proof / Relationship / Trace line-stage primitives; Today proof rows already use the closure/recovery primitive family. |
| motion-object-stage | Promoted | Motion | Motion Current | AMB-574 | Replaces active Motion field panel, lane cards, state-row panels, trace pills, and source/proof/receipt panel chrome with a full-bleed Motion Current object stage. |
| goals-object-stage | Promoted | Goals | Direction Atlas / Constellation Atlas | AMB-575 | Replaces active Goals equal-weight area band, Atlas container, relationship field shell, Orbital Lens container, lane blocks, and source/proof/trust block chrome with a full-bleed Direction Atlas object stage. |

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

- Detached You profile hero, generic settings wall, operator-style root overview, rounded per-row card stack, and stale unreachable generic containers recorded by AMB-566 and AMB-576.
- Catch-all You section wrappers that behave like generic settings containers instead of semantic runtime controls.

Not a card because:

- It is the You object-stage/control primitive for Personal Runtime / User System Profile, not a marketing-style block or equal-weight content panel.
- It connects planning setup, runtime preferences, local context controls, receipts, defaults, privacy, and trust settings in grouped native control order.
- It uses line-based grouped navigation and semantic control groups where appropriate instead of rounded root-row cards.

Accessibility:

- VoiceOver names object, group purpose, current state, and available controls in grouped order.
- Dynamic Type preserves grouped navigation order and stacks row title/status/detail before supporting content.
- Reduce Motion uses native disclosure and route-haptic state rather than motion-only meaning.
- Increase Contrast and Differentiate Without Color use line, symbol, and status text in addition to accent color.

Proof artifact:

- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-576-you-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/you-object-stage-amb-576.png`

Rollback:

- Revert the AMB-576 commit to restore prior You root row-card chrome, generic catch-all section wrapper, stale unreachable generic containers, and pre-primitive contract state.
- Remove the AMB-576 report and screenshot artifact if only the proof packet needs rollback.

### capture-route-ribbon

Replaces:

- Capture route cards, composer panels, category-like capture buckets, first-run card shell, draft-route local containers, route preview panels, and correction-control clusters recorded by AMB-566 and AMB-577.

Not a card because:

- It is the activated Atmosphere Composer object stage for Global Capture.
- It connects input, route reason, uncertainty, correction, receipt behavior, and continuity lines.
- It keeps Capture as a global action and does not become a persistent utility, standalone intake block, message-first shell, raw activity stream, or classification board.

Accessibility:

- VoiceOver names input, suggested route, consequence, privacy, receipt, correction choices, and save action in stage order.
- Dynamic Type stacks route controls before supporting route evidence.
- Reduce Motion uses static route-reveal state rather than motion-only meaning.
- Increase Contrast and Differentiate Without Color use line, symbol, and text labels in addition to accent color.
- Keyboard path must reach correction and save actions.

Proof artifact:

- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-577-capture-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/capture-object-stage-amb-577.png`

Rollback:

- Revert the AMB-577 commit to restore prior Capture route cards, composer panels, category-like capture buckets, first-run card shell, draft-route local containers, and registry state.
- Remove the AMB-577 report and screenshot artifact if only the proof packet needs rollback.

### capture-routing-family

Replaces:

- Activated Capture routing panels, state overview route grid, route proof pills, rounded route option detail cards, correction option grid, unsupported certainty labels, and chat-transcript-like shells in the global Capture seam.

Not a card because:

- It is the action-state primitive family for Capture routing, not a detached category picker or transcript.
- Input source, deterministic route basis, review state, correction control, receipt path, and no-silent-placement boundary remain in one line-stage order before saving.
- It keeps Capture as a global Atmosphere Composer action and preserves local correction instead of presenting route selection as classifier confidence.

Accessibility:

- VoiceOver reads deterministic route basis, selected route, correction options, receipt path, and no-silent-placement boundary before save actions.
- Dynamic Type stacks source, route basis, review state, correction, receipt, and no-silent-placement lines in order.
- Reduce Motion keeps route meaning in static labels.
- Increase Contrast and Differentiate Without Color use line strength, symbols, and explicit text rather than card fill or color alone.

Proof artifact:

- `artifacts/ambitions-ui-reconstruction/action-state/AMB-580-capture-routing-family.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/capture-routing-family-amb-580.png`

Rollback:

- Revert the AMB-580 commit to restore prior activated Capture seam route proof strip, placement review, correction fold, state overview, registry state, concept-lock prefixes, and focused test coverage.
- Remove the AMB-580 report and screenshot artifact if only the proof packet needs rollback.

### closure-recovery-family

Replaces:

- Active generic closure panels, recovery panels, rounded recovery cards, closure outcome cards, receipt preview cards, and closure tray chrome recorded by AMB-566 and AMB-578.
- Today closure sheet containers that present closure outcomes, recovery prompt, and receipt preview as generic panels instead of action-state stages.
- Recovery summary wrappers in Today, Habits, shared recovery panel usage, and recovery tide strips that behave like generic cards.

Not a card because:

- It is the action-state primitive family for Closure and Recovery, not a decorative panel shell.
- It orders context, outcome meaning, recovery consequence, receipt preview, and no-silent-mutation boundaries in line-stage sequence.
- It keeps closure/recovery language non-punitive and recovery-aware instead of turning outcomes into celebration, metric, chain, or shame pressure.

Accessibility:

- VoiceOver names closure, recovery, receipt, and no-silent-change state in action order.
- Dynamic Type stacks action-state lines instead of depending on fixed card grids.
- Reduce Motion uses static labels and symbols rather than animated-only state.
- Increase Contrast and Differentiate Without Color use line strength, symbol, and explicit text in addition to accent color.

Proof artifact:

- `artifacts/ambitions-ui-reconstruction/action-state/AMB-578-closure-recovery-family.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/closure-recovery-family-amb-578.png`

Rollback:

- Revert the AMB-578 commit to restore prior generic closure panels, recovery panels, rounded recovery cards, closure outcome cards, receipt preview cards, closure tray chrome, and registry state.
- Remove the AMB-578 report and screenshot artifact if only the proof packet needs rollback.

### quiet-reflow-family

Replaces:

- Active Time reflow decision panel, reflow option card rows, before/after preview card, Time root reflow trust seam, Today replacement original recommendation card, Today replacement alternative cards, impact preview card, and receipt preview card.

Not a card because:

- It is the preview-before-commit action-state path for Quiet Reflow, not a detached scheduling module.
- Current state, proposed state, source, reason, user control, manual fallback, and receipt preview remain in a single line-stage order before any approval.
- The user-owned confirmation path stays explicit; the primitive does not authorize hidden schedule mutation or calendar writes.

Accessibility:

- VoiceOver reads preview, option, source, reason, control, receipt, and available actions in order.
- Dynamic Type stacks current state, proposed state, source, control, and receipt without changing meaning.
- Reduce Motion keeps before/after labels static.
- Increase Contrast and Differentiate Without Color use line strength, symbols, and explicit text rather than card fill as the only state channel.

Proof artifact:

- `artifacts/ambitions-ui-reconstruction/action-state/AMB-579-quiet-reflow-family.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/quiet-reflow-family-amb-579.png`

Rollback:

- Revert the AMB-579 commit to restore prior Time reflow decision panel treatment, Time root reflow seam treatment, Today replacement local containers, registry state, concept-lock prefixes, and focused test coverage.
- Remove the AMB-579 report and screenshot artifact if only the proof packet needs rollback.

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

### time-object-stage

Replaces:

- Active Time first-viewport horizon chip strip, rounded LifeShape canvas panel, capacity statement panel, source/receipt pills, continuity pills, and reflow preview panel chrome.
- Unreachable legacy Time contour button and selected contour panel helpers that retained stale rounded card geometry.

Not a card because:

- It is the LifeShape Field product object itself, not a calendar block, detached panel, or schedule module.
- Horizon selection is an inline field control attached to the object texture.
- Capacity, source, reason, receipt, and privacy are rendered as object-stage lines rather than separate cards or status pills.

Accessibility:

- VoiceOver reads LifeShape Field, horizon, capacity, source, reason, receipt, privacy, and available reflow actions in order.
- Dynamic Type stacks horizon/source relationships without changing object order.
- Reduce Motion keeps pressure texture static and text-labeled.
- Increase Contrast and Differentiate Without Color use line strength, text, and symbols rather than card fill as the only state channel.

Proof artifact:

- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-573-time-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/time-object-stage-amb-573.png`

Rollback:

- Revert the AMB-573 commit to restore prior Time first-viewport horizon chips, rounded LifeShape canvas, source/receipt pills, and reflow panel treatment.
- Remove the AMB-573 report and screenshot artifact if only the proof packet needs rollback.

### horizon-capacity-family

Replaces:

- Active Time LifeShape Field horizon chip controls, capacity statement panel, source/receipt pills, and continuity pills.
- Dormant `TimeLifeSuiteCard` and `TimeCapacityEnvelopeCard` card helpers remain unreachable from the active `TimeScreen` body; no broader dormant cleanup is needed for this issue.

Not a card because:

- It is the relationship primitive family for Time horizon and capacity, not a detached schedule module or root tab strip.
- Horizon, capacity fit, protected/open time relationship, source, receipt, continuity, and no-root-navigation boundaries stay in line-stage order.
- It keeps horizon controls subordinate to LifeShape Field and does not present Day, Week, or Month as root destinations.

Accessibility:

- VoiceOver reads selected horizon, capacity statement, source, receipt, continuity, and no-root-navigation boundary in order.
- Dynamic Type stacks horizon, capacity, source, receipt, and continuity lines without changing meaning.
- Reduce Motion keeps selected horizon and capacity fit in static labels.
- Increase Contrast and Differentiate Without Color use line strength, symbols, and explicit text rather than chip fill as the only state channel.

Proof artifact:

- `artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-581-horizon-capacity-family.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/horizon-capacity-family-amb-581.png`

Rollback:

- Revert the AMB-581 commit to restore prior Time LifeShape Field horizon controls, capacity statement, source/receipt row, continuity dock, registry state, concept-lock prefixes, and focused test coverage.
- Remove the AMB-581 report and screenshot artifact if only the proof packet needs rollback.

### proof-relationship-trace-family

Replaces:

- Active Motion Current trace chips, source/proof/receipt field rows, lane trace datum rows, and source/proof/receipt inspection panel.
- Active Goals Mission Control review-trail cards and receipt cards.
- Today proof rows inspected for AMB-582 already use closure/recovery primitives, so no additional Today source replacement was needed.

Not a card because:

- It is an inspectable proof and relationship path, not a decorative proof badge or detached receipt block.
- Source, relationship, proof, receipt, replay trace, and user inspection stay in a single line-stage order.
- Proof remains tied to the local source and receipt path before state changes can be interpreted.

Accessibility:

- VoiceOver reads source, relationship, proof, receipt, replay trace, and user inspection in order.
- Dynamic Type stacks proof and trace lines instead of restoring fixed cards or horizontal chip clusters.
- Reduce Motion uses static symbols and labels rather than animated trace-only state.
- Increase Contrast and Differentiate Without Color use line strength, symbols, and explicit text rather than fill color alone.

Proof artifact:

- `artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-582-proof-relationship-trace-family.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/proof-relationship-trace-family-amb-582.png`

Rollback:

- Revert the AMB-582 commit to restore prior Motion trace chips, Motion source/proof/receipt rows, Goals review-trail cards, Goals receipt cards, registry state, concept-lock prefixes, and focused test coverage.
- Remove the AMB-582 report and screenshot artifact if only the proof packet needs rollback.

### motion-object-stage

Replaces:

- Active Motion first-viewport Motion Current field panel, lane cards, lane state-row panels, trace pills, and source/proof/receipt panel chrome.

Not a card because:

- It is the Motion Current product object itself, not a detached generic status block.
- Proof, recovery, re-entry, source, proof, and receipt are rendered as connected current lines rather than stacked lane cards.
- The first viewport keeps Motion as an inspectable current instead of a generic list.

Accessibility:

- VoiceOver reads Motion Current, proof, recovery, re-entry, source, proof, receipt, and available continuity actions in order.
- Dynamic Type preserves lane title, state, and trace values without restoring row panels.
- Reduce Motion uses static proof-thread marks.
- Increase Contrast and Differentiate Without Color use line strength, text, and symbols rather than card fill as the only state channel.

Proof artifact:

- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-574-motion-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/motion-object-stage-amb-574.png`

Rollback:

- Revert the AMB-574 commit to restore prior Motion field panel, lane cards, lane state-row panels, trace pills, and source/proof/receipt panel treatment.
- Remove the AMB-574 report and screenshot artifact if only the proof packet needs rollback.

### goals-object-stage

Replaces:

- Active Goals first-viewport equal-weight area band, Atlas container, relationship field shell, Orbital Lens container, lane blocks, and source/proof/trust block chrome.

Not a card because:

- It is the Direction Atlas product object, with the Constellation Atlas stage serving as the source-compatible component name.
- Life area, source, proof, receipt, and Today relationships are rendered as object-stage rules and texture instead of detached blocks.
- The first viewport keeps Goals as a direction object rather than a generic root status grid, detached hero treatment, or decorative star field.

Accessibility:

- VoiceOver reads Direction Atlas, life area, source, proof, receipt, Today link, and available continuity actions in order.
- Dynamic Type preserves Atlas title, life area order, and relationship lane order without restoring Atlas/Lens containers.
- Reduce Motion keeps the Atlas relationship field static.
- Increase Contrast and Differentiate Without Color use line strength, text, and symbols rather than card fill as the only state channel.

Proof artifact:

- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-575-goals-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/goals-object-stage-amb-575.png`

Rollback:

- Revert the AMB-575 commit to restore prior Goals equal-weight area band, Atlas container, relationship field shell, Orbital Lens container, lane blocks, and source/proof/trust block treatment.
- Remove the AMB-575 report and screenshot artifact if only the proof packet needs rollback.

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
