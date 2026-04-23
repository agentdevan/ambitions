# Ambitions Frontend Transformation Execution Classification

## Purpose

This document classifies future frontend transformation systems and surface programs into the correct implementation tier so later Codex execution stays safe, coherent, and flagship-focused.

It is the canonical sequencing truth for:

- what must land in the early frontend core tranche
- what is real but should wait for later core batches
- what must wait for advanced later-core integration after its owning later-core surfaces are stable

Use this with:

- [README.md](README.md)
- [../Ambitions_Full_Frontend_Transformation_Program.md](../Ambitions_Full_Frontend_Transformation_Program.md)
- [../../../MASTER_PRODUCT_SPEC.md](../../../MASTER_PRODUCT_SPEC.md)
- [../../codex/batches/README.md](../../codex/batches/README.md)
- [transformation-terminology-spec.md](transformation-terminology-spec.md)

## Operational Guardrail

- Batch 38 is completed.
- Batch 48 is completed in the registry.
- Batch 49 is completed in the registry.
- Batch 50 is completed in the registry.
- Batch 51 is active in the registry.
- Batches 52-60 remain queued.
- Nothing in this document activates future frontend work ahead of the registry.
- Execution tiering remains sequencing truth only; it does not authorize implementation before the owning batch is active.

## Classification Rubric

### Early Core

Use when the item is:

- foundational to shell coherence or flagship quality
- required for the transformed product to feel obviously different and better early
- safe enough to build before later support and ambient work
- likely to be reused by many later batches

### Later Core

Use when the item is:

- real and important
- dependent on earlier shell, system, or surface work
- better after the early shell and flagship surfaces are stable
- still required for the full transformed product

### Advanced Later Core

Use when the item is:

- fully approved and mandatory
- dependent on already-stable later-core surfaces or interaction grammar
- likely to cause double work, density overload, or shell drift if brought forward too early
- better as a final mandatory deepening pass inside the later program rather than as early-core or first-pass later-core work

## Early Core Tranche

Recommended early-core batch band:

- Batch 39 for canon/control-file foundation, then Batches 40-45 as the first implementation tranche for transformed shell and flagship surfaces

### Systems

| Item | Classification | Why | Dependencies | Change Type | Flagship Requirement | iPhone-First Safe | Wait for Later? | Early-Risk Note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Living Hero Surface | Early core | Defines the product's dominant-truth posture across major screens. | Shell hierarchy, design system, motion grammar. | IA, composition, motion. | Required. | Yes. | No. | Weak hero execution would make the redesign feel generic. |
| Contextual Global Compose | Early core | Unifies creation and quick action entry at the shell layer. | Shell model, route ownership. | Shell structure, action entry. | Required. | Yes. | No. | If deferred, later command and capture work fragments. |
| Quiet Command Sheet | Early core | The consumer-facing execution surface for global actions must be designed with the compose system, not bolted on later. | Contextual Global Compose, shell overlays, copy rules. | Shell interaction and action UX. | Required. | Yes. | No. | High risk only if it drifts into power-user palette behavior. |
| Shell-Aware Transitions | Early core | The transformed shell will feel incoherent without one motion grammar early. | Shell model, motion primitives. | Motion grammar. | Required. | Yes. | No. | If postponed, later surfaces accumulate mismatched route behavior. |
| Adaptive Header Rail | Early core | It is one of the main structural differentiators and reweights every top-level destination. | Shell ownership, design system. | Shell structure, IA, utility placement. | Required. | Yes. | No. | Needs restraint to avoid header clutter. |
| Object-Persistent Navigation | Early core | Preserving identity across surfaces is foundational to the "external brain" feeling. | Shell-aware transitions, route ownership, motion grammar. | Navigation and motion grammar. | Required. | Yes. | No. | If ignored early, later coherence retrofits become expensive. |
| Intent-Sensitive Primary Action | Early core | Keeps each major screen obvious while avoiding control multiplication. | Screen architecture, state model, copy rules. | Interaction model. | Required. | Yes. | No. | Too many exceptions would erode clarity. |
| Trust Whisper | Early core | First-layer trust is necessary for high-trust flagship quality from the first redesigned surfaces. | Copy rules, trust disclosure model, design system. | Trust presentation. | Required. | Yes. | No. | Must remain quiet; overexposure creates debug-UI feel. |
| Full shell reconsideration / final shell model | Early core | All later surface work depends on canonical shell truth. | None beyond current canon. | Shell structure and route ownership. | Required. | Yes. | No. | The only major risk is over-innovating the shell. |
| Full design system rollout | Early core | Shared visual language must land before surface rebuilds to avoid one-off styling. | Design token and component architecture. | Presentation system. | Required. | Yes. | No. | If delayed, every later batch becomes rework-prone. |
| Motion system rollout | Early core | One transition and feedback grammar is needed before flagship surfaces rebuild. | Design system, shell transitions. | Motion system. | Required. | Yes. | No. | Too much animation would violate calmness. |
| Today full redesign | Early core | Today is the habit-forming home base and must define the transformed product early. | Shell, design system, motion, trust whisper. | Screen architecture, interaction model, some logic exposure. | Required. | Yes. | No. | Must avoid dense dashboard relapse. |
| Goals full redesign | Early core | Goals is the first direction board and is needed early to show ambition structure. | Shell, design system, early navigation grammar. | Screen architecture and IA. | Required. | Yes. | No. | Needs strong hierarchy or it becomes list-first again. |

