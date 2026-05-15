# Codex-Free GitHub API Audit — 2026-05-15

Status: Active supporting audit and direct-operation receipt  
Authority: Subordinate to `docs/truth/*`  
Scope: GitHub API audit, stale-canon classification, GitHub Actions policy inspection, direct main-branch cleanup receipt, and remaining follow-up queue  
Non-proof boundary: This document does not prove build success, tests passing, visual QA, accessibility conformance, device validation, TestFlight readiness, App Store readiness, or release readiness.

## Summary

This audit was performed directly through the GitHub API while Codex usage was unavailable. The objective was to advance Ambitions without Codex by repairing repo authority drift directly on `main`, not by creating a prompt queue or draft PR.

Direct main-branch changes completed:

| Commit | Path | Result |
|---|---|---|
| `386185bd15d29151fa46262dfb9871af124b26c3` | `docs/canon/SOURCE_OF_TRUTH_MAP.md` | Replaced stale source-truth ordering with truth-first routing and current `Today / Goals / Capture / Time / You` IA. |
| `872b619a872cfe50fe38b8b0b6b5c43510de041c` | `docs/status/cleanup-decision-register.md` | Recorded 2026-05-15 direct cleanup findings and next cleanup targets. |
| `3efb6e7fa2f430a5584c4853c24d4ddc80c8e251` | `docs/AmbitionsCanon/README.md` | Demoted AmbitionsCanon from source-truth posture to supporting canon pack. |
| `9620493ce4ce67e4acef497e6400fa32858a6385` | `Native/Ambitions/Features/Plan/PlanViewModel.swift` | Replaced isolated user-facing Plan error copy with Time copy. |
| `a435032bc9d68316bf8f4260178310fad21caa0f` | `Native/Ambitions/Features/Plan/PlanFoundationCards.swift` | Replaced isolated Plan pressure copy with Time/week copy. |
| `7aac76481c9ef6ad816a8c6113d31a8eaca4ba18` | `docs/canon/PLAN_CALENDAR_BELIEVABILITY.md` | Converted active Plan-era canon into supporting Time/calendar/believability compatibility canon. |

## Current Authority Classification

| Area | Classification | Rule |
|---|---|---|
| `docs/truth/*` | Active authority | Product/design, moat, implementation, release/proof, Codex process, and historical cleanup truth. |
| `README.md`, `docs/README.md` | Active front doors | Route readers through `docs/truth/*` first. |
| `frontend/README.md` | Active frontend portal | Current IA is `Today / Goals / Capture / Time / You`; Plan is compatibility-only. |
| `frontend/visual-encyclopedia/**` | Active/supporting frontend visual canon | Use after truth files; design canon only unless implementation proof exists. |
| `docs/AmbitionsCanon/**` | Supporting product/design canon | Useful material only where compatible with `docs/truth/*`; no longer source-truth package. |
| `docs/canon/SOURCE_OF_TRUTH_MAP.md` | Supporting routing map | Repaired to route through truth files; does not override them. |
| `docs/canon/PLAN_CALENDAR_BELIEVABILITY.md` | Supporting Time compatibility canon | Preserves calendar/believability rules without restoring Plan as top-level IA. |
| `docs/canon/Ambitions_2_0*`, `docs/canon/Ambitions_3_0*`, `docs/canon/Ambitions_4_0*` | Historical by default | Mine only for compatible durable decisions after extraction. |
| `docs/canon/PXOS_*`, `docs/canon/ACUI_*` | Historical/quarantine by default | Do not use as active authority unless compatible content is extracted into current truth/supporting docs. |
| `docs/audits/**` | Historical/supporting evidence | Traceability only unless tied to current commit/log proof. |
| `docs/handoff/**` | Historical/supporting handoff trail | Not active authority. |
| `.codex/**` | Supporting Codex control plane | Operate only after truth files; not product or release truth. |
| `Native/Ambitions/Features/Plan/**` | Needs continued inspection | Some naming is internal compatibility; user-facing Plan copy should be repaired narrowly or through a planned rename pass. |
| `.github/README.md` | Active GitHub automation policy | No hosted workflow should auto-run on push by default. |
| `.github/workflows/**` | Absent on main during audit | Contents endpoint returned 404 for `.github/workflows`. |

## Stale Canon Terms Searched

