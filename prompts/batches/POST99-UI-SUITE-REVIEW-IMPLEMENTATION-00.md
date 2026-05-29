<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: duplicate_stable_id, retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-duplicate_stable_id-27437331, AMB28-retired_ia_or_terminology_reference-98509272, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-authority, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00

## Mission

Activate the executable UI Suite review and implementation lane after the completed bounded moat/runtime proof.

This batch exists because:

- `AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md` already recommends UI Suite review and implementation after core-loop proof/backend repair.
- Repo Doctor and Codex OS currently report `idle` because the recommendation was not registered as an executable train.

This batch must bridge recommendation -> executable implementation routing.

## Required reads

1. `docs/codex/batch-trains/post99-ui-suite/README.md`
2. `docs/codex/reports/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md`
3. `docs/audits/amb-fe-be-integrated-proof-99-report.md`
4. `frontend/visual-encyclopedia/**`
5. `.codex/skills/**`
6. `.codex/operations/**`
7. `docs/truth/**`

## Objectives

1. Inspect the currently installed UI review/QA/visual/reliability systems.
2. Build an executable UI Suite batch map.
3. Determine the safest next UI implementation/review batch.
4. Register a non-idle next executable action for Repo OS / Codex OS.
5. Avoid duplicate train invention when equivalent batches/skills already exist.

## Explicit focus areas

- Reality Meridian review and refinement
- Start Here integration quality
- Living Chrome / shell continuity
- LifeShape Field implementation quality
- Capture Atmosphere implementation quality
- proof/receipt presentation quality
- screenshot readiness
- preview matrices
- accessibility evidence
- motion/haptics review
- visual regression proof
- anti-generic drift enforcement

## Forbidden behavior

Do not:

- claim release readiness
- claim App Store readiness
- claim accessibility conformance without proof
- claim device proof without proof
- bypass the runner
- create a generic productivity UI train
- create chatbot/dashboard/task-manager framing
- overwrite existing source truth

## Required output

At minimum:

- executable next-batch recommendation
- updated queue/activation evidence if required
- concrete runner command
- explicit Green/Yellow/Red status
- no idle fallback remaining if a safe executable UI batch exists

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
