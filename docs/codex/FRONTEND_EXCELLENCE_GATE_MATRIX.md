# Frontend Excellence Gate Matrix

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Active Codex OS gate matrix for future frontend/UI-touching batches
Date: 2026-05-09
Batch: CQS25 / FET00

## Gate Result Contract

Each FET gate returns Green, Yellow, or Red with rationale, evidence, required repair if Red, deferral owner if Yellow, and evidence required before continuation.

## Gate Matrix

| Gate | Applies when | Green | Yellow | Red | Owner/review skill |
| --- | --- | --- | --- | --- | --- |
| FET Applicability Gate | Every batch dry-run | Batch declares whether it is UI-touching, docs-only UI governance, preview/screenshot infrastructure, or not applicable. | Ambiguous surface impact is owned before edits. | UI-touching work proceeds without FET classification. | `faang-frontend-implementation-lead` |
| Screenshot / Preview Evidence Gate | UI, visual, motion, chrome, widget, Live Activity, App Intent confirmation, or screenshot work | Fresh simulator screenshot or meaningful preview evidence exists and limitations are named. | Missing only for docs-only governance or tooling that makes no rendered UI claim. | UI-touching work has no screenshot/preview evidence, or build/test proof is substituted for visual proof. | `screenshot-visual-qa-reviewer` |
| First Viewport Composition Gate | Top-level or landing/detail first screen work | One primary object, max two support objects, no competing primary surfaces, chip/body-copy/floating-control/bottom-nav budgets respected. | Minor density risk owned with screenshot evidence. | More than one primary object, more than two support objects, more than four chips, more than twelve body-copy lines, more than one floating control, more than one active bottom navigation system, architecture copy, or generic stacked hero/panel pile above the fold. | `first-viewport-composition-reviewer` |
| Bottom Chrome Ownership Gate | Shell, tab, toolbar, floating action, receipt overlay, global actions, top-level navigation | Native tab bar/custom rail/FAB/toolbar roles are separated and screenshot evidence proves no competition. | Nonblocking overlap risk has owner and no current UI claim. | Native tab bar, custom tab rail, floating global action, toolbar, or receipt overlay compete visually or obscure each other. | `bottom-chrome-navigation-reviewer` |
| Primitive Identity Gate | Signature object, primitive, panel, card, list, rail, spine, field, fold, receipt, drawer, composer, map | Primitive has Ambitions-specific role, density role, anatomy, state matrix, and screenshot/preview evidence. | Existing generic debt is named with owner and not worsened. | Signature object becomes a generic rounded card, surface panel, list wall, chip grid, nested-panel container, or decorative wrapper. | `primitive-misuse-density-reviewer` |
| Copy Compression Gate | User-facing UI copy | Copy states user value, next action, source/trust only when useful; root copy is compressed. | Minor wording debt owned. | Product explains internal architecture, compliance, AI/model machinery, or implementation names instead of user value. | `copy-compression-product-language-reviewer` |
| Accessibility Resilience Gate | Any UI-touching work | Dynamic Type, VoiceOver, touch target, contrast/non-color, Reduce Motion/cognitive-load evidence exists. | Human/manual accessibility proof still pending and no public claim is made. | Identifiers exist but Dynamic Type, VoiceOver, touch target, contrast, or reduced cognitive load evidence is missing for touched UI. | `ios-product-design-director`, `swiftui-senior-systems-engineer` |
| Motion Meaning Gate | Animation, transition, haptics, motion, live state, reduced motion | Motion orients/confirms/reduces uncertainty and has Reduce Motion or non-motion equivalent. | Motion polish deferred with owner and safe fallback. | Motion is decorative, unexplained, gamified, or lacks Reduce Motion equivalent. | `ios-product-design-director`, `swiftui-senior-systems-engineer` |
| Surface Distinction Gate | Today / Goals / Capture / Time / You or cross-surface work | Each touched surface has distinct object language and first-glance role. | Existing interchangeability debt is named and not worsened. | Top-level surfaces look visually interchangeable. | `ios-product-design-director`, `faang-frontend-implementation-lead` |
| Frontend Scorecard Gate | UI-touching batch closeout | Average >= 90, no category below 85, no hard Red. | Average 80-89 with no hard Red and owner. | Average below 80, missing scorecard, or any hard Red. | `faang-frontend-implementation-lead` |
| Route / Compatibility Safety Gate | UI work near routes, raw values, persistence, external URLs, defaults, schema | No route/raw/persistence/schema/dependency/signing/workflow change, or explicit compatibility proof exists if approved. | Compatibility seam remains internal with owner. | Route/raw/persistence/schema/dependency/signing/workflow changed outside explicit scope. | `swiftui-senior-systems-engineer` |
| Release Claim Safety Gate | Any UI quality, screenshot, accessibility, release, App Store, TestFlight, premium/flagship claim | Claims match screenshot/rubric/manual evidence and non-claims are stated. | Aspirational/internal language is clearly non-release and owned. | Premium, flagship, Apple-level, FAANG-level, 10/10, visual approval, accessibility approval, release-ready, App Store-ready, or TestFlight-ready claim lacks required evidence. | `faang-frontend-implementation-lead` |

## Batch-Type Gate Packs

- Docs-only frontend governance: FET Applicability, Copy Compression if UI language is defined, Release Claim Safety, Handoff, Rollback.
- Preview/screenshot infrastructure: FET Applicability, Screenshot / Preview Evidence, Accessibility Resilience, Route / Compatibility Safety, Release Claim Safety.
- Top-level UI implementation: all FET gates plus existing AFI/FCP/PD/SI/FVQ gates.
- Drill-down UI implementation: Screenshot / Preview Evidence, First Viewport Composition, Primitive Identity, Copy Compression, Accessibility Resilience, Motion Meaning when relevant, Frontend Scorecard, Route / Compatibility Safety, Release Claim Safety.
- Shell/chrome/navigation: Screenshot / Preview Evidence, Bottom Chrome Ownership, First Viewport Composition, Accessibility Resilience, Frontend Scorecard, Route / Compatibility Safety, Release Claim Safety.
- External surface UI: Screenshot / Preview Evidence when rendered proof is possible, Primitive Identity, Copy Compression, Accessibility Resilience, Release Claim Safety, plus PFC platform gates.

## Scorecard

Use the 1-100 scorecard in `FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md`. Green requires average >= 90 and no category below 85. Yellow is average 80-89 with no hard Red and a named owner. Red is average below 80, any hard Red, missing screenshots for UI-touching work, or build/test success used as visual proof.

## Advisory Scripts

Run the FET advisory scans after `git diff --check` and before closeout for UI-touching batches. At FET00 the scripts are non-mutating. Findings become hard Red when they map to a hard frontend Red condition and the batch touches visible UI.

## Non-Claims

This matrix governs future work. It does not certify current UI quality or current accessibility/release readiness.

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
