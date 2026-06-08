> Supporting note: This file supports Ambitions primitive governance. It does not override `docs/truth/*`, live source, current validation logs, or release proof.

# Ambitions Primitive Green Gate

Status: Active supporting governance
Scope: Gate checklist for proposed or promoted UI primitives
Owner posture: Gate definition, not proof by itself

## Purpose

This gate defines when a primitive-related issue may report Green. It is stricter than "the file exists" and narrower than release proof.

## Green Requirements

A primitive issue may report Green only when all applicable items are satisfied:

- The active truth files were inspected.
- The primitive has a named owner surface and product object.
- Existing primitive owners were searched before invention.
- No parallel implementation was introduced.
- The primitive avoids top-level pile-of-panels, generic metric-board, chat-transcript, calendar-copy, habit-ranking, points, reward-counter, and guilt-pressure patterns.
- The source path is listed exactly, or the issue is docs-only and lists docs paths exactly.
- Accessibility fallback is documented for VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, Differentiate Without Color, and tap targets when the primitive affects UI.
- Runtime inspection path is listed when the primitive touches recommendations, source, receipts, proof, personalization, or local learning.
- Focused test, preview, screenshot, source audit, or manual proof is recorded when applicable.
- Any skipped validation is named with a concrete reason.
- No release, device, public accessibility, performance, privacy/legal, TestFlight, App Store, or product-completion claim is made without matching proof.

## Yellow Conditions

Report Yellow when the scoped install or implementation is correct, but one or more non-blocking evidence items remain:

- Current screenshot proof is blocked or missing.
- Manual VoiceOver traversal is not yet available.
- Visual review is not provided.
- A focused test does not exist and should not be invented for the issue.
- A follow-up owner issue is filed for missing proof.

Yellow closeout must name the owner issue or explicitly say `none needed`.

## Red Conditions

Report Red when any of these occur:

- UI source changes outside scope.
- Active truth files are contradicted.
- A new primitive duplicates an existing owner without approval.
- Top-level pile-of-panels or generic metric-board structure remains.
- Capture becomes a tab, generic holding bin, notes stream, chat-transcript, or always-visible utility button.
- Motion becomes generic measurement-board, social-style stream, points system, reward-counter, or productivity recap.
- Time becomes calendar density, schedule optimization, or resource allocation.
- Claims exceed available evidence.

## Required Primitive Gate Footer

```markdown
Primitive gate verdict: Green / Yellow / Red
Owner surface:
Product object:
Existing owners inspected:
New primitive created:
Existing primitive extended:
Accessibility fallback:
Runtime inspection path:
Focused validation:
Proof artifacts:
Remaining Yellow debt:
No-claim boundary:
```
