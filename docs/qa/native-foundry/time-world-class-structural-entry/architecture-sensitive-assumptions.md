<!-- markdownlint-disable MD013 -->

# Architecture-Sensitive Assumptions

These are hypotheses or target dependencies. None is current implementation proof.

## Identity and authority

- Event, Schedule Placement, Step, Reminder, recurrence series, occurrence, source observation, conflict participant, proposal/change set, and operation each have stable identities where represented.
- A Schedule Placement remains a relationship to Time and never becomes a copy of its Step or Event.
- Accepted, proposed, external, stale, historical, unknown, and pending are independent authority states, not one visual-status enum.
- Proposed Goal timing can be projected without acquiring accepted placement state.
- External observation can reserve reviewed capacity without becoming an Ambitions Event.

## Range, route, and restoration

- Time owns one root-local active range, supported scale selection, selected day, selected object, review origin, and focus target.
- Week is the first-use default; a later implemented scale is restored only when intentionally selected and still supported.
- Framework navigation can preserve native Back and interactive Back beneath authored Time composition.
- Compact detail and focused consequential review can retain the same canonical object and placement IDs.
- Exact period/day/object/focus restoration is a target contract; pixel-perfect scroll restoration is best effort.

## Scheduling and conflict

- Capacity can distinguish calendar-open, reviewed external busy, protected, fixed, flexible, and personally usable facts.
- Personal usability remains unknown unless sufficient local facts exist; the UI can preserve this uncertainty without recommendation pressure.
- Conflict resolution has identifiable participants and a typed authority owner.
- Over-capacity is computed separately from pairwise conflict.
- Current/proposed review revalidates exact revisions before any later commit.
- Grouped reflow, recurrence-wide changes, and external writes remain absent until durable typed contracts exist.

## Settlement, Receipt, and Undo

- Saving, pending, changed, unchanged, blocked, failed, uncertain, and partial settlement remain distinct.
- Pending is representable only with a durable operation identity, persistence, recovery, and reconciliation contract.
- Receipt appears only for a mutation-registry-covered durable result.
- Undo appears only with a safe executable typed inverse; rollback metadata alone is insufficient.
- The first calibration may stop at cancel, keep current, or fixture-only alternative inspection.

## Accessibility

- Calendar geometry can expose an ordered semantic mirror with stable object identity and chronology.
- At Accessibility Dynamic Type the primary visual model can recompose into a chronological passage or List without losing exact time, authority, protection, consequence, action, and return.
- Native focus APIs can restore focus to the selected day/object after dismissal or truthful settlement.
- Custom geometry, if used, can remain supplementary to named controls, keyboard navigation, VoiceOver actions, and static reduced-effects equivalents.
- No proposal/protection/source/conflict meaning depends on color, transparency, motion, haptics, or position alone.

## Material and shell

- System, Light, and Dark can preserve identical anatomy and truth meaning.
- Primary content remains opaque and matte; transient crown/review material has an authored opaque equivalent.
- The Crowned Edge Dock remains a provisional high-risk shell hypothesis and is not evaluated or frozen here.
- The Time direction does not authorize dock changes, final tokens, component APIs, or cross-root shell reconstruction.

## Capability boundary

- Immutable fixture snapshots can express target truth without suggesting runtime support when the fixture and proof ceiling are explicit.
- Later runtime adapters could construct the same semantic snapshot only after canonical Event/Placement/source contracts exist; the research fixture does not define those APIs.
- The live Time week projection is not a safe visual authority for accepted-versus-proposed state.
- No finding in this packet authorizes broad production implementation, runtime integration, or calendar replacement claims.

## Assumptions that invalidate all directions if false

- Accepted and proposed placement cannot be represented as distinct semantic states.
- Stable subject/placement/source identity cannot survive focused review and return.
- Protected time cannot be preserved while previewing a conflicting alternative.
- Week cannot provide a complete ordered accessibility equivalent.
- Native Back/focus ownership cannot coexist with the selected custom composition.

If any condition above is false in native prototyping, the structural family must return to research or architecture reconciliation rather than be visually patched.
