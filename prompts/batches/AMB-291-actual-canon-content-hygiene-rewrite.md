<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

Issue: AMB-291 — Perform actual canon content and hygiene rewrite pass

## Batch ID

`AMB-291-actual-canon-content-hygiene-rewrite`

Accepted Yellow policy:
- owner: repo canon cleanup owner for AMB-291 docs/prompts-only pass
- reason: runner/process guard may return Yellow in historical replay context while still permitting safe docs-only progress
- no-claim boundary: no build, app, TestFlight, release, accessibility, privacy/legal, or device readiness claims
- follow-up gate: retain guard artifacts and require explicit subsequent implementation gate run before any source-changing continuation
- affected canonical owner: docs/prompts canon cleanup only; no app/runtime/source owners changed

## Active Source Truth

Read these before editing:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `README.md`
10. `docs/README.md`
11. `project.yml`
12. `Package.swift`

Lower-authority docs, prompts, reports, queue snapshots, and historical canon must not override `docs/truth/*` or live source/proof evidence.

## Objective

Move beyond disposition reports and actually rewrite/clean active repo canon and prompt documents where prior reports identified safe, docs-only remediation.

This is a content/hygiene pass, not a report-only pass.

## Allowed Scope

- Rewrite retired IA and terminology in active docs/prompts.
- Add explicit active/historical/quarantined headers to ambiguous docs.
- Add missing source-of-truth references to active prompt docs where the governing file is obvious.
- Normalize Linear/repo-truth non-claim boundaries.
- Mark stale prompt docs as historical/quarantined when they should not drive future implementation.
- Produce a rewrite report with exact changed files and before/after classes.
- If a later approved scope becomes runtime-affecting, it must carry `SourceRecord`, `Receipt`, `ReplayTrace`, and `You`/`What Ambitions knows` inspection wiring before any Green claim.

## Forbidden Scope

- Do not edit Swift/source code.
- Do not delete/archive files.
- Do not edit docs/truth/*.
- Do not claim build/test/release readiness.
- Do not add app runtime dependencies, hosted services, analytics, telemetry, cloud AI, external LLM, signing automation, App Store automation, or hosted CI.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not treat historical docs, queue snapshots, disposition reports, or prompt text as implementation, validation, accessibility, privacy, device, release, TestFlight, or App Store proof.

## Required Outputs

- docs/ops/canon-collapse/actual-canon-content-hygiene-rewrite.md
- docs/ops/canon-collapse/actual-canon-content-hygiene-rewrite.json

## Validation

Run:

```bash
git diff --check
python3 -m json.tool docs/ops/canon-collapse/actual-canon-content-hygiene-rewrite.json >/tmp/amb291-report-json-check.json
python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-291-actual-canon-content-hygiene-rewrite --prompt prompts/batches/AMB-291-actual-canon-content-hygiene-rewrite.md --changed-from f836649bb8ac18113b1546fffada016f82178771
```

Do not run Xcode validation for this docs/prompts-only phase.

## Hard Red

Stop and report Red if any of these occur:

- Swift/source, project, package, entitlement, privacy manifest, resource, or `.xcodeproj` changes are required.
- `docs/truth/*` must be edited to make the pass coherent.
- A file must be deleted, archived, or moved.
- The pass would create or preserve active guidance that conflicts with `docs/truth/*`.
- A runtime-affecting continuation lacks `SourceRecord`, `Receipt`, `ReplayTrace`, and `You` inspection wiring.
- Any build, test, release, accessibility, privacy/legal, device, TestFlight, App Store, or production-readiness claim is needed without current proof.

## Rollback

Restore only this phase's approved files:

```bash
git restore -- prompts/batches/AMB-291-actual-canon-content-hygiene-rewrite.md docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md docs/codex/batches/AOS29_AmbitionsOS_Repair_Train_Prompt.md docs/ops/canon-collapse/actual-canon-content-hygiene-rewrite.md docs/ops/canon-collapse/actual-canon-content-hygiene-rewrite.json
```

## Acceptance Gates

- The pass changes actual docs/prompts, not only reports.
- Every changed file is listed with reason and safety class.
- Ambiguous historical/stale files get explicit non-active headers.
- Active prompts have current authority references where safe.
- No source code changes occur.
