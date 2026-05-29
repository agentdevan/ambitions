# Xcode Validation Lane Matrix

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-stale_or_unknown_active_status-39854993

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, status-expedite
> Dispositions: clarify-status-before-use, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Date: 2026-05-11

## Active batch-to-lane guidance

| Lane | Area type | Default lane | Notes |
| --- | --- | --- | --- |
| L0_NONE | prompt/governance | `none` | docs/prompt-only updates only |
| L1_BUILD | service extraction and package/wiring changes | `build` | compile path only |
| L2_BUILD_FOR_TESTING | focused performance fixture/cache setup | `build-for-testing` | produces build-for-testing `.xcresult` |
| L3_FOCUSED_TEST | Prompt/gov and implementation owner seams | `focused-test` | target seam tests only |
| L4_SEGMENT_TEST | named feature batch segments | `test-plan` | where explicit test plan exists |
| L5_FULL_TEST | full batch gates | `build` + `build-for-testing` + broad suite as allowed by gate | reserved for late validation gates |
| L6_UI_PROOF | UI/FET/FVQ/PX | `ui-proof` | simulator + screenshot/evidence path |
| L7_TERMINAL_DEVICE_PROOF | terminal DPTG/release proof | `terminal-device-proof` | terminal only when gate requires |

## Required lane mapping

- Service extraction: `focused-test`
- Storage/storage-like extraction: `focused-test`
- Side effects / privacy / source-atlas seam: `focused-test`
- Intelligence boundary: `focused-test`
- Performance/fixtures: `build-for-testing` or `focused-test`
- Package extraction: `build` for compile plus focused validation if seam changes tests
- UI/FVQ/PX: `ui-proof`
- Terminal DPTG: `terminal-device-proof`

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
