# PXEQ Living Interface Rubric

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, rewrite-authority-before-proof, terminology-quarantine
> Dispositions: quarantine-or-rewrite-terminology, rewrite-authority-before-proof, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Active PXEQ rubric; not implementation evidence.
Date: 2026-05-03

Score each UI batch from 1 to 5.

| Dimension | Green 4-5 | Yellow 3 | Red 1-2 |
| --- | --- | --- | --- |
| Statefulness | Module changes with meaningful user/system state | State is present but shallow | Static shell with no meaningful state |
| Calm Motion | Motion orients, confirms, or reveals | Motion is optional polish | Motion distracts or hides state |
| Native Feel | iPhone-first, safe-area-aware, HIG-restrained | Mostly native with rough edges | SaaS/web/admin/dashboard feel |
| Minimal Utility | Fewer elements, stronger actions | Some extra density | Empty, underpowered, or cluttered |
| Visual Quality | Beautiful, readable, restrained | Needs human polish | Decorative noise or unreadable material |
| Trust Context | Sources, receipts, confidence, user control visible | Some trust detail deferred | Omniscient or creepy memory/intelligence |
| Accessibility | Dynamic Type, VoiceOver, Reduce Motion, non-color meaning | Advisory gap owned | Primary flow inaccessible |

Green requires no Red row and an average of 4 or higher. A technically passing
batch with Red product experience must stop or repair before Green.

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
