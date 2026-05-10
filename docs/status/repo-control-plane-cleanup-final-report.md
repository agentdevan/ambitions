# Repo Control-Plane Cleanup Final Report

Status: Phase 7 Green with accepted Yellow items
Date: 2026-05-10
Scope: Phases 0, 0B, 1, 2, 3, 4, 5, 6, and 7 only

## Executive Status

Phase 0 completed after pulling the latest `origin/main` state.

Phase 0B completed as operating-system component discovery and family-level classification. Phase 1 created the consolidated Codex OS router at `.codex/OPERATING_SYSTEM.md`. Phase 2 created the consolidated senior-department registry at `.codex/DEPARTMENT_REGISTRY.md`. Phase 3 created skill governance at `.codex/SKILL_GOVERNANCE.md`. Phase 4 created batch train governance at `.codex/BATCH_TRAIN_REGISTRY.md`. Phase 5 created the cleaned global sequencing file at `.codex/GLOBAL_BATCH_TRAIN.md`. Phase 6 created the tooling and validation map at `.codex/TOOLING_AND_VALIDATION.md`. Phase 7 created the current session bootstrap at `.codex/SESSION_BOOTSTRAP.md`. Later cleanup phases were not started in this checkpoint.

Accepted Yellow items:

- The worktree was already dirty before this pass, including modified app/source files and untracked screenshot audit material. After explicit owner instruction, those uncommitted pre-existing worktree changes were removed before Phase 0B.
- `docs/audits/tracked-files.txt` still contains historical paths for deleted provider skills. Current status docs already record the provider deletion, so this is a stale inventory item for a later cleanup ledger pass.
- Large train/control-plane files exist and should be classified through existing override policy before any rewrite, move, archive, or delete action.
- The local Ambitions Repo MCP still reports an older source-truth stack that does not include `docs/truth/*`; MCP output was treated as a repo-derived aid, not authority.
- Active state files disagree on the next execution target: `.codex/state/active-batch.yml` and MCP output point to `PK14 Durable Command/Event Ledger`, while `.codex/reports/current-batch-train-state.md` also names `IR-01 Big Frontend Recovery Implementation` as the next recommended implementation pass before visible top-level feature expansion. This is classified as an active-state reconciliation item for Phase 5, not resolved in Phase 0B.
- Phase 4 classified large train families from current registries, ledgers, state files, and headers rather than full line-review of every train prompt.
- Phase 5 reconciled the next-action tension by keeping `PK14` as the next non-UI platform batch and `IR-01` as the UI recovery prerequisite before visible top-level expansion.

## Pull / Repo State

- Branch: `main`
- Starting HEAD: `d21f9dfc1eac2a2f907c15359e5cae14055696d0`
- Updated HEAD: `3b8fdc3d38a5cdce3001c8d6f1af9f2b5b317128`
- Upstream status after pull: `0 0` for `HEAD...origin/main`
- Pull result: fast-forward from `origin/main`
- Working tree after pull: dirty from pre-existing app/source changes and untracked audit/report paths
- Worktree cleanup after owner instruction: removed uncommitted pre-existing app/source modifications and `docs/audits/screenshots/`

Pre-existing dirty paths observed during Phase 0 and removed before Phase 0B after owner instruction:

- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/Ambitions/Features/Captures/CaptureAtmosphereComposer.swift`
- `Native/Ambitions/Features/Captures/CapturesScreen.swift`
- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/Ambitions/Features/Plan/PlanScreen.swift`
- `Native/Ambitions/Features/Profile/ProfileRootSurface.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Sources/Components/PersonalSystemCenterPrimitives.swift`
- `docs/audits/screenshots/`

Post-cleanup worktree state:

- Clean except for local commits ahead of `origin/main`.

## Mandatory Read-Order Files

All required Phase 0 read-order files exist in the post-pull checkout:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `README.md`
- `docs/README.md`
- `AGENTS.md`
- `.codex/README.md`
- `docs/codex/CODEX_OS_INDEX.md`
- `docs/status/current-implementation-map.md`
- `docs/status/release-evidence-packet.md`
- `docs/status/cleanup-decision-register.md`
- `docs/status/codex-agents-skill-inventory.md`
- `docs/status/reference-dependency-scan-cleanup-plan.md`
- `docs/status/quarantine-archive-folder-plan.md`
- `docs/status/large-doc-classification-overrides.md`
- `docs/status/historical-header-pass-audit.md`
- `.codex/manifests/skills-routing-map.yml`

