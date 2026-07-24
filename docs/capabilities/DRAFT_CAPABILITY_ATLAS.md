# Ambitions Draft Capability Atlas

Status: **non-normative Phase E draft for owner review**

This document states the durable product promises proposed for Ambitions after repository archaeology, extraction, taxonomy, and reconciliation. It does not alter canon, authorize implementation, or assert that current code fulfills any promise.

The machine-readable companion is `draft-capability-atlas.json`.

## Lifecycle posture

Every entry currently has:

- Authority: `proposed`
- Specification maturity: `framed`
- Implementation status: `not_assessed`
- Verification status: `not_assessed`

Implementation evidence may appear in the repository without proving that the complete capability exists. Owner approval is required before any entry becomes canonical product authority.

## Proposed capability set

| ID | Capability | Primary product domain | Unresolved scope decision |
|---|---|---|---|
| `CAP-CONTEXT-001` | Skill Transference | Personal Context, Learning, and Transfer | Standalone capability or local-learning subcapability |
| `CAP-PATH-001` | Contextual Generative Goal Pathing | Goals, Paths, and Progression | None beyond general approval |
| `CAP-SIMULATION-001` | Alternate Career Path Simulation | Simulation, Scenarios, and Counterfactuals | Career-specific or broader life-path scope |
| `CAP-TIME-001` | Adaptive Step Placement Reflow | Time, Capacity, and Reflow | Standalone capability or broader reflow subcapability |
| `CAP-SEARCH-001` | Ambitions Native Search and Command | Search, Retrieval, and Command | None beyond general approval |
| `CAP-APPEARANCE-001` | Appearance Studio | Appearance and Personal Expression | Minimum first-class authoring depth |
| `CAP-SHARING-001` | Content Share Studio | Sharing, Publishing, and External Expression | Initial output formats |
| `CAP-KNOWLEDGE-001` | Goal-Attached Files and Knowledge | Files, Attachments, and Personal Knowledge | Goal-first or object-wide product scope |
| `CAP-RESILIENCE-001` | Local-First Operational Continuity | Resilience, Recovery, and Degraded Operation | None beyond general approval |

---

## `CAP-CONTEXT-001` — Skill Transference

### Product promise

Help a person deliberately recognize and reuse demonstrated skills, strategies, and operating patterns from one life domain in another where the evidence and context make the transfer plausible.

### User outcome

The person can carry hard-won capability across work, relationships, health, creativity, learning, and other pursuits instead of repeatedly starting from zero.

### Why it exists

People often possess transferable capability without noticing the structural similarity between domains. Ambitions should make that leverage visible without pretending that success in one context guarantees success in another.

### Example experience

After repeated evidence that the person breaks complex work into small milestones effectively, Ambitions proposes applying that strategy to learning music. It shows the source evidence, explains meaningful differences between the domains, states uncertainty, and lets the person accept, modify, defer, or dismiss the transfer.

### Required controls

- Inspect source evidence and confidence.
- Accept, edit, defer, or dismiss a proposed transfer.
- Limit or disable transfer across selected life areas.
- Correct the inferred pattern and retain the correction.

### Non-goals

- Claim that competence automatically transfers between unrelated domains.
- Infer credentials, professional qualification, or guaranteed outcomes.
- Apply a learned pattern to consequential plans without person review.
- Turn local learning into an opaque recommendation feed.

### Privacy and trust boundary

Derived transfer proposals are private, local, evidence-linked, confidence-bounded, inspectable, correctable, and deletable. Sensitive evidence cannot be reused across domains without an explicit lawful and person-controlled basis.

### Supporting authority and systems

- `docs/canon/specifications/systems/local-learning.md`
- `docs/canon/specifications/systems/privacy-and-data-classification.md`
- `docs/canon/specifications/objects/goal-path.md`
- Local Learning, Private Life Runtime, Goal Path, and Trust Inspection

### Open decision

