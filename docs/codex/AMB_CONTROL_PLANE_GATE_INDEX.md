# Ambitions Control-Plane Gate Index

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-1350962, AMB28-same_source_file_targeted_by_multiple_active_batches-42995888, AMB28-same_source_file_targeted_by_multiple_active_batches-46654715, AMB28-same_source_file_targeted_by_multiple_active_batches-72454456

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: active supporting control-plane index  
Date: 2026-05-10  
Owner posture: enforcement map, not product implementation proof

## Purpose

This index lists the direct read-only control-plane gates installed to make Ambitions batch execution faster, safer, and less dependent on manual interpretation.

These gates do not replace the Ambitions runner. They are preflight and adjudication checks for queue truth, batch scope, Source Atlas title integrity, final report quality, and forbidden readiness claims.

## Gates

| Gate | Path | Main use | Red condition examples |
| --- | --- | --- | --- |
| Queue snapshot | `scripts/ambitions-queue-snapshot.py` | Determine next safe action from active mirrors and queue JSON. | Next-batch mirror mismatch, stale PK14/PK15 references, invalid queue JSON, generic Source Atlas labels. |
| Source Atlas title check | `scripts/ambitions-source-atlas-title-check.py` | Ensure SA queue titles match the SA train manifest. | `SA11`, `SA12`, etc. used as titles instead of manifest titles. |
| Final report gate | `scripts/ambitions-final-report-gate.py` | Reject weak Green/Yellow final reports. | Missing Status/Scope/Files/Evidence/Validation/Claims Not Made/Next Step, or forbidden readiness phrase without non-claim framing. |
| Aggregate control-plane check | `scripts/ambitions-control-plane-check.py` | Run queue JSON validation, snapshot, and Source Atlas title check together. | Any constituent gate returns Red. |
| Batch scope guard | `scripts/ambitions-batch-scope-guard.py` | Compare changed files against a batch prompt's allowed/forbidden scope. | Changed file matches forbidden scope, or changed file is outside allowed scope. |

## Recommended use

Before running an implementation batch:

```bash
python3 scripts/ambitions-control-plane-check.py
```

Before accepting a final report:

```bash
python3 scripts/ambitions-final-report-gate.py docs/audits/<report>.md --strict
```

Before accepting a changed-files set:

```bash
python3 scripts/ambitions-batch-scope-guard.py prompts/batches/<BATCH>.md --strict
```

Before Source Atlas or queue-reference work closes:

```bash
python3 scripts/ambitions-source-atlas-title-check.py --strict
```

## Acceptance policy

A batch final report cannot be accepted as Green if:

- the aggregate control-plane check is Red
- the final report gate is Red
- the scope guard reports a forbidden-scope hit
- Source Atlas title defects remain after a queue/reference batch
- the report makes release/readiness claims without proof

Accepted Yellow is allowed only when the defect is explicitly non-blocking, owned, non-release, non-privacy, non-data-safety, and does not create next-batch ambiguity.

## Non-claims

These gates do not prove:

- app build success
- unit test success
- UI test success
- visual QA
- accessibility conformance
- performance validation
- privacy/legal approval
- release/TestFlight/App Store readiness
- physical-device validation
- global train completion

## Future integration targets

- Add Makefile targets after local validation.
- Add a prompt header scanner if `make prompt-audit` does not already cover all runner-header requirements.
- Add rendered visual proof packet validation before IR/FVQ/FCP UI closeouts.
- Add accessibility proof packet validation before any accessibility conformance claim.
- Add release proof packet validation before EFC/PFC terminal work.

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
