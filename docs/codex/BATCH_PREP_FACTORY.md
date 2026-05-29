# Batch Prep Factory

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

The prep factory keeps future batch prep deterministic, auditable, and read-only.

## Read-only output format

Each prep note must follow:

- **Batch ID:**
- **Title:**
- **Queue classification:**
- **Current dependency status:**
- **Active truth files:**
- **Prompt file:**
- **Likely owner files:**
- **Likely forbidden files:**
- **Likely tests:**
- **Validation commands:**
- **EFC applicability:**
- **Known yellow caveats:**
- **Senior-only risks:**
- **GPT-5.4-mini-safe work:**
- **Hard Red triggers:**
- **Rollback notes:**
- **Non-claims:**
- **Next runner command:**

The prep note is explicitly a candidate file and **must not** authorize implementation.

## Factory outputs

- `docs/codex/batch-prep/PK16.md` through `docs/codex/batch-prep/PK25.md` should exist as seeded prep notes.
- `docs/codex/batch-prep/README.md` documents naming and read flow.
- `prompts/_BATCH_PREP_TEMPLATE.md` anchors deterministic prep formatting.
- `make throughput-prep` previews the PK16-PK25 scaffold window in dry-run mode.

## Rules

- Every prep note must state whether the prompt file is present.
- Prompts not present must use `Prompt availability: missing`.
- Any owner file names must be candidate statements only (`likely`, `candidate`, or `tbd`), unless evidence from
  existing files proves them.
- No implementation commands or commit commands appear inside prep notes.
- The factory never writes to `.codex/runs/**`, app source, project manifests, or release/CI files.
- Makefile convenience targets must use dry-run prep output; scaffold file writes require an explicit
  direct script invocation and `--force` only when an owner intentionally refreshes an existing prep note.

## EFC and queue coupling

- Prep notes should explicitly record EFC applicability from live queue state.
- If a caveat is quarantined in known-yellow, prep notes should mention it as a local relevance warning, not a failure.

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
