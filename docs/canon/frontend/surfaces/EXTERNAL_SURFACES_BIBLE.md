# External Surfaces

Status: Active frontend canon surface bible
Authority: `docs/truth/PRODUCT_DESIGN_TRUTH.md`, live source evidence, and this atlas.
Implementation claim: Documentation only; source presence is not release proof.

## Top-Level Anatomy

This surface contains widgets, share extension, App Intents, notifications, shortcuts, external snapshots where source-present; all remain supporting and must avoid release claims without proof. The top-level visual hierarchy is `External Surface Projections` first, one primary next action second, source/trust/proof affordances third, and secondary metadata last.

## Primary Object

- Destination: External
- Primary object: External Surface Projections
- User job: Platform continuity
- Data/source basis: local source truth, current SwiftUI source when present, receipts/proof/source labels where implemented, and planned canon only when explicitly marked planned.

## Drill-Downs

Widget detail; share intake; shortcut/open route; notification action detail.

## States

Every visible state must name what changed, why it matters, what source powers it, what the user can do, and whether a receipt or proof object is expected. Required state classes: default, empty, active, overloaded, recovery, blocked/waiting, no-data, stale-source, local-only/offline, Dynamic Type, VoiceOver, and Reduce Motion.

## Forbidden Patterns

Do not convert this surface into a generic card-stack dashboard, chatbot UI, calendar clone, habit tracker, score/ring/streak system, SaaS/admin panel, or decorative celestial scene. Do not revive Plan as a top-level destination; existing `plan` names are compatibility seams whose user-facing destination is Time.

## Accessibility Behavior

Dynamic Type must preserve the primary object, primary action, trust/source path, and closure/recovery path. VoiceOver grouping must summarize the object before row-level controls. Reduce Motion must provide static before/after and state labels wherever motion would otherwise carry meaning. ADHD usability requires one primary question, visible escape/cancel/recover controls, and no shame language.

## Proof Expectations

Future visual proof must include default, empty, active, overloaded, recovery, blocked/waiting, no-data, large Dynamic Type, VoiceOver grouping notes, Reduce Motion, iPhone size variants, dark mode, and MRI/HBI-relevant states when applicable. This file does not supply screenshot proof.

## Source Truth

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- Relevant feature source under `Native/Ambitions/Features/`
- Relevant preview/accessibility source under `Sources/Previews/` and `Sources/Accessibility/`
