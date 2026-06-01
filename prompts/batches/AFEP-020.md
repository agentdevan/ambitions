<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-020 - Deterministic Visual Diff Lab

Linear issue context: AMB-414 / AFEP-020 in the Ambitions Flagship Elevation Program.

## Mission

Create a deterministic visual diff lab foundation for canonical Ambitions surfaces and proof artifacts without claiming rendered screenshot proof, accessibility certification, release readiness, or production visual QA completion.

## Product Law

Ambitions is a premium native iPhone-first, local-first Personal Life Operating System. Visual proof must support object-first flagship quality, not generic module-grid or card-stack aesthetics. Today / Goals / Capture / Time / You remain the only top-level IA. Plan is not a user-facing top-level destination. Visual diff tooling must be deterministic, local, simulator/CI safe, and proof-honest.

## Scope Allowed

1. Inspect current repo truth:
   - `docs/truth/*`
   - `AGENTS.md`
   - `project.yml`
   - existing preview/screenshot fixtures, especially `Native/Ambitions/PreviewSupport/ShellPreviewMatrix.swift`
   - existing UI/unit test proof lanes
   - existing visual/accessibility audit docs and scripts

2. Add deterministic visual diff lab foundation only:
   - canonical surface fixture matrix for Today, Goals, Capture, Time, You
   - named deterministic data seeds/projection inputs
   - variant dimensions for baseline, loading, empty, private/source-review, blocked/recovery, overloaded, Reduce Motion, Increase Contrast, and Dynamic Type
   - artifact bundle metadata model for future screenshot/diff outputs
   - proof-boundary metadata that can reference SourceRecord, Receipt, and ReplayTrace identifiers when future rendered artifacts exist
   - You / What Ambitions knows inspection labels for future artifact provenance
   - local-only proof/claim boundary fields
   - no screenshot generation claim unless a current command actually generates screenshots
   - no production UI redesign unless the smallest compile-safe hook is required

3. Add focused tests proving:
   - all canonical tabs/surfaces are covered
   - required accessibility variants are present
   - artifact metadata is deterministic and path-safe
   - no release/accessibility/device proof is claimed by the scaffold
   - SourceRecord, Receipt, ReplayTrace, and You inspection provenance fields are present but do not imply rendered proof
   - rollback to existing AFRI screenshot proof paths is explicit

4. Add proof artifacts:
   - `docs/audits/afep020-visual-diff-lab-report.md`
   - `docs/audits/afep020-visual-diff-fixture-matrix.md`
   - `docs/audits/afep020-visual-proof-claim-boundary.md`

## Strictly Forbidden

- Do not claim screenshots were rendered unless current logs prove it.
- Do not claim deterministic visual diffs are production-ready.
- Do not claim VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, device, TestFlight, App Store, CI, privacy/legal, or performance readiness.
- Do not add third-party snapshot dependencies.
- Do not add hosted CI, backend services, telemetry, analytics, cloud AI, or custom server infrastructure.
- Do not create a sixth top-level destination.
- Do not reintroduce Plan as a top-level IA.
- Do not redesign visible product surfaces as part of this batch.
- Do not commit generated `.codex/runs`, `.xcresult`, repo-intelligence indexes, graph artifacts, or local generated tool caches.

## Implementation Requirements

- Prefer extending `Native/Ambitions/PreviewSupport/ShellPreviewMatrix.swift` or adding a sibling under `Native/Ambitions/PreviewSupport/` over creating a parallel visual proof owner.
- Keep all new source deterministic, value-model oriented, and testable without simulator screenshots.
- Use compile-safe Swift models and unit tests.
- Preserve existing screenshot hook behavior.
- Document whether this batch is Green as a foundation only or Yellow because rendered proof is still absent.

## Suggested Validation

Run the strongest safe local validation available:

- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-020`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-020 --prompt prompts/batches/AFEP-020.md --batch-type source-changing`
- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AFEP-020`
- focused XCTest for the new visual diff lab tests
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-020 --prompt prompts/batches/AFEP-020.md --changed-from <BASE_SHA> --batch-type source-changing`
- `git diff --check`
- targeted grep checks for forbidden claims and generated artifacts

## Acceptance Gates

Green only if:

- Build/focused tests pass, or any failure is documented as pre-existing with evidence.
- The fixture matrix covers all five canonical surfaces.
- Accessibility variants include Dynamic Type, Reduce Motion, and Increase Contrast coverage.
- Artifact metadata is deterministic and local path-safe.
- No rendered screenshot, visual diff, accessibility certification, release, device, or CI proof is overclaimed.
- Rollback to AFRI screenshot proof paths is documented.

## Report Format

End with:

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
- exact steps to return to the prior AFRI screenshot/preview proof path.

## Commit Behavior

Create a clean commit if validations are Green or Yellow-with-documented-preexisting-failures. Do not commit Red implementation.
