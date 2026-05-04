# SI14 Iconography Symbol And Status Grammar Report

Date: 2026-05-04
Result: PASS WITH YELLOW
Commit: pending

## Source Truth Read

- `docs/codex/batches/SI14_Iconography_Symbol_And_Status_Grammar_Prompt.md`
- `README.md`
- `AGENTS.md`
- `docs/README.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_4_0_Execution_Program.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/PXOS_Surface_Hierarchy_And_Navigation.md`
- `docs/canon/PXOS_Visual_Interaction_System.md`
- `docs/canon/PXOS_Product_Depth_And_Drilldown_Rules.md`
- `docs/canon/Ambitions_Signature_Interface_System.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/canon/AmbitionsOS_Living_Dream_Architecture_Index.md`
- `docs/canon/AmbitionsOS_Living_Dream_System_Map.md`
- `docs/codex/LDI_ROADMAP_TO_IMPLEMENTATION_REORDER_PROTOCOL.md`
- `.codex/skills/signature-interface-creative-director.md`
- `.codex/skills/ambitions-native-ui-primitive-reviewer.md`
- `.codex/skills/top-level-surface-composition-reviewer.md`
- `.codex/skills/interaction-motion-haptics-reviewer.md`
- `.codex/skills/accessibility-adaptive-interface-reviewer.md`
- `.codex/skills/ia-shell-navigation-reviewer.md`
- `.codex/skills/visual-qa-preview-fixture-reviewer.md`
- `.codex/skills/signature-iconography-symbol-reviewer.md`
- `.codex/skills/loading-degraded-state-reviewer.md`
- `.codex/skills/si-file-size-component-boundary-reviewer.md`
- `.codex/review-boards/signature-interface-review-board.md`

LDI source truth was read as future hook guidance only. SI14 adds visual-only
symbol grammar for source, proof, privacy, pressure, support, local-only,
continuity-paused, pack-unavailable, professional-boundary, blocked, review,
recovery, setup, waiting, disabled, and no-signal states. It does not implement
LDI runtime, source-pack logic, recompiler logic, sync logic, classifier logic,
hosted behavior, or silent commitment mutation.

The SI14 prompt still contains a stale embedded global-order label of `061`.
The deterministic global train scripts and global order doc select SI14 at
global order `116`; that operational source of truth was used.

## Files Changed

- `Sources/Components/IconographyStatusPrimitives.swift`
- `Sources/Previews/IconographyStatusPreviews.swift`
- `Native/AmbitionsTests/App/IconographyStatusDesignSystemTests.swift`
- `docs/audits/si14-iconography-symbol-status-grammar-report.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md`

## Implementation Summary

SI14 adds `AmbitionsStatusSymbolFamily`, `AmbitionsStatusSymbolRole`,
`AmbitionsStatusSymbolStyle`, and `AmbitionsStatusSymbol` to the shared design
system. The grammar uses SF Symbols, visible text labels, accessibility labels,
theme semantic state, and static Reduce Motion semantics so status meaning is
not carried by color or icon alone.

The implementation also adds mapping helpers from existing SI10/SI13 state
types into the new grammar:

- `SourceFreshnessState.statusSymbolRole`
- `TrustReceiptLayerKind.statusSymbolRole`
- `AmbitionsLoadingState.statusSymbolRole`

No product route, raw value, persistence, account, CloudKit, dependency,
workflow, signing, entitlement, product-surface composition, or release behavior
changed.

## State Matrix

| State | SI14 treatment |
| --- | --- |
| normal | `proofSaved`, `sourceFresh`, and `privacyProtected` carry stable label pairs. |
| selected | Selected semantics are inherited through theme semantic state, not color alone. |
| focused | Row style keeps full title/detail for focus and VoiceOver order. |
| loading | `loading` has hourglass plus visible label. |
| empty | `noDataYet` has dashed-circle plus visible no-signal label. |
| disabled | `disabledPendingValidation` names why action is still. |
| error/degraded | `sourceConflict`, `packUnavailable`, and `unsafeBlocked` are explicit. |
| privacy-sensitive | `privacySensitive`, `privacyProtected`, `localOnly`, and `syncUnavailable` avoid private detail reveal. |
| reduced-motion | Every role exposes static Reduce Motion semantics. |
| Dynamic Type | Preview includes accessibility Dynamic Type. |
| stale source | `sourceStale` pairs clock/source symbol with review label. |
| partial source | `sourcePartial` pairs half-filled circle with visible label. |
| offline/local-only | `localOnly` keeps device-only state visible. |
| blocked | `unsafeBlocked` is a blocked visual state only. |
| waiting | `waiting` names parked state. |
| needs review | `needsReview` routes meaning to visible review copy. |
| recovery | `recoveryAvailable` uses non-shaming recovery label. |
| overwhelming day | nearest equivalent is `recoveryAvailable`; SI14 does not model day load directly. |
| setup needed | `setupNeeded` names setup as visual status. |
| denied source | `sourceDenied` has visible source-denied label. |
| no data yet | `noDataYet` avoids fake certainty. |

