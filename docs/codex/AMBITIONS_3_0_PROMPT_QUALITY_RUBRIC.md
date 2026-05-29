# Ambitions 3.0 Prompt Quality Rubric

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active Codex intake rubric

Score each prompt from 0 to 2 for every criterion:

| Criterion | 0 | 1 | 2 |
| --- | --- | --- | --- |
| Source truth included | Missing | Mentions docs loosely | Names 3.0 docs/read order |
| Task width defined | Missing | Implied | XS/S/M/L/XL/XXL stated |
| Primitive named | Missing | Broad area only | Specific primitive/surface |
| Allowed files named | Missing | Broad directories | Clear touch budget |
| Forbidden files named | Missing | Partial | Clear no-touch areas |
| Validation named | Missing | Generic tests | Specific validation pack/commands |
| Stop conditions named | Missing | Generic blockers | Concrete stop/escalation rules |
| Output format clear | Missing | Partial | Exact closeout/report shape |
| Release claims controlled | Missing | Generic caution | Explicit claim-state constraints |
| No broad fix-everything language | Broad | Some scope risk | Bounded and split-ready |

## Interpretation

- 18-20: Ready for Codex execution.
- 14-17: Acceptable for S/M work with Codex clarification from files.
- 10-13: Needs narrowing before risky edits.
- Under 10: Split or rewrite before execution.

Prompts asking Codex to fix everything, modernize all tests, migrate all identifiers, redesign all surfaces, or claim readiness without gates should be rejected or split.

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
