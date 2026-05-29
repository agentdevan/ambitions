# Known-Yellow Quarantine Ledger

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, finish-real-source-proof
> Dispositions: proof-readiness, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Known caveats are recorded here to prevent re-discovery and false "fixed" claims.

## PK15 External Surface Stale Projection Mismatch

ID: KY-2026-05-10-PK15-EXT-01  
Source: PK15 Receipt Backend closeout evidence and queue-state reconciliation  
Observed in: `ExternalSurfaceVerificationChecklistTests.testM04ExistingProjectionsCarryStalePrivateAndFallbackBehavior`  
Status: Accepted Yellow (historically known and pending external-surface follow-up)  
Owner: QA / External Surface proof lane  
Why it is quarantined: The failure is reproducible in full-surface proof context and unrelated to PK16-closeout follow-through; it remains tracked for External Surface follow-up after local trust/backend proof lanes close.

When it blocks:
- Claiming full external-surface validation green.
- Claiming global batch completion based on the affected external-surface expectation.
- Re-running a similarly scoped full-surface gate without explicit external-surface follow-up.

When it does not block:
- Focused trust-history and local persistence work that does not touch the affected external surface projection path.
- Local PK17-PK21 service extraction work when it does not alter the tested external projection path.

Recheck command:
- `bash scripts/global-train-red-repair-hint.sh ExternalSurfaceVerificationChecklistTests.testM04ExistingProjectionsCarryStalePrivateAndFallbackBehavior`

No-claim boundary:
- Do not claim full external-surface verification green until this caveat is resolved by the owning follow-up lane.

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
