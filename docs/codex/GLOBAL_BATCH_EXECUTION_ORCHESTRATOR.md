# Global Batch Execution Orchestrator

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-37136745, AMB28-same_surface_multiple_active_batches-66075429

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Ambitions 4.0 execution-program orchestrator; full-stack completion order overlay active; no queued train started by this document
Date: 2026-05-05

## Purpose

This orchestrator tells future Codex sessions how to select, execute, validate, repair, commit, and continue globally ordered batches without weakening Ambitions product quality, repo quality, platform quality, legal/privacy posture, or truth.

This document does not start REC, PXOS, ME, CS, SI, Product Depth, FCP, PFC, AOS, LDI, release, or any implementation train.

Ambitions 4.0 is the active post-3.0 execution program, not a shipped product version. Queued 4.0 batches are not implemented and not release-proven until a batch runs, validates, commits, and records evidence.

## Global Order Source

Use this order for remaining work:

1. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md` — active highest-priority overlay for full app/repo/platform/framework/legal completion.
2. `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md` — prior optimized overlay for product/FCP/AOS/LDI ordering where PFC is not involved.
3. `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md` — historical global order, completed-batch evidence, and stable batch identity map.
4. Train manifests under `docs/codex/batch-trains/` — batch-local dependencies, boundaries, and gates.
5. Batch prompts under `docs/codex/batches/` — exact selected-batch instructions.
6. `docs/canon/Ambitions_Codex_Quality_System.md` and
   `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md` — recurring quality,
   repair, and review gates for every later batch.
7. `docs/codex/visual-quality/FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL.md`
   — recurring rendered proof gate for every UI-affecting batch.

When the full-stack order, optimized order, historical order, or train manifest conflict for remaining queued work, use the stricter dependency, stricter gate, or safer order. Stop and write a reconciliation report if the conflict affects safety.

## Approval Phrases

Do not treat vague language as execution approval.

- `Run Next Global Batch`: run only the next eligible globally ordered batch.
- `Run Global Batch Sequence Until Blocked`: run global batches in full-stack order until a Red, human-proof requirement, explicit approval gate, weak validation condition, unsafe condition, or user stop blocks continuation.
- `Continue Release Evidence Closure`: continue REC only.
- `Start PXOS Future-Canon Train`: start PXOS future-canon train only.
- `Start ME Train`: start ME only.
- `Start CS Train`: start CS only.
- `Start Signature Interface Train`: start SI only.
- `Start Product Depth Train`: start Product Depth only.
- `Start Flagship Completion Train`: start FCP only.
- `Start Platform Framework Compliance Train`: start PFC only.
- `Start AOS Train`: start AOS only.

This global sequencing prompt is not an approval phrase to execute a future batch.

When a current user prompt says the exact phrase `Run Global Batch Sequence Until Blocked` and explicitly preauthorizes cross-train Ambitions 4.0 execution, that approval satisfies routine train transition approval for the next eligible batch in `GLOBAL_FULL_STACK_COMPLETION_ORDER.md`. This preauthorization is only permission to attempt the next eligible batch. It does not satisfy proof, validation, release, platform, visual-approval, privacy/legal, App Store Connect, TestFlight, signed archive, physical-device, public accessibility, or final release decision requirements.

## Execution Loop

1. Confirm branch is `main` unless the user explicitly requested otherwise.
2. Run `git status --short`, current branch, HEAD, and latest commit.
3. Select the next eligible batch from `GLOBAL_FULL_STACK_COMPLETION_ORDER.md`.
4. Cross-check the selected batch against `GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`, `GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`, the dependency graph, train manifest, and batch prompt.
5. Read the batch prompt or, if the full-stack order names a reconciliation/planning step, read the named reconciliation/planning prompt or train manifest.
6. Read all source truth required by that batch.
7. Confirm the exact approval phrase exists for the batch/train/mode, or that the current prompt's global cross-train sequence preauthorization explicitly covers the selected train.
8. Confirm all prerequisite gates are Green or accepted Yellow.
9. Confirm no blocker exists.
10. Create a narrow implementation or docs plan with allowed/forbidden files.
11. Invoke required skills/review boards and record gate outputs.
12. Implement only the batch scope.
13. Run required validation and classify validation strength as Strong, Adequate, Weak, or Missing.
14. Classify the batch through CQS as Green, Accepted Yellow, Recoverable Red,
    or Hard Red.
15. If Green, update evidence, registry/context/run-state as required, stage,
    commit, and continue only if continuation rules allow.
16. If Accepted Yellow, document owner, why safe, repair path, and explicit
    no-claim boundary, then continue only if safe.
17. If Recoverable Red, repair in scope, rerun validation, or split a narrow
    repair batch when safer.
18. If Hard Red, stop forward progress and write a stop report.
17. Commit only after Green or accepted Yellow.
18. Continue to the next full-stack batch only when the continuation protocol allows.

## Single-Batch Mode

Use single-batch mode when:

- Code implementation is involved.
- Human review or human proof is needed.
- Validation is expensive or uncertain.
- Release proof or claim boundaries are involved.
- Compatibility seams are touched.
- Top-level UI surfaces are touched.
- FCP flagship objects are touched.
- PFC platform/framework/legal/security/schema/sync/monetization work is touched.
- AOS runtime/intelligence is touched.
- LDI runtime/safety/source/continuity is touched.
- The task is risky or broad.

Run one batch, validate, repair if needed, commit, report, and stop.

## Continuous Mode

Continuous mode is allowed only when:

- The user says `Run Global Batch Sequence Until Blocked`.
- Batches are docs-only or low-risk.
- Each batch can be committed independently.
- No human proof is required.
- Validation strength is Strong or Adequate.
- No batch requires a separate approval phrase outside the current global cross-train preauthorization.
- Train control and full-stack global order both allow continuation.

Continuous mode means implement, validate, repair, commit, then continue. It never means pushing through failures.

Continuous mode has no arbitrary batch-count cap. After compaction, resume, or long-run context refresh, reload the 4.0 execution source truth, the last completed batch report, the full-stack order, and the next selected prompt before continuing.

## Gate Sequence

Run gates in this order unless the batch prompt adds stricter sequencing:

1. Source Truth Gate.
2. Full-Stack Order Selection Gate.
3. Scope Boundary Gate.
4. Product Decision Lock Gate.
5. Batch-type gates from the relevant gate matrix.
6. Product Drift Gate.
7. Platform / Framework / Legal Gate when PFC or platform behavior is touched.
8. Validation Evidence Gate.
9. FVQ Rendered Proof Gate when a batch touches visible UI, shell/chrome,
   visual primitives, preview fixtures, widgets, Live Activities, App Intents
   confirmations, notifications, onboarding, screenshots, motion/haptics with
   visual state, or accessibility presentation.
10. Validation Strength Gate.
11. Handoff Gate.
12. Rollback Gate.
13. Continuation Gate.

## CQS Repair Cycle

Every batch now uses the Codex Quality System repair cycle:

1. Execute.
2. Validate.
3. Classify as Green, Accepted Yellow, Recoverable Red, or Hard Red.
4. Repair Recoverable Red in scope.
5. Split a narrow repair batch only when it reduces risk.
6. Commit only Green or Accepted Yellow.
7. Stop only on Hard Red.

Hard Red means continuing could break the app, corrupt data/schema, severely
drift canon, hide security/privacy risk, require unsupported legal/privacy/
release claims, require human legal/device/App Store/signing/credential proof,
or require weakening gates, deleting tests, or lying in docs.

## FVQ Recurring Rendered Proof Gate

Every UI-affecting batch must classify its rendered-proof impact before it can
close:

- `FVQ not applicable`: no visible UI, preview, screenshot, external surface,
  motion/haptic visual state, or accessibility presentation changed.
- `FVQ inherited`: visible risk is already covered by a current FVQ artifact
  and the batch did not materially change rendered output.
- `FVQ produced`: durable screenshot or rendered preview evidence, freshness
  proof, visual score, accessibility/readability impact, Reduce Motion impact,
  privacy-sensitive rendering impact, dashboard/card-stack drift result, and
  repair decision were recorded in the batch report.
- `FVQ operator checklist`: tooling, device, or external-surface constraints
  prevented rendered proof; the batch may close only Accepted Yellow with an
  explicit owner, proof checklist, no-claim boundary, and no Hard Visual Red.

A UI-affecting batch may not close Green from compile, tests, or docs alone.
If rendered output is materially worse, screenshot freshness cannot be proven,
or a primary object becomes dashboard/card-stack/prototype/generic, classify as
Recoverable Red or Hard Red according to CQS/AQOS.

## Skills And Review Boards

Always invoke or map an equivalent protocol for:

- Source truth / canon review.
- Codex prompt quality review.
- Evidence / validation review.
- Release claim safety review.
- Product decision lock review.
- Scope boundary review.
- Full-stack order / dependency review.
- CQS reviewer selection and anti-agentic-slop review.

Use additional reviewers by batch type:

- PXOS/user-facing: PXOS surface hierarchy, product-depth/deep-not-wide, top-level composition, premium visual, product language, accessibility/cognitive-load, recovery, trust/proof.
- ME/code maintainability: maintainability, large-file extraction, testability, file-size/diff-size.
- CS/compatibility: compatibility migration, route/raw value/external surface, persistence/import/export if relevant.
- SI/signature UI: signature-interface creative director, Ambitions-native UI primitive, top-level surface composition, IA/shell/navigation, interaction/motion/haptics, accessibility adaptive interface, visual QA/preview fixture, iconography/symbol, loading/degraded state, file-size/component boundary, and release-claim safety.
- FCP/flagship completion: 10/10 object standard, anti-generic UI, receipt/proof/source, accessibility/reduced-motion, file-boundary, top-level object identity, and full-app audit.
- PFC/platform-framework-compliance: build/repo hygiene, architecture/schema, iCloud/CloudKit, WidgetKit, ActivityKit, App Intents, notifications, StoreKit/monetization, privacy manifest, App Store privacy labels, legal review packet, security, performance/battery, observability, release engineering, and FAANG handoff.
- AOS/intelligence: runtime contract, privacy/trust, recommendation/source-truth, fallback/degraded-state.
- LDI/living dream: safety/legality/feasibility, source claim graph, pack integrity, mutation permissions, professional boundary, privacy/local-first, red-team evaluation.
- REC/release: release evidence, claim boundary, human proof.
- CQS/Codex OS: staff iOS architecture, SwiftUI composition, visual quality,
  anti-agentic-slop, canon drift, accessibility/reduced-motion, privacy/legal/
  App Store, performance/battery, platform surface, StoreKit, schema/sync/
  migration, and FAANG handoff reviewers as applicable.
- FVQ/visible UI: FAANG rendered visual reviewer, AQOS impact/evidence
  classifier, accessibility/reduced-motion reviewer, product canon drift
  reviewer, and privacy-safe rendering reviewer.

If a required skill does not exist, map to an existing equivalent skill, define the review behavior in the batch report, or document the gap as Yellow only if safe.

## Validation Strength Rules

- Strong: focused tests/build/scans directly cover the changed behavior and batch risks.
- Adequate: docs/evidence scans cover the docs-only or audit-only batch risks.
- Weak: validation is indirect, partial, or missing a relevant risk area.
- Missing: required validation did not run and no acceptable substitute exists.

Implementation batches with Weak or Missing validation are Red unless a documented repo/tooling constraint and near-term validation owner make the risk nonblocking. Docs-only batches may pass with Adequate validation and advisory doc QA when findings are classified.

## Stop Conditions

Stop on:

- Unresolved Red.
- Human proof requirement.
- App Store Connect, signing, hardware, public accessibility, external rendered proof, legal/privacy signoff, or release decision requirement.
- Forbidden file touch.
- Weak/Missing implementation validation.
- Missing approval phrase or missing current global cross-train preauthorization.
- Unsafe dirty worktree.
- Source truth conflict affecting safety.
- Full-stack order and train manifest conflict affecting safety.
- Product degradation proposed as a repair.
- Top-level surface composition violation.
- SI/FCP primitive generic/dashboard/card-stack drift.
- Missing Reduce Motion equivalent for motion work.
- Uncontrolled component/file-size regression.
- Unsupported release/platform/PXOS/AmbitionsOS/FCP/PFC/LDI implementation claim.
- Privacy label, privacy manifest, or legal compliance claim that outruns actual behavior.
- Sensitive content in logs, widgets, Live Activities, notifications, analytics, or diagnostics.
- StoreKit/paywall dark pattern or entitlement ambiguity.
- iCloud/CloudKit sync conflict behavior undefined when sync is implemented.
- LDI unsafe operationalization, professional-boundary breach, or user-data-server claim.

## Commit Rules

- Commit only after Green or accepted Yellow.
- Commit one batch at a time.
- Do not bundle unrelated repairs.
- Do not commit if `git diff --check` fails.
- Do not commit if changed files violate the allowed boundary.
- After commit, confirm branch cleanliness before any continuation.

## No-Degradation Rules

Codex must not resolve a failure by weakening product canon, UX, accessibility, architecture, maintainability, compatibility, privacy, release truth, legal posture, platform quality, or validation quality. Codex must not delete tests, loosen gates, hide failures in docs, or replace Ambitions-specific requirements with generic productivity language to make a batch pass.

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