`DEC-CONTEXT-001-SCOPE`: retain as a standalone flagship capability or treat it as a named local-learning subcapability. Recommended default: **standalone flagship capability**.

---

## `CAP-PATH-001` — Contextual Generative Goal Pathing

### Product promise

Generate a unique, revisable path toward a person's goal using their context, constraints, capacity, learned behaviors, dependencies, uncertainty, and accepted preferences rather than assigning a generic checklist.

### User outcome

The person receives a coherent route designed for their actual life, can understand why it was proposed, and can revise it without losing canonical ownership, history, or downstream consequences.

### Why it exists

A meaningful goal rarely fails because the person lacks a list of obvious tasks. It fails when the path ignores real capacity, dependencies, prior behavior, ambiguity, and the way the pursuit must coexist with the rest of life.

### Example experience

A person chooses to become a working photographer. Ambitions proposes evidence-backed stages, identifies prerequisite skill and portfolio dependencies, fits early steps to available time, marks uncertain assumptions, and projects the accepted canonical Goal Path into Today, Time, Search, Motion, and Trust without creating competing copies.

### Required controls

- Compare proposed path variants.
- Accept, edit, regenerate, defer, or reject the path.
- Lock constraints and protected commitments.
- Inspect assumptions, dependencies, confidence, and consequences.
- Restore or compare prior accepted path versions.

### Non-goals

- Generate static template checklists and label them personalized.
- Commit generated steps or placements without person acceptance.
- Create separate canonical paths for individual surfaces.
- Hide uncertainty, conflicts, or personalization sources.

### Privacy and trust boundary

Path generation uses private local canonical state by default. The person can inspect which context influenced a proposal. Sensitive context is minimized and purpose-bound; private life-graph content is not sent to external services merely to generate a path.

### Supporting authority and systems

- `docs/canon/specifications/objects/goal-path.md`
- `docs/canon/specifications/systems/local-learning.md`
- `docs/canon/specifications/systems/scheduling-and-capacity.md`
- `docs/canon/specifications/surfaces/goals.md`
- `docs/canon/specifications/surfaces/today.md`
- `docs/canon/specifications/surfaces/time.md`
- `docs/canon/specifications/global/search.md`
- Goal Path, Local Learning, Scheduling and Capacity, Private Life Runtime, and Trust Inspection

---

## `CAP-SIMULATION-001` — Alternate Career Path Simulation

### Product promise

Let a person explore plausible alternate career paths and compare assumptions, transitions, skill demands, time horizons, trade-offs, and consequences without mutating the committed life graph.

### User outcome

The person can reason about a career change as a set of inspectable scenarios rather than a vague fantasy or irreversible plan.

### Why it exists

Career decisions combine identity, time, learning, money, opportunity, uncertainty, and family constraints. Ambitions should expose those relationships while remaining explicit about what cannot be predicted.

### Example experience

A person compares staying in product management, moving into iOS product leadership, and pursuing music full time. Ambitions models staged transitions, prerequisite skills, available capacity, likely sacrifices, reversible experiments, and uncertainty. Nothing enters Goals or Time until the person explicitly adopts part of a scenario.

### Required controls

- Create, duplicate, compare, revise, archive, or discard scenarios.
- Change assumptions and immediately inspect consequences.
- Adopt selected scenario elements only through explicit canonical review.
- Exclude sensitive constraints from a scenario or export.

### Non-goals

- Predict a person's career, income, or success with unsupported certainty.
- Provide legal, financial, educational, or employment guarantees.
- Mutate committed goals, steps, or placements during exploration.
- Generalize career evidence to all life domains without approved scope.

### Privacy and trust boundary

Career scenarios and private constraints remain local by default. External reference material remains provenance-bearing and separate from private context. Every conclusion exposes assumptions, uncertainty, and correction controls.

### Supporting authority and systems

