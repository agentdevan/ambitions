# AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01 Train Manifest

## Train
Train 0.

## Goal
Create the minimum batch scaffold needed to continue the reset without widening scope.

## Scope
- Snapshot current repo truth
- Record the active authority map
- Record the train boundary and non-goals
- Record validation evidence for the bounded patch
- Emit the initial JSON report

## Files Likely Touched
- `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.md`
- `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-train-manifest.md`
- `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-authority-map.md`
- `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-validation-proof.md`
- `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.json`
- `build/reports/amb-repo-green-flagship-reset-master-01.json`
- `scripts/ambitions-codex-os-validate.py`

## Files Explicitly Not Touched
- `Native/**`
- `Sources/**`
- `AppUI/**`
- `project.yml`
- `Package.swift`
- `.xcodeproj/**`
- `.codex/runs/**`
- existing audit artifacts outside this batch prefix
- the untracked batch prompt file
- generated validator reports outside this batch prefix, including `build/reports/ambitions-codex-os-validate.json`

## Validation Commands
- `python3 -m json.tool build/reports/amb-repo-green-flagship-reset-master-01.json >/tmp/amb-green-reset.json`
- `python3 -m json.tool docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.json >/tmp/amb-green-reset-docs-path.json`
- `python3 scripts/ambitions_validate_prompt_headers.py`
- `python3 scripts/ambitions_validate_batch_ids.py`
- `python3 scripts/ambitions-codex-os-validate.py`
- `git diff --check`
- `git status --short`

## Green Criteria
- All train-0 artifacts exist.
- The JSON report parses.
- No unexpected file classes are touched.
- The diff remains limited to batch docs/reports; no validator allowlist change is required because the prompt-required build-report path is already accepted.

## Yellow Criteria
- Validation parses but one or more follow-up trains remain deferred.
- A validator mismatch is found and documented without widening the patch.

## Red Criteria
- Any source, project, or historical-archive file is touched outside the approved boundary.
- The JSON report fails to parse.
- The patch introduces a claim that is not supported by the recorded evidence.

## Rollback
- `git restore -- docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01*.md build/reports/amb-repo-green-flagship-reset-master-01.json`
- If any file remains untracked, remove only the batch prefix files created in this phase.

## Phase-04 Repair Ownership Decision
- The required batch JSON now exists at `build/reports/amb-repo-green-flagship-reset-master-01.json`.
- `scripts/ambitions-codex-os-validate.py` already allowlists that exact required report path.
- The docs-path JSON remains a supporting copy for audit readability.
- `build/reports/ambitions-codex-os-validate.json` is a validator-generated side effect, not a batch-owned deliverable for this train.
- Commit eligibility for this train excludes `build/reports/ambitions-codex-os-validate.json`; rerunning the validator may rewrite it locally, but it must be restored or left unstaged unless a later scoped batch explicitly owns that report.
