# Ambitions Design Truth

This folder contains the active Ambitions 2.0 Design Constitution and supporting contract matrices/specs.

For active Ambitions 2.0 Batch 61+ work, the top-level design source of truth is [Ambitions_Design_Constitution.md](Ambitions_Design_Constitution.md). It wins for design, IA, UX writing, component naming, interaction, trust, accessibility, and external surfaces.

The top-level visual source of truth remains [../Ambitions_2_0_Visual_System.md](../Ambitions_2_0_Visual_System.md) where it does not conflict with the Design Constitution.

It exists to remove interpretation drift from future implementation batches.
Use these active specs together with:

- [Ambitions_Design_Constitution.md](Ambitions_Design_Constitution.md)
- [../../../MASTER_PRODUCT_SPEC.md](../../../MASTER_PRODUCT_SPEC.md)
- [../../codex/BATCH_REGISTRY.md](../../codex/BATCH_REGISTRY.md)

## Use Rules

- The Design Constitution and its supporting matrices/specs are active design canon.
- Older transformation docs were moved to [../../archive/README.md](../../archive/README.md) and are historical only.
- All batches before Batch 61 are complete for planning purposes.
- Treat iPhone execution truth as primary unless a spec explicitly defines a future-platform role.
- Prefer [Ambitions_Design_Constitution.md](Ambitions_Design_Constitution.md) and [../Ambitions_2_0_Visual_System.md](../Ambitions_2_0_Visual_System.md) for future active UI direction.
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

## Superseded / Archived Docs

The previous frontend transformation specs were archived under [../../archive/superseded-design-canon/design](../../archive/superseded-design-canon/design). Use them only for historical reasoning, never as implementation source of truth.

- [Archived design specs](../../archive/superseded-design-canon/design)

## Application Order

Use these specs in this order when planning a frontend batch:

1. Design Constitution.
2. Screen contract matrix.
3. Component contract matrix.
4. Panel density/size spec.
5. GroupedNavigationList and Smart Attachment specs.
6. UX writing/state language matrix.
7. Accessibility Nutrition screen matrix.
8. External surfaces contract.
9. Archived historical specs only where they do not conflict with active canon.

## Scope Notes

- `Capture` is a singular top-level tab.
- `Habits` are absorbed into Rituals, Plan, Today, Goal Detail, and You/Reviews; they are not a standalone top-level product area.
- `Insights` is contextual intelligence, not a top-level tab.
- `Profile` is compatibility language only where current code requires it; user-facing active canon uses `You`.
- `Task = standalone One-Step Goal`; `Step = contained action inside a Goal, Path, or Plan`.
- `Weekly Review`, `Monthly Review`, and `History` are treated as designed supporting routes, not top-level shell destinations.
- `Widgets`, `Live Activities`, `notifications`, `App Intents`, and `share extension` are specified here as future surfaces only.
- Additional named systems such as `Semantic Zoom`, `Quiet Command Sheet`, `Continuity Ribbon`, and Smart Attachment are governed by the active constitution and matrices above.
