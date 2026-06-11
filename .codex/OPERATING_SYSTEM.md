# Ambitions Codex Operating System

Status: Active Codex OS router  
Scope: Codex operating behavior, task routing, gates, evidence, validation, recovery, and resume  
Authority: Subordinate to `docs/truth/*`  
Updated: 2026-05-10

This file routes Codex work. It does not replace product truth, implementation truth, release proof, historical policy, source evidence, or owner approval.

## 1. What `.codex` Is

`.codex/` is operating support for Codex and future AI agents. It helps decide:

- what to read
- what task mode applies
- what files may be touched
- what validation is required
- what evidence counts
- when to stop
- how to repair
- how to resume
- which skill or train material may be used

## 2. What `.codex` Is Not

`.codex/` is not:

- product/design truth
- implementation proof
- release proof
- App Store/TestFlight/device proof
- public accessibility conformance proof
- legal/privacy signoff
- approval to change app behavior
- approval to add hosted CI, cloud/backend/provider architecture, telemetry, analytics, or external LLM runtime

If `.codex/*` conflicts with `docs/truth/*`, `docs/truth/*` wins.

## 3. Mandatory Read Order

For non-trivial work:

1. User request.
2. `docs/truth/README.md`.
3. `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
4. `docs/truth/IMPLEMENTATION_TRUTH.md`.
5. `docs/truth/RELEASE_TRUTH.md`.
6. `docs/truth/CODEX_PROCESS_TRUTH.md`.
7. `docs/truth/HISTORICAL_POLICY.md`.
8. `AGENTS.md`.
9. `README.md`.
10. `docs/README.md`.
11. Relevant status docs, source, tests, scripts, and `.codex` route files.
12. Historical docs only after classification.

For Goal Mode program work, also read `docs/codex-os/PROGRAM_REGISTRY.md`, the program GOAL file, the program run-state file, the program skill, script-output standards, proof ledger standards, reviewer board standards, and Linear closeout standards before edits.

For explicitly requested legacy batch-train work, also read current active state, batch registry/overlays, model-tier policy, post-batch gates, and EFC overlay files before edits.

## 4. Conflict Precedence Matrix

| Conflict | Winner |
| --- | --- |
| Product/design direction | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Implementation/source status | Live source/project/test/script evidence through `IMPLEMENTATION_TRUTH.md` |
| Release/proof/readiness claim | Current raw evidence through `RELEASE_TRUTH.md` |
| Codex process | `docs/truth/CODEX_PROCESS_TRUTH.md` |
| Historical/archive/delete policy | `docs/truth/HISTORICAL_POLICY.md` |
| README/front-door conflict | `docs/truth/*` |
| Batch report vs release proof | Current release proof wins |
| Docs-only plan vs implementation claim | Live implementation evidence wins |
| MCP output vs source truth | Source truth and current raw evidence win |

## 5. Task Mode Router

| Task mode | Inspect first | Autonomous scope | Required output |
| --- | --- | --- | --- |
| Docs cleanup | `docs/truth/*`, target docs, cleanup ledgers | Small truth-preserving doc edits | Changed files, validation, non-claims |
| Source implementation | Truth files, source owner files, tests, batch scope | Only explicitly scoped owner files | Source/test evidence and no-claim boundary |
| Visual QA | Product truth, AmbitionsCanon support, visual QA gates | Inspection, fixtures, docs, scoped repairs only if authorized | Screenshot/proof status and gaps |
| Build triage | Build scripts, logs, `project.yml`, source owner files | Minimal repair to failing lane | Raw command, exit code, residual risk |
| Release proof | `RELEASE_TRUTH.md`, release evidence packet, raw logs | Evidence capture and claim firewall only | Verified/failed/not verified/human follow-up |
| Skill review | Skill governance, routing map, skill files | Metadata/classification unless implementation authorized | Review status and allowed/forbidden paths |
| Archive cleanup | Historical policy, inbound refs, cleanup ledgers | No move/delete until gates pass | Replacement authority, rollback, owner gate |
| Goal Mode program | `docs/codex-os/PROGRAM_REGISTRY.md`, program GOAL, run-state, skill, standards | Current program issue only | Run-state/proof/script-output/Linear closeout |
| Legacy batch train | Active state, global train, registry, EFC, gates | Current batch only when explicitly requested | Green/Yellow/Red closeout |
| Recovery | Current repo state, latest reports, active state | Reconstruct from repo evidence, not memory | Repair plan or stop reason |

## 6. Autonomous Actions

Codex may autonomously:

- inspect files and repo state
- make docs-only routing/status updates inside the active scope
- add control-plane reports requested by the owner
- run read-only scans and local validation commands when appropriate
- stage/commit path-limited docs-control changes when the phase is Green or accepted Yellow
- preserve conservative non-claim wording

## 6A. Goal Mode Default

Goal Mode is the default autonomous execution model for new Ambitions work.

Use:

- `docs/codex-os/PROGRAM_REGISTRY.md`
- program GOAL files as execution source
- program run-state files as compact memory
- `.agents/skills/<program>/`
- deterministic scripts under `scripts/codex/` and program skills
- `artifacts/proof-ledger/`
- read-only reviewer board passes
- Linear closeouts after successful pushes to `main`

The old Ambitions runner is legacy/supporting/historical unless an active issue explicitly requests it. New Goal Mode program work does not require runner headers and must not route through `scripts/ambitions-codex-train.sh`.

## 7. Approval Required

Explicit owner approval is required for:

- app/source behavior changes outside a named implementation batch
- destructive archive/delete/move operations
- dependency additions
- hosted CI/workflow additions
- write-capable MCP tools
- provider/backend/cloud/user-data server architecture
- signing, entitlements, App Store/TestFlight upload, or self-hosted runner setup
- release-readiness or public conformance claims

## 8. Forbidden

Codex must not:

- implement app features during Codex OS/docs-only passes
- refactor SwiftUI or production source outside scope
- reintroduce `Plan` as top-level IA
- create a new top-level destination
- recreate deleted provider skills
- add hosted CI or backend/cloud assumptions by accident
- claim build/test/release/device/accessibility/performance/legal/privacy proof without current evidence
- treat old prompts, batch docs, screenshots, or memory as current proof

## 9. Stop-The-Train Conditions

Stop immediately on:

- missing truth files
- broken front doors
- authority conflict that cannot be resolved from repo evidence
- dirty worktree risk that affects scoped files
- source mutation outside allowed paths
- destructive cleanup without replacement authority and rollback
- validation contradiction
- release/proof claim without evidence
- provider/backend/cloud reintroduction
- unreviewed write-capable MCP or hosted CI mutation

## 10. Red Repair Loop

When Red:

1. Stop edits.
2. Record exact trigger, files involved, and command output if any.
3. Classify whether repair is safe, owner-gated, or blocked.
4. Repair only the smallest safe owning seam.
5. Re-run the failed validation or explain why it was not rerun.
6. Close with verified, failed, not verified, and non-claims.

## 11. Yellow Debt Rules

Accepted Yellow requires:

- owner or responsible department
- safety reason
- no-claim boundary
- retirement condition
- next prompt or repair path

Yellow does not authorize release claims or destructive cleanup.

## 12. Evidence Hierarchy

Strongest to weakest:

1. Current raw command logs with exit codes.
2. Current source/project/test/script evidence.
3. Current proof packets tied to commit and command.
4. Current status docs that cite evidence.
5. Current batch reports with bounded claims.
6. Supporting canon/docs.
7. Historical docs, prompts, audits, and memory.

Only items 1-4 can support current proof claims, and only within their scope.

## 13. No-Claim Firewall

Unless current evidence proves it, do not claim:

- build success
- tests pass
- release readiness
- TestFlight readiness
- App Store readiness
- signed archive readiness
- physical-device validation
- public accessibility conformance
- performance readiness
- legal/privacy approval
- hosted CI proof
- implementation completeness

Batch completion is not implementation completion unless source/test evidence proves it. Docs-only plans are not implementation proof. Repo inventory is not proof by itself.

## 14. Destructive Change Approval Gate

Before moving, archiving, or deleting a file:

1. Classify it as active, supporting, historical, stale, obsolete, archive-candidate, or delete-candidate.
2. Search inbound references.
3. Identify replacement authority.
4. Preserve unique decisions or evidence.
5. Define rollback.
6. Confirm no active front door breaks.
7. Obtain approval if any useful history or active reference remains.

## 15. Goal Mode And Legacy Batch-Train Authority Rules

- Goal Mode is the active sequencing layer for new autonomous work.
- Program GOAL files and run-state files are the active execution/memory sources for Goal Mode.
- The cleaned global train and originating trains are legacy/supporting unless an active issue explicitly requests the runner.
- `BATCH_REGISTRY.md` is operational status, not product/source/release proof.
- EFC is a proof overlay for unfinished work, not a feature train or release approval.
- Completed docs batches do not prove app implementation.
- Completed release batches require release evidence.

Resolved sequencing note: `.codex/GLOBAL_BATCH_TRAIN.md` distinguishes
`PK14 Durable Command/Event Ledger` as the non-UI platform lane and `IR-01 Big
Frontend Recovery Implementation` as the prerequisite before visible UI
expansion.

## 16. Model-Tier Policy

- Use senior-capable judgment for authority conflicts, destructive cleanup, release claims, architecture decisions, and unresolved Yellow/Red.
- Mini-tier may execute bounded mechanical passes only when `MODEL_TIER_EXECUTION_POLICY.md` and `MODEL_TIER_BATCH_MATRIX.md` classify the work as Mini-safe.
- Mini must defer senior-only gates to `MODEL_TIER_DEFERRAL_LEDGER.md`.
- Unknown-tier runs inherit Mini-safe restrictions for risky decisions.

## 17. Tooling And Validation Handoff

Use `.codex/TOOLING_AND_VALIDATION.md` when it exists. Until then, use:

- `docs/truth/RELEASE_TRUTH.md`
- `AGENTS.md`
- `docs/native-build-and-release.md`
- `docs/status/release-evidence-packet.md`
- relevant scripts under `scripts/`
- MCP docs under `tools/mcp/` and `docs/codex/*MCP*`

Tool output is not proof unless captured, scoped, and reported with non-claims.

## 18. Session Bootstrap Handoff

Use `.codex/SESSION_BOOTSTRAP.md` when it exists. Until then:

1. Read truth files.
2. Check `git status`, branch, HEAD, and upstream.
3. Check active batch/current run state for batch work.
4. Load only the skills and context needed for the task.
5. Treat old prompts as historical unless a current truth-first file promotes them.
6. Rebuild from repo evidence, not chat memory.

## 19. Repo Inventory Handoff

Use `.codex/REPO_INVENTORY.md` when it exists. Until then:

- read `docs/truth/README.md`
- use this file for Codex OS routing
- use current status docs for implementation, release, cleanup, and skill posture
- verify live paths with `rg --files`, `find`, and targeted reads

The inventory will be a map, not authority or proof.

## 20. Current Resume Prompt

```text
Resume the Ambitions repo-control-plane cleanup from live repo evidence.
Read docs/truth/README.md, PRODUCT_DESIGN_TRUTH.md, IMPLEMENTATION_TRUTH.md, RELEASE_TRUTH.md, CODEX_PROCESS_TRUTH.md, HISTORICAL_POLICY.md, AGENTS.md, .codex/OPERATING_SYSTEM.md, and docs/status/repo-control-plane-cleanup-final-report.md first.
Preserve app runtime/source behavior unless an explicitly approved implementation batch owns it.
Use resolved control-plane routing from `.codex/REPO_INVENTORY.md`,
`.codex/GLOBAL_BATCH_TRAIN.md`, `.codex/BATCH_TRAIN_REGISTRY.md`, and
`docs/status/archive-and-stale-material-ledger.md`.
Use Green/Yellow/Red gates, record evidence, and make no release/build/test/device/accessibility/performance/legal/privacy claims without current proof.
```

## 21. Release Evidence Firewall

Local validation is the only validation this OS may assume unless current raw
evidence says otherwise. Hosted CI, real-hardware validation, TestFlight, App
Store submission, public accessibility conformance, performance, legal/privacy,
and backend/provider activation remain non-claims without current evidence.
Batch reports, docs-only plans, train completion, and repo inventory are not
release proof or implementation proof by themselves.
