# Global Batch Sequence

Status: Active single global batch train authority
Date: 2026-05-21
Scope: Repo-governance sequence truth, implementation/proof classification, next-run selection, and no-claim boundaries
Authority posture: Single Codex batch train authority after `docs/truth/*`, live source, current proof logs, and human release gates.

## Executive Status

Current repo sequence status: Yellow / single authority installed.

This document is now the single global batch train authority to read after `docs/truth/*`. It consolidates older global order overlays, current batch registry evidence, IOS26 flagship train manifest, installed prompts, audit artifacts, and commit evidence into one operational answer.

Codex runner selection rule:

- `IOS26-*` batches are the only runnable global train batches.
- Every non-`IOS26-*` batch ID is classified as `historical`.
- Historical batches preserve repository history, prompts, reports, and implementation evidence, but they must not be selected or executed by Codex global train runners.
- The machine-readable runner authority is `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`.

What is authoritative now:

- Product, implementation, release, Codex process, and historical authority still begin in `docs/truth/*`.
- Live source, project files, tests, scripts, and current proof artifacts remain stronger than plans or prompts.
- `.codex/state/active-batch.yml`, `.codex/reports/current-run-state.md`, and `.codex/reports/current-batch-train-state.md` are historical mirrors for non-IOS26 selection; they no longer select the next runnable Codex global batch when they point at non-`IOS26-*` work.
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml` and `docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md` govern the installed IOS26 flagship train, which is installed/not run and now includes `IOS26-T02-B00 Safe Area Root Invariant` before `IOS26-T02-B01`.
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json` remains useful historical data only. Its non-IOS26 rows are not runnable global train candidates.

What remains unproven:

- No release readiness, App Store readiness, TestFlight readiness, physical-device validation, public accessibility conformance, performance validation, legal/privacy approval, hosted CI proof, global completion, or fully validated IOS26 migration is proven by this document.
- IOS26 proof packet shape passed, but no IOS26 proof roots exist yet.
- `scripts/ambitions-codex-os-validate.py` failed in this audit; the failure is recorded under `build/reports/global-batch-sequence/`.

## Source-Of-Truth Hierarchy

Read in this order for sequence decisions:

1. `docs/truth/README.md` and the truth files it routes to.
2. Live source/project/test/script evidence.
3. Current validation/proof artifacts and current audit packet paths.
4. `.codex/state/active-batch.yml`.
5. `.codex/reports/current-run-state.md`.
6. `.codex/reports/current-batch-train-state.md`.
7. `docs/codex/GLOBAL_BATCH_SEQUENCE.md`.
8. `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`.
9. `docs/codex/BATCH_REGISTRY.md`.
10. `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
11. `docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md`.
12. `prompts/batches/` and `prompts/trains/`.
13. Commit history.
14. Historical/supporting overlays listed below.

Older supporting overlays now defer to this document for current sequence interpretation:

- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/AMB_GLOBAL_BATCH_TRAIN_SEQUENCE.md`
- `docs/codex/AMB_REMAINING_BATCH_REFERENCE.md`
- `docs/governance/FINAL_RECONCILED_BATCH_REGISTRY.md`
- `docs/governance/ACTIVE_EXECUTION_GRAPH.md`
- `docs/governance/REMAINING_WORK_GRAPH.md`

Those files are not deleted. They retain historical and supporting value, but they must not override this index, `docs/truth/*`, live source, or current proof.

## Commit-Derived Implementation Ledger

Audit basis:

- `build/reports/global-batch-sequence/git-log-reverse.tsv`
- `build/reports/global-batch-sequence/git-log-newest-first.tsv`
- `build/reports/global-batch-sequence/git-log-name-status.tsv`

The current audit saw 2,416 commits from `bafff3caa3f56f312522bc0f954b3167c38a82fb` (`Foundation`, 2026-04-11) through `21a32580ffccc69f3e752ec03ddc8063198c5e0b` (`Complete T18 final green report`, 2026-05-20).

