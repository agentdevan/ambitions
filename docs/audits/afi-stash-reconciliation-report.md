# AFI Stash Reconciliation Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Status: Yellow
Branch: `main`
HEAD at correction start: `6062280c`
Stash: `stash@{0}: On main: pre-sync local dirty work before pulling Codex OS upgrade`

## Result

Status: Yellow.

The active AFI source truth supersedes the earlier Plan-era assumption:

```text
Today
Goals
Capture
Time
You
```

Plan is not a top-level destination. Plan remains valid only as an action or
contextual noun such as Adjust plan, Shape week, or Review pressure. ACUI is
superseded by AFI.

No app code was modified during this reconciliation.

## Source Truth Used

- `docs/AmbitionsCanon/Ambitions_Design_System.md`
- `docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md`
- `docs/AmbitionsCanon/01A_Product_Canon_Flagship_Amendment.md`
- `docs/AmbitionsCanon/11_Canonical_Vocabulary_And_Copy_Bible.md`
- `docs/AmbitionsCanon/15_AFI_Implementation_Lane.md`
- `docs/codex/AMBITIONS_CANON_UI_COMPLETION_INSERTION_OVERLAY.md`

## Stash Classification

The stash was inspected with `git stash show --name-only stash@{0}`,
`git stash show --stat stash@{0}`, and targeted diff searches for IA,
sequencing, AFI, ACUI, PLR, PK, and LDI routing terms.

| Stash hunk area | Classification | Disposition |
| --- | --- | --- |
| AFI source-truth language using `Today / Goals / Capture / Time / You` | Valid current source truth | Preserved in stash; current HEAD already contains AFI source-truth docs, and run-state/registry were corrected directly. |
| Hunks that supersede `Plan` as a top-level destination | Valid AFI source truth | Preserved in stash; reflected in this correction report and active state. |
| Hunks that insert PLR sequencing and mark PLR02 next | Not fully registry-proven in current HEAD | Preserved in stash; not applied because the active worktree does not contain the corresponding PLR owner docs from the stash name/stat view. |
| Hunks that keep LDI15 from being the fallback next batch | Valid sequencing improvement | Reconciled through helper-script live-state support and AFI-aware fallback order. |
| Hunks that add PLR ID support to helper scripts | Potentially useful, but incomplete without PLR owner docs in active HEAD | Preserved in stash; not applied in this pass. |
| Hunks that would restore Plan as top-level truth | Stale Plan-era IA | Rejected. No such hunk was applied. |
| Hunks that would treat ACUI as active over AFI | Superseded by AFI | Rejected. No such hunk was applied. |
| Hunks duplicate with current HEAD or PK00 integration | Duplicate / superseded | Preserved in stash for later human-safe reconciliation; not reapplied. |

## Hunks Applied

- No stash hunk was applied directly.
- Helper scripts were updated manually so live run-state can route `AFIxx` IDs
  and the deterministic fallback no longer falls through to LDI15 while AFI is
  the current next eligible lane.
- Run-state, batch-train state, registry, context, and PK state mirrors were
  corrected to AFI source truth.

## Hunks Rejected

- Any hunk that would make Plan a top-level destination.
- Any hunk that would downgrade AFI to ACUI or treat ACUI as active over AFI.
- Any hunk that would let optional PK/PLR expansion outrun AFI without
  registry/report proof of a minimum safety prerequisite.
- Any stale sequencing hunk that would route directly to LDI15 while AFI is the
  active next eligible lane.

## Hunks Preserved

The full stash remains preserved at `stash@{0}`. No stash entry was dropped or
popped. PLR-related sequencing material remains parked Yellow until PLR owner
docs and registry evidence are present in active HEAD or intentionally
reconciled from the stash.

## Source-Truth Conflicts Found

- The earlier PK integration report incorrectly treated
  `Today / Goals / Capture / Plan / You` as current active IA. This was wrong
  for active flagship canon and has been corrected.
- `docs/AmbitionsCanon/Ambitions_Design_System.md` still contains older Plan
  wording in some sections, but `01A_Product_Canon_Flagship_Amendment.md`,
  `10_Ambitions_Flagship_Interface_Canon.md`, `11_Canonical_Vocabulary_And_Copy_Bible.md`,
  `15_AFI_Implementation_Lane.md`, and the AFI insertion overlay supersede
  Plan-as-top-level wording for active flagship decisions.
- Current app/source may still contain legacy Plan owner paths or symbols. That
  is compatibility debt, not permission to restore Plan as top-level product
  truth.

## Plan-Era IA Rejection

Plan-era top-level IA was rejected. No file in this correction intentionally
restores Plan as a top-level destination.

## AFI Status

AFI remains active. AFI01 Canon Language Purge is the next eligible global
batch.

## PK Status

PK is active planned Platform Kernel scope. PK00 is complete / Green with
accepted Yellow follow-ups as a backend/platform proof baseline. PK01-PK41 are
queued and may run before a later AFI batch only if registry/report evidence
proves the specific PK batch is a minimum safety prerequisite. PK is not
currently proven as a prerequisite for AFI01 Canon Language Purge or AFI02 IA
Hierarchy Lock.

## Next Eligible Batch

AFI01 Canon Language Purge.

## Continuation Rule

Continue through Green and accepted Yellow. Do not continue into PK01-PK41, PLR,
LDI15, AOS24, or unrelated future expansion before AFI unless current registry
and owner-report evidence prove a specific minimum prerequisite. Stop on hard
Red if Plan is restored as a top-level destination, AFI is downgraded to ACUI,
stale stash content overwrites newer source truth, helper scripts route to
LDI15 despite AFI/PK/PLR order, optional expansion outruns AFI without proof, or
app code is modified during reconciliation.

## Validation

- `bash -n scripts/global-train-next-batch.sh scripts/global-train-status-summary.sh`: exit 0.
- `scripts/global-train-next-batch.sh`: exit 0; returned `AFI01 Canon Language Purge.` from `.codex/reports/current-run-state.md`.
- `scripts/global-train-status-summary.sh`: exit 0; returned `AFI01 Canon Language Purge.` from `.codex/reports/current-run-state.md`.
- `git diff --check`: exit 0.
- `python3 scripts/ai/acx_local.py bundle quick`: exit 0; raw logs under `.codex/logs/2026-05-08T10-22-46/`.
- `python3 scripts/ai/acx_impact.py <changed files>`: exit 0; route `Canon Drift`, suggested bundles `docs` and `batch-closeout`.
- `python3 scripts/ai/acx_local.py bundle docs`: exit 0; `acx-gate-all` Green with advisory scan findings; raw logs under `.codex/logs/2026-05-08T10-23-29/`, `.codex/logs/2026-05-08T10-23-30/`, and `.codex/logs/2026-05-08T10-23-31/`.
- `python3 scripts/ai/acx_local.py bundle batch-closeout`: exit 0; advisory CQS scan findings only.
- `scripts/batch-train-gate-check.sh || true`: exit 0; Yellow hint for expected dirty tree before commit.
- `python3 scripts/ai/acx_repair.py diagnose`: exit 0; Yellow `NoActiveRepairEvidence`; no state written.

No app build, focused Swift tests, visual packet, or accessibility packet was
run because this reconciliation changed docs, Codex state mirrors, and helper
scripts only. No app source changed.
