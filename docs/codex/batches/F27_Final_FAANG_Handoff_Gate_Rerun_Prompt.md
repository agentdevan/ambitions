# F27 Final FAANG Handoff Gate Rerun Prompt

Status: Queued after F26 Green

Rerun the full FAANG handoff readiness gate. Do not implement product behavior unless a tiny report/index fix is required.

Run or update evidence for:

- file inventory
- generated artifact scan
- legacy language scan
- internal identifier scan
- build
- `scripts/test-local.sh || true`
- doc QA
- orphan docs
- traceability
- release claim truth
- architecture scan
- privacy/accessibility evidence

Create `docs/audits/ambitions-3-0-final-faang-handoff-readiness-report.md`.

F27 PASS only if all required gates pass. If PARTIAL/FAIL, commit coherent evidence and run F28 only for identified blockers.
