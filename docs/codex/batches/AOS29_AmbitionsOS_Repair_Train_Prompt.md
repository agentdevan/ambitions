# AOS29 AmbitionsOS Repair Train Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-81883364, AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-54089190, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-83544260, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Historical work-order prompt; not active canon until sequenced by an approved owner gate.

## Batch Identity

- Batch ID: `AOS29`
- Name: AmbitionsOS Repair Train
- Owning kernel: Governance Kernel
- Current active user-facing IA: Today / Goals / Capture / Time / You
- `Plan` remains an internal compatibility seam unless a scoped migration changes it.
- Affected surface: repair scope only
- Dependency gate: runs only after the owner classifies the relevant review/Yellow AOS gates
- Implementation boundary: classified repair only after the owner-approved gate sequence

## Active Source Truth

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`
- The current manifest and queue authority files named by the active truth set.

## Allowed Scope

- `docs/**` and `.codex/**` for planning, reports, traceability, fixtures, and evidence.
- Future implementation files only when this exact batch explicitly scopes them after preflight and names them.
- Test files and preview fixtures that directly prove this batch's contract.

## Forbidden Scope

- `.github/workflows/**`
- Dependency manifests and package manager lockfiles.
- Signing, project release config, and entitlement changes unless a separately approved platform train owns them.
- Persistence/schema files unless this batch is explicitly a schema/migration batch and has Green migration review.
- External route, App Intent, widget, Live Activity, EventKit, CloudKit, StoreKit, sync, backend, account, telemetry, analytics, crash reporting, remote config, or AI API implementation unless a later approved train owns that capability.
- Any new top-level navigation destination.

## Purpose

Move exactly this batch's AmbitionsOS contract or implementation slice forward without widening Ambitions into a chatbot, generic productivity app, calendar clone, source-certification authority, or broad AI assistant. Preserve current Ambitions behavior unless this batch explicitly owns a tested behavior change.

## Living Dream Architecture Hook

LDI hook: Map any Living Dream requirement to existing AOS kernel contracts only if this batch explicitly owns the kernel seam; otherwise defer to LDI01-LDI22.

## Validation

Use focused validation first and broaden only if the focused proof is Green.

- `git diff --check`
- `python3 -m json.tool docs/ops/canon-collapse/actual-canon-content-hygiene-rewrite.json >/tmp/amb291-report-json-check.json`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-291-actual-canon-content-hygiene-rewrite --prompt prompts/batches/AMB-291-actual-canon-content-hygiene-rewrite.md --changed-from f836649bb8ac18113b1546fffada016f82178771`

Do not run Xcode validation for this docs/prompts-only phase.

## Hard Red

- Do not edit Swift/source code.
- Do not delete, archive, or move files.
- Do not edit `docs/truth/*`.
- Do not claim build, test, release, accessibility, privacy/legal, device, or platform readiness.
- If a later approved scope becomes runtime-affecting, it must carry `SourceRecord`, `Receipt`, `ReplayTrace`, and `You` inspection wiring before any Green claim.

## Rollback

Restore only the files touched by this phase if the content or guard outputs show drift:

```bash
git restore -- prompts/batches/AMB-291-actual-canon-content-hygiene-rewrite.md docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md docs/codex/batches/AOS29_AmbitionsOS_Repair_Train_Prompt.md docs/ops/canon-collapse/actual-canon-content-hygiene-rewrite.md docs/ops/canon-collapse/actual-canon-content-hygiene-rewrite.json
```

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- `rg -n "AOS29|Governance Kernel|AmbitionsOS|release ready|App Store ready|TestFlight ready|Current active top-level IA|Plan remains an internal compatibility seam|historical work-order prompt|docs/truth/" docs .codex Native README.md AGENTS.md || true`

Proceed only on `main`, with a coherent worktree, no unclassified user changes in target files, and a Green predecessor gate recorded in the AOS dependency graph.

## Required Evidence Outputs

- Batch report under `docs/ops/canon-collapse/actual-canon-content-hygiene-rewrite.md`
- JSON report under `docs/ops/canon-collapse/actual-canon-content-hygiene-rewrite.json`
- Evidence ledger entry
- Traceability matrix update
- Test impact matrix update
- Registry/context/run-state update after evidence, not before
- Failure-forensics report if any focused or broad proof is Red or unclassified Yellow

## Green / Yellow / Red Criteria

Green: predecessor gate is Green, only allowed files changed, focused proof passes, evidence is recorded, release claims remain bounded, and no invariant is violated.

Yellow: advisory docs/tooling backlog, optional tool absence, simulator/environment instability, or future-only gap is classified with no app behavior or claim risk.

Red: forbidden file touched, dependency/workflow/release config drift, unclassified validation failure, source-truth overclaim, privacy leak, hidden model mutation, compatibility uncertainty, performance budget violation, new top-level surface, or release/platform readiness claim without proof.

## Stop Conditions

Stop on Red, missing predecessor gate, dirty target files owned by someone else, unclear owner, untrusted validation, missing rollback path, release-claim ambiguity, privacy ambiguity, or a request to broaden beyond AOS29.

## Rollback / Repair Expectations

Preserve failing logs, classify the failure, revert only your own changes if rollback is required, do not weaken tests to pass, and open AOS29 repair only when the failure is classified and the train rules allow it.

## What This Batch Must Not Claim

It must not claim AmbitionsOS is implemented, that Ambitions has an on-device reasoning engine, that Calendar/Reminders replacement exists, that official requirements are verified, or that the app is release/App Store/TestFlight/device/accessibility/platform ready.

## What This Batch Does Not Prove

This batch does not prove physical-device behavior, public accessibility conformance, signed archive validation, App Store Connect validation, external-platform rendering, production model behavior, backend availability, or future AOS batch readiness beyond the next named gate.

## Commit Message Recommendation

`Run AOS29 AmbitionsOS Repair Train`

## Next Safe Prompt / Next Gate

Proceed only to the next AOS batch named by `docs/codex/AMBITIONSOS_AOS_DEPENDENCY_GRAPH.md` after this batch is Green, committed, pushed, and recorded. Yellow or Red starts the repair/failure-forensics path instead of automatic continuation.

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
