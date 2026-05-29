<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-60162119, AMB28-same_source_file_targeted_by_multiple_active_batches-10542241, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_surface_multiple_active_batches-13212827

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Batch ID
CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01
# Objective
Fully install and wire the Ambitions Codex OS into the existing Governance OS, repo doctor, runner, canon installer, global batch train, and generated governance system so Ambitions can operate as a mature autonomous repo operating system.
The target loop is:
ChatGPT direction
-> Canon installer
-> Repo doctor
-> Codex OS reads generated governance state
-> Codex OS chooses next safest batch/action
-> Runner executes
-> Repo doctor closes loop
-> Global train updates
This batch must not implement product features. It must install and harden the autonomous development infrastructure.
# Required Outcome
After this batch, the repo must support:
```bash
python3 scripts/governance/ambitions-repo-doctor.py
python3 scripts/governance/ambitions-repo-doctor.py --strict
python3 scripts/governance/ambitions-canon-installer.py
python3 scripts/codex-os/ambitions-codex-os-context-pack.py
python3 scripts/codex-os/ambitions-codex-os-next-action.py
python3 scripts/codex-os/ambitions-codex-os-sync-governance.py
scripts/ambitions-authorized-batch.sh <BATCH_ID> <PROMPT_FILE>
make repo-doctor
make repo-doctor-strict
make canon-install
make codex-os-context
make codex-os-next
make authorized-batch BATCH=<BATCH_ID> PROMPT=<PROMPT_FILE>
```

Active Source Truth To Inspect

Inspect before editing:

* docs/governance/
* docs/governance/generated/
* docs/governance/SEVEN_STEP_AUTONOMY_CONTRACT.md
* docs/governance/AUTONOMY_LOOP.md
* docs/governance/AUTONOMOUS_REPO_OPERATING_MODEL.md
* docs/governance/RUNNER_GOVERNANCE_CONTRACT.md
* scripts/governance/
* scripts/codex-os/
* .codex/
* scripts/ambitions-codex-train.sh
* scripts/ambitions-authorized-batch.sh
* scripts/ambitions-global-train-supervisor.sh
* Makefile
* docs/codex/BATCH_REGISTRY.md
* global train / queue files under docs/codex/
* current .github/workflows/

Allowed Scope

You may edit/create:

