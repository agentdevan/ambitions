<!-- markdownlint-disable MD013 -->

# Codex Global Batch Train

Status: Active Codex sequencing file
Date updated: 2026-05-10
Branch at update: main

## Authority

This file is the cleaned active Codex sequencing layer. It is subordinate to:

1. `docs/truth/*`
2. `AGENTS.md`
3. `.codex/OPERATING_SYSTEM.md`
4. `.codex/BATCH_TRAIN_REGISTRY.md`
5. Current raw source, validation, and state evidence

This file is not product truth, implementation proof, release proof, build
proof, test proof, accessibility proof, performance proof, device proof,
privacy/legal approval, hosted CI proof, or App Store/TestFlight readiness.

## Current Source Of Sequencing

Originating trains are inputs, not authorities. Current sequencing is composed
from:

- `.codex/state/active-batch.yml`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
- `.codex/BATCH_TRAIN_REGISTRY.md`

Current reconciliation:

- Next non-UI platform batch: `PK14 Durable Command/Event Ledger`.
- UI recovery prerequisite before visible top-level expansion: `IR-01 Big Frontend Recovery Implementation`.
- This cleanup pass does not start either batch.

## Global Sequence Table

| Seq | Batch id | Title | Origin | Status | Owner department | Dependencies | Allowed paths | Forbidden paths | Validation required | Evidence required | Stop conditions | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | IR-01 | Big Frontend Recovery Implementation | FET follow-up | Yellow prerequisite before visible UI expansion | Design, iOS Engineering, QA, Accessibility | FET01-FET12 gates, active product/design truth | Only a future explicitly approved UI recovery batch may touch app UI/source paths | This cleanup pass forbids `Native/`, `Sources/`, `AppUI/`, project/package files, resources, entitlements, privacy manifests, tests | Future UI batch must run focused local build/test/visual/accessibility proof | Fresh screenshots/logs/source evidence, no public accessibility or release claim | Any source mutation in this cleanup pass; any release/readiness claim | Record as prerequisite, do not run now |
| 2 | PK14 | Durable Command/Event Ledger | PK | Active next non-UI platform batch | iOS Engineering, Privacy/Trust, QA | PK13 Green, EFC overlay, source/data-safety gates | Future PK14 batch must name exact source/test files before editing | This cleanup pass forbids app runtime/source changes | Future PK14 batch must run focused unit tests and claim scan | Source/test proof, EFC applicability, no data-loss-proof or sync claim | Dirty unclassified worktree, missing dependency, source mutation outside batch | Select when implementation work is explicitly resumed |
| 3 | PK15-PK16 | Receipt backend and trust history query | PK | Planned | iOS Engineering, Privacy/Trust, QA | PK14 complete | Future scoped PK paths only | UI expansion, release claims, backend/provider activation | Focused tests and local proof | Source/test proof | PK14 incomplete | Queue after PK14 |
| 4 | PK17-PK21 | Service extraction sequence | PK | Planned | iOS Engineering, Build Systems, QA | PK16 complete | Future scoped service/source/test paths only | UI redesign, dependency additions without approval | Build/tests relevant to touched seams | Source/test proof | Architecture or validation contradiction | Queue after PK16 |
| 5 | PK22-PK28 | Side effects, privacy, diagnostics, data controls | PK | Planned | Privacy/Trust, iOS Engineering, QA | PK21 complete | Future scoped side-effect/privacy/data-control paths only | Silent mutation, telemetry/analytics, cloud/backend assumptions | Focused tests, privacy scans, claim scan | Source/test/privacy evidence | Privacy or side-effect uncertainty | Queue after PK21 |
| 6 | PK29-PK31 | Sync readiness and manual merge foundations | PK | Planned | iOS Engineering, Privacy/Trust, Release | PK28 complete | Future scoped local/portable sync-readiness paths only | Hosted sync/cloud launch claims | Focused tests and no-claim scan | Source/test proof; no launch sync claim | Any cloud/provider assumption | Queue after PK28 |
| 7 | PK32-PK34 | Knowledge and intelligence boundaries | PK | Planned | Product, Privacy/Trust, iOS Engineering | PK31 complete | Future scoped local intelligence boundary paths only | Hosted AI, chatbot, external LLM architecture, hidden learning | Focused tests, claim scan | Source/test/proof receipts | AI theater or provider activation | Queue after PK31 |
| 8 | PK35-PK41 | Scale, performance, modularization | PK | Planned | Build Systems, iOS Engineering, QA | PK34 complete | Future scoped performance/package paths only | Package/project mutation without explicit batch approval | Focused local build/test/performance proof where relevant | Source/test/performance evidence | Performance claim without raw evidence | Queue after PK34 |
| 9 | SA/LDI/AOS/FCP/PFC tails | Source atlas, intelligence, product, platform tails | Originating trains | Planned/deferred/blocked mix | Product, Design, iOS Engineering, QA, Privacy, Release | Relevant PK/FET/EFC gates | Future batch-specific paths only | Out-of-order train resurrection | Owner-specific validation | Source/test/docs evidence by batch | Missing prerequisites | Select only through global order |
| 10 | RHC01-RHC06 | Repo hygiene closeout | RHC | Planned late unless hygiene Hard Red appears | Repo Hygiene, Codex Process | No active implementation blocker unless promoted | Docs/control-plane paths only unless separately approved | Runtime/source cleanup without approval | Docs QA, link/reference checks | Ledger and rollback evidence | Data-loss or reference break risk | Queue late or on Hard Red |

