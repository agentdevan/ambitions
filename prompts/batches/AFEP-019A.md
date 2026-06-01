<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-019A - CloudKit Foundation & Continuity Infrastructure

Linear issue context: AMB-413 / AFEP-019 remains blocked until this foundation and later approval gates are Green.

## Mission

Set up CloudKit continuity foundations for Ambitions without implementing production sync of user objects.

## Product Law

Ambitions is local-first. The local Private Life Runtime remains authoritative. CloudKit is optional Apple-native continuity only, never the source of truth. Do not add a custom backend. Do not make planner/runtime behavior depend on network or iCloud availability.

## Source Truth And Gate Inputs

Read and obey:

- `docs/truth/*`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`
- `docs/architecture/APPLE_NATIVE_SYNC_CLOUDKIT_READINESS_GATE.md`
- `docs/audits/pfc10-cloudkit-schema-zone-conflict-model-report.md`
- `docs/audits/pfc11-sync-implementation-conflict-tests-deferral-report.md`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift`
- `Native/Ambitions/Support/Ambitions.entitlements`
- the app privacy manifest

Current key fact: the app is local-only and AFEP-019 production sync is not approved. This batch may only add a disabled/testable foundation.

## Allowed Scope

Inspect and, where safe, update:

- Xcode project/workspace source truth (`project.yml`, not generated project files)
- app entitlements source
- app identifier/container configuration assumptions
- SwiftData/local persistence and sync capability owner
- privacy manifest
- diagnostics/proof scripts if already present and relevant
- existing CloudKit gate docs

Add CloudKit foundation only:

- iCloud/CloudKit entitlement configuration only if safe and source-controlled through existing entitlement/project structure
- CloudKit container constants/configuration layer
- account availability/status service
- CloudKit diagnostics service/model that can be consumed later by an approved owner
- sync capability feature flag such as `cloudKitContinuityEnabled`, default `false`
- local-only fallback path
- authority model documenting local device as source of truth
- conflict model scaffolding/types only
- rollback-to-local-only proof
- privacy manifest review/update if needed
- test harnesses proving disabled/offline/account-unavailable behavior

Prefer existing canonical owners:

- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift`
- `Native/Ambitions/Support/Ambitions.entitlements`
- the app privacy manifest
- existing diagnostics model owners only if a minimal internal diagnostics object already exists

## Strictly Forbidden

- Do not implement production synchronization of goals, steps, proofs, runtime snapshots, user profile, captures, closures, receipts, preferences, or private life data.
- Do not write CloudKit records containing real user data.
- Do not turn sync on by default.
- Do not create a custom hosted backend.
- Do not remove or weaken local-first behavior.
- Do not silently migrate local data into cloud.
- Do not make planner/runtime behavior depend on network or iCloud availability.
- Do not add external/cloud LLM, analytics, telemetry, hosted CI, signing/upload automation, or a paid service dependency.
- Do not modify completed AFRI issues except by adding new proof references.
- Do not mark AFEP-019 complete.
- Do not claim device/iCloud, TestFlight, App Store, privacy/legal, performance, CI, presentation-layer, or production sync proof.

## Implementation Requirements

- Add a feature flag such as `cloudKitContinuityEnabled`, default `false`.
- Add a safe CloudKit account probe abstraction that can report:
  - `available`
  - `noAccount`
  - `restricted`
  - `temporarilyUnavailable`
  - `unknown`
- Keep all new code testable without real iCloud login.
- Mock CloudKit/account states in tests.
- Keep simulator and CI safe.
- Add compile-safe abstractions so future AFEP-019 can plug in record sync only after later gates are approved.
- Add diagnostics service/model output that reports local-only/offline/account-unavailable safely without writing user data to CloudKit.
- Do not add presentation-layer code or navigation.
- Add conflict model scaffolding/types only; no record sync engine.
- Preserve `LocalOnlySyncCapability` as the default runtime path.
- Preserve local device as source of truth in names, docs, and test expectations.
- Future sync scaffolding must preserve SourceRecord, Receipt, ReplayTrace, and What Ambitions Knows inspection boundaries; do not implement those object sync paths in this batch.

## Required Proof Artifacts

Create:

- `docs/audits/afep019a-cloudkit-foundation-report.md`
- `docs/audits/afep019a-cloudkit-gate-checklist.md`
- `docs/audits/afep019a-local-only-fallback-proof.md`
- `docs/audits/afep019a-conflict-model-scaffold.md`

Each artifact must separate verified, not passed, not verified, blocked, and human/device follow-up.

## Acceptance Gates

Green only if:

- Project builds/tests pass, or any failure is pre-existing and documented with current evidence.
- CloudKit foundation exists behind an OFF feature flag.
- Local-only operation remains fully valid.
- Account unavailable/offline paths are safe.
- No production object sync is implemented.
- No user data is written to CloudKit.
- Rollback to local-only is documented and tested.
- AFEP-019 remains blocked until this foundation plus later approval gates are Green.

Yellow is acceptable only for a narrow, documented pre-existing validation blocker or an explicitly unavailable device/iCloud proof path, with no production sync claim.

Red stop conditions:

- Silent migration of local data to cloud.
- Any real user object CloudKit write path.
- Sync enabled by default.
- Planner/runtime dependency on network or iCloud.
- Custom hosted backend, analytics, telemetry, cloud AI, signing/upload automation, or paid service dependency.
- Privacy manifest dishonesty.
- Broad source rewrite outside the canonical sync/persistence owner.

## Validation

Run the strongest available repo validation commands. At minimum inspect and use repo wrappers where available:

- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-019A`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-019A --prompt prompts/batches/AFEP-019A.md --batch-type source-changing`
- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AFEP-019A`
- focused `make xcode-focused-test` lanes for changed test classes, including `AmbitionsTests/SyncCapabilityTests`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-019A --prompt prompts/batches/AFEP-019A.md --changed-from <BASE_SHA> --batch-type source-changing`
- `git diff --check`
- `git diff --cached --check` before commit
- grep checks proving no production object sync was added and no CloudKit writes of user data exist

If `swift test` is not applicable to the iOS app target, say so. If a wrapper reports a pass without executing tests, rerun with fully qualified XCTest identifiers and record the boundary.

## Closeout Required

Produce:

- GREEN / YELLOW / RED
- Changed files
- Validation commands and results
- Proof artifacts
- What AFEP-019 can do next
- What remains blocked
- Rollback: exact steps to disable CloudKit foundation and return to local-only operation

Commit only if validations are Green or Yellow with documented pre-existing failures. Do not commit Red implementation.
