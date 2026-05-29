# Linear Template Usage

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active usage note.
Scope: How to use the Ambitions Linear template files efficiently.

Use these files as the source for Linear project and issue generation:

- `docs/codex/linear-templates/README.md`
- `docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml`
- `docs/codex/linear-templates/AMB-ISSUE-TEMPLATES.md`
- `docs/codex/linear-templates/AMB-PROJECT-TEMPLATE.md`

## Default Flow

1. Select the smallest matching template from the manifest.
2. Create one Linear issue for one bounded outcome.
3. Use exact repo paths for authority, scope, validation, and proof.
4. Keep the issue compact by referencing the manifest instead of repeating the full product law.
5. Ask Codex to execute only the issue contract.
6. Review the final report before merge readiness.

## Compact Issue Minimum

Every issue should include:

```text
Template:
Manifest:
Authority inspected:
Intent:
Scope:
Non-goals:
Requirements:
Validation:
Proof:
Stop conditions:
Final response:
```

## Ready for Codex Checklist

An issue is ready for Codex when it has:

- one clear outcome
- exact allowed files or folders
- explicit non-goals
- validation commands or a validation lane
- proof expectations
- clear stop conditions
- required Green/Yellow/Red final report

## Reuse Rule

When a future issue needs more detail, update these repo templates first, then use
the updated template in Linear. Do not let one-off Linear phrasing become the new
standard unless it is promoted back into this directory.

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