## Completed Section

| Completed work | Proof type | No-overclaim boundary |
| --- | --- | --- |
| PK01-PK13 | Registry/state/report evidence, focused tests where named by prior closeouts | Does not prove release readiness, sync readiness, data-loss-proof behavior, or app completeness. |
| FET01-FET12 | Codex OS/frontend quality-system evidence | Does not implement live UI recovery or prove public accessibility conformance. |
| PX01-PX20 | Historical future-canon/roadmap evidence | Does not make PXOS active implementation authority. |
| PD01-PD18 | Product-depth train evidence | Does not prove runtime behavior without source evidence. |
| EFC00 | Proof-overlay insertion evidence | Does not replace global sequencing or product truth. |

## Active Next Section

Active next implementation selector:

- If the user asks for non-UI platform/kernel continuation, select `PK14`.
- If the user asks for visible UI/top-level expansion, first resolve `IR-01`.
- If the user asks for this repo-control-plane cleanup, continue Phase 6 next.

Exact allowed files for the next cleanup phase:

- `.codex/TOOLING_AND_VALIDATION.md`
- `docs/status/repo-control-plane-cleanup-final-report.md`

Validation requirement:

- Claim scan on changed governance/status files.
- Docs QA if safe.
- No Xcode build/test unless app source changes.

## Planned Section

Planned future work follows logical product/architecture order:

1. Resolve UI recovery prerequisite before visible top-level expansion.
2. Finish PK14-PK16 event/receipt/trust foundations.
3. Finish PK17-PK21 service extraction foundations.
4. Finish PK22-PK28 side effect/privacy/data-control foundations.
5. Finish PK29-PK31 local sync-readiness and merge foundations without cloud claims.
6. Finish PK32-PK34 knowledge/intelligence boundary hardening.
7. Finish PK35-PK41 scale, performance, and package work.
8. Resume source atlas, intelligence, product, platform, and release tails only when dependencies are satisfied.
9. Run RHC hygiene closeout late or when hygiene becomes a Hard Red blocker.

## Deferred Section

- SIG01-SIG16 remain deferred until global prerequisites are satisfied.
- RHC01-RHC06 remain late unless hygiene blocks active work.
- Conditional CS repair batches run only when a named seam trigger exists.
- Standalone EFC batches run only when no existing owner can produce required proof.

## Obsolete Section

| Originating entry | Classification | Recommendation |
| --- | --- | --- |
| PX active rerun prompts | Historical complete / do not rerun | Keep as historical until archive ledger and inbound-reference pass. |
| F03.5/F04-F30 old Ambitions 3.0 prompts | Historical/supporting | Archive only after reference and rollback gates. |
| Standalone EFC feature-train interpretation | Obsolete interpretation | Keep EFC as proof overlay. |
| Provider/backend skill assumptions | Obsolete/forbidden | Do not recreate without explicit approval and truth-file promotion. |

## Hard Stop Rules

Stop immediately for:

- Source mutation outside the active allowed paths.
- Release, TestFlight, App Store, device, accessibility, performance, legal/privacy, or hosted CI claims without current raw evidence.
- Backend/provider/Supabase/auth/sync/analytics/telemetry/external LLM reintroduction.
- Old Plan/Profile/Captures terminology promoted as active user-facing IA.
- Unreviewed destructive archive/delete/move action.
- Validation contradiction.
- Dirty worktree that cannot be classified.

## Resume Prompt

```text
Continue the Ambitions repo-control-plane cleanup with Phase 6 only.
Read docs/truth/* first, then .codex/OPERATING_SYSTEM.md,
.codex/BATCH_TRAIN_REGISTRY.md, and .codex/GLOBAL_BATCH_TRAIN.md.
Create/update .codex/TOOLING_AND_VALIDATION.md as a tooling map, not proof.
Do not implement app features, mutate source/runtime behavior, add
dependencies, add hosted CI, or make release/accessibility/performance/device
claims. Run claim scan on changed files and record Green/Yellow/Red.
```

## Phase 5 Gate Result

Phase 5 result: Green with accepted Yellow items.

EFC applicability: invoked for governance and continuation proof. This file
does not claim app implementation, release readiness, public accessibility
conformance, performance proof, device validation, hosted CI proof, legal/privacy
approval, App Store readiness, or TestFlight readiness.

Accepted Yellow:

- `PK14` and `IR-01` remain distinct next-action lanes rather than collapsed
  into one implementation batch.
- Large legacy train files remain unmodified.
- Archive/delete candidates still require inbound-reference checks.
