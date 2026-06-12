# PLOS Validation Registry

Status: Active PLOS M00 governance registry
Issue: AMB-645 / PLOS-009
Parent: AMB-608 / PLOS-M00
Authority posture: Supporting validation registry subordinate to `docs/truth/*`, `docs/codex-os/*`, and live source evidence
Runtime implementation proof: none

`PLOS_VALIDATION` is the local registry for commands that may support PLOS Green, Yellow, or Red reporting. It records known repo commands and explicitly marks unknown or phase-specific commands as unknown instead of inventing proof.

## Registry Rules

- Do not invent commands to satisfy an issue.
- Do not treat a listed command as proof unless it was run for the current issue or current pushed commit.
- Record command, exit code, artifact/log path, scope, and non-claims in the issue report.
- Mark unavailable, unselected, or phase-specific commands as unknown and assign an owning phase.
- Treat local simulator evidence as local proof only.
- Treat human/device/legal/release proof as unavailable unless current artifacts prove it.
- Keep validation separate from release readiness.

## Known Structural Commands

| Lane | Command | Current status | Owner / follow-up | Green boundary |
|---|---|---|---|---|
| PLOS readiness | `python3 scripts/codex/plos-readiness-validate.py` | Known structural validator | M00 | Proves PLOS readiness artifacts are present, AMB-bound, and internally consistent. |
| PLOS readiness self-test | `python3 scripts/codex/plos-readiness-validate.py --self-test` | Known self-test | M00 | Proves validator rejects synthetic PLOS identifiers and accepts valid in-memory shape. |
| Program preflight | `scripts/codex/program-preflight.sh plos` | Known structural gate | M00+ | Proves required program files exist and forbidden dirty source/project paths are absent at run time. |
| Program phase gate | `scripts/codex/program-phase-gate.sh plos <phase>` | Known structural gate | M00+ | Proves the requested phase is declared and PLOS readiness validator passes for that phase. |
| PLOS closeout | `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child <file>` | Known closeout validator | M00+ | Proves required closeout fields exist and forbidden PLOS overclaims/identifier drift are absent. |
| Proof index | `bash scripts/codex/program-proof-index.sh plos` | Known ledger indexer | M00+ | Produces a bounded proof index from the proof ledger. |
| Source Atlas readiness | `python3 scripts/codex/source-atlas-readiness-validate.py` | Known structural validator | SAF / PLOS M04-M06 | Proves Source Atlas readiness artifacts carry required control phrases; not runtime implementation proof. |

## Build And Test Commands

| Lane | Command | Current status | Owner / follow-up | Green boundary |
|---|---|---|---|---|
| Local build | `./scripts/build-local.sh` | Known existing command, not run by AMB-645 | M01 when runtime truth map starts source proof; M26 for full certification | Green only for the exact current run and commit when logs pass. |
| Xcode build for testing | `scripts/ambitions-xcode-build-for-testing.sh` | Known existing command, not run by AMB-645 | Source-changing PLOS phase that needs compile proof | Green only when current logs prove the targeted scheme/target. |
| Focused Xcode test | `scripts/ambitions-xcode-test-focused.sh` | Known existing wrapper, selector is phase-specific unknown | Source-changing PLOS phase that owns the behavior | Green only when selected tests execute and pass; zero-test output is not Green. |
| Test plan | `scripts/ambitions-xcode-test-plan.sh` | Known existing wrapper, plan selection is phase-specific unknown | M01 source map and source-changing phases | Green only when the current issue names and runs the relevant plan. |
| Swift format/lint | Unknown installed command | Unknown | M01 source map or M26 certification | Do not invent; if SwiftFormat or SwiftLint is installed later, record exact command and version. |

## Source Atlas Validation

| Lane | Command | Current status | Owner / follow-up | Green boundary |
|---|---|---|---|---|
| Source Atlas readiness | `python3 scripts/codex/source-atlas-readiness-validate.py` | Known structural validator | SAF / PLOS M04-M06 | Structural readiness only. |
| Source pack validation | `scripts/sa-pack-validate.sh` | Known existing script, pack input is phase-specific unknown | PLOS M04-M06 | Green only with concrete pack path, source binding, freshness, revocation, release receipt, and rollback proof. |
| Source pack schema | `scripts/sa-pack-schema-validate.sh` | Known existing script, schema input is phase-specific unknown | PLOS M05 | Green only for the exact schema/pack path validated. |
| Coverage validation | `tools/source-atlas/coverage-validate.py` | Known existing tool, invocation is phase-specific unknown | PLOS M05-M07 | Green only for current source coverage input and current output artifact. |

## Screenshot And Visual Proof

