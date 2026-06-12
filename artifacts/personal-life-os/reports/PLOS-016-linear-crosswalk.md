# PLOS-016 Linear Crosswalk

Status: Green for AMB-652 repo/Linear crosswalk scope; Yellow for unavailable Linear document creation and bounded repo-search logs
Linear issue: AMB-652
Parent issue: AMB-609
Program phase: PLOS-M01 live runtime truth map
Updated: 2026-06-12
Branch: main

## Closeout Header

- PLOS child closeout: yes
- Linear issue: AMB-652
- Parent issue: AMB-609
- Green/Yellow/Red status: Green for adjacent project, issue, and document classification; Yellow for unavailable Linear document creation in the current tool surface and bounded repo-search evidence.
- Pushed to main: pending at report creation
- Push hash: pending at report creation
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: no
- Linear identifiers used: AMB issue identifiers for Linear reads/writes/comments/status; PLOS labels are local labels only.
- Validation run: see Validation
- Red blockers: none
- Yellow limits: Linear document creation was not available through the exposed tools; repo search logs were bounded because generated artifacts inflated the raw logs; issue/project volume is classified by high-value adjacent control planes rather than exhaustively linking every archived issue.
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-652 commit, push, and Linear closeout, validate AMB-609 / PLOS-M01 parent acceptance gate only. Do not execute AMB-610 / PLOS-M02.

## Existing-First Evidence

Repo evidence:

- `artifacts/personal-life-os/validation/PLOS-016-linear-repo-crosswalk-search.txt`
- `artifacts/personal-life-os/validation/PLOS-016-linear-repo-crosswalk-search-adapted.txt`
- `artifacts/personal-life-os/validation/PLOS-016-linear-repo-crosswalk-search-stderr.txt`
- `artifacts/personal-life-os/validation/PLOS-016-linear-repo-crosswalk-search-exit-code.txt`
- `artifacts/personal-life-os/validation/PLOS-016-linear-repo-crosswalk-search-adapted-stderr.txt`
- `artifacts/personal-life-os/validation/PLOS-016-linear-repo-crosswalk-search-adapted-exit-code.txt`
- `artifacts/personal-life-os/validation/PLOS-016-repo-search-metadata.tsv`

The literal required repo search exited `2` because the repo has `Native/AmbitionsTests` instead of a top-level `tests` directory. The adapted search over `Native/AmbitionsTests` exited `0`.

The raw repo search logs were bounded before commit:

| Raw output | Bytes | Lines |
|---|---:|---:|
| Literal required repo search | 15,891,905 | 59,538 |
| Adapted repo search | 37,063,881 | 120,233 |

Linear searches performed:

- all-entity search for Ambitions, Source Atlas, AOR, AESP, AFRI, runtime, Step, proof, receipt, replay, trust, privacy, CloudKit, R2, TestFlight.
- project searches for Ambitions, Source Atlas, Runtime, Frontend, AOR, AESP, AFRI.
- issue search for AOR, AESP, AFRI, Packet, Source Atlas, runtime, proof, receipt, replay, trust, privacy, CloudKit, R2, TestFlight.
- targeted all-entity search for AOR, AESP, AFRI, Master Frontend Maturity Implementation Bundle, UIQL, Source Atlas, Runtime Laws.

## Existing Project Map

