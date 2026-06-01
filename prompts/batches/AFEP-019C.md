<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-019C - Approved CloudKit Sync Implementation

You are Codex operating in repo `agentdevan/ambitions`.

Create and run a gate-safe implementation batch for:

`AFEP-019 - Local-First Sync Implementation`

Linear issue: `AMB-413`

## Batch ID

AFEP-019C

## Owner Approval

On 2026-06-01, the user explicitly approved production CloudKit sync setup for
AFEP-019 after AFEP-019A completed the local-only CloudKit foundation.

This approval authorizes CloudKit sync implementation work only inside the
local-first, Apple-native continuity boundary below. It does not authorize a
custom backend, default-on sync, hosted account infrastructure, analytics,
telemetry, release-readiness claims, device/iCloud proof claims without current
evidence, or planner/runtime dependence on network or iCloud availability.

## Product Law

Ambitions remains a premium native iPhone-first, local-first Personal Life OS.

Canonical IA is exactly:

`Today / Goals / Capture / Time / You`

The Private Life Runtime and local SwiftData store remain authoritative.
CloudKit is optional Apple-native continuity only. It is a replica and recovery
path, not planner truth, runtime truth, or a hidden source of truth.

Sync must be:

- user-controlled
- reversible
- disabled/off by default until explicit in-app/user enablement exists
- local-first under account unavailable, restricted, offline, and CloudKit
  failure states
- testable without real iCloud login
- implemented without a custom hosted backend

## Mandatory Source-Truth Inspection

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
- `docs/architecture/APPLE_NATIVE_SYNC_CLOUDKIT_READINESS_GATE.md`
- `docs/canon/Ambitions_CloudKit_Schema_Zone_Conflict_Model.md`
- `docs/audits/afep019a-cloudkit-foundation-report.md`
- `docs/audits/afep019a-cloudkit-gate-checklist.md`
- `docs/audits/afep019a-local-only-fallback-proof.md`
- `docs/audits/afep019a-conflict-model-scaffold.md`
- current entitlements, privacy manifest, SwiftData models, persistence
  contracts, export/import services, sync capability source, and sync tests

## Allowed Implementation Scope

Implement the smallest coherent production CloudKit sync foundation that can
ship behind OFF-by-default user-controlled enablement:

- CloudKit entitlement/container configuration when source-controlled and safe.
- CloudKit container/config constants.
- Real CloudKit account status probe mapping:
  - available
  - noAccount
  - restricted
  - temporarilyUnavailable
  - unknown
- Sync mode/feature flag preserving default OFF local-only behavior.
- CloudKit client abstractions that can use real CloudKit in app builds and
  fake/mocked stores in tests.
- Private custom-zone setup contract for `AmbitionsCoreZone`, idempotent in
  implementation.
- Record encoding/decoding for approved launch record families where local
  models are Codable and portable enough to support deterministic tests.
- Local outbox/change metadata types needed for future incremental sync.
- Conflict/tombstone scaffolding that prevents silent destructive overwrite.
- A sync coordinator/service that never blocks local writes and never makes the
  planner/runtime depend on iCloud/network availability.
- Local-only fallback path and rollback-to-local-only proof.
- Diagnostics object updates for disabled, account unavailable, restricted,
  temporarily unavailable, paused, needs review, and healthy-only-after-proof
  states.
- Unit tests using fake CloudKit/account states only; tests must not require
  iCloud login or write to a real CloudKit container.
- Proof artifacts:
  - `docs/audits/afep019-cloudkit-sync-implementation-report.md`
  - `docs/audits/afep019-sync-gate-checklist.md`
  - `docs/audits/afep019-conflict-replay-packet.md`
  - `docs/audits/afep019-privacy-local-only-fallback-report.md`
  - `docs/audits/afep019-rollback-to-local-only-proof.md`

## Required Implementation Boundaries

- Keep `cloudKitContinuityEnabled` or equivalent default `false`.
- Preserve SourceRecord, Receipt, and ReplayTrace continuity when modeling sync
  provenance, conflict review, replay, rollback, and user-visible explanation.
- Preserve You / What Ambitions Knows inspection requirements for any synced,
  staged, conflicted, tombstoned, or rollback-relevant record metadata.
- Do not silently migrate existing local data into CloudKit.
- Do not run sync unless the feature flag/user-controlled enablement is true,
  account status is compatible, and the sync coordinator is explicitly invoked.
- Do not write user data to CloudKit during tests.
- Do not add a custom backend or hosted account server.
- Do not add analytics, telemetry, crash SDK, hosted CI, signing automation,
  App Store upload automation, or paid/external service dependencies.
- Do not change canonical IA or reintroduce `Plan` as a user-facing top-level
  destination.
- Do not claim device/iCloud validation, privacy/legal approval, TestFlight,
  App Store, CI, accessibility, performance, or release readiness without
  current evidence.
- Do not make widgets, Live Activities, notifications, App Intents, logs,
  previews, or audit reports expose private synced content.

## Acceptance Gates

Green only if:

- Production CloudKit sync setup exists behind OFF-by-default optional
  enablement.
- Local SwiftData remains source of truth.
- Account unavailable/restricted/offline paths preserve local operation.
- Fake/mocked CloudKit tests pass without iCloud login.
- Real CloudKit writes are isolated behind explicit enablement/invocation.
- No custom backend exists.
- Conflict/tombstone scaffolding prevents silent destructive overwrite.
- Rollback to local-only is documented and test-covered.
- Privacy manifest/entitlement docs are honest.
- Validation passes, or any failure is pre-existing and documented with current
  evidence.

Yellow only if implementation is safely partial, disabled by default, and
clearly documents remaining gates without claiming production sync readiness.

Red if sync becomes default-on, makes CloudKit the source of truth, blocks local
operation, writes test user data to real CloudKit, adds a custom backend,
weakens local-first behavior, or makes unsupported release/privacy/device
claims.

## Validation

Run the strongest available scoped validation commands. Prefer:

- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-019C`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-019C --prompt prompts/batches/AFEP-019C.md --batch-type source-changing`
- `xcodegen generate` if project wiring changes
- focused sync/CloudKit tests
- `make xcode-build-for-testing BATCH=AFEP-019C`
- `make xcode-focused-test BATCH=AFEP-019C TEST=AmbitionsTests/SyncCapabilityTests`
- any new focused CloudKit sync tests
- grep checks proving no custom backend and no default-on sync
- privacy/release claim scans if available
- `python3 tools/mcp/ambitions_repo_mcp/server.py --self-test`
- `git diff --check`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-019C --prompt prompts/batches/AFEP-019C.md --changed-from <BASE_SHA> --batch-type source-changing`

## Rollback

Rollback must be exact:

- disable `cloudKitContinuityEnabled`/sync enablement to return to local-only;
- remove any CloudKit coordinator/client/service wiring added by AFEP-019C if
  a full source rollback is needed;
- remove iCloud/CloudKit entitlement keys if app signing/container rollout must
  be reversed;
- keep SwiftData local store intact and authoritative;
- keep export/import/local-only proof artifacts valid;
- rerun focused sync tests, grep checks, and `git diff --check`.

## Report Format

At the end, produce:

GREEN / YELLOW / RED

Changed files:
- ...

Validation:
- command -> result

Proof artifacts:
- ...

What AFEP-019 can do next:
- ...

What remains blocked:
- ...

Rollback:
- exact steps to disable CloudKit foundation/sync setup and return to
  local-only operation.

## Commit Behavior

Create a clean commit if validations are Green or Yellow with documented safe
partial implementation and pre-existing failures. Do not commit Red
implementation.
