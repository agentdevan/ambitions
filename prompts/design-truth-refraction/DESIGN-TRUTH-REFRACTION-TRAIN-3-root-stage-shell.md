<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`DESIGN-TRUTH-REFRACTION-TRAIN-3`

## Objective

Implement Design Truth Refraction Train 3: root stage and shell migration.

Active product law:

```text
Persistent surfaces: Today / Goals / Time / You
Global composer: Capture
Cross-surface behavior: Motion
Trust inspection: Proof / Source / Privacy / History / Receipts
```

Capture is the global Atmosphere Composer / Open Field action layer, not a tab, inbox, notes feed, category grid, chatbot, or persistent floating button.

Motion is Stage/Motion behavior, not a tab, destination, activity feed, analytics surface, score, streak, or progress dashboard.

Plan/Profile/Captures/Pulse/Motion-tab/Capture-tab language is historical or compatibility context only unless active truth explicitly scopes a migration.

## Previous Train Clearance

PREVIOUS_PACKET_CLEARANCE:
- Train 0/1 audit artifacts exist and may need regeneration against current `HEAD`.
- Train 2 enforcement gates landed on `main`.
- Train 2.6 recovered focused XCTest infrastructure with executed-test proof for `ScreenContractRegistryTests`, `RepoTruthAuditLedgerTests`, and `StageMotionRoutingTests`.
- Yellow debt from earlier Train 2 focused-test startup is superseded by Train 2.6 for the focused XCTest infrastructure prerequisite.
- Do not reopen older Red artifacts unless current source or guard evidence shows a new active Red.

## Active Source Truth To Inspect

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
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppNavigation.swift`
- `Native/Ambitions/App/AppTab.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`
- `Native/Ambitions/Stage/`
- `Native/AmbitionsTests/App/`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `scripts/ambitions-design-truth-refraction-audit.py`

## Allowed Scope

- Refresh generated Train 0/1 audit artifacts if stale:
  - `docs/audits/design_truth_readback.md`
  - `docs/audits/design_truth_refraction_audit.md`
  - `docs/audits/file_by_file_truth_ledger.md`
- Add this Train 3 prompt under `prompts/design-truth-refraction/`.
- Add Stage shell ownership/path policy files under `Native/Ambitions/Stage/`.
- Update root shell and navigation files only as needed to remove technical `TabView` root architecture and centralize dock/overlay/depth policy:
  - `Native/Ambitions/App/AmbitionsRootView.swift`
  - `Native/Ambitions/App/AppNavigation.swift`
  - `Native/Ambitions/App/AppStageShellChromeState.swift`
  - `Native/Ambitions/App/AppMeridianShell.swift`
- Update focused app shell tests and affected UI shell tests:
  - `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
  - `Native/AmbitionsTests/App/AppShellChromeTests.swift`
  - `Native/AmbitionsUITests/AmbitionsUITests.swift`
- Add a Train 3 validation report under `docs/validation/`.

## Forbidden Scope

- No Today, Goals, Time, You content reconstruction.
- No Capture composer rebuild beyond route/chrome integration.
- No Motion feature UI rebuild.
- No new runtime dependency.
- No project manifest, entitlement, signing, account, provider, R2, privacy manifest, or release mutation.
- No Motion root destination.
- No Capture root destination.
- No fifth persistent surface.
- No hosted AI/cloud LLM/core model dependency.
- No account requirement for core local app value.
- No private life graph backend.
- No private user context in R2/Source Atlas requests.

## Implementation Requirements

- Replace root `TabView` product architecture with a Stage-owned host driven by Today, Goals, Time, and You only.
- Create or complete `SurfaceOwnershipRegistry`.
- Create or complete `StagePathStore`.
- Centralize shell policy for route depth, overlay state, dock visibility, dock clearance, capture overlay clearance, and receipt clearance.
- Ensure root dock appears only at root depth and when global Capture is not active.
- Ensure drilldowns use native back behavior and do not show the root dock.
- Ensure Capture compatibility routes open a global overlay, never a root destination.
- Ensure Motion compatibility routes resolve to Today or Stage/Motion behavior, never a root destination.
- Retire stale dual-shell launch-mode assumptions if the source has a single real shell.

## Validation Expectations

- `git diff --check`
- `python3 scripts/ambitions-design-truth-refraction-audit.py --write`
- `python3 scripts/ambitions-design-truth-refraction-audit.py --check`
- `python3 scripts/ambitions-legacy-ia-route-lint.py`
- `python3 scripts/ambitions-surface-contract-lint.py`
- `python3 scripts/ambitions-copy-contract-lint.py --include-components`
- `python3 scripts/ambitions-visible-copy-drift-scan.py --strict`
- `python3 scripts/ambitions-vocabulary-drift-scan.py`
- `python3 scripts/ambitions-moat-drift-scan.py`
- `python3 scripts/ambitions-repo-authority-validate.py`
- `scripts/ambitions-xcode-build-for-testing.sh --batch DESIGN-TRUTH-REFRACTION-TRAIN-3`
- Focused XCTest lanes:
  - `AmbitionsTests/AppShellNavigationTests`
  - `AmbitionsTests/AppShellChromeTests`
  - `AmbitionsTests/ScreenContractRegistryTests`
  - `AmbitionsTests/ShellPreviewMatrixTests`
  - `AmbitionsTests/StageMotionRoutingTests`
  - `AmbitionsTests/ShellCommandRouterTests`
- Affected UI shell tests for root dock, drilldown dock hiding, Capture overlay keyboard clearance, Motion non-root routing, and shell screenshots.

## Visual Proof Expectations

- Extract or identify Train 3 screenshot attachments from the affected UI test result bundle.
- Visually inspect screenshots before making visual claims.
- Record screenshot paths, review result, and no-claim boundaries in `docs/validation/`.
- Do not claim public accessibility certification, device validation, release readiness, TestFlight readiness, App Store readiness, privacy/legal approval, account readiness, or R2 readiness.

## Hard Red Stop Conditions

- Motion appears as a root destination.
- Capture appears as a root destination.
- Root shell keeps technical `TabView` as product architecture.
- A fifth persistent surface appears.
- Focused tests execute zero intended tests.
- Source changes cannot be validated honestly.
- Tests are updated to hide failures instead of validating the Stage shell truth.

## Rollback Expectations

- Record the starting commit.
- Commit only the Train 3 scoped files after validation.
- Push `main` only after Green or explicitly accepted Yellow.
- Rollback is the Train 3 commit revert; no hidden alternate product shell should be required.
