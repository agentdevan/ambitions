# AMB-1729 Stale File Deletion Inventory

Status: inventory complete; deletion not executed
Issue: AMB-1729
Parent: AMB-1680 Source Atlas Scope Freeze
Baseline: `main` at `207f1210b9550b9b268c6b0db924c5923ab8b0ef`
Date: 2026-07-03

## Scope

This inventory maps current Source Atlas source, docs, generated proof, foundry
tooling, and QA artifacts into retained/current, review-before-delete, and
candidate-delete classes before any deletion.

This artifact does not delete files and does not promote historical proof to
current proof.

## Authority Boundary

Source Atlas remains public/reference/freshness infrastructure only. R2 is not a
user-data backend and must not receive goals, captures, calendar data, schedule
assumptions, proof, receipts, closure history, personalization, behavior
patterns, inferred priorities, private user context, or the private life graph.

Current release truth still blocks Source Atlas production readiness, R2
production readiness, privacy/legal approval, device proof, TestFlight readiness,
App Store readiness, and Release Green unless current evidence separately proves
those claims.

## Inventory Commands

The counts below came from the current tracked worktree and ignored local state:

```bash
git status --short --branch
git rev-parse HEAD
git ls-remote origin refs/heads/main
git ls-files 'tools/source-atlas/generated/**' | wc -l
git ls-files 'tools/source-atlas/**' | rg -v '^tools/source-atlas/generated/' | wc -l
git ls-files 'docs/qa/source-atlas/**' | wc -l
git ls-files 'Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/**' | wc -l
git ls-files 'Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/**' | wc -l
git ls-files 'Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/*SourceAtlas*' 'Native/AmbitionsTests/LocalRuntimeOS/RuntimeBoundary/*SourceAtlas*' | wc -l
git ls-files 'docs/platform/*SOURCE_ATLAS*' 'docs/platform/*SourceAtlas*' 'docs/platform/*source-atlas*'
git ls-files 'scripts/*source*atlas*' 'scripts/*r2*' 'scripts/*public*pack*' 'scripts/ambitions-remediation-governance-check.py'
find tools/source-atlas -type f \( -name '*.pyc' -o -name '.DS_Store' \) | wc -l
```

## Retained Current Files

| Area | Count | Classification | Evidence / reason |
|---|---:|---|---|
| `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/**` | 80 | Retain | Canonical current source owner named by implementation truth and ADR-2026-07-02. |
| `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/**` | 47 | Retain | Focused Source Atlas test owner for current source behavior. |
| Source Atlas runtime-boundary source/tests | 6 | Retain | Required by private graph / public reference egress boundary proof. |
| `Native/Ambitions/Resources/source-atlas-public-refresh-targets.json` | 1 | Retain | App-side public refresh registry resource; referenced by current app/container tests. |
| `tools/source-atlas/**` excluding `generated/**` | 381 | Retain for now | Active foundry/tooling, governance, frontier, gateway, fixture, and pytest surface used by CI and retained scripts. |
| `scripts/ambitions-remediation-governance-check.py` | 1 | Retain | Enforces Source Atlas growth allowlist and AMB-1658 remediation freeze. |
| `scripts/source-atlas-boundary-audit.py` | 1 | Retain | Current public/reference boundary audit. |
| `scripts/source-atlas-no-private-graph-egress-audit.py` | 1 | Retain | Current no-private-graph egress audit. |
| `docs/adr/ADR-2026-07-02-source-atlas-scope-freeze.md` | 1 | Retain | Current AMB-1680 / AMB-1725 scope-freeze authority. |
| `docs/platform/SOURCE_ATLAS_*` plus Apple atlas | 5 | Retain | Current platform/source-map support referenced by ADR/truth. |

## Review Before Delete

These groups are likely too large to keep permanently, but they need a bounded
deletion pass because some artifacts may still be active evidence for unresolved
R2, launch-floor, public-pack, or legal-review follow-ups.

