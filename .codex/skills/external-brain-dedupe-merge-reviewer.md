# External Brain Dedupe Merge Reviewer

## Purpose

Review Ambitions 4.0 External Brain work in this lane and protect the train from duplicate source truth, unsupported claims, privacy drift, accessibility gaps, feature sprawl, and implementation without evidence.

## When It Applies

Use for EB01-EB40 prompts, canon, integration reports, review boards, validation scripts, implementation boundaries, and any future code batch that touches External Brain scope.

## Source-Truth Hierarchy

1. `README.md`
2. `AGENTS.md`
3. `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
4. `docs/canon/Ambitions_4_0_External_Brain_Foundation_Index.md`
5. Target EB kernel canon
6. PXOS, SI, Product Depth, AmbitionsOS, privacy, accessibility, and release-claim docs named by the batch
7. `docs/codex/BATCH_REGISTRY.md` for status truth only

## Inputs Required

- Batch prompt or diff.
- Files changed.
- Source docs read.
- Allowed and forbidden files.
- Validation commands and logs.
- Privacy, accessibility, release-claim, and rollback evidence.

## Review Checklist

- Ambitions remains a life OS, not a notes app, chatbot wrapper, CRM clone, dashboard, generic task app, or feature dump.
- External Brain is active Ambitions 4.0 scope and not framed as a prior-version or post-program lane.
- Kernels remain coherent and do not duplicate existing canon.
- Capture reduces load, routes are understandable, and correction exists.
- Memory has source, confidence, edit, delete, rejection, stale review, and receipt controls.
- Trust controls expose evidence, undo, correction, audit, export, delete, source freshness, and privacy boundaries.
- Onboarding demonstrates first-week value, supports skip/later, and avoids pressure.
- Accessibility covers Dynamic Type, VoiceOver, Reduce Motion, non-color meaning, motor alternatives, plain language, and cognitive load.
- Release/platform/legal/privacy/public-accessibility claims are not made without matching evidence.

## Evidence Required

Source docs, exact files, validation logs, claim scan, privacy scan, accessibility scan, dedupe map result, implementation boundary result, and rollback plan.

## Green Criteria

Scope is exact, source truth is current, no forbidden files changed, validation is Green or advisory-only, and claims match evidence.

## Yellow Criteria

Existing repo-wide advisory, tooling advisory, future implementation deferred to a named EB batch, human/platform proof deferred, or dedupe ambiguity safely referenced without duplicate source truth.

## Red Criteria

Forbidden file touched, duplicate active canon created without map, forbidden prior-version active naming, unsupported implementation claim, privacy/accessibility/release overclaim, hidden inference, no correction/delete/undo path, or vague prompt ownership.

## Forbidden Approvals

Do not approve hidden memory, unsupported recommendations, broad capture automation, forced sensitive setup, new top-level destinations, dependency/workflow changes, release claims, or production Swift in docs/canon batches.

## Repair Guidance

Narrow the batch, name the owner, restore source-truth hierarchy, add missing evidence, park unsafe implementation as Yellow, or stop Red with a repair prompt.

## What It May Claim

It may claim review of the named EB scope after evidence is recorded.

## What It Must Not Claim

It must not claim product implementation, platform proof, App Store/TestFlight readiness, physical-device proof, legal/privacy signoff, public accessibility conformance, or market proof.

## Relation To Active 4.0 Train

This skill supports EB01-EB40 as active planned Ambitions 4.0 scope and preserves existing 4.0 status truth.

## Relation To No-Overwrite / Dedupe Policy

Prefer update/reference of canonical owners, preserve historical audit truth, and create new files only when the dedupe map allows it.
