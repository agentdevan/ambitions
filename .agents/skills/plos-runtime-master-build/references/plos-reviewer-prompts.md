# PLOS Reviewer Prompts

Status: Active read-only reviewer prompt library
Use: Copy the relevant prompt into a read-only reviewer/subagent pass. Reviewers inspect and report; the main agent owns edits.

## Shared Reviewer Input Packet

Provide this context to every reviewer:

- Active issue: `<AMB-* issue id and title>`
- Phase: `<M## / PLOS-M##>`
- Scope: `<readiness/governance/source/ui/validation/etc.>`
- Changed files: `<git diff --name-only>`
- Truth files inspected: `<list>`
- Validation run so far: `<commands and outcomes>`
- Proof boundary: `<what is not claimed>`

## Phase-Order And Linear Binding Reviewer

Prompt:

Review this PLOS packet for phase-order, Linear identifier, and synthetic issue drift risks. Confirm that every PLOS label used for execution is bound to an actual `AMB-*` issue, that Linear fetch/update/comment/closeout targets use `AMB-*` identifiers, and that the phase order matches `artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json`. Treat any `PLOS-M##` or `PLOS-###` Linear identifier use as Red. Return findings first with file/line references, then Green/Yellow/Red, then required repair.

## Privacy / Local-First / R2 Reviewer

Prompt:

Review this PLOS packet for privacy, local-first architecture, and R2 boundary drift. Confirm that core runtime behavior remains local-first and inspectable, that no required cloud LLM or custom server dependency is introduced, and that R2/Source Atlas material is public-reference-only with no private user data. Treat private user data in R2, required cloud LLM core behavior, telemetry/tracking drift, or unproven privacy claims as Red. Return findings first with file/line references, then Green/Yellow/Red, then required repair.

## Source Atlas Boundary Reviewer

Prompt:

Review this PLOS/Source Atlas packet for Source Atlas Factory boundary quality. Confirm that existing Source Atlas tooling is reused or extended, pack/seed release gates include source binding, freshness, revocation, review, release receipt, rollback, and runtime eligibility, and no duplicate architecture or unreviewed runtime pack path is introduced. Treat missing release receipt, missing revocation, missing source binding, private data in public packs, or runtime eligibility without gates as Red. Return findings first with file/line references, then Green/Yellow/Red, then required repair.

## Runtime Architecture Reviewer

Prompt:

Review this PLOS packet for Ambitions runtime architecture integrity. Confirm that the change stays inside the active issue scope, preserves the Private Life Runtime moat, avoids generic task/calendar/dashboard/chatbot patterns, avoids duplicate ownership, and does not claim runtime behavior that source/tests do not prove. Treat required cloud runtime, hidden recommendation mutation, missing receipts, broad runtime expansion before M10, or source ownership ambiguity as Red. Return findings first with file/line references, then Green/Yellow/Red, then required repair.

## Visual / Accessibility Reviewer

Prompt:

Review this PLOS packet for UI, accessibility, and product-quality proof if any user-facing surface changed. Confirm native iPhone quality, safe areas, Dynamic Type, VoiceOver semantics, Reduce Motion, Reduce Transparency, Increase Contrast, tap targets, copy language, and avoidance of dashboard/card/list/chatbot/calendar-clone anatomy. Treat ugly UI, clipped text, unsafe shell geometry, missing accessibility semantics, or screenshot-path-only proof as Yellow or Red depending on severity. Return findings first with file/line references, then Green/Yellow/Red, then required repair.

## Validation / Closeout Reviewer

Prompt:

Review this PLOS closeout for proof honesty. Confirm that the closeout lists actual `AMB-*` issue IDs, changed files, validation commands, validation failures, Yellow limits, Red blockers, Linear update target, commit/push state, and next eligible action. Confirm that it does not claim owner approval, runtime implementation, release readiness, accessibility verification, privacy/legal approval, performance verification, TestFlight/App Store readiness, or PLOS phase completion without evidence. Return findings first with file/line references, then Green/Yellow/Red, then required repair.
