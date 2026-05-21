# Cleanup Decision Register

Status: Yellow through 2026-05-16 Train D reference-dependency scan  
Date: 2026-05-16

## Authority

Active repo authority starts in `docs/truth/README.md`. Historical cleanup policy is `docs/truth/HISTORICAL_POLICY.md`. If this register conflicts with `docs/truth/*`, the truth files win.

Phase 11 reconciliation note, 2026-05-10: this register remains supporting cleanup context. For current repo map and stale/archive decisions, inspect `.codex/REPO_INVENTORY.md` and `docs/status/archive-and-stale-material-ledger.md` after `docs/truth/*`.

2026-05-15 direct GitHub API note: `docs/canon/SOURCE_OF_TRUTH_MAP.md` was repaired directly on `main` to route through `docs/truth/*`, restore `Today / Goals / Capture / Time / You`, and demote older Ambitions 2.0 / 3.0 / PXOS / ACUI material to historical or supporting status unless extracted into current truth.

2026-05-16 Train B note: historical/supporting headers were added directly on `main` to selected high-risk Ambitions 2.0, Ambitions 3.0, and PXOS files. Train B is Yellow, not Green, because several full-preservation updates were blocked by the connector safety layer and broad legacy-family coverage remains incomplete. Receipt: `docs/status/train-b-historical-header-quarantine-receipt-2026-05-16.md`.

2026-05-16 Train C note: active-surface hygiene/routing artifacts were added directly on `main`. Train C is Yellow, not Green, because scanners were installed but not run locally, no Swift patches were made without concrete evidence, and generated artifacts were classified but not moved/deleted. Receipt: `docs/status/train-c-active-surface-hygiene-receipt-2026-05-16.md`.

2026-05-16 Train D Phase 11 note: reference-dependency scan planning was refreshed and an archive/delete candidate register was created. Train D Phase 11 is Yellow, not Green, because connector search is not a full static link graph and no local `rg`/markdown-link scan was run. No archive moves and no deletions are approved. Receipt: `docs/status/train-d-reference-dependency-scan-receipt-2026-05-16.md`.

## Scope

Cleanup classification/status only. No Swift source changes, app implementation changes, app feature work, build/test/device validation, or release/readiness claims.

## Classification Legend

- Active: current authority or current source/proof owner.
- Supporting: useful operating, implementation, or traceability material that does not override truth files.
- Historical: retained for traceability, not current authority.
- Quarantine: retained but blocked from default use because it can cause drift.
- Deleted from active path: removed from active repo path; do not recreate without explicit approval.
- Deletion-candidate: candidate for a later approved extract/link-check/delete pass.

## Active

| Area | Decision | Reason |
| --- | --- | --- |
| `docs/truth/` | Active | Current authority layer for product/design, moat, implementation/source, release/proof, Codex process, and historical policy. |
| `README.md`, `docs/README.md`, `AGENTS.md` | Active front doors | Route through `docs/truth/*` first. |
| `frontend/README.md` | Active frontend portal | Routes to installed/intended frontend canon and locks `Today / Goals / Capture / Time / You`. |
| `.github/README.md` | Active GitHub automation policy | States no tracked hosted workflow should run on `push` by default; any restored workflow must be manual by default. |
| `docs/status/current-implementation-map.md` | Active supporting implementation map | Evidence-based implementation posture. |
| `docs/status/release-evidence-packet.md` | Active supporting release/proof posture | Release and validation non-claim boundary. |
| `docs/native-build-and-release.md` | Active supporting validation workflow | Local VM/Mac validation procedure. |
| live source, tests, `project.yml`, `Package.swift`, scripts, resources, entitlements, privacy manifest | Active implementation/proof surfaces | Do not classify for cleanup in docs-only passes. |

## Supporting

