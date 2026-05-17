<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

REPO-AUTHORITY-LEGACY-ACTIVE-HEADER-CLEANUP-01

## Objective

Repair misleading legacy active-authority headers found in `docs/canon/Ambitions_3_0*` and related legacy canon files so they no longer present old Ambitions 2.0/3.0/4.0 material as active repo truth.

This is a docs/source-truth cleanup batch. Do not implement app behavior.

## Active Source Truth To Inspect

- `docs/truth/README.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/canon/README.md`
- `docs/status/old-canon-classification-index.md`
- `scripts/validate-repo-authority.sh`
- legacy files flagged by `bash scripts/validate-repo-authority.sh .`

## Allowed Scope

- `docs/canon/Ambitions_2_0*.md`
- `docs/canon/Ambitions_3_0*.md`
- `docs/canon/Ambitions_4_0*.md`
- `docs/status/old-canon-classification-index.md` only if needed to keep classification evidence current

## Required Work

- Replace misleading `Status: Active...` legacy headers with historical/supporting/subordinate wording.
- Preserve useful historical content and traceability.
- Do not delete or move files.
- Do not make old canon the active source of truth.

## Validation Expectations

- `bash scripts/validate-repo-authority.sh .`
- `python3 scripts/ambitions-repo-authority-validate.py`
- `git diff --check`

## Forbidden Scope

- No Swift/source changes.
- No roadmap rewrite.
- No release, implementation, accessibility, privacy, performance, or production claims.

## Runner Command

```bash
make batch BATCH=REPO-AUTHORITY-LEGACY-ACTIVE-HEADER-CLEANUP-01 PROMPT=prompts/batches/REPO-AUTHORITY-LEGACY-ACTIVE-HEADER-CLEANUP-01.md
```