### Early-Core Notes

- Early core is intentionally small.
- The early tranche should make Ambitions unmistakably different through shell, Today, Goals, shared system language, and first-layer trust.
- Early core should not absorb every interesting invention just because it is promising.

## Later Core Tranche

Recommended later-core batch band:

- Batches 46-60 after Batch 39 establishes doctrine and the shell, design system, motion system, Today, and Goals are stable

### Systems

| Item | Classification | Why | Dependencies | Change Type | Flagship Requirement | iPhone-First Safe | Wait for Later? | Early-Risk Note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Time Aperture | Later core | Strong and real, but it depends on Today and Plan structure being stable first. | Today hero and Plan shaping surfaces. | Interaction and time presentation. | Required for full product, not day-one shell. | Yes. | Yes. | Early landing risks premature dense time UI. |
| Recovery Bloom | Later core | Signature behavior, but best after Today's core action model is established. | Today redesign, trust whisper, motion grammar. | Interaction, motion, some product-logic exposure. | Required for full product. | Yes. | Yes. | Brought forward too early, it can overcomplicate the first Today pass. |
| Pressure Map | Later core | Valuable and calmer than a scrubber-first model, but depends on Plan and Goals shape. | Plan and Goals rebuilt structure. | Presentation and decision support. | Required for full weekly-shaping quality. | Yes. | Yes. | Early use without stable week structure risks clutter. |
| Pressure Scrubber | Later core | A real interaction, but it should follow stable pressure grammar rather than define it. | Pressure Map, Plan/Goals structure, motion grammar. | Interaction detail. | Useful, not the first requirement. | Yes. | Yes. | Early scrubber-first design risks novelty over clarity. |
| Path Filmstrip | Later core | Core to Goal Detail quality, but Goal Detail comes after shell and primary surfaces. | Goal Detail structure, motion, hierarchy. | Goal Detail interaction and presentation. | Required for full Goal Detail flagship quality. | Yes. | Yes. | Early use without stable detail composition feels ornamental. |
| Elastic Week View | Later core | Real differentiator for Plan, but Plan should follow shell and first flagship surfaces. | Plan IA, pressure grammar, motion. | Plan composition. | Required for full Plan quality. | Yes. | Yes. | Early implementation risks calendar-clone complexity. |
| Strategy Composer | Later core | A key flagship setup flow, but it is safer after shell and goal language are stable. | Goals IA, Horizon Ladder, trust language. | Creation flow and some logic presentation. | Required for the full transformed product. | Yes. | Yes. | Too early means overinvesting before goal structure is proven. |
| Memory Lens | Later core | Valuable across surfaces, but it depends on command, correction, and history coherence. | Quiet Command Sheet, Goal Detail trust depth, history routes. | Recall and trust interaction. | Important, but not the first differentiator. | Yes. | Yes. | Early landing risks duplicate history and audit flows. |
| Horizon Ladder | Later core | Strong structural system, but it depends on mature Goals and Strategy Composer work. | Goals and Goal Detail architecture. | Structural hierarchy. | Required for full direction clarity. | Yes. | Yes. | Too early can overload the Goals surface. |
| Focus Screenlet | Later core | Useful, but it spans in-app plus ambient surfaces and is not required for the first shell tranche. | Today focus model, external-surface direction. | Surface component / ambient continuity. | Important later. | Yes. | Yes. | Early landing fragments effort across in-app and external surfaces. |
| Appearance Studio | Later core | Real and premium, but Profile can wait until core execution surfaces are excellent. | Design system and Profile rebuild. | Utility and personalization. | Required for full transformed finish, not early shell proof. | Yes. | Yes. | Early theming emphasis could misallocate effort. |
| Sync Pulse | Later core | Real trust UI, but it should wait for Profile and cross-device trust work. | Profile trust center, future cross-device work. | Trust presentation. | Important later. | Partially. | Yes. | Too early creates trust UI ahead of meaningful device state. |
| Cognitive Mode Lens | Later core | Powerful but structurally risky. It should follow stable shell and screen architecture. | Header rail, intent-sensitive primary action, screen architecture. | Cross-screen weighting system. | Helpful for differentiation, but not first-proof essential. | Yes. | Yes. | Early overuse could make the app feel mode-heavy. |
| Continuity Ribbon | Later core | Valuable continuity layer, but it should ride on already-stable shell and surface hierarchies. | Header rail, object persistence, trust signals. | Cross-surface continuity presentation. | Important later. | Yes. | Yes. | Too early becomes a second hero or notification layer. |
| Semantic Zoom for Goals | Later core | Real structural improvement, but depends on a stable Goals and Goal Detail hierarchy first. | Goals redesign, Goal Detail architecture, motion grammar. | Goal structure interaction. | Important later. | Yes. | Yes. | Early zoom could create hierarchy overload. |
| Review Constellation | Later core | Strong for reflection, but Insights is a later support surface. | Insights rebuild, history coherence, copy rules. | Reflection composition. | Required for full reflection quality. | Yes. | Yes. | Early reflection work distracts from execution surfaces. |
| Living Capture | Later core | Real improvement to capture UX, but capture should follow shell and planning coherence. | Capture routes, Quiet Command Sheet, Plan and Goal promotion flows. | Capture interaction model. | Important later. | Yes. | Yes. | Early capture-state expansion risks workflow sprawl. |
| Goal Detail full redesign | Later core | Deep and important, but not needed before Today and Goals establish the transformed product. | Goals redesign, shell transitions, design system. | Surface program. | Required later. | Yes. | Yes. | Early detail depth before top-level clarity is backwards. |
| Plan full redesign | Later core | Core to the product, but should follow Today and Goals in execution order. | Shell, design system, motion, pressure grammar. | Surface program. | Required later. | Yes. | Yes. | Brought forward too early, it becomes dense and overbuilt. |
| Captures redesign | Later core | Important, but best after command entry and planning structure stabilize. | Quiet Command Sheet, shell ownership, Plan follow-through. | Surface program. | Important later. | Yes. | Yes. | Early capture redesign can scatter the shell. |
| Habits redesign | Later core | Real support work, but not the first proof of transformation. | Plan structure, review flows. | Surface program. | Important later. | Yes. | Yes. | Early work here dilutes flagship focus. |
| Insights redesign | Later core | Real and important, but reflection should follow execution-surface success. | Review Constellation, history coherence. | Surface program. | Important later. | Yes. | Yes. | Early insights work risks dashboard drift. |
| Profile redesign | Later core | Valuable, but utility surfaces should follow flagship execution surfaces. | Design system, Appearance Studio, trust center. | Surface program. | Important later. | Yes. | Yes. | Early profile polish overweights settings. |
| Onboarding / first-run / permissions redesign | Later core | Needed, but should follow stable shell and main-surface decisions. | Shell, primary flows, copy system. | State and first-run program. | Required later. | Yes. | Yes. | Too early means rewriting onboarding against unstable flows. |
| External surfaces redesign | Later core | Real product work, but must inherit stable shell and main-surface truth. | Shell, object persistence, Focus Screenlet, trust language. | Ambient and external surface program. | Important later. | No, not first. | Yes. | Early external work creates double rework. |
| Cross-device design truth carry-forward | Later core | Important for consistency, but should follow stable iPhone truth. | Stable iPhone shell and surface systems. | Cross-platform design continuation. | Important later. | No, not first. | Yes. | Early spread weakens iPhone-first execution. |
| Trust / explainability presentation overhaul | Later core | First-layer whisper is early; the deeper overhaul belongs after stable surfaces exist. | Trust Whisper, Goal Detail, Plan, Insights. | Trust UX and explanation depth. | Required later. | Yes. | Yes. | Too early becomes instrumentation-heavy. |