- `docs/canon/specifications/objects/branch-viability-certificate.md`
- `docs/canon/specifications/journeys/life-branch-reconciliation.md`
- `docs/canon/specifications/systems/certified-executable-branch-reconciliation.md`
- `docs/canon/specifications/systems/local-learning.md`
- `docs/canon/specifications/systems/scheduling-and-capacity.md`
- `docs/canon/specifications/systems/privacy-and-data-classification.md`
- Branch Viability, Local Learning, Scheduling and Capacity, Source Atlas, and Trust Inspection

### Open decision

`DEC-SIMULATION-001-BREADTH`: career-specific or broader alternate-life-path capability. Recommended default: **career-specific initial scope with expandable architecture**.

---

## `CAP-TIME-001` — Adaptive Step Placement Reflow

### Product promise

When a person places or changes a step, recalculate the affected temporal plan around dependencies, protected commitments, real capacity, and accepted constraints, then preview the proposed reflow before consequential mutation.

### User outcome

The person can place new work into a living plan without manually repairing every downstream date or losing trust in what moved.

### Example experience

A person adds a prerequisite certification step before an application deadline. Ambitions identifies dependent steps, protected events, overload, and infeasible placements; proposes a revised sequence; explains every movement; and commits only the accepted version.

### Required controls

- Preview and compare reflow proposals.
- Lock steps, dates, constraints, and protected commitments.
- Accept all, accept selected changes, edit, or cancel.
- Inspect movement rationale, conflicts, and excluded alternatives.
- Restore prior arrangements through canonical mutation history.

### Non-goals

- Treat simple list reordering as schedule reflow.
- Move protected commitments or constraints silently.
- Hide conflicts, dropped work, or capacity assumptions.
- Let scheduling infrastructure become the canonical owner of goals or steps.

### Privacy and trust boundary

Reflow operates on private local planning state. External timing evidence remains source-scoped and permission-bound. Sensitive commitments can affect capacity without exposing their content in unrelated surfaces.

### Supporting authority and systems

- `docs/canon/specifications/journeys/schedule-reflow.md`
- `docs/canon/specifications/systems/scheduling-and-capacity.md`
- `docs/canon/specifications/objects/schedule-placement.md`
- `docs/canon/specifications/objects/step.md`
- `docs/canon/specifications/objects/goal-path.md`
- `docs/canon/specifications/surfaces/time.md`
- Scheduling and Capacity, Goal Path, Persistence and Replay, and Trust Inspection

### Open decision

`DEC-TIME-001-LEVEL`: standalone visible capability or broader schedule-reflow subcapability. Recommended default: **standalone visible capability backed by broader scheduling infrastructure**.

---

## `CAP-SEARCH-001` — Ambitions Native Search and Command

### Product promise

Provide one global, fast, private, native command surface for finding Ambitions objects and relationships, asking grounded questions about retrieved local evidence, inspecting trust context, and invoking allowed actions through the canonical mutation owner.

### User outcome

The person can reach and act on anything meaningful in Ambitions without navigating a hierarchy or surrendering privacy, provenance, or consequence visibility.

### Example experience

The person searches for “the photography step blocked by my certification.” Ambitions resolves the canonical Step, explains the relationship, offers allowed commands, and supports a grounded follow-up. A reschedule action routes through Time's mutation authority and returns an inspectable Receipt.

### Required controls

- Search canonical objects, relationships, history, and permitted projections.
- Filter and scope results without leaking protected identity.
- Ask grounded questions only against retrieved, inspectable evidence.
- Preview command consequences before material action.
- Inspect Receipt, History, provenance, and recovery state.

### Non-goals

- Create a fifth root destination.
- Behave as a generic chatbot detached from retrieved evidence.
- Own generic mutation or bypass object owners.
- Send private queries or results to a hosted search service.

### Privacy and trust boundary

Query, index, retrieval, grounded Ask, and permitted command routing remain local. Protected identities stay suppressed. Search delegates mutation and cannot convert retrieval confidence into authority.

### Supporting authority and systems

