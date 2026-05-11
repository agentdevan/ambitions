<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Ambitions Remaining Batch Execution Standard

This template is inherited by remaining executable global-train prompts created or rebuilt by GLOBAL-PROMPT-REBUILD-REMAINING-01.

## Operating mode

Run only through the Ambitions runner: GPT-5.5 plan → GPT-5.3-Codex-Spark bounded patch → GPT-5.5 review/repair/final commit readiness assessment. Direct Codex execution is forbidden unless the user explicitly bypasses the runner.

## Global invariants

- Completed batches must not be reactivated.
- Canonical batch IDs must not be renumbered.
- Queue order must not change without active repo evidence.
- PK17-PK41 remain separate executable batch IDs.
- Active top-level IA is Today / Goals / Capture / Time / You.
- Plan is superseded as a top-level destination and may remain only as an internal compatibility seam or action/context noun where current code requires it.
- Core intelligence remains local-first and deterministic.
- External/cloud LLMs are not part of core Ambitions architecture and must not be added, authorized, implied, scaffolded, or required for core product behavior.
- Do not introduce network, sync, analytics, telemetry, hosted inference, account, backend, or cloud dependencies unless the exact batch and active source truth explicitly authorize a bounded local-only seam for future work.
- Do not make release, TestFlight, App Store, device, accessibility, performance, privacy, legal, security, production-readiness, or compliance claims without direct proof from allowed validation artifacts.
- DPTG00 remains terminal and must not become eligible until all pre-device gates close.

## Required source truth

Each inheriting prompt must inspect current repo authority before editing, including:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `.codex/state/active-batch.yml`
- `.codex/reports/current-batch-train-state.md`
- `.codex/reports/current-run-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
- `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`
- relevant train manifest under `docs/codex/batch-trains/**`
- relevant remaining-batch inventory under `docs/codex/AMB_REMAINING_BATCH_REFERENCE.*`

## Required prompt sections

Each inheriting prompt must include or materially provide:

- Batch ID
- runner command
- objective
- active source truth
- queue/dependency rule
- allowed scope
- forbidden scope
- validation expectations
- final report path and required report fields
- rollback expectations
- hard Red stop conditions
- Accepted Yellow policy
- next-batch handoff rule
- claims-not-made discipline

## Validation baseline

Every batch must run or record why it could not run:

```bash
git status --short
git diff --check
make batch-self-check || true
python3 scripts/ambitions-control-plane-check.py || true
```

Production Swift changes require `xcodegen generate` and the narrowest safe focused `xcodebuild` build/test lane. JSON changes require JSON validation. Source/provenance/freshness changes require `python3 scripts/ambitions-source-atlas-title-check.py --strict || true` where applicable. Final reports must be checked with `scripts/ambitions-final-report-gate.py` when available.

Do not hide failures behind `|| true`; record the actual result and assessment.

## Source Atlas gate

If a batch touches source claims, freshness, provenance, titles, trust history, citation surfaces, or source-backed UI:

- locate the active SA train manifest
- use canonical titles from the manifest
- forbid generic labels such as Source 1, Source 2, Doc, Document, Reference, Untitled, Generic Source, Placeholder Source, SA item, or source TBD where canonical titles exist
- distinguish source data, derived read-model data, and UI labels
- make no freshness claims without evidence

## AIR gate

If a batch touches local intelligence, ranking, suggestions, deterministic reasoning, recommendations, automations, planning logic, summaries, interpretation, claim boundaries, or assistant-like behavior:

- fold AIR obligations into that batch
- do not create a standalone AIR train
- keep behavior local-first and deterministic
- require deterministic fixtures or focused tests where applicable
- record privacy/data-minimization review

## EFC gate

If a batch touches final experience, release confidence, user-visible polish, end-to-end flows, or readiness/completion claims:

- keep EFC obligations narrow and proof-bound
- do not create broad EFC sprawl
- distinguish polish implemented from polish validated
- do not make release/readiness claims without release-grade proof

## FET/FVQ gate

If a batch touches UI implementation, interaction, visual design, navigation, screen composition, or components:

- produce simulator or equivalent visual proof when UI files are touched
- include before/after screenshots or explain why screenshots cannot be generated
- include accessibility-relevant visual notes
- make no premium/native visual claim without evidence

## Accepted Yellow policy

Accepted Yellow is allowed only for non-blocking, fully documented defects. It must include the defect, why non-blocking, affected files/scope, validation performed, risk assessment, rollback/follow-up path, and next eligible batch impact. Accepted Yellow is forbidden for safety, privacy, data loss, persistence/schema correctness, queue integrity, completed-batch reactivation, canonical ID drift, external/cloud LLM core behavior, release/readiness overclaim, Source Atlas title failure, DPTG sequencing failure, or production files outside allowed scope.

## Hard Red baseline

Stop Red if completed batches are reactivated, canonical IDs are renumbered, queue order changes without evidence, forbidden files are touched, external/cloud LLM core behavior is introduced, release/readiness claims are made without proof, AIR becomes standalone, EFC sprawls, RHC broad cleanup is pulled early, DPTG00 becomes non-terminal, validation failures are hidden, or final report evidence is missing.

## Final report fields

Every final report must include status, batch ID, objective, files changed, files intentionally not changed, queue evidence, source truth inspected, validation commands and exit codes, defects found/repaired/deferred, Accepted Yellow rationale if any, claims made, claims not made, privacy/local-first assessment, external/cloud LLM assessment, Source Atlas/AIR/EFC/FET/FVQ assessments when applicable, rollback notes, and next eligible implementation batch.
