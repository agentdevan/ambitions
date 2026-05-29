# PXOS Drift Detection Protocol

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Future Codex OS protocol; PXOS implementation not started
Date: 2026-05-02

## Scan Families

Run drift scans for new top-level tabs, generic task-app language, generic habit
language, calendar-clone language, chatbot-wrapper language, AI overclaiming,
App Store/TestFlight overclaiming, production-ready overclaiming, physical-device
overclaiming, hidden automation language, shame/failure language, unsupported
platform integration, unsupported personalization/memory, next-best-move copy,
generic surface terminology, enterprise OKR drift, command-center sprawl,
stacked-card top-level composition, repeated same-size card stacks, dense
top-level lists, and top-level detail-container drift.

## Advisory Scan

```bash
grep -R "Your Recommended step\|Recommended step\|needs review\|failure\|proof thread broken\|AI magic\|fully automated" docs/canon docs/codex .codex || true
grep -R "new top-level tab\|sixth tab\|chatbot\|surface\|habit tracker\|calendar clone" docs/canon docs/codex .codex || true
grep -R "stacked cards\|same-size cards\|card grid\|detail container\|dense list" docs/canon docs/codex .codex || true
```

Hits are allowed in forbidden-language lists, negative tests, risk registers,
and drift protocols. Hits are not allowed as active product promises or shipped
status claims.

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