The GitHub API audit searched for the following high-risk terms and patterns:

```text
Ambitions_2_0
Ambitions_3_0
Today / Goals / Capture / Plan / You
Begin Focus
Start Focus
Recommended next step
next best move
Your best next move
external LLM
cloud LLM
chatbot
Hero Step Panel
Plan pressure
Unable to load Plan
```

## Findings

### Repaired immediately

- `docs/canon/SOURCE_OF_TRUTH_MAP.md` still promoted older source-truth ordering and Plan-era canon. It now routes through `docs/truth/*` and locks `Time`.
- `docs/AmbitionsCanon/README.md` called the folder a canonical source-truth package. It now says supporting canon pack, subordinate to truth files.
- `docs/canon/PLAN_CALENDAR_BELIEVABILITY.md` called itself an active canon consolidation layer and owned Plan/calendar/believability. It now preserves useful rules as Time compatibility canon.
- `Native/Ambitions/Features/Plan/PlanViewModel.swift` contained isolated user-facing Plan error copy. It now says Time.
- `Native/Ambitions/Features/Plan/PlanFoundationCards.swift` contained isolated user-facing Plan pressure copy. It now says Time pressure / this week.

### Left open intentionally

- Large-scale `Plan` symbol/folder/model renames were not attempted through the GitHub API. Those require local build/test validation.
- Old `Ambitions_2_0*`, `Ambitions_3_0*`, PXOS, ACUI, audit, and handoff files were not deleted. They require extract-then-delete or archive movement.
- Some stale-term hits are legitimate drift-scan rules, historical prompts, audit ledgers, or compatibility ledgers.
- `Native/Ambitions/Features/Plan/**` may contain internal compatibility names that should not be blindly changed without a build-backed migration.

## GitHub Actions / CI Inspection

Observed state:

- `.github/README.md` is present and says Ambitions does not use hosted GitHub Actions workflows as automatic validation on every commit.
- `.github/workflows` returned 404 through the GitHub contents endpoint during audit, indicating no tracked workflow directory on `main`.
- Existing workflow files found by search are examples under `docs/codex/workflow-templates/`, not active `.github/workflows` files.

Manual-only patch plan:

1. Keep `.github/workflows` absent unless a human-approved manual workflow is explicitly restored.
2. If a workflow is restored, it must use only:

```yaml
on:
  workflow_dispatch:
```

3. Do not add `push` or `pull_request` triggers without a policy change and audit note.
4. Do not use hosted CI logs as current release proof unless `docs/truth/RELEASE_TRUTH.md` and `.github/README.md` are updated first.
5. Continue to treat local VM/Mac validation, local Xcode/xcodebuild logs, simulator/device evidence, and current proof artifacts as the active validation path.

## GitHub Issues Created / Updated

Created during the audit:

| Issue | Status | Purpose |
|---|---|---|
| `#3` | Closed completed | Source truth map repair. Completed by direct main commits. |
| `#4` | Closed completed | Hosted workflow manual-only proof. Completed by inspection. |
| `#5` | Open | Visual encyclopedia stale-language sweep. |
| `#6` | Open | Private Life Runtime proof scenarios. |
| `#7` | Open | Historical quarantine / obsolete canon demotion. |

Note: Issue bodies may still mention runner commands because they were initially created before the operation switched fully to direct-main mode. Treat the actual direct-main commits and this audit as the current operational record.

## Remaining Direct Cleanup Queue

1. Audit active frontend authority files under `frontend/visual-encyclopedia/**` for stale visible language.
2. Add explicit historical/supporting headers to high-risk old canon files that remain linked from active paths.
3. Inspect `Native/Ambitions/Features/Plan/**` for user-visible Plan copy and patch only isolated strings that do not require type/folder renames.
4. Create a Private Life Runtime proof spec in docs, not a prompt, covering same intent, different users, different daily plans, local-only execution, closure/recovery adaptation, replay after relaunch, and inspectable Start Here receipts.
5. Do not delete or move large doc families until extraction and link checks are done.

## Red Lines

Do not claim any of the following from this audit:

- app builds
- tests pass
- Swift compile success
- accessibility conformance
- visual QA success
- device validation
- hosted CI success
- TestFlight readiness
- App Store readiness
- release readiness

This was a direct repo hygiene and authority repair pass only.