Major implementation and governance waves:

| Era | Evidence | Classification | Notes |
| --- | --- | --- | --- |
| Foundation through native hardening | `bafff3caa3f...` through mid-April phase commits | Partially implemented | Native app and early product surfaces exist, but release/device/accessibility/performance claims are not proven by history alone. |
| Ambitions 2.0 / 3.0 / Product Depth history | Batch 40/83, PD, F-series, and 3.0 docs/implementation commits | Historical/supporting plus partially implemented source | Preserved as completed rebuild evidence and compatibility context. It does not override `docs/truth/*`. |
| Platform Kernel / PK | PK00-PK41 prompts, closeout reports, canonical queue, and commits such as `1a5b758d` through later PK41 evidence | Source-changing and proof-linked through PK41 in queue evidence, with mixed Green/Accepted Yellow | Earlier registry sections saying PK28 remains next are stale. Current queue evidence marks PK28-PK41 complete/do-not-run, while active state mirror now has no next recorded after EFC18 retirement. |
| Source Atlas / SA | SA07-SA32 prompts, closeout reports, and commits from May 2026 | Source-changing and docs/proof mixed | Current evidence indicates SA07-SA32 complete/do-not-run in canonical queue material; individual Yellow boundaries remain in closeouts. |
| EFC overlay | EFC01-EFC18 prompts and closeouts, including `65b90675...` | Docs/proof overlay, mostly absorbed/do-not-run | EFC is proof overlay coverage, not standalone product implementation unless an owner batch owns source changes. |
| Reset master / IOS26 install wave | `06f3f977...`, `ca798269...`, `0e86b1da...`, `10cceeff...` through `21a32580...` | Prompt/tooling/docs/source mixed | IOS26 train tooling and prompts are installed; reset train T04-T18 commits are recent source/docs work. IOS26 train itself remains installed/not run. |
| Current uncommitted slice before this document | `git-status-before.txt` in this audit | Docs/control-plane and audit output | Includes IOS26 `T02-B00` prompt insertion and this truth-indexing batch. Not implementation proof until committed and validated. |

## Current Authoritative Batch Sequence

### Historical Global Train Mirror

The pre-IOS26 global train mirror says:

- Current batch: `EFC18 Anti-Ceremony Compiler / Green`.
- Next eligible batch: none recorded in the mirror after CS02C-CS06C and CS09C retirement documentation.
- CS02C, CS03C, CS04C, CS05C, CS06C, and CS09C are retired metadata-only records and must not be selected as executable next batches.

Because the single authority now routes runnable work through the IOS26 flagship train, this document does not select PK28, PK29, CS02C, EFC, SA, PK, AOS, LDI, FCP, PFC, SI, DAV, PXOS, AMB, or other non-IOS26 rows as next global batches. They are historical unless a future human-approved batch creates a new scoped IOS26-compatible repair.

### IOS26 Flagship Train

The IOS26 flagship train is installed/not run and runner-required. The cold-start sequence is:

1. `IOS26-T00-B01` Repo source inventory
2. `IOS26-T00-B02` Validation baseline
3. `IOS26-T00-B03` Naming/API drift inventory
4. `IOS26-T01-B01` Toolchain confirmation
5. `IOS26-T01-B02` Deployment target bump
6. `IOS26-T01-B03` Availability compatibility cleanup
7. `IOS26-T02-B00` Safe Area Root Invariant
8. `IOS26-T02-B01` Native iOS 26 shell
9. `IOS26-T02-B02` Liquid Glass token layer
10. `IOS26-T02-B03` Icon and screenshot foundation
11. Continue through Train 03-16 as listed in `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml` and `docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md`.

Current runnable next batch:

```bash
scripts/ambitions-codex-train.sh IOS26-T00-B01 prompts/batches/IOS26-T00-B01-repo-source-inventory.md
```

