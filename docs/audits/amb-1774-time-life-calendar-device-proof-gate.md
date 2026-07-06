# AMB-1774 Time Life Calendar Device Proof Gate

Status: Implemented Yellow / Life Calendar source repair with device proof
blocked
Date: 2026-07-05
Scope: AMB-1774, Time Life Calendar device proof gate
Baseline SHA: `d00de1d63ca893792a62e27dca285fbc36913edd`
Linear status before closeout: `In Progress`

## Purpose

AMB-1774 is the device and screenshot proof gate for Time flagship behavior.
Current truth says Time is Ambitions' native Life Calendar: calendar-grade,
Apple-native, and enriched by capacity, protection, placement, proof, recovery,
and goal-path intelligence. Current truth also treats `LifeShape Field` as a
legacy/internal compatibility name unless future canon promotes it.

The current user instruction authorizes issue completion without running tests.
This packet therefore completes AMB-1774 as Implemented Yellow: active
product-facing Time source is repaired to `Life Calendar`, and the device proof
gate is recorded, but current physical-device proof, screenshots, accessibility
proof, and owner acceptance remain absent.

## Authority Inputs

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/remediation/dossiers/AMB-1197-time-native-life-calendar.md`
- `docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.md`
- `docs/audits/amb-1748-design-system-adoption-proof.md`
- `docs/audits/amb-1766-frontend-accessibility-acceptance.md`
- `docs/audits/amb-1769-frontend-known-issue-mapping.md`
- Current Time source under `Native/Ambitions/Surfaces/Time`
- Current Time product-object, component, accessibility, preview, theme, test,
  and vocabulary guard source

## Source Repair

The source repair replaces active product-facing Time object strings from the
legacy/internal `LifeShape Field` name to `Life Calendar` across:

- `Native/Ambitions/Language/UserFacingLanguage.swift`
- `Native/Ambitions/Surfaces/SurfacePrimaryObject.swift`
- `Native/Ambitions/Stage/StageObject.swift`
- `Native/Ambitions/Surfaces/Time/**`
- `Sources/Accessibility/*`
- `Sources/Components/*`
- `Sources/Previews/*`
- `Sources/Theme/*`
- Matching app and Time test assertions

Intentional compatibility left in place:

- Internal type, file, token, function, and case names such as
  `LifeShapeFieldView`, `LifeShapeFieldCanvas`, `TimeLifeShape*`,
  `lifeShapeField`, and `time.lifeShapeField` remain as source/compatibility
  names only. They are not treated as root user-facing product labels in this
  gate.

No route, persistence, command, side-effect, storage, projection ownership, or
runtime authority was added.

## Device Proof Gate Map

| Gate | Current result | Proof ceiling |
| --- | --- | --- |
| Native Life Calendar object language | Active product-facing Time strings now use `Life Calendar`. | Source repaired; rendered proof absent. |
| Legacy object label quarantine | Scoped active source/test scan for `LifeShape Field` returned no hits in product-facing Time paths. | Source repaired; internal identifiers remain. |
| Device proof | No physical-device Time run was performed. | Device proof absent. |
| Screenshot proof | No current Time screenshot matrix was captured. | Screenshot proof absent. |
| Time mutation/placement proof | Existing source remains mapped; no no-Step/valid-Step runtime walkthrough was produced here. | Runtime proof absent. |
| Known issue rows | AMB-1769 maps this gate to `AMB-ISSUE-0009`, `0501`-`0507`, `0913`, and `1401`-`1405`. This packet does not close those rows. | Known issue closure remains blocked by current proof. |

## Gate Decision

- AMB-1774 may close only as Implemented Yellow under the current no-testing
  instruction.
- Source law is repaired for current Time product language.
- Time is not device Green, screenshot Green, Runtime Green, Visual Green, or
  Release Green. Current dark/light screenshots, no-Step fake-placement proof,
  valid placement proof, day/week/month/year evidence, list accessibility
  proof, Dynamic Type proof, physical-device proof, and owner visual acceptance
  remain missing.

## Rollback And Block Policy

- If `LifeShape Field` reappears as active product-facing Time copy, move
  AMB-1774 or the affected follow-up to Needs Repair.
- If Time renders as a weak calendar clone, anti-calendar abstraction, fake
  placement surface, or unreadable visual field in current screenshots, keep
  Time Yellow/Red.
- If no-Step, valid-placement, orientation, list-equivalent, or proof-residue
  behavior lacks current runtime/device proof, block Time Green.
- Do not substitute source-only, architecture-only, stale screenshot, preview,
  or simulator-only evidence for physical-device proof.

## Proof Ceiling

Allowed claim:

- Current `main` contains an AMB-1774 source repair that aligns active
  product-facing Time object copy and contracts to `Life Calendar`, with
  device/screenshot/runtime proof gates and non-claims recorded.

Forbidden claims from this packet:

- physical-device Time proof exists
- Time screenshot proof exists
- no-Step fake-placement runtime proof exists
- valid placement runtime proof exists
- day/week/month/year rendered proof exists
- list/accessibility equivalent proof exists
- Dynamic Type Time text-fit proof exists
- manual VoiceOver proof exists
- owner visual acceptance exists
- Time Green
- Visual Green
- Runtime Green
- TestFlight readiness
- App Store readiness
- Release Green

## Validation

Commands run from `/Users/devan/Documents/GitHub/ambitions`:

- `git diff --check` - passed.
- `jq -e . docs/audits/amb-1774-time-life-calendar-device-proof-gate.json
  >/dev/null` - passed.
- `npx markdownlint-cli2 --no-globs
  docs/audits/amb-1774-time-life-calendar-device-proof-gate.md` - passed with 0
  errors.
- `rg -n "LifeShape Field" Native/Ambitions/Language Native/Ambitions/Stage
  Native/Ambitions/Surfaces/SurfacePrimaryObject.swift
  Native/Ambitions/Surfaces/Time Sources/Accessibility Sources/Components
  Sources/Previews Sources/Theme Native/AmbitionsTests/App
  Native/AmbitionsTests/Time -S` - passed; no scoped active
  product-facing/test hits remained.
- `python3 scripts/ambitions-unsupported-claim-scan.py
  docs/audits/amb-1774-time-life-calendar-device-proof-gate.md
  docs/audits/amb-1774-time-life-calendar-device-proof-gate.json` - passed.
- `scripts/release-claim-safety-scan.sh
  docs/audits/amb-1774-time-life-calendar-device-proof-gate.md
  docs/audits/amb-1774-time-life-calendar-device-proof-gate.json` - passed.
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
- `scripts/no-unsupported-ai-claim-scan.sh
  docs/audits/amb-1774-time-life-calendar-device-proof-gate.md
  docs/audits/amb-1774-time-life-calendar-device-proof-gate.json` - completed
  with advisory hits reviewed as context and non-claims.
- `scripts/privacy-boundary-scan.sh
  docs/audits/amb-1774-time-life-calendar-device-proof-gate.md
  docs/audits/amb-1774-time-life-calendar-device-proof-gate.json` - completed
  with advisory recommendation/inference wording hits reviewed as context, not
  claims from this packet.
- `xcodegen generate --spec project.yml` - passed and wrote the generated
  project.
- `scripts/ambitions-xcodegen-needed.sh` - pre-commit output was
  `XCODEGEN_NEEDED=1` because tracked Swift source/resource inputs were still
  dirty; `Ambitions.xcodeproj` had no diff after regeneration. Post-commit
  rerun returned `XCODEGEN_NEEDED=0` with project build inputs unchanged.

Commands not run:

- XCTest, UI test, simulator, screenshot, Time no-Step walkthrough, Time valid
  placement walkthrough, day/week/month/year rendered walkthrough,
  list/accessibility walkthrough, crash-log/symbolication proof, manual
  accessibility, performance walkthrough, physical-device, signed archive, and
  App Store Connect validation lanes - skipped under the current no-testing
  instruction.

## Closeout Notes

- Private Life Orchestration relationship: preserved. Time remains the local
  calendar-grade time-shaping surface that makes capacity, protection,
  placement, recovery, proof, and goal fit inspectable.
- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Language`, `Stage`, `Surfaces/Time`,
  `Sources/Components`, `Sources/Accessibility`, `Sources/Previews`,
  `Sources/Theme`, tests, and audit docs.
- Files created: `docs/audits/amb-1774-time-life-calendar-device-proof-gate.md`
  and `docs/audits/amb-1774-time-life-calendar-device-proof-gate.json`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: internal `LifeShape*` source identifiers
  remain compatibility/type names only.
- Yellow debt: current Time physical-device proof, screenshot proof,
  no-Step/valid-placement proof, orientation proof, list-equivalent
  accessibility proof, Dynamic Type text fit, manual accessibility, owner visual
  acceptance, and release proof remain absent.
- No equivalent folder/path interpretation was used.
