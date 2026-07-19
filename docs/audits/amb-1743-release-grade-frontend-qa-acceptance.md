# AMB-1743 Release-Grade Frontend QA Acceptance

Status: Implemented Yellow / completion authorized without runtime testing
Date: 2026-07-05
Scope: AMB-1743, M10 Release-grade Frontend QA
Baseline SHA: `c1782c54a139dd2a47fa74cbe73838c4b60a2b08`
Linear status before closeout: `In Progress`

## Purpose

AMB-1743 installs the release-grade frontend QA acceptance ladder that must sit
between source work and any visual, interaction, accessibility, navigation, or
release claim.

The current user instruction authorizes issue completion without running tests.
This packet therefore completes the QA contract and evidence index as
Implemented Yellow. It does not run XCTest, UI tests, simulator lanes,
screenshots, manual accessibility review, performance walkthroughs, or device
proof, and it does not claim frontend QA Green.

## Controlling Inputs

Current retained repo inputs:

- AMB-1749 frontend evidence harness:
  `docs/audits/amb-1749-frontend-evidence-harness.md`,
  `docs/audits/amb-1749-frontend-evidence-harness.json`, and
  `scripts/ambitions-frontend-evidence-harness.py`.
- AMB-1750 frontend proof gate:
  `Native/Ambitions/Quality/ReleaseFrontendProofGate.swift` and
  `docs/audits/amb-1750-visual-green-app-store-frontend-proof-gate.md`.
- Current route/screen/journey registries:
  `docs/audits/frontend-screen-route-registry.md` and
  `docs/audits/frontend-journey-registry.md`.
- Current design-system adoption proof:
  `docs/audits/amb-1748-design-system-adoption-proof.md`.
- Local benchmark wrapper:
  `scripts/ambitions-xcode-benchmark.sh`.

## QA Ladder

| Layer | Retained owner | Scope | Claim ceiling |
| --- | --- | --- | --- |
| Fast local frontend lane | `scripts/ambitions-frontend-evidence-harness.py` -> `fast_frontend_local` | Source-route, shell, visual-fixture, and accessibility contract checks. | Harness/source coverage only. No rendered quality, accessibility conformance, device, or frontend Green claim. |
| Focused journey lanes | AMB-1749 UI journey index | Root shell, Capture, Today, Goals, Time, You, and inspection path test symbols. | Indexed test coverage only until those lanes are executed and artifacts are reviewed. |
| Screenshot artifact lane | AMB-1749 `frontend_screenshot_artifacts` | Stable screenshot/result/log/summary roots under `.codex/xcode-*`. | Screenshot artifact existence only for a named run; not visual acceptance. |
| Slow release index lane | AMB-1749 `frontend_release_index` | Validates harness structure and proof-denial locks. | Index proof only. AMB-1750 owns release-facing status. |
| Accessibility smoke | AMB-1749 accessibility smoke index plus AMB-1748 accessibility policy mapping | Dynamic Type contracts, Reduce Motion contracts, non-color meaning, hit target, and manual proof requirements. | Requirement coverage only. No manual VoiceOver or accessibility conformance claim. |
| Visual review gate | AMB-1750 frontend proof gate | Keeps frontend release quality Yellow until current screenshots, human review, accessibility, and device proof exist. | Blocks Visual Green and App Store frontend claims. |
| Performance budget hook | `scripts/ambitions-xcode-benchmark.sh` | Measures local Xcode loop or wraps named commands into benchmark summaries. | Timing evidence only; not build, test, release, accessibility, device, TestFlight, or App Store proof. |
| Rollback / flake policy | This packet plus AMB-1750 gate | Flaky gates may be disabled only by preserving artifact capture and creating Needs Repair follow-up. | Disabling a gate cannot upgrade readiness. |

## Required Journey Coverage

AMB-1743 requires QA coverage for root shell, Capture-to-Today, Today, Goals,
Time, You, and inspection paths. Current repo evidence provides source/test
index coverage through AMB-1749:

| Journey | Indexed evidence | Required before Green |
| --- | --- | --- |
| Root shell | AMB-1749 `root_shell` journey symbols in `Native/AmbitionsUITests/AmbitionsUITests.swift`. | Current launch screenshot, safe-area proof, dock hit target proof, and root route review. |
| Capture-to-Today | AMB-1749 `capture` journey symbols plus AMB-1736 Capture acceptance packet. | Keyboard clearance, save mutation, placement/review, receipt, dismissal, and screenshot proof. |
| Today | AMB-1749 `today` journey symbols plus AMB-1737 Today acceptance packet. | Start here screenshot, route handoff, state mutation, receipt, and accessibility summary proof. |
| Goals | AMB-1749 `goals` journey symbols plus AMB-1738 Goals acceptance packet. | Goals root, Life Area, goal detail, create/edit, back path, and screenshot proof. |
| Time | AMB-1749 `time` journey symbols plus AMB-1739 Time acceptance packet. | LifeShape Field, weekly review, Dynamic Type, Reduce Motion, time-boundary proof, and screenshots. |
| You | AMB-1749 `you` journey symbols plus AMB-1740 You acceptance packet. | You root, detail routes, privacy/trust rows, settings controls, and screenshot proof. |
| Inspection paths | AMB-1749 `inspection` journey symbols plus Trust inspection source owners. | Proof, Source, Privacy, History, Receipts invocation proof, return paths, and accessibility-size review. |

