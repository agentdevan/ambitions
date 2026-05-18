# AMB-POST23 Eligibility Gate

Status: **Blocking gate**

## Rule

The post-23 truth audit/repair train is installed now but must remain blocked until the original 23-batch FE/BE train is complete.

## Required evidence

The completion sentinel must find evidence for all of the following:

- Original 23-batch train manifest exists.
- Original 23-batch train execution order exists.
- All 23 batches are accounted for.
- The final integrated proof batch is present: `AMB-FE-BE-INTEGRATED-PROOF-99` or active equivalent.
- Final integrated proof report exists or the original train has a terminal Red/Yellow closeout that explicitly blocks proceeding.
- No original batch is currently marked active/running/in-progress.
- No runner artifact indicates an active patch in progress.
- No unsafe worktree state would be overwritten by post-23 audit/repair.

## Hard Red conditions

The sentinel must stop Red if any of these are true:

1. It cannot identify the original 23-batch train.
2. It cannot identify final proof batch status.
3. Any original implementation batch is pending, active, or ambiguous.
4. The runner appears to be in the middle of a patch.
5. The worktree has unrelated dirty files that would make audit/repair unsafe.
6. The post-23 train was already run and the repo lacks an explicit re-run request.
7. The repo has conflicting post-23 train authorities.

## Eligible result

If the gate passes, the next command is:

```bash
scripts/ambitions-codex-train.sh AMB-POST23-01-TRUTH-AUDIT prompts/batches/post-23-truth-audit/AMB-POST23-01-TRUTH-AUDIT.md
```

## Ineligible result

If the gate does not pass, Codex must leave the train installed and blocked, then continue or recommend continuing the original 23-batch train.
