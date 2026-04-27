# Ambitions Visual Review Checklist

Use this checklist after any batch that changes visible UI, navigation, empty states, user-facing language, or surface hierarchy.

This is a manual review tool. It is not product canon and does not replace `docs/canon/Ambitions_2_0_Visual_System.md`.

## Capture requirements

For each affected surface, capture or inspect:

- Default state.
- Empty state.
- Long-text state.
- Error or unavailable state if relevant.
- Active / completed / blocked state if relevant.
- Dark appearance.
- Light appearance if the change touches colors, materials, or contrast.
- Small-device behavior if layout density changed.

Core surfaces to consider:

- Today.
- Goals.
- Goal Detail.
- Capture.
- Plan.
- You.
- Any modal, sheet, command, or external-route landing affected by the batch.

## Three-second comprehension test

A user should understand these within three seconds:

- What screen am I on?
- What matters most here?
- What is the next useful action?
- Why is this information being shown?
- Where can I go deeper without losing my place?

If any answer is unclear, the screen needs hierarchy or copy tightening before the batch is accepted.

## Ambitions identity test

The surface should feel:

- Calm.
- Premium.
- Warm.
- Intelligent.
- Human.
- Focused.
- Deep without being visually wide.

The surface should not feel:

- Like a generic to-do app.
- Like an enterprise dashboard.
- Like a habit tracker clone.
- Like a pile of equal-weight cards.
- Like a placeholder template.
- Like it is exposing system complexity too early.

## Goal / plan / task / proof clarity

For any goal-related surface, verify:

- The goal has a clear visual identity or position.
- The plan shows a believable path, not just a list.
- The next task or next visible step is obvious.
- Proof of progress is visible or intentionally deferred.
- Risk, assumption, or uncertainty language is calm and actionable.
- Archive or completed states preserve learning, not just status.

## Top-level minimalism test

Top-level screens should show only the strongest information and one or two useful actions.

Flag the screen if it has:

- Too many chips.
- Too many badges.
- Too many equal-weight cards.
- Multiple competing primary actions.
- Dense metrics without explanation.
- Repeated explanations.
- Drill-down content exposed too early.

Depth belongs in drill-downs. The top level should orient, not overwhelm.

## Visual hierarchy review

Check:

- Is the primary card or section unmistakable?
- Are secondary details visually subordinate?
- Is spacing generous enough for a premium mobile app?
- Are section headers doing useful work?
- Are icons and badges clarifying, not decorating?
- Are repeated components visually consistent?
- Does the scroll path feel intentional?

## Copy review

User-facing copy should be:

- Specific.
- Calm.
- Short.
- Truthful.
- Non-judgmental.
- Free of fake certainty.

Avoid:

- Hype language.
- Overpromising intelligence.
- Vague AI claims.
- Shame-based productivity language.
- Long explanatory blocks on top-level screens.

## Accessibility nutrition check

For affected UI, verify:

- Text is readable at normal mobile size.
- Controls are touch-friendly.
- State is not communicated by color alone.
- Contrast appears safe in dark and light modes.
- Labels are understandable without visual context.
- Motion is not required to understand the surface.

If accessibility was not verified, do not publish user-facing accessibility claims.

## Review outcome

Use this result block in batch summaries:

```markdown
## Visual Review

Affected surfaces:
- ...

Review performed:
- [ ] Three-second comprehension
- [ ] Ambitions identity
- [ ] Goal/plan/task/proof clarity
- [ ] Top-level minimalism
- [ ] Visual hierarchy
- [ ] Copy
- [ ] Accessibility nutrition

Outcome:
Pass / Needs fixes / Deferred

Notes:
- ...
```
