<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-041 - Experience QA rubric

Linear issue: AMB-463
Project: Ambitions Experience Sovereignty Program
Milestone: M08 - Frontend Proof, Screenshot Diffing, and Release Authority

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/accessibility/AMB_ACCESSIBILITY_MOAT_MATRIX.md`
- `docs/launch/10-release-readiness-gates.md`

## Batch Goal

Consolidate surface, journey, visual, motion, accessibility, platform, release-proof, rollback, and Yellow/Red handling into the final QA rubric after M03–M08 evidence packets exist.

## Implementation Scope

- `docs/audits`
- `docs/status`
- `docs/launch`
- `docs/accessibility`
- `Native/AmbitionsTests/App/ReleaseCandidateLockDecisionReportTests.swift`
- `Native/AmbitionsTests/App/ReleaseDeviceQAReadinessReportTests.swift`
- `Native/AmbitionsTests/App/ReleaseExternalTruthReadinessPacketTests.swift`
- `Native/AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests.swift`

## Required Product Outcomes

- Single consolidated QA rubric with explicit pass/fail/blocked status across M03–M08.
- Rollback paths and claim locks are clear.
- No release claim is made without owner evidence.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-041/experience-qa-rubric-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-041
make xcode-focused-test BATCH=AESP-041 TEST=AmbitionsTests/App/ReleaseCandidateLockDecisionReportTests
make xcode-focused-test BATCH=AESP-041 TEST=AmbitionsTests/App/ReleaseDeviceQAReadinessReportTests
make xcode-focused-test BATCH=AESP-041 TEST=AmbitionsTests/App/ReleaseExternalTruthReadinessPacketTests
make xcode-focused-test BATCH=AESP-041 TEST=AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests
```
