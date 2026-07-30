# Accessibility review

## Structural behavior

- At accessibility Dynamic Type sizes, the measured spatial timeline is absent
  and replaced by an ordered chronological equivalent.
- Accepted, protected, external, proposed, Now, and open-capacity entries retain
  explicit spoken state; color is never the only carrier.
- Proposal actions expose named input labels and review hints.
- The detail sheet supports the accessibility escape action.
- Native Back and native controls preserve platform focus and keyboard behavior.
- Typed focus anchors return to the selected day, object, or proposal after
  dismissal or review.

## Verified

- Accessibility 2 layout renders without the spatial timeline.
- All Wednesday and Thursday fixture entries remain reachable through scrolling.
- Chronological order places fixed truth before Now and protected truth after
  Now.
- UI automation can reach review participants and both non-mutating outcomes.

## Not claimed

VoiceOver speech order, Switch Control, Voice Control, Full Keyboard Access,
haptics, physical-device gesture behavior, and direct-device contrast remain
future proof. The Simulator evidence is structural, not a physical-device
accessibility certification.
