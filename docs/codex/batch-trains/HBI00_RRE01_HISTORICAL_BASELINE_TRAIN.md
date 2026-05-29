# HBI00-RRE01 Historical Baseline Train

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active planned train inserted into the global batch train  
Date: 2026-05-13  
Queue relationship: Applies after the Source Atlas import/review foundation and before downstream source-aware personalization claims.

## Purpose

Install a first-class Historical Baseline system so Ambitions can construct a reviewable Current State from user-selected evidence, source records, candidate claims, confidence bands, review actions, receipts, and portability controls.

This train is active now. It must be honored by Codex whenever the active global queue touches source import, evidence, candidate claims, review, current state, recommendation influence, runtime inspection, export/delete/restore, monetization boundaries, or final proof.

## Execution order

| Batch | Title | Objective | Allowed scope | Forbidden scope | Validation |
|---|---|---|---|---|---|
| HBI-00 | Canon + authority docs | Add historical baseline canon and source hierarchy. | Canon, authority docs, queue overlay. | Code changes. | Canon title/path gate. |
| HBI-01 | Core schema | Add SourceRecord, EvidenceItem, CandidateClaim, LifeFact, Snapshot. | Core schema and unit tests. | UI polish. | Unit schema tests. |
| HBI-02 | Evidence vault | Store evidence digests, local refs, hashes. | Local vault and tests. | Cloud storage. | Vault tests. |
| HBI-03 | Source adapters shell | Add protocols, import plans, run receipts. | Adapter contracts. | Real imports. | Adapter contract tests. |
| HBI-04 | Calendar/Reminders | Add EventKit adapter. | Calendar/reminder read/import boundary. | Auto-goal creation. | Calendar fixture tests. |
| HBI-05 | Files/PDF/Resume | Add UIDocumentPicker and PDFKit extraction. | User-selected files, PDFs, resumes. | File crawling. | File import tests. |
| HBI-06 | Photos/Screenshots | Add PhotosUI selected import and Vision OCR. | User-selected images/screenshots. | Full-library access default. | OCR fixture tests. |
| HBI-07 | LinkedIn/GitHub archives | Add user-supplied archive parsers. | Local archive parsing. | Live OAuth connector. | Archive fixture tests. |
| HBI-08 | Candidate extraction | Add deterministic local extraction rules. | Candidate claims only. | Cloud AI dependency. | Extraction tests. |
| SCI-01 | Confidence scoring | Add bands, score, source authority. | Transparent scoring. | Hidden magic scoring. | Confidence tests. |
| SCI-02 | Staleness | Add freshness policy by source/domain. | Stale downgrade rules. | Permanent stale influence. | Stale-source tests. |
| SCI-03 | Contradictions | Add contradiction groups. | Conflict grouping and review. | Silent winner-picking. | Conflict tests. |
| IRQ-01 | Review queue model | Add queue buckets/actions. | Review model. | Bulk accept sensitive. | Queue tests. |
| IRQ-02 | Review queue UI | Add review cards and correction fold. | Review UI and screenshots. | Long forms. | UI screenshots. |
| HBI-09 | Current State Snapshot | Add snapshot compiler and UI. | Current State object. | Profile form. | Snapshot tests. |
| HBI-10 | Life Map | Add Life Map and Life Delta. | Life Map UI and Visual QA. | Generic surface. | Visual QA. |
| PRI-01 | Runtime inspection | Add Why This? and source influence. | Inspection receipts. | Exposing noisy internals. | Comprehension fixtures. |
| RHE-01 | Recommendation humility | Add weight rules and confidence copy. | Conservative recommendation policy. | False certainty. | Red-team tests. |
| PPL-01 | Export | Add JSON/schema/export bundle. | Portable export. | Proprietary-only export. | Round-trip tests. |
| PPL-02 | Delete/restore | Add delete receipts and restore drill. | Delete/restore proof. | Irreversible silent delete. | Restore tests. |
| LSF-01 | Local simulation | Add what-if capacity model. | Local scenario simulation. | Autonomous life decisions. | Scenario tests. |
| MGP-01 | Monetization | Add Free/Core/Cloud tier gates. | Entitlement boundaries. | Paywall trust controls. | Entitlement tests. |
| RRE-01 | Final evidence | Close proof reports, accessibility, privacy. | Evidence reports and final gates. | Release claims without proof. | Proof reports. |

## Global gates

- Active IA remains Today / Goals / Capture / Time / You.
- Core intelligence remains local-first and deterministic.
- External/cloud LLMs are not part of core architecture.
- Imported evidence creates candidates, not active goals.
- Review, correction, export, delete, and trust receipts are not paywalled.
- Recommendation influence must be sourceable, dateable, correctable, suppressible, exportable, and deletable.
- No release, App Store, TestFlight, device, accessibility, privacy, legal, investor, or commercial-readiness claim may be made without current proof.

## Canonical runner command pattern

```bash
scripts/ambitions-codex-train.sh <BATCH_ID> prompts/batches/<BATCH_ID>.md
```

Equivalent:

```bash
make batch BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md
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