- `docs/canon/specifications/global/search.md`
- `docs/canon/specifications/journeys/search-find-act-inspect.md`
- `docs/canon/specifications/journeys/search-find-ask-act-inspect.md`
- `docs/canon/specifications/global/trust-inspection.md`
- Local Search, FTS/Semantic Local Index, canonical command routing, and Trust Inspection

---

## `CAP-APPEARANCE-001` — Appearance Studio

### Product promise

Give a person a coherent first-class place inside You to author Ambitions' visual expression within native, accessible, semantically safe boundaries and preview the result before applying it across the product.

### User outcome

The person can make Ambitions feel personally theirs without fragmenting the design system, hiding meaning, weakening accessibility, or turning appearance into scattered settings.

### Recommended initial scope

A bounded multidimensional studio with live preview for appearance mode, approved accent/palette expression, surface/material intensity, supported density or emphasis choices, and motion-expression preferences where they do not conflict with accessibility settings or product law.

### Required controls

- Live preview before commit.
- Restore system/default expression.
- Explain accessibility or semantic constraints on unavailable combinations.
- Preserve required status, contrast, hierarchy, and nonvisual meaning.
- Apply changes coherently across supported roots and depths.

### Non-goals

- Arbitrary theming that bypasses design tokens or semantic roles.
- Per-screen visual drift or user-authored layout architecture.
- Customization that hides required state or action meaning.
- Replacement of system accessibility preferences.

### Privacy and trust boundary

Appearance settings are local user-owned preferences. They do not infer personality, emotional state, identity labels, or behavioral judgments. Optional continuity remains separately governed.

### Supporting authority and systems

- `docs/canon/specifications/surfaces/you.md`
- `docs/canon/design/VISUAL_SYSTEM_R1.md`
- `docs/canon/design/VC_WAVE_2_SURFACE_JOURNEY_CLOSURE.md`
- `docs/canon/design/VC_WAVE_3_ACCESSIBILITY_STRESS_CLOSURE.md`
- You, Design Tokens, Accessibility, Motion Reduction, and local settings persistence

### Open decision

`DEC-APPEARANCE-001-DEPTH`: minimum authoring depth that establishes first-class status. Recommended default: **bounded multidimensional studio with live preview**.

---

## `CAP-SHARING-001` — Content Share Studio

### Product promise

Let a person deliberately transform selected Ambitions content into an exact, audience-bound external representation with format controls, privacy review, redaction, provenance, and final preview before anything leaves the device.

### User outcome

The person can share progress, plans, proof, or selected context in a polished form without exposing the private life graph or manually rebuilding the content elsewhere.

### Recommended initial scope

Native share payloads plus polished visual and document exports. Every format uses the same audience, field-selection, redaction, provenance, and final-preview contract.

### Required controls

- Select source objects and exact included fields.
- Choose audience, purpose, and supported output format.
- Transform or summarize without mutating the source object.
- Review automatic redactions and manually exclude content.
- Preview the exact final representation and destination consequence.
- Record export/share Receipt and outcome where applicable.

### Non-goals

- A raw share-sheet button that exports uncontrolled source data.
- Social publishing, collaboration, or cloud hosting by implication.
- Mutating source objects to fit an external format.
- Sending private graph data to an Ambitions backend for rendering.

### Privacy and trust boundary

Sharing is explicit reviewed egress. Unknown classification, destination, or scope fails closed. Rendering remains local unless a separately approved named integration receives only the person-selected minimum payload.

### Supporting authority and systems

- `docs/canon/specifications/systems/privacy-and-data-classification.md`
- `docs/canon/specifications/systems/import-export-repair.md`
- `docs/canon/specifications/objects/attachment.md`
- `docs/canon/specifications/global/trust-inspection.md`
- Export, redaction, local rendering, Receipt/History, and system share integration

### Open decision

`DEC-SHARING-001-FORMATS`: initial output formats. Recommended default: **native payloads plus visual and document exports**.

---

## `CAP-KNOWLEDGE-001` — Goal-Attached Files and Knowledge

### Product promise

Let a person keep relevant local files, media, links, and reference material with a Goal so the material remains searchable, inspectable, recoverable, exportable, and meaningfully connected to the pursuit.

