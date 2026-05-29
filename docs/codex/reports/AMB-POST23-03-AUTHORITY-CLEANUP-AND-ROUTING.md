# AMB-POST23-03 Authority Cleanup and Routing

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-authority, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Green
Date: 2026-05-19
Batch: AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING
Stage: authority cleanup and routing

## Scope

This report classifies the current post-23 authority and routing material only.

It does not modify app source, tests, truth files, project config, package config, or runner state. It is a docs-only authority cleanup report and routing note.

The active top-level IA remains:

```text
Today / Goals / Capture / Time / You
```

`Plan` remains compatibility/contextual only in supporting material and should not be re-promoted as active top-level IA.

## Evidence Used

Primary authority:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`

Repo front-door and support docs:

- `AGENTS.md`
- `README.md`
- `docs/README.md`

Post-23 train docs:

- `docs/codex/batch-trains/post-23-truth-audit/README.md`
- `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-MANIFEST.md`
- `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-CLASSIFICATION-RUBRIC.md`
- `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-ELIGIBILITY-GATE.md`
- `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING.md`
- `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-STATUS.md`

Post-23 reports and prompts:

- `docs/codex/reports/AMB-POST23-00-COMPLETION-SENTINEL.md`
- `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md`
- `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md`
- `docs/codex/reports/AMB-POST23-TRUTH-AUDIT-REPAIR-INSTALL-01.md`
- `prompts/batches/post-23-truth-audit/AMB-POST23-00-COMPLETION-SENTINEL.md`
- `prompts/batches/post-23-truth-audit/AMB-POST23-01-TRUTH-AUDIT.md`
- `prompts/batches/post-23-truth-audit/AMB-POST23-02-UNDERDELIVERY-REPAIR.md`
- `prompts/batches/post-23-truth-audit/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md`
- `prompts/batches/post-23-truth-audit/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md`

Supporting portal guidance:

- `docs/README.md` portal index for `frontend/`, `frontend/visual-encyclopedia/`, `backend/`, `codex-os/`, `product-canon/`, `validation/`, and `history/`

## Classification Summary

| Material | Status | Why |
| --- | --- | --- |
| `docs/truth/README.md` and the truth files it indexes | Active | This is the repo authority layer. It defines current product, moat, implementation, release, process, and historical policy truth. |
| `PRODUCT_DESIGN_TRUTH.md` | Active | It is the current product/design canon, including the active IA and the `Plan` compatibility boundary. |
| `PRODUCT_MOAT_TRUTH.md` | Active | It is the current moat and anti-commodity guardrail authority. |
| `IMPLEMENTATION_TRUTH.md` | Active | It is the implementation/source truth authority for live source interpretation. |
| `RELEASE_TRUTH.md` | Active | It is the release/proof/claim authority. |
| `CODEX_PROCESS_TRUTH.md` | Active | It is the current Codex operating authority. |
| `HISTORICAL_POLICY.md` | Active | It governs historical cleanup, archive, and delete handling. |
| `AGENTS.md` | Supporting | It routes agents, but it explicitly defers to `docs/truth/*`. |
| `README.md` | Supporting | It is architectural orientation and engineering guidance, not active authority. |
| `docs/README.md` | Supporting | It is the docs portal index and routing map, not authority. |
| `docs/codex/batch-trains/post-23-truth-audit/README.md` | Supporting | It installs and sequences the post-23 train, but it is a train-control document rather than repo truth. |
| `AMB-POST23-TRUTH-AUDIT-MANIFEST.md` | Supporting | It defines the installed post-23 train set and declared scope; it is operational routing, not authority truth. |
| `AMB-POST23-TRUTH-AUDIT-CLASSIFICATION-RUBRIC.md` | Supporting | It defines the batch classification rubric and audit checklist; it is supporting control material. |
| `AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING.md` | Supporting | It is routing guidance for post-audit repair decisions, not active product canon. |
| `prompts/batches/post-23-truth-audit/*.md` | Supporting | These are runner inputs for the post-23 train family, not current product/source truth. |
| `docs/codex/reports/AMB-POST23-00-COMPLETION-SENTINEL.md` | Historical | It records a prior gate check and is evidence history, not current authority. |
| `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md` | Historical | It is a prior truth-audit result and should be read as evidence history. |
| `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md` | Historical | It is a prior repair-routing result and should be read as evidence history. |
| `docs/codex/reports/AMB-POST23-TRUTH-AUDIT-REPAIR-INSTALL-01.md` | Historical | It is a prior install/report artifact and belongs in evidence history, not active authority. |
| `AMB-POST23-TRUTH-AUDIT-STATUS.md` | Obsolete | Its blocked-status language conflicts with the sentinel pass and should not be treated as current repo truth. |
| `AMB-POST23-TRUTH-AUDIT-ELIGIBILITY-GATE.md` | Obsolete | Its blocking language is stale relative to the sentinel pass and should be demoted to historical/supporting context until rewritten. |
| `frontend/` and `frontend/visual-encyclopedia/` | Active portal | `docs/README.md` identifies them as active visual canon portals. |
| `backend/`, `codex-os/`, `product-canon/`, `validation/` | Supporting portals | They are active repository portals, but they are not the active truth layer. |
| `history/` | Historical portal | It is the designated archive portal. |

## Conflict Log

1. Blocked-status drift vs sentinel pass.
   - `AMB-POST23-TRUTH-AUDIT-STATUS.md` and `AMB-POST23-TRUTH-AUDIT-ELIGIBILITY-GATE.md` still say the post-23 train is blocked.
   - `docs/codex/reports/AMB-POST23-00-COMPLETION-SENTINEL.md` says the gate is eligible to continue to the next audit step.
   - Current routing should follow the sentinel result, with the older blocked wording treated as stale control text.

2. Top-level IA consistency.
   - Active truth preserves `Today / Goals / Capture / Time / You`.
   - Supporting docs should keep `Plan` only as compatibility/contextual language.

3. Authority hierarchy.
   - `docs/truth/*` remains the active authority layer.
   - Reports, prompts, and batch-train docs may route work, but they do not supersede truth files.

## Routing Decision

1. Keep the truth files as active authority.
2. Keep the post-23 manifest, rubric, repair routing, and prompt family as supporting control-plane material.
3. Demote the stale blocked-status and eligibility-gate wording to obsolete until the text is rewritten to match the sentinel result.
4. Preserve the post-23 reports as historical evidence.
5. Route the next batch to `AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION` after this cleanup pass, not to a flagship implementation train.

## What This Batch Does Not Claim

This report does not claim:

- app build success
- test success
- device proof
- accessibility proof
- privacy/legal approval
- performance proof
- release readiness
- product completion
- UI Suite readiness

## Validation

Validated:

- `test -f docs/codex/reports/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md`
- `rg -n "Active|Supporting|Historical|Obsolete|Archive-candidate|Delete-candidate|Unknown|STATUS: (GREEN|YELLOW|RED)" docs/codex/reports/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md`
- `bash scripts/codex-forbidden-claim-scan.sh docs/codex/reports/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md`
- `git diff --check -- docs/codex/reports/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md`
- `git status --short --branch`

Not verified:

- app source behavior
- build output
- tests
- device behavior
- accessibility conformance
- privacy/legal approval
- performance proof
- release readiness

## Rollback

Remove this report only:

```bash
rm -f docs/codex/reports/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md
```

STATUS: GREEN

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