| Project | URL | Status | Relation to PLOS | Reason | Key docs/issues | Action |
|---|---|---|---|---|---|---|
| Ambitions Personal Life OS Runtime Master Build Program | https://linear.app/ambitionsos/project/ambitions-personal-life-os-runtime-master-build-program-a342b96a282c | In Progress | Active control plane | Superseding PLOS runtime program; AMB-609 owns M01. | AMB-608, AMB-609, AMB-610+, Runtime Laws document, Source Atlas Pack and Seed Release Contract references. | Continue only through PLOS phase order. |
| Ambitions Flagship UI Quality Lockdown | https://linear.app/ambitionsos/project/ambitions-flagship-ui-quality-lockdown-03b01184dce5 | Completed | Inherited UI proof, not runtime proof | Recent UIQL project contains shell proof, reconstruction, accessibility variant proof, and owner approval package artifacts. | AMB-956, AMB-957, AMB-958, AMB-968, AMB-969, AMB-970; UIQL docs. | Inherit UI proof with scope boundaries; do not execute UIQL in PLOS-M01. |
| Ambitions Active Runtime UI Reconstruction | https://linear.app/ambitionsos/project/ambitions-active-runtime-ui-reconstruction-9f0f0e0fc1d4 | Completed | Inherited/superseded by UIQL and PLOS maps | AOR established runtime path and reconstruction evidence but includes failure/supersession history. | AMB-523, AMB-525, AMB-526, AMB-528, AMB-531, AMB-538, AMB-553; AOR Operating Contract, AOR Runtime Path Template. | Inherit source-path and screenshot harness evidence through AMB-646/UIQL; stale AOR wording cannot override PLOS law. |
| Master Frontend Maturity Implementation Bundle | https://linear.app/ambitionsos/project/master-frontend-maturity-implementation-bundle-df1839eaf1b2 | Completed / trashed | Inherited frontend maturity evidence; superseded as control plane | Packet work is useful for UI maturity and TestFlight review boundaries, but PLOS is the active runtime control plane. | AMB-513, AMB-516, AMB-518, AMB-520, AMB-522. | Use as historical/supporting proof only; no TestFlight readiness claim. |
| Ambitions Flagship Runtime Integration | https://linear.app/ambitionsos/project/ambitions-flagship-runtime-integration-965b6583bb48 | Completed / trashed | Inherited runtime foundation; superseded control plane | AFRI contains source/runtime/release foundation evidence, but its project is archived/trashed and PLOS now owns future runtime phases. | AMB-353, AMB-369, AMB-382, AMB-389. | Inherit specific evidence where source-current; do not repeat from scratch unless PLOS phase requires. |
| Ambitions Flagship Elevation Program | https://linear.app/ambitionsos/project/ambitions-flagship-elevation-program-0ad175362612 | Completed / trashed | Inherited evidence; superseded control plane | AFEP adds proof/provenance/replay/sync/evidence packet work; useful for PLOS M02/M17/M23/M24/M26. | AMB-395, AMB-397, AMB-403, AMB-413, AMB-418. | Inherit as supporting evidence with freshness checks. |
| Ambitions Experience Sovereignty Program | https://linear.app/ambitionsos/project/ambitions-experience-sovereignty-program-cffd546904bb | Canceled / trashed | Superseded/irrelevant except historical context | Canceled post-AFRI/AFEP frontend program; should not guide PLOS execution. | No active PLOS dependency found. | Do not use as current authority. |
| Ambitions Flagship IA Migration - Motion + Global Capture | https://linear.app/ambitionsos/project/ambitions-flagship-ia-migration-motion-global-capture-eddcb2665415 | Canceled / trashed | Superseded | Canon migrated into current truth/PLOS/UIQL; old Capture/Pulse language is stale unless mapped by AMB-650. | Motion/global Capture lineage. | Historical only. |
| Ambitions Experience Kernel Integration | https://linear.app/ambitionsos/project/ambitions-experience-kernel-integration-d0a898cba7b5 | Canceled / trashed | Superseded/irrelevant | Older kernel integration project pre-dates current PLOS and truth hierarchy. | None required for PLOS-M01. | Do not use as active control plane. |
| Time Runtime 001 - LifeShape Field as Visual Runtime | https://linear.app/ambitionsos/project/time-runtime-001-lifeshape-field-as-visual-runtime-89c805fecc0c | Canceled / trashed | Superseded | Canceled because Time runtime work belongs under repo truth/manifest/PLOS, not a standalone project. | Time runtime context. | Historical only. |

## Issue Inheritance Map

