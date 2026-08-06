# Verification

## Exact automated, static, and build commands

Run from the repository root and record exit status plus launched, executed,
passed, failed, and skipped counts where the runner exposes them.

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/intelligence-quality-safety-evaluation --json
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 -m unittest discover -s tools/intelligence-evaluation/tests -p 'test_*.py'
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-INTELLIGENCE-EVAL --test AmbitionsTests/IntelligenceEvaluationModelsTests --test AmbitionsTests/IntelligenceEvaluationRegistryTests --test AmbitionsTests/IntelligenceEvaluationRunnerTests --test AmbitionsTests/IntelligenceEvaluationInvariantEvaluatorTests --test AmbitionsTests/IntelligenceEvaluationVerdictEngineTests --test AmbitionsTests/IntelligenceEvaluationInvalidationTests --test AmbitionsTests/IntelligenceEvaluationStoreTests --test AmbitionsTests/IntelligenceEvaluationDeletionTests --test AmbitionsTests/IntelligenceEvaluationPrivacyTests --test AmbitionsTests/FutureAstronautPivotEvaluationTests --test AmbitionsTests/IntelligenceEvaluationInspectionTests --test AmbitionsTests/IntelligenceEvaluationAccessibilityTests
make test-local BATCH=PDL-INTELLIGENCE-EVAL-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
make xcode-build-for-testing BATCH=PDL-INTELLIGENCE-EVAL
git diff --check
```

Run strict SwiftLint against every changed Swift file with the same pinned
container and arguments used by `.github/workflows/code-quality.yml`:

```bash
INTELLIGENCE_EVAL_BASE="$(git merge-base HEAD origin/main)"
git diff --name-only -z "$INTELLIGENCE_EVAL_BASE" HEAD -- '*.swift' > /tmp/ambitions-intelligence-eval-swift-files
xargs -0 docker run --rm -v "$PWD:/repo" -w /repo ghcr.io/realm/swiftlint:latest swiftlint lint --strict --reporter github-actions-logging < /tmp/ambitions-intelligence-eval-swift-files
```

Run the complete `Code Quality` workflow on the published branch; do not modify
or weaken the workflow for this initiative.

## Automated contract evidence

- Stable identity, schema round-trip, duplicate rejection, explicit dependency
  applicability, legal state transitions, and exact claim ceilings.
- Separate contract, source, privacy/security, model, runtime/device, expert,
  accessibility, and direct-user evidence; API/static proof that no universal
  score exists.
- One failing case for every hard invariant in `REQ-005`, including prohibited
  private egress, unauthorized mutation/effect, unsupported/currentness claims,
  validation bypass, hidden post-delete influence, severe unjustified denial,
  missing fallback, and invalidated-evidence reuse.
- Citation entailment versus decorative, stale, conflicting, rights-ineligible,
  wrong-jurisdiction, invented, and unsupported-detail citations.
- Empty, skipped, partial, canceled, unavailable, disputed, and missing-method
  cases yield no optimistic pass.
- Versioned and calibrated model-evaluator evidence; self-judging and sole-judge
  protected-claim cases fail or remain insufficient.
- Deterministic clock/seed/order/report bytes, idempotent append, bounded
  concurrency, immutable rerun lineage, and exact dependency invalidation.

## Runtime and integration evidence

- Execute `EVAL-FUTURE-ASTRONAUT-PIVOT-001` against isolated in-memory owners and
  committed synthetic/licensed fixtures.
- Prove recommendation -> provisional Goal -> grounded path -> contextual
  schedule -> explicit correction -> localized resimulation -> option-preserving
  pivot without accepting a proposal, mutating the live store, or claiming
  deterministic success prediction.
- Exercise stale/conflicting source, offline, model unavailable/refusal/context
  limit/invalid output, permission denial, provider outage, private canary,
  delete/reset, and indeterminate external-operation variants.
- Inspect the result through the development Trust surface and CLI report. The
  same run identity, dependency hash, evidence types, limitations, and verdict
  must appear in both without private payload leakage.
- Record production corpus, real model, production external provider,
  direct-user usefulness, release, deployment, and App Store evidence as N/A or
  insufficient for the foundation—not pass.

## Privacy, security, deletion, and recovery evidence

- Seed unique canaries in Goal/context/source annotation/evaluator inputs and
  assert zero occurrence in remote requests, logs, CLI/report output,
  diagnostics, crash material, screenshots, filenames, caches, embeddings,
  shared fixtures, and model-judge payloads.
- Verify strongest supported file protection, no ordinary sync/backup/export,
  protected-data unavailable behavior, disk-full atomicity, index corruption
  rebuild, unsupported-schema quarantine, and no canonical-store writes.
- Interrupt deletion after each phase and prove it resumes until inputs,
  outputs, caches, embeddings, screenshots, owned logs, and indices are gone;
  dependent verdicts invalidate immediately and history retains only
  non-recoverable descriptors/receipts.
- Run prompt/tool injection, poisoned/stale source, citation swap,
  schema-valid semantic attack, evaluator collusion, reidentification,
  counterfactual discrimination, orphaned influence, and blind-retry cases.

## Accessibility and rendered evidence

- Automated semantic tests cover VoiceOver labels/values/traits/headings,
  reading and focus order, actions, redundant state meaning, localization keys,
  and complete typed fallback copy.
- Render empty, ready, running, partial, awaiting-adjudication, disputed, pass,
  needs-revision, insufficient, invalidated, superseded, deleted, long-copy, and
  dense states in light/dark and every supported Dynamic Type class with reduced
  motion variants.
- Execute the inspection flow on a supported simulator with accessibility
  inspection plus keyboard, switch, and voice-control focus evidence.
- Execute on at least one supported physical iPhone: protected-data transition,
  launch/run/cancel/rerun, inspection reading order, largest Dynamic Type,
  reduced motion, delete interruption/resume, and relaunch. Record device, OS,
  build SHA, commands, screenshots/recording paths, and results. Simulator proof
  is not physical-device proof.

## Persistence and migration evidence

- Fresh v1 store creation and schema-ledger registration are required.
- Migration of pre-existing intelligence-evaluation data is N/A because no such
  store exists. Do not manufacture a legacy migration.
- Prove unsupported future schema failure, atomic initialization rollback,
  backup/export exclusion, deterministic index rebuild, and compatibility with
  the existing backup/dry-run/repair ownership for a future migration.

## Performance evidence

Measure small, launch-floor, and stress partitions on simulator and a supported
physical device. Record suite/case/dependency/evidence counts, artifact bytes,
peak memory, wall time, time to first visible progress, cancellation latency,
index rebuild, paged-inspection latency, and deletion duration. Establish
thresholds from the measured baseline before merge; no unmeasured number is a
release claim. Confirm bounded concurrency and that runner, report generation,
index rebuild, and deletion do not block the main actor.

## Final evidence and claim ceiling

The implementation is complete only when every `REQ-001` through `REQ-018` has
linked automated evidence and all applicable build, privacy/security,
accessibility, recovery, performance, simulator, and device lanes pass. The
verification record must preserve exact commands and results, dependency and
fixture hashes, findings and fixes, and remaining insufficient/N/A evidence.
Source, build, automated, rendered-simulator, physical-device, accessibility,
model, production-corpus, direct-user, merge, deployment, and release proof must
remain separately labeled.
