# Object Frontend Green / Yellow / Red Rubric

Status: Final working draft  
Scope: Object frontend implementation, validator, previews, tests, proof, and no-card architecture

---

## Green

A batch may close Green only when all required items are true:

- Source changed in the intended scope.
- Named or inferred object root installed.
- Active card architecture removed.
- Top-level surface no longer resembles cards/list/dashboard/feed/chat/calendar clone.
- Tests updated.
- Preview matrix updated.
- Accessibility labels/identifiers present.
- Reduce Motion path exists where motion changed.
- `scripts/ios26-anti-card-check.py` passes for the relevant surface.
- Proof artifact written.
- Screenshot/manual proof supplied where required.
- Final report separates source, tests, previews, validators, proof, prompts, and design-system changes.

---

## Yellow

Yellow is allowed only after a repair cycle.

A valid Yellow must include:

- exact reason
- exact files affected
- owner
- no-claim boundary
- follow-up gate
- validation posture
- repair attempts already made
- whether user-visible UI is affected

Allowed Yellow cases:

- screenshot automation unavailable
- legacy compatibility remains outside active UI
- design-system cleanup intentionally deferred
- external tool/simulator unavailable
- manual screenshot checklist required

Yellow may not claim object-purity completion.

---

## Red

Red if any of these remain:

- active top-level card stack
- active dashboard/feed/chat/list/calendar-clone root
- object root absent
- design system overwritten without scoped need
- accessibility path broken
- gesture without tap fallback
- motion-only meaning
- haptic-only confirmation
- silent material mutation
- unreceipted material change
- active card compatibility wrapper in rendered UI
- forbidden Assistant/chat/dashboard/productivity/task framing

---

## Rollback

Rollback must:

- revert only files touched by the batch
- preserve unrelated dirty work
- remove malformed generated artifacts
- keep generated reports if needed for failure diagnosis
- never broad reset the repo

---

## Final Implementation Thesis

```text
Install an object-first SwiftUI frontend that inherits AmbitionsDesignSystem and removes generic card architecture from active top-level surfaces.

Convert Ambitions from screen/card UI into named native life instruments with proof, motion, accessibility, and validation.

Make Ambitions’ frontend implementation match its product objects: Meridian, Field, Atlas, Composer, Profile, and Proof.
```
