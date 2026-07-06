# AMB-1775 Shell Chrome Screenshot Matrix

Status: Implemented Yellow / shell matrix indexed with rendered proof blocked
Date: 2026-07-06
Scope: AMB-1775, shell chrome screenshot matrix
Baseline SHA: `0bece62b10b05ac3d7fb66dd2127ec19c8699b00`
Linear status before closeout: `In Progress`

## Purpose

AMB-1775 is the shell-specific screenshot proof lane for Ambitions root chrome,
route depth, safe-area behavior, and Dynamic Type states. It maps the shell
proof requirements that remain after earlier source repairs into a concrete
matrix that can be captured once testing is re-enabled.

The current user instruction authorizes issue completion without running tests.
This packet therefore completes AMB-1775 as Implemented Yellow: the current
matrix is indexed, and one source regression in the root dock selected state is
repaired, but no current rendered shell screenshots, simulator run,
physical-device proof, manual accessibility review, owner visual acceptance, or
release proof were produced.

## Authority Inputs

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.md`
- `docs/audits/amb-1749-frontend-evidence-harness.md`
- `docs/audits/amb-1765-frontend-screenshot-device-proof-matrix.md`
- `docs/audits/amb-1769-frontend-known-issue-mapping.md`
- Current shell source under `Native/Ambitions/App` and
  `Native/Ambitions/Stage`
- Current shell contract tests under `Native/AmbitionsTests/App`

## Source Repair

The AMB-1775 source change removes the visible selected capsule fill from
`StageDockRail`. Selection now stays limited to icon foreground color plus the
accessibility selected trait.

This repair aligns the active dock source with `AMB-ISSUE-1703`, which records
that the root dock should not show underline, selected capsule fill, active
border, or active weight change.

Files changed:

- `Native/Ambitions/Stage/Chrome/StageDockRail.swift`
- `Native/AmbitionsTests/App/AppShellChromeTests.swift`

No navigation, route, persistence, command, side-effect, storage, projection,
receipt, replay, or runtime authority was added.

## Static Shell Evidence

Current source now provides static, non-rendered evidence for the shell lanes:

| Source contract | Current source state | Proof ceiling |
| --- | --- | --- |
| Root dock visibility | `DockBehaviorPolicy` shows the root dock only at root route depth with no overlay. | Source contract only; rendered proof absent. |
| Drilldown chrome | `StagePathStore` derives drilldown state from Goals, Time, and You route paths, and `AmbitionsStage` renders the dock only when `showsRootDock` is true. | Source contract only; route screenshots absent. |
| Safe-area clearance | `StageSafeAreaPolicy` reserves root dock clearance and larger Dynamic Type clearance; `AppShellScaffold` applies bottom safe-area inset clearance. | Source contract only; no-overlap proof absent. |
| Overlay chrome | Capture, sheet, create-goal, and memory-lens overlays hide the root dock through shell overlay presentation policy. | Source contract only; overlay screenshots absent. |
| Dock anatomy | `StageDockRail` remains icon-only in visible content and uses accessibility labels for the four destinations. | Source contract only; rendered visual review absent. |
| Selected state | The selected visual state is icon foreground color without a visible capsule fill. | Source contract only; current screenshots absent. |

## Required Screenshot Matrix

| Lane | Required captures | Current status |
| --- | --- | --- |
| Root shell | Today, Goals, Time, and You root shell with the dock visible and content clear of the bottom chrome. | Required, not captured. |
| Route depth | Goals detail, Time drilldown, You detail, back return, and reselection-to-root paths with the dock hidden. | Required, not captured. |
| Safe area / no overlap | Small supported iPhone class, primary current iPhone class, keyboard-present state, and accessibility Dynamic Type root shell. | Required, not captured. |
| Overlays | Capture composer, Search/Memory Lens overlay, create-goal sheet, continuity receipt, and dismiss/back return state. | Required, not captured. |
| Appearance | Light, System, and Dark appearance for root shell and at least one drilldown. | Required, not captured. |
| Accessibility settings | Dynamic Type accessibility size, Reduce Motion, Increase Contrast, and Differentiate Without Color for the root shell. | Required, not captured. |
| Surface transitions | Today to Goals, Goals to Time, Time to You, and You back to Today using the dock without duplicate bottom navigation. | Required, not captured. |
| Inspection/trust entry | Proof, Source, Privacy, History, or Receipts entry and return path from shell context. | Required, not captured. |

## Known Issue Mapping

AMB-1769 maps AMB-1775 to:

- `AMB-ISSUE-0006`
- `AMB-ISSUE-0007`
- `AMB-ISSUE-0806`
- `AMB-ISSUE-0901`
- `AMB-ISSUE-0902`
- `AMB-ISSUE-1011`
- `AMB-ISSUE-1701` through `AMB-ISSUE-1709`

This packet does not close those known issue rows. It updates the source state
for the selected dock fill regression and records the proof matrix needed to
verify the rows later. The rows remain unverified until current rendered
screenshots prove root dock anatomy, no-overlap behavior, route-depth hiding,
overlay behavior, and supported accessibility settings.

## Gate Decision

- AMB-1775 may close only as Implemented Yellow under the current no-testing
  instruction.
- Source now matches the icon-only selected-state expectation for the touched
  dock row.
- Shell screenshot proof, no-overlap proof, Dynamic Type proof, overlay proof,
  device proof, manual accessibility proof, owner visual acceptance, and release
  proof remain absent.

## Rollback And Block Policy

- If the dock selected capsule fill, underline, active border, duplicate shelf,
  or visible dock words reappear in active root shell source, move the affected
  row to Needs Repair.
- If current screenshots show root content behind the dock, route-depth dock
  leakage, duplicate bottom navigation, clipped Dynamic Type text, unsafe
  keyboard overlap, or inaccessible selected state, keep the shell lane Yellow
  or Red.
- Do not substitute source-only, matrix-only, stale screenshot, preview-only,
  simulator-only, or historical review evidence for current rendered proof.

## Proof Ceiling

Allowed claim:

- Current `main` contains an AMB-1775 shell screenshot matrix and a narrow
  source repair that removes the root dock selected capsule fill, with
  screenshot/device/accessibility non-claims recorded.

Forbidden claims from this packet:

- shell screenshots were captured
- root dock no-overlap proof exists
- route-depth dock hiding rendered proof exists
- keyboard clearance proof exists
- Dynamic Type shell proof exists
- Reduce Motion shell proof exists
- manual VoiceOver proof exists
- physical-device shell proof exists
- owner visual acceptance exists
- shell Visual Green
- frontend Visual Green
- Accessibility Green
- TestFlight readiness
- App Store readiness
- Release Green

## Validation

Commands run from `/Users/devan/Documents/GitHub/ambitions`:

- `git diff --check` - passed.
- `jq -e . docs/audits/amb-1775-shell-chrome-screenshot-matrix.json
  >/dev/null` - passed.
- `npx markdownlint-cli2 --no-globs
  docs/audits/amb-1775-shell-chrome-screenshot-matrix.md` - passed with 0
  errors.
- `python3 scripts/ambitions-unsupported-claim-scan.py
  docs/audits/amb-1775-shell-chrome-screenshot-matrix.md
  docs/audits/amb-1775-shell-chrome-screenshot-matrix.json` - passed.
- `scripts/release-claim-safety-scan.sh
  docs/audits/amb-1775-shell-chrome-screenshot-matrix.md
  docs/audits/amb-1775-shell-chrome-screenshot-matrix.json` - passed.
- `python3 scripts/ambitions-screenshot-artifact-audit.py` - passed as a static
  guard; no screenshot artifact was produced.
- `python3 scripts/ambitions-device-proof-required.py` - passed as a static
  guard; no device proof was produced.
- `python3 scripts/ambitions-remediation-governance-check.py` - passed.
- `python3 scripts/ambitions-architecture-inventory.py` - passed with final-tree
  parity.
- `python3 scripts/ambitions-vocabulary-drift-scan.py` - passed.
- `python3 scripts/ambitions-truth-path-vocabulary-audit.py` - passed.
- `python3 scripts/ambitions-green-standard-audit.py` - passed as a static
  source scan.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` - passed.
