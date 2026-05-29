# EB02 Universal Capture Canon And Domain Model Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

## Batch Identity

- Batch ID: EB02
- Name: Universal Capture Canon And Domain Model
- Global order after EB insertion: 048

## Active 4.0 Status

Active planned Ambitions 4.0 External Brain Foundation scope. Not completed. Not app behavior until this batch or a later batch changes code, validates it, commits it, and records evidence.

## Purpose

Advance Universal Capture Canon And Domain Model inside the EB train with exact ownership, evidence, privacy, accessibility, and no-overwrite controls. Canon/domain planning; no production implementation in EB02 until exact domain files are approved by gate.

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

- docs/canon docs/codex Native/Ambitions/Domain only if later implementation gate opens
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

If UI is allowed, it must stay inside Today / Goals / Capture / Plan / You or owned drill-downs, use SI/PXOS rules, and reject stacked-card surface structure.

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

May claim only EB02 evidence after validation and commit.

## Non-Claims

Must not claim whole External Brain implementation, production readiness, TestFlight/App Store readiness, physical-device proof, public accessibility proof, legal/privacy signoff, market proof, or release readiness.

## Commit Message

`Run EB02 Universal Capture Canon And Domain Model`

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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
