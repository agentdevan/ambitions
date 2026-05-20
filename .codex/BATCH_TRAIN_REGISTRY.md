<!-- markdownlint-disable MD013 -->

# Codex Batch Train Registry

Status: Active Codex operating registry
Date updated: 2026-05-10
Branch at update: main
HEAD at update: 20c56b5d8f69baa9ad4918c7508d2602df9c1596

## Authority

This registry classifies batch trains for Codex operation. It is subordinate to:

1. `docs/truth/*`
2. `AGENTS.md`
3. `.codex/OPERATING_SYSTEM.md`
4. Current raw repo evidence

This registry is not product truth, implementation proof, release proof, build proof, test proof, accessibility proof, performance proof, device proof, legal/privacy approval, hosted CI proof, or App Store/TestFlight readiness.

Batch reports and train closeouts are historical/process evidence. They may show that a docs, tooling, or source-control batch closed, but they do not prove shipped product behavior unless current source/test evidence supports that claim.

## Discovery Sources

Inspected sources for this Phase 4 registry:

- `.codex/state/active-batch.yml`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
- `docs/codex/batch-trains/*.md`

Large train files were classified by header, registry excerpts, queue ledgers, current state files, and source routing evidence. They were not all line-reviewed end to end in Phase 4.

## Status Vocabulary

| Status | Meaning |
| --- | --- |
| Active | Currently governs the next Codex execution or active proof overlay. |
| Planned | Intended future work but not next. |
| Completed | Closed with process/source evidence named by current registries. Completion does not prove release readiness. |
| Superseded | Replaced by newer truth, global order, or a consolidated registry. |
| Obsolete | No longer useful as active guidance. |
| Deferred | Useful but not currently sequenced. |
| Blocked | Requires dependency, owner decision, missing evidence, or repair. |
| Archived | Retained for traceability only. |
| Deletion-candidate | Candidate only after inbound-reference, replacement-authority, rollback, and owner gates. |

No originating train is active merely because its file exists.

## Train Families Discovered

