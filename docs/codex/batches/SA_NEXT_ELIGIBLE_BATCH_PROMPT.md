# Source Atlas Next Eligible Batch Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Reusable Codex prompt for SA01-SA32.
Date: 2026-05-06

```markdown
You are operating in the Ambitions repo as a full FAANG-level product, iOS, AI systems, privacy, platform, design, QA, and strategy organization.

Task:
Run exactly one next eligible Source Atlas batch unless the active global prompt authorizes continuous global execution.

Do not replay completed batches.
Do not implement hosted AI, user-data server, CloudKit sync, account system, source-pack marketplace, official database, or new top-level UI.

Required source stack:
1. README.md
2. AGENTS.md
3. docs/canon/Ambitions_Source_Atlas.md
4. docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md
5. docs/codex/SOURCE_ATLAS_GATE_MATRIX.md
6. docs/codex/SOURCE_ATLAS_UNIVERSAL_SOURCE_BINDER_COVERAGE_MAP.md
7. docs/codex/SOURCE_ATLAS_UI_OBJECT_LANGUAGE.md
8. docs/codex/SOURCE_ATLAS_CODEX_OS_UPGRADE_MAP.md
9. docs/codex/SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP.md
10. docs/codex/GLOBAL_SOURCE_ATLAS_COMPLETION_ORDER_OVERLAY.md
11. docs/canon/Ambitions_Human_Progress_Systems_Upgrade.md
12. docs/codex/HPS_GATE_MATRIX.md
13. docs/codex/HPS_CROSS_TRAIN_INTEGRATION_MAP.md
14. docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md
15. docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md
16. docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
17. docs/codex/BATCH_REGISTRY.md
18. docs/codex/CONTEXT_INDEX.md
19. .codex/reports/current-run-state.md
20. .codex/reports/current-batch-train-state.md

Preflight:
- Run `git status --short`.
- Confirm live active batch and next eligible batch.
- Select the next eligible SA batch only if HPS/order dependencies permit it.
- State selected batch, owner, dependencies, allowed files, forbidden files, validation, and stop conditions.

Source Atlas laws:
- Source Atlas is not a surface, tab, or marketplace.
- Universal Source Binder must support all scoped containers or remove unsupported ones from scope before implementation.
- User-provided/OCR/copied content is not official.
- Job postings are example market evidence, not universal career requirements.
- School/certification/legal/civic/professional claims require strict review and no certainty.
- No imported claim mutates goals, proof, memory, schedule, recommendations, or privacy without review/receipt.
- App must work offline from bundled/cached/source-needed states.
- Source packs must validate before use.
- Stale high-risk claims cannot drive recommendations as current.
- UI-affecting Source Atlas work requires rendered proof.

Required validation:
- `git status --short`
- `git diff --check`
- relevant focused tests
- `scripts/sa-source-container-coverage-scan.sh || true`
- `scripts/sa-pack-schema-validate.sh || true`
- `scripts/sa-no-claim-scan.sh || true`
- `scripts/sa-offline-fallback-scan.sh || true`
- relevant CQS/FVQ scripts

Report:
Write `docs/audits/saXX-<kebab-name>-report.md` with:
- Result
- batch ID
- files read
- files changed
- Source Atlas primitives touched
- source containers touched
- document categories touched
- source states covered
- privacy states covered
- review flow status
- no-claim scan status
- offline fallback status
- FVQ rendered proof status if UI-affecting
- AOS/LDI integration status if relevant
- validation run
- Yellow items
- Hard Red status
- rollback path
- next eligible batch

Stop on Hard Red:
- Source Atlas tab/dashboard/marketplace
- user-provided source labeled official
- OCR output treated as truth without review
- source-free official requirement
- high-risk stale claim drives current recommendation
- private document leak
- hidden mutation
- internet-required core behavior
- hosted AI/user-data-server/live-API dependency without explicit authorization
- unsupported legal/career/education/professional certainty

Final response:
- Result
- selected batch
- files changed
- validation result
- unresolved Yellow items
- next eligible batch
```

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
