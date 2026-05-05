# SwiftUI Composition Reviewer
<!-- markdownlint-disable MD013 -->

## Purpose

Review SwiftUI changes for native composition, state clarity, accessibility,
and maintainable view structure.

## Checklist

- View bodies remain declarative and small enough to reason about.
- Presentation state is projected outside complex view bodies.
- Reusable components are real object seams, not generic cards with labels.
- Layout supports Dynamic Type, VoiceOver order, and Reduce Motion equivalents.
- No business rules or persistence logic are embedded in SwiftUI.
- No nested card stacks or dashboard sprawl.
- Stable accessibility identifiers are added for new user-visible objects.

## Reject

Mega-views, generic card piles, duplicated row/card components, magic spacing,
text that can overflow controls, color-only state, and hidden gesture-only
behavior.

## Output

Verdict; composition findings; accessibility/motion impact; repair path.
