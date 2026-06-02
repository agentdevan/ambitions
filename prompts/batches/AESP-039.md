<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-039 - Visual diff and regression gate

Linear issue: AMB-461
Project: Ambitions Experience Sovereignty Program
Milestone: M08 - Frontend Proof, Screenshot Diffing, and Release Authority

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Batch Goal

Install or run visual diff workflow for baseline capture, thresholding, artifact naming, and regression result reporting tied to current commit/environment.

## Implementation Scope

- `scripts/ambitions-visual-regression-readiness-check.py`
- `scripts/ambitions-visual-100*`
- `frontend/visual-encyclopedia/trace`
- `docs/audits/visual-evidence`
- `scripts/fe11*` visual QA assets and scripts
- `Native/AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests.swift`

## Required Product Outcomes

- Deterministic visual regression baseline process exists.
- Regression deltas are reported with explicit severity and handling rules.
- False-positive handling is documented and owned.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-039/visual-diff-and-regression-gate-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-039
make xcode-focused-test BATCH=AESP-039 TEST=AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests
python3 scripts/ambitions-visual-regression-readiness-check.py
make xcode-focused-test BATCH=AESP-039 TEST=AmbitionsTests
```
