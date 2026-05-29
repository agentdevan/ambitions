# AMB-FE-BE Execution Order

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Installed docs-only order file

1. `AMB-FE-BE-PREFLIGHT-00`
2. `AMB-FE-BE-CONTRACT-FREEZE-01`
3. `BE-01-RUNTIME-BASELINE`
4. `BE-02-LEDGER-REPLAY`
5. `BE-03-REALITY-MERIDIAN-CAPACITY`
6. `BE-04-RECOMMENDATION-DETERMINISM`
7. `BE-05-PROOF-FRESHNESS-RECEIPTS`
8. `BE-06-PROTECTED-TIME-PRIVACY`
9. `BE-07-VERTICAL-SLICE-PROOF`
10. `BE-08-DIAGNOSTICS-MIGRATION-HARDENING`
11. `FE-01-CANON-FREEZE`
12. `FE-02-DESIGN-LANGUAGE`
13. `FE-03-TOKENS`
14. `FE-04-PRIMITIVES`
15. `FE-05-GEOMETRY-REALITY-MERIDIAN`
16. `FE-06-SHELL-MIGRATION`
17. `FE-07-ROOT-SURFACES`
18. `FE-08-PROOF-RECEIPTS-TRUST`
19. `FE-09-COMPONENT-SYSTEM`
20. `FE-10-INTERACTION-ACCESSIBILITY`
21. `FE-11-PREVIEWS-VISUAL-QA`
22. `FE-12-CHROME-CONTRACTS-HARDENING`
23. `AMB-FE-BE-INTEGRATED-PROOF-99`

## Gate rule

Later stages stop on Red unless the prompt explicitly says it is a repair batch.
This order is sequencing only; it does not claim any stage is implemented, validated, or release-ready.

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
