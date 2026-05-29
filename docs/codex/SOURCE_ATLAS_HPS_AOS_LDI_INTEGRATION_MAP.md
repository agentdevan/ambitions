# Source Atlas HPS / AOS / LDI Integration Map

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748, AMB28-stale_or_unknown_active_status-59261457

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active integration map for Source Atlas-dependent work.
Date: 2026-05-06

## Purpose

Source Atlas becomes the source/freshness/claim substrate for HPS, AOS, LDI, FCP, PFC, CQS, and FVQ work that depends on real-world requirements, user-provided sources, source packs, document parsing, or source freshness.

## HPS integration

Source Atlas implements HPS primitives:

- Source Truth / Requirement Graph
- Verified Proof Ledger bridge
- Commitment Memory / Searchable Life Recall source labels
- Start Here Recommendation Quality source/freshness proof
- Option Value / Pivot Preservation proof/source transfer
- Living Dream Compiler source/requirement substrate
- Privacy / Memory Permission Kernel for private user sources
- Local Intelligence Adapter deterministic fallback
- AI Governance / Evaluation Lab fixtures
- Singular Experience / No-Sprawl gates

HPS remains the product-scope governor. Source Atlas cannot widen the app.

## AOS integration

AOS cannot consume official/current path requirements without Source Atlas source proof.

| AOS kernel | Source Atlas requirement |
|---|---|
| AOS02 Life Graph | Source-backed claim and source locator support where graph nodes depend on world knowledge. |
| AOS05 Starting Position | User facts can map to source-backed requirements but eligibility cannot be certified. |
| AOS06 Goal Path Compiler | Must compile from Source Atlas requirements or source-needed fallback. |
| AOS07 Local Goal Packs | Must use Source Atlas pack schema and source-state rules. |
| AOS08 Alternate Path | Path transfer must preserve source/freshness/uncertainty. |
| AOS09 Option Value | Proof transfer must cite Source Atlas requirement/proof map where relevant. |
| AOS12 Proof Trust Closure | Evidence Ledger can reference Source Atlas proof requirements. |
| AOS13 Source Truth | Must inherit Source Atlas claim states, freshness states, revocation, dispute, and user-provided rules. |
| AOS14 Start Here Recommendation | Must include source/freshness proof or source-needed fallback. |
| AOS15 Local Language | May extract candidates but must route to Source Atlas review; deterministic fallback required. |
| AOS17 Privacy Safety | Private user sources must remain local/private and redacted from external surfaces. |
| AOS18 Evaluation | Must include Source Atlas stale/source-needed/OCR/private/high-risk fixtures. |
| AOS24 UI Integration | Must use Source Atlas UI primitives without creating surface. |

## LDI integration

LDI cannot generate real-world dream paths as official/current without Source Atlas.

| LDI batch | Source Atlas requirement |
|---|---|
| LDI01 | Source Atlas must be named as source/requirement substrate. |
| LDI02 | Capture handling ladder routes source attachments to Universal Source Binder. |
| LDI03 | Safety/legal/professional triage uses Source Atlas risk classes. |
| LDI04 | North Star extraction may create symbolic paths, but official requirements need Source Atlas. |
| LDI05 | Source Claim Graph uses Source Atlas claim state model. |
| LDI06 | Pack Registry uses Source Atlas pack schema and no-marketplace boundary. |
| LDI07 | Pack supply chain security uses hash/signature/revocation/rollback contracts. |
| LDI08 | Requirement Graph Runtime consumes Source Atlas requirements. |
| LDI09 | Eligibility/deadline logic blocks stale high-risk claims. |
| LDI10 | Starting Position intake can bind user-provided sources through Universal Source Binder. |
| LDI11 | Path Portfolio labels source-needed/current/stale/unknown path portions. |
| LDI12 | Capacity bridge cannot schedule deadline-sensitive actions from stale source as current. |
| LDI13 | Today bridge exposes source/freshness/source-needed line in Start Here where needed. |
| LDI14 | Dream handling receipts cite imported source, pack, claim, and review state. |
| LDI15 | Recompiler uses changed claim IDs and local impact matching. |
| LDI16 | Mutation permissions protect source-driven path changes. |
| LDI20 | Freshness Broker uses Source Atlas manifest/diff/revocation contracts. |
| LDI21 | Red-team includes URL/PDF/OCR/job/school/certification fixtures. |

## FCP surface integration

Source Atlas UI must appear only as restrained trust chrome.

### Today

Start Here may show source/freshness/source-needed line, SourceImpactReceipt, and Receipt Drawer source detail. It must not show Source Atlas surface or pack library.

### Goals

LifePath, Mission Control, Proof Spine, and Alternate Path may show RequirementSourceFold, SourceBadge, FreshnessBadge, and proof-source details in drill-downs.

### Capture

Capture owns Universal Source Binder entry. Capture must remain text-first and minimal; source attach/review is progressive disclosure.

### Plan

Plan may show stale/deadline/source review warnings only when source state affects scheduling or reflow.

### You

You owns source/privacy/history controls, imported source management, pack/freshness settings, delete/correct/reject controls, and private source preferences.

## PFC integration

PFC must account for:

- private source documents
- PDF/OCR extraction privacy
- logs/analytics redaction
- static freshness manifest hosting
- pack signing/revocation/rollback
- source adapter supply-chain risk
- API key avoidance in app bundle
- no user-data server claim
- no official database overclaim
- TestFlight/App Store claim boundaries

## CQS/FVQ integration

Future UI-affecting Source Atlas work requires rendered proof and Source Atlas scans. Compile/tests/docs alone cannot close Green.

Required proof classes:

- URL review
- PDF text extraction review
- scanned PDF/OCR review
- screenshot/OCR review
- copied text review
- source-needed fallback
- stale/source-changed/disputed/revoked
- private source shield
- high-risk school/certification/job states
- no internet / last-known-good
- Dynamic Type and reduced-motion equivalent

## Global order rule

Preferred order:

1. HPS closeout.
2. SA01-SA32.
3. Deep AOS runtime.
4. LDI runtime.
5. Source/freshness-dependent platform surfaces.

If active work has advanced, do not replay completed batches. Insert Source Atlas at the earliest safe point before any remaining AOS/LDI/source/freshness implementation.

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
