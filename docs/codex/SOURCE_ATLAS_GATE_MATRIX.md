# Source Atlas Gate Matrix
<!-- markdownlint-disable MD013 -->

Status: Active Source Atlas gate matrix for SA01-SA32 and all Source Atlas-dependent work.
Date: 2026-05-06

## Purpose

This matrix prevents Source Atlas from becoming a brittle scraper, vague AI source system, source dashboard, privacy leak, or unsupported official-requirement engine.

Source Atlas must make Ambitions more trustworthy, not more claimy.

## Universal hard Red gates

| Gate | Hard Red condition |
|---|---|
| No Source Atlas Dashboard Gate | Adds Source Atlas as a top-level tab, dashboard, marketplace, or database browser. |
| Source Container Coverage Gate | A supported source type lacks import route, extraction route, failure mode, privacy state, review path, and no-claim language. |
| PDFKit Extraction Gate | Text-based PDF support lacks page-aware extraction, failure states, or review path. |
| OCR Review-Required Gate | OCR output can create official/current claims or mutate plans without user review. |
| URL Snapshot Gate | URL source handling lacks original/canonical URL, retrieval time, content type, source hash, failure fallback, or user review. |
| User-Provided Is Not Official Gate | User-imported/pasted/OCR-derived/copy-derived content is labeled official without independent official source validation. |
| Job Posting Example-Only Gate | A job posting is treated as universal career requirement rather than employer-specific market evidence. |
| School/Certification Strict Review Gate | Education/certification eligibility, deadlines, costs, or admissions requirements are treated as guaranteed/current without strict source/freshness review. |
| No Silent Claim Mutation Gate | Imported source claims alter goals, requirements, recommendations, proof, memory, schedule, or Start Here without review/receipt. |
| Offline Source Fallback Gate | App fails or blocks core use when internet, manifest, pack download, or source fetch is unavailable. |
| Pack Schema Validation Gate | Pack can load without schema validation, stable IDs, source IDs, risk/freshness states, and fallback copy. |
| Pack Revocation / Rollback Gate | Revoked/corrupt/invalid packs can remain active without quarantine, rollback, or user-safe stale state. |
| Stale High-Risk Claim Block Gate | staleCritical/high-risk legal/civic/education/certification/deadline claims can drive recommendations as current. |
| Private Document Protection Gate | Private source text, PDF content, OCR output, or extracted claims can enter logs, analytics, widgets, Live Activities, notifications, or screenshots by default. |
| No-Claim Language Gate | Copy claims always-current, official-complete, legal/career/education certainty, or professional advice without evidence. |
| Rendered Source-State Proof Gate | UI-affecting Source Atlas work closes Green without rendered proof for relevant source states. |

## Supported source containers

Each container must have import, extraction, failure, privacy, review, accessibility, and rendered-proof coverage.

| Container | Required support |
|---|---|
| URL | paste/share URL, HTML/text/PDF detection, redirect/canonical handling, source hash, failure fallback, user review. |
| PDF | local PDF, PDF URL, PDFKit text extraction, OCR fallback, page refs, locked/corrupt/huge/partial states, review-required claims. |
| Screenshot/Image | import/share, Vision OCR, low-confidence label, manual correction, review-required claims. |
| Copied Text | paste/import, normalization, classification, user-provided label, review candidates. |
| Local File | UTType-based routing into PDF/image/text/unsupported states. |
| Official Pack | schema/hash/signature/freshness validation. |
| User Mini-Pack | local/private, user-confirmed claims only, deletion/correction/rejection support. |

## Supported document categories

Document categories must never be confused with import types.

| Category | Required behavior |
|---|---|
| Rulebook | rules/equipment/scoring/eligibility/effective-date/version/governing-body detection; official label only with official source. |
| School Program Page | institution/program/prereq/deadline/cost/credits/admissions/residency/accreditation/contact detection; no admission certainty. |
| Job Posting | employer/role/skills/responsibilities/salary/deadline detection; example-only market evidence. |
| Certification Handbook | issuing body/credential/eligibility/exam/fees/renewal/deadlines/effective date detection; no eligibility certification. |
| Official Page | authority candidate, source hash, date/freshness, official-source proof before official label. |
| Generic Text | useful starter extraction only; user-provided/unknown source label. |
| Legal/Civic/Professional Source | strict review; no legal/professional advice or certainty. |

## Claim review gates

Every claim candidate must show:

- source container
- source category
- extracted text
- proposed claim
- claim state
- freshness state
- risk class
- source locator when available
- extraction quality
- privacy state
- actions: confirm, edit, reject, mark private, needs official review, do not use for recommendations, delete source

No claim candidate may affect user state until confirmed or explicitly allowed by a future deterministic low-risk rule.

## UI gates

Source Atlas UI must obey HPS/FVQ standards.

Required UI states when touched:

- source-backed
- source-needed
- stale
- stale-critical
- source changed
- disputed
- revoked
- user-provided
- OCR low confidence
- partial PDF extraction
- private source
- no internet / last-known-good
- corrupt/invalid pack
- high-risk review required
- reduced-motion equivalent
- Dynamic Type-adjacent proof

Allowed UI primitives:

- SourceBadge
- FreshnessBadge
- SourceNeededFold
- RequirementSourceFold
- ClaimReviewDrawer
- SourceBinderReviewSheet
- PackUpdateReceipt
- PrivateSourceShield
- OCRReviewNotice
- SourceImpactReceipt

Forbidden UI patterns:

- source database dashboard
- pack marketplace UI
- giant source library as default surface
- AI chat source assistant
- KPI/source health dashboard on top-level tabs
- generic card stack of imported sources

## Pack factory gates

Pack Factory output must pass:

- schema validation
- stable pack ID
- stable claim IDs
- source IDs
- source hash or retrieval metadata
- risk class
- freshness policy
- no-claim scan
- high-risk review policy
- fixture coverage
- diff support
- rollback/revocation contract

## Freshness Broker gates

Freshness Broker must be public and non-personal.

Hard Red:

- receives user goals, personal source text, proof, memories, or private documents
- requires account identity
- exposes user-specific changed-claim impact
- blocks app when unreachable
- has no last-known-good fallback

Required contract:

- atlas manifest
- pack index
- changed claim IDs
- hashes/signatures
- revocation list
- rollback pointers
- changelog
- generic update receipts

## Accessibility gates

Source/freshness state must not rely on color alone. Every badge/fold/drawer must have readable text, VoiceOver label, Dynamic Type behavior, and reduced-motion equivalent when animation is used.

## Closeout standard

SA32 cannot close until every Source Atlas gate is implemented, integrated into a later batch, or accepted Yellow with owner, repair path, and explicit user-facing claim block.