| Train family | Source files | Current status | Completed batches | Planned / active / blocked batches | Replacement authority | Evidence source | Archive/delete recommendation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Global | `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`, `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`, `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`, state/report files | Active with accepted Yellow | Global queue maturity pass complete; PK01-PK13 complete per current registries | PK14 is executable now in canonical queue; IR-01 is separately recommended before visible UI expansion | Future `.codex/GLOBAL_BATCH_TRAIN.md` | Global queue ledger, active-batch state, current-batch report | Keep active; consolidate in Phase 5 |
| PK | `docs/codex/batch-trains/PK00_PK41_PLATFORM_KERNEL_TRAIN.md`, global queue/order files | Active / planned | PK00 baseline complete; PK01-PK02 accepted Yellow; PK03-PK13 Green per registry | PK14 executable now; PK15-PK41 executable later in dependency order | Global train + PK manifest | Current batch state, batch registry, maturity ledger | Keep active; no archive/delete |
| EFC | `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`, `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`, EFC global overlay docs | Active proof overlay | EFC00 active insertion complete | EFC01-EFC18 absorbed as overlay unless no existing owner can produce proof | EFC overlay + global train | EFC overlay registry, Repo MCP status | Keep as overlay; do not run as parallel feature train |
| SA | `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md` | Planned / dependency-gated | SA01-SA06 and SAP01-SAP05 complete per registry | SA07-SA32 executable later after global prerequisites | Global train | Batch registry, maturity ledger | Keep supporting/planned |
| LDI | `docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md` | Mixed completed / planned / blocked | LDI01-LDI14 complete per registry | LDI15, LDI16, LDI20-LDI22 blocked until dependency; LDI17-LDI19 executable later | Global train | Batch registry, maturity ledger | Keep supporting/planned |
| AOS | `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md` | Mixed completed / blocked | AOS01 accepted Yellow; AOS02-AOS23 complete Green per registry | AOS24-AOS30 blocked until dependency | Global train | Batch registry, maturity ledger | Keep supporting/planned |
| FCP | `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md` | Mixed completed / planned | Earlier FCP batches recorded complete in batch registry | FCP27-FCP30 executable later | Global train | Batch registry, maturity ledger | Keep supporting/planned |
| PFC | `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md` | Mixed completed / planned | PFC01-PFC30 recorded complete or supporting in registry context | PFC31-PFC40 executable later | Global train | Batch registry, maturity ledger | Keep supporting/planned |
| RHC | `docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md` | Planned / late | None claimed in Phase 4 | RHC01-RHC06 executable later unless hygiene hard-blocks active work | Global train | Maturity ledger | Keep planned; do not run early without blocker |
| PX | `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md` | Completed / historical / do not rerun | PX01-PX20 completed as future-canon and roadmap evidence | None active | `docs/truth/*` + global train | Batch registry, maturity ledger | Keep historical; archive only after inbound-reference review |
| CS | `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md` | Completed with retired metadata records | CS01-CS10 completed/supporting per registry context; CS02C-CS06C and CS09C are retired metadata only | None active | Global train + implementation truth | Global queue maturity ledger | Keep supporting; do not select CS02C-CS06C or CS09C as executable work |
| CQS | `docs/codex/batch-trains/CQS01_CQS24_CODEX_QUALITY_SYSTEM_TRAIN.md` | Completed / supporting Codex OS | CQS train recorded as complete quality-system layer | No active next batch in Phase 4 | `.codex/OPERATING_SYSTEM.md`, tooling docs | Current state and registry context | Keep supporting |
| FET | `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md` | Completed / supporting gates | FET01-FET12 complete Green as Codex OS/frontend quality-system evidence | IR-01 recommended UI implementation pass before visible top-level expansion | Global train + FET gates | Batch registry, current state | Keep supporting; reconcile IR-01 in Phase 5 |
| PD | `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md` | Completed / supporting | PD01-PD18 complete; no release proof | None active | Product/design truth + implementation truth | Batch registry | Keep historical/supporting |
| SI | `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md` | Completed / supporting | SI01-SI18 complete/supporting per registry context | None active | `docs/truth/*`, implementation truth | Batch registry/current train state | Keep supporting |
| DAV | `docs/codex/batch-trains/DAV01_DAV15_DYNAMIC_ADAPTIVE_VISUAL_SYSTEM_TRAIN.md` | Completed / supporting | DAV01-DAV15 recorded complete/supporting in current registry context | None active | FET gates + implementation truth | Batch registry/current state | Keep supporting |
| EB | `docs/codex/batch-trains/EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN.md` | Completed / supporting | EB01-EB40 recorded as train closeout history | None active | `docs/truth/*`, implementation truth | Batch registry/current state | Keep historical/supporting |
| SIG | `docs/codex/batch-trains/SIG01_SIG16_SIGNATURE_EXPERIENCE_LAYER_TRAIN.md` | Deferred / planned | None claimed in Phase 4 | SIG01-SIG16 deferred until global prerequisites | Global train | Batch registry/manifest presence | Keep deferred |
| HPS | `docs/codex/batch-trains/HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN.md` | Completed / supporting | HPS01-HPS12 recorded as source-truth/quality layer | None active | `docs/truth/*`, global train | Batch registry/current state | Keep supporting |
| FL | `docs/codex/batch-trains/FL01_FL06_FOUND_LIFE_LAYER_TRAIN.md` | Completed / supporting | FL01-FL06 complete Green as product-soul/source-truth layer | None active | `docs/truth/*` | Batch registry/current state | Keep supporting |
| ME | `docs/codex/batch-trains/ME01_ME12_MAINTAINABILITY_EXTRACTION_TRAIN.md` | Completed / supporting | ME01-ME12 recorded complete/supporting | None active | Implementation truth + global train | Batch registry/current state | Keep supporting |
| REC | `docs/codex/batch-trains/REC01_REC06_RELEASE_EVIDENCE_CLOSURE_TRAIN.md` | Completed / supporting release evidence | REC01-REC06 recorded as release-evidence closure context | None active | `docs/truth/RELEASE_TRUTH.md`, `docs/status/release-evidence-packet.md` | Batch registry/current state | Keep supporting; no release claim by itself |
| F03.5 / F04-F30 | `docs/codex/batch-trains/F03_5_*.md`, `F04_F06_*.md`, `F07_F09_*.md`, `F10_F12_*.md`, `F13_F14_*.md`, `F15_F16_F16_5_*.md`, `F17_F30_*.md`, `F17_Shell_Meridian_Train.md` | Completed / historical Ambitions 3.0 evidence | F03.5 and F04-F30 family recorded complete/historical in repo context | None active | `docs/truth/*`, implementation truth, global train | Historical train files/current registry context | Keep historical; archive only after inbound-reference review |

## Completion Rules

- Completed docs batch does not prove app implementation.
- Completed implementation batch requires source/test evidence before any implementation claim.
- Completed release batch requires current release evidence before any release claim.
- Obsolete docs must not remain in active authority paths.
- Superseded train docs must point to the global train, a truth file, or an archive/stale ledger before any move/delete.
- Historical train completion does not authorize rerunning old prompts out of sequence.
- EFC completion is proof-layer completion only unless current source/test evidence says otherwise.

## Obsolete Train Policy

Classify before moving or deleting:

1. Search inbound references with `rg`.
2. Identify replacement authority.
3. Preserve traceability if the file records completed batch history.
4. Archive rather than delete when historical value remains.
5. Delete only when no current value remains and rollback is recorded.
6. Do not delete active truth, active front doors, active state, active global train, release evidence, implementation map, or source/runtime files.

## Current Planned Work Ledger

