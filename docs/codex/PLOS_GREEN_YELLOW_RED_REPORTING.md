# PLOS Green Yellow Red Reporting

Status: Active PLOS M00 governance law
Issue: AMB-645 / PLOS-009
Parent: AMB-608 / PLOS-M00
Authority posture: Supporting PLOS reporting standard subordinate to `docs/truth/*`, `docs/codex-os/*`, and live source evidence
Runtime implementation proof: none

This standard defines how PLOS issues and phases report Green, Yellow, and Red without false readiness claims. It extends `docs/codex-os/PROOF_ARTIFACT_STANDARD.md`, `docs/codex-os/LINEAR_CLOSEOUT_STANDARD.md`, and `docs/codex/PROGRAM_EXECUTION_CONTRACT.md`.

## Core Rule

PLOS Green is a proof claim, not a tone. Yellow is a bounded proof gap with an owner. Red is a stop condition until repaired, rescoped, or explicitly accepted as not Green.

Every PLOS report must bind the verdict to:

- actual `AMB-*` issue identifier
- PLOS label as a local alias only
- pushed commit when pushed
- changed files
- validation commands and exit codes
- proof artifacts
- source, privacy, safety, accessibility, performance, and release boundaries
- rollback or failure behavior
- next eligible issue or phase

## Green Means

Green means all of the following are true for the scoped issue or phase:

- live runtime path is proven where runtime behavior is relevant
- required tests pass, or the active issue proves tests are not applicable
- visual proof is captured and visually evaluated where UI is relevant
- performance budget is met or the specific performance gap is accepted Yellow with owner and no readiness claim
- privacy checks pass for the changed scope
- safety checks pass for the changed scope
- source authority checks pass for the changed scope
- no unowned threat, Red blocker, or hidden Yellow debt remains
- app source changed only when the active issue authorizes app source changes
- no release, TestFlight, App Store, owner approval, privacy/legal, device, accessibility certification, or performance claim exceeds evidence

For governance-only M00 children, Green can mean the governance artifact is installed, wired, validated, and bounded. It does not mean runtime behavior exists.

## Yellow Means

Yellow means the scoped work is structurally correct but one or more named proof gaps remains:

- safe partial implementation or governance installation is complete
- known limitation is documented in the issue report, run-state, and closeout
- fallback works or the gap is governance-only and does not affect user-facing behavior
- next phase, child issue, or owner owns the gap
- no unsafe user-facing claim is made
- no release, TestFlight, App Store, device, privacy/legal, public accessibility, owner approval, or performance readiness claim is made
- non-waivable privacy, safety, source, data, security, phase-order, and AMB-ID gates pass

Yellow cannot hide ownerless debt. A Yellow item without owner, next gate, or no-claim boundary is Red.

## Red Means

Red means execution or closeout must stop until repaired or explicitly rescoped. Red includes:

- unsafe user-facing behavior or process
- unproven implementation claim
- unwired runtime path while claiming runtime Green
- performance-broken surface or runtime while claiming performance Green
- privacy-risky data path, including private user data in R2 or public Source Atlas objects
- source-untrusted or stale-source path while claiming source-backed Green
- misleading screenshot, accessibility, owner approval, release, device, privacy/legal, or performance claim
- PLOS label used as a Linear issue identifier
- phase-order violation
- app source mutation outside the active issue scope
- Green verdict without proof artifacts
- vague Red conditions that leave the next agent unsure why the issue stopped

## Required Final Report Format

Each PLOS issue report should use this shape unless the active issue provides a stricter one:

```markdown
# <AMB issue> / <PLOS label> Report

Status: Green | Yellow | Red for <exact scope>

## Summary
## Existing-First Inspection
## Files Changed
## Linear Changes
## Validation
## Proof Artifacts
## Runtime Path Proof
## Privacy / Safety / Source Checks
## Accessibility Checks
## Performance Notes
## Rollback / Failure Behavior
## Remaining Yellow / Red
## Follow-Up Issues Created
## Next Issue To Run
## Non-Claims
```

Required field behavior:

- `Status` must state the exact scoped verdict.
- `Existing-First Inspection` must name the source, docs, scripts, or artifact conventions inspected before adding new material.
- `Validation` must list command and result. Unknown commands are recorded as unknown in `docs/codex/PLOS_VALIDATION_REGISTRY.md`, not invented.
- `Proof Artifacts` must use the paths in `docs/codex/PLOS_PROOF_ARTIFACT_CONTRACT.md` or explain a stronger existing repo convention.
- `Runtime Path Proof` must say not applicable for governance-only work.
- `Privacy / Safety / Source Checks` must say pass, Yellow with owner, or Red with stop reason.
- `Accessibility Checks` and `Performance Notes` must separate not applicable, not verified, and verified.
- `Rollback / Failure Behavior` must identify the revert or repair path.
- `Non-Claims` must explicitly deny runtime, release, owner approval, accessibility, privacy/legal, device, and performance claims when not proven.

## Issue-To-Phase Rollup

A child issue may roll up to its parent phase only when:

- the child was resolved and updated through an actual `AMB-*` identifier
- child report exists under `artifacts/personal-life-os/reports/`
- closeout validator passed for child or phase scope
- proof ledger entry exists or is explicitly not applicable for docs-only scope
- run-state records pushed hash or pending push state honestly
- any Yellow item has owner, phase, and no-claim boundary
- parent phase gate still passes after the child

A parent phase may close Green only when every required child is Green or accepted Yellow and the parent acceptance gate passes with no hidden Red. Parent closeout must not imply later phases executed.

## Screenshot And Accessibility Boundary

Screenshot paths are not visual proof. Visual proof requires captured screenshots plus visual evaluation notes. Accessibility proof requires current accessibility evidence; screenshot paths, labels, or docs alone are not accessibility certification.

Screenshots never imply release readiness, TestFlight readiness, App Store readiness, owner approval, physical-device proof, public accessibility conformance, privacy/legal approval, or performance proof.

## Cross-Links

- `docs/codex/PROGRAM_EXECUTION_CONTRACT.md`
- `docs/codex/PLOS_VALIDATION_REGISTRY.md`
- `docs/codex/PLOS_PROOF_ARTIFACT_CONTRACT.md`
- `docs/codex-os/PROOF_ARTIFACT_STANDARD.md`
- `docs/codex-os/LINEAR_CLOSEOUT_STANDARD.md`
- `artifacts/plos-runtime/PLOS_PHASE_GATES.md`
- `artifacts/plos-runtime/PLOS-run-state.md`
- `.agents/skills/plos-runtime-master-build/references/plos-closeout-template.md`

## Non-Claims

AMB-645 does not claim:

- PLOS runtime implementation
- app source behavior change
- build or test proof for app source
- screenshot proof
- accessibility verification
- performance verification
- privacy/legal approval
- owner approval
- release, TestFlight, or App Store readiness
- PLOS-M01 or later execution
