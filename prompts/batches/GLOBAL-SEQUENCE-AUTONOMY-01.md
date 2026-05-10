<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`GLOBAL-SEQUENCE-AUTONOMY-01`

# Runner Command

```bash
make batch BATCH=GLOBAL-SEQUENCE-AUTONOMY-01 PROMPT=prompts/batches/GLOBAL-SEQUENCE-AUTONOMY-01.md
```

# Objective

Audit the remaining Ambitions global batch train, reconcile exact remaining
batch counts, verify whether autonomous sequence preconditions are Green, make
the smallest safe queue/status/governance repairs if needed, and update the
final autonomous global-train prompt so it can run the remaining train through
the hybrid runner only after prerequisites are Green.

This is a global train orchestration, governance, and queue-hardening batch.
Do not implement app features, modify app UI, or run the global train.

# Active Source Truth To Inspect

Read these first, in order:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/IMPLEMENTATION_TRUTH.md`
4. `docs/truth/RELEASE_TRUTH.md`
5. `docs/truth/CODEX_PROCESS_TRUTH.md`
6. `docs/truth/HISTORICAL_POLICY.md`
7. `AGENTS.md`
8. `.codex/state/active-batch.yml`
9. `.codex/reports/current-batch-train-state.md`
10. `docs/codex/BATCH_REGISTRY.md`
11. `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`
12. `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
13. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
14. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md`
15. `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
16. `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
17. `docs/codex/POST_BATCH_GATE_REGISTRY.md`
18. `docs/codex/MODEL_TIER_EXECUTION_POLICY.md`
19. `docs/codex/MODEL_TIER_BATCH_MATRIX.md`
20. `docs/audits/global-sequence-autonomy-audit.md`
21. `prompts/batches/AUTO-HARDEN-01.md`
22. `scripts/ambitions-codex-train.sh`
23. `scripts/ambitions-wrap-prompt.sh`
24. `scripts/ambitions-prompt-audit.sh`
25. `Makefile`
26. `prompts/_RUNNER_REQUIRED_HEADER.md`
27. `prompts/_BATCH_TEMPLATE.md`
28. `docs/codex/ambitions-hybrid-runner.md`

Also inspect directly referenced queue, route, manifest, closeout, or runner
proof files needed to prove current train state.

# Questions This Batch Must Answer

Compute and report:

- `executable_now`
- `executable_later`
- `blocked_until_dependency`
- `absorbed_as_overlay`
- `conditional_trigger_only`
- `historical_complete_do_not_run`
- `unknown_requires_repair`

Report derived totals:

```text
normal autonomous remaining = executable_now + executable_later
real future work remaining = executable_now + executable_later + blocked_until_dependency
non-historical non-complete universe = executable_now + executable_later + blocked_until_dependency + absorbed_as_overlay + conditional_trigger_only
```

Do not count `historical_complete_do_not_run` as remaining runnable work.

# Perfect Sequence Definition

The sequence is perfect only when:

- active truth files are obeyed
- live unfinished current-run state wins over fallback queue
- the next eligible batch is unambiguous
- no completed/historical batch is runnable
- no overlay is incorrectly treated as a standalone normal batch
- no conditional trigger is in the normal autonomous path unless named
- dependency-blocked batches are not run early
- PK storage/data-safety/platform foundations run before dependent claims
- Source Atlas batches become reachable before source-dependent LDI/AOS/FCP/PFC claims
- UI recovery gates are respected before visible top-level expansion
- EFC overlays are inherited by owner batches unless no owner can produce proof
- RHC hygiene tail does not block implementation unless hygiene Hard Red exists
- Time is the active top-level destination
- Plan remains only an internal compatibility seam or contextual/action noun
- queue docs do not revive obsolete IA, stale release claims, hosted CI assumptions, or external/cloud LLM core architecture
- the hybrid runner can execute every normal remaining batch or prerequisite blockers are explicit

If the sequence is already Green/perfect, do not churn queue files.

# Required Output Files

Create or update:

```text
docs/audits/global-sequence-autonomy-audit.md
prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md
```

The audit must include:

```markdown
# Global Sequence Autonomy Audit

## Status
Green / Yellow / Red

## Remaining Batch Counts
- executable_now:
- executable_later:
- blocked_until_dependency:
- absorbed_as_overlay:
- conditional_trigger_only:
- historical_complete_do_not_run:
- unknown_requires_repair:

## Derived Totals
- normal autonomous remaining:
- real future work remaining:
- non-historical non-complete universe:

## Next Eligible Batch
- canonical next:
- visible/UI recovery next, if different:
- non-UI platform next, if different:

## Sequence Verdict
Perfect / Needs repair / Red

## Sequence Rules Applied
- rule
- evidence

## Queue Repairs Made
- path -- change

## Queue Repairs Not Made
- path/reason

## AUTO-HARDEN-01 Status
- found / not found / created / completed / blocked
- evidence path
- whether it is required before autonomous full-train execution