* .codex/os/**
* scripts/codex-os/**
* scripts/governance/**
* docs/governance/**
* docs/codex/** only for governance/global-train wiring
* .github/workflows/** only for governance/Codex OS validation
* Makefile
* scripts/ambitions-authorized-batch.sh
* scripts/ambitions-codex-train.sh only if needed to wire repo doctor closeout safely
* scripts/ambitions-global-train-supervisor.sh only if needed to consume Codex OS next-action/global sequencing outputs

Forbidden Scope

Do not modify product implementation unless required to repair a tooling reference.

Forbidden:

* app UI implementation
* product feature implementation
* Swift model/schema changes
* dependency additions
* network services
* paid services
* secrets
* release/TestFlight/App Store claims
* broad README rewrites unrelated to governance/Codex OS
* deleting historical files without archive plan
* moving files without manifest/update proof

Required Installation And Upgrade Work

Install at least the following. Add more if repo inspection shows gaps.

1. Codex OS authority directory

Create and fully populate:

.codex/os/
├── AMBITIONS_OPERATING_CONTEXT.md
├── ACTIVE_AUTHORITY_MAP.md
├── CODEX_DECISION_POLICY.md
├── AUTONOMY_RULES.md
├── FAILURE_RECOVERY_POLICY.md
├── TOOL_USE_POLICY.md
├── BATCH_SELECTION_POLICY.md
├── GOVERNANCE_INPUTS.md
├── PERFORMANCE_PROFILE.md
└── AGENT_ROLES.md

Each file must be mature, operational, and specific to Ambitions.

2. Codex OS scripts

Create and wire:

scripts/codex-os/
├── ambitions-codex-os-context-pack.py
├── ambitions-codex-os-next-action.py
├── ambitions-codex-os-batch-selector.py
├── ambitions-codex-os-repair-router.py
├── ambitions-codex-os-performance-check.py
└── ambitions-codex-os-sync-governance.py

These must be executable Python scripts with clear CLI behavior, deterministic output, and no external dependencies.

3. Context pack generation

Generate:

build/codex-os/ambitions-context-pack.md

The context pack must include:

* active authority map
* governance surface
* repo doctor summary
* canon impact plan
* implementation expectation map
* global train resequence output
* semantic code graph summary
* architecture debt score
* cleanup action plan
* stale overlay audit summary
* orphan prompt audit summary
* next recommended Codex action
* blocked action reason when blocked
* exact command Codex should run next

4. Next-action resolver

ambitions-codex-os-next-action.py must decide:

* governance Red -> repair governance
* missing generated outputs -> run repo doctor
* canon impact exists -> run canon installer
* frontend/encyclopedia failure -> run relevant authority repair
* global train sequencing stale -> run resequencer
* implementation expectation mismatch -> repair expectations/proof
* no blockers -> select next batch
* no next batch -> report complete/idle

It must write:

build/codex-os/next-action.json
build/codex-os/next-action.md

5. Batch selector

ambitions-codex-os-batch-selector.py must consume generated governance/global train outputs and choose the safest next batch.

It must output:

* batch id
* prompt file if known
* lane
* reason
* blockers
* required preflight commands
* required postflight commands

6. Repair router

ambitions-codex-os-repair-router.py must classify failures into:

* governance repair
* canon propagation repair
* prompt rewrite repair
* frontend authority repair
* encyclopedia repair
* global train sequencing repair
* proof/closeout repair
* archive/shrink repair
* implementation safety repair

It must output a repair plan markdown and JSON.

7. Performance check

ambitions-codex-os-performance-check.py must report:

* number of generated outputs present/missing
* unresolved governance count
* stale overlay count
* orphan prompt count
* architecture debt score
* context pack freshness
* next-action freshness
* repo doctor command status if available

8. Governance sync bridge

ambitions-codex-os-sync-governance.py must:

* run or verify repo doctor outputs
* run Codex OS context pack
* run next-action resolver
* run batch selector
* run repair router
* run performance check
* write a consolidated Codex OS sync report

Output:

build/codex-os/sync-report.md
build/codex-os/sync-report.json

9. Wire repo doctor

Update scripts/governance/ambitions-repo-doctor.py so every run refreshes Codex OS context and next action.

It should run:

* governance reconcile
* canon impact
* semantic code graph
* symbol ownership
* AST mutation safety
* codemod plan
* mature spec synthesis
* prompt rewrite planner
* supersession planner
* implementation expectation map
* global train resequencer
* cleanup plan
* archive candidates
* drift forecast
* architecture debt score
* governance surface
* Codex OS sync/context/next action
* validators

Repo doctor should continue non-stop in normal mode and fail in strict mode.

10. Wire canon installer

Update scripts/governance/ambitions-canon-installer.py so canon changes regenerate:

* impact maps
* propagation plans
* prompt rewrite plans
* mature specs
* implementation expectation maps
* global train resequence plans
* Codex OS context pack
* Codex OS next action
* repo doctor outputs

11. Wire authorized batch

Update scripts/ambitions-authorized-batch.sh so it:

* runs repo doctor before batch
* runs Codex OS sync before batch
* runs runner
* runs repo doctor after batch
* runs Codex OS sync after batch
* fails or reports governance Red clearly
* writes a final summary path

12. Wire runner closeout

If safe, update scripts/ambitions-codex-train.sh so successful batch closeout runs repo doctor or records that the authorized wrapper must run it.

Do not break existing runner behavior.

13. Wire global train

Update global train tooling so it can consume Codex OS next action or generated global resequence plan.

If direct mutation is unsafe, generate a required patch plan and document exact command.

14. Makefile targets

Add:

repo-doctor
repo-doctor-strict
canon-install
codex-os-context
codex-os-next
codex-os-sync
codex-os-performance
codex-os-repair-route
codex-os-batch-select
authorized-batch
autonomy-loop

autonomy-loop should run canon installer, repo doctor, Codex OS sync, and next-action.

15. CI enforcement

Update/add governance CI so it runs:

* repo doctor strict, or
* repo doctor normal plus freshness/critical checks if strict is not yet viable.

CI must not falsely imply release readiness.

16. Generated freshness

Ensure generated outputs have a freshness checker that includes Codex OS outputs.

17. No duplicate sprawl

Remove or deprecate duplicate wrappers only if safe.

If duplicate names must remain, document them as aliases.

18. Canon-change command path

The canonical command for new ChatGPT direction must be:

python3 scripts/governance/ambitions-canon-installer.py
python3 scripts/governance/ambitions-repo-doctor.py
python3 scripts/codex-os/ambitions-codex-os-sync-governance.py

19. Codex command path

The canonical Codex command must be:

python3 scripts/codex-os/ambitions-codex-os-next-action.py

Then Codex follows the emitted command.

20. Documentation

Create/update:

docs/governance/CODEX_OS_INTEGRATION.md
docs/governance/AUTONOMY_COMMANDS.md

These must tell the operator exactly:

* what to run after ChatGPT installs canon
* what to tell Codex
* what generated files to inspect
* what failures mean
* when feature work is blocked

21. Active authority map

Codex OS must know which files outrank others.

Generate or maintain:

build/codex-os/active-authority-map.json

22. Failure handling

Failure behavior must be explicit:

* normal repo doctor collects all failures
* strict repo doctor exits non-zero
* Codex OS next action routes to repair
* authorized batch refuses or warns on governance Red according to mode

23. Agent specialization

Codex OS must encode specialist roles:

* Governance Agent
* Canon Agent
* Frontend Agent
* Platform Agent
* Cleanup Agent
* Proof Agent
* Release Agent

Use these roles in context pack and repair routing.

24. Global train sequencing

Global sequencing must prioritize:

* governance Red repair
* canon propagation
* prompt rewrite
* frontend/encyclopedia authority
* implementation
* proof closeout
* archive/shrink

Origin train order must not override dependency readiness.

25. Validation surface

Ensure final outputs include:

* docs/governance/GOVERNANCE_DASHBOARD.md
* docs/governance/generated/repo_doctor_summary.md
* build/codex-os/ambitions-context-pack.md
* build/codex-os/next-action.md
* build/codex-os/sync-report.md

Quality Bar

This must be world-class repo OS work.

Do not add shallow placeholder scripts that only print messages.

Every script must:

* have deterministic behavior
* read real repo files
* produce useful output
* be runnable locally
* avoid external dependencies
* fail clearly
* write generated outputs where appropriate

Validation Expectations

Run:

python3 -m py_compile scripts/governance/*.py scripts/codex-os/*.py
python3 scripts/governance/ambitions-repo-doctor.py
python3 scripts/codex-os/ambitions-codex-os-sync-governance.py
python3 scripts/codex-os/ambitions-codex-os-next-action.py
python3 scripts/codex-os/ambitions-codex-os-performance-check.py
make codex-os-sync
make repo-doctor

If strict mode fails due existing repo debt, do not hide it. Ensure failures are captured in generated reports.

Visual Proof Expectations

No UI changes expected.

If any frontend/encyclopedia authority command runs, record generated proof files only. Do not claim visual implementation changed.

Hard Red Stop Conditions

Stop and report RED if:

* scripts cannot run due syntax errors
* repo doctor cannot generate outputs
* Codex OS context pack cannot generate
* next-action cannot resolve a safe action
* Makefile targets are broken
* runner is broken
* authorized batch wrapper is broken
* governance files are duplicated in a way that creates conflicting authority
* any script requires external paid/network services
* any change creates release readiness claims

Rollback Expectations

Provide exact rollback paths for:

* .codex/os/**
* scripts/codex-os/**
* changed governance scripts
* changed Makefile
* changed runner/authorized batch/global train files
* changed CI files

Final Response Required From Codex

Return:

STATUS: GREEN | YELLOW | RED

And include:

* files changed
* commands run
* generated outputs created
* remaining Yellow advisories
* exact next command the user should run
* whether "Run Codex OS" is now operational
* whether "Run repo doctor" now includes Codex OS sync
* whether "Run global batch train until complete" is now governance-aware

Runner Command

scripts/ambitions-codex-train.sh CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01 prompts/batches/CODEX-OS-GOVERNANCE-FULL-AUTONOMY-INTEGRATION-01.md

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