| Issue | Title | Project | Status | Evidence artifacts / relation | PLOS phase affected | Use in PLOS | Risk |
|---|---|---|---|---|---|---|---|
| AMB-646 | PLOS-010 - Produce active app runtime path proof | PLOS | Done | `PLOS-010-active-runtime-path-proof.md` | M01/M10+ | Active runtime path source proof. | Do not treat as build/run proof. |
| AMB-647 | PLOS-011 - Produce Source Atlas Factory runtime map | PLOS | Done | Source Atlas runtime map and classification. | M01/M04-M06 | Source Atlas existing-first map. | Do not treat tests/fixtures as production Factory. |
| AMB-648 | PLOS-012 - Produce surface ownership map | PLOS | Done | Surface ownership map. | M01/M10/M17 | Surface owner and drift map. | Capture must remain global/support route. |
| AMB-649 | PLOS-013 - Produce runtime model ownership map | PLOS | Done | Runtime model ownership map. | M01/M02+ | Model owner map. | Missing/future PLOS objects stay phase-owned. |
| AMB-650 | PLOS-014 - Produce stale artifact and duplicate map | PLOS | Done | Stale/duplicate map. | M01 | Prevent stale IA and duplicate drift. | Cleanup not authorized. |
| AMB-651 | PLOS-015 - Classify production vs fixture/test/script artifacts | PLOS | Done | Production/fixture/test/script classification. | M01 | Prevent fixture/source confusion. | Raw-log bounding is Yellow. |
| AMB-525 | AOR-001 - Prove active runtime path | AOR | Done | AOR runtime path proof lineage. | M01 | Inherited via AMB-646 and UIQL. | AOR proof can be stale; current source proof wins. |
| AMB-956 | UIQL-001 - AOR Failure Postmortem + Supersession | UIQL | Done | AOR failure/supersession map. | M01/M26 | Explains why AOR is inherited with limits. | Do not use AOR as active UI quality approval. |
| AMB-958 | UIQL-003 - Runtime Shell Proof Refresh | UIQL | Done | Shell proof refresh. | M01/M26 | Supporting shell evidence only. | UIQL is not PLOS runtime implementation. |
| AMB-968 | UIQL-013 - Accessibility Variant Proof Pass | UIQL | Done | UI accessibility variant proof. | M26 | Future certification input. | No accessibility certification claimed by PLOS-M01. |
| AMB-969 | UIQL-014 - Final Owner Approval Package | UIQL | Done | UIQL owner package. | M26 / owner review | Supporting UIQL closeout context. | Not PLOS runtime owner approval. |
| AMB-970 | UIQL-013.5 - Independent Red-Team Visual Audit | UIQL | Done | Independent visual audit. | M26 | Future UI proof input. | Screenshot paths still need inspection. |
| AMB-369 | AFRI-017 - Same-intent/different-context runtime proof harness | AFRI | Done / archived | Moat runtime proof harness. | M10/M26 | Reusable concept/test evidence if source-current. | Archived issue cannot override PLOS gates. |
| AMB-382 | AFRI-030 - Optional CloudKit continuity decision gate | AFRI | Done / archived | CloudKit continuity gate. | M02/M23 | Reusable decision history. | No current CloudKit implementation claim. |
| AMB-389 | AFRI-037 - Device-truth release candidate packet | AFRI | Done / archived | Release/device proof packet. | M25/M26 | Future release proof reference. | No release/TestFlight readiness claim. |
| AMB-397 | AFEP-003 - Versioned Runtime Snapshot Ledger | AFEP | Done / archived | Runtime snapshot/provenance. | M02/M17/M24 | Reusable model/proof history if source-current. | Archived project evidence must be revalidated. |
| AMB-403 | AFEP-009 - Execution Ledger and Replay Browser | AFEP | Done / archived | Execution/replay proof lineage. | M17/M24 | Reusable receipt/replay history. | Do not claim active UI path without source proof. |
| AMB-413 | AFEP-019 - Local-First Sync Implementation | AFEP | Done / archived | Local-first sync history. | M23 | Reusable sync boundary context. | No current sync Green. |
| AMB-418 | AFEP-024 - Evidence Packet Automation | AFEP | Done / archived | Evidence packet automation. | M24/M26 | Reusable proof format history. | PLOS proof ledger is current authority. |
| AMB-520 | Packet 12 - Screenshot / QA / proof packet | Frontend maturity | Done / archived | Screenshot/QA proof context. | M26/UIQL | Supporting UI proof context. | No visual approval from path alone. |
| AMB-522 | Packet 14 - Internal TestFlight readiness review packet | Frontend maturity | Done / archived | TestFlight review packet. | M25/M26 | Historical release-boundary input. | No TestFlight readiness claim. |
| AMB-658 | PLOS-025 - Define R2 source-only boundary | PLOS M02 | Backlog | Future R2 boundary issue. | M02 | Active dependency after M01. | Do not execute in this run. |
| AMB-668 | PLOS-040 - Create R2 bucket/object layout spec | PLOS M04 | Backlog | Future R2 spec issue. | M04 | Blocked by M02/M03. | Do not execute in this run. |
| AMB-674 | PLOS-046 - Define Source Atlas freshness cadence | PLOS M04 | Backlog | Future Source Atlas freshness issue. | M04 | Blocked by M02/M03. | Do not execute in this run. |
| AMB-719 | PLOS-101 - Build golden R2 source/seed pack fixture and validation plan | PLOS M10 | Backlog | Future golden-slice fixture plan. | M10 | Blocked until M10. | Do not execute in this run. |

## Document Inheritance Map

