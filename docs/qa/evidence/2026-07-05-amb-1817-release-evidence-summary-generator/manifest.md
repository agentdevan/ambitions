# AMB-1817 Release Evidence Summary Generator

Status: Implemented Yellow / Ready For Review for this release-evidence generator leaf
Date: 2026-07-05T16:26:30Z
Branch: `main`
Baseline main SHA: `8957784455d63703bde57a93341eb75a25479227`
Commit SHA: artifact commit SHA is recorded in Linear after commit/push
Environment: local Codex macOS workspace at `/Users/devan/Documents/GitHub/ambitions`
Xcode version: Xcode 26.6, build version 17F113
Simulator or device: no simulator/device procedure is required or claimed for this generator packet
Exit code(s): listed in Validation Run below
Artifact paths: this manifest, `docs/qa/evidence/2026-07-05-amb-1817-release-evidence-summary-generator/generator-contract.json`, and `scripts/ambitions-release-evidence-summary.py`
Parent: `AMB-1696` Parent Feature - Release Evidence Packet Automation
Issue: `AMB-1817` Release Evidence Leaf - Build and test summary generator

## Scope

This leaf adds a deterministic release evidence summary generator:

```bash
scripts/ambitions-release-evidence-summary.py
```

The generator records repo metadata, supplied command records, skipped checks,
artifact paths, known risks, and non-claims into:

- `release-evidence-summary.md`
- `release-evidence-summary.json`

It does not run build, test, device, archive, upload, privacy/legal,
accessibility, or release procedures.

## Input Contract

Command records are supplied as repeated JSON objects:

```bash
--command-record '{"id":"static_gate","command":"git diff --check","exit_code":0,"artifact_path":"n/a","result":"passed"}'
```

Each command record must include:

- `id`
- `command`
- `exit_code`
- `artifact_path`
- `result`

Skipped-check records are supplied as repeated JSON objects:

```bash
--skipped-check '{"id":"xcodebuild_build","reason":"not run","proof_ceiling":"no build success claim"}'
```

Each skipped-check record must include:

- `id`
- `reason`
- `proof_ceiling`

The generator always adds default non-claims for Release Green, TestFlight
readiness, App Store readiness, device readiness, accessibility conformance,
and privacy/legal approval.

## Output Shape

Generated Markdown includes:

- status, generated timestamp, branch, commit SHA, environment, Xcode version,
  simulator/device field, and artifact paths;
- claim boundary;
- command result table;
- skipped-check / validation-not-run table;
- known risks;
- non-claims;
- rollback note.

Generated JSON includes:

- `issue`
- `title`
- `status`
- `generated_at`
- `branch`
- `commit_sha`
- `remote_main`
- `environment`
- `xcode_version`
- `simulator_or_device`
- `artifact_paths`
- `command_records`
- `skipped_checks`
- `known_risks`
- `non_claims`
- `claim_boundary`

## Validation Run

Completed for this generator packet:

| Command | Exit code | Result |
| --- | ---: | --- |
| `python3 -m py_compile scripts/ambitions-release-evidence-summary.py` | 0 | Passed after script creation. |
| `scripts/ambitions-release-evidence-summary.py --self-test` | 0 | Passed; verified generated JSON keys and default release non-claim. |
| `scripts/ambitions-release-evidence-summary.py --issue AMB-1817 --title "AMB-1817 Release Evidence Summary Dry Run" --status "Dry run only; no release readiness claim" --simulator-or-device "not used" --output-dir /tmp/ambitions-amb1817-release-evidence --command-record '{"id":"static_gate","command":"git diff --check","exit_code":0,"artifact_path":"n/a","result":"passed"}' --skipped-check '{"id":"xcodebuild_build","reason":"not run under current instruction","proof_ceiling":"no build success claim"}' --known-risk "dry-run output is temporary"` | 0 | Passed after script creation. |
| `python3 -m json.tool /tmp/ambitions-amb1817-release-evidence/release-evidence-summary.json` | 0 | Passed after dry run. |
| `git diff --check` | 0 | Passed after packet creation. |
| `python3 -m json.tool docs/qa/evidence/2026-07-05-amb-1817-release-evidence-summary-generator/generator-contract.json` | 0 | Passed after packet creation. |
| `python3 scripts/ambitions-release-non-claim-gate.py docs/qa/evidence/2026-07-05-amb-1817-release-evidence-summary-generator/manifest.md docs/qa/evidence/2026-07-05-amb-1817-release-evidence-summary-generator/generator-contract.json` | 0 | Passed; `release_facing_packets_checked=2`. |
| `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` | 0 | Passed; `checkedAcceptedYellowIssues=19`, `invalidAcceptedYellowIssues=0`. |
| `python3 scripts/ambitions-unsupported-claim-scan.py scripts/ambitions-release-evidence-summary.py docs/qa/evidence/2026-07-05-amb-1817-release-evidence-summary-generator/manifest.md docs/qa/evidence/2026-07-05-amb-1817-release-evidence-summary-generator/generator-contract.json` | 0 | Passed; unsupported completion/readiness claim scan reported Green. |
| `python3 scripts/ambitions-remediation-governance-check.py` | 0 | Passed; `changed_paths=3`, `production_swift_files=1421`, `overHardLineCapFiles=0`. |

## Validation Not Run

- XcodeGen, xcodebuild package resolution, xcodebuild build, xcodebuild test,
  build-for-testing, focused tests, test plans, UI screenshots, app launch,
  physical-device procedure, accessibility walkthrough, performance profiling,
  privacy/legal review, account/R2 production proof, archive, App Store
  validation, TestFlight upload, and release approval were not run for AMB-1817
  under the current user instruction authorizing issue completion without
  testing until advised otherwise.

## Non-Claims

- No Release Green.
- No TestFlight readiness.
- No App Store readiness.
- No build success, test success, build-for-testing success, archive success,
  app launch proof, screenshot proof, accessibility conformance, device proof,
  privacy/legal approval, account readiness, R2 readiness, Source Atlas
  production readiness, upload readiness, or product completion.
- The generator can summarize supplied records. It cannot make absent proof
  exist.
- `AMB-1696` remains In Progress because screenshot, accessibility, privacy,
  known-issues, migration, device, release notes, and Linear attachment
  automation remain outside this leaf.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: release/QA tooling only; no Swift source.
- Files moved or created: this manifest, a paired JSON contract, and
  `scripts/ambitions-release-evidence-summary.py`.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture/proof debt remains: yes. The generator records proof; it
  does not produce build/test/device/release proof by itself.
- Next repair train if debt remains: continue `AMB-1696` leaves for screenshot,
  accessibility, privacy, known-issues, migration, device, release notes, and
  Linear attachment automation.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.

## Rollback

Revert this evidence folder and `scripts/ambitions-release-evidence-summary.py`.
Move `AMB-1817` back to `Ready For Codex` or `Needs Repair` if the generator
does not preserve command records, skipped checks, artifact paths, and
non-claims.
