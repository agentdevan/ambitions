# Repo Governance Master Cleanup Plan

Status: Active cleanup control plane  
Last updated: 2026-05-15 Train A closeout  
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
| 4 | Ambitions 2.0 historical headers | Not started |
| 5 | Ambitions 3.0 / 4.0 / PXOS / ACUI headers | Not started |
| 6 | Frontend visual encyclopedia sweep | Not started |
| 7 | Generated report classification | Not started |
| 8 | Swift visible-copy sweep + scan script | Not started |
| 9 | Authority/workflow validation scripts | Not started |
| 10 | Audit/prompt routing READMEs | Not started |
| 11 | Reference dependency scan | Not started |
| 12 | Ambitions 2.0 archive migration | Not started |
| 13 | Ambitions 3.0 / 4.0 / PXOS archive migration | Not started |
| 14 | Historical prompt/generated-report cleanup | Not started |
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

## Next train

Train B should perform Phase 4 and Phase 5: add historical/supporting/guardrail headers to old Ambitions 2.0, Ambitions 3.0, Ambitions 4.0, PXOS, and ACUI files. No file movement should happen in Train B.