| Document | Project | Status | Use in PLOS | Superseded by / conflict notes |
|---|---|---|---|---|
| Runtime Laws | PLOS | Active | Supporting runtime-law document found in Linear search. | Subordinate to repo truth and PLOS artifacts. |
| AOR Operating Contract | AOR | Historical/supporting | Explains AOR process and source-path proof lineage. | Superseded by PLOS GOAL/run-state/phase gates and UIQL supersession docs. |
| AOR Runtime Path Template | AOR | Historical/supporting | Useful format precedent for runtime path proof. | AMB-646 is current PLOS runtime path proof. |
| AOR Reviewer Checklist | AOR | Historical/supporting | Reviewer protocol lineage. | PLOS reviewer prompts and closeout validator are current. |
| AOR Remaining Issue Materialization Queue - Superseded | AOR/UIQL | Superseded | Explicit stale-queue marker. | Do not use as active execution queue. |
| AOR Final UI Quality Proof Standard | AOR | Historical/supporting | UI proof boundary precedent. | UIQL/M26 own current UI proof/certification. |
| UIQL Codex Execution Map | UIQL | Active/recent supporting | UIQL issue execution context. | Do not execute UIQL in PLOS-M01. |
| UIQL Global Run Contract | UIQL | Active/recent supporting | UI quality execution contract. | UIQL-only authority unless future PLOS phase imports it. |
| UIQL Primitive Freeze Policy | UIQL | Active/recent supporting | UI primitive protection context. | Not PLOS runtime implementation proof. |
| Source Atlas Pack and Seed Release Contract | PLOS referenced document | Supporting/future | Referenced by PLOS R2/Source Atlas children. | M04-M06/M10 must validate before use. |

## Dependency And Supersession Actions

- Do not reopen archived AFRI/AFEP/frontend/AOR issues unless a live PLOS phase finds an active Red blocker.
- Treat completed AOR/UIQL/frontend/AFRI/AFEP work as inherited evidence only after current source/proof freshness checks.
- Treat canceled/trashed projects as historical or superseded. They cannot drive active PLOS implementation.
- Linkage comments are useful only on high-value control issues. This AMB-652 closeout will add a supersession/inheritance note to `AMB-956` / UIQL-001 because it is the visible AOR supersession control issue. Broader project spam is intentionally avoided.
- The recommended Linear document `PLOS Linear Crosswalk - inherited, superseded, active, and blocked work` was not created because the current tool surface exposes issue/project comments and status updates but not document creation.

## M01 Parent Acceptance Rollup

M01 acceptance after AMB-652:

| Gate | Evidence | Status |
|---|---|---|
| Active app runtime path proven | AMB-646 / PLOS-010 | Green for mapping scope |
| Source Atlas assets mapped/classified | AMB-647 / PLOS-011 | Green for mapping scope; implementation future-owned |
| Surface ownership proven | AMB-648 / PLOS-012 | Green for mapping scope with Yellow ownership limits |
| Runtime model ownership mapped | AMB-649 / PLOS-013 | Green for mapping scope with future-owned gaps |
| Stale/duplicate/preview/fixture artifacts classified | AMB-650 / PLOS-014 | Green for mapping scope |
| Production vs fixture/test/script boundaries clear | AMB-651 / PLOS-015 | Green for classification scope; bounded-log Yellow |
| Existing Linear projects/issues/docs cross-linked | AMB-652 / PLOS-016 | Green for high-value crosswalk; Linear document unavailable Yellow |
| Unknowns have owner phase/follow-up | M01 reports and risk register | Green/Yellow by issue |
| No source-changing implementation before proof | Git commits scoped to reports/validation/PLOS artifacts | Green |
| Later issues can use M01 reports | M01 report set and proof ledger | Green for M01 map use, not runtime implementation |

## Validation

Commands run for AMB-652:

- `git status --short --branch --ahead-behind`
- `git pull --ff-only`
- Linear issue fetch for `AMB-652`
- Linear status update for `AMB-652` to In Progress
- literal required `rg -n "AMB-[0-9]+|AOR|AESP|AFRI|Packet|Linear|linear.app|project" docs prompts artifacts scripts Native Sources tests`
- adapted repo search with `Native/AmbitionsTests`
- Linear all-entity and project/issue searches for required terms

Closeout validation run before commit:

- `git diff --check`
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json`
- `scripts/codex/program-preflight.sh plos`
- `scripts/codex/program-phase-gate.sh plos M01`
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-016-linear-crosswalk.md`
- `bash scripts/codex/program-proof-index.sh plos`

Validation still to run after staging:

- `git diff --cached --check`

Not run:

- Build/test/screenshot/accessibility/performance validation was not run because AMB-652 is a read-only Linear/repo crosswalk child and no app source, project, UI, runtime, or test source files were changed. No runtime behavior, UI quality, release, accessibility, privacy/legal, or performance claim is made.

## Verdict

Green for AMB-652 scope: adjacent projects were searched and classified, inherited evidence is mapped, stale/superseded work is clearly separated, active blockers/future PLOS dependencies are identified, and the next issue/gate is AMB-609 parent acceptance only.

Yellow limits remain: Linear document creation was unavailable in the current tool surface, some archived issue volume is classified by representative high-value control planes rather than exhaustive per-issue linking, and repo search logs are bounded due generated artifact volume.

Red blockers: none.
