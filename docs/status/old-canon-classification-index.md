# Old Canon Classification Index

Status: Active supporting cleanup index  
Created: 2026-05-15  
Last updated: 2026-05-16 Train B YELLOW status  
Authority: Subordinate to `docs/truth/*` and `docs/status/README.md`

This index classifies old canon and old execution-material families so humans and AI agents can tell what is active, supporting, historical, quarantined, archive-candidate, or delete-candidate before editing or moving files.

This file does not move, delete, or promote any old material. It is a classification layer only.

## Classification rules

- Active: current authority or live source/proof owner for a narrow scope.
- Supporting: useful context that cannot override `docs/truth/*`.
- Historical: retained for traceability only.
- Quarantine: retained but unsafe for default use until reconciled.
- Archive-candidate: likely moveable after reference checks and stubs.
- Delete-candidate: potentially removable only after extraction, reference checks, approval, and rollback planning.

## Replacement authorities

| Topic | Replacement authority |
|---|---|
| Product/design truth | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Moat strategy | `docs/truth/PRODUCT_MOAT_TRUTH.md` |
| Implementation/source truth | `docs/truth/IMPLEMENTATION_TRUTH.md`, live source, and `docs/status/current-implementation-map.md` |
| Release/proof truth | `docs/truth/RELEASE_TRUTH.md` and current validation evidence |
| Historical handling | `docs/truth/HISTORICAL_POLICY.md` |
| Repo cleanup status | `docs/status/cleanup-decision-register.md` and this index |
| Archive/delete safety | `docs/status/archive-and-stale-material-ledger.md` |
| Runtime proof target | `docs/runtime/PRIVATE_LIFE_RUNTIME_PROOF_SPEC.md` |
| Frontend visual canon | `frontend/README.md` and `frontend/visual-encyclopedia/` active files |

## Family classification