## Advanced Later-Core Tranche

Recommended placement:

- mandatory late-program integrations after their owning later-core surfaces are stable
- primary ownership should stay with the mature surface that benefits most, not with the first batch that merely mentions the idea

### Systems

| Item | Classification | Why | Dependencies | Change Type | Flagship Requirement | iPhone-First Safe | Wait for Later? | Early-Risk Note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Path Preview Drawer | Advanced later core | Required future-path inspection, but it should land only after Goal Detail base structure, Semantic Zoom, and Path Filmstrip are stable. | Goals redesign, Semantic Zoom for Goals, Goal Detail rebuild I, Path Filmstrip. | Goal Detail supporting interaction. | Required for full Goal Detail flagship quality. | Yes. | Yes. | Added too early, it duplicates the primary path hierarchy and weakens first-layer clarity. |
| Window Magnetism | Advanced later core | Required for the final week-shaping experience, but it should follow stable Plan structure, Elastic Week View, and pressure grammar so it reads as intelligence rather than novelty. | Plan rebuild I, Elastic Week View, Pressure Map, Pressure Scrubber, suggestion-quality baseline. | Suggestion interaction. | Required for full Plan flagship quality. | Yes. | Yes. | Added too early, it turns week shaping into animated suggestion noise before the base workspace is trusted. |
| Split-Pane Thinking on iPhone | Advanced later core | Required only as a tightly contained clarity aid in advanced shaping states, not as a general shell pattern. | Goal Detail maturity, Plan maturity, shell presentation rules, object persistence. | Navigation and composition refinement. | Required in constrained states, not as universal layout. | Conditionally. | Yes. | Added too early, it creates cramped tool-like density and teaches the wrong shell expectation. |

