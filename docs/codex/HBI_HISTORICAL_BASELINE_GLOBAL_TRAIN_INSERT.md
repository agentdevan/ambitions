# HBI Historical Baseline Global Train Insert

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-stale_or_unknown_active_status-60586850

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active global batch train insert
Date: 2026-05-13
Branch: main

HBI is active Ambitions global-train scope.

Purpose:
- Add a first-class Historical Baseline / Current State train.
- Make Codex pick up the work through the Ambitions runner.
- Prevent the train from being treated as a side proposal.

Required first prompt:

`prompts/batches/HBI00-HISTORICAL-BASELINE-ACTIVE-TRAIN-01.md`

Required first command:

```bash
scripts/ambitions-codex-train.sh HBI00 prompts/batches/HBI00-HISTORICAL-BASELINE-ACTIVE-TRAIN-01.md
```

Routing:
- HBI00 installs active authority, queue entries, validators, and proof scaffolding.
- HBI01+ implement source, evidence, review, confidence, current-state, runtime-inspection, export, and release-evidence work in scoped batches.
- HBI must not claim production completion until source, tests, and proof artifacts exist.

Placement:
- HBI is active before any final market-leading, release-readiness, or product-completeness claim.
- HBI may run after current data-control and intelligence-boundary prerequisites, or earlier as docs/control-plane setup when no production source files are touched.

Hard stops:
- No direct Codex execution unless explicitly bypassed by the user.
- No source crawling behavior.
- No automatic active-goal creation from imports.
- No cloud AI dependency in core Historical Baseline behavior.
- No release, privacy, accessibility, sync, App Store, or device claim without current proof.

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
