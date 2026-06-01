<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-023 - Field-Level Privacy and Protected Storage Architecture

You are Codex operating in repo `agentdevan/ambitions`.

Create and run a gate-safe implementation batch for:

`AFEP-023 - Field-Level Privacy and Protected Storage Architecture`

Linear issue: `AMB-417`

## Mission

Define and validate field-level privacy, protected local storage, redaction, export, reset, and delete architecture for Ambitions without changing production storage behavior.

## Product Law

Ambitions is local-first. Local user-owned data remains authoritative. This batch must not add a custom backend, analytics, telemetry, hosted storage, hosted AI, or silent cloud migration. Privacy claims must match source artifacts and evidence boundaries.

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
- `project.yml`
- `Package.swift`
- the app privacy manifest file
- existing privacy, storage, export/delete, redaction, user inspection, and release-boundary code/tests/docs
- existing guard reports and concept-lock docs relevant to storage, export, delete, reset, and evidence boundaries

## Scope Allowed

Gate-safe support/report scaffold only:

- Add a support/report model such as `Native/Ambitions/Support/ReleasePrivacyProtectedStorageReport.swift`.
- Add focused tests such as `Native/AmbitionsTests/App/ReleasePrivacyProtectedStorageReportTests.swift`.
- Add audit artifacts under `docs/audits/`.
- Add schema/value objects that describe field-level privacy, protected local storage classes, redaction/export/reset/delete policy, privacy manifest alignment, and rollback gates.
- Add validation packet fields that explicitly reference local input anchors, action-history anchors, continuation-history anchors, and user inspection policy without modifying those owners.
- Classify canonical surface/object field categories for Today, Goals, Capture, Time, You, continuity snapshots, schedule blocks, runtime snapshots, action history, evidence records, corrections, and user system profile fields.
- Validate that sensitive/private fields default to local-only or redacted export.
- Validate that reset/delete/export rules are explicit.
- Validate that App Group, Keychain, protected local file, SwiftData local store, and in-memory projection storage classes are distinguishable as architecture policy.
- Validate privacy manifest alignment against the current app manifest.
- Preserve rollback to conservative AFRI privacy defaults.

## Scope Forbidden

- Do not modify existing storage owner source directories.
- Do not modify existing domain model owner source directories.
- Do not modify existing service owner source directories.
- Do not modify existing runtime owner source directories.
- Do not modify widget, share-extension, or continuity runtime code.
- Do not implement production storage migration.
- Do not write user data to cloud.
- Do not add custom backend, analytics, telemetry, hosted monitoring, hosted storage, hosted AI, or network dependency.
- Do not weaken `PrivacyInfo.xcprivacy`.
- Do not claim legal/privacy approval.
- Do not claim release readiness, TestFlight readiness, App Store readiness, physical-device validation, or complete privacy certification.
- Do not mark AFEP-019 complete.

## Required Artifacts

Add audit artifacts:

- `docs/audits/afep023-field-level-privacy-matrix.md`
- `docs/audits/afep023-protected-storage-architecture-packet.md`
- `docs/audits/afep023-export-reset-delete-redaction-rules.md`
- `docs/audits/afep023-privacy-manifest-alignment-report.md`
- `docs/audits/afep023-rollback-plan.md`

## Required Tests

All new code must be testable without device-only storage, keychain access, App Group runtime availability, network, cloud login, or real user data.

Tests must prove:

- every listed field category has storage, export, reset/delete, continuity, local input-anchor, action-history, continuation-history, and user inspection policy;
- sensitive/private life fields are not externally projectable raw;
- privacy manifest alignment does not add tracking or collected data claims;
- protected storage policy remains local-first and simulator/CI safe;
- rollback to conservative privacy defaults is available;
- no public/legal/privacy/release approval claim is unlocked.

## Validation Commands

Run the strongest available repo validation commands for this scoped batch. Prefer:

- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-023`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-023 --prompt prompts/batches/AFEP-023.md --batch-type source-changing`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-023 --prompt prompts/batches/AFEP-023.md --changed-from <BASE_SHA> --batch-type source-changing`
- `python3 scripts/ambitions-performance-budget-check.py`
- `bash scripts/cqs-privacy-security-claim-scan.sh`
- focused `make xcode-focused-test BATCH=AFEP-023 TEST=AmbitionsTests/ReleasePrivacyProtectedStorageReportTests`
- `make xcode-build-for-testing BATCH=AFEP-023`
- `git diff --check`

## Acceptance Gates

Green only if:

- Cloud/backend/telemetry/analytics/storage dependencies remain absent.
- Privacy manifest alignment is reviewed and not weakened.
- Sensitive field policies have local-only/redacted defaults.
- Export/reset/delete policies are explicit.
- local input-anchor, action-history, continuation-history, and user inspection references are present in the architecture packet.
- Tests pass or any failure is pre-existing and documented with evidence.
- Guard post status is Green, or accepted Yellow is fully documented with owner, safety reason, no-claim boundary, and follow-up gate.

## Report Format

At the end, produce:

GREEN / YELLOW / RED

Changed files:
- ...

Validation:
- command -> result

Audit artifacts:
- ...

What AFEP can do next:
- ...

What remains blocked:
- ...

Rollback:
- exact steps to remove AFEP-023 and return to conservative local-only privacy defaults.

## Commit Behavior

Create a clean commit if validations are Green or Yellow-with-documented-preexisting-failures. Do not commit Red implementation.
