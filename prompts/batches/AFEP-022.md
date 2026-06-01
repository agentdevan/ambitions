<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-022 - Performance and Energy Observatory

Issue: AMB-416
Project: Ambitions Flagship Elevation Program
Milestone: Trust and Evidence Operating System

## Mission

Create a reusable performance and energy observatory foundation for AFEP surfaces, local projection contracts, render paths, and fallback decisions without claiming release-grade performance, battery, thermal, memory, or device readiness.

## Product Law

Ambitions remains local-first and native iPhone-first. Local intelligence remains deterministic. Performance and energy observability must protect local-first operation, privacy, and user experience. Do not add analytics, telemetry SDKs, hosted monitoring, remote event collection, cloud AI, or a custom backend.

Performance claims are evidence-bound. Contract budgets, source scaffolds, and tests can support review, but they do not prove measured device performance, Instruments performance, battery impact, thermal safety, memory safety, release readiness, TestFlight readiness, or App Store readiness without current logs tied to command, commit, environment, and device or simulator context.

## Required Truth Read

Read before implementation:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `README.md`
10. `docs/README.md`
11. `project.yml`
12. `Package.swift`
13. Existing performance validation/source/test material, especially:
    - `AFRI-035 performance local observability baseline`
    - `docs/status/performance-budgets.md`
    - `Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift`
    - `Native/AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests.swift`

## Scope Allowed

Add an AFEP-022 performance and energy observatory foundation only:

- Signpost and metric plan types or source scaffold.
- Canonical surface observatory plans for Today, Goals, Capture, Time, and You.
- Query budget links to AFEP-004 local projection and repository budget contracts.
- Render, launch, scroll, background maintenance, memory, wakeup, and energy-impact budget scaffolding.
- Validation packet format that records command, commit, environment, device or simulator context, artifact path, metric kind, pass/fail/skipped state, known limitation, owner, and follow-up validation requirement.
- Degradation/fallback plan types that keep elevated visuals, expensive render paths, and background work optional or deferable before user experience degrades.
- Public/release performance claim locks that stay false unless current measured validation exists.
- Rollback path to AFRI-035 and existing performance-budget validation paths.
- Tests proving required surfaces, metric plans, budget links, fallback decisions, validation boundaries, and performance-claim locks exist.
- Audit artifacts:
  - `docs/audits/afep022-performance-energy-observatory-report.md`
  - `docs/audits/afep022-query-render-budget-report.md`
  - `docs/audits/afep022-degradation-fallback-report.md`
  - `docs/audits/afep022-performance-claim-boundary.md`
  - `docs/audits/afep022-rollback-plan.md`

## Source Boundary

Prefer extending the existing release-performance support owner instead of creating a parallel subsystem or changing deeper app-intelligence ownership:

- `Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift`
- `Native/AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests.swift`

If the runner or guard proves a different canonical owner is safer, document why in the final report.

## Strictly Forbidden

- Do not claim Ambitions is performant, battery efficient, memory safe, thermally safe, release ready, TestFlight ready, App Store ready, device verified, launch verified, scroll verified, or Instruments verified unless current validation is actually collected and documented.
- Do not add analytics, telemetry SDKs, crash reporters, hosted observability, remote event collection, cloud AI, external LLMs, or custom backend services.
- Do not write private life data, runtime snapshots, user profile data, or planner state to any remote performance system.
- Do not modify production planner behavior based on observatory metadata.
- Do not add continuous animation, expensive blur/glow/material effects, background work, polling, timers, network calls, or persistence writes.
- Do not silently alter user data, persistence schemas, sync, privacy manifest claims, or app identifiers.
- Do not add a new top-level destination.
- Do not reintroduce Plan as a top-level destination.
- Do not stage `.codex/runs`, `.xcresult`, local indexes, graph artifacts, generated visual-summary artifacts, generated benchmark outputs, or broad generated project churn.

## Validation Boundary Requirements

Every new performance/energy validation type must distinguish:

- contract budget
- source-backed review
- automated-test result
- command timing
- simulator measurement
- Instruments measurement
- physical-device measurement
- memory graph measurement
- battery or thermal sample
- human/device release approval
- public performance claim approval

Only source/test/contract support may be Green in this batch unless current measurement validation is actually collected. Simulator, Instruments, device, memory, battery, thermal, and release validation gaps must remain explicit and blocking for public claims.

Keep local-only observatory labels limited to `PerformanceBudget.afep022.performance-energy-observatory` and internal report metadata. These labels must not imply telemetry, hosted services, production monitoring, release-grade measurement, or user-facing performance claims.

## Validation

Run the strongest available repo validation commands for the touched scope. Prefer:

- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-022`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-022 --prompt prompts/batches/AFEP-022.md --batch-type source-changing`
- `xcodegen generate`
- `python3 scripts/ambitions-performance-budget-check.py`
- `bash scripts/cqs-performance-budget-scan.sh Native/Ambitions`
- `make xcode-build-for-testing BATCH=AFEP-022`
- `make xcode-focused-test BATCH=AFEP-022 TEST=AmbitionsTests/AmbitionsOSPerformanceEnergyModelsTests`
- `make xcode-focused-test BATCH=AFEP-022 TEST=AmbitionsTests/AFEP004QueryBudgetPrivacyPolicyTests`
- `git diff --check`
- Claim scans proving no positive release, device, battery, thermal, memory, Instruments, or performance-readiness claim was added.

If any validation is unavailable or fails for pre-existing reasons, document exact evidence and keep status Yellow at best.

## Acceptance Gates

Green only if:

- Performance and energy observatory scaffold exists behind explicit validation boundaries.
- Today, Goals, Capture, Time, and You are covered.
- Query, render, launch, scroll, background maintenance, memory, wakeup, and energy-impact budget dimensions are represented.
- AFEP-004 query budget contracts are referenced without changing production query behavior.
- Elevated visuals and expensive work have degrade/defer/fallback decisions before user experience degrades.
- Public/release performance claims remain locked.
- Simulator, Instruments, physical-device, memory, battery, thermal, and release validation requirements remain explicit.
- Existing AFRI-035 performance observability baseline remains a rollback baseline.
- Tests pass for the new scaffold.
- No user-facing performance, energy, battery, memory, device, TestFlight, App Store, or release readiness claim is made.

## Report Format

End with:

```text
GREEN / YELLOW / RED

Changed files:
- ...

Validation:
- command -> result

Validation artifacts:
- ...

What AFEP can do next:
- ...

What remains blocked:
- ...

Rollback:
- exact steps
```

## Commit Behavior

Create a clean commit if validations are Green or Yellow-with-documented-preexisting-failures. Do not commit Red implementation.
