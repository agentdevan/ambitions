# Train 00-08 Evidence Inventory

Date: 2026-06-20
Linear issue: `AMB-1145`
Branch: `main`
Audit commit: `06cef368199efe85c75079d5815e27d135cde264`
Remote main at audit start: `06cef368199efe85c75079d5815e27d135cde264`
Scope: Program Control verification only.

This note reconciles Trains 00-08 against the current repo plan, current source ownership, retained validation docs, local proof artifacts, and current Linear proof-gap issues. It does not edit product source, `docs/truth`, Xcode project generation, or implementation trains.

## Authority Read

Read for this audit:

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
- `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`
- `docs/superpowers/plans/2026-06-18-design-truth-refraction-trains-6-completion.md`
- retained validation docs under `docs/validation`

The repo Train 6-13 plan says Trains 0-5 were previously accepted under user Assume Green policy and Trains 6-8 were user-reported complete. This audit does not convert those statements into Green completion unless current retained proof supports it.

## Current Source Checkpoints

- Current top-level tab source is `Native/Ambitions/App/AppTab.swift`.
- `AppTab` currently declares only Today, Goals, Time, and You.
- `find Native/Ambitions -path '*Features*' -type f -name '*.swift'` returned no Swift files.
- `Native/Ambitions/Features` still exists as empty legacy directory structure only.
- Capture current owner: `Native/Ambitions/Composer/Capture`.
- Motion current owner: `Native/Ambitions/Stage/Motion`.
- Persistent surface current owners: `Native/Ambitions/Surfaces/Today`, `Native/Ambitions/Surfaces/Goals`, `Native/Ambitions/Surfaces/Time`, `Native/Ambitions/Surfaces/You`.
- Quality/current guardrail source exists under `Native/Ambitions/Quality`, `Native/Ambitions/Scenarios`, `Native/AmbitionsTests/Quality`, and `scripts/ambitions-quality-gate.py`.

## Status Table

| Train | Status | Current evidence | Remaining work / proof gap | Linear follow-up |
| --- | --- | --- | --- | --- |
| 00 | Done by User Assumption / Needs Verification | Repo plan accepts Trains 0-5 under Assume Green. Local generated artifacts exist under `.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-0-1` and `.codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-0-1`. Current `AppTab` is four-surface canon. | No retained `docs/validation/train_0*.md` closeout at HEAD. No current screenshot/accessibility proof claimed. | `AMB-1155` |
| 01 | Done by User Assumption / Needs Verification | Commits `c0d1dc361` and `450f66cb5` added audit/scanner authority checkpoints. Local generated artifacts exist for `DESIGN-TRUTH-REFRACTION-TRAIN-1-5` and `DESIGN-TRUTH-REFRACTION-TRAIN-1-6`. | No retained `docs/validation/train_1*.md` closeout at HEAD. Current scanner proof must be reverified before Green. | `AMB-1156` |
| 02 | Done by User Assumption / Needs Verification | Commits `8d0955861`, `8dc324107`, and `4eaec0e25` added enforcement gates, checkpoint hygiene, and focused XCTest recovery. Local artifacts exist for `DESIGN-TRUTH-REFRACTION-TRAIN-2`, `2-5`, and `2-6`. Current quality/scenario sources exist. | No retained `docs/validation/train_2*.md` closeout at HEAD. Strict-gate Green is a global precondition, not proof that every Train 02 requirement is retained. | `AMB-1157` |
| 03 | Superseded by Later Work | Commit `55ca1c77c` implemented root stage shell work. Current source has four canonical tabs, no Swift files under `Features`, Capture under `Composer/Capture`, Motion under `Stage/Motion`, and persistent surfaces under `Surfaces/*`. | Old Train 03 proof is source-history evidence, not retained current Green proof. Shell visual/accessibility/safe-area proof must be reverified if claiming completion. | `AMB-1158` |
| 04 | Done by User Assumption / Needs Verification | Commit `bd382be1a` added Train 4 design system foundation policies. Current quality source includes gates for language, accessibility, dynamic type, safe area, motion reduction, performance budget, and visual regression harnesses. | No retained `docs/validation/train_4*.md` closeout at HEAD. Raw design literal and token enforcement need exact current proof before Green. | `AMB-1159` |
| 05 | Partially Done | Retained docs: `docs/validation/train_5_5_today_viewport_accessibility_recovery.md` and `docs/validation/train_5_6_bounded_xcode_validation.md`. They report build/focused tests/screenshot proof for the bounded Today viewport slice. | Train 5.5 is Yellow: manual VoiceOver, Increase Contrast, and Reduce Transparency were not run. | `AMB-1152` |
| 06 | Partially Done | Retained doc: `docs/validation/train_6_closure_refraction_closeout.md`. It records closure runtime/projection mutation work, passing focused Today tests, and build-for-testing. | Train 6 is Yellow: AMB-962 screenshot flow failed before repaired closure visual proof; full VoiceOver/Dynamic Type/manual visual review for repaired closure sheet remains unproven. | `AMB-1153` |
| 07 | Done with Evidence | Retained doc: `docs/validation/train_7_capture_composer_refraction_closeout.md`. It records focused build/tests, screenshot visual review at `.codex/screenshots/TRAIN_07_CAPTURE_SHELL/activated-capture-seam.png`, and Capture as global composer. Current source now places Capture under `Native/Ambitions/Composer/Capture`, superseding stale "equivalent owner" wording in the old closeout. | Full screenshot matrix for every Capture state is not claimed, but no current blocker was found for the focused Train 7 completion claim. | None |
| 08 | Partially Done | Retained doc: `docs/validation/train_8_goals_refraction_closeout.md`. It records Goals refraction, focused tests, build-for-testing, and visually reviewed Goals screenshots. Current source has moved Goals under `Surfaces/Goals`, `Projection/SurfaceLenses`, and `DesignSystem/ProductObjects`. | Train 8 closeout is Yellow: Constellation projection copy ownership, internal MissionControl naming, large Goals files, and current applicability of old screenshots need re-audit. | `AMB-1154` |