Stop rules:

- Stop on Red.
- Continue on Yellow only with owner, safety reason, no-claim boundary, and post-batch gate.
- Never skip Train 0.
- Do not run source-changing IOS26 trains until Train 0 baseline artifacts exist.
- Do not run iOS 26 target bump until toolchain proof exists.

## Status Matrix

| Sequence position | Train/batch ID | Title | Status | Evidence files | Source-changing? | Proof artifact path | Next action | Claim boundary |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | Truth files | Active authority layer | Active | `docs/truth/*` | No direct app change | N/A | Read first | Truth does not prove implementation/release readiness. |
| 1 | Current source | Native app/source state | Implemented in source / unproven release | `Native/`, `Sources/`, `AppUI/`, `project.yml`, `Package.swift` | Yes | Current logs required per batch | Inspect before claiming | Source presence is not build/test/release proof. |
| 2 | Active global mirror | EFC18 closeout mirror | Historical docs/proof mirror | `.codex/state/active-batch.yml`, `.codex/reports/current-run-state.md`, `.codex/reports/current-batch-train-state.md` | No | `docs/audits/efc18-batch-closeout-report.md` | Preserve as history; do not select as runnable | No global completion claim. |
| 3 | PK00-PK41 | Platform Kernel | Historical; source-changing/proof mixed | `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`, `docs/audits/pk*-batch-closeout-report.md`, `.codex/state/global-train-attempt-ledger.md` | Yes for many PK rows | `docs/audits/pk*-batch-closeout-report.md` | Do not rerun as global train | PK does not prove backend completion, sync, migration, performance, or release readiness. |
| 4 | SA07-SA32 | Source Atlas | Historical; source-changing/proof mixed | `prompts/batches/SA*.md`, `docs/audits/sa*-batch-closeout-report.md` | Yes for many SA rows | `docs/audits/sa*-batch-closeout-report.md` | Do not rerun as global train | Source Atlas does not prove public source freshness or release readiness. |
| 5 | EFC01-EFC18 | Flagship proof closure overlay | Historical docs/proof overlay | `prompts/batches/EFC*.md`, `docs/audits/efc*-batch-closeout-report.md` | Usually no | `docs/audits/efc*-batch-closeout-report.md` | Preserve as owner-batch proof obligations | Overlay proof does not equal implementation proof. |
| 6 | IOS26-FLAGSHIP | iOS 26 flagship train | Installed as prompt/train/tooling; runnable forward sequence | `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`, `docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md`, `prompts/batches/IOS26-*.md`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json` | Not yet from train execution | `build/reports/ios26-*` when run | Run `IOS26-T00-B01` first | Installed prompt system is not migration proof. |
| 7 | IOS26-T02-B00 | Safe Area Root Invariant | Installed as prompt/train only | `prompts/batches/IOS26-T02-B00-safe-area-root-invariant.md` | Not yet | `build/reports/ios26-shell/safe-area-root-invariant.md` when run | Run only after Train 1 / T01-B03 is Green or accepted Yellow | No safe-area, screenshot, visual, device, or accessibility claim yet. |
| 8 | Reset master T00-T18 | Green flagship reset train | Historical; recent docs/source/proof mixed | `prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T*.md`, commits through `21a32580` | Mixed | Existing batch reports | Treat as evidence only where source/logs prove it | Does not prove global completion or release readiness. |
| 9 | Historical 2.0/3.0/4.0/PXOS/DAV/HPS/FCP/PFC/SI/AMB/DAV overlays | Older plans and completed waves | Historical/supporting/superseded where conflicts exist | `docs/canon/`, `docs/codex/`, `history/`, `prompts/batches/` | Mixed historical | Historical reports only | Do not select as runnable global train | Do not revive old IA, Plan tab, or readiness claims. |
| 10 | This batch | GLOBAL-BATCH-SEQUENCE-TRUTH-INDEX | Truth-indexing docs/audit batch | `docs/codex/GLOBAL_BATCH_SEQUENCE.md`, `build/reports/global-batch-sequence/` | No app source | `build/reports/global-batch-sequence/` | Commit/push when accepted | Does not implement app behavior. |

## Supersession And Quarantine

Historical for current sequence selection:

- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md` is a supporting historical overlay, not the singular current sequence.
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md` is a supporting historical optimization record.
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md` preserves historical numbering and old planned scope.
- `docs/codex/AMB_GLOBAL_BATCH_TRAIN_SEQUENCE.md` is supporting sequence context.
- `docs/codex/AMB_REMAINING_BATCH_REFERENCE.md` contains useful rows but has stale next-eligible language in places.
- `docs/governance/FINAL_RECONCILED_BATCH_REGISTRY.md`, `ACTIVE_EXECUTION_GRAPH.md`, and `REMAINING_WORK_GRAPH.md` are reconciliation evidence, not current singular authority.

