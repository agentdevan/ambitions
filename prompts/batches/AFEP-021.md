<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-021 — Accessibility Certification Program

Issue: AMB-415
Project: Ambitions Flagship Elevation Program
Milestone: Trust and Evidence Operating System

## Mission

Create a reusable accessibility certification program scaffold for AFEP surfaces and continuity paths without claiming public accessibility certification or conformance.

## Product Law

Ambitions remains a premium native iPhone-first, local-first Personal Life Operating System. Active top-level IA remains exactly:

`Today / Goals / Capture / Time / You`

Primary objects remain:

- Today -> Reality Meridian / Start Here
- Goals -> Constellation Atlas
- Capture -> Atmosphere Composer
- Time -> LifeShape Field
- You -> User System Profile

Accessibility proof is evidence-bound. Source hooks, labels, fixture metadata, and automated tests can support accessibility review, but they do not prove public accessibility conformance without current manual/device proof.

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
13. Existing accessibility proof/source/test material, including the AFRI accessibility proof matrix, accessibility proof protocols, current accessibility tests, and active proof-bound claim locks.

## Scope Allowed

Add an AFEP-021 accessibility certification program foundation only:

- Certification program data model or source scaffold.
- Canonical surface fixture states for Today, Goals, Capture, Time, and You.
- Gates for VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, tap targets, semantic grouping, non-color meaning, motion-independent meaning, privacy/redaction readability, and cognitive load.
- Evidence packet format that records command, artifact path, surface, fixture state, pass/fail/skipped state, known limitation, owner, and follow-up proof requirement.
- Public-claim lock integration that keeps accessibility certification unavailable until manual/device proof exists.
- Rollback path to AFRI accessibility proof matrix and existing accessibility nutrition checks.
- Tests proving all required surfaces/gates exist, all public claims remain locked, and manual/device proof gaps stay explicit.
- Audit artifacts:
  - `docs/audits/afep021-accessibility-certification-program-report.md`
  - `docs/audits/afep021-accessibility-gate-matrix.md`
  - `docs/audits/afep021-accessibility-proof-claim-boundary.md`
  - `docs/audits/afep021-accessibility-rollback-plan.md`

## Source Boundary

Prefer extending the existing preview-proof support pattern from AFEP-020 instead of creating a parallel subsystem:

- `Native/Ambitions/PreviewSupport/ShellPreviewMatrix.swift`
- `Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift`
- `Native/AmbitionsTests/App/ShellPreviewMatrixTests.swift`

If the runner or guard proves a different canonical owner is safer, document why in the final report.

## Strictly Forbidden

- Do not claim Ambitions is accessible, fully accessible, VoiceOver verified, Dynamic Type verified, Reduce Motion verified, Increase Contrast verified, WCAG compliant, ADA compliant, App Store ready, TestFlight ready, release ready, or device verified.
- Do not add a new top-level destination.
- Do not reintroduce Plan as a top-level destination.
- Do not add analytics, telemetry SDKs, hosted accessibility services, cloud AI, external LLMs, or custom backend services.
- Do not modify production planner/runtime behavior based on accessibility scaffold metadata.
- Do not silently alter user data, persistence schemas, sync, or privacy manifest claims.
- Do not stage `.codex/runs`, `.xcresult`, local indexes, graph artifacts, generated visual-summary artifacts, or broad generated project churn.

## Proof Boundary Requirements

Every new accessibility proof type must distinguish:

- source-backed support
- automated-test evidence
- rendered screenshot evidence
- manual VoiceOver traversal
- Dynamic Type screenshot review
- Reduce Motion walkthrough
- Increase Contrast measured review
- tap-target/motor review
- physical-device proof
- public accessibility claim approval

Only source/test support may be Green in this batch unless current proof is actually collected. Manual/device/rendered proof gaps must remain explicit and blocking for public claims.

Where this batch touches proof, receipt, replay, or source-inspection language, keep local-only provenance explicit:

- `SourceRecord.afep021.accessibility-certification-program`
- `Receipt.afep021.accessibility-certification-program`
- `ReplayTrace.afep021.accessibility-certification-program`
- `You / What Ambitions knows`

These labels are provenance hooks only; they must not imply runtime sync, hosted services, production certification, or user-facing accessibility claims.

## Validation

Run the strongest available repo validation commands for the touched scope. Prefer:

- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-021`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-021 --prompt prompts/batches/AFEP-021.md --batch-type source-changing`
- `xcodegen generate`
- `python3 scripts/ambitions_validate_accessibility_gates.py`
- `make xcode-build-for-testing BATCH=AFEP-021`
- `make xcode-focused-test BATCH=AFEP-021 TEST=AmbitionsTests/AccessibilityNutritionChecklistTests`
- `git diff --check`
- Claim scans proving no positive accessibility/release/device certification claim was added.

If any validation is unavailable or fails for pre-existing reasons, document exact evidence and keep status Yellow at best.

## Acceptance Gates

Green only if:

- Accessibility certification program scaffold exists behind explicit proof boundaries.
- Today, Goals, Capture, Time, and You are covered.
- VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, tap target, semantic grouping, non-color, motion-independent, privacy/readability, and cognitive-load gates are represented.
- Public accessibility claims remain locked.
- Manual/device/rendered proof requirements remain explicit.
- Existing AFRI accessibility proof matrix remains a rollback baseline.
- Tests pass for the new scaffold.
- No user-facing accessibility certification or release readiness claim is made.

## Report Format

End with:

```text
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
- exact steps
```

## Commit Behavior

Create a clean commit if validations are Green or Yellow-with-documented-preexisting-failures. Do not commit Red implementation.
