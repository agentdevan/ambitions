# Post-Batch Gate Registry

<!-- markdownlint-disable MD013 -->

Status: Active continuation gate registry. Current singular sequence index: `GLOBAL_BATCH_SEQUENCE.md`.
Date: 2026-05-08  
Scope: post-batch safety gates for the global train.

## Purpose

This registry defines mandatory gates that must run after specific batches and before the global train continues.

It exists to prevent Codex from continuing over dirty, unclassified, stale, or unsafe repo state.

## Gate Rules

- Gates do not replace the active global batch train.
- Gates do not change product IA or app behavior by themselves.
- Gates must re-read `.codex/state/active-batch.yml` before acting.
- Gates must not run destructive git cleanup commands.
- If a gate exits nonzero, the global train must stop until the report is classified.

## Active Gates

| Trigger | Gate | Required command | Pass condition | Block condition | Resume behavior |
| --- | --- | --- | --- | --- | --- |
| After PK03 AppUnitOfWork Foundation closes, before selecting the next global batch | Post-PK03 Dirty Worktree Reconciliation Gate | `bash scripts/codex-post-pk03-dirty-reconciliation.sh` | exit 0 and clean worktree | exit 86 or unknown dirty state | Re-read active batch, then resume global train only after clean/classified state |

## Post-PK03 Dirty Worktree Reconciliation Gate

Source prompt:

- `docs/codex/batches/POST_PK03_Dirty_Worktree_Reconciliation_Gate_Prompt.md`

Script:

- `scripts/codex-post-pk03-dirty-reconciliation.sh`

Generated evidence:

- `.codex/logs/dirty-worktree/status-*.txt`
- `.codex/logs/dirty-worktree/untracked-*.txt`
- `.codex/logs/dirty-worktree/name-status-*.txt`
- `.codex/patches/dirty-worktree-*.patch`
- `.codex/patches/dirty-worktree-staged-*.patch`
- `docs/audits/post-pk03-dirty-worktree-reconciliation-*.md`
- `docs/audits/post-pk03-dirty-worktree-reconciliation-latest.md`

## Required Codex Behavior

After PK03 closes:

1. Do not start PK04 or any next global batch yet.
2. Re-read active batch state.
3. Run the required command.
4. If clean, record the report and continue.
5. If dirty, classify every dirty file before continuing.
6. Do not discard or reset anything without human approval.

## Hard Red

Continuing the global train after PK03 without this gate is a Hard Red.

Continuing with dirty unclassified state is a Hard Red.

## Non-Claims

This registry does not implement app behavior, validate builds/tests, prove release readiness, prove device behavior, prove public accessibility conformance, or grant legal/privacy approval.

## IOS26 Flagship Train Gates

Status: installed_not_run. Accepted Yellow IOS26 closeouts must record owner, safety reason, no-claim boundary, and follow-up gate here before continuation. Red stops the train.

### IOS26-T01-B01 Accepted Yellow

- Date: 2026-05-22
- Owner: Codex operator for the user-requested global train continuation
- Run directory: `.codex/runs/IOS26-T01-B01/20260522T113527Z`
- Safety reason: toolchain proof artifacts confirm Xcode app `26.3`, iOS SDK `26.2`, iOS runtime `26.3`, booted `iPhone 17`, XcodeGen `2.45.4`, Swift `6.2.4`, and the SwiftPM boundary that `.iOS(.v26)` requires PackageDescription `6.2`; no target bump, project/package edit, source edit, build claim, test claim, accessibility claim, privacy claim, or release claim was made.
- Yellow reason: raw `xcodebuild -version` and `xcodebuild -showsdks` shell probes were blocked by the outer policy with `approval required by policy, but AskForApproval is set to Never`.
- No-claim boundary: do not claim raw `xcodebuild` proof, build success, test success, accessibility proof, privacy approval, release readiness, device proof, or completed iOS 26 target migration from this batch.
- Follow-up gate: `IOS26-T01-B02` may consume this as accepted-Yellow toolchain evidence only if it preserves the recorded raw-`xcodebuild` blocker and reruns build/test validation after the target bump.

### IOS26-T02-B00 Safe-Area Screenshot/Device Gate

- Date: 2026-05-22
- Owner: Codex operator / next IOS26 train continuation owner
- Run directory: `.codex/runs/IOS26-T02-B00/20260522T123555Z`
- Safety reason: source and wrapper validation support the safe-area root invariant without broadening architecture: root bottom chrome moved into `AmbitionsRootView.safeAreaInset(edge: .bottom, spacing: 0)`, Capture foreground top safe-area ignore was removed, `xcodegen generate` passed, `scripts/build-local.sh` passed, and `make xcode-focused-test BATCH=IOS26-T02-B00 TEST=AmbitionsTests/AppShellChromeTests` passed.
- Yellow reason: simulator screenshot proof, device proof, keyboard-specific visual proof, and manual accessibility proof were not collected for the touched root/Capture geometry.
- No-claim boundary: do not claim screenshot proof, device validation, keyboard collision proof, visual quality completion, accessibility validation, release readiness, TestFlight readiness, App Store readiness, or physical-device behavior from IOS26-T02-B00 until current proof artifacts exist.
- Follow-up gate: before Train 05 or any screenshot-dependent IOS26 shell/visual batch claims Green from this geometry invariant, collect simulator screenshot or device proof for status bar, Dynamic Island, home indicator, keyboard, tab chrome, and touched Capture top inset behavior; record accessibility/visual proof status in the relevant proof packet.

### IOS26-T02-B03 Screenshot/Icon Proof Foundation Gate

- Date: 2026-05-22
- Owner: Codex operator / Design-QA proof continuation owner
- Run directory: `.codex/runs/IOS26-T02-B03/20260522T142815Z`
- Safety reason: scoped proof infrastructure landed without app-source, project-config, asset, privacy-manifest, entitlement, or runtime behavior changes. `make validate-visual-proof` and `python3 scripts/ambitions_validate_visual_proof.py` passed with `GREEN`; `xcodegen generate` passed; `scripts/build-local.sh` passed with latest reviewed log `output/logs/build-local-20260522-104146.log`.
- Yellow reason: current screenshot capture proof, manual visual approval, public accessibility verification, device proof, and full test-suite Green are absent. The wrapper lane `make xcode-focused-test BATCH=IOS26-T02-B03 TEST=AmbitionsTests` produced `.codex/xcode-summaries/IOS26-T02-B03/20260522T144322Z/focused-test-summary.json` with `test_failure`; the failures are outside the B03 proof-foundation slice.
- No-claim boundary: do not claim screenshot proof, visual approval, accessibility approval, physical-device validation, performance validation, release readiness, TestFlight readiness, App Store readiness, or full test-suite Green from IOS26-T02-B03 until current proof artifacts exist.
- Follow-up gate: before any screenshot-dependent IOS26 shell/visual batch claims Green, add current screenshot capture artifacts or a real screenshot-helper proof lane, attach them to the current commit, classify accessibility proof separately from source support, and rerun the visual proof validator plus the appropriate Xcode wrapper lane.
