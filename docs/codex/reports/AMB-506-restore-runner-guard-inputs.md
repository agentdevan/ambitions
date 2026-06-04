# AMB-506 Restore Runner Guard Inputs

Status: Green
Date: 2026-06-04
Branch: main

## Scope

Runner/process tooling repair only. No app source, tests, project files, package manifests, privacy manifests, entitlements, or product truth files were changed.

## Root Cause

`scripts/ambitions-codex-train.sh` requires source-changing batches to have canonical owner and parallel implementation guard inputs before running champion coverage and parallel guard checks. The required inputs were installed by `d9eef81f2` and later removed by `7f291ea9d` during a mass historical/obsolete canon purge. AMB-505 did not remove those inputs; it left the runner fail-closed path in place, so AMB-475 stopped before source changes with `guard inputs missing after bootstrap`.

## Required Guard Inputs Restored

- `docs/codex/canonical-owner-map.yml`
- `docs/codex/parallel-guard-concept-registry.yml`
- `docs/codex/existing-code-champion-coverage.yml`
- `docs/audits/intelligence-consolidation/CANONICAL_OWNER_MAP.md`
- `docs/audits/intelligence-consolidation/SUPERSESSION_LEDGER.md`
- `docs/audits/intelligence-consolidation/BEST_CODE_RESCUE_LEDGER.md`
- `docs/codex/CHAMPION_SELECTION_GATE.md`
- `docs/codex/PRIVATE_LIFE_RUNTIME_WIRING_GATE.md`

`docs/codex/concept-lock-registry.yml` was also restored because the parallel implementation guard reads it to preserve locked-concept protection.

## Repair

- Restored the missing guard input artifacts instead of relaxing `guard_required_inputs_present()`.
- Refreshed guard metadata to active canon:
  - Capture is global Capture / Atmosphere Composer, not a tab.
  - Motion / Motion Current has a canonical owner.
  - App shell / IA routing has a canonical owner for `Today / Goals / Time / Motion / You` plus global Capture.
- Updated the champion coverage bootstrap classifier so `Native/Ambitions/App/**` maps to `app_shell`, and future `Native/Ambitions/Features/Motion/**` files map to `motion_root`.
- Updated parallel guard reporting so Motion and Motion Current appear in concept detection.

## Validation

- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01 --bootstrap-install`: Yellow by design, no defects; regenerated current coverage.
- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-475`: Green.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-475 --prompt <temp> --batch-type source-changing`: Green; canonical owners found; concepts detected included Capture, Motion, Time, Today, and You; no duplicate risks, locked-concept violations, old-term violations, or runtime wiring gaps.

The full AMB-475 runner was not launched because, after guard preflight, it would proceed into Codex patch phases. This AMB-506 proof is limited to guard bootstrap/readiness.

## Protections Preserved

- `guard_required_inputs_present()` remains fail-closed.
- Champion coverage remains blocking for Red and Yellow without accepted-Yellow policy.
- Parallel implementation guard remains blocking for Red and Yellow without accepted-Yellow policy.
- Canonical owner map, concept registry, existing code coverage, supersession ledger, rescue ledger, champion selection gate, runtime wiring gate, and concept lock registry are present.

## Proof Boundaries

This evidence does not prove app build success, test success, release readiness, TestFlight readiness, App Store readiness, physical-device validation, accessibility validation, performance validation, privacy/legal approval, or AMB-475 implementation.

## Rollback

After commit, rollback with:

```bash
git revert <AMB-506-commit-sha>
```
