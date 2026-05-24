# AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01

Status: GREEN for Phase 02 proof-only closeout. No app source, project config, tests, runtime wiring, or deletion changed.

## Purpose

Plan quarantine, retirement, archive, and delete candidates after champion merge proof without deleting source in this batch.

## Truth and Evidence Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`
- `.codex/state/active-batch.yml`
- `docs/codex/POST_BATCH_GATE_REGISTRY.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/canonical-owner-map.yml`
- `docs/codex/concept-lock-registry.yml`
- `docs/audits/intelligence-consolidation/CANONICAL_OWNER_MAP.md`
- `docs/audits/intelligence-consolidation/CHAMPION_MERGE_QUEUE.md`
- `docs/audits/intelligence-consolidation/SUPERSESSION_LEDGER.md`
- `docs/audits/intelligence-consolidation/BEST_CODE_RESCUE_LEDGER.md`
- `docs/audits/intelligence-consolidation/SUPERSESSION_RETIREMENT_PLAN.md`
- `build/reports/intelligence-consolidation/champion-coverage-check.md`
- `build/reports/intelligence-consolidation/parallel-implementation-scan.md`
- Champion merge reports under `build/reports/intelligence-consolidation/champion-merge-*.md`

## Required Final Report Fields

| Field | Value |
| --- | --- |
| Status | GREEN for Phase 02 proof-only closeout; future quarantine/delete execution remains approval-gated. |
| Concept | Champion merge quarantine, retirement, archive, and delete planning. |
| Canonical owner before | Active owner map already resolves Today, Goals, Capture, Time, You, Runtime, Proof/Receipt/Replay, Persistence, External Surfaces, and Design System through `docs/codex/canonical-owner-map.yml`. |
| Canonical owner after | Unchanged. No owner map change is approved for Phase 02. |
| Competing implementations | Compatibility and historical references remain: `Native/Ambitions/Features/Plan`, Profile-era language in historical/control-plane material, preview-only references under `Sources/Previews/**`, package/widget metadata with legacy Plan/Profile labels, and stale active-label aliases such as `realityRail` / `lifeShapeMap` compatibility aliases. |
| Better fragments rescued | Already recorded by prior champion reports: Today source/reason/receipt/proof/replay labels; Capture routing and replay destination dedupe; Runtime local rejection-learning influence; Proof/Receipt/Replay bridge facts; Time/Plan compatibility owner; You inspection/reset-delete/trust controls; Design System shared `TagPill` and active motion-object names; Persistence/external-surface portable receipt/tombstone history and canonical Time fallback. |
| Active code changed | None in this proof-only batch. Phase 02 approved boundary is proof/report only unless owner explicitly widens scope. |
| Runtime wires | No runtime wires changed. Existing runtime wire status is inherited from prior champion reports and remains bounded by their Yellow/Green proof status. |
| SourceRecord | No SourceRecord model change. Quarantine planning must preserve SourceRecord paths and may only classify stale references. |
| Receipt | No receipt model change. Quarantine planning must preserve canonical receipt history and proof ledger paths. |
| ReplayTrace | No ReplayTrace model change. Quarantine planning must preserve canonical replay trace and inspection paths. |
| You inspection | No You surface change. Planning records that Profile-era language is quarantine/archive-candidate only where historical/control-plane classification allows it. |
| Reset/delete | No reset/delete behavior change. Any future delete requires owner approval, extract-then-delete proof, and rollback path. |
| Tests run | `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01`; `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01 --prompt prompts/batches/champion-merge/AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01.md`. |
| Proof artifact | `build/reports/intelligence-consolidation/champion-merge-quarantine-plan.md`. |
| Supersession ledger update | Not approved in Phase 02. Existing ledger reviewed. Phase 02 may only append quarantine-plan notes if owner explicitly requires ledger updates. |
| Best-code rescue ledger update | Not approved in Phase 02. Existing ledger reviewed; it already records rescued fragments and remaining review boundaries. |
| Concept lock update | Not approved in Phase 02. Existing concept-lock registry reviewed. |
| Duplicates remaining | See "Duplicates Safe To Quarantine Later" below. No duplicate is approved for deletion in this batch. |
| Retirement candidates | See "Retirement Candidates" below. |
| Yellow/Red items | Yellow: future cleanup requires owner approval, source/reference verification, and successful guard validation. Red: deleting source, tests, ledgers, or historical material without extract-then-delete approval. |
| Claims allowed | This phase may claim a proof-backed quarantine plan exists and that pre-guard/champion coverage are Green. |
| Claims forbidden | No app behavior changed; no source deletion; no build/test/release/accessibility/privacy/performance/device proof; no claim that all duplicates are removed or unused. |

