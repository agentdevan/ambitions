# Step Accessibility Validator

Status: Active PLOS M09 downstream validator
Issue: AMB-715 / PLOS-094
Parent: AMB-627 / PLOS-M09
Scope: Accessibility and VoiceOver validation contract, machine-readable rules, fixtures, and local validator linkage
Runtime implementation proof: none

## Purpose

The Step Accessibility Validator blocks or degrades a Step candidate when its VoiceOver label, value, hint, non-visual summary, Dynamic Type posture, Reduce Motion posture, or visual-only meaning is missing or unsafe.

This validator extends the AMB-711 Step Quality Firewall contract. It is a downstream control-plane artifact for AMB-716, AMB-717, and the AMB-617 / PLOS-M10 Golden Slice dependency gate. It does not prove UI implementation or accessibility certification.

## Required Inputs

The validator consumes the canonical `StepQualityInput` envelope and reads:

- `accessibility.voiceOverLabel`
- `accessibility.voiceOverValue`
- `accessibility.voiceOverHint`
- `accessibility.nonVisualSummary`
- `accessibility.visualOnlyMeaning`
- `accessibility.dynamicTypeBehavior`
- `accessibility.reduceMotionBehavior`

## Blocking Outputs

The validator emits deterministic `StepQualityVerdict.blockingCodes`:

- `missing_accessibility_semantics`
- `accessibility_label_missing`
- `accessibility_value_missing`
- `accessibility_hint_missing`
- `accessibility_summary_missing`
- `accessibility_visual_only`
- `accessibility_generic_label`
- `dynamic_type_unsafe`
- `reduce_motion_unsafe`
- `accessibility_repair_required`

Any accessibility failure requires Step Graph Compiler repair or a safe accessible fallback before a Step can be surfaced.

## Acceptance Rules

Accepted accessibility candidates must:

- carry a concrete VoiceOver label, value, hint, and non-visual summary
- avoid generic labels such as `Step`, `Button`, `Action`, `Item`, and `Open`
- avoid visual-only meaning
- declare Dynamic Type behavior as `wraps`, `stacks`, or `not-applicable`
- declare Reduce Motion behavior as `not-required`, `static-equivalent`, or `system-reduced-motion`

## Downstream Consumers

- AMB-716 / PLOS-095 must validate elasticity variants without accessibility bypass.
- AMB-717 / PLOS-096 must route failed accessibility cases through compiler repair and safe fallback.
- AMB-617 / PLOS-M10 must keep this validator runnable until production runtime integration exists.

## No-Claim Boundary

AMB-715 does not claim app source changes, Swift/domain runtime implementation, production Step Quality Firewall wiring, UI implementation, accessibility certification, VoiceOver verification, Dynamic Type verification, Reduce Motion verification, device proof, measured performance proof, Source Atlas publication, R2 writes, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, M09 parent completion, M10 Golden Slice readiness, or full PLOS project completion.
