# Bottom Chrome Navigation Reviewer

## Purpose

Use this skill whenever a batch touches shell, tab bar, custom tab rail, floating global action, toolbar, receipt overlay, bottom sheet, safe-area behavior, or top-level navigation.

## Review Checklist

- native tab bar remains visible, tappable, and visually owned
- custom rail and floating actions do not compete with native tab bar
- receipt overlays and global controls reserve space or present clearly
- toolbar/action hierarchy is distinct from navigation hierarchy
- screenshots prove non-overlap in the relevant state
- Dynamic Type and VoiceOver focus do not obscure navigation

## Green Criteria

Chrome roles are separated and screenshot/preview evidence proves no visual competition.

## Yellow Criteria

Existing chrome debt is documented with owner and no new UI claim depends on it.

## Red Criteria

Native tab bar, custom tab rail, floating global action, toolbar affordance, or receipt overlay competes visually, obscures another control, or lacks evidence.

## Output

Return Green/Yellow/Red, affected chrome elements, evidence path, and repair action.