## Linear Reconciliation

New proof-gap verification issues created from this AMB-1145 pass:

- `AMB-1155` - Train 00 Proof Gap - baseline canon/source proof re-verification
- `AMB-1156` - Train 01 Proof Gap - audit/scanner authority retained-proof verification
- `AMB-1157` - Train 02 Proof Gap - enforcement gate retained-proof verification
- `AMB-1158` - Train 03 Proof Gap - root shell architecture proof re-verification
- `AMB-1159` - Train 04 Proof Gap - design token foundation retained-proof verification

Pre-existing proof-gap issues verified:

- `AMB-1152` - Train 05 Proof Gap - Today viewport manual accessibility verification
- `AMB-1153` - Train 06 Proof Gap - Closure sheet screenshot and accessibility recovery
- `AMB-1154` - Train 08 Proof Gap - Goals Yellow debt re-audit and bounded repair decision

No new issue was created for Train 07 because retained focused proof exists and no current blocking regression was found. The old Train 7 closeout's "equivalent owner" wording is superseded by current source ownership under `Native/Ambitions/Composer/Capture`.

## Validation Results

Run for this AMB-1145 closeout:

```bash
git status --short --branch
git rev-parse HEAD
git ls-remote origin refs/heads/main
find Native/Ambitions -path '*Features*' -type f -name '*.swift'
```

Results before doc edits:

- Branch was `## main...origin/main`.
- Local HEAD was `06cef368199efe85c75079d5815e27d135cde264`.
- Remote main was `06cef368199efe85c75079d5815e27d135cde264`.
- `Features` Swift scan returned no files.

Run after doc edits:

```bash
git diff --check
python3 scripts/ambitions-quality-gate.py --max-per-gate 20
scripts/release-claim-safety-scan.sh
python3 scripts/ambitions-unsupported-claim-scan.py docs/validation/train_00_08_evidence_inventory.md docs/validation/README.md
rg -n "Train 0|Train 1|Train 2|Train 3|Train 4|Train 5|Train 6|Train 7|Train 8" docs/validation docs/superpowers .codex/xcode-summaries --glob '*.md' --glob '*.json'
```

Results:

- `git diff --check`: passed.
- `python3 scripts/ambitions-quality-gate.py --max-per-gate 20`: `GREEN all strict quality gates passed` with `production_swift_files=972` and `changed_paths=2`.
- `scripts/release-claim-safety-scan.sh`: `GREEN no proof-sensitive release claims found`.
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/validation/train_00_08_evidence_inventory.md docs/validation/README.md`: passed.
- Required train-evidence `rg`: completed. Current retained train docs found for Train 5.5, Train 5.6, Train 6, Train 7, and Train 8, plus the Train 6-13 repo plan and this ledger. No retained `docs/validation/train_0*.md`, `train_1*.md`, `train_2*.md`, `train_3*.md`, or `train_4*.md` closeout was present at HEAD.

## Not Claimed

- No full build was run for AMB-1145.
- No simulator UI test was run for AMB-1145.
- No new screenshot or manual accessibility proof was produced for AMB-1145.
- No TestFlight, App Store, release, device, privacy/legal, or public accessibility readiness is claimed.
- Strict quality gate Green, when present, is only a global precondition and does not close every train's screenshot/accessibility/proof gap.

## Risk

The main risk is stale proof inflation: old local `.codex` artifacts and old commit messages are useful for inventory, but they are not current retained Green proof unless tied to current source, current commands, and current visual/accessibility review.

## Next Issue

The exact next active implementation/control-plane issue remains `AMB-1146` - Train 09 Exit Audit - Time Refraction close/repair decision.
