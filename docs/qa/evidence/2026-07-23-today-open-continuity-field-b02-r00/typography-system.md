# B02 provisional typography system

Status: `PROPOSED`

B02 uses semantic SwiftUI system typography only. No custom font, fixed
screenshot-tuned type system, or production typography token was added.

| Role | SwiftUI basis | Purpose |
| --- | --- | --- |
| Object identity | `.title2.weight(.semibold)` | Stable Step and primary object identity |
| State | `.body` | Current, proposed, settled, and interrupted truth |
| Relationship | `.subheadline` | Pursuit, protection, and temporal relationships |
| Metadata | `.footnote` | Genuinely secondary time and context |
| Action | `.body.weight(.semibold)` | Native action labels |

## Composition rules

- Identity precedes state, relationship, metadata, and action.
- A compact object uses no more than three visible sizes and two weights.
- Time values use monospaced digits where alignment improves scanning.
- Uppercase micro-labels were removed from the B02 grammar; fixture-local
  sentence case carries the hierarchy.
- Titles and relationships wrap naturally; essential text is not truncated to
  preserve a screenshot composition.
- Accessibility Dynamic Type moves dense horizontal structures into a natural
  vertical sequence and retains all required actions in the scroll field.
- Long-English LTR stress copy uses natural wrapping and leading alignment
  rather than scaled-down type.

## Proof ceiling

Native Simulator rendering and UI geometry checks support these choices.
Physical reading comfort, Bold Text, Smart Invert, grayscale, and device viewing
distance remain open direct-device obligations.

The final B02 evidence package is English only by owner direction. RTL and
localization behavior are not claimed here and remain open.
