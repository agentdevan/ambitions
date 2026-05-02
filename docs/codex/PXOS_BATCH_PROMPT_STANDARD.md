# PXOS Batch Prompt Standard

Status: Future Codex OS standard; PXOS implementation not started
Date: 2026-05-02

Every PXOS future prompt must be self-contained and executable.

## Required Sections

- Batch ID and name
- Status: Future prompt; do not run automatically
- Purpose
- Source truth files to read first
- Product-experience decision boundaries
- Product-decision lock references
- Allowed files
- Forbidden files
- Exact surface ownership
- Top-level surface composition tests, if a top-level tab is touched
- Relationship to Ambitions 3.0
- Relationship to AmbitionsOS
- Relationship to ME
- Relationship to CS
- Relationship to REC/release claims
- Implementation boundary
- Non-goals
- Required validation
- Required evidence/report output
- Required registry/context/run-state update
- Green / Yellow / Red criteria
- Stop conditions
- Rollback/repair expectations
- What this batch may claim
- What this batch must not claim
- What this batch does not prove
- Commit message recommendation
- Next safe prompt/path

Reject prompts that only say follow canon, validate, update as needed, preserve
behavior, selected by manifest, improve design, make it premium, or add polish
without concrete owners, files, gates, evidence, and stop conditions.

For top-level surface work, reject prompts that propose a vertical stack of
generic cards as the main structure. The prompt must require a glance test,
one-primary-object test, and drill-down discipline test, and it must name where
secondary detail moves behind a tap.
