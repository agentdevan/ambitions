# Ambitions Design Truth

This folder contains supporting design constitution material and contract matrices/specs.

Ambitions 3.0 is the current product baseline. Use the Ambitions 3.0 source stack first, especially [../Ambitions_3_0_Source_Of_Truth_Override.md](../Ambitions_3_0_Source_Of_Truth_Override.md), [../Ambitions_3_0_Primitive_Architecture.md](../Ambitions_3_0_Primitive_Architecture.md), and [../Ambitions_3_0_Product_Language_System.md](../Ambitions_3_0_Product_Language_System.md).

[Ambitions_Design_Constitution.md](Ambitions_Design_Constitution.md) and the matrices here remain supporting design evidence where Ambitions 3.0 does not replace the domain.

The older visual system remains supporting context where it does not conflict with Ambitions 3.0.

[DESIGN_TOKENS.md](DESIGN_TOKENS.md) is the implementation-readable token consolidation layer for color, typography, spacing, radius, elevation, motion, haptics, density, and semantic states. It clarifies the Visual System; it does not replace it.

It exists to remove interpretation drift from future implementation batches.
Use these active specs together with:

- [Ambitions_Design_Constitution.md](Ambitions_Design_Constitution.md)
- [../../../MASTER_PRODUCT_SPEC.md](../../../MASTER_PRODUCT_SPEC.md)
- [../../codex/BATCH_REGISTRY.md](../../codex/BATCH_REGISTRY.md)
- [../SOURCE_OF_TRUTH_MAP.md](../SOURCE_OF_TRUTH_MAP.md)

## Use Rules

- Ambitions 3.0 docs decide active product, IA, and language direction.
- The Design Constitution and its supporting matrices/specs are supporting design canon where not superseded.
- Older transformation docs were moved to [../../archive/README.md](../../archive/README.md) and are historical only.
- Older batch history remains historical implementation evidence.
- Treat iPhone execution truth as primary unless a spec explicitly defines a future-platform role.
- Prefer current Ambitions 3.0 docs for future active UI direction, using these matrices as supporting detail only where compatible.
- If a future implementation task conflicts with current shipping behavior, preserve shipping truth until the relevant frontend batch becomes active.

## Active Constitution And Contract Set

- [Ambitions_Design_Constitution.md](Ambitions_Design_Constitution.md)
- [screen-contract-matrix.md](screen-contract-matrix.md)
- [component-contract-matrix.md](component-contract-matrix.md)
- [ux-writing-state-language-matrix.md](ux-writing-state-language-matrix.md)
- [accessibility-nutrition-screen-matrix.md](accessibility-nutrition-screen-matrix.md)
- [external-surfaces-contract.md](external-surfaces-contract.md)
- [smart-attachment-spec.md](smart-attachment-spec.md)
- [grouped-navigation-list-spec.md](grouped-navigation-list-spec.md)
- [panel-density-size-spec.md](panel-density-size-spec.md)
- [DESIGN_TOKENS.md](DESIGN_TOKENS.md)

## Superseded / Archived Docs

The previous frontend transformation specs were archived under [../../archive/superseded-design-canon/design](../../archive/superseded-design-canon/design). Use them only for historical reasoning, never as implementation source of truth.

- [Archived design specs](../../archive/superseded-design-canon/design)

## Application Order

Use these specs in this order when planning a frontend batch:

1. Design Constitution.
2. Source-of-truth map when document ownership is unclear.
3. Visual System.
4. Design Tokens for implementation naming.
5. Screen contract matrix.
6. Component contract matrix.
7. Panel density/size spec.
8. GroupedNavigationList and Smart Attachment specs.
9. UX writing/state language matrix.
10. Accessibility Nutrition screen matrix.
11. External surfaces contract.
12. Archived historical specs only where they do not conflict with active canon.

## Scope Notes

- `Capture` is a singular top-level tab.
- `Habits` are absorbed into Rituals, Plan, Today, Goal Detail, and You/Reviews; they are not a standalone top-level product area.
- `Insights` is contextual intelligence, not a top-level tab.
- `Profile` is compatibility language only where current code requires it; user-facing active canon uses `You`.
- `Task = standalone One-Step Goal`; `Step = contained action inside a Goal, Path, or Plan`.
- `Weekly Review`, `Monthly Review`, and `History` are treated as designed supporting routes, not top-level shell destinations.
- `Widgets`, `Live Activities`, `notifications`, `App Intents`, and `share extension` are specified here as future surfaces only.
- Additional named systems such as `Semantic Zoom`, `Quiet Command Sheet`, `Continuity Ribbon`, and Smart Attachment are governed by the active constitution and matrices above.