- `rg -n
  "theme\\.shell\\.controlBackground|Text\\(destination\\.title\\)|\\.stroke\\(|\\.background \\{"
  Native/Ambitions/Stage/Chrome/StageDockRail.swift -S` - returned no hits;
  selected capsule fill and visible dock-title text remain absent from the
  dock source.
- `scripts/no-unsupported-ai-claim-scan.sh
  docs/audits/amb-1775-shell-chrome-screenshot-matrix.md
  docs/audits/amb-1775-shell-chrome-screenshot-matrix.json` - completed with
  advisory hits reviewed as context and non-claims.
- `scripts/privacy-boundary-scan.sh
  docs/audits/amb-1775-shell-chrome-screenshot-matrix.md
  docs/audits/amb-1775-shell-chrome-screenshot-matrix.json` - completed with
  advisory hits reviewed as context and non-claims.
- `xcodegen generate --spec project.yml` - passed and wrote the generated
  project.
- `scripts/ambitions-xcodegen-needed.sh` - pre-commit output was
  `XCODEGEN_NEEDED=1` because tracked Swift source inputs were still dirty;
  `Ambitions.xcodeproj` had no diff after regeneration. Post-commit rerun
  returned `XCODEGEN_NEEDED=0` with project build inputs unchanged.

Commands not run:

- XCTest, UI test, simulator, screenshot capture, keyboard walkthrough,
  route-depth walkthrough, overlay walkthrough, manual accessibility,
  performance walkthrough, physical-device, signed archive, and App Store
  Connect validation lanes - skipped under the current no-testing instruction.

## Closeout Notes

- Private Life Orchestration relationship: preserved. Shell chrome stays a
  thin native route/access layer around Today, Goals, Time, You, Capture,
  Motion behavior, and inspectable trust entry points.
- Final Architecture Tree inspected: yes.
- Canonical owners inspected: `App/`, `Stage/`, `Stage/Chrome`, `Stage/Overlays`,
  `Surfaces/Today`, `Surfaces/Goals`, `Surfaces/Time`, `Surfaces/You`,
  `Composer/Capture`, `Trust/`, tests, and audit docs.
- Canonical owners touched: `Stage/Chrome`, tests, and audit docs.
- Files created: `docs/audits/amb-1775-shell-chrome-screenshot-matrix.md` and
  `docs/audits/amb-1775-shell-chrome-screenshot-matrix.json`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow debt: current rendered shell screenshots, route-depth screenshots,
  no-overlap proof, keyboard clearance proof, Dynamic Type proof, Reduce Motion
  proof, manual accessibility, physical-device proof, owner visual acceptance,
  and release proof remain absent.
- Next proof train: capture the AMB-1775 shell matrix when testing/device proof
  is re-enabled.
- No equivalent folder/path interpretation was used.
