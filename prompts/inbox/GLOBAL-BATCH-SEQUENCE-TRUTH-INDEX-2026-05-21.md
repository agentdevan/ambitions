<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# GLOBAL-BATCH-SEQUENCE-TRUTH-INDEX — Global Batch Sequence Reconciliation

## Mission
Act as Ambitions repo-governance lead, release-proof engineer, and Codex OS maintainer for `agentdevan/ambitions`.

Update the repo's global batch train / global implementation sequence so it accurately reflects the real repository history, current committed source state, installed batch prompts, train manifests, runbooks, proof artifacts, and current commit evidence.

This is not a canon rewrite. This is a truth reconciliation pass.

## Primary Goal
Create or update one singular authoritative global sequence document that answers:

1. What has actually been installed or implemented?
2. What is docs-only / prompt-only / proof-only?
3. What is source-changing and already committed?
4. What train/batch order is currently authoritative?
5. What should run next?
6. What must not be claimed yet?
7. What sequences are obsolete, superseded, duplicated, or historically quarantined?

## Target Output
Prefer updating or creating:

- `docs/codex/GLOBAL_BATCH_SEQUENCE.md`

Also update cross-links only where necessary in:

- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/codex/POST_BATCH_GATE_REGISTRY.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`

Do not delete historical documents unless clearly obsolete and safely quarantined. Prefer adding supersession notes and links to the new authoritative document.

## Required Audit Commands
Run and save outputs under `build/reports/global-batch-sequence/`:

```bash
mkdir -p build/reports/global-batch-sequence
git status --short > build/reports/global-batch-sequence/git-status-before.txt
git log --reverse --date=iso-strict --pretty=format:'%H%x09%ad%x09%an%x09%s' > build/reports/global-batch-sequence/git-log-reverse.tsv
git log --date=iso-strict --pretty=format:'%H%x09%ad%x09%an%x09%s' > build/reports/global-batch-sequence/git-log-newest-first.tsv
git log --reverse --name-status --date=iso-strict --pretty=format:'COMMIT%x09%H%x09%ad%x09%s' > build/reports/global-batch-sequence/git-log-name-status.tsv
find docs/codex prompts/batches prompts/trains .codex -type f 2>/dev/null | sort > build/reports/global-batch-sequence/codex-file-inventory.txt
rg -n "IOS26-|TRAIN_|AMB-|PK[0-9]+|SI[0-9]+|AUTO-|GLOBAL-|BATCH|Status:|installed_not_run|Green|Yellow|Red|superseded|quarantine|runner" docs prompts .codex scripts Makefile project.yml Package.swift 2>/dev/null > build/reports/global-batch-sequence/batch-train-keyword-scan.txt || true
python3 scripts/ios26-flagship-preflight.py || true
python3 scripts/ios26-flagship-proof-packet-check.py || true
python3 scripts/ambitions-codex-os-validate.py || true
```

Save all command results. Do not claim Green unless commands actually pass.

## Reconciliation Rules
Build the global sequence from evidence in this priority order:

1. Current committed source files.
2. Current train manifests and runbooks.
3. Current batch prompt files.
4. Proof artifacts and reports.
5. Commit history and commit subjects.
6. Historical docs only when clearly not superseded.

Classify every major train/batch/group as one of:

- Implemented in source
- Installed as prompt/train only
- Docs/proof only
- Partially implemented
- Superseded
- Historical/quarantined
- Blocked
- Unknown / needs manual review

Do not treat a prompt file as implementation.
Do not treat a proof packet shape check as proof of product quality.
Do not treat committed docs as app behavior.
Do not claim release readiness, accessibility verification, performance validation, App Store readiness, or device verification without current proof.

## Global Sequence Document Requirements
`docs/codex/GLOBAL_BATCH_SEQUENCE.md` must include executive status, source-of-truth hierarchy, commit-derived implementation ledger, current authoritative batch sequence, status matrix, supersession/quarantine section, next-run recommendation, no-claim boundaries, and validation appendix.

## Acceptance Gates
Green only if `GLOBAL_BATCH_SEQUENCE.md` exists, reflects current manifests/prompt files/committed source/commit evidence, distinguishes implementation from docs/prompt/proof installation, identifies the next eligible batch accurately, saves validation/audit outputs, and introduces no release/accessibility/performance/device/App Store overclaims.

Yellow if commit history is too large or ambiguous in places but unknowns are marked, or some validators cannot run locally and the reason is recorded.

Red if the sequence is speculative, docs-only work is labeled implemented, old plans remain authoritative without supersession notes, next eligible batch conflicts with dependencies/stop rules, or unsupported release/quality claims are introduced.