## Front Door Check

Checked:

- `README.md`
- `docs/README.md`
- `AGENTS.md`
- `.codex/README.md`
- `docs/codex/CODEX_OS_INDEX.md`

Finding:

- These front doors exist.
- They route active authority to `docs/truth/README.md` and the truth files.
- They state that they are not implementation proof, validation proof, or release proof.
- They preserve `docs/truth/*` as the conflict winner.

Phase 0 front-door gate: Green.

## Provider / Backend Preflight

Active provider skill path checks:

- `.agents/skills/supabase/`: absent
- `.agents/skills/supabase-postgres-best-practices/`: absent
- `scripts/t07c-provider-skill-quarantine-move.sh`: absent

Stale provider inventory check:

- `docs/audits/tracked-files.txt` still lists deleted provider skill paths.
- `docs/status/cleanup-decision-register.md` records `.agents/skills/supabase/` and `.agents/skills/supabase-postgres-best-practices/` as deleted from active skill paths.
- `docs/status/codex-agents-skill-inventory.md` records the same provider deletion and says not to recreate without explicit approval.
- `.codex/manifests/skills-routing-map.yml` lists both provider roots as forbidden skill roots.

Provider/backend gate: Green for active path deletion, Yellow for stale historical inventory cleanup.

## Batch Train / Train-State Visibility

Visible active state and current-run files include:

- `.codex/state/active-batch.yml`
- `.codex/state/active-repair.yml`
- `.codex/state/hard-red-ledger.md`
- `.codex/state/yellow-ledger.md`
- `.codex/state/repair-ledger.md`
- `.codex/reports/current-batch-train-state.md`
- `.codex/reports/current-run-state.md`

Ambitions Repo MCP reported:

- Current batch: `PK13 Restore Rollback`
- Next eligible batch: `PK14 Durable Command/Event Ledger`
- Previous batch: `PK12 Staged Portable Import Dry Run`
- Previous result: `Green`
- Train: `Global full-stack execution`
- EFC overlay active: true

MCP caveat:

- The MCP `get_source_truth_stack` output still names the older front-door stack and does not include `docs/truth/*`. Treat this as a tooling freshness gap for later cleanup, not as authority.

## Discovered Train Families

The `docs/codex/batch-trains/` directory contains visible train files for these families:

- AOS
- CQS
- CS
- DAV
- EB
- EFC
- F03.5
- F04-F30 family trains
- FCP
- FET
- FL
- HPS
- LDI
- ME
- PD
- PFC
- PK
- PX
- REC
- RHC
- SA
- SI
- SIG

Additional global/model/tooling train/control-plane files are visible under `docs/codex/`, `.codex/state/`, `.codex/reports/`, `.codex/manifests/`, `.codex/templates/`, `.codex/context-packs/`, `.codex/skills/`, `scripts/`, and `tools/mcp/`.

No train family was fully classified in Phase 0. That belongs to Phase 0B and Phase 4.

## Phase 0B Operating-System Component Discovery

Phase 0B classified Codex OS component families at the family/path level. It did not line-review every large file, batch prompt, skill, script, or historical report. Large files and long train registries remain subject to override-aware classification in later phases.

Codex OS mental model used:

```text
Authority + State + Skills + Trains + Gates + Tools + Evidence + Resume
```

### Component Family Classification

