# Global Batch FAANG Quality Bar

<!-- markdownlint-disable MD013 -->

Status: Ambitions 4.0 global Codex OS control; no queued train started
Date: 2026-05-02

## Product Quality Requirements

- Product intent is clear and source-bound.
- Work preserves `Today / Goals / Capture / Plan / You`.
- Ambitions remains a premium native life execution system.
- Work advances the core loop: Capture, Place, Plan, Do Today, Close/Recover, Save Proof.
- No new top-level destination is added.
- No generic task-app, habit-tracker, calendar-clone, chatbot, notes, analytics dashboard, or SaaS control-panel drift is introduced.
- Top-level surfaces remain visual orientation surfaces with drill-down discipline.

## Architecture Requirements

- Ownership is clear before implementation.
- Dependencies are minimal and policy-approved.
- Runtime contracts are typed.
- UI state and business logic are separated where the codebase pattern supports it.
- Projectors/services/models own logic that should not live in views.
- Compatibility seams are retired only through CS proof.
- AmbitionsOS/PXOS canon is not treated as implemented behavior.

## Maintainability Requirements

- File sizes are checked before and after code batches.
- Large owner files receive extraction before expansion.
- Diffs are narrow and reviewable.
- Refactor and feature work are not mixed unless explicitly scoped.
- Tests and preview fixtures are updated when behavior changes.
- No batch makes future extraction harder without a documented Yellow owner.

## Accessibility Requirements

- Dynamic Type is considered for UI changes.
- VoiceOver labels and navigation order are preserved or improved.
- Reduce Motion equivalents exist where motion is meaningful.
- No color-only meaning.
- Visible alternatives exist for gestures.
- Cognitive load is reviewed for top-level and recovery flows.

## Visual Quality Requirements

- UI is calm, native, premium, and restrained.
- Top-level tabs prioritize visual state, spatial hierarchy, one primary object or decision, and drill-down entry points.
- Cards are used with purpose, not as same-size stacks that become the whole screen.
- Visual proof is required for meaningful UI work where tooling supports it.

## Copy And Language Requirements

- Language uses Ambitions 3.0/PXOS terms where appropriate.
- Copy avoids shame, fake precision, fake certainty, AI theater, and model jargon.
- User-facing intelligence is source-grounded and trust-aware.
- Release and platform copy stays bounded by evidence.

## Trust And Proof Requirements

- Meaningful changes are user-visible and reversible where relevant.
- Proof, receipt, source, freshness, correction, export/import, and local-first boundaries are preserved.
- Private or sensitive projections are redacted appropriately.
- No hidden automation or silent rescheduling.

## Release-Claim Requirements

- No App Store, TestFlight, production, final RC, physical-device, signed archive, App Store Connect, public accessibility, external rendered proof, AmbitionsOS implementation, or PXOS implementation claim without evidence.
- Human-only proof stays human-only.
- Simulator proof is useful but not platform readiness.

## Test Quality Requirements

- Tests are meaningful for the risk changed.
- Implementation batches require Strong validation unless explicitly impossible and owned.
- Tests are not deleted, loosened, or rewritten to match broken behavior.
- Flakes are classified rather than ignored.
- Advisory validation is documented as advisory.

## File-Size Discipline

Prefer extraction, decomposition, narrow helpers, testable projectors, focused models, preview fixtures, small views, separated state, separated copy, and scoped services over adding code to already-large files.

## Anti-Degradation Rules

Unacceptable fixes include:

- Making UI generic to pass tests.
- Replacing visual orientation with stacked cards.
- Removing accessibility requirements.
- Removing compatibility safeguards.
- Weakening PXOS or Ambitions 3.0 canon.
- Hiding release uncertainty.
- Adding dependencies to avoid clean implementation.
- Broadening scope to dodge a failing gate.
- Disabling tests without replacement or documented retirement.
- Changing train status to make a report look Green.