| Area | Decision | Rule |
| --- | --- | --- |
| `docs/canon/SOURCE_OF_TRUTH_MAP.md` | Supporting routing map | Subordinate to `docs/truth/*`; repaired 2026-05-15 to stop promoting older canon as active authority. |
| `docs/AmbitionsCanon/` | Supporting product/design canon | Use only where compatible with `docs/truth/*`. |
| `docs/codex/` | Supporting Codex process material | Operating support only; not product source truth or release proof. |
| `.codex/README.md` | Supporting Codex entry | Truth-first routing point. |
| `.codex/manifests/skills-routing-map.yml` | Supporting route map | Routing support; truth files win conflicts. |
| `.codex/skills/` | Supporting operating skill library | Active only as scoped support; builder skills remain candidate until selected by active batch. |
| `.codex/checklists/`, `.codex/operations/`, `.codex/playbooks/`, `.codex/templates/`, `.codex/validation/` | Supporting control-plane material | Keep for now; consolidate later if duplicate or stale. |
| Native subfolder `AGENTS.md` files | Supporting local contributor guidance | Must remain subordinate to root `AGENTS.md` and `docs/truth/*`. |
| generated-report classification and scanner scripts | Supporting cleanup/validation aids | Useful for local validation and cleanup planning only; not source proof. |
| archive/delete candidate register and reference-dependency plan | Supporting cleanup safety ledgers | Required before any archive/delete/move decision; not approval by themselves. |

## Historical

| Area | Decision | Rule |
| --- | --- | --- |
| `docs/canon/` old Ambitions 2.0 / 3.0 / 4.0 / PXOS / ACUI / SI material | Historical | Mine only for compatible durable decisions; not active authority. |
| `docs/audits/` | Historical/supporting evidence | Use for traceability, not current proof unless tied to current commit/logs. |
| `docs/handoff/` | Historical/supporting handoff trail | Use for traceability; extract durable decisions before archive/delete. |
| old batch-train reports and closeouts | Historical/process history | Batch Green does not prove current source or release readiness. |
| one-off prompts and old implementation plans | Historical | Candidate for extract-then-delete if no durable current value remains. |

## Deleted From Active Paths

| Area | Decision | Reason |
| --- | --- | --- |
| `.agents/skills/supabase/` | Deleted from active skills path | Hosted provider workflow is not active Ambitions core architecture. Do not recreate without explicit approval. |
| `.agents/skills/supabase-postgres-best-practices/` | Deleted from active skills path | External database/provider reference is not active Ambitions architecture. Do not recreate without explicit approval. |

## Quarantine

| Area | Decision | Reason |
| --- | --- | --- |
| provider/backend/cloud assumption docs | Quarantine | Must not imply active user-data backend, account sync, or provider architecture. |
| old release-readiness/App Store/TestFlight/device-proof reports without current proof | Quarantine | Release claims require current evidence. |
| stale context packs that revive old Plan/Profile/Captures/PXOS/ACUI language | Quarantine until reconciled | Can cause Codex drift. |
| active-looking docs that still promote `Plan` as a top-level destination | Quarantine until repaired | Current IA is `Today / Goals / Capture / Time / You`. |
| Train B connector-blocked old canon files | Quarantine until locally patched or archived | Full-preservation header updates were blocked by the connector safety layer; do not truncate these files. |
| generated artifacts under `build/reports/*` | Quarantine until generated-report classification/reference scan | Classification exists, but no generated reports are approved for deletion or release proof by default. |

## Deletion Candidates — No Deletion Approved Yet

| Area | Candidate Action | Required Before Deletion |
| --- | --- | --- |
| stale tracked-file inventories such as `docs/audits/tracked-files.txt` | Replace with generated/current inventory or archive minimal trace | Confirm no active links depend on it; extract current classification value; record rollback path. |
| obsolete one-off prompts | Extract durable decisions, then delete | Link search, useful-content extraction, owner approval. |
| duplicate closeout reports with no unique current value | Extract final decision, then archive/delete | Confirm no release/proof dependency. |
| duplicate `.codex` checklists/templates that restate truth files | Consolidate then delete duplicates | Map replacement authority and update links. |

## 2026-05-15 Direct GitHub API Audit Findings

| Finding | Classification | Direct action taken |
| --- | --- | --- |
| `README.md` correctly points to `docs/truth/README.md` as active authority. | Active | No change required. |
| `docs/truth/README.md` correctly establishes mandatory truth-first read order. | Active | No change required. |
| `frontend/README.md` correctly states current IA is `Today / Goals / Capture / Time / You` and Plan is compatibility-only. | Active | No change required. |
| `.github/README.md` states hosted GitHub Actions should not auto-run on `push` by default. | Active | No change required. |
| `docs/canon/SOURCE_OF_TRUTH_MAP.md` still promoted older canon and Plan-era ordering. | Supporting map with active drift | Repaired directly on `main` in commit `386185bd15d29151fa46262dfb9871af124b26c3`. |
| Search surfaced many `docs/canon/Ambitions_2_0*` and `docs/canon/Ambitions_3_0*` files. | Historical by policy | No deletion performed; extraction/quarantine pass required before movement. |
| Search surfaced `Native/Ambitions/Features/Plan/*`. | Needs inspection | No source change performed; may be internal compatibility naming or real active drift. |
| Search surfaced old `Hero Step Panel`, `Start Focus`, and `next best move` references. | Historical/compatibility drift; active-looking usage now classified in frontend docs | No blanket replacement; preserve as historical material unless a later source-backed rename pass is approved. |

