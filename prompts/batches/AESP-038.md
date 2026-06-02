<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-038 - Experience screenshot matrix

Linear issue: AMB-460
Project: Ambitions Experience Sovereignty Program
Milestone: M08 - Frontend Proof, Screenshot Diffing, and Release Authority

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/accessibility/AMB_ACCESSIBILITY_MOAT_MATRIX.md`

## Runtime Contract Boundary

- Preserve and expose `SourceRecord`, `Receipt`, and `ReplayTrace` continuity for any runtime-affecting change.
- Include explicit `What Ambitions Knows` / You inspection so state transitions remain explainable.

## Batch Goal

Define and collect a current screenshot matrix across surfaces, journeys, sizes, appearances, accessibility settings, and states, with transparent verification status.

## Implementation Scope

- `Native/Ambitions/Features`
- `Native/Ambitions/PreviewSupport`
- `Native/Ambitions/App`
- `Native/AmbitionsTests/App/ShellPreviewMatrixTests.swift`
- `Native/AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests.swift`
- `Sources/Previews/SignatureInterfaceVisualQAFixtures.swift` (fixture source if present)
- `docs/launch/` and `frontend/visual-encyclopedia/` matrix artifacts
- `docs/audits/visual-evidence/`
- `scripts/ambitions-fe11-generate-fixture-screenshots.py`
- `scripts/ambitions-fe11-preview-visual-qa-report.py`

## Required Product Outcomes

- Screenshot coverage matrix is complete and machine-checked by state/surface/setting.
- Verified/unverified/not verified/blocked status is explicit.
- Provenance and environment metadata is attached to each screenshot artifact.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-038/experience-screenshot-matrix-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-038
make xcode-focused-test BATCH=AESP-038 TEST=AmbitionsTests/App/ShellPreviewMatrixTests
make xcode-focused-test BATCH=AESP-038 TEST=AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests
python3 scripts/ambitions-fe11-generate-fixture-screenshots.py
python3 scripts/ambitions-fe11-preview-visual-qa-report.py
```