Stale or conflicted sequence statements found:

- Some older governance files still say PK28 is next eligible even though later closeout evidence and canonical queue rows mark PK28-PK41 complete/do-not-run.
- `docs/codex/BATCH_REGISTRY.md` contains both stale PK28/PK29 next language and newer EFC18/no-next mirror language. This document resolves that conflict in favor of the live `.codex` mirrors plus current closeout evidence.
- CS02C-CS06C and CS09C are retired metadata-only records and must not be selected unless a new scoped repair batch is created.

No historical document was deleted in this pass.

## Next-Run Recommendation

The next runnable global batch is the first unrun IOS26 train batch:

```bash
scripts/ambitions-codex-train.sh IOS26-T00-B01 prompts/batches/IOS26-T00-B01-repo-source-inventory.md
```

Preconditions:

- Current worktree clean or explicitly classified.
- `docs/truth/*` read.
- `docs/codex/GLOBAL_BATCH_SEQUENCE.md` and `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json` read.
- IOS26 preflight passes.
- Train 0 baseline artifacts can be written under `build/reports/ios26-baseline/`.

Stop condition:

- Stop on Red.
- Stop if source-changing train would begin before Train 0 baseline artifacts exist.
- Stop if a Yellow lacks owner, safety reason, no-claim boundary, and post-batch gate.

Expected proof:

- Batch-local proof report under the relevant `build/reports/ios26-*` root.
- Raw command logs for any build/test/screenshot claims.
- Explicit no-claim boundaries for release, accessibility, device, performance, and App Store readiness.

## No-Claim Boundaries

This document does not claim:

- app build success
- unit/UI test success
- screenshot proof
- visual quality proof
- safe-area correctness
- public accessibility verification
- Dynamic Type / VoiceOver / Reduce Motion verification
- performance validation
- physical-device validation
- TestFlight readiness
- App Store readiness
- signed archive readiness
- privacy/legal approval
- hosted CI proof
- global train completion
- IOS26 migration completion

## Validation Appendix

Audit artifacts created:

- `build/reports/global-batch-sequence/git-status-before.txt`
- `build/reports/global-batch-sequence/git-log-reverse.tsv`
- `build/reports/global-batch-sequence/git-log-newest-first.tsv`
- `build/reports/global-batch-sequence/git-log-name-status.tsv`
- `build/reports/global-batch-sequence/codex-file-inventory.txt`
- `build/reports/global-batch-sequence/batch-train-keyword-scan.txt`
- `build/reports/global-batch-sequence/batch-train-keyword-scan.stderr`
- `build/reports/global-batch-sequence/ios26-flagship-preflight.txt`
- `build/reports/global-batch-sequence/ios26-flagship-preflight-after.txt`
- `build/reports/global-batch-sequence/ios26-flagship-proof-packet-check.txt`
- `build/reports/global-batch-sequence/ios26-flagship-proof-packet-check-after.txt`
- `build/reports/global-batch-sequence/ambitions-codex-os-validate.txt`
- `build/reports/global-batch-sequence/ambitions-codex-os-validate-rerun.txt`
- `build/reports/global-batch-sequence/ambitions-codex-os-validate.json`
- `build/reports/global-batch-sequence/forbidden-claim-scan.txt`
- `build/reports/global-batch-sequence/new-files-forbidden-claim-scan.txt`
- `build/reports/global-batch-sequence/runner-read-only-audit.txt`
- `build/reports/global-batch-sequence/runner-read-only-audit-after.txt`
- `build/reports/global-batch-sequence/ios26-flagship-preflight-final.txt`
- `build/reports/global-batch-sequence/ios26-flagship-proof-packet-check-final.txt`

