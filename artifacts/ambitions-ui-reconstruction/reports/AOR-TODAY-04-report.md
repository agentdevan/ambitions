# AOR-TODAY-04 Report - Today Accessibility, Motion, Screenshot Proof

Status: Accepted Yellow - no hard-red Today blocker found; human visual review and full nonvisual traversal were not produced.
Issue: AMB-534
Date: 2026-06-06
Base commit: `95b3845944ed2e48e8976562db7f28330ad42433`

## Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`

## Scope

AMB-534 proved the reconstructed Today Reality Meridian across simulator screenshot variants and repaired a concrete Dynamic Type failure found during proof. The repair keeps Today as the object-owned Reality Meridian / Start Here surface, preserves the local-first source/receipt/trust posture, and does not add a new destination, card-stack inspection surface, analytics surface, cloud dependency, telemetry, or release claim.

## Runner / Guard Posture

- `ALLOW_DIRTY=1 scripts/ambitions-codex-train.sh AMB-534 prompts/batches/AMB-534.md`
  - Prompt self-heal: no diff remained after header check.
  - Champion coverage: Green.
  - Parallel implementation guard pre: Green.
  - Nested Phase 01 stopped before any source patch because the runner model returned a usage-limit error: retry after `2026-06-11 00:31`.
- Local repair continued after the runner-local guards passed because AMB-534 exposed a Today accessibility proof defect and the source patch was limited to Today Dynamic Type layout and guard metadata.

## Changed Source

- `Native/Ambitions/Features/Today/TodayScreen.swift`
  - Reads `dynamicTypeSize`.
  - Uses inline navigation title display at accessibility Dynamic Type sizes so large navigation chrome does not consume the Today proof viewport.
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
  - Adds an accessibility-size context crown.
  - Switches the rail to compact visual nodes at accessibility sizes while preserving the Start Here / Now relationship through the connector and accessibility label.
  - Moves the primary action above long explanatory copy at accessibility sizes.
  - Uses a short local-proof continuity summary instead of the full Up Next stack at accessibility sizes.
- `docs/codex/concept-lock-registry.yml`
  - Adds `AMB-534` to the Today / Start Here locked-concept allowlist for this bounded repair.
- `prompts/batches/AMB-534.md`
  - Runner header and AMB-534 issue contract are installed.

## Screenshot Evidence

All screenshots were captured from the booted `iPhone 17e` simulator at 1170 x 2532 after installing `.codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`.

| Screenshot | Bootstrap / setting | Result |
|---|---|---|
| `today-default-after-final.png` | `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=preview`, `-AmbitionsInitialSurface today`, `-AmbitionsScreenshotMode YES` | Today opens past onboarding into the empty/manual Reality Meridian. |
| `today-active-step-live-after-final.png` | Demo bootstrap, `-AmbitionsTodayEntryContext stepSession` | Step-session path remains Today-owned. |
| `today-trust-open-after-final.png` | Demo bootstrap, `-AmbitionsTodayEntryContext recovery`, `-AmbitionsTodaySheet trust` | Trust/detail sheet opens with source, context, goal, reasons, and proof/receipt sections. |
| `today-receipt-available-after-final.png` | Demo bootstrap, `-AmbitionsTodayEntryContext recovery`, `-AmbitionsTodaySheet receipt` | Receipt closure sheet opens from Today recovery state. |
| `today-source-unavailable-manual-after-final.png` | Preview bootstrap, `-AmbitionsInitialSurface today`, `-AmbitionsScreenshotMode YES` | Empty/manual copy shows `Source unavailable. Manual fallback stays open.` |
| `today-needs-recovery-after-final.png` | Demo bootstrap, `-AmbitionsTodayEntryContext recovery` | Recovery state keeps Start Here attached to the active rail node. |
| `today-large-dynamic-type-after-final.png` | Demo bootstrap, `xcrun simctl ui booted content_size accessibility-extra-extra-extra-large` | Start Here remains attached and the primary action remains visible in the first viewport after repair. |
| `today-reduce-motion-after-final.png` | Demo bootstrap, simulator `com.apple.Accessibility ReduceMotionEnabled = YES` | Static connector/origin relationship remains visible without relying on glow/motion. |
| `today-increase-contrast-after-final.png` | Demo bootstrap, `xcrun simctl ui booted increase_contrast enabled` | Boundaries and object edges remain visible under increased contrast. |
| `today-reduce-transparency-after-final.png` | Demo bootstrap, simulator `com.apple.Accessibility ReduceTransparencyEnabled = YES` | Meaning remains available through labels, connector, and primary action; no transparency-only meaning is required. |

## Accessibility / Motion Result

- Dynamic Type: repaired from a visible failure where the accessibility-size screenshot pushed the primary action out of the practical first viewport. The final screenshot keeps the Start Here title, active node connector, hero step, source context, and primary action visible together.
- Reduce Motion: the source already removes connector glow where `accessibilityReduceMotion` is true; screenshot proof confirms the static connector relationship remains visible.
- Increase Contrast: simulator setting was applied with `xcrun simctl ui`; screenshot proof confirms the Today object remains legible.
- Reduce Transparency: simulator accessibility defaults were applied; screenshot proof confirms the Today object still communicates through text, connector, and action placement.
- Nonvisual access: source inspection confirms the Reality Meridian container has a composed accessibility label including Today, Reality Meridian, mode, context, Start Here, attachment to current Now node, source, freshness, receipt, and primary action. A full VoiceOver traversal was not performed.

## Stop / Go Decision

No hard Red remains for AMB-534 after the Dynamic Type repair. The issue closes as accepted Yellow because human visual review and full VoiceOver traversal are still not produced. This allows continuation only with that Yellow boundary carried forward; it does not prove public accessibility conformance or release readiness.

## Validation

- `ALLOW_DIRTY=1 scripts/ambitions-codex-train.sh AMB-534 prompts/batches/AMB-534.md`
  - Runner-local champion coverage and pre-guard Green; nested model phase Red due usage-limit before source patch.
- `git diff --check`
  - Passed.
- `make xcode-build-for-testing BATCH=AMB-534`
  - Passed after repair.
- `make xcode-focused-test BATCH=AMB-534 TEST=AmbitionsTests/TodayRealityMeridianExperienceElevationTests`
  - Passed after repair.
- `xcrun simctl install booted .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - Passed.
- `sips -g pixelWidth -g pixelHeight` on all ten AMB-534 screenshots
  - All screenshots are 1170 x 2532.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-534 --prompt prompts/batches/AMB-534.md --changed-from 95b3845944ed2e48e8976562db7f28330ad42433 --batch-type source-changing`
  - Green.
  - Report: `build/reports/parallel-implementation-guard/AMB-534-post.md`.

## Proof Boundaries

- Current evidence proves the scoped source patch, local build/test pass, guard preflight pass, and simulator screenshot packet for AMB-534.
- Current evidence does not prove human visual approval, complete VoiceOver traversal, real-device behavior, performance, physical-device QA, privacy/legal approval, CI proof, TestFlight readiness, App Store readiness, or release readiness.

## Rollback

Revert the AMB-534 commit, or remove the source/report/screenshot/prompt/guard-metadata changes listed above and rebuild from `95b3845944ed2e48e8976562db7f28330ad42433`.
