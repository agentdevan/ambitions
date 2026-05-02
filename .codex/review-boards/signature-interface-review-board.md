# Signature Interface Review Board
<!-- markdownlint-disable MD013 -->

## Purpose

This board gates Signature Interface canon, prompts, implementation batches,
and SI-derived Product Depth or AOS24 UI integration.

## Member Roles

- Signature Interface creative director.
- Ambitions native UI primitive reviewer.
- Top-level surface composition reviewer.
- IA shell/navigation reviewer.
- Interaction motion/haptics reviewer.
- Accessibility adaptive interface reviewer.
- Visual QA preview fixture reviewer.
- SI file-size/component-boundary reviewer.
- Release-claim safety auditor.

## Required Source Truth

- `README.md`
- `AGENTS.md`
- Ambitions 3.0 source-of-truth and primitive docs.
- PXOS surface, visual, accessibility, and Product Depth canon.
- `docs/canon/Ambitions_Signature_Interface_System.md` when present.
- Relevant SI prompt and current SwiftUI source.

## Required Evidence Package

- Dry-run selection and execution budget.
- Changed files and file-size snapshot.
- Component state matrix.
- Invented-but-native rubric scores.
- Preview/screenshot or visual QA evidence where UI changed.
- Accessibility/Reduce Motion notes.
- Anti-generic UI, top-level composition, and release-claim scans.
- Rollback path and non-claims.

## Review Sequence

1. Source-truth and scope review.
2. Invented-but-native rubric.
3. Anti-generic UI review.
4. Top-level composition review when a top-level surface is touched.
5. IA/shell/navigation review.
6. Accessibility/adaptive review.
7. Interaction/motion/haptics review.
8. Preview/visual QA review.
9. File-size/component-boundary review.
10. Release-claim safety review.

## Voting And Gate Standard

Green requires all Red-free gates, invented-but-native average score at least 4,
no rubric category below 3, Strong validation for implementation, and complete
evidence. Yellow requires a named owner and safe continuation rationale. Red
blocks continuation.

## Invented-But-Native Rubric

Score 1-5 for originality, native iPhone believability, usefulness, restraint,
accessibility, emotional tone, system coherence, and maintainability.

## Anti-Generic UI Review

Reject generic card stacks, dashboards, calendar clones, habit tracker UI,
chatbot wrappers, notes/inbox surfaces, project-management boards, fake AI
glow, and vague productivity language.

## Accessibility And Adaptive Review

VoiceOver order, Dynamic Type behavior, Reduce Motion equivalents, non-color
meaning, tap targets, privacy redaction, and cognitive load must be reviewed.

## Preview And Visual QA Review

UI-changing batches need deterministic previews, state matrix, screenshot or
visual QA evidence where tooling allows, and explicit human/device proof
non-claims.

## File-Size And Component Boundary Review

Every Swift file touched by SI needs before/after size evidence. New
components need responsibility names and ownership. Giant view files and
generic utility buckets are Yellow or Red.

## Yellow Classification Protocol

Classify Yellow as Fix Now, Already Owned by Later Batch, Existing Repo-Wide
Advisory, Tooling/Environment Advisory, Human-Proof Advisory, or Needs New
Repair Batch. Deferral needs owner, safety rationale, and revisit point.

## Red Stop Protocol

Stop for generic UI drift, top-level card-stack regression, missing UI proof,
missing state matrix, accessibility blocker, weak implementation validation,
route/raw/persistence break, unsupported release/platform claim, or false SI
implementation claim.

## Release-Claim Safety Review

Never claim SI, PXOS, PD, or AOS implementation beyond committed evidence.
Never claim App Store, TestFlight, physical-device, public accessibility,
signed archive, legal/privacy, platform, human visual approval, or final
release proof without actual proof.
