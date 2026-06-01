<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-024 - Evidence Packet Automation

You are Codex operating in repo `agentdevan/ambitions`.

Create and run a gate-safe implementation batch for:

`AFEP-024 - Evidence Packet Automation`

Linear issue: `AMB-418`

## Mission

Automate provenance-rich Ambitions evidence packets that combine validation command records, artifact paths, screenshots where available, accessibility proof boundaries, performance proof boundaries, privacy proof boundaries, replay/continuity references where available, and release non-claims without elevating local validation into release readiness.

## Product Law

Ambitions remains local-first and proof-honest. Evidence automation may organize and summarize repo-local proof, but it must not create release, accessibility, privacy/legal, performance, device, TestFlight, App Store, CI, or production-readiness claims unless those claims are directly proven by current artifacts and active truth files. Do not add hosted CI, backend, analytics, telemetry, signing/upload automation, or paid/external services.

## Required Repo Truth Inspection

Inspect current repo truth before editing:

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
- existing proof, audit, validation, release-boundary, claim-scan, benchmark, Xcode wrapper, and batch-runner scripts/docs
- recent AFEP evidence artifacts, especially AFEP-020 through AFEP-023

## Scope Allowed

Gate-safe local automation/support only:

- Add an evidence packet schema/model in an appropriate support or script-owned location.
- Add a repo-local generator or validator that creates a deterministic evidence packet from explicit inputs or current repo-local artifacts.
- Capture commit, branch, command, environment, artifact paths, pass/fail status, skipped checks, non-claims, blocked checks, and rollback notes.
- Include Green/Yellow/Red closeout fields.
- Include explicit proof-boundary sections separating local validation from release readiness.
- Link existing screenshot, accessibility, performance, privacy, replay/continuity, Xcode summary, and audit artifacts when present; represent missing artifacts as blocked/not verified, not as failure unless required by the packet inputs.
- Preserve existing runtime proof anchors by referencing `SourceRecord`, `Receipt`, `ReplayTrace`, and You / What Ambitions knows inspection only as evidence-packet provenance fields; do not modify those owners.
- Add a sample AFEP proof packet artifact under `docs/audits/` or another current proof/audit location.
- Add focused tests or validator fixtures that prove the schema preserves explicit non-claims and does not overclaim readiness.
- Preserve a manual AFRI proof-packet fallback path if automation is unavailable or unstable.

## Scope Forbidden

- Do not add hosted CI, GitHub Actions, external runners, cloud storage, backend, analytics, telemetry, signing, notarization, App Store upload, TestFlight upload, or paid/external service dependencies.
- Do not claim release readiness, accessibility conformance, privacy/legal approval, performance readiness, device validation, TestFlight readiness, App Store readiness, CI proof, or production readiness.
- Do not treat screenshots, local simulator logs, or local Xcode wrapper summaries as release proof.
- Do not modify production runtime behavior.
- Do not write user data to cloud.
- Do not weaken privacy manifest honesty.
- Do not replace existing manual proof paths with automation unless rollback/fallback remains explicit.
- Do not mark AFEP-019 complete.

## Required Artifacts

Add proof artifacts:

- `docs/audits/afep024-evidence-packet-automation-report.md`
- `docs/audits/afep024-sample-proof-packet.md`
- `docs/audits/afep024-claim-boundary-scan-report.md`
- `docs/audits/afep024-manual-proof-fallback.md`

## Required Tests

All new code must be testable without network, cloud login, device-only artifacts, real screenshots, signing credentials, hosted CI, or real user data.

Tests or validator checks must prove:

- packet schema records commit, branch, command, environment, artifact paths, pass/fail, skipped checks, blocked checks, and non-claims;
- release/readiness claims stay separated from local validation;
- missing optional artifacts become `notVerified` or equivalent, not false Green;
- Green/Yellow/Red fields are explicit and machine-readable;
- rollback/manual fallback remains available;
- no external service or hosted dependency is required.

## Validation Commands

Run the strongest available repo validation commands for this scoped batch. Prefer:

- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-024`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-024 --prompt prompts/batches/AFEP-024.md --batch-type source-changing`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-024 --prompt prompts/batches/AFEP-024.md --changed-from <BASE_SHA> --batch-type source-changing`
- focused unit or script tests for the new evidence packet automation
- `python3 scripts/ambitions-performance-budget-check.py`
- relevant claim-scan/release-proof scripts if present
- `make xcode-focused-test BATCH=AFEP-024 TEST=<focused-test-id>` if Swift test code is added
- `make xcode-build-for-testing BATCH=AFEP-024` if app/test source is touched
- `git diff --check`

## Acceptance Gates

Green only if:

- evidence packet automation exists and is deterministic/repo-local;
- packet fields include provenance, command records, artifacts, pass/fail/skipped/blocked checks, non-claims, and rollback;
- release/readiness claims remain separated from local validation;
- missing optional proof is reported honestly as not verified or blocked;
- manual proof fallback is documented;
- tests/validators pass or any failure is pre-existing and documented with evidence;
- guard post status is Green, or accepted Yellow is fully documented with owner, safety reason, no-claim boundary, and follow-up gate.

## Report Format

At the end, produce:

GREEN / YELLOW / RED

Changed files:
- ...

Validation:
- command -> result

Proof artifacts:
- ...

What AFEP can do next:
- ...

What remains blocked:
- ...

Rollback:
- exact steps to disable/remove AFEP-024 automation and return to manual AFRI proof packets.

## Commit Behavior

Create a clean commit if validations are Green or Yellow-with-documented-preexisting-failures. Do not commit Red implementation.
