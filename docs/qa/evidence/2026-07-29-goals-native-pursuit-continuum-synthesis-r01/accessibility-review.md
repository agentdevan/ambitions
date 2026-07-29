# Accessibility review

## Verified in Simulator

- Accessibility Dynamic Type (`accessibility2`) preserves Goal identity,
  accepted truth, Proof disclosure, current movement, and future disclosure
  through natural scrolling.
- Row-wide Life Area and Goal navigation expose native button semantics and
  minimum interaction envelopes.
- Navigation order follows Goals → Life Area → Goal → supporting depth.
- Native Back and interactive Back restore the prior selected object.
- Proof, future, Goal Path, and relationship controls remain discoverable by
  stable accessibility identifiers and semantic labels.
- Reduce Motion keeps Proof, future, and relationship meaning available without
  depending on animation.
- Reduce Transparency replaces functional shell material with an opaque
  equivalent while preserving navigation.
- Light and Dark retain hierarchy without color-only state meaning.

## Transformation model

At accessibility sizes, the Goal seam and truth regions recompose vertically.
The identity, truth, evidence, action, and future layers remain in semantic order;
fine geometry is not required to understand the object.

## Remaining physical-device obligations

VoiceOver traversal quality, Voice Control, Switch Control, Full Keyboard
Access, one-handed dock reach, edge-gesture coexistence, low-brightness Dark,
haptics, and prolonged-use fatigue remain unproven on a physical iPhone. The
Crowned Edge Dock remains a provisional high-risk hypothesis.