## Duplicates Safe To Quarantine Later

These are candidates for a future cleanup batch only. They are not approved for deletion here.

| Candidate | Classification | Required checks before quarantine | Safe next action |
| --- | --- | --- | --- |
| `Sources/Previews/**` Today / Reality Meridian / Start Here preview-only references | supporting/reference-candidate | Confirm no app target membership; extract any stronger visual/accessibility fixtures into canonical Today owners; run Today guard and relevant wrapper tests. | Quarantine as historical/reference only after extraction. |
| `Native/Ambitions/Features/Plan` | active compatibility seam | Confirm Time owns active user-facing surface; preserve required compatibility routes/tests; owner approval required before move/archive/delete. | Keep active compatibility; do not quarantine yet. |
| Profile-era wording in historical/control-plane files | historical/archive-candidate | Confirm each occurrence is not active user-facing copy or source identifier; preserve compatibility notes where needed. | Add historical header or archive under policy in a docs-only cleanup pass. |
| Design motion compatibility aliases `realityRail` / `lifeShapeMap` | active compatibility aliases | Confirm all active callers have migrated to `realityMeridian` / `lifeShapeField`; run design-system focused tests when simulator/Xcode is healthy. | Keep until caller migration is proven. |
| Widget/package-local Plan/Profile metadata labels in `AppUI/Sources/**` | package/supporting-candidate | Confirm external surface fallbacks already route to canonical Time/You labels; run external-surface wrapper tests. | Quarantine only stale metadata comments or historical docs, not package code, without proof. |
| Historical Today hero/rail references | historical/archive-candidate | Confirm no live source dependency and no unique accessibility fixture remains unrescued. | Archive/demote under historical policy. |

## Docs And Prompts To Archive Later

Archive only after applying `docs/truth/HISTORICAL_POLICY.md` headers and link updates.

- Historical champion merge prompt files under `prompts/batches/champion-merge/` after the active merge train is fully closed and no runner needs them.
- Historical batch-train and old-canon docs that repeat completed champion merge source truth without adding current source/proof evidence.
- Historical Profile/Plan-era handoff or audit docs that conflict with Today / Goals / Capture / Time / You and are not needed as active compatibility references.
- Generated scan reports superseded by newer scan output, only when the newer report path is linked and no current proof packet references the old file.

## Delete Candidates Requiring Owner Approval

No delete is approved in this phase.

| Candidate | Why owner approval is required |
| --- | --- |
| Any Swift source under `Native/Ambitions/**`, `Sources/**`, or `AppUI/Sources/**` | Source deletion can remove active runtime, compatibility, preview, accessibility, package, widget, or test coverage. |
| Any tests under `Native/AmbitionsTests/**` or `Native/AmbitionsUITests/**` | Test deletion weakens proof and can hide compatibility regressions. |
| `docs/audits/intelligence-consolidation/*LEDGER*.md` and `docs/codex/*owner*` / `concept-lock-registry.yml` | These are active runner inputs for guard and owner decisions. |
| Current proof artifacts referenced by champion reports or `.codex/xcode-summaries/**` | Release/proof truth forbids treating old reports as disposable without replacement evidence and link updates. |
| `Native/Ambitions/Features/Plan` | Active Time compatibility seam; retirement requires a scoped migration batch, tests, and explicit owner approval. |

## Approved Phase 02 Boundary

Phase 02 may edit only:

- `build/reports/intelligence-consolidation/champion-merge-quarantine-plan.md`

Optional Phase 02 edits only if the owner explicitly asks for ledger synchronization:

- `docs/audits/intelligence-consolidation/SUPERSESSION_RETIREMENT_PLAN.md`

Forbidden files for Phase 02:

