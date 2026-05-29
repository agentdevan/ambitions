# AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: duplicate_stable_id, same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-duplicate_stable_id-84016860, AMB28-same_source_file_targeted_by_multiple_active_batches-83525689

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-authority, merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: supporting install report

Supporting note: This report supports current Ambitions Codex work but does not override `docs/truth/`.

## Summary

Installed a thin, subordinate flagship Codex OS layer under `docs/codex/os/`, added routing skill wrappers under `.codex/skills/ambitions/`, and tightened the local Codex OS validator so `--help` can report usage without running validation.

## Installed artifacts

- `docs/codex/os/README.md`
- `docs/codex/os/AMB-CODEX-OS-FLAGSHIP-UPGRADE-MANIFEST.md`
- `docs/codex/os/AMB-CODEX-OS-AUTHORITY-RESOLVER.md`
- `docs/codex/os/AMB-CODEX-OS-GREEN-YELLOW-RED-STANDARD.md`
- `docs/codex/os/AMB-CODEX-OS-NO-SPRAWL-GUARD.md`
- `docs/codex/os/AMB-CODEX-OS-PROOF-LEDGER.md`
- `docs/codex/os/AMB-CODEX-OS-VISUAL-QA-GATE.md`
- `docs/codex/os/AMB-CODEX-OS-PRIVACY-CLAIM-GATE.md`
- `docs/codex/os/AMB-CODEX-OS-APPLE-CONTINUITY-GATE.md`
- `docs/codex/os/AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE.md`
- `prompts/batches/OS-FLAGSHIP-01-AUTHORITY-RESOLVER.md`
- `prompts/batches/OS-FLAGSHIP-02-NO-SPRAWL-GUARD.md`
- `prompts/batches/OS-FLAGSHIP-03-PROOF-LEDGER.md`
- `prompts/batches/OS-FLAGSHIP-04-VISUAL-QA-GATE.md`
- `prompts/batches/OS-FLAGSHIP-05-PRIVACY-APPLE-CONTINUITY-GATES.md`
- `prompts/batches/OS-FLAGSHIP-06-LAUNCH-BELIEVABILITY-REVIEW.md`
- `prompts/batches/OS-FLAGSHIP-07-SKILL-REGISTRY-AND-RUNNER-INTEGRATION.md`

## Phase 04 repair notes

- Added the seven required generated batch prompt artifacts with runner headers.
- Repaired the SwiftUI wrapper route from missing `native-ios-believability-reviewer` to existing `ios-native-believability-reviewer`.
- Tightened `scripts/ambitions-codex-os-validate.py` so generated prompt artifacts are required and runner-header checked.
- Restored generated `build/codex-os/*` churn before final validation.

## Validation status

Validation was rerun after the Phase 04 repair and is recorded in the batch closeout narrative for this turn.

## Non-claims

This report does not claim implementation, release readiness, or new product behavior.

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
