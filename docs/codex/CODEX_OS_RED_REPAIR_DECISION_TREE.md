# Codex OS Red Repair Decision Tree

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite
> Dispositions: rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Active Red classification and repair protocol.
Date: 2026-05-03

## Red Classes

- Recoverable Red: batch too broad, proof target missing, ledger missing, prompt skeletal, validation command missing but addable, docs-only scope needs split, or implementation dependency gate missing.
- Unrecoverable Red: data loss risk, source-truth corruption, production behavior drift, broken compatibility, unsafe privacy/security change, destructive overwrite, unsupported dependency/workflow/signing change, false release claim, human proof required but unavailable, or repeated same-root Red after two repair attempts.
- Dry-run Red: preflight finds unsafe scope before edits. Repair by A/B/C staging and run map/proof stage first.
- Proof Red: evidence is missing for a required claim. Repair by evidence ledger or downgrade claim.
- Compatibility Red: route/raw/default/accessibility/import/export/persistence seam risk. Repair only with named regression target and proof lane.
- Privacy/Security Red: sensitive data, inference, memory, export/delete, private mode, or dependency risk lacks controls. Stop unless a docs-only threat model can bound it.
- Accessibility Red: UI/copy interaction lacks Dynamic Type, VoiceOver, Reduce Motion, non-color meaning, motor alternative, or cognitive-load path. Repair with evidence gate before UI closeout.
- Release-Claim Red: readiness, platform, legal/privacy, device, App Store/TestFlight, or public accessibility claim outruns proof. Repair by removing/downgrading claim.
- Source-Truth Red: active canon conflict would affect implementation. Repair by owner-led reconciliation; do not overwrite history.
- Dirty-Tree Red: unknown dirty files before work. Stop.

## A/B/C Split

A: source map and dependency ledger. B: focused proof or compatibility evidence. C: narrow implementation or retirement only after A/B are Green. Preserve the parent batch identity and record sub-stage evidence without silently changing formal batch counts.

## Continue After Repair

Continue only when the repaired stage is Green or accepted Yellow, the tree is clean, the next batch dependencies remain valid, and no release/privacy/accessibility/compatibility claim is weakened.

## Stop

Stop when a repair would require production behavior drift, destructive overwrite, dependency/workflow/signing changes without approval, false claims, privacy/security ambiguity, or a third occurrence of the same root cause.

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