- `Native/Ambitions/**`
- `Sources/**`
- `AppUI/Sources/**`
- `project.yml`
- `Package.swift`
- `Ambitions.xcodeproj/**`
- `Native/AmbitionsTests/**`
- `Native/AmbitionsUITests/**`
- `docs/codex/canonical-owner-map.yml`
- `docs/codex/concept-lock-registry.yml`
- `docs/audits/intelligence-consolidation/SUPERSESSION_LEDGER.md`
- `docs/audits/intelligence-consolidation/BEST_CODE_RESCUE_LEDGER.md`
- `.swiftpm/**`
- `.codex/runs/**`

## Validation Commands For Phase 02

Run only docs/guard validation unless the owner widens scope:

```bash
python3 scripts/ambitions-champion-coverage-check.py --batch AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01
python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01 --prompt prompts/batches/champion-merge/AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01.md
git diff --check -- build/reports/intelligence-consolidation/champion-merge-quarantine-plan.md
```

If Phase 02 changes the optional retirement plan file, include it in `git diff --check` and rerun the pre guard.

## Rollback Plan

For this proof-only plan:

```bash
git restore -- build/reports/intelligence-consolidation/champion-merge-quarantine-plan.md
```

If the file is still untracked:

```bash
rm build/reports/intelligence-consolidation/champion-merge-quarantine-plan.md
```

If Phase 02 also changes the optional retirement plan:

```bash
git restore -- docs/audits/intelligence-consolidation/SUPERSESSION_RETIREMENT_PLAN.md
```

Do not roll back unrelated dirty work such as `.swiftpm/xcode/xcuserdata/devan.xcuserdatad/xcschemes/xcschememanagement.plist` or runner-generated guard reports unless the owner explicitly scopes them.

## GPT-5.4-mini Bounded Patch Handoff

You are implementing Phase 02 for `AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01`.

Scope:
- Update only `build/reports/intelligence-consolidation/champion-merge-quarantine-plan.md`.
- Do not edit app source, package source, tests, project config, ledgers, concept locks, or generated Xcode project files.
- Do not delete, move, or archive files.

Task:
- Preserve the proof-only quarantine plan.
- Ensure it lists duplicate/quarantine candidates, archive candidates, delete candidates requiring owner approval, validation commands, rollback command, and proof/claim boundaries.
- Keep all cleanup actions future-gated by `docs/truth/HISTORICAL_POLICY.md`.

Required validation:
- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01 --prompt prompts/batches/champion-merge/AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01.md`
- `git diff --check -- build/reports/intelligence-consolidation/champion-merge-quarantine-plan.md`

Stop Red if any source file needs deletion, any owner map/ledger mutation appears necessary, or the guard reports duplicate risks/runtime wiring gaps.

## Guard Fields

- Champion coverage status: GREEN
- Champion coverage report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- Parallel guard pre status: GREEN
- Parallel guard pre report: `build/reports/parallel-implementation-guard/AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01-pre.md`
- Parallel guard post status: not run in Phase 02 because no app source/runtime patch is approved
- Parallel guard post report: not applicable for Phase 02
- Canonical owner extended: none
- New implementation owners: none
- Canonical owner map changed: no
- Supersession ledger updated: no
- Best-code rescue checked: yes
- Runtime wiring gate: no runtime changes; pre guard reports no runtime wiring gaps
- Yellow accepted reason: future cleanup remains Yellow until owner-approved archive/delete pass runs
- Red blockers: none for Phase 02 proof-only closeout

## Repo Intelligence

- Repo intelligence status: NOT_AVAILABLE
- CodeGraph used: no
- CodeGraph evidence: `command -v codegraph`, `command -v cg`, and shallow `.codegraph` search found no available tool/artifact
- Semble used: no
- Semble evidence: `command -v semble` and shallow `.semble`/`semble*` search found no available tool/artifact
- Understand Anything used: no
- Advisory findings directly verified: all findings came from direct repo file reads, runner reports, guard output, and truth files
- Fallback behavior: direct `rg`, `sed`, guard scripts, and current repo reports
- Generated local tool artifacts staged: no

## Phase 02 Closeout

- Scope remained proof/report only. No source, owner-map, ledger, concept-lock, or runtime edits were made.
- Validation rerun in this phase stayed aligned with the approved proof boundary and produced no new red conditions.
- Existing unrelated dirty items remained untouched: `.swiftpm/xcode/xcuserdata/devan.xcuserdatad/xcschemes/xcschememanagement.plist` and runner-generated guard reports.
