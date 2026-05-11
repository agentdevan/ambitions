<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`LDI17`

# Runner Command

```bash
make batch BATCH=LDI17 PROMPT=prompts/batches/LDI17.md
```

# Operating Mode

Run through the Ambitions runner only: GPT-5.5 plan -> GPT-5.3-Codex-Spark bounded patch -> GPT-5.5 review/repair/final commit eligibility.

# Queue Status

- Title: Continuity Sync
- Queue position: 70
- Train: LDI
- Classification: executable_later
- Execution posture: Runner-executable only when dependency gates pass.
- Dependency gate: Relevant PK transaction/storage/side-effect/privacy proof plus Source Atlas SA07-SA32 where source/freshness or changed claims are used.
- Next handoff: LDI18

# Objective

Implement Continuity Sync in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.

# Active Source Truth To Inspect

- docs/truth/README.md
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/truth/RELEASE_TRUTH.md
- docs/truth/CODEX_PROCESS_TRUTH.md
- docs/truth/HISTORICAL_POLICY.md
- AGENTS.md
- .codex/state/active-batch.yml
- .codex/reports/current-batch-train-state.md
- docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
- docs/codex/AMB_REMAINING_BATCH_REFERENCE.json
- docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json

# Queue Rule

Preserve canonical ID `LDI17` and canonical queue order. Do not reactivate completed batches, renumber IDs, collapse PK17-PK41, pull RHC broad cleanup early, turn AIR into a standalone train, turn EFC into a broad implementation stream, or make DPTG terminal proof executable before all pre-device gates close.

# Allowed Scope

Only files named by the live batch prompt after source-truth inspection. Do not touch app source outside the owning seam. Do not touch Package.swift, project.yml, .github, signing, entitlements, generated Xcode projects, or unrelated train files.

# Forbidden Scope

- Native/AppUI/Sources outside owner seam, Package.swift, project.yml, .github, signing, entitlements, generated Xcode, release automation, hosted backend/LLM core.
- No top-level IA changes. Active IA remains `Today / Goals / Capture / Time / You`.
- No Plan top-level destination restoration.
- No external/cloud LLM core behavior.
- No hosted backend/account/user-data server behavior unless a future approved batch explicitly scopes it.
- No Package.swift, project.yml, generated Xcode project, .github workflow, signing, entitlement, or release automation mutation unless explicitly scoped by active truth.
- No release, TestFlight, App Store, device, public accessibility, performance, privacy/legal, hosted CI, production-readiness, or global-completion claim without current proof.

# Batch-Specific Implementation Instructions

Primary implementation action: Implement Continuity Sync in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.

Concrete instructions:
- Inspect the LDI train manifest, owning domain models, and existing Plan/Today/Goal service seams before implementing Continuity Sync.
- Fold AIR obligations only through the owning batch; do not create standalone AIR work or cloud intelligence.
- Require visible mutation permission, deterministic local behavior, rollback, and receipts whenever user plans or recommendations change.

Candidate owner files to inspect first:
- `docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md`
- `Native/Ambitions/Domain/Planning/**`
- `Native/Ambitions/Features/Plan/**`
- `Native/Ambitions/Services/AmbitionsCommandExecutor.swift`
- `Native/AmbitionsTests/*Planning*`

Required tests/proof for this batch:
- `git status --short`
- `git diff --check`
- `make prompt-audit`
- `make batch-self-check`
- `scripts/codex-forbidden-claim-scan.sh <changed files> 2>/dev/null || true`
- `xcodegen generate if source/project wiring requires it`
- `focused xcodebuild unit tests for touched owner seam`

# Validation

- `git status --short`
- `git diff --check`
- `make prompt-audit`
- `make batch-self-check`
- `scripts/codex-forbidden-claim-scan.sh <changed files> 2>/dev/null || true`
- `xcodegen generate if source/project wiring requires it`
- `focused xcodebuild unit tests for touched owner seam`

# Gates

- Source Atlas gate: not-applicable unless source/freshness claims are touched.
- AIR fold-in gate: fold-in only where owning batch touches intelligence/runtime obligations.
- EFC proof gate: invoked.
- FET/FVQ visual proof gate: not-applicable unless UI-facing source changes.
- RHC cleanup limit: not-applicable; do not pull RHC broad cleanup early.
- DPTG terminal rule: not-applicable; terminal proof remains later.

# Accepted Yellow Policy

Accepted Yellow is allowed only for exact environment/proof blockers or unrelated known-yellow failures that are documented with owner, no-claim boundary, and next proof path. It is not allowed for queue corruption, invalid JSON, completed-batch reactivation, production-file mutation outside scope, release overclaim, or unresolved hard preconditions.

# Hard Red Conditions

- Required source cannot be inspected.
- Dependency gate fails without an accepted-yellow owner.
- Completed batches are reactivated or canonical IDs/order change without authority.
- Scope touches forbidden app, package, project, workflow, signing, entitlement, release, or hosted-service files.
- The batch adds external/cloud LLM core behavior or hosted user-data behavior.
- The batch restores Plan as top-level IA or adds a sixth top-level destination.
- Validation root cause remains unknown after bounded repair.
- Claims are made without matching current proof.

# Rollback Expectations

Record changed files before patching. Revert only this batch's changes on failed repair. Preserve pre-existing user work, logs, and historical evidence. For do-not-run records, rollback is metadata-only unless a future approved runner pass widens scope.

# Final Report Requirements

Create or update `docs/audits/ldi17-batch-closeout-report.md` with status, source truth inspected, files changed, validation commands and exit codes, EFC applicability, accepted-yellow rationale if any, claims not made, rollback notes, and next handoff.

# Claims Not Made

Do not claim app release readiness, TestFlight readiness, App Store readiness, signed archive readiness, physical-device validation, public accessibility conformance, VoiceOver verification, Dynamic Type verification, Reduce Motion verification, performance validation, privacy/legal approval, hosted CI proof, production readiness, PK17 completion unless this is PK17 and proof exists, or global queue completion.
