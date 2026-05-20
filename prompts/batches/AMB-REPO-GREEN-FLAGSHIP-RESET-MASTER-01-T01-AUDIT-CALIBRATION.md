<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Audit Calibration And Validator Repair

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T01-AUDIT-CALIBRATION

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T01-AUDIT-CALIBRATION prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T01-AUDIT-CALIBRATION.md`

## Objective
Make audit and validator output trustworthy before production-source cleanup.

## Active source truth to inspect
Read the truth files first, then `build/audits/amb_file_by_file_repo_audit.py`, `scripts/ambitions-codex-os-validate.py`, existing audit Red/Yellow reports, and current JSON proof artifacts.

## Allowed scope
Audit scripts, Codex OS validator logic, reset-master authority map, validation proof, and master JSON.

## Forbidden scope
No production source, UI, project config, package manifest, historical deletion, app dependencies, hosted CI, cloud/backend/LLM, or release claims.

## Implementation requirements
Classify false positives versus real Red, distinguish prohibition/negative/historical/supporting/proof-target text from active drift, and treat timed-out validation as Yellow. If underscore-form validator expectations remain active, repair or explicitly demote them.

## Visual proof expectations
None.

## Accessibility expectations
None beyond non-claims.

## Privacy / trust expectations
No new dependency or network path.

## Continuity expectations
Keep old audit output available as evidence; do not delete history to make scanners Green.

## Validation expectations
Run prompt validators, Codex OS validator, audit script dry/summary command if available, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Truth weakening, production-source edit, required validator still missing while expected, or scanner producing false Green.

## Rollback expectations
Restore touched validator/audit scripts and reset-master audit files for this train.

## Expected final report format
List adjudicated Reds/Yellows, validator repairs, false-positive classes, remaining Yellow, commands, and non-claims.
