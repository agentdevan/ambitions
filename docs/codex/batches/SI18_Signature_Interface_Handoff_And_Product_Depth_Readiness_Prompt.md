# SI18 Signature Interface Handoff And Product Depth Readiness Prompt

<!-- markdownlint-disable MD013 -->

## Batch Identity

- Batch ID: SI18
- Title: Signature Interface Handoff And Product Depth Readiness
- Train: SI01-SI18 Signature Interface Implementation Train
- Global order after SI insertion: 065
- Type: docs/handoff/evidence

## Status

Queued Ambitions 4.0 Signature Interface batch. Not started until the global order selects it and the dry-run says Execution allowed: YES.

## Purpose

Close SI and determine Product Depth readiness.

PXOS defines experience intent. SI creates reusable SwiftUI expression. ME protects file ownership. CS protects compatibility. PD composes SI primitives into depth. AOS may expose runtime intelligence only through trust gates. REC keeps claims bounded.

## User-Visible Outcome

Product Depth starts only with clear SI evidence boundaries.

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

- docs/**
- .codex/**

## Forbidden Files

- Production Swift
- tests
- app behavior
- release/platform claims
- .github/workflows/**
- Dependency manifests or lockfiles
- App Store, TestFlight, signed archive, device, public accessibility, legal/privacy, or release decision claims

## Component Ownership

Primitive inventory, PD dependency map, AOS24 UI readiness implications, Yellow owner list.

Likely owner families: docs/**; .codex/**. Any actual owner change must be named in the batch report before edits.

## Interaction Requirements

Document interaction evidence and unresolved gaps.

Motion must orient, confirm, or reduce uncertainty. Haptics must be system-native and optional.

## Accessibility Requirements

Document accessibility evidence and human-proof non-claims.

No icon-only meaning, no color-only meaning, no private content leak, and no Dynamic Type collapse.

## Visual Acceptance Criteria

Handoff is evidence-grounded and honest about remaining work.

Typography uses native rhythm. Spacing is calm and scan-first. Material/depth supports hierarchy rather than decoration.

## Anti-Generic UI Rules

No claim that PD/AOS24 may skip gates.

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

- Max file count touched: 10
- Max intended new files: 3
- Max intended deleted files: 0 unless approved in the batch report before deletion
- Max diff size: Medium
- Swift files require before/after line counts. Files crossing 400/700/1000 lines require Yellow/Red classification.

## Validation Commands

~~~bash
git status --short
git diff --check
scripts/si-readiness-gate.sh || true
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
rg -n "SI18|Signature Interface Handoff And Product Depth Readiness|Signature Interface|release ready|App Store ready|TestFlight ready" README.md docs .codex || true
~~~

Adequate docs validation plus evidence inventory scans.

## Preview And Visual Evidence

No new screenshots unless closing existing evidence links.

Do not claim human visual approval unless a human actually approves. Do not claim physical-device proof unless performed.

## Green Criteria

- Scope completed exactly for SI18.
- Required SI gates are Green or accepted Yellow with owners.
- Validation strength is Adequate.
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

Rollback by reverting the SI18 commit. Repair Red by narrowing scope, restoring boundaries, adding missing evidence, splitting oversized files, or stopping with a Red repair report. Do not weaken product canon, tests, accessibility, compatibility, release truth, or SI gates.

## Claims

This batch may claim only the SI18 scope completed after validation, evidence, commit, and push.

## Non-Claims

This batch does not claim SI complete, PXOS implemented, Product Depth implemented, AmbitionsOS implemented, App Store readiness, TestFlight readiness, production readiness, physical-device proof, public accessibility proof, signed archive proof, legal/privacy signoff, human visual approval, or final release decision.

## Commit Message

Run SI18 Signature Interface Handoff And Product Depth Readiness

## Next Safe Path

Run the next SI batch only when global order reaches it, prerequisites are Green or accepted Yellow, and dry-run says Execution allowed: YES.
