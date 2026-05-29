# Moat Runtime Autonomous Routing Policy

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-79183457, AMB28-stale_or_unknown_active_status-38730954

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: active control-plane routing policy  
Date: 2026-05-12  
Authority: subordinate to `docs/truth/*`, current queue state, and live source/proof evidence

## Purpose

MRI is now an autonomous sidecar train. It is not appended blindly to the canonical global queue. It runs when milestone triggers indicate that the normal global train needs moat/runtime integration before continuing safely.

## Router

Primary router:

```bash
python3 scripts/ambitions-mri-autonomous-router.py --status
python3 scripts/ambitions-mri-autonomous-router.py --next
python3 scripts/ambitions-mri-autonomous-router.py --json
```

Primary wrapper:

```bash
make -f Makefile.mri mri-autonomous-status
make -f Makefile.mri mri-autonomous-next
make -f Makefile.mri mri-autonomous-once
MAX_BATCHES=10 make -f Makefile.mri mri-autonomous-train
```

## Behavior

- If no MRI intervention is due, the wrapper delegates to `scripts/ambitions-post-pk-speed-train.sh`.
- If an MRI intervention is due, the wrapper materializes MRI prompts, runs the next MRI sidecar batch through the canonical runner, marks it complete in `.codex/state/mri-autonomous-state.json`, pushes the state marker, then resumes.
- MRI completion state is tracked separately from the canonical global queue so MRI does not pollute or reorder active SA/AOS/LDI/FCP/PFC/RHC execution.

## Milestone Triggers

| Milestone | Trigger next batch | MRI bundle |
| --- | --- | --- |
| after-source-atlas-core | SA11 | MRI01-MRI08 |
| after-source-atlas-runtime | SA17 | MRI09-MRI16 |
| after-source-atlas-importers | SA25 | MRI17-MRI24 |
| after-source-atlas-complete | AOS24/AOS25/LDI17/FCP27/PFC31/RHC01 | MRI25-MRI34 |
| before-terminal-assurance | RHC01/RHC02/DPTG01/FINAL01/PFC37-PFC40 | MRI35-MRI44 |
| final-moat-integration | FINAL01/DPTG01/RELEASE01 | MRI45-MRI50 |

## Rule

MRI runs when it protects product-loop completeness. The normal global queue still owns implementation order.

## Non-Claims

This routing policy does not claim MRI implementation completion, visual runtime completion, release readiness, TestFlight readiness, App Store readiness, device proof, public accessibility conformance, performance validation, privacy/legal approval, or global train completion.

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