### Mandatory Landing Decisions

- `Path Preview Drawer` is owned by `Batch 48` after `Batch 45` establishes Semantic Zoom for Goals and `Batch 47` stabilizes Goal Detail first-layer path visualization.
- `Window Magnetism` is owned by `Batch 50` after `Batch 49` stabilizes Elastic Week View, Pressure Map, Pressure Scrubber, and the base Plan shaping workspace.
- `Split-Pane Thinking on iPhone` is owned by `Batch 50` as an advanced later-core containment layer.
  - primary use: selected-block or open-window shaping in `Plan`
  - secondary use: carry-forward shaping in `Weekly Review`
  - narrowly allowed Goal Detail use: future-path inspection only when the contextual pane stays lighter than a push or sheet alternative
  - never allowed: shell-wide phone layout, Today default state, Goals overview, or Profile

## Surface Program Classification Summary

### Early Core Surfaces

- final shell model
- Today redesign
- Goals redesign

### Later Core Surfaces

- Goal Detail redesign
- Plan redesign
- Captures redesign
- Habits redesign
- Insights redesign
- Profile redesign
- onboarding / first-run / permissions redesign
- external surfaces redesign
- cross-device design truth carry-forward
- deeper trust / explainability overhaul

### Advanced Later-Core Surface Behaviors

- Goal Detail shallow future-path drawer after first-layer path systems are stable
- window-magnet planning behaviors after Plan pressure grammar is already trusted
- narrow split-pane iPhone compositions only in mature shaping states with explicit containment rules

## Recommended Sequencing Implications

### Early-Core Tranche Should Prove

- the transformed shell
- one undeniable flagship home base (`Today`)
- one undeniable direction surface (`Goals`)
- one shared visual and motion language
- one calm first-layer trust posture

### Later-Core Tranche Should Deepen

- goal depth
- week shaping
- capture and habit absorption
- reflection
- utility and trust center
- ambient and cross-device continuation

### Advanced Later-Core Work Must Integrate Last

- advanced later-core systems remain mandatory, but they must land only after their owning later-core surfaces already feel stable
- late placement is sequencing, not exclusion
- advanced later-core systems must never force shell-wide interaction patterns or duplicate earlier surface structures

## Re-Phasing Decisions

- `Cognitive Mode Lens` moved out of implied early shell novelty and into later core because it is powerful but structurally risky.
- `Continuity Ribbon` moved out of assumed shell-core status into later core because it should sit on top of already-stable hierarchy.
- `Pressure Map` is later core, while more interactive pressure exploration should not define the early tranche.
- `Path Preview Drawer` moved into advanced later core and is now mandatory in `Batch 48` once Goal Detail and Semantic Zoom are stable.
- `Window Magnetism` moved into advanced later core and is now mandatory in `Batch 50` after Plan pressure grammar is stable.
- `Split-Pane Thinking on iPhone` moved into advanced later core and is now mandatory in `Batch 50` as a tightly contained Plan and Weekly Review clarity system, with Goal Detail allowed only in very narrow future-path states.
- `Trust Whisper` stays early core, but the full trust and explanation overhaul remains later core.

## Batch Alignment Notes

- Batch 39 owns canon, terminology, doctrine, and validation alignment only.
- Batches 40-45 should reference only the early-core systems required for shell, shared system language, Today, and Goals.
- Batches 46-60 should absorb the later-core systems as their owning surfaces mature.
- Batch 48 owns `Path Preview Drawer` as mandatory advanced later-core Goal Detail deepening.
- Batch 50 owns `Window Magnetism` and `Split-Pane Thinking on iPhone` as mandatory advanced later-core Plan and review-shaping deepening.
