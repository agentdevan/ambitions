# Implementation Plan

## Outcome and boundary

Implement the approved claim-bound intelligence evaluation foundation. It will
run committed synthetic/licensed and private-local cases against immutable
dependency snapshots, preserve separate evidence and coverage, enforce hard
invariants, invalidate stale evidence, and project redacted readiness and
limitation information to existing Trust/owning surfaces. It will not calculate
a universal score, approve a release, mutate canonical product state, run a
production external effect, collect a private behavior corpus, or convert
missing evidence into pass.

The initial implementation proves the foundation with
`EVAL-FUTURE-ASTRONAUT-PIVOT-001`. Production-source coverage, a real model,
provider-production actions, direct-user usefulness, and release readiness must
remain `not_applicable` or `insufficient_evidence` until their independently
approved owners supply evidence.

## Affected components and exact files

### Canon and fixture contracts

- Add `docs/canon/specifications/systems/intelligence-evaluation.md`.
- Update `docs/canon/specifications/systems/private-life-runtime.md`,
  `docs/canon/specifications/systems/source-atlas.md`,
  `docs/canon/specifications/systems/privacy-and-data-classification.md`, and
  `docs/canon/specifications/global/trust-inspection.md` only for narrow
  ownership and traceability handoffs approved in Design.
- Add `tools/intelligence-evaluation/schema/intelligence-evaluation-suite-v1.schema.json`,
  `tools/intelligence-evaluation/fixtures/v1/future-astronaut-pivot/suite.json`,
  and the public/synthetic fixture records beneath that fixture directory.
- Add `tools/intelligence-evaluation/README.md` documenting claim ceilings,
  data classes, local execution, report format, and prohibited private inputs.

### Domain, execution, and persistence

- Add these files under
  `Native/Ambitions/Core/LocalRuntimeOS/IntelligenceEvaluation/`:
  `IntelligenceEvaluationIdentityModels.swift`,
  `IntelligenceEvaluationDependencyModels.swift`,
  `IntelligenceEvaluationEvidenceModels.swift`,
  `IntelligenceEvaluationVerdictModels.swift`,
  `IntelligenceEvaluationManifestLoader.swift`,
  `IntelligenceEvaluationRegistry.swift`,
  `IntelligenceEvaluationRunner.swift`,
  `IntelligenceEvaluationInvariantEvaluator.swift`,
  `IntelligenceEvaluationVerdictEngine.swift`,
  `IntelligenceEvaluationInvalidationPlanner.swift`,
  `IntelligenceEvaluationStoreSchema.swift`,
  `IntelligenceEvaluationStore.swift`, and
  `IntelligenceEvaluationDeletionService.swift`.
- Add
  `Native/Ambitions/Core/LocalRuntimeOS/Boundary/Clients/RuntimeIntelligenceEvaluationClient.swift`
  for read-only projections and a non-authoritative change-impact DTO.
- Update `Native/Ambitions/App/Bootstrap/RuntimeBootstrap.swift` only to compose
  the local repository, runner, and read client. The evaluation owner must not
  receive a canonical command client or production external credentials.

### Inspection, CLI, and reports

- Add `Native/Ambitions/Trust/IntelligenceEvaluationInspectionModels.swift`,
  `Native/Ambitions/Trust/IntelligenceEvaluationInspectionProjection.swift`,
  `Native/Ambitions/Trust/IntelligenceEvaluationInspectionView.swift`, and
  `Native/Ambitions/Trust/IntelligenceEvaluationInspectionAccessibility.swift`.
- Update `Native/Ambitions/Trust/InspectionSurface.swift` to expose the
  inspector in development/review configurations only; no new root or user
  quality dashboard is permitted.
- Add `tools/intelligence-evaluation/ambitions_intelligence_evaluation.py` and
  `tools/intelligence-evaluation/report.py` for schema validation, deterministic
  fixture enumeration, and machine-readable redacted reports. The Python tool
  must share golden schema fixtures with the Swift decoder.

### Exact focused test files