## Accessibility Acceptance Contract

Automated smoke requirements:

- Dynamic Type coverage must include root shell, Capture, Today, Goals, Time,
  You, and inspection details.
- Reduce Motion coverage must include shell transitions, Capture, Time layers,
  recovery/reflow, and inspection routes.
- VoiceOver labels, values, hints, focus order, and semantic grouping must be
  checked for launch-critical paths before any accessibility Green claim.
- Non-color meaning, contrast, tap targets, and clipping/overlap checks must
  be included for release-critical screenshots.
- Automated contract checks are not enough for public accessibility
  conformance.

Manual owner-review requirements:

- Manual VoiceOver walkthrough for launch-critical paths.
- Dynamic Type screenshot review at accessibility sizes.
- Reduce Motion walkthrough with static-equivalent review.
- Owner visual review of hierarchy, clipping, awkward controls, and dead routes.
- Device-sensitive review before App Store or TestFlight frontend claims.

## Acceptance Mapping

| AMB-1743 acceptance criterion | Current result |
| --- | --- |
| Tests cover root shell, Capture-to-Today, Today, Goals, Time, You, and inspection paths. | Indexed through AMB-1749 harness and AMB-1751 route/journey registries. Not executed in this packet. |
| Screenshot artifacts are generated in a predictable location. | Stable roots are defined by AMB-1749 under `.codex/xcode-results`, `.codex/xcode-logs`, and `.codex/xcode-summaries`. No new screenshots are captured here. |
| Accessibility smoke includes VoiceOver labels and Dynamic Type. | Requirement and contract coverage are indexed by AMB-1748 and AMB-1749. Manual VoiceOver and current Dynamic Type render proof remain missing. |
| Slow release lane is separated from fast local lane. | Present in AMB-1749: `fast_frontend_local`, `frontend_screenshot_artifacts`, and `frontend_release_index` are separate lanes. |
| QA gates do not make subjective Visual Green claims without human review. | Present through AMB-1750: frontend release quality remains Yellow and Visual Green/App Store claims are blocked. |
| Baseline screenshot matrix and comparison approach are defined and runnable. | Defined through AMB-1749 screenshot lane and `scripts/ambitions-run-ui-screenshot-matrix.sh`; not run under no-testing instruction. |
| Automated smoke plus manual-owner review requirements are documented. | Present in this packet and AMB-1750 proof gate. |
| Passing unit tests alone cannot close frontend QA Green. | Present. This packet explicitly preserves Yellow and requires screenshot, visual, accessibility, performance, and device proof. |
| Rollback plan preserves artifact capture and Needs Repair follow-up. | Present. Flaky gates may be disabled only with artifact capture retained and a Needs Repair follow-up. |

## Proof Ceiling

Allowed claim:

- Current `main` has a release-grade frontend QA acceptance ladder that indexes
  fast/slow frontend lanes, journey coverage, screenshot artifact roots,
  accessibility smoke requirements, manual owner-review requirements,
  performance timing hooks, rollback policy, and no-fake-Green gates.

Forbidden claims from this packet:

- rendered screenshot coverage
- rendered visual quality
- accessibility conformance
- manual VoiceOver completion
- Dynamic Type rendered fit
- Reduce Motion rendered fit
- performance budget pass
- physical-device behavior
- TestFlight readiness
- App Store readiness
- frontend QA Green
- Release Green

## Validation

Commands run from `/Users/devan/Documents/GitHub/ambitions`:

- `python3 scripts/ambitions-frontend-evidence-harness.py --check --json`
  - initially failed because AMB-1749 referenced stale symbol
  `testLaunchURLCanLandOnCanonicalTimeSurface`.
  - Fixed AMB-1749 to reference current symbol
  `testDemoTimeWorkspaceShowsBatch49CoreModules`.
  - Rerun passed, `status=passed`, `failure_category=passed`.
- `bash scripts/ambitions-xcode-benchmark.sh --status` - passed,
  `status=installed`, `artifact_root=.codex/xcode-benchmarks`.
- `python3 -m py_compile scripts/ambitions-frontend-evidence-harness.py`
  - passed.
