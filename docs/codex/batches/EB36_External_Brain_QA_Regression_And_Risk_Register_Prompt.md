# EB36 External Brain QA Regression And Risk Register Prompt

<!-- markdownlint-disable MD013 -->

## Batch Identity

- Batch ID: EB36
- Name: External Brain QA Regression And Risk Register
- Global order after EB insertion: 082

## Active 4.0 Status

Active planned Ambitions 4.0 External Brain Foundation scope. Not completed. Not app behavior until this batch or a later batch changes code, validates it, commits it, and records evidence.

## Purpose

Advance External Brain QA Regression And Risk Register inside the EB train with exact ownership, evidence, privacy, accessibility, and no-overwrite controls. QA/risk batch; production implementation is not allowed unless a named repair batch follows.

## User-Visible Outcome

The eventual user-facing outcome must make life context easier to capture, understand, trust, recover, or control while preserving Today / Goals / Capture / Plan / You. This prompt alone creates no user-visible behavior unless its allowed files and validation lane explicitly permit implementation.

## Source Truth

- README.md
- AGENTS.md
- docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md
- docs/canon/Ambitions_4_0_External_Brain_Foundation_Index.md
- docs/canon/Ambitions_4_0_External_Brain_Cross_Kernel_Primitives_And_Dependencies.md
- docs/codex/EB_EXTERNAL_BRAIN_DEPENDENCY_GRAPH.md
- docs/codex/BATCH_REGISTRY.md
- docs/codex/CONTEXT_INDEX.md

## Allowed Files

- tests docs audits .codex only
- docs/audits/** for this batch report
- .codex/reports/** for run-state evidence

## Forbidden Files

- Native/**, Sources/**, AppUI/**, tests, project.yml, .github/workflows/**, dependencies, lockfiles, signing, App Store/TestFlight files, persistence/schema, production Swift

## Kernel Ownership

Name the owning EB kernel before edits. If the work crosses kernels, cite the cross-kernel dependency rule and owner of each primitive.

## Cross-Kernel Dependencies

Respect EB13 Trust and EB25 Accessibility early gates. Universal Capture cannot create durable memory without Trust controls. Durable memory requires source, confidence, edit, delete, and receipt paths.

## PXEQ Product Experience Requirements

UI-affecting work must read `docs/codex/PXEQ_PRODUCT_EXPERIENCE_EQUIVALENCE_GATE.md`, `docs/codex/PXEQ_LIVING_INTERFACE_RUBRIC.md`, `docs/codex/PXEQ_SURFACE_BEHAVIOR_MATRIX.md`, `docs/codex/PXEQ_VISUAL_SYSTEM_CONSERVATIVE_FUTURISM_RULES.md`, `docs/codex/PXEQ_MOTION_AND_STATE_CHANGE_RULES.md`, `docs/codex/PXEQ_MINIMALISM_WITH_UTILITY_RULES.md`, and `docs/codex/PXEQ_UI_IMPLEMENTATION_EVIDENCE_TEMPLATE.md`. The batch report must record either no UI changed or PXEQ evidence: primary visual object, living/evolving state reason, before/after product-experience impact, preview/fixture evidence, Reduce Motion/Dynamic Type/VoiceOver/tap target/contrast/non-color proof, and anti-generic checks. Technical pass with mediocre, generic, static, cluttered, unreadable, noisy, decorative, or overbuilt experience is Yellow or Red depending on severity.

UI-affecting work must also cite `docs/canon/Ambitions_4_0_Signature_Experience_Layer.md`, `docs/canon/Ambitions_4_0_Transformative_Motion_System.md` when motion is affected, and `docs/reference/visual-targets/ambitionsos-photo-matched/README.md`; it must record SIG scorecard, DAV scorecard, photo-matched reference evidence, preview evidence, accessibility evidence, Reduce Motion evidence, and Transformative Motion QA when motion is affected.

## Privacy Requirements

Classify sensitive data, local-first posture, permission boundary, export/delete impact, source freshness, private mode, and privacy receipt needs.

## Trust/User-Control Requirements

Every intelligent action needs evidence, undo or correction where applicable, receipt, and clear user control. No hidden inference or silent automation.

## Accessibility Requirements

Document Dynamic Type, VoiceOver order, Reduce Motion equivalent, non-color meaning, tap target, motor alternative, and public-claim boundary.

## Cognitive Load Requirements

Show how the batch reduces load, avoids shame, supports overloaded days, uses plain language, and keeps detail behind deliberate drill-downs.

## Interaction/UI Requirements

If UI is allowed, it must stay inside Today / Goals / Capture / Plan / You or owned drill-downs, use SI/PXOS rules, and reject stacked-card dashboard structure.

## Domain Model Requirements

If domain work is allowed, model names, raw values, persistence impact, fixtures, migration, import/export, and rollback must be explicit before changes.

## Evidence Requirements

Batch report, files read, files changed, no-overwrite result, privacy result, accessibility result, release-claim scan, validation logs, Yellow/Red classifications, and next safe path.

## Validation Commands

- git status --short
- git diff --check
- scripts/eb-active-train-integration-gate.sh || true
- scripts/eb-no-unsupported-claim-scan.sh || true
- scripts/eb-no-5-version-drift-scan.sh || true
- scripts/run-doc-qa.sh || true
- scripts/batch-train-gate-check.sh || true
- Focused tests named by this prompt when implementation is allowed

## Green Criteria

Source truth current, exact owner named, allowed files respected, validation Green or advisory-only, privacy/accessibility/claim evidence present, and no existing status changed outside this batch.

## Yellow Criteria

Existing repo-wide advisory, tooling/environment advisory, future implementation deferred to a named EB batch, human/platform proof deferred, or safe dedupe reference.

## Red Criteria

Forbidden file touched, forbidden prior-version active naming, unsupported implementation or release claim, missing source/confidence/delete for memory, missing route/correction for capture, missing accessibility gates, or changed existing batch statuses.

## Stop Conditions

Stop on Red, dirty unknown changes, source-truth conflict, weak validation, broad scope, or request to touch forbidden files.

## Rollback And Repair

Revert only unsafe changes from this batch, preserve historical evidence, classify Yellow/Red, and write a repair prompt.

## Claims

May claim only EB36 evidence after validation and commit.

## Non-Claims

Must not claim whole External Brain implementation, production readiness, TestFlight/App Store readiness, physical-device proof, public accessibility proof, legal/privacy signoff, market proof, or release readiness.

## Commit Message

`Run EB36 External Brain QA Regression And Risk Register`

## Next Safe Path

Continue only on Green or accepted Yellow under global train rules; otherwise stop with repair or decision prompt.

## No-Overwrite Requirements

Do not overwrite recent 4.0 changes or historical audit truth. Reference canonical owners when dedupe is uncertain.

## Existing-Canon Merge Requirements

Search existing Capture, memory, trust, onboarding, accessibility, PXOS, AOS, SI, Product Depth, review-board, skill, and validation docs before creating new source truth.

## File-Size/Diff-Size Budget

Keep the diff narrow. If code is allowed, name files before edits and stop if owner files become broader than the batch evidence can validate.

## Focused Test Expectations

Docs-only batches run doc/gate scans. Implementation batches must add or rerun focused tests for the changed model, UI, receipt, routing, privacy, accessibility, or fixture behavior.

## Preview/Fixture Expectations

UI batches need preview or fixture evidence for normal, empty, sensitive, correction, accessibility, and overloaded-day states where relevant.

## Release-Claim Scan Requirement

Run a release-claim scan and classify hits as forbidden lists, explicit non-claims, historical truth, or Red unsupported claims.
