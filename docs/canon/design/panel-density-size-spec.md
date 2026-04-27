# Panel Density And Size Spec

Status: Active supporting design canon.

## Core Variants

Display Density:

- Minimal.
- Balanced.
- Detailed.

Panel Size:

- Compact.
- Comfortable.
- Large.

Default: Balanced + Comfortable.

## Definitions

- Density = how much information appears.
- Size = how large the same information feels.
- Large panels show fewer things at once.
- Compact panels must not become cramped.
- Large panels must not feel like stretched UI.

## Per-Screen Overrides

- Today defaults to Balanced + Comfortable; Minimal can hide extra evidence but must keep the planned day signal.
- Goals defaults to Balanced + Comfortable; Detailed can reveal more goal health and proof; Minimal preserves direction and next step.
- Goal Detail can use Detailed density because it is object-scoped.
- Capture defaults to Minimal or Balanced around fast input.
- Plan can use Detailed below the hero for week evidence.
- You uses Balanced grouped lists at root and Detailed inside Trust/Memory.

## Global Defaults

The default app experience is Balanced + Comfortable. User preference may adjust density and size, but product-critical state remains visible through collapsed signals.

## Safe-Zone Reordering

- Hero panels are anchored.
- Critical panels cannot fully hide.
- Supporting panels can reorder only inside defined safe zones.
- Noncritical panels can hide.
- Critical panels collapse into a signal, ribbon, badge, or required state.

## Required Panels

Required panels for a screen must remain reachable in every density/size combination. They can collapse, summarize, or move below the fold only when the screen's dominant question remains answered.

## Critical Panels

Critical panels include Hero Decision Panel, Today Plan Panel, Recovery Panel when risk is active, Trust Panel when a trust action is needed, and Receipt Panel after a meaningful command.

## Optional Panels

Optional panels include noncritical insights, secondary proof previews, extended history, decorative summaries, and deeper configuration routes.

## Large Panel Behavior

- Show fewer panels at once.
- Increase clarity, not whitespace.
- Avoid stretched rows, stretched charts, or oversized labels inside compact controls.

## Compact Panel Behavior

- Preserve tap targets.
- Keep primary action visible.
- Use concise labels and collapsed signals.
- Do not cram Detailed density into Compact size.

## Accessibility Behavior

- Dynamic Type may force lower density.
- Reduce Motion must preserve state clarity.
- VoiceOver summaries should not depend on visual density.
- No color-only meaning in any combination.

## Testing Matrix

Every major screen and reusable panel must be checked across:

| Display Density | Compact | Comfortable | Large |
| --- | --- | --- | --- |
| Minimal | Required before claim | Required before claim | Required before claim |
| Balanced | Required before claim | Default required | Required before claim |
| Detailed | Required before claim | Required before claim | Required before claim |