- `git diff --check` - passed.
- `jq . docs/audits/amb-1743-release-grade-frontend-qa-acceptance.json`
  - passed.
- `jq . docs/audits/amb-1749-frontend-evidence-harness.json` - passed.
- `npx markdownlint-cli2 --no-globs docs/audits/amb-1743-release-grade-frontend-qa-acceptance.md docs/audits/amb-1749-frontend-evidence-harness.md`
  - passed, `Summary: 0 error(s)`.
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1743-release-grade-frontend-qa-acceptance.md docs/audits/amb-1743-release-grade-frontend-qa-acceptance.json docs/audits/amb-1749-frontend-evidence-harness.md docs/audits/amb-1749-frontend-evidence-harness.json`
  - passed, `GREEN: unsupported completion/readiness claim scan passed`.
- `scripts/release-claim-safety-scan.sh docs/audits/amb-1743-release-grade-frontend-qa-acceptance.md docs/audits/amb-1743-release-grade-frontend-qa-acceptance.json docs/audits/amb-1749-frontend-evidence-harness.md docs/audits/amb-1749-frontend-evidence-harness.json`
  - passed, `GREEN no proof-sensitive release claims found`.
- `python3 scripts/ambitions-screenshot-artifact-audit.py` - passed,
  `ambitions-screenshot-artifact-audit GREEN`.
- `python3 scripts/ambitions-device-proof-required.py` - passed,
  `ambitions-device-proof-required GREEN`.
- `python3 scripts/ambitions-remediation-governance-check.py` - passed,
  `GREEN remediation governance guard passed`.
- `python3 scripts/ambitions-architecture-inventory.py` - passed,
  `GREEN final-tree parity achieved`.
- `python3 scripts/ambitions-vocabulary-drift-scan.py` - passed,
  `GREEN: canonical and active vocabulary terms are present and explicit ban
  terms are absent`.
- `python3 scripts/ambitions-truth-path-vocabulary-audit.py` - passed,
  `GREEN: truth paths resolve or are explicitly planned/internal, and active
  stale terms are quarantined`.
- `python3 scripts/ambitions-green-standard-audit.py` - passed,
  `GREEN: no disallowed architecture-as-UI strings found in active primary UI
  source`.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed,
  `GREEN: local-first/account/R2/hosted-AI boundary checks passed in active
  authority files`.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` - passed,
  `valid=true`, `invalidAcceptedYellowIssues=0`.
- `scripts/no-unsupported-ai-claim-scan.sh docs/audits/amb-1743-release-grade-frontend-qa-acceptance.md docs/audits/amb-1743-release-grade-frontend-qa-acceptance.json docs/audits/amb-1749-frontend-evidence-harness.md docs/audits/amb-1749-frontend-evidence-harness.json`
  - advisory Yellow; review showed contextual non-claim terms only.
- `scripts/privacy-boundary-scan.sh docs/audits/amb-1743-release-grade-frontend-qa-acceptance.md docs/audits/amb-1743-release-grade-frontend-qa-acceptance.json docs/audits/amb-1749-frontend-evidence-harness.md docs/audits/amb-1749-frontend-evidence-harness.json`
  - advisory Yellow; review showed contextual privacy/local-first terms only.
- `xcodegen generate --spec project.yml` - passed.
- `scripts/ambitions-xcodegen-needed.sh` - passed, `XCODEGEN_NEEDED=0`.

Commands not run:

- XCTest, UI test, simulator, screenshot, accessibility runtime, performance
  walkthrough, and device lanes - skipped under the current no-testing
  instruction.

## Closeout Notes

- Private Life Orchestration relationship: preserved. The QA ladder protects
  frontend evidence for the user-facing loop from intent through context, path,
  time fit, action, proof, and learning.
- Final Architecture Tree inspected: yes.
- Canonical owners inspected: `App/`, `Stage/`, `DesignSystem/`,
  `Surfaces/Today`, `Surfaces/Goals`, `Surfaces/Time`, `Surfaces/You`,
  `Composer/Capture`, `Trust/`, `Quality/`, scripts, and audit docs.
- Canonical owners touched: none in production source.
- Files created: `docs/audits/amb-1743-release-grade-frontend-qa-acceptance.md`
  and `docs/audits/amb-1743-release-grade-frontend-qa-acceptance.json`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: execution of the fast local lane, focused UI journeys,
  screenshot matrix, manual accessibility review, Dynamic Type review, Reduce
  Motion review, performance budget walkthrough, visual owner review, and device
  proof remains outside this packet.
- Next proof train: AMB-1744 and the smaller proof leaves AMB-1765 through
  AMB-1775 when testing/device proof is re-enabled.
- No equivalent folder/path interpretation was used.
