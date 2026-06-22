---
name: ambitions-product-object
description: Use before any Ambitions SwiftUI surface or product-object work to prevent component-stack implementations and enforce rendered object dominance, ownership, and first-viewport hierarchy.
---

# Ambitions Product Object Skill

Use this skill before any SwiftUI surface, design-system product object, root surface, or visual implementation work.

## Law

A product object is not a `VStack` of named components.

A product object is a single rendered instrument with internal anatomy.

A component is not first-class because it has a file, type, test, accessibility identifier, or canon name. It is first-class only when the rendered state proves dominance, single ownership, native interaction, accessible semantics, target match, and old UI non-reachability.

## Before Editing

1. Identify the primary product object.
2. Identify the shell owner, crown owner, dock owner, composer owner, search owner, inspection owner, and detail/correction owner.
3. Draw the first viewport hierarchy in text.
4. State what must be visually dominant.
5. State which existing components must be deleted, absorbed, or demoted.
6. State what screenshot would make this Red.

## During Implementation

- Build one root object container.
- Put child controls inside that object unless shell owns them.
- Do not expose detail, correction, proof, receipt, or inspection as root siblings unless selected by user intent.
- Do not make text the primary shape.
- Do not duplicate shell crown, Capture, Search, dock, or trust ownership.
- Do not preserve old fallback UI reachable from the root path.

## Closeout

- Attach or reference the approved target screenshot/rubric.
- Attach or reference the actual screenshot in a reviewable location.
- Compare the first viewport against the hierarchy contract.
- Mark self Red or Yellow if the object is still a stack.
- Codex may mark Ready for Visual Review, not Visual Green.
