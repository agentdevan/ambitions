<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`PK15-FINALIZE-01`

# Objective

Finalize the existing PK15 Receipt Backend attempt without rerunning Spark or restarting PK15.

Current evidence shows PK15 stopped Yellow after Spark with bounded uncommitted persistence/test work:

- `.codex/runs/PK15/20260510T151222Z/final-summary.md`
- `.codex/runs/PK15/20260510T151222Z/final/01-plan.final.md`
- `.codex/runs/PK15/20260510T151222Z/final/02-spark-bounded-patch.final.md`

# Required Behavior

- Inspect the current PK15 diff and the PK15 run artifacts above.
- Do not rerun the PK15 implementation prompt.
- Do not rerun Spark.
- Do not invoke the global train.
- Do not invoke nested `make batch`.
- Do not run concurrent `xcodebuild`.
- Classify the noted full-suite failure:
  `ExternalSurfaceVerificationChecklistTests.testM04ExistingProjectionsCarryStalePrivateAndFallbackBehavior`.
- Commit only if the PK15-owned patch is safe and validation is Green or accepted Yellow with owner, reason, no-claim boundary, retirement condition, resume path, and proof path.
- Stop Red if the existing diff is unsafe, out of scope, or cannot be validated without forbidden cleanup.

# Allowed Scope

- Existing PK15 diff only:
  - `Native/Ambitions/Persistence/PersistenceContracts.swift`
  - `Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift`
  - `Native/Ambitions/Persistence/SwiftDataModels.swift`
  - `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
  - `Native/Ambitions/Persistence/SwiftDataStore.swift`
  - `Native/AmbitionsTests/Persistence/ActionReceiptHistoryRepositoryTests.swift`
- PK15 closeout/status docs only if evidence supports Green or accepted Yellow.

# Forbidden Scope

- No app UI/source outside the existing PK15 diff.
- No `project.yml`, `Package.swift`, entitlement, signing, hosted CI, dependency, backend, telemetry, analytics, account, sync, cloud, TestFlight, or App Store changes.
- No docs/truth edits.
- No broad cleanup.
- No release, accessibility, privacy, performance, physical-device, TestFlight, App Store, legal, or global-train-completion claims.

# Required Checks

```bash
git status --short --branch
pgrep -fl 'ambitions-codex-train|codex exec|xcodebuild' || true
git diff --check
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/ActionReceiptHistoryRepositoryTests test
scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Persistence/PersistenceContracts.swift Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift Native/Ambitions/Persistence/SwiftDataModels.swift Native/Ambitions/Persistence/SwiftDataRepositories.swift Native/Ambitions/Persistence/SwiftDataStore.swift Native/AmbitionsTests/Persistence/ActionReceiptHistoryRepositoryTests.swift
```

Run broader tests only if needed to classify whether the existing PK15 diff caused the known unrelated failure. Run validation sequentially.

# Final Status

End with one of:

```text
STATUS: GREEN
STATUS: YELLOW
STATUS: RED
```
