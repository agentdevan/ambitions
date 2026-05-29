# SI03 App Shell IA And Navigation List System Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

## Batch Identity

- Batch ID: SI03
- Title: App Shell IA And Navigation List System
- Train: SI01-SI18 Signature Interface Implementation Train
- Global order after SI insertion: 050
- Type: SwiftUI implementation

## Status

Queued Ambitions 4.0 Signature Interface batch. Not started until the global order selects it and the dry-run says Execution allowed: YES.

## Purpose

Build shell, IA, and grouped navigation primitives.

PXOS defines experience intent. SI creates reusable SwiftUI expression. ME protects file ownership. CS protects compatibility. PD composes SI primitives into depth. AOS may expose runtime intelligence only through trust gates. REC keeps claims bounded.

## User-Visible Outcome

Shell and You/drill-down hubs use native navigation without new tabs.

## Source Truth

- README.md
- AGENTS.md
- docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md
- docs/canon/Ambitions_3_0_Primitive_Architecture.md
- docs/canon/Ambitions_4_0_Execution_Program.md
- docs/canon/Ambitions_Product_Experience_OS_Index.md
- docs/canon/PXOS_Surface_Hierarchy_And_Navigation.md
- docs/canon/PXOS_Visual_Interaction_System.md
- docs/canon/PXOS_Product_Depth_And_Drilldown_Rules.md
- docs/canon/Ambitions_Signature_Interface_System.md
- docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md
- docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md
- docs/codex/BATCH_REGISTRY.md

## Allowed Files

