<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-19490901, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`AOS28`

# Runner Command

```bash
make batch BATCH=AOS28 PROMPT=prompts/batches/AOS28.md
```

# Operating Mode

Run through the Ambitions runner only: GPT-5.5 plan -> GPT-5.3-Codex-Spark bounded patch -> GPT-5.5 review/repair/final commit eligibility.

# Queue Status

- Title: AmbitionsOS Experience Tail Gate
- Queue position: 80
- Train: AOS
- Classification: blocked_until_dependency
- Execution posture: Runner-executable only when dependency gates pass.
- Dependency gate: Complete source/freshness dependencies, PK intelligence/data-control gates, and owner-specific LDI proof where applicable.
- Next handoff: AOS29

# Objective

Implement AmbitionsOS Experience Tail Gate as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.

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

Preserve canonical ID `AOS28` and canonical queue order. Do not reactivate completed batches, renumber IDs, collapse PK17-PK41, pull RHC broad cleanup early, turn AIR into a standalone train, turn EFC into a broad implementation stream, or make DPTG terminal proof executable before all pre-device gates close.

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

Primary implementation action: Implement AmbitionsOS Experience Tail Gate as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.

Concrete instructions:
- Inspect the AOS train manifest, owning domain models, and existing Plan/Today/Goal service seams before implementing AmbitionsOS Experience Tail Gate.
- Fold AIR obligations only through the owning batch; do not create standalone AIR work or cloud intelligence.
- Require visible mutation permission, deterministic local behavior, rollback, and receipts whenever user plans or recommendations change.

Candidate owner files to inspect first:
- `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_PROMPT.md`
- `Native/Ambitions/Domain/AmbitionsOS*.swift`
- `Native/Ambitions/Runtime/**`
- `Native/Ambitions/Services/**`
- `Native/AmbitionsTests/*AmbitionsOS*`

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

Record changed files before patching. Revert only this batch's changes on needs review repair. Preserve pre-existing user work, logs, and historical evidence. For do-not-run records, rollback is metadata-only unless a future approved runner pass widens scope.

# Final Report Requirements

Create or update `docs/audits/aos28-batch-closeout-report.md` with status, source truth inspected, files changed, validation commands and exit codes, EFC applicability, accepted-yellow rationale if any, claims not made, rollback notes, and next handoff.

# Claims Not Made

Do not claim app release readiness, TestFlight readiness, App Store readiness, signed archive readiness, physical-device validation, public accessibility conformance, VoiceOver verification, Dynamic Type verification, Reduce Motion verification, performance validation, privacy/legal approval, hosted CI proof, production readiness, PK17 completion unless this is PK17 and proof exists, or global queue completion.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
