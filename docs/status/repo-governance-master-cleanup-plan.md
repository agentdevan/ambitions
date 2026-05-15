# Repo Governance Master Cleanup Plan

Status: Active cleanup control plane  
Created: 2026-05-15  
Execution mode: Direct GitHub API / local branch work only  
Authority: Subordinate to `docs/truth/*`

This file tracks the Codex-free repository governance cleanup train. It is not product canon, implementation proof, validation proof, or release proof. It exists so humans and AI agents can complete the cleanup without reviving stale authority.

## Active authority hierarchy

Read in this order before changing repo governance, docs, status ledgers, or cleanup classification:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `README.md`
9. `docs/README.md`
10. relevant portal README files

If any file below this hierarchy conflicts with `docs/truth/*`, the truth files win.

## Direct-main policy

Default for this cleanup train:

- use the GitHub API directly on `main`
- make small reversible commits
- do not create Codex prompts as deliverables
- do not create draft PRs unless a destructive archive/delete phase becomes too risky for direct `main`
- do not modify Swift, project files, scripts, resources, entitlements, or workflows unless a phase explicitly allows it
- do not move or delete files until after reference-dependency classification

## No-proof boundary

This cleanup train may improve repo readability and authority routing. It does not prove:

- Xcode build success
- test success
- simulator/device behavior
- accessibility conformance
- visual QA
- privacy/legal conformance
- TestFlight readiness
- App Store readiness
- release readiness

Release claims require current evidence under `docs/truth/RELEASE_TRUTH.md` and current proof artifacts.

## Open cleanup issues

| Issue | Purpose | Current execution mode |
|---|---|---|
| #5 | Active frontend/visual encyclopedia stale-language sweep | Direct GitHub API or local branch work; no Codex runner prompt as deliverable |
| #7 | Historical quarantine and obsolete canon demotion | Direct GitHub API or local branch work; no Codex runner prompt as deliverable |

## The 22 cleanup objectives

| # | Objective | Primary phase | Status |
|---:|---|---|---|
| 1 | Demote every active-looking old canon file | 3-5 | Planned |
| 2 | Replace `Status: Active canon` in old files | 4-5 | Planned |
| 3 | Create old canon classification index | 3 | In progress |
| 4 | Assign one owner role to each status ledger | 1 | In progress |
| 5 | Convert GitHub API audit into historical receipt | 1 | In progress |
| 6 | Remove stale runner-command language from open issues | 1 | In progress |
| 7 | Historical header pass before deletion | 4-5 | Planned |
| 8 | Archive old files only after reference scan | 11-14 | Planned |
| 9 | Root README cleanup | 2 | In progress |
| 10 | Docs README cleanup | 2 | In progress |
| 11 | Frontend visual encyclopedia stale-language sweep | 6 | Planned |
| 12 | Generated frontend packet classification | 7 | Planned |
| 13 | Swift user-visible copy sweep | 8 | Planned |
| 14 | Protect internal compatibility names until local validation | 8 | Planned |
| 15 | GitHub Actions manual-only policy | 9 | Planned |
| 16 | Link runtime proof spec from active docs | 2 | In progress |
| 17 | Add sharper moat proof target | 2 | In progress |
| 18 | Add audit receipt rules | 10 | Planned |
| 19 | Delete only after extraction/reference scan | 11-14 | Planned |
| 20 | Route prompts out of active authority path | 10/14 | Planned |
| 21 | Add repo authority validation script | 9 | Planned |
| 22 | Add Swift visible-copy drift scan script | 8 | Planned |

## Phase checklist

| Phase | Name | Scope | Status |
|---:|---|---|---|
| 0 | Master cleanup tracker | Create this control plane | Complete once committed |
| 1 | Issue cleanup + status ledger roles | `docs/status/README.md`, issues #5/#7, cleanup register | In progress |
| 2 | Truth/front-door integration | README, docs README, moat truth, implementation map | In progress |
| 3 | Old Canon Classification Index | old-canon index, canon/history links if needed | In progress |
| 4 | Historical header pass A | Ambitions 2.0 files | Not started |
| 5 | Historical header pass B | Ambitions 3.0 / 4.0 / PXOS / ACUI | Not started |
| 6 | Frontend visual encyclopedia sweep | active frontend canon files | Not started |
| 7 | Generated report classification | build/reports and generated packets | Not started |
| 8 | Swift visible-copy sweep + scan script | visible copy only, no symbol renames | Not started |
| 9 | Authority/workflow validation scripts | local scripts only | Not started |
| 10 | Audit/prompt routing READMEs | audit and prompt entry points | Not started |
| 11 | Reference dependency scan | no moves/deletes | Not started |
| 12 | Archive migration A | Ambitions 2.0 family if safe | Not started |
| 13 | Archive migration B | Ambitions 3.0 / 4.0 / PXOS / ACUI if safe | Not started |
| 14 | Archive/delete prompt and generated junk | only after classification | Not started |
| 15 | Final verification and closeout | all 22 objectives | Not started |

## Rollback expectations

Every direct commit must be independently reversible. For each phase, the closeout report must list:

- commit SHA
- files changed
- issues updated
- blocked paths
- claims allowed
- claims not allowed

Do not perform broad file moves or deletes without a reference-dependency scan and rollback path.

## Current Train A target

Train A covers Phases 0-3:

- create this master tracker
- create status ledger roles
- update open issues #5 and #7 away from Codex-runner language
- link runtime proof and cleanup status from active front doors
- create old canon classification index

No Swift changes, workflow changes, file moves, or deletions are allowed in Train A.
