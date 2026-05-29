<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Studio Prompt 09: Preview Screenshot Matrix

## Batch ID

`UI-STUDIO-09-PREVIEW-SCREENSHOT-MATRIX`

## Purpose

Require a controlled preview and screenshot matrix for flagship UI work so proof coverage is explicit before any visual claim.

## Active Source Truth To Inspect

- `docs/truth/RELEASE_TRUTH.md`
- `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`
- `frontend/visual-encyclopedia/trace/UI_STUDIO_SCREEN_STATE_MATRIX.md`

## Install Scope

- Require preview fixtures for empty, normal, dense, recovery, error, reduced motion, large Dynamic Type, small iPhone, and large iPhone states when relevant.
- Require an explicit screenshot inventory for the same state set when screenshots are owned.
- Separate preview fixture coverage, screenshot inventory requirements, actual rendered screenshot proof, accessibility proof, device proof, and release proof.
- Treat preview coverage as a proof requirement, not proof itself.

## Hard Rules

- No fake screenshot claims.
- No release readiness claims from previews alone.
- No omission of non-ideal states when the surface can show them.
- Do not let "screenshot inventory complete" imply screenshots were captured, approved, device-verified, accessible, or release-ready.

## Validation Expectations

- `make prompt-audit`
- `git diff --check`

## Final Response Format

- Summarize the preview matrix requirements.
- End with `STATUS: GREEN|YELLOW|RED`.

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