| Path / family | Current classification | Why retained | Replacement authority | Safe to delete? | Safe to archive? | Stub required? | Inbound refs checked? | Last reviewed |
|---|---|---|---|---|---|---|---|---|
| `docs/canon/Ambitions_2_0_*` | Historical, archive-candidate, Train B partial headers | Retains old product architecture, roadmap, capability, and audit context; not active truth. | `docs/truth/*`, `docs/status/current-implementation-map.md`, `frontend/README.md` | No | Later, after reference scan | Likely for high-link files | Not complete | 2026-05-16 |
| `docs/codex/Ambitions_2_0_*` | Historical process artifact, archive-candidate, Train B partial headers | Retains old Codex execution context; not current execution mode. | `docs/truth/CODEX_PROCESS_TRUTH.md`, `codex-os/README.md`, `.codex/README.md` | No | Later, after reference scan | Likely | Not complete | 2026-05-16 |
| `docs/canon/Ambitions_3_0_*` | Historical/supporting, partial quarantine, Train B partial headers | Retains useful copy, privacy, design, recommendation, proof, and deprecation decisions; active-looking names can cause drift. | `docs/truth/*`, `frontend/README.md`, `docs/status/current-implementation-map.md` | No | Later, after durable-value extraction | Likely | Not complete | 2026-05-16 |
| `docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md` | Historical process artifact, quarantine | Old master prompt can override current direct-main / truth-first operations if reused blindly. | `docs/truth/CODEX_PROCESS_TRUTH.md`, `docs/status/repo-governance-master-cleanup-plan.md` | No | Later, after prompt routing rules | Likely | Not complete | 2026-05-16 |
| `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md` | Historical process artifact, quarantine | Old orchestrator can revive outdated train assumptions. | `docs/truth/CODEX_PROCESS_TRUTH.md`, `codex-os/README.md` | No | Later, after reference scan | Likely | Not complete | 2026-05-16 |
| `docs/canon/Ambitions_4_0_*` | Historical/supporting, partial quarantine, connector-blocked physical headers | Retains External Brain and memory/kernel thinking; must not override current Private Life Runtime proof target. | `docs/truth/PRODUCT_MOAT_TRUTH.md`, `docs/runtime/PRIVATE_LIFE_RUNTIME_PROOF_SPEC.md` | No | Later, after extraction | Likely | Not complete | 2026-05-16 |
| `docs/codex/batches/EB*_Ambitions_4_0_*` and `docs/codex/batches/EB*` | Historical execution artifact | Retains old External Brain batch history; not current proof or direct-execution instruction. | `docs/truth/CODEX_PROCESS_TRUTH.md`, `docs/status/README.md` | No | Later, after prompt routing and reference scan | Possibly | Not complete | 2026-05-16 |
| `docs/canon/PXOS_*` | Historical/supporting, partial quarantine, Train B partial headers | Retains Product Experience OS concepts; some terms may conflict with current frontend/IA language. | `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `frontend/README.md`, `frontend/visual-encyclopedia/` | No | Later, after frontend sweep | Likely | Not complete | 2026-05-16 |
| `docs/codex/PXOS_HANDOFF_PACKAGE.md` | Historical handoff/process artifact | Retains PXOS handoff context; not active authority. | `docs/truth/*`, `frontend/README.md`, `docs/status/cleanup-decision-register.md` | No | Later, after reference scan | Possibly | Not complete | 2026-05-16 |
| `docs/codex/batches/PX*` and `prompts/batches/PX*` | Historical execution artifact, partial quarantine | Retains old Product Experience train prompts; not direct-main instructions. | `docs/truth/CODEX_PROCESS_TRUTH.md`, `docs/status/repo-governance-master-cleanup-plan.md` | No | Later, after prompt routing rules | Possibly | Not complete | 2026-05-16 |
| `docs/canon/ACUI_*` | Historical/quarantine if present | ACUI references are legacy authority terms unless explicitly reconciled; current search found references mostly through maps/audits, not confirmed active ACUI family files. | `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `frontend/README.md` | No | Only if files are confirmed and scanned | Unknown | Not complete | 2026-05-16 |
| `docs/canon/Ambitions_Beyond_3_0_*` | Historical/supporting if present | Future-looking beyond-3.0 canon must not override current truth. | `docs/truth/*`, `docs/status/current-implementation-map.md` | No | Later, after confirmation and reference scan | Unknown | Not complete | 2026-05-16 |
| `docs/canon/design/*` | Supporting or historical depending on file | Some design material may remain valuable but must not outrank active frontend/truth files. | `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `frontend/README.md`, `frontend/visual-encyclopedia/` | No | Later, after frontend sweep | Possibly | Not complete | 2026-05-16 |
| `docs/handoff/Ambitions_3_0_*` | Historical handoff artifact | Retains handoff history; not active truth. | `docs/truth/*`, `docs/status/cleanup-decision-register.md` | No | Later, after reference scan | Possibly | Not complete | 2026-05-16 |
| `docs/handoff/Ambitions_4_0_*` | Historical handoff artifact | Retains handoff history; not active truth. | `docs/truth/*`, `docs/status/cleanup-decision-register.md` | No | Later, after reference scan | Possibly | Not complete | 2026-05-16 |
| `docs/audits/ambitions-3-0-*` | Historical/supporting audit receipt | Retains old audit evidence; not current proof unless tied to current commit/logs. | `docs/truth/RELEASE_TRUTH.md`, `docs/status/release-evidence-packet.md` | No | Later, after audit README/routing | Possibly | Not complete | 2026-05-16 |
| `docs/audits/px*` | Historical/supporting audit receipt | Retains old PX audit evidence; not active frontend proof by itself. | `docs/truth/RELEASE_TRUTH.md`, `frontend/README.md` | No | Later, after audit README/routing | Possibly | Not complete | 2026-05-16 |
| `docs/audits/si*` | Historical/supporting audit receipt | Retains Signature Interface evidence; not current visual proof by itself. | `docs/truth/RELEASE_TRUTH.md`, `frontend/README.md`, active visual encyclopedia | No | Later, after audit README/routing | Possibly | Not complete | 2026-05-16 |
| `docs/codex/batch-trains/*` | Historical/supporting process artifact | Retains execution sequencing history; not active truth or proof. | `docs/truth/CODEX_PROCESS_TRUTH.md`, `codex-os/README.md` | No | Later, after prompt routing and reference scan | Possibly | Not complete | 2026-05-16 |
| `prompts/batches/*` | Historical or pending execution artifact | Prompts are execution artifacts, not authority. Must not be treated as current instructions unless refreshed. | `docs/truth/*`, user-scoped direct instruction, `codex-os/README.md` | No | Later, after prompt README/routing | Possibly | Not complete | 2026-05-16 |
| `build/reports/*` | Generated/historical report material pending classification | Generated reports may be stale or proof-adjacent; each needs generated-report classification. | `docs/status/generated-report-classification.md` once created, `docs/truth/RELEASE_TRUTH.md` | No | Later, after generated-report classification | Unknown | Not complete | 2026-05-16 |

## Train B physical header status

Train B ran on 2026-05-16 and is YELLOW, not Green.

Receipt: `docs/status/train-b-historical-header-quarantine-receipt-2026-05-16.md`

Physical headers/status demotions completed:

- `docs/codex/Ambitions_2_0_Codex_Execution_Guide.md`
- `docs/canon/Ambitions_2_0_Master_Plan.md`
- `docs/canon/Ambitions_2_0_Product_Architecture.md`
- `docs/canon/Ambitions_3_0_Copy_QA_Protocol.md`
- `docs/canon/Ambitions_3_0_Privacy_Threat_Model.md`
- `docs/canon/Ambitions_3_0_Flake_Management_Protocol.md`
- `docs/canon/PXOS_Empty_Edge_And_Degraded_States.md`

Connector-blocked full-preservation updates:

- `docs/canon/Ambitions_3_0_Design_System_Primitives.md`
- `docs/canon/Ambitions_4_0_Signature_Experience_Layer.md`
- `docs/canon/Ambitions_4_0_External_Brain_Privacy_Threat_Model.md`

Train B did not move, delete, or truncate files. Remaining broad legacy families still require local safer patching, later reference-dependency scan, or family archive migration.

## Header policy

Retained old files should receive one of these headers before any archive/delete movement.

Historical reference:

```markdown
> Historical note: This file is retained for traceability only.
> It is not active authority. Current authority starts in `docs/truth/README.md`.
```

Supporting reference:

```markdown
> Supporting note: This file may contain compatible durable decisions.
> It does not override `docs/truth/*`, live source, or current proof evidence.
```

Quarantine reference:

```markdown
> Quarantine note: This file contains obsolete or potentially conflicting language.
> Do not use it for implementation until compatible value is extracted into active truth/status files.
```

## Hard stops

- Do not delete old canon families from this index alone.
- Do not archive old canon families until inbound references and replacement authority are recorded.
- Do not use old prompts as current execution instructions.
- Do not treat audit receipts as current release proof.
- Do not treat generated reports as implementation proof without live source and current logs.
- Do not promote Plan, Profile, Captures, PXOS, ACUI, Ambitions 2.0, Ambitions 3.0, or Ambitions 4.0 as current product truth.

## Next cleanup phase

Either run a local safer bulk-header pass for the remaining Train B files, or proceed to Train C only with Train B's YELLOW status accepted. No file movement or deletion should happen until the reference-dependency scan phase.
