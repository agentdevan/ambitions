# Accessibility review

## Implemented and Simulator-verified

- Stable accessibility identifiers for Life Areas, Goals, lens, focused truth, relationship, Path, Proof, actions, and shell passage.
- Selected state communicates geometry, explicit label, and accessibility value rather than hue alone.
- Minimum 44-point controls; accessibility passage rows use authored 56-point minimum frames.
- Accessibility Dynamic Type uses natural vertical recomposition and keeps Open Goal reachable.
- Standard horizontal Goal Path becomes an ordered semantic list at accessibility sizes.
- Path nodes expose title, state, selection, and position.
- Root and global shell actions preserve Today, Goals, Time, You, then Search and Capture ordering.
- System typography, native scrolling, and native navigation preserve standard platform behavior.

## VoiceOver order contract

Life Area → Goal → current truth → consequence → active thread → next movement → Proof → action → return.

## Unresolved direct-device obligations

- Spoken VoiceOver order and focus restoration.
- Voice Control, Switch Control, and Full Keyboard Access.
- Both-hand and one-handed dock reach.
- System-edge gesture coexistence and repeated-use fatigue.
- Physical Reduce Motion, Reduce Transparency, haptics, and low-brightness inspection.
- Production localization, genuine RTL content, and device-specific safe-area pressure.

Simulator evidence does not close these obligations.