## Final Autonomous Run Prompt
- path
- status
- blocked/unblocked

## Validation
Commands run:
Commands not run:

## Claims Not Made
- release readiness
- build success
- test success
- visual quality
- accessibility conformance
- performance validation
- device validation
- TestFlight/App Store readiness
```

If `AUTO-HARDEN-01` is Green and this batch closes Green, remove any stale
statement that the final autonomous prompt is blocked until these two
prerequisites are Green. Preserve all no-claim boundaries.

# AUTO-HARDEN-01 Requirement

Verify `AUTO-HARDEN-01` using committed evidence such as:

- `prompts/batches/AUTO-HARDEN-01.md`
- `.codex/runs/AUTO-HARDEN-01/*/final-summary.md`
- `docs/audits/auto-harden-01-report.md`
- runner hardening changes matching the required behavior

If it is missing or Red, stop with Red. Do not run `AUTO-HARDEN-01` from this
batch.

# Allowed Scope

You may modify only:

```text
docs/audits/global-sequence-autonomy-audit.md
docs/codex/BATCH_REGISTRY.md
docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md
docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md
docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md
docs/codex/POST_BATCH_GATE_REGISTRY.md
docs/codex/CONTEXT_INDEX.md
.codex/state/active-batch.yml
.codex/reports/current-batch-train-state.md
prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md
prompts/batches/GLOBAL-SEQUENCE-AUTONOMY-01.md
```

# Forbidden Scope

Do not modify:

```text
Native/
Sources/
AppUI/
Package.swift
project.yml
docs/truth/
docs/status/release-evidence-packet.md
docs/status/current-implementation-map.md
Native/AmbitionsTests/
Native/AmbitionsUITests/
scripts/
Makefile
```

Do not implement app features, run the global train, execute PK14 or any other
implementation batch, delete historical material, add hosted CI, add
dependencies, add signing/TestFlight/App Store automation, add external/cloud
LLM behavior, weaken validation gates, or claim readiness/proof without
evidence.

# Validation Expectations

Run and record exact command, exit code, and result:

```bash
git diff --check
python3 -m json.tool docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json >/tmp/ambitions-global-queue-json-check.txt
bash -n scripts/ambitions-codex-train.sh
bash -n scripts/ambitions-wrap-prompt.sh
bash -n scripts/ambitions-prompt-audit.sh
test -x scripts/ambitions-codex-train.sh
test -x scripts/ambitions-wrap-prompt.sh
test -x scripts/ambitions-prompt-audit.sh
make -n batch BATCH=TEST PROMPT=prompts/_BATCH_TEMPLATE.md
make -n prompt-audit
make -n batch-status
scripts/ambitions-prompt-audit.sh
scripts/ambitions-codex-train.sh --self-check
```

Also run a forbidden app-source touch check. Do not run the global train or a
real implementation batch.

# Hard Red Stop Conditions

Stop immediately with Red if:

- active truth files cannot be read
- canonical queue files cannot be parsed
- remaining counts cannot be reconciled
- next-batch state is contradictory and cannot be safely repaired
- `AUTO-HARDEN-01` is missing or not Green
- final autonomous run prompt cannot be generated or unblocked after proof
- runner is required but missing
- app source would need to be touched
- `docs/truth/*` would need to be touched
- validation fails in a way that makes the queue unsafe
- any unsupported release/readiness/accessibility/performance/visual claim would be introduced
- this batch tries to run the global train

# Rollback Expectations

Before mutation, record starting branch and commit. For docs/prompt changes,
rollback by path-limited restore from starting SHA if uncommitted, or by
`git revert <commit-sha>` if committed by the runner. Do not run broad
destructive cleanup.

# Final Report Format

End with:

```markdown
## Status

STATUS: GREEN | STATUS: YELLOW | STATUS: RED

## Scope

What was requested and what was actually done.

## Remaining Batch Count

- executable_now:
- executable_later:
- blocked_until_dependency:
- absorbed_as_overlay:
- conditional_trigger_only:
- historical_complete_do_not_run:
- normal autonomous remaining:
- real future work remaining:
- non-historical non-complete universe:

## Sequence Verdict

- perfect / repaired / blocked / red
- next canonical batch:
- next visible/UI recovery pass:
- next non-UI platform batch:

## Files Changed

- path -- reason

## Queue Repairs

- path -- change

## AUTO-HARDEN-01

- found / completed / blocked
- evidence:
- required before full autonomous run: yes/no

## Final Autonomous Run Prompt

- path:
- status:
- blocked/unblocked:
- runner command:

## Validation

Commands run:
- command -- exit code -- result

Commands not run:
- command -- reason

## Risks / Remaining Gaps

- gap
- impact
- next proof

## Claims Not Made

- release readiness
- build success
- test success
- visual quality
- accessibility conformance
- performance validation
- physical-device validation
- TestFlight/App Store readiness
- actual global train completion

## Next Recommended Step

One bounded next step only.
```