| Work | Originating train | Current registry status | Global sequence note |
| --- | --- | --- | --- |
| Durable command/event ledger | PK14 | Active candidate / executable now | Next non-UI platform batch according to active-batch state, EFC overlay, global queue ledger, and batch registry. |
| Big Frontend Recovery / IR-01 | FET follow-up | Yellow reconciliation item | Recommended before visible top-level UI expansion; not yet reconciled as the single next global batch. |
| PK15-PK41 platform kernel tail | PK | Planned / executable later | Runs serially after PK14 and dependency gates. |
| SA07-SA32 source atlas maturity tail | SA | Planned / executable later | Runs after global prerequisites and active PK dependency gates. |
| LDI17-LDI19 | LDI | Planned / executable later | Must obey source/freshness/privacy/dependency gates. |
| FCP27-FCP30 | FCP | Planned / executable later | Must inherit EFC and FET gates when relevant. |
| PFC31-PFC40 | PFC | Planned / executable later | Must inherit release/proof/no-claim gates. |
| RHC01-RHC06 | RHC | Planned late | Runs early only if repo hygiene creates a Hard Red for active work. |

## Completed Work Ledger

| Work | Proof type recorded here | No-claim boundary |
| --- | --- | --- |
| PK01-PK13 | Current registry/state evidence | Does not prove release readiness, device validation, or app completeness. |
| PX01-PX20 | Historical future-canon/roadmap completion evidence | Does not make PXOS active implementation authority. |
| FET01-FET12 | Codex OS/frontend quality-system completion evidence | Does not implement live UI recovery or prove accessibility conformance. |
| PD01-PD18 | Product-depth batch completion evidence | Does not prove runtime behavior unless source evidence supports it. |
| REC01-REC06 | Release-evidence closure context | Does not prove TestFlight, App Store, device, legal, privacy, or public accessibility readiness. |
| EFC00 | Proof-overlay insertion evidence | Does not replace product truth or global train sequencing. |

## Obsolete / Superseded Work Ledger

| Work | Classification | Preconditions before archive/delete |
| --- | --- | --- |
| PX01-PX20 active rerun prompts | Historical / do not rerun | Confirm inbound refs, preserve roadmap traceability, update archive/stale ledger. |
| Old F03.5/F04-F30 Ambitions 3.0 prompts | Historical/supporting | Confirm no active prompt path depends on them; archive rather than delete if traceability remains. |
| Originating train files superseded by global order | Supporting / superseded as active authority | Add explicit header or ledger classification before any movement. |
| Standalone EFC feature-train interpretation | Obsolete interpretation | Keep EFC as proof overlay only; do not delete overlay docs. |
| Stale provider-skill train references | Stale/obsolete | Cross-reference provider deletion records; do not recreate provider skills. |

## Active Next-Batch Reconciliation

Current evidence is reconciled:

- `.codex/state/active-batch.yml`, `docs/codex/BATCH_REGISTRY.md`, `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`, and `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md` point to `PK14 Durable Command/Event Ledger` as next eligible or executable now.
- `.codex/reports/current-batch-train-state.md` and `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md` also record `IR-01 Big Frontend Recovery Implementation` as the next recommended UI implementation pass before further visible top-level feature expansion.

Phase 5 resolved this by distinguishing lanes:

- next non-UI platform batch: `PK14`
- next UI recovery prerequisite before visible expansion: `IR-01`

## Archive/Delete Recommendation Summary

No move/delete action is authorized by this registry alone.

- Keep active: Global, PK, EFC overlay.
- Keep planned/supporting: SA, LDI, AOS, FCP, PFC, RHC, SIG.
- Keep completed/supporting: FET, PD, SI, DAV, EB, HPS, FL, ME, REC, CQS, CS.
- Keep historical/do-not-rerun until archive pass: PX, F03.5/F04-F30 family prompts.
- Deletion candidates: none approved in Phase 4.

## Phase 4 Gate Result

Phase 4 result: Green. Former Yellow items were resolved by later cleanup
passes.

EFC applicability: invoked. This registry changes Codex governance and evidence-status routing, so EFC proof obligations apply as release-claim boundary and continuation-proof checks. No release, implementation, accessibility, performance, device, hosted CI, legal/privacy, App Store, or TestFlight claims are made.

Green basis:

- Every discovered train family has a current classification.
- The registry is subordinate to `docs/truth/*` and `.codex/OPERATING_SYSTEM.md`.
- It does not claim implementation, release, accessibility, performance, device, hosted CI, legal/privacy, App Store, or TestFlight proof.
- It does not archive, move, delete, or rewrite large train files.

Resolved follow-up basis:

- Large train files are governed by registry/ledger/override classification.
- Phase 5 reconciled `PK14` and `IR-01` as separate lanes.
- Completed-train details are routed through `.codex/REPO_INVENTORY.md` and
  `docs/status/archive-and-stale-material-ledger.md`.
- Archive/delete candidates were retained after inbound references showed dense
  historical/supporting links.

## Release Evidence Firewall

Train completion is not release proof. Batch reports do not prove build, tests,
real-hardware validation, public accessibility conformance, performance,
legal/privacy signoff, TestFlight, App Store submission, hosted CI, or
backend/provider activation unless current raw evidence is cited.