| Family | Active files | Supporting files | Historical / stale / obsolete findings | Replacement / target authority | Target artifact |
| --- | --- | --- | --- | --- | --- |
| Authority router | `docs/truth/*`, `README.md`, `docs/README.md`, `AGENTS.md`, `.codex/README.md`, `docs/codex/CODEX_OS_INDEX.md` | `docs/status/current-implementation-map.md`, `docs/status/release-evidence-packet.md`, `docs/native-build-and-release.md` | Older front-door references remain in historical docs and are subordinate | `docs/truth/README.md` and truth files | `.codex/OPERATING_SYSTEM.md`, `.codex/SESSION_BOOTSTRAP.md`, `.codex/REPO_INVENTORY.md` |
| Active state | `.codex/state/active-batch.yml`, `.codex/reports/current-batch-train-state.md`, `.codex/reports/current-run-state.md` | `.codex/state/recent-changes.md`, `.codex/state/recent-validation.md`, `.codex/state/proof-cache.json`, repair/yellow/hard-red ledgers | Next-batch tension between PK14 and IR-01/FET recovery language | Phase 5 global train reconciliation | `.codex/GLOBAL_BATCH_TRAIN.md`, `.codex/BATCH_TRAIN_REGISTRY.md` |
| Batch trains | `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`, EFC overlay files, `.codex/state/active-batch.yml`, current run/state reports | `docs/codex/BATCH_REGISTRY.md`, `docs/codex/batch-trains/*`, global queue ledgers, prompt files | Many originating trains and prompts are supporting or historical, not automatically active | Clean global train and registry | `.codex/GLOBAL_BATCH_TRAIN.md`, `.codex/BATCH_TRAIN_REGISTRY.md` |
| Skills and routing | `.codex/manifests/skills-routing-map.yml`, `.codex/skills/README.md`, active `.codex/skills/*` | `docs/status/codex-agents-skill-inventory.md` | Not every skill has been line-reviewed; provider skill roots are deleted but still referenced by stale inventories | Skill governance and metadata pass | `.codex/SKILL_GOVERNANCE.md`, `.codex/REPO_INVENTORY.md` |
| Model-tier policy | `docs/codex/MODEL_TIER_EXECUTION_POLICY.md`, `docs/codex/MODEL_TIER_BATCH_MATRIX.md`, `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`, resume docs | `AGENTS.md` model-tier sections | Older model references and prompt docs are supporting only | Truth-first model routing in bootstrap | `.codex/OPERATING_SYSTEM.md`, `.codex/SESSION_BOOTSTRAP.md` |
| MCP tooling | `tools/mcp/ambitions_repo_mcp`, `tools/mcp/ambitions_proof_mcp`, MCP setup/plans under `docs/codex/*MCP*` | visual/accessibility/source-atlas/release-truth/fixture MCP folders and plans | Repo MCP source-truth stack lags `docs/truth/*`; planned MCPs are not app dependencies | Tooling classification and MCP freshness repair | `.codex/TOOLING_AND_VALIDATION.md` |
| Validation scripts | `scripts/run-doc-qa.sh`, `scripts/build-local.sh`, `scripts/test-local.sh`, gate/scan scripts, validation manifests | `scripts/ai/*`, focused scan scripts by train family | Scripts vary in proof strength; running a script is not proof unless output is captured | Task-type validation map | `.codex/TOOLING_AND_VALIDATION.md` |
| Reports and closeout templates | `.codex/templates/*`, `.codex/reports/current-*`, docs report templates | `docs/codex/*REPORT*`, `docs/codex/*CLOSEOUT*`, handoff docs | Old prompt/report templates can impersonate current process if not routed | Bootstrap and template cleanup | `.codex/SESSION_BOOTSTRAP.md`, `.codex/OPERATING_SYSTEM.md` |
| GitHub / CI / infrastructure policy | `docs/codex/GITHUB_NATIVE_TOOLING_POLICY.md`, `docs/codex/workflow-templates/*.example` | `scripts/ci-local-parity.sh` | `.github/` is absent; hosted workflow templates are examples only | No hosted CI without approval | `.codex/TOOLING_AND_VALIDATION.md` |
| Dependency / security / privacy policy | `DEPENDENCY_RISK_LEDGER`, privacy/security gate docs, provider cleanup status docs | relevant skills and scripts | Provider/backend material remains forbidden unless explicitly approved | Dependency/security/privacy gates | `.codex/DEPARTMENT_REGISTRY.md`, `.codex/TOOLING_AND_VALIDATION.md` |
| Release / proof / claim firewalls | `docs/truth/RELEASE_TRUTH.md`, `docs/status/release-evidence-packet.md`, release-claim scan docs/scripts | release/handoff history | Old release/App Store/TestFlight docs are not current proof | Release evidence firewall | `.codex/OPERATING_SYSTEM.md`, `.codex/TOOLING_AND_VALIDATION.md` |
| Visual / accessibility / copy QA gates | FET/SI/SIG/PXEQ/Accessibility gate docs and scripts | visual/copy/accessibility skills | Some evidence docs are historical or advisory and do not prove public conformance | QA gate map | `.codex/DEPARTMENT_REGISTRY.md`, `.codex/TOOLING_AND_VALIDATION.md` |
| Nested AGENTS overlays | `AGENTS.md`, `docs/AGENTS.md`, `Native/Ambitions/App/AGENTS.md`, `Native/Ambitions/Domain/AGENTS.md`, `Native/Ambitions/Features/AGENTS.md` | none discovered beyond these | Native overlays are source-area guidance; not modified in this pass | Overlay map | `.codex/REPO_INVENTORY.md`, `.codex/SESSION_BOOTSTRAP.md` |
| Context packs | `.codex/context-packs/*`, `docs/codex/CONTEXT_INDEX.md` | route/context docs | Context packs are supporting, not truth; some old context references need stale prompt cleanup | Context classification | `.codex/REPO_INVENTORY.md`, `.codex/SESSION_BOOTSTRAP.md` |
| Prompt and resume templates | `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`, `RESUME_MINI`, `RESUME_SENIOR`, `.codex/templates/global-batch-resume-prompt.md` | many old batch prompt docs | Old copy/paste prompts are historical unless updated and truth-first | Current resume prompt template | `.codex/SESSION_BOOTSTRAP.md` |
| Archive / cleanup / historical policy | `docs/truth/HISTORICAL_POLICY.md`, cleanup/status docs | `docs/status/large-doc-classification-overrides.md`, cleanup plans | `docs/audits/tracked-files.txt` stale provider paths; many historical docs require inbound-reference checks | Archive/stale ledger | `docs/status/archive-and-stale-material-ledger.md` |