- Native/Ambitions/App/**
- Sources/Components/**
- Sources/Previews/**
- Native/AmbitionsTests/**
- docs/audits/**

## Forbidden Files

- New top-level tabs
- route/raw deletion
- persistence
- workflows
- dependencies
- .github/workflows/**
- Dependency manifests or lockfiles
- App Store, TestFlight, signed archive, device, public accessibility, legal/privacy, or release decision claims

## Component Ownership

AmbitionsSurfaceShell, GroupedNavigationList, GroupedNavigationRow, overlay zone.

Likely owner families: Native/Ambitions/App/**; Sources/Components/**; Sources/Previews/**; Native/AmbitionsTests/**; docs/audits/**. Any actual owner change must be named in the batch report before edits.

## Interaction Requirements

Back/forward, sheet entry, row feedback, overlay presentation, reduced-motion equivalents.

Motion must orient, confirm, or reduce uncertainty. Haptics must be system-native and optional.

## Accessibility Requirements

Navigation title support, row labels/values, Dynamic Type rows, non-icon-only meaning.

No icon-only meaning, no color-only meaning, no private content leak, and no Dynamic Type collapse.

## Visual Acceptance Criteria

Compact shell, calm headers, list use only where navigation is the primary job.

Typography uses native rhythm. Spacing is calm and scan-first. Material/depth supports hierarchy rather than decoration.

## Anti-Generic UI Rules

No duplicate destinations, orphan screens, or settings clutter outside owned hubs.

The result must be identifiable as an Ambitions object, rail, lane, map, composer, receipt, shell, or system center.

## Required SI Gates

- Signature Interface Creative Direction Gate
- Native iPhone Believability Gate
- Anti-Generic UI Gate
- Top-Level Composition Gate where relevant
- Interaction/Motion/Haptics Gate
- Reduce Motion Gate
- Accessibility/Dynamic Type/VoiceOver Gate
- Preview Coverage Gate
- Visual QA Gate
- File-Size/Component Boundary Gate
- Release-Claim Safety Gate

Required skills/review boards:

- .codex/skills/signature-interface-creative-director.md
- .codex/skills/ambitions-native-ui-primitive-reviewer.md
- .codex/skills/top-level-surface-composition-reviewer.md
- .codex/skills/interaction-motion-haptics-reviewer.md
- .codex/skills/accessibility-adaptive-interface-reviewer.md
- .codex/skills/ia-shell-navigation-reviewer.md
- .codex/skills/visual-qa-preview-fixture-reviewer.md
- .codex/skills/signature-iconography-symbol-reviewer.md
- .codex/skills/loading-degraded-state-reviewer.md
- .codex/skills/si-file-size-component-boundary-reviewer.md
- .codex/review-boards/signature-interface-review-board.md

## Invented-But-Native Rubric

Score 1-5 for originality, native iPhone believability, usefulness, restraint, accessibility, emotional tone, system coherence, and implementation maintainability. Green requires average score >= 4, no score below 3, and no Red in accessibility, release-claim safety, route/compatibility, or file-size boundary.

## Component State Matrix

- normal
- selected
- focused
- loading
- empty
- disabled
- error/degraded
- privacy-sensitive
- reduced-motion
- Dynamic Type
- stale source
- partial source
- offline/local-only
- blocked
- waiting
- needs review
- recovery
- overwhelming day
- setup needed
- denied source
- no data yet

If a state is impossible for this batch, the report must say why and name the nearest equivalent proof.

## File-Size And Diff Budget

- Max file count touched: 14
- Max intended new files: 8
- Max intended deleted files: 0 unless approved in the batch report before deletion
- Max diff size: Medium
- Swift files require before/after line counts. Files crossing 400/700/1000 lines require Yellow/Red classification.

## Validation Commands

~~~bash
git status --short
git diff --check
scripts/build-local.sh
scripts/si-readiness-gate.sh || true
scripts/si-visual-qa-report.sh || true
scripts/swiftui-architecture-scan.sh || true
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
rg -n "SI03|App Shell IA And Navigation List System|Signature Interface|release ready|App Store ready|TestFlight ready" README.md docs .codex Native Sources AppUI || true
~~~

Strong build/tests, route scans, SI scripts, preview proof.

## Preview And Visual Evidence

Preview enabled, disabled, setup-needed, private, receipt/history, Dynamic Type.

Do not claim human visual approval unless a human actually approves. Do not claim physical-device proof unless performed.

## Green Criteria

- Scope completed exactly for SI03.
- Required SI gates are Green or accepted Yellow with owners.
- Validation strength is Strong.
- No forbidden files changed.
- No unsupported release/platform/SI/PXOS/PD/AOS implementation claim.
- Accessibility, Reduce Motion, preview, and file-size evidence are recorded where relevant.
- Batch report under docs/audits/ is complete with rollback path and next eligible batch.

## Yellow Criteria

- Advisory is noncritical, named, owned, and safe for the next batch.
- Existing repo-wide doc QA or architecture-scan backlog is classified without hiding Red.
- Preview or screenshot gap is tooling-limited and has a named future owner.

## Red Criteria

- Build or focused tests fail because of this batch.
- Weak or Missing implementation validation.
- Generic product drift, top-level stack regression, route/raw/persistence break, test weakening, uncontrolled file-size growth, forbidden file touch, or unsupported claim.
- UI-changing work lacks state matrix, accessibility evidence, or Reduce Motion equivalent where motion matters.

## Stop Conditions

Stop for unresolved Red, unsafe dirty tree, missing source truth, forbidden files, weak implementation validation, human-only proof requirement, or source-truth conflict affecting safety.

## Rollback And Repair

Rollback by reverting the SI03 commit. Repair Red by narrowing scope, restoring boundaries, adding missing evidence, splitting oversized files, or stopping with a Red repair report. Do not weaken product canon, tests, accessibility, compatibility, release truth, or SI gates.

## Claims

This batch may claim only the SI03 scope completed after validation, evidence, commit, and push.

## Non-Claims

This batch does not claim SI complete, PXOS implemented, Product Depth implemented, AmbitionsOS implemented, App Store readiness, TestFlight readiness, production readiness, physical-device proof, public accessibility proof, signed archive proof, legal/privacy signoff, human visual approval, or final release decision.

## Commit Message

Run SI03 App Shell IA And Navigation List System

## Next Safe Path

Run the next SI batch only when global order reaches it, prerequisites are Green or accepted Yellow, and dry-run says Execution allowed: YES.

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