## File-Size Evidence

- `Sources/Components/IconographyStatusPrimitives.swift`: 0 -> 383 lines.
- `Sources/Previews/IconographyStatusPreviews.swift`: 0 -> 80 lines.
- `Native/AmbitionsTests/App/IconographyStatusDesignSystemTests.swift`:
  0 -> 72 lines.

No touched Swift file crosses the 400-line SI advisory threshold.

## Validation

- `git branch --show-current`: `main`.
- Starting commit: `d2a1b7f2` (`Run SI13 Loading Empty Degraded State Primitives`).
- `scripts/global-train-next-batch.sh || true`: SI14 selected, global order 116.
- `scripts/global-train-status-summary.sh || true`: SI14 selected, clean tree before edits.
- `scripts/batch-train-gate-check.sh || true`: GREEN_HINT before edits.
- `xcodegen generate`: PASS.
- `git diff --check`: PASS.
- Focused design-system tests: PASS, 5 tests, 0 failures.
  - Command: `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/IconographyStatusDesignSystemTests test CODE_SIGNING_ALLOWED=NO`
  - First run failed on a preview-only read-only Reduce Motion environment key.
  - Rerun result bundle:
    `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.04_14-37-01--0400.xcresult`
- `scripts/build-local.sh`: PASS.
  - Log: `output/logs/build-local-20260504-144037.log`
- `scripts/si-readiness-gate.sh || true`: advisory complete. Existing
  file-size, symbol, and backlog inventory remains advisory.
- `scripts/si-visual-qa-report.sh || true`: advisory complete. SI14 adds named
  previews but no rendered screenshot artifact.
- `scripts/swiftui-architecture-scan.sh || true`: advisory complete. Existing
  extraction backlog remains; SI14 touched files stayed below thresholds.
- `scripts/run-doc-qa.sh || true`: advisory complete.
  - Stale guidance log:
    `docs/audits/doc-qa/20260504-144114-stale-guidance.log`
  - Deprecated-language log:
    `docs/audits/doc-qa/20260504-144114-deprecated-language.log`
  - Markdownlint log:
    `docs/audits/doc-qa/20260504-144114-markdownlint.log`
  - Lychee log: `docs/audits/doc-qa/20260504-144114-lychee.log`
  - Lychee result: 650 total, 650 OK, 0 errors.
  - Markdownlint result: existing repo-wide backlog remains advisory.
- LDI scans before staging were broad advisory scans because SI14 files were
  still unstaged. After staging the SI14 delta,
  `scripts/ldi-gate-check.sh || true`, `scripts/ldi-release-claim-scan.sh || true`,
  `scripts/ldi-global-order-consistency-check.sh || true`, and
  `scripts/ldi-handling-lane-scan.sh || true` passed for SI14 closeout after
  scanner-safe claim-boundary wording was repaired in the staged run-state docs.

## Yellow Advisories

- Rendered screenshot proof, human visual review, physical-device proof,
  VoiceOver review, contrast certification, and Instruments/battery proof were
  not produced.
- Passing simulator tests emit existing unsigned app-group warnings under
  `CODE_SIGNING_ALLOWED=NO`.
- SI14 defines reusable status-symbol grammar and preview evidence only; it does
  not prove product-surface composition.
- Existing repo-wide architecture, markdownlint, deprecated-language, and SI
  scan backlog remains advisory.
- The SI14 prompt's embedded `061` order label is stale; global order `116`
  from deterministic train tooling was used.

## Claim Boundaries

SI14 may claim only the shared Iconography Symbol And Status Grammar primitive
system after validation, commit, and push. It does not claim SI complete, PXOS
implemented, Product Depth implemented, AmbitionsOS implemented, LDI runtime,
platform release proof, physical-device proof, signed archive proof, public
accessibility conformance, legal/privacy signoff, remote model behavior,
server-owned data behavior, account behavior, CloudKit behavior, sync runtime,
or human visual approval.

## Rollback Path

Revert the SI14 commit to remove the iconography/status grammar primitive,
preview gallery, focused design-system tests, and SI14 status/evidence updates.

## Next Eligible Batch

SI15 Accessibility Adaptive Interface Pass is the next eligible global batch if
post-commit global train checks remain Green or accepted Yellow.