### Batch Train Families Discovered

Discovered train families remain classified at family level only:

| Family | Current Phase 0B classification |
| --- | --- |
| Global | Active sequencing/supporting authority, pending cleanup into `.codex/GLOBAL_BATCH_TRAIN.md`. |
| PK | Active/planned implementation train family; next active-state source points to PK14, but must reconcile IR-01 note. |
| EFC | Active proof overlay; not app behavior, release proof, or parallel feature train. |
| FET | Recently completed Codex/frontend quality-system gates; supporting gates, with IR-01 follow-up note. |
| AOS, LDI, SA, PFC, FCP, PD, SI, SIG, DAV, EB, PX, FL, HPS, CQS, CS, ME, REC, RHC, F03.5/F04-F30 | Supporting/planned/completed/historical mix; must be classified per train in Phase 4 before archive/delete decisions. |

### Tooling Discovery Notes

- `.github/` is absent.
- `docs/codex/workflow-templates/` contains example workflow files only.
- `tools/mcp/` contains repo, proof, release-truth, visual, accessibility, source-atlas, and fixture MCP folders.
- `scripts/` contains build/test scripts plus many local scan/gate scripts.
- No write-capable MCP expansion, hosted CI, dependency addition, or app-source validation was performed.

### Phase 0B Gate Result

Phase 0B result: Green with accepted Yellow items.

Green basis:

- Every required OS component family from the prompt was located at least at directory/file-family level.
- Each family has an active/supporting/historical/stale/delete-candidate direction.
- No app source, project, package, tests, resources, entitlements, or privacy manifests were modified.
- No archive/delete/move operation was performed.

Accepted Yellow basis:

- Large train registries and long prompt files were not fully line-reviewed.
- Active-state files need reconciliation before declaring one next batch.
- The Repo MCP source-truth-stack output lags the new truth hierarchy.
- Stale provider paths remain inside `docs/audits/tracked-files.txt`.
- Skill inventory is not a full line-review of every skill.

## Nested AGENTS Visibility

Visible `AGENTS.md` overlays:

- `AGENTS.md`
- `docs/AGENTS.md`
- `Native/Ambitions/App/AGENTS.md`
- `Native/Ambitions/Domain/AGENTS.md`
- `Native/Ambitions/Features/AGENTS.md`