## 2026-05-16 Train B Header Quarantine Findings

| Finding | Classification | Direct action taken |
| --- | --- | --- |
| Selected Ambitions 2.0 files physically received historical headers. | Partial historical quarantine | Patched `Ambitions_2_0_Codex_Execution_Guide.md`, `Ambitions_2_0_Master_Plan.md`, and `Ambitions_2_0_Product_Architecture.md`. |
| Selected Ambitions 3.0 files physically received historical/supporting headers and status demotions. | Partial historical quarantine | Patched `Ambitions_3_0_Copy_QA_Protocol.md`, `Ambitions_3_0_Privacy_Threat_Model.md`, and `Ambitions_3_0_Flake_Management_Protocol.md`. |
| Selected PXOS file physically received supporting historical header and status demotion. | Partial historical quarantine | Patched `PXOS_Empty_Edge_And_Degraded_States.md`. |
| Several large/blocked files could not be safely replaced through connector. | Connector-blocked quarantine | Do not truncate. Patch locally or via safer edit path. See Train B receipt. |
| ACUI direct family files were not confirmed. | Not found in direct family scan | Keep ACUI classified as historical/quarantine only if direct files are later found. |

## 2026-05-16 Train C Active Surface Hygiene Findings

| Finding | Classification | Direct action taken |
| --- | --- | --- |
| Generated report families lacked a clear classification owner. | Supporting cleanup gap | Created `docs/status/generated-report-classification.md`. |
| Visible-copy drift needed a local scanner. | Supporting validation gap | Created `scripts/ambitions-visible-copy-drift-scan.py`. |
| Repo authority and GitHub workflow policy needed local validation aids. | Supporting validation gap | Created `scripts/validate-repo-authority.sh` and `scripts/validate-github-workflow-policy.sh`. |
| Audit and prompt folders lacked clear routing front doors. | Supporting cleanup gap | Created `docs/audits/README.md` and `prompts/README.md`. |
| Historical Codex batch READMEs looked too active. | Historical/process drift | Demoted `docs/codex/batches/README.md` and `docs/codex/batch-trains/README.md`. |
| Direct Swift visible-copy searches did not prove a safe source patch target. | Needs local validation | No Swift source was changed. |
| Active frontend stale-language search did not prove a safe direct patch target. | Needs local validation | Issue #5 remains open pending local scanner/full sweep. |

## 2026-05-16 Train D Reference Dependency Findings

| Finding | Classification | Direct action taken |
| --- | --- | --- |
| Archive/delete candidates lacked a current Phase 11 candidate register. | Supporting cleanup gap | Created `docs/status/archive-delete-candidate-register.md`. |
| Reference-dependency plan still used older T06/T07 framing. | Supporting cleanup drift | Refreshed `docs/status/reference-dependency-scan-cleanup-plan.md` for Train D / Phase 11. |
| Representative old-canon and prompt files still have inbound references. | Destructive-action blocker | No archive moves or deletions approved. |
| Generated reports need regeneration/owner proof before cleanup. | Destructive-action blocker | No generated-report deletion approved. |
| Phase 12/13/14 require local/Antigravity reference scans and stubs. | Blocked pending local proof | Master tracker marks migration/cleanup phases blocked. |

## Hard Stops

Do not delete or move production Swift, tests, project config, package manifests, scripts, resources, entitlements, privacy manifests, current proof logs, or active truth files as part of docs cleanup.

Do not delete `.codex` or batch-train material opportunistically. Classify first, extract value, update links, get approval, then perform a dedicated cleanup pass.

## Next Recommended Direct Cleanup Step

Do not run archive migration through connector-only evidence. Run a local/Antigravity inbound-reference scan for one family at a time, starting with Ambitions 2.0. Prepare stubs, replacement authority, and rollback paths before Phase 12.