### User outcome

The person's supporting material stays with the work it informs instead of becoming detached files that must be rediscovered and reinterpreted elsewhere.

### Example experience

A person attaches a course syllabus, portfolio brief, reference links, and draft images to a photography Goal. Ambitions preserves stable Attachment identities and provenance, makes the material available from the Goal and Search, distinguishes files from Proof, and keeps unlink, Trash, restore, export, and permanent deletion consequences explicit.

### Required controls

- Ingest, link, unlink, rename metadata, replace, archive, Trash, restore, export, and permanently delete.
- Inspect source, availability, privacy class, parent relationships, and integrity status.
- Search attachment metadata and permitted derived text without leaking content.
- Distinguish removing a Goal link from deleting shared bytes.
- Recover from permission, bookmark, or local-availability loss.

### Non-goals

- A generic cloud drive or full document-management product.
- Treat Attachment as Proof, completion, or public content automatically.
- Delete shared content when one parent relationship is removed.
- Upload private files to Account, R2, Source Atlas, or hosted AI.

### Privacy and trust boundary

Attachment bytes, metadata, thumbnails, OCR, and relationships are private local data by default. Export/share and any future continuity route require explicit classification, preview, and consent.

### Supporting authority and systems

- `docs/canon/specifications/objects/attachment.md`
- `docs/canon/specifications/objects/goal.md`
- `docs/canon/specifications/systems/import-export-repair.md`
- `docs/canon/specifications/global/search.md`
- `docs/audits/persistence-storage-owner-map.md`
- Local Storage, Attachment lifecycle, Goal relationships, Search, and Trust Inspection

### Open decision

`DEC-KNOWLEDGE-001-SCOPE`: goal-first or object-wide product scope. Recommended default: **goal-first experience with object-capable architecture**.

---

## `CAP-RESILIENCE-001` — Local-First Operational Continuity

### Product promise

Keep accepted local truth and safe core operation useful during offline, stale, partial, interrupted, or recovering conditions while making limitations, affected scope, and repair paths explicit.

### User outcome

The person can continue understanding and using Ambitions without the product fabricating certainty, blocking valid local work, or obscuring what did and did not change.

### Required behavior

- Preserve accepted input and committed local objects wherever safe.
- Distinguish local success from failed external side effects.
- Disclose stale or unavailable external evidence only where interpretation changes.
- Preserve the last valid index or projection until a replacement is validated.
- Offer bounded retry, refresh, inspection, restoration, or owner handoff.
- Keep recovery accessible without requiring visual interpretation.

### Non-goals

- A separate warning center or diagnostics product.
- Pretend external writes succeeded because local mutation succeeded.
- Block local planning, Search, history, or inspection solely because the network is absent.
- Use generic error banners that hide affected identity and consequence.

### Privacy and trust boundary

Degraded-state information remains local and reveals only the permitted affected scope. Diagnostics and external retry use their dedicated privacy and authority boundaries.

### Supporting authority and systems

- `docs/canon/specifications/app/degraded-states.md`
- `docs/canon/specifications/surfaces/today.md`
- `docs/canon/specifications/global/search.md`
- `docs/canon/specifications/systems/persistence-and-replay.md`
- `docs/canon/specifications/systems/privacy-and-data-classification.md`
- Repair, Diagnostics, Persistence and Replay, Search, Today, and Trust Inspection

---

## Atlas-wide acceptance requirements

Before canonization, every approved capability must have:

1. A stable ID and owner-approved name.
2. A product promise, user outcome, example, and explicit non-goals.
3. One primary product domain and bounded secondary relationships.
4. Privacy classification and local/network boundary.
5. Person controls for consequential behavior.
6. Requirement and source provenance.
7. Independent authority, specification, implementation, and verification states.
8. A retirement or supersession path that requires explicit owner decision.

This draft intentionally does not infer implementation readiness from existing code, tests, visual work, or audit prose.