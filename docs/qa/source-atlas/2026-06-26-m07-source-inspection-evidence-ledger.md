# M07 Source Inspection Evidence Ledger

Status: Green for scoped source/test/rendered simulator proof; no device or manual accessibility readiness claimed.
Train: Source Atlas Implementation Train 04, M07.
Issues: AMB-1354, AMB-1355, AMB-1356, AMB-1357, AMB-1358, AMB-1371.

## Scope Completed

- Source inspection UX contract and presentation state model added at `Native/Ambitions/Trust/SourceInspectionModels.swift`.
- Required states covered: current, stale, stale-critical, unavailable, conflicted, revoked, unsupported, review-required.
- Source inspection renderer remains a Trust detail at `Native/Ambitions/Trust/SourceInspectionView.swift`.
- You Sources detail attaches Source inspection inside the existing `You` surface at `Native/Ambitions/Surfaces/You/YouRootDetailContent.swift`.
- Copy audit added at `Native/Ambitions/Language/SourceInspectionCopyAudit.swift`.
- Accessibility proof contract added at `Native/Ambitions/Quality/SourceInspectionAccessibilityProof.swift`.
- Rendered proof UI test added at `Native/AmbitionsUITests/VisualTargetAttachmentUITests.swift`.

## Product Law Preserved

- No Source Atlas root destination was added.
- Source inspection is hidden from root surfaces and appears only inside You Sources detail.
- Today / Goals / Time / You remain the only persistent surfaces.
- Capture remains the global composer. Motion remains cross-surface behavior.
- Rendered detail exposes public/reference source context only.
- No private goals, captures, schedule assumptions, Life Capital, proof payloads, receipts, private graph nodes/edges, account secrets, or user IDs are intentionally exposed by the Source inspection model.

## Proof Artifacts

- UX contract/state model: `Native/Ambitions/Trust/SourceInspectionModels.swift`
- Renderer: `Native/Ambitions/Trust/SourceInspectionView.swift`
- Existing surface attachment: `Native/Ambitions/Surfaces/You/YouRootDetailContent.swift`
- Copy audit: `Native/Ambitions/Language/SourceInspectionCopyAudit.swift`
- Presentation fixture tests: `Native/AmbitionsTests/Trust/SourceInspectionPresentationTests.swift`
- Accessibility proof model/tests: `Native/Ambitions/Quality/SourceInspectionAccessibilityProof.swift`, `Native/AmbitionsTests/Quality/SourceInspectionAccessibilityProofTests.swift`
- Rendered proof test: `Native/AmbitionsUITests/VisualTargetAttachmentUITests.swift`
- Rendered dark screenshot: `.codex/xcode-summaries/SOURCE_ATLAS_TRAIN04_RENDERED/20260626T212938Z-AmbitionsUITests-VisualTargetAttachmentUITests-71631-1936/extract/screenshots/source-inspection-you-sources-dark-rendered-proof_0_76692C62-822A-438D-9A9F-219F293D152C.png`
- Rendered Accessibility XL screenshot: `.codex/xcode-summaries/SOURCE_ATLAS_TRAIN04_RENDERED/20260626T212938Z-AmbitionsUITests-VisualTargetAttachmentUITests-71631-1936/extract/screenshots/source-inspection-you-sources-dark-accessibility-xl-rendered-proof_0_2567789C-6629-459E-9C60-599C1ABDB16F.png`
- Rendered result summary: `.codex/xcode-summaries/SOURCE_ATLAS_TRAIN04_RENDERED/20260626T212938Z-AmbitionsUITests-VisualTargetAttachmentUITests-71631-1936/focused-test-summary.json`

## Focused Validation

- `scripts/ambitions-xcode-test-focused.sh --batch SOURCE_ATLAS_TRAIN04_FOCUSED --only-testing AmbitionsTests/SourceInspectionPresentationTests --timeout 15m --kill-after 60s`
  - Passed; 4 tests.
  - Summary: `.codex/xcode-summaries/SOURCE_ATLAS_TRAIN04_FOCUSED/20260626T202657Z-AmbitionsTests-SourceInspectionPresentationTests-10121-20330/focused-test-summary.json`
- `scripts/ambitions-xcode-test-focused.sh --batch SOURCE_ATLAS_TRAIN04_FOCUSED --only-testing AmbitionsTests/SourceInspectionAccessibilityProofTests --timeout 15m --kill-after 60s`
  - Passed; 2 tests.
  - Summary: `.codex/xcode-summaries/SOURCE_ATLAS_TRAIN04_FOCUSED/20260626T203349Z-AmbitionsTests-SourceInspectionAccessibilityProofTests-14794-20334/focused-test-summary.json`
- `scripts/ambitions-xcode-test-focused.sh --batch SOURCE_ATLAS_TRAIN04_RENDERED --only-testing AmbitionsUITests/VisualTargetAttachmentUITests --timeout 15m --kill-after 60s`
  - Passed; 2 tests.
  - Summary: `.codex/xcode-summaries/SOURCE_ATLAS_TRAIN04_RENDERED/20260626T212938Z-AmbitionsUITests-VisualTargetAttachmentUITests-71631-1936/focused-test-summary.json`

## Validation Command Ledger

- `git diff --check`: passed.
- `bash scripts/ci/ambitions-pr-review-local.sh --continue`: passed; 16 checks passed, 0 failed.
- `python3 scripts/ambitions-green-standard-audit.py`: passed; no disallowed architecture-as-UI strings found in active primary UI source.
- `python3 scripts/source-atlas-boundary-audit.py`: passed; 40 targets.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py`: passed.
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests`: passed; 41 tests.
- `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard`: passed.
  - Summary: `.codex/xcode-summaries/green-standard/20260626T213532Z/extract/summary.json`
- Privacy boundary scan inside the local PR review stack reported advisory hits for review-context copy and local-first settings copy, then passed with explicit non-claim review.

## Proof Ceiling

- AMB-1371 has current rendered simulator proof for You Sources Source inspection in dark mode and Accessibility XL.
- No physical-device proof is claimed.
- No manual VoiceOver sweep, manual Dynamic Type sweep, Reduce Transparency sweep, or public accessibility conformance is claimed.
- Screenshots are current simulator artifacts for this branch, not release readiness proof.

## Known Risks

- Accessibility XL rendered screenshot proves the Source detail is reachable and the status label no longer truncates, but it still shows large-type density pressure in the header/card. This remains a visual polish follow-up, not a blocker for scoped M07 proof.
- The rendered source state shown by current preview data is review-required. Other states are covered by fixtures and model tests, not all by rendered screenshots.

## Rollback Plan

- Revert `Native/Ambitions/Trust/SourceInspectionModels.swift`, `Native/Ambitions/Trust/SourceInspectionView.swift`, `Native/Ambitions/Language/SourceInspectionCopyAudit.swift`, `Native/Ambitions/Quality/SourceInspectionAccessibilityProof.swift`, the You Sources attachment in `Native/Ambitions/Surfaces/You/YouRootDetailContent.swift`, and related M07 tests.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Trust/`, `Language/`, `Quality/`, `Surfaces/You/`.
- Files moved or created: new Source inspection model/copy/accessibility proof files and tests listed above.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt: none for this scoped train.
- Next repair train if debt remains: none.
- Confirmation: no equivalent folder/path interpretation was used.
