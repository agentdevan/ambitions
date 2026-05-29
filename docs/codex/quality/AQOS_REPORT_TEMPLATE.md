# AQOS Batch Report Template

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite
> Dispositions: rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active AQOS report template.
Date: 2026-05-05

Use this template for every AQOS-adopted batch.

```markdown
# <BATCH ID> <Batch Name> Report

Result: <Green type(s) / Accepted Yellow / Recoverable Red / Hard Red>
Date:
Active train:
Current global order position:

## 1. Batch Scope

- Goal:
- Allowed files:
- Forbidden files:
- Dependencies:
- Stop conditions:

## 2. Impact Classifier

- Domains touched:
- User-facing surfaces touched:
- Sensitive data touched:
- External surfaces touched:
- Runtime/platform claims touched:
- Required gates:

## 3. Required Evidence

| Domain | Required evidence | Produced? | Evidence path | Result |
|---|---|---:|---|---|

## 4. Green Taxonomy Achieved

- [ ] Structural Green
- [ ] Behavioral Green
- [ ] Rendered Visual Green
- [ ] Accessibility Green
- [ ] Privacy Green
- [ ] Data Integrity Green
- [ ] Performance Green
- [ ] Architecture Green
- [ ] Copy Green
- [ ] Platform Green
- [ ] Release Green
- [ ] Handoff Green

## 5. Files Read

## 6. Files Changed

## 7. Implementation / Docs Summary

## 8. Evidence Produced

- Build/test evidence:
- Visual evidence:
- Accessibility evidence:
- Privacy evidence:
- Performance evidence:
- Data integrity evidence:
- Architecture evidence:
- Copy evidence:
- Release/claim evidence:

## 9. Evidence Not Produced

For each missing proof:

- Missing evidence:
- Why missing:
- Risk:
- Classification: Accepted Yellow / Recoverable Red / Hard Red
- Owner batch:

## 10. Autonomous Quality Council

| Role | Result | Strongest concern | Evidence reviewed | Required repair |
|---|---|---|---|---|
| Founder Vision Guardian |  |  |  |  |
| Chief Product Reviewer |  |  |  |  |
| Apple Design Award Visual Reviewer |  |  |  |  |
| Staff iOS Architect |  |  |  |  |
| Senior SwiftUI Reviewer |  |  |  |  |
| Accessibility Lead |  |  |  |  |
| Privacy / Security Reviewer |  |  |  |  |
| Performance / Battery Reviewer |  |  |  |  |
| QA / Test Lead |  |  |  |  |
| App Store / Claim Truth Reviewer |  |  |  |  |
| Legal Boundary Reviewer |  |  |  |  |
| FAANG Handoff Auditor |  |  |  |  |

## 11. Tests / Commands Run

```bash
# commands
```

## 12. AQOS Scripts Run

- aqos-impact-classifier:
- aqos-required-evidence-check:
- aqos-claim-truth-scan:
- aqos-copy-internal-term-scan:
- aqos-visual-card-stack-scan:
- aqos-architecture-fitness-scan:
- aqos-privacy-exposure-scan:
- aqos-screenshot-freshness-check:
- aqos-evidence-folder-check:
- aqos-state-coverage-check:
- aqos-evidence-maturity-ledger-check:

## 13. Yellow / Red Items

| Item | Classification | Owner | Repair path | Can continue? |
|---|---|---|---|---|

## 14. Repair Batch Created

- Name:
- Scope:
- Evidence required:
- Next action:

## 15. No-Claim Boundary

State exactly what this batch does not claim.

## 16. Rollback Path

## 17. Next Eligible Batch
```

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
