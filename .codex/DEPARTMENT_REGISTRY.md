# Ambitions Codex Department Registry

Status: Active Codex department and ownership router  
Scope: Department roles, review routing, ownership, file responsibility, compatibility debt, risk, Yellow debt, and rollback policy  
Authority: Subordinate to `docs/truth/*` and `.codex/OPERATING_SYSTEM.md`  
Updated: 2026-05-10

This registry consolidates senior-department routing for Codex work. It is not product truth, implementation proof, validation proof, or release proof.

## 1. Department Model

| Department | Owns | Does not own |
| --- | --- | --- |
| Product | Product promise, object model, IA intent, user jobs, non-shaming language | Claiming implementation without source evidence |
| Design | Visual system, interaction quality, motion/accessibility-aware UX, surface coherence | Generic redesign outside truth/batch scope |
| iOS Engineering | Native SwiftUI architecture, domain/services/persistence boundaries, tests, app-source implementation | Docs-only strategy claims or release approval |
| QA | Test strategy, focused validation, regression selection, failure triage | Release readiness without proof |
| Accessibility | Dynamic Type, VoiceOver, Reduce Motion, cognitive load, gesture alternatives | Public conformance claims without evidence |
| Privacy/Trust | Local-first posture, data boundaries, receipts, correction/export/delete, provider exclusion | Legal/privacy signoff without human approval |
| Release | Release evidence, claim firewall, archive/export/signing proof when approved | App Store/TestFlight/device claims without current evidence |
| Build Systems | XcodeGen, local build/test scripts, toolchain checks, generated-project hygiene | Hosted CI/workflow mutation without approval |
| Repo Hygiene | Truth routing, stale-file classification, archive/delete gates, inventory | Destructive cleanup without inbound refs and rollback |
| Codex Process | Read order, task routing, skills, batch trains, gates, recovery, closeout | Product/source/release truth itself |

## 2. Review Board Matrix

| Task type | Required reviewers / departments |
| --- | --- |
| Product/design truth | Product, Design, Codex Process |
| Source implementation | iOS Engineering, QA, Product or Design if user-facing |
| Visual QA or UI polish | Design, Accessibility, QA, iOS Engineering |
| Build failure or project wiring | Build Systems, iOS Engineering, QA |
| Release/proof work | Release, QA, Privacy/Trust when data claims are involved |
| Privacy/security/provider policy | Privacy/Trust, Release, Codex Process, iOS Engineering when source is touched |
| Accessibility evidence | Accessibility, QA, Design |
| Skill governance | Codex Process, Repo Hygiene, owning department for skill scope |
| Batch-train reconciliation | Codex Process, Product, iOS Engineering, QA, Release when claims appear |
| Archive/delete cleanup | Repo Hygiene, Codex Process, owning department, Release if proof/history is involved |
| Dependency/tooling changes | Build Systems, Privacy/Trust, Release, iOS Engineering |

## 3. Ownership Map

| Repo area | Owner department |
| --- | --- |
| `docs/truth/` | Product, iOS Engineering, Release, Codex Process, Repo Hygiene by truth file |
| `docs/status/` | Repo Hygiene, Release, Codex Process |
| `docs/AmbitionsCanon/` | Product and Design |
| `docs/codex/` | Codex Process with owning department by file family |
| `docs/canon/` | Product/Design when compatible; otherwise Repo Hygiene historical classification |
| `docs/audits/` | QA, Release, Repo Hygiene |
| `docs/handoff/` | Release, QA, Repo Hygiene |
| `.codex/` | Codex Process, Repo Hygiene, Build Systems for validation maps |
| `.agents/` | Codex Process and Repo Hygiene |
| `Native/` | iOS Engineering with Product/Design/QA/Accessibility by surface |
| `Sources/` | iOS Engineering and Design System ownership |
| `AppUI/` | iOS Engineering and platform/shared UI ownership |
| `scripts/` | Build Systems, QA, Repo Hygiene, Release by script type |
| `tools/mcp/` | Codex Process, Build Systems, Repo Hygiene, Release/QA by MCP type |
| `.github/` | Build Systems and Release, currently absent as active workflow path |

## 4. File Responsibility Map

| Path | Responsibility | Active rule |
| --- | --- | --- |
| `docs/truth/README.md` | Authority index | Wins routing conflicts. |
| `docs/truth/PRODUCT_DESIGN_TRUTH.md` | Product/design direction | Wins product/design conflicts. |
| `docs/truth/IMPLEMENTATION_TRUTH.md` | Implementation/source boundaries | Live source evidence wins implementation claims. |
| `docs/truth/RELEASE_TRUTH.md` | Proof/release claims | No proof, no readiness. |
| `docs/truth/CODEX_PROCESS_TRUTH.md` | Codex operating behavior | Process truth for Codex work. |
| `docs/truth/HISTORICAL_POLICY.md` | Historical/archive/delete policy | Required before stale cleanup. |
| `.codex/OPERATING_SYSTEM.md` | Codex OS router | Subordinate to truth files; routes work. |
| `.codex/state/` | Compact active state | Must be reconciled with reports before train claims. |
| `.codex/reports/` | Current run/train reports | Process evidence, not release proof. |
| `.codex/manifests/` | Routing/ownership maps | Supporting; truth files win. |
| `.codex/templates/` | Report/prompt templates | Supporting; old templates need cleanup if stale. |
| `.codex/skills/` | Skill library | Active/candidate/historical status requires governance. |
| `.agents/skills/supabase*` | Deleted provider skill roots | Must not be recreated without approval. |
| `Native/`, `Sources/`, `AppUI/` | Production/runtime source | Forbidden in control-plane cleanup unless explicitly approved. |