Commands passed:

- `git status --short`
- `git log --reverse --date=iso-strict --pretty=format:'%H%x09%ad%x09%an%x09%s'`
- `git log --date=iso-strict --pretty=format:'%H%x09%ad%x09%an%x09%s'`
- `git log --reverse --name-status --date=iso-strict --pretty=format:'COMMIT%x09%H%x09%ad%x09%s'`
- `find docs/codex prompts/batches prompts/trains .codex -type f 2>/dev/null | sort`
- `rg -n "IOS26-|TRAIN_|AMB-|PK[0-9]+|SI[0-9]+|AUTO-|GLOBAL-|BATCH|Status:|installed_not_run|Green|Yellow|Red|superseded|quarantine|runner" docs prompts .codex scripts Makefile project.yml Package.swift`
- `python3 scripts/ios26-flagship-preflight.py`
- `python3 scripts/ios26-flagship-proof-packet-check.py`
- `READ_ONLY_AUDIT=1 AUTO_BRANCH=0 AUTO_COMMIT=0 AUTO_PUSH=0 scripts/ambitions-codex-train.sh GLOBAL-BATCH-SEQUENCE-TRUTH-INDEX prompts/inbox/GLOBAL-BATCH-SEQUENCE-TRUTH-INDEX-2026-05-21.md`
- `git diff --check`
- `scripts/codex-forbidden-claim-scan.sh docs/codex/GLOBAL_BATCH_SEQUENCE.md prompts/inbox/GLOBAL-BATCH-SEQUENCE-TRUTH-INDEX-2026-05-21.md prompts/batches/IOS26-T02-B00-safe-area-root-invariant.md`

Commands failed:

- `python3 scripts/ambitions-codex-os-validate.py`
- `python3 scripts/ambitions-codex-os-validate.py --report-path build/reports/global-batch-sequence/ambitions-codex-os-validate.json`
- `scripts/codex-forbidden-claim-scan.sh <touched docs/control-plane files>`

Failure summary:

- Codex OS validation status: Red.
- Hook compile checks failed for multiple `.codex/hooks/*.py` files.
- Execpolicy checks failed with JSON parse errors.
- The validator also classifies the new `build/reports/global-batch-sequence/` artifacts as disallowed report changes under its Codex OS scope.
- The broad forbidden-claim scan reported blocking hits in older touched supporting docs and truth files. The new `GLOBAL_BATCH_SEQUENCE.md` hit was context-only, and the blocking hits were retained as Yellow/Red evidence instead of being hidden.

Yellow/Red items:

- Yellow: Commit history and sequence overlays are large and contain stale next-eligible language; this document classifies the conflict rather than deleting historical material.
- Yellow: IOS26 proof roots are declared but not present.
- Red: Codex OS validator failed in current dirty/control-plane context.

Rollback:

- Revert `docs/codex/GLOBAL_BATCH_SEQUENCE.md`, the cross-link notes added in this pass, `prompts/inbox/GLOBAL-BATCH-SEQUENCE-TRUTH-INDEX-2026-05-21.md`, and `build/reports/global-batch-sequence/`.
- Keep unrelated source/history untouched.
