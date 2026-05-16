# Repo Governance Master Cleanup Plan

Status: Active cleanup control plane  
Last updated: 2026-05-16 Train D Phase 11 YELLOW closeout  
Execution mode: Direct GitHub API / local branch work only  
Authority: Subordinate to `docs/truth/*`

This file tracks the Codex-free repository governance cleanup train. It is not product canon, implementation evidence, validation evidence, or release evidence.

## Authority order

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `README.md`
9. `docs/README.md`
10. portal README files

If this file conflicts with `docs/truth/*`, the truth files win.

## Operating rules

- Use direct GitHub API commits to `main` for small documentation/status updates.
- Use local branch work for source-code or validation-sensitive work.
- Do not create Codex prompts as the deliverable for this cleanup train.
- Do not create draft PRs unless a later high-risk file movement needs a safety branch.
- Do not modify Swift, project config, scripts, resources, or workflows unless a later phase explicitly allows it.
- Do not move historical files until reference-dependency classification is complete.
- Do not truncate historical files to make connector writes easier.

## Open cleanup issues

| Issue | Purpose | Mode |
|---|---|---|
| #5 | Active frontend/visual encyclopedia stale-language sweep | Direct GitHub API or local branch work |
| #7 | Historical canon demotion without losing useful decisions | Direct GitHub API or local branch work |

## Phase status

| Phase | Name | Status |
|---:|---|---|
| 0 | Master cleanup tracker | Complete |
| 1 | Issue cleanup + status ledger roles | Complete |
| 2 | Truth/front-door integration | Complete |
| 3 | Old Canon Classification Index | Complete |
| 4 | Ambitions 2.0 historical headers | YELLOW partial |
| 5 | Ambitions 3.0 / 4.0 / PXOS / ACUI headers | YELLOW partial |
| 6 | Frontend visual encyclopedia sweep | YELLOW partial |
| 7 | Generated report classification | Complete |
| 8 | Swift visible-copy sweep + scan script | YELLOW partial |
| 9 | Authority/workflow validation scripts | Complete, not locally run |
| 10 | Audit/prompt routing READMEs | Complete |
| 11 | Reference dependency scan | YELLOW complete, non-destructive |
| 12 | Ambitions 2.0 archive migration | Blocked pending local reference scan/stubs |
| 13 | Ambitions 3.0 / 4.0 / PXOS archive migration | Blocked pending local reference scan/stubs |
| 14 | Historical prompt/generated-report cleanup | Blocked pending local reference scan/regeneration proof |
| 15 | Final verification and closeout | Not started |

## Train A closeout

Train A completed Phases 0-3 on 2026-05-15.

Completed artifacts:

- `docs/status/repo-governance-master-cleanup-plan.md`
- `docs/status/README.md`
- issue #5 direct-execution update
- issue #7 direct-execution update
- root `README.md` runtime/status links
- `docs/README.md` runtime/status links
- `docs/truth/PRODUCT_MOAT_TRUTH.md` Private Life Runtime proof target
- `docs/status/current-implementation-map.md` runtime proof target link and non-claims
- `docs/status/old-canon-classification-index.md`
- `docs/canon/README.md` old-canon index link
- `history/README.md` old-canon index link

Train A did not modify Swift, project config, scripts, resources, workflows, or generated build artifacts. It did not move historical files.

## Train B closeout

Train B is YELLOW, not Green.

Receipt: `docs/status/train-b-historical-header-quarantine-receipt-2026-05-16.md`

Completed physical headers:

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

Remaining broad legacy families still need either local safer patching or later archive/reference-scan work. No file movement or deletion occurred in Train B.

## Train C closeout

Train C is YELLOW, not Green.

Receipt: `docs/status/train-c-active-surface-hygiene-receipt-2026-05-16.md`

Completed artifacts:

- `docs/status/generated-report-classification.md`
- `scripts/ambitions-visible-copy-drift-scan.py`
- `scripts/validate-repo-authority.sh`
- `scripts/validate-github-workflow-policy.sh`
- `docs/audits/README.md`
- `prompts/README.md`
- `docs/codex/batches/README.md`
- `docs/codex/batch-trains/README.md`

Yellow boundaries:

- scanner scripts were installed but not run locally;
- no Swift source was patched because direct search did not prove a safe visible-copy target;
- active frontend stale-language sweep did not find a clear direct patch target, but issue #5 remains open until local scanner validation is performed;
- generated reports were classified, not moved or deleted.

## Train D Phase 11 closeout

Train D Phase 11 is YELLOW complete and non-destructive.

Receipt: `docs/status/train-d-reference-dependency-scan-receipt-2026-05-16.md`

Completed artifacts:

- `docs/status/archive-delete-candidate-register.md`
- refreshed `docs/status/reference-dependency-scan-cleanup-plan.md`

Phase 11 result:

- Representative inbound-reference searches confirmed old canon/prompt/PXOS files still have active/supporting/historical references.
- No archive moves are approved.
- No deletions are approved.
- Phase 12, Phase 13, and Phase 14 remain blocked until local/Antigravity reference scans, stubs, replacement authority, and rollback paths are prepared.

## Next step

Before any archive migration, run a local/Antigravity reference scan for the Ambitions 2.0 family and prepare stubs. If local proof is unavailable, keep Phase 12 blocked and do not move files.
