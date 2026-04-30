# Full Regression Escalation Skill

## Purpose

Use this skill for full regression escalation skill work in Ambitions 3.0.

## Use When

- The task explicitly matches `full-regression-escalation-skill`.
- The work touches Ambitions 3.0 source truth, native SwiftUI, validation, dependency, release, UX, language, privacy, or repo hygiene in this skill's lane.

## Do Not Use When

- The task belongs to a narrower skill.
- The request is a simple status check or one-command answer.
- Using this skill would widen scope beyond the user's request.

## Required Docs To Read

- `README.md`
- `docs/README.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_3_0_Product_Language_System.md`
- Target primitive/surface/contract docs named by the context pack.
- `docs/codex/BATCH_REGISTRY.md` for implementation status only.

## Primary Files Likely Touched

- `docs/canon/Ambitions_3_0_*` when canon/status changes.
- `docs/codex/*` and `.codex/*` when operating guidance changes.
- `Native/Ambitions/**`, `Sources/**`, `AppUI/Sources/**`, `project.yml`, or tests only when implementation is in scope.

## Required Plan Shape

1. Mode and scope.
2. Source docs read.
3. Primary files.
4. Touch budget.
5. Validation pack.
6. Stop conditions.

## Implementation Rules

- Preserve Ambitions 3.0 source hierarchy.
- Build additively inside existing seams.
- Do not create new top-level destinations.
- Do not add runtime dependencies.
- Do not claim readiness without evidence.

## Validation Commands

```bash
git status --short
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' build CODE_SIGNING_ALLOWED=NO
```

Run narrower tests/scans from the selected validation pack.

## Evidence Output

- Files changed.
- Commands run.
- PASS/PARTIAL/FAIL.
- Known risks.
- Next exact prompt.

## Common Failure Modes

- Starting from historical 2.0/v2 docs as active truth.
- Broad renames that break compatibility.
- Running the full UI suite without first checking known failures.
- Overstating release, accessibility, or device proof.

## Stop Conditions

- Source truth conflict cannot be resolved from files.
- Required local tooling is missing and no fallback exists.
- The next step would require paid services, credentials, physical-device proof, or broad product scope not requested.

## Related Skills

- `.codex/skills/source-truth-reconciler.md`
- `.codex/skills/evidence-gate-reporter.md`
- `.codex/skills/build-test-pack-runner.md`
- `.codex/skills/diff-scope-controller.md`
