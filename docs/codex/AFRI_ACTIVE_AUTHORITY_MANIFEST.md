# AFRI Active Authority And Automation Manifest

Status: Active AFRI governance routing manifest
Owner: AMB-391 / AFRI-039
Machine manifest: `docs/codex/AFRI_ACTIVE_AUTHORITY_MANIFEST.json`

## Purpose

This file gives Codex a narrow front door for AFRI closeout work: where source truth starts, how batch order is resolved, which local commands validate authority drift, how Green/Yellow/Red proof reporting works, and how rollback is bounded.

It is governance routing only. It does not prove app behavior, release readiness, device behavior, accessibility conformance, privacy/legal approval, TestFlight readiness, App Store readiness, or CI proof.

## Authority Order

Use this order before touching files:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `README.md`
10. `docs/README.md`
11. `project.yml`
12. `Package.swift`
13. relevant live source, tests, scripts, proof packets, and current logs

`docs/canon/**`, `docs/AmbitionsCanon/**`, `docs/codex/**`, `.codex/**`, `.agents/**`, generated governance outputs, audits, and status docs are supporting or historical unless the truth files promote a specific file.

## Batch And Runner Instructions

For normal Ambitions batch execution, use:

```bash
scripts/ambitions-codex-train.sh <BATCH_ID> <PROMPT_FILE>
```

or:

```bash
make batch BATCH=<BATCH_ID> PROMPT=<PROMPT_FILE>
```

Runner-compatible prompts must include:

```html
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
```

For the current AFRI closeout lane, the user explicitly ordered AMB-364, AMB-365, and AMB-366 after AMB-389 and before AMB-390. That human order is now recorded in the machine manifest so future agents do not infer a stale sequence.

## Validation Commands

Run these for AMB-391 authority proof:

```bash
python3 scripts/ambitions-afri-authority-manifest-validate.py
python3 scripts/ambitions-afri-stale-doc-detector.py
git diff --check
```

Use the parallel implementation guard for pre/post proof when the issue touches guard-scanned governance or proof concepts.

## Green / Yellow / Red Reporting

Green:

- required local gates passed with current logs
- no unresolved Red
- no release or implementation overclaim is made

Yellow:

- a scoped gate is advisory, blocked, timed out, not applicable, or accepted
- owner, safety reason, no-claim boundary, and follow-up gate are recorded

Red:

- required gate failed
- active stale guidance was introduced
- truth-file authority was weakened
- proof would overclaim current evidence

## Rollback

Rollback is commit-scoped:

- revert the AMB-391 commit if this manifest or validator misroutes active work
- do not delete historical material to make validation Green
- keep generated `.codex/runs`, `output`, DerivedData, and unrelated local dirt out of commits