| Area | Count | Evidence / risk | Deletion precondition |
|---|---:|---|---|
| `docs/qa/source-atlas/**` | 799 | QA artifacts are heavily train/date/current-status named. `761` paths match old train, date, LFF, or closeout naming; `101` paths match current/ledger/live/stable/legal/R2 markers. | Collapse into a current retained ledger set, then delete historical train packets no current issue, script, or truth file references. |
| `tools/source-atlas/generated/**` | 2,855 | Tracked generated outputs are the largest stale-risk set. Historical policy says generated state may exist for active validation but old proof is not current release proof. | Keep only generated outputs that a current proof packet, test fixture, or release evidence path requires; delete or regenerate the rest from retained tooling. |
| `tools/source-atlas/generated/r2-publisher/**` | 706 | Largest generated subtree; high duplication risk with R2 QA ledgers. | Verify no current R2 proof issue requires these exact files before deletion. |
| `tools/source-atlas/generated/pack-production/**` | 396 | Generated pack-production output; likely reproducible from foundry tooling. | Preserve only current pack fixtures required by tests or active QA ledgers. |
| `tools/source-atlas/generated/autonomous-production-supervisor/**` | 216 | Historical/autonomous production proof naming; production readiness is not release-proven. | Delete after any current owner-accepted production-risk summary is preserved in a retained ledger. |
| Launch-floor generated / QA artifacts | 115 generated, 37 QA | Current launch-floor work has active ledger/corpus history, so blind deletion could remove active coverage evidence. | Require a Source Atlas launch-floor owner pass that chooses the single current ledger/corpus set and deletes stale LFF train outputs. |

## Candidate Deletes

These are deletion candidates, not deletion proof. They should be handled in
small follow-up commits with validation after each batch.

1. Delete ignored local byproducts under `tools/source-atlas`.
   Evidence: `find tools/source-atlas -type f \( -name '*.pyc' -o -name '.DS_Store' \) | wc -l` returned `252`, and `git ls-files tools/source-atlas | rg '(__pycache__|\.pyc$|\.DS_Store$)'` returned no tracked paths. This is local cleanup only and does not affect AMB-1680 tracker completion.

2. Prune `tools/source-atlas/generated/**` to a current generated-proof allowlist.
   Evidence: `2,855` tracked generated files are present. Historical policy and release truth block treating old generated proof as current release proof. Top generated subtrees are `r2-publisher` (`706`), `pack-production` (`396`), `autonomous-production-supervisor` (`216`), `governed-harvest` (`94`), and `catalog-direct-source-approval-chain` (`94`).

3. Consolidate and delete stale `docs/qa/source-atlas/**` train packets after a current ledger is selected.
   Evidence: `799` tracked QA artifacts are present, including `761` old train/date/LFF/closeout-named paths. Many are useful historical evidence summaries, but they are not current release proof unless tied to current SHA/logs.

4. Review launch-floor artifacts separately before deletion.
   Evidence: launch-floor artifacts are both generated and QA-visible, and recent Source Atlas launch-floor proof work may still depend on a current ledger/corpus subset. These files should not be deleted in a broad cleanup batch.

5. Review old R2 production proof packets separately before deletion.
   Evidence: R2 production/readiness is explicitly not release-proven. Any retained R2 artifact must be current, public/reference-only, and legally/owner accepted if used for a release-facing claim.

## Residual Cleanup Follow-Ups

Recommended follow-up leaves under AMB-1680:

1. Source Atlas generated-output pruning: define a keep allowlist for `tools/source-atlas/generated/**`, delete unreferenced historical outputs, and rerun Source Atlas boundary audits plus Source Atlas Python tests.
2. Source Atlas QA packet consolidation: choose retained current ledgers under `docs/qa/source-atlas/**`, delete obsolete train/date packets, and rerun claim/release safety scans.
3. Source Atlas launch-floor retention pass: preserve the single current launch-floor ledger/corpus set, delete superseded LFF train outputs, and record the remaining proof ceiling.
4. Source Atlas R2 proof retention pass: preserve only current public/reference R2 proof artifacts and delete stale production-readiness packets that are not current evidence.

## Closeout Ceiling

AMB-1729 can close the inventory scope after this artifact is reviewed and
guards pass. AMB-1680 should not be marked Done from this inventory alone if the
project requires actual deletion of tracked stale files. The parent can move
only as far as the current evidence supports, with deletion follow-ups linked.

Unsupported claims:

- No tracked Source Atlas files were deleted in this pass.
- No production R2 behavior is proven.
- No privacy/legal approval is proven.
- No device, accessibility, TestFlight, App Store, or Release Green claim is made.
- No historical generated proof is promoted to current proof.