| Lane | Command | Current status | Owner / follow-up | Green boundary |
|---|---|---|---|---|
| Screenshot proof | Unknown PLOS-specific screenshot matrix | Unknown | UI-bearing phases, then M26 certification | Do not invent; use existing UIQL screenshot conventions or active issue commands when provided. |
| Simulator screenshot helpers | `scripts/sim/simctl_screenshot.sh` and `scripts/sim/simctl_screenshot_smoke.sh` | Known helpers, not PLOS proof by themselves | UI-bearing phases | Captures are Yellow until visually evaluated and tied to issue report. |
| Visual proof validation | `scripts/ambitions_validate_visual_proof.py` | Known existing script, invocation is phase-specific unknown | UI-bearing phases | Green only for current manifest/report and visual evaluation. |

## Accessibility Proof

| Lane | Command | Current status | Owner / follow-up | Green boundary |
|---|---|---|---|---|
| Accessibility contract | `scripts/ambitions-accessibility-contract-check.py` | Known existing script, invocation is phase-specific unknown | UI-bearing phases | Structural/accessibility-contract proof only for current run. |
| Accessibility gates | `python3 scripts/ambitions_validate_accessibility_gates.py` | Known existing script, invocation is phase-specific unknown | UI-bearing phases | Green only for current scope; not public accessibility certification. |
| Cognitive load scan | `scripts/eb-accessibility-cognitive-load-scan.sh` or `scripts/accessibility-cognitive-load-scan.sh` | Known existing scripts, target set is phase-specific unknown | UI-bearing phases | Scan proof only; must not replace visual/accessibility behavior review. |
| VoiceOver traversal | Unknown automated PLOS command | Unknown | M26 certification or specific UI phase | Do not invent; manual or tool proof must be recorded when available. |

## Performance Proof

| Lane | Command | Current status | Owner / follow-up | Green boundary |
|---|---|---|---|---|
| Performance budget scan | `scripts/ambitions-performance-budget-check.py` | Known existing script, invocation is phase-specific unknown | Performance-bearing phases and M19 | Green only for current surface/runtime budget and current logs. |
| CQS performance scan | `scripts/cqs-performance-budget-scan.sh` | Known existing script, target set is phase-specific unknown | M19 | Scan proof only for current target set. |
| Xcode benchmark | `scripts/ambitions-xcode-benchmark.sh` | Known existing command, benchmark target is phase-specific unknown | M19 and M26 | Green only for current benchmark logs and accepted budget. |

## Privacy / Source / Safety Proof

| Lane | Command | Current status | Owner / follow-up | Green boundary |
|---|---|---|---|---|
| Privacy boundary scan | `scripts/privacy-boundary-scan.sh` | Known existing script, target set is phase-specific unknown | Data/privacy phases | Scan proof only for current paths. |
| EB privacy boundary scan | `scripts/eb-privacy-boundary-scan.sh` | Known existing script, target set is phase-specific unknown | Data/privacy phases | Scan proof only for current paths. |
| Trust/privacy validation | `python3 scripts/ambitions_validate_trust_privacy.py` | Known existing script, invocation is phase-specific unknown | Data/privacy phases | Green only for current inputs and output. |
| Runtime authority validation | `python3 scripts/ambitions_validate_runtime_authority.py` | Known existing script, invocation is phase-specific unknown | M01+ source/runtime phases | Green only for current source map and changed scope. |
| Source proof receipt coverage | `python3 scripts/ambitions-source-proof-receipt-coverage-check.py` | Known existing script, invocation is phase-specific unknown | Source/proof phases | Green only for current source/proof report. |
| High-risk safety proof | Unknown PLOS-specific command | Unknown | M18 and high-risk child issues | Do not invent; use active issue source, tests, reviewers, and reports when specified. |

## R2 / CloudKit / Sharing Proof

| Lane | Command | Current status | Owner / follow-up | Green boundary |
|---|---|---|---|---|
| R2 compatibility proof | Unknown PLOS-specific command | Unknown | PLOS M04 and M26 | Do not invent; must prove public-reference-only objects and no private user data before Green. |
| CloudKit sync proof | Unknown PLOS-specific command | Unknown | PLOS M23 and M26 | Do not invent; must prove user-owned iCloud/CloudKit behavior before sync Green. |
| Sharing visual proof | Unknown PLOS-specific command | Unknown | PLOS M20 and M26 | Do not invent; must prove local preview, redaction, visual state, and no social-pressure drift. |

## Unknown Command Handling

When a lane is unknown:

- write `Unknown` in this registry and the issue report
- name the owning phase, usually M01 for source mapping or M26 for full certification
- avoid a Green claim that depends on the unknown proof
- use Yellow only if the scoped issue is otherwise complete and the gap is safe, owned, and not user-facing
- use Red if the unknown proof is required for the current user-facing or runtime claim

## Non-Claims

AMB-645 does not run build, app tests, screenshots, accessibility traversal, performance benchmarks, CloudKit sync, R2 compatibility, sharing visual proof, high-risk domain proof, or full certification gauntlets. It installs the registry that future phases must use.