No nested overlay was modified in Phase 0.

## Work Intentionally Not Done

Not run in Phase 0:

- Phase 0B operating-system component discovery
- Phase 1 Codex Operating System creation
- archive/delete/move operations
- app source edits
- SwiftUI redesign or runtime behavior changes
- `xcodegen generate`
- Xcode build/test
- source validation
- markdown/link checker
- docs QA script

Not run in Phase 0B:

- full per-file train classification
- full skill line-review
- archive/delete/move operations
- docs QA or link checking
- source/build/test validation
- MCP self-tests

Not run in Phase 4:

- archive/delete/move operations
- full line-review of every large train prompt
- inbound-reference checks for archive/delete candidates
- Phase 5 global batch train cleanup

## Validation Run

Commands/tools run:

- `git status --short --branch`
- `git rev-parse --abbrev-ref HEAD`
- `git rev-parse HEAD`
- `git fetch origin --prune`
- `git rev-list --left-right --count HEAD...origin/main`
- `git pull --ff-only`
- required-file existence checks
- front-door truth-routing search with `rg`
- provider path checks
- provider stale-reference checks in `docs/audits/tracked-files.txt`
- train/control-plane file listing with `find` and `rg`
- nested `AGENTS.md` discovery with `find`
- OS family discovery with `find` across `docs/truth`, `docs/status`, `docs/codex`, `.codex`, `tools/mcp`, `scripts`, and workflow-template paths
- model-tier / resume / validation / gate / tooling text searches with `rg`
- owner-directed worktree cleanup using `git restore` for pre-existing modified app/source files and `rm -rf docs/audits/screenshots`
- Ambitions Repo MCP: `get_source_truth_stack`
- Ambitions Repo MCP: `summarize_repo_posture`
- Ambitions Repo MCP: `get_efc_overlay_status`
- Ambitions Repo MCP: `get_active_batch`
- batch-train evidence search with `rg` across global queue, EFC overlay, current state, and batch registry files
- batch-train manifest listing with `find docs/codex/batch-trains`
- Ambitions Repo MCP: `check_efc_applicability` for Phase 4 changed files
- Ambitions Repo MCP: `changed_file_impact` for Phase 4 changed files
- Ambitions Repo MCP: `detect_forbidden_claims` for Phase 4 changed files; finding count was `0`
- `scripts/run-doc-qa.sh`; exit code `0`, with advisory stale-guidance, deprecated-language, markdownlint, and one redirect finding recorded under `docs/audits/doc-qa/20260510-004419-*`

## Validation Not Run

- Xcode build/test
- simulator validation
- archive validation
- MCP self-tests
- app accessibility/performance/privacy validation
- strict docs QA clean pass

## Hard Claims Not Made

This report does not claim:

- app implementation completion
- app build success
- test success
- release readiness
- TestFlight readiness
- App Store readiness
- physical-device validation
- accessibility conformance
- performance proof
- legal/privacy approval
- hosted CI proof

## Phase 0 Gate Result

Phase 0 result: Green with accepted Yellow items.

Green basis:

- Latest `origin/main` was pulled by fast-forward.
- Required truth files exist.
- Required front doors route to `docs/truth/*`.
- Current provider skill roots are absent from active `.agents/skills/` paths.
- Current cleanup/status docs record provider deletion.

Accepted Yellow basis:

- Dirty app/source files pre-existed and were not touched.
- Stale provider references remain in `docs/audits/tracked-files.txt`.
- Large control-plane/train files require later override-aware classification.
- MCP source-truth-stack output lags the new `docs/truth/*` hierarchy.

## Phase 0B Gate Result

Phase 0B result: Green with accepted Yellow items.

Green basis:

- Codex OS component families were discovered and classified.
- Active, supporting, historical/stale, and later-target-artifact roles were recorded.
- No source/runtime behavior was changed.
- No destructive archive/delete pass was attempted.

Accepted Yellow basis:

- Active state needs a later reconciliation decision between PK14 and IR-01/FET recovery guidance.
- Large files remain classified by family and existing override policy rather than full line-review.
- Provider deletion is complete in active paths, but stale inventory references remain.
- MCP source-truth-stack freshness needs later repair.