## 5. Compatibility Debt Register

| Debt | Current classification | Owner | Retirement condition |
| --- | --- | --- | --- |
| `Plan -> Time` | Active compatibility debt | Product, iOS Engineering | Scoped AFI/compatibility migration proves user-facing and route safety. |
| `Profile -> You` | Active compatibility debt | Product, Design, iOS Engineering | User-facing You stays stable while internal names migrate only under scope. |
| `Captures -> Capture` | Active compatibility debt | Product, iOS Engineering | Singular user-facing Capture remains; internal names migrate only safely. |
| `ACUI -> AFI` | Historical naming debt | Product, Design, Repo Hygiene | Old ACUI references classified or archived. |
| Ambitions 3.0 hierarchy -> `docs/truth/` hierarchy | Historical authority debt | Codex Process, Repo Hygiene | Active paths route through truth files; old docs labeled/supporting/archive. |
| Provider/backend assumptions | Deleted/quarantined | Privacy/Trust, Repo Hygiene | No active provider roots or backend architecture without approval. |
| Large historical docs | Override-governed | Repo Hygiene | Header/ledger pass with patch-safe tooling. |
| Old release/App Store/TestFlight language | Release-claim debt | Release | Current raw proof or demotion to historical/non-claim. |
| `PlanScreen`, `.plan`, `planNavigation()`, `Native/Ambitions/Features/Plan/` | Internal compatibility seams | iOS Engineering | Scoped migration with tests and no user-facing IA regression. |

## 6. Risk Register

| Risk | Owner | Mitigation |
| --- | --- | --- |
| Authority drift | Codex Process, Repo Hygiene | Read `docs/truth/*` first; front doors route to truth. |
| Stale docs | Repo Hygiene | Classify before using; archive/delete gates. |
| Stale batch trains | Codex Process | Fold into global train and registry. |
| False release claims | Release | Release truth and no-claim firewall. |
| Accidental source mutation | iOS Engineering, Repo Hygiene | Allowed/forbidden paths and `git status` preflight. |
| Provider/backend reintroduction | Privacy/Trust | Forbidden roots and explicit approval gate. |
| Archive/delete data loss | Repo Hygiene | Inbound refs, extraction, rollback, approval. |
| Old prompt reuse | Codex Process | Session bootstrap and prompt cleanup. |
| Unreviewed skills | Codex Process | Skill governance review status tracker. |
| Train duplication | Codex Process | Batch train registry and global sequence. |
| Tool/script misuse | Build Systems, QA | Tooling map and task-type validation. |
| Large-file truncation | Repo Hygiene | Large-file override policy and patch-safe edits only. |

## 7. Yellow Debt Ledger

| Item | Owner | Reason | Retirement condition |
| --- | --- | --- | --- |
| Active-state next-batch tension: PK14 vs IR-01/FET recovery | Codex Process | State/report files disagree on next execution emphasis | Phase 5 global train cleanup selects one active next batch and records why. |
| Large train/control-plane files not line-reviewed | Repo Hygiene | Avoid unsafe whole-file rewrites/truncated reads | Phase 4/9 override-aware classification. |
| Stale provider paths in `docs/audits/tracked-files.txt` | Repo Hygiene | Historical inventory still lists deleted roots | Phase 9 ledger or approved stale inventory retirement. |
| Repo MCP source-truth-stack lag | Codex Process, Tools | MCP output omits `docs/truth/*` | Tooling validation/repair pass updates MCP or records limitation. |
| Skills not line-reviewed | Codex Process | Inventory is summary-level | Phase 3 governance and future metadata header pass. |
| Missing later target artifacts | Codex Process | Phases not reached yet | Create during Phases 3-9. |

## 8. Cleanup Rollback Policy

For docs/control-plane changes:

1. Commit each Green or accepted-Yellow phase separately.
2. Stage only explicit paths.
3. Record changed files and validation.
4. Revert by commit if the phase proves wrong.

For archive/delete/move changes:

1. Do not proceed until inbound references, replacement authority, preserved value, and rollback are recorded.
2. Prefer archive over delete when traceability has value.
3. Use small batches by file family.
4. Keep stubs only when active inbound links require them.
5. Never delete active truth files, active front doors, source/runtime files, current proof logs, or release evidence required for claims.

## 9. Current Department Handoff

Next target artifact after this registry:

```text
.codex/SKILL_GOVERNANCE.md
```

Carry forward accepted Yellow items from Phase 0B and Phase 1. Do not implement app features during skill governance.

## 10. Release Evidence Firewall

Departments may use local validation, source evidence, and status reports only
within their proven scope. No department may claim hosted CI proof,
real-hardware validation, TestFlight or App Store submission readiness, public
accessibility conformance, performance proof, legal/privacy signoff,
backend/provider activation, or implementation completeness without current raw
evidence and the required review board.
