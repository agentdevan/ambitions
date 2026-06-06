# AMB-521 Packet 13 Rename / Migration Closeout

Status: Green
Date: 2026-06-06
Branch: main
Base SHA: `d6d8066ba993556ad499c92e4b22c4293ffb123e`

## Scope

AMB-521 is the conditional rename / migration packet after AMB-520 accepted Yellow. The migration target proved necessary for central active surface-contract copy: Goals still exposed `Constellation Atlas` as the active primary object and You still exposed `User System Profile` as the active primary object.

This packet did not perform broad file/type renames, root IA changes, generated authority rewrites, design-truth edits, screenshot baseline changes, or surface maturity implementation.

## Active Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

## Files Changed

- `prompts/batches/AMB-521.md`
- `scripts/ambitions-parallel-implementation-guard.py`
- `Native/Ambitions/App/AppTab.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceActionPayloads.swift`
- `Native/Ambitions/PreviewSupport/ShellPreviewMatrix.swift`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceActionPayloadTests.swift`
- `Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/AmbitionsDomain.swift`
- `Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/AmbitionsLivingViews.swift`
- `Packages/AmbitionsExperienceKernel/Tests/AmbitionsExperienceKernelTests/AmbitionsExperienceKernelTests.swift`
- `docs/codex/reports/AMB-521-packet-13-rename-migration-closeout.md`

## Why

- AMB-520 closed accepted Yellow with no Red blockers, which cleared the dependency for AMB-521.
- AMB-521 remained conditional; current source inspection showed an exact rename target in active surface contracts and external reopening titles.
- Goals now exposes `Direction Atlas` as the active primary object in the app shell contract.
- You now exposes `Personal Runtime` as the active primary object in the app shell contract.
- The package-level `AmbitionsExperienceKernel` contract now uses `directionAtlas` and `personalRuntime` while retaining `constellationAtlas`, `userSystemProfile`, `ConstellationAtlasObject`, and `UserSystemProfileObject` as compatibility wrappers.
- The parallel guard was repaired narrowly so concept-lock path checks match exact paths or prefixes. This preserves the top-level `Sources/` design-primitives lock without falsely classifying `Packages/AmbitionsExperienceKernel/Sources/...` as that lock.

## Verified

- AMB-520 dependency is Linear Done / accepted Yellow at commit `d6d8066ba993556ad499c92e4b22c4293ffb123e`.
- Runtime root remains `AmbitionsApp -> LaunchGateView -> AmbitionsRootView -> SwiftUI TabView`.
- `AppTab.allCases` remains `Today / Goals / Time / Motion / You`.
- `AppTab.capture` remains compatibility-only and is not a canonical top-level tab.
- No root IA change was introduced.
- No screenshot or visual baseline was changed.
- No product/design truth file was edited.
- Compatibility wrappers remain for the old package object names.

## Validation

Run:

- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-521` -> GREEN.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-521 --prompt prompts/batches/AMB-521.md --batch-type source-changing` -> initial RED because the prompt lacked `SourceRecord`, `Receipt`, `ReplayTrace`, and `You / What Ambitions knows`; GREEN after prompt repair.
- `swift test --package-path Packages/AmbitionsExperienceKernel` -> passed, 9 tests executed.
- `make xcode-focused-test BATCH=AMB-521 TEST=AmbitionsTests/ShellPreviewMatrixTests` -> initial failure from preview fixture order; passed after repair, 12 tests executed.
- `make xcode-focused-test BATCH=AMB-521 TEST=AmbitionsTests/AppShellNavigationTests` -> passed, 37 tests executed.
- `make xcode-focused-test BATCH=AMB-521 TEST=AmbitionsTests/ExternalSurfaceActionPayloadTests` -> passed, 12 tests executed.
- `python3 -m py_compile scripts/ambitions-parallel-implementation-guard.py` -> passed.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-521 --prompt prompts/batches/AMB-521.md --changed-from d6d8066ba993556ad499c92e4b22c4293ffb123e --batch-type source-changing` -> initial RED from a guard path false positive; GREEN after guard path-prefix repair.
- `git diff --check` -> passed.

## Not Verified

- Rendered screenshots.
- Screenshot baselines.
- Human visual approval.
- Manual VoiceOver traversal.
- Dynamic Type simulator/device proof.
- Reduce Motion proof.
- Increase Contrast proof.
- Reduce Transparency proof.
- Differentiate Without Color proof.
- Tap-target measurement.
- Performance proof.
- Privacy/legal approval.
- Physical-device proof.
- TestFlight readiness.
- App Store readiness.
- Release readiness.

Reason: AMB-521 is a narrow rename / compatibility migration packet, not a screenshot, accessibility-certification, performance, privacy, device, or release-readiness packet.

## Yellow Items

- Broader generated/supporting source still contains compatibility names such as `Constellation Atlas`, `Atmosphere Composer`, and `User System Profile` where those are generated authority records, compatibility wrappers, preview catalogs, or non-touched owner surfaces.
- Package docs under `Packages/AmbitionsExperienceKernel/Docs/` still mention the old names and were not edited because AMB-521 forbids design-doc updates without human approval.

## Red Blockers

None remaining for the scoped AMB-521 migration.

## Rollback

Before commit:

```bash
git restore prompts/batches/AMB-521.md scripts/ambitions-parallel-implementation-guard.py Native/Ambitions/App/AppTab.swift Native/Ambitions/ExternalSnapshots/ExternalSurfaceActionPayloads.swift Native/Ambitions/PreviewSupport/ShellPreviewMatrix.swift Native/AmbitionsTests/App/AppShellNavigationTests.swift Native/AmbitionsTests/App/ExternalSurfaceActionPayloadTests.swift Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/AmbitionsDomain.swift Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/AmbitionsLivingViews.swift Packages/AmbitionsExperienceKernel/Tests/AmbitionsExperienceKernelTests/AmbitionsExperienceKernelTests.swift
rm -f docs/codex/reports/AMB-521-packet-13-rename-migration-closeout.md
```

After commit, revert the AMB-521 commit.

## Next Gate

Next eligible packet after Green closeout: `AMB-522`, subject to current truth and Linear dependency preflight.