## Phase 1 Codex Operating System

Created:

- `.codex/OPERATING_SYSTEM.md`

Updated:

- `.codex/README.md`
- `docs/codex/CODEX_OS_INDEX.md`
- `docs/status/repo-control-plane-cleanup-final-report.md`

Phase 1 result: Green with accepted Yellow items carried forward.

Green basis:

- `.codex/OPERATING_SYSTEM.md` exists.
- It is explicitly subordinate to `docs/truth/*`.
- It routes rather than duplicates product/design canon.
- It includes mandatory read order, conflict precedence, task modes, autonomous/approval/forbidden rules, stop conditions, Red repair loop, Yellow rules, evidence hierarchy, no-claim firewall, destructive change gate, batch-train authority, model-tier policy, tooling handoff, session bootstrap handoff, repo inventory handoff, and a current resume prompt.
- `.codex/README.md` and `docs/codex/CODEX_OS_INDEX.md` now point to `.codex/OPERATING_SYSTEM.md`.

Accepted Yellow basis:

- Later target artifacts do not exist yet: `.codex/DEPARTMENT_REGISTRY.md`, `.codex/SKILL_GOVERNANCE.md`, `.codex/GLOBAL_BATCH_TRAIN.md`, `.codex/BATCH_TRAIN_REGISTRY.md`, `.codex/TOOLING_AND_VALIDATION.md`, `.codex/SESSION_BOOTSTRAP.md`, and `.codex/REPO_INVENTORY.md`.
- Active-state next-batch reconciliation remains deferred to Phase 5.
- Large train/control-plane files remain override-aware classification work.

## Phase 2 Department Registry

Created:

- `.codex/DEPARTMENT_REGISTRY.md`

Updated:

- `docs/status/repo-control-plane-cleanup-final-report.md`

Phase 2 result: Green with accepted Yellow items carried forward.

Green basis:

- One consolidated department registry exists.
- It includes department model, review board matrix, ownership map, file responsibility map, compatibility debt register, risk register, Yellow debt ledger, and cleanup rollback policy.
- It is explicitly subordinate to `docs/truth/*` and `.codex/OPERATING_SYSTEM.md`.
- It does not claim implementation, validation, release, device, accessibility, performance, legal/privacy, hosted CI, or App Store/TestFlight proof.

Accepted Yellow basis:

- Some ownership maps remain summary-level until `.codex/REPO_INVENTORY.md` and `.codex/BATCH_TRAIN_REGISTRY.md` exist.
- Yellow debt items are recorded but not retired in Phase 2.

## Phase 3 Skill Governance

Created:

- `.codex/SKILL_GOVERNANCE.md`

Updated:

- `docs/status/repo-control-plane-cleanup-final-report.md`

Phase 3 result: Green with accepted Yellow items carried forward.

Green basis:

- Skill governance exists.
- It includes classification model, metadata schema, current inventory summary, auto-load policy, explicit-batch-selection policy, must-not-use list, deleted provider skill record, line-review tracker, future metadata header pass plan, and future folder split plan.
- It explicitly says not every `.codex/skills` file has been line-reviewed.
- It keeps provider skills deleted from active paths and forbidden unless explicitly approved.

Accepted Yellow basis:

- Skill inventory remains summary-level.
- Full skill metadata headers are future work.
- No skills were moved or rewritten in Phase 3.
- Stale provider references remain in `docs/audits/tracked-files.txt`.

## Phase 4 Batch Train Registry

Created:

- `.codex/BATCH_TRAIN_REGISTRY.md`

Updated:

- `docs/status/repo-control-plane-cleanup-final-report.md`

Phase 4 result: Green with accepted Yellow items carried forward.

EFC applicability: invoked. The changed files are Codex governance and evidence-status docs, and the required proof families are release-claim boundary and continuation proof.

Green basis:

