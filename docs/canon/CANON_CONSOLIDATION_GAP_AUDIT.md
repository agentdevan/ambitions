# Ambitions Canon Consolidation Gap Audit

Status: Active canon consolidation layer.

Purpose: Record what the repo already covers, what was consolidated, and what still needs product decisions. This is a documentation architecture audit, not a feature implementation gap audit.

## Executive Summary

The Ambitions repo is not missing the major product/design canon stack. It already contains product truth, design truth, IA, UX writing, surface ownership, systems architecture, visual doctrine, intelligence standards, accessibility posture, roadmap sequencing, batch governance, and review/QA material.

The actual weakness was distribution: many truths existed, but they were spread across broad master docs, architecture docs, visual docs, matrices, and historical/support docs. That creates risk for Codex and future planning because the same concept can appear in multiple places at different levels of specificity.

The consolidation pass added narrower implementation-readable docs that extract existing doctrine without replacing the active canon stack.

## Consolidated Docs Added

- `SOURCE_OF_TRUTH_MAP.md`
- `DOMAIN_MODEL.md`
- `GOAL_PLAN_TASK_LIFECYCLE.md`
- `ONBOARDING_SPEC.md`
- `TRUST_PRIVACY_MEMORY.md`
- `EMPTY_ERROR_RECOVERY_STATES.md`
- `IMPLEMENTATION_ACCEPTANCE_GATES.md`
- `design/DESIGN_TOKENS.md`

## What Already Existed

| Area | Existing strength |
| --- | --- |
| Product identity | Strong. The product promise and personal life organization system positioning are already present. |
| IA / shell | Strong. Today, Goals, Capture, Plan, You are locked. Insights/Habits demotion is clear. |
| Surface ownership | Strong. Product Architecture defines tab responsibilities and forbidden top-level content. |
| Visual doctrine | Strong. Visual System defines rich panels, dark-first direction, shell, Goal Weather, Proof Spine, Lifecycle Rail, etc. |
| Component behavior | Strong. Component contract matrix defines anatomy, actions, accessibility, motion, and fallbacks. |
| UX writing | Strong. Voice, disallowed language, labels, receipts, recovery wording, and state language exist. |
| Intelligence | Strong direction. Intelligence Standards prevent generic task-app behavior and define context, priority, commitment capture, and explanations. |
| Systems | Strong. Systems Architecture assigns ownership to shared layers and avoids duplicate engines. |
| Roadmap | Strong but large. Roadmap and Batch Plan have detailed future sequencing. |
| Accessibility posture | Strong doctrine. Verification boundary is correctly cautious. |

## Primary Weaknesses

### 1. Authority Overlap

The same high-level truths appear in multiple files:

- product identity appears in Master Product Spec and Design Constitution
- shell and IA appear in Master Product Spec, Design Constitution, and Product Architecture
- visual doctrine appears in Visual System and component/design matrices
- trust appears in Design Constitution and Systems Architecture

This is not inherently wrong, but it is dangerous without a source-of-truth map. Codex may pick the wrong file or treat supporting context as equal authority.

Mitigation added:

- `SOURCE_OF_TRUTH_MAP.md`

### 2. Planned Canon vs Shipped Code Ambiguity

Some docs describe future systems in product-truth language. That is useful for roadmap direction, but implementation summaries must distinguish:

- implemented behavior
- foundation model exists
- UI not yet implemented
- planned canon only
- platform review still required

Mitigation added:

- `IMPLEMENTATION_ACCEPTANCE_GATES.md`
- explicit planned-vs-shipped checklist in completion template

Remaining gap:

- Future batch prompts should always include planned-vs-shipped reporting.

### 3. Object Model Spread

The object model existed, but across multiple documents:

- Life Area / North Star / Goal / Path / Plan hierarchy
- Task vs Step distinction
- Proof / Decision / Receipt / Review roles
- Smart Attachment and Capture routing

Mitigation added:

- `DOMAIN_MODEL.md`

Remaining gap:

- Field-level schema should be reconciled against actual Swift models in a future implementation audit.

### 4. Lifecycle Was Implied More Than Executable

Goal Lifecycle Rail, Goal Weather, Completion Archive, Proof Spine, Decision Trail, Plan Treaty, Reality Reflow, and Task/Step behavior were already described, but there was no compact lifecycle/state machine reference.

Mitigation added:

- `GOAL_PLAN_TASK_LIFECYCLE.md`

Remaining gap:

- Final user-facing labels for states such as Dropped, Cancelled, Broken, Fragile, and Foggy need product decisions.

### 5. Onboarding Was Directional, Not Screen-Level

The Design Constitution already defined onboarding principles, but did not fully specify a step-by-step first-run flow.

Mitigation added:

- `ONBOARDING_SPEC.md`

Remaining gap:

- Final onboarding path needs decisions on examples, Life Area requirement, appearance setup timing, and first landing destination.

### 6. Trust / Privacy / Memory Was Important Enough To Stand Alone

Trust existed in the Design Constitution and Systems Architecture, but because Ambitions wants to organize a user's life, trust deserves its own direct implementation reference.

Mitigation added:

- `TRUST_PRIVACY_MEMORY.md`

Remaining gap:

- Memory confirmation policy, undo duration, privacy modes, and export scope need final decisions.

### 7. Non-Ideal States Needed A Surface Matrix

UX state language existed, but there was no screen-by-screen empty/error/recovery state spec.

Mitigation added:

- `EMPTY_ERROR_RECOVERY_STATES.md`

Remaining gap:

- Final copy for the most sensitive states should be reviewed in question waves.

### 8. Visual Tokens Needed Implementation Names

The visual system was strong conceptually, but implementation work benefits from explicit token names.

Mitigation added:

- `design/DESIGN_TOKENS.md`

Remaining gap:

- Actual SwiftUI token files should be reconciled to this doc in a later implementation batch.

### 9. Completion Standards Were Spread Across QA/Review Docs

Visual review, RC maturity, roadmap, and batch docs contained acceptance expectations. Future implementation needs one generic gate document.

Mitigation added:

- `IMPLEMENTATION_ACCEPTANCE_GATES.md`

Remaining gap:

- Future batch docs should include an acceptance-gate section by default.

### 10. Historical Docs Can Still Create Drift

The repo preserves useful archived/historical docs. They should remain available, but not override active canon.

Mitigation added:

- `SOURCE_OF_TRUTH_MAP.md`
- updated canon/design indexes

Remaining gap:

- Future prompts must explicitly say archived docs are historical only.

## Product Decision Gaps For Question Waves

The next step is not more document creation. The next step is answering product questions that fill the open areas inside the new docs.

Question waves should cover:

1. Product identity and life-area defaults.
2. Domain model and lifecycle labels.
3. Onboarding first-run behavior.
4. Trust, privacy, memory, and receipts.
5. Empty/error/recovery copy tone.
6. Design tokens, appearance, density, and theme behavior.
7. Acceptance gates and Codex workflow strictness.
8. Future implementation priority and batch integration.

## Recommended Rule Going Forward

Do not add a new major canon doc unless it does one of three things:

1. Extracts repeated active doctrine into a narrower implementation reference.
2. Records a product decision that resolves ambiguity.
3. Defines acceptance criteria for implementation or QA.

Avoid creating parallel roadmaps, parallel product constitutions, or alternate design systems.