- `Native/AmbitionsTests/LocalRuntimeOS/IntelligenceEvaluation/IntelligenceEvaluationModelsTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/IntelligenceEvaluation/IntelligenceEvaluationRegistryTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/IntelligenceEvaluation/IntelligenceEvaluationRunnerTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/IntelligenceEvaluation/IntelligenceEvaluationInvariantEvaluatorTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/IntelligenceEvaluation/IntelligenceEvaluationVerdictEngineTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/IntelligenceEvaluation/IntelligenceEvaluationInvalidationTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/IntelligenceEvaluation/IntelligenceEvaluationStoreTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/IntelligenceEvaluation/IntelligenceEvaluationDeletionTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/IntelligenceEvaluation/IntelligenceEvaluationPrivacyTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/IntelligenceEvaluation/FutureAstronautPivotEvaluationTests.swift`
- `Native/AmbitionsTests/Trust/IntelligenceEvaluationInspectionTests.swift`
- `Native/AmbitionsTests/Quality/IntelligenceEvaluationAccessibilityTests.swift`
- `Native/AmbitionsUITests/IntelligenceEvaluationInspectionUITests.swift`
- `tools/intelligence-evaluation/tests/test_schema_and_reports.py`

The existing recursive source declarations in `project.yml` already include the
new Swift and test paths, so `project.yml` is expected to remain unchanged.
Regenerate `Ambitions.xcodeproj/project.pbxproj` with XcodeGen after adding each
task's files. Never edit generated project state by hand. If a future target or
resource—not a recursively included source file—requires a project definition
change, stop and reconcile that newly discovered need against this plan first.

## Interfaces and data flow

Committed manifests and typed fixtures enter the manifest loader, registry, and
dependency resolver. The actor-isolated runner captures an immutable snapshot,
runs declared methods with bounded concurrency, and appends idempotent evidence
batches. The invariant and verdict engines derive claim-specific results. The
store preserves immutable run lineage, adjudication, invalidation, and private
deletion receipts. Existing features receive only
`IntelligenceEvaluationEvidenceProjection`; change management later receives a
read-only impact set. Neither interface exposes a command or approval method.

Source-grounding cases read exact eligible Source Atlas claims. A future model
adapter conforms to the evaluation-method interface and supplies explicit
model/prompt/guardrail bindings. Until then, model cases remain insufficient.
External-effect cases use the existing non-production state-machine test double
only.

## Persistence, migration, concurrency, and recovery

Repository fixtures are public licensed or synthetic. Private-local artifacts
use a separate protected evaluation directory under the active runtime
generation, excluded from ordinary sync, backup, and export. The v1 store owns
an append-only record log, content-addressed local artifacts, rebuildable
indices, a schema ledger, and deletion tombstones. It must not duplicate or
write canonical Goals, Time, Capabilities, Proof, or source truth.

This is a fresh additive schema; migration from prior evaluation data is N/A.
Fresh-store creation, unsupported-schema rejection, atomic append, disk-full
recovery, index rebuild, deletion resume, and future migration/repair handoff
are mandatory. Runs snapshot dependencies, use an injected clock and seed for
deterministic methods, canonicalize evidence order, and create new IDs on rerun.
Captured model/human evidence is versioned but not misrepresented as replayable.

## Rollout and implementation order

Land canon/schema/fixture contracts first, then models and registry, store and
recovery, runner/evaluators/verdict, invalidation/read projection, inspection,
CLI/reporting, and the end-to-end fixture. Keep the inspection route
development/review-only until user-facing owning initiatives consume narrow
evidence projections. Keep production corpora, remote/private model calls,
production external actions, and direct-user claims disabled.

No workflow change or new process gate is planned. The implementation must run
the repository's unchanged required Code Quality workflow.
Every proof report must distinguish source, build, automated, simulator,
physical-device, accessibility, privacy/security, model, production-source,
direct-user, and release evidence.

## Grooming review and approval

Review verdict: **PASS**. The plan, tasks, and verification contract were
reviewed together against the approved Design. The review reconciled the
existing recursive XcodeGen source boundary, corrected the full-test lane,
verified exact expected source/test/canon/tool paths, mapped every requirement
to owning tasks, and covered schema, persistence, recovery, concurrency,
privacy/security, accessibility, performance, simulator, physical-device,
build, and claim-ceiling evidence. No unresolved implementation fork remains.

Devan delegated approval authority for this documentation program. The
implementation grooming set was approved under that authority on 2026-08-04.
Approval makes the initiative implementation-ready as documentation; it does
not claim that its source, canon, tests, migration, runtime, device evidence,
merge, deployment, or release work has occurred.