- Every discovered train family has a current registry classification.
- The registry is explicitly subordinate to `docs/truth/*` and `.codex/OPERATING_SYSTEM.md`.
- Originating trains are classified as active, planned, completed, supporting, historical, deferred, blocked, or do-not-rerun where current repo evidence supports that classification.
- The registry records that batch reports and train closeouts are not implementation or release proof by themselves.
- Ambitions Repo MCP forbidden-claim scan found `0` findings for `.codex/BATCH_TRAIN_REGISTRY.md` and `docs/status/repo-control-plane-cleanup-final-report.md`.
- `scripts/run-doc-qa.sh` completed with exit code `0`; broad advisory findings remain in existing docs and are not treated as Phase 4 release or implementation proof.
- No archive, move, delete, source edit, SwiftUI refactor, dependency addition, CI change, or app behavior mutation was performed.

Accepted Yellow basis:

- Large train files were classified from current registry/state/ledger/header evidence, not full line-review.
- Active next-batch reconciliation remains open: PK14 is the next non-UI platform batch, while IR-01 is a recommended UI recovery pass before visible top-level expansion.
- Archive/delete candidates were identified only as policy classes; no inbound-reference safety pass was run.

## Phase 5 Global Batch Train

Created:

- `.codex/GLOBAL_BATCH_TRAIN.md`

Updated:

- `docs/status/repo-control-plane-cleanup-final-report.md`

Phase 5 result: Green with accepted Yellow items carried forward.

Green basis:

- The cleaned global sequencing file exists and is subordinate to `docs/truth/*`.
- It distinguishes `PK14 Durable Command/Event Ledger` as the next non-UI platform batch from `IR-01 Big Frontend Recovery Implementation` as the prerequisite before visible top-level UI expansion.
- It records the global sequence, completed work ledger, planned work, deferred work, obsolete/superseded work, hard stops, and a Phase 6 resume prompt.
- It does not start implementation work or authorize app source changes in this cleanup pass.

Accepted Yellow basis:

- `PK14` and `IR-01` remain separate lanes to be selected by a future implementation prompt.
- Large legacy train files remain unmodified.
- Archive/delete candidates still require inbound-reference checks.

## Phase 6 Tooling And Validation

Created:

- `.codex/TOOLING_AND_VALIDATION.md`

Updated:

- `docs/status/repo-control-plane-cleanup-final-report.md`

Phase 6 result: Green with accepted Yellow items carried forward.

Green basis:

- MCP tooling, scripts, workflow-template posture, task-type validation, safe commands, dangerous commands, and evidence rules are classified.
- `.github/` remains absent; workflow templates are examples only.
- Tooling existence is explicitly not treated as proof.
- No scripts, MCP servers, workflows, dependencies, source files, or runtime files were modified.

Accepted Yellow basis:

- Some scripts are advisory/noisy by design.
- Repo MCP source-truth stack freshness remains a later repair item.
- Candidate MCPs remain classified, not proven production tools.

## Phase 7 Session Bootstrap

Created:

- `.codex/SESSION_BOOTSTRAP.md`
- `.codex/templates/current-resume-prompt.md`

Updated:

- `docs/status/repo-control-plane-cleanup-final-report.md`

Phase 7 result: Green with accepted Yellow items carried forward.

Green basis:

- A single current start/resume/recovery path exists.
- The bootstrap is truth-first and explicitly subordinate to `docs/truth/*`.
- It records model-tier rules, skill selection, old prompt policy, recovery policy, and a current resume prompt.
- It does not delete or move older prompts before the stale/archive ledger pass.

Accepted Yellow basis:

- Older prompt/resume docs remain in place and require stale-ledger classification before archive/move/delete decisions.
- `.codex/REPO_INVENTORY.md` does not exist until Phase 8.

## Next Exact Prompt

```text
Continue the Ambitions repo-control-plane cleanup with Phase 8 only.
Use the current repo state after Phase 7. Preserve docs/truth/* as the winning authority, do not implement app features, and create/update .codex/REPO_INVENTORY.md as a repo map and routing index, not product truth or proof.
Carry forward accepted Yellow items: large-file override-aware classification, stale provider inventory references, Repo MCP source-truth-stack freshness, summary-level ownership maps, unreviewed skill metadata, separate PK14/IR-01 next-action lanes, advisory/noisy scripts, candidate MCPs, old prompt classification, and archive/delete candidates requiring inbound-reference checks.
Do not continue to Phase 9 unless Phase 8 is Green or accepted Yellow with reason.
```
