# Source Atlas Universal Source Binder Coverage Map

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active coverage map for Universal Source Binder implementation.
Date: 2026-05-06

## Purpose

Universal Source Binder is the Source Atlas intake system for user-provided sources. It must support every committed source type fully or explicitly remove it from scope before implementation. This map keeps all supported types honest.

## Core model

User-facing source examples are normalized into two dimensions:

1. Source containers: URL, PDF, image/screenshot, copied text, local file, official pack, user mini-pack.
2. Document categories: rulebook, school program page, job posting, certification handbook, official page, generic text, legal/civic/professional source.

The app imports containers. The app classifies categories after extraction.

## Universal pipeline

Source container -> extraction route -> normalized source record -> document category classifier -> claim candidates -> requirement/proof/starter candidates -> risk/freshness/privacy labels -> review sheet -> user confirmed/rejected/private claims -> private mini-pack or source-linked goal facts.

No step may silently mutate user goals, requirements, proof, recommendations, memory, schedule, or privacy state.

## Container coverage

### URL

Required states:

- pasted URL
- Share Sheet URL
- HTML page
- plain text page
- PDF URL
- redirect / canonical URL
- unavailable URL
- paywalled/login-required page
- JavaScript-heavy page fallback
- source changed later
- source hash mismatch
- private/sensitive URL

Required outputs:

- originalURL
- canonicalURL when available
- retrievedAt
- contentType
- pageTitle
- normalizedTextBlocks
- sourceHash
- extractionQuality
- sourceAuthorityCandidate
- userProvided flag
- reviewRequired flag

### PDF

Required states:

- local PDF import
- PDF URL import
- embedded/selectable text
- scanned/image PDF
- mixed text/image PDF
- encrypted/locked PDF
- huge PDF / size limit
- corrupted PDF
- partial extraction
- no text found
- low OCR confidence
- private/sensitive PDF

Required outputs:

- fileName
- pageCount
- metadata when available
- sourceHash
- textBlocksByPage
- ocrBlocksByPage
- extractionMode
- extractionQuality
- page locators
- reviewRequired flag
- privacy state

### Screenshot / image

Required states:

- screenshot import
- image import
- Share Sheet image
- OCR successful
- OCR low confidence
- OCR no text
- rotated/cropped image
- private/sensitive image

Required outputs:

- imageHash
- recognizedTextBlocks
- recognitionQuality
- manualCorrectionAvailable
- reviewRequired flag
- privacy state

### Copied/plain text

Required states:

- pasted text
- large pasted text
- malformed text
- missing source URL
- user adds optional source URL
- private/sensitive text

Required outputs:

- rawText
- normalizedText
- optionalSourceURL
- userProvided flag
- sourceAuthority unknown by default
- reviewRequired flag

### Local file

Required states:

- PDF
- image
- text
- unsupported type
- too large
- inaccessible security-scoped resource
- private/sensitive file

Required outputs:

- UTType classification
- routed container type
- unsupported fallback copy
- privacy state

### Official source pack

Required states:

- bundled pack
- cached pack
- downloaded pack
- invalid schema
- hash mismatch
- signature missing
- signature invalid
- revoked pack
- stale pack

Required outputs:

- pack status
- validation result
- freshness result
- rollback result
- quarantine result

### User mini-pack

Required states:

- created from confirmed source claims
- partially confirmed
- rejected claims
- private claims
- source deleted
- source stale
- source disputed

Required outputs:

- local-only mini-pack
- user confirmation ledger
- correction/deletion/rejection path
- source locator
- privacy state

## Document category coverage

### Rulebook

Detect when possible:

- rule title
- governing body
- version/effective date
- sections/rules
- equipment requirements
- scoring rules
- eligibility rules
- sanctions/competition rules

Required copy:

- official only if official source is proven
- stale if effective date unknown/past policy
- review required for eligibility/equipment claims

### School program page

Detect when possible:

- institution
- program name
- degree/certificate
- prerequisites
- admissions requirements
- application deadline
- tuition/cost
- credits
- residency/state rules
- accreditation notes
- contact office

Required copy:

- no admission guarantee
- no cost guarantee unless current source-backed
- deadline-sensitive claims require freshness
- high-risk education label

### Job posting

Detect when possible:

- employer
- role title
- location
- salary if listed
- responsibilities
- required skills
- preferred skills
- years experience
- education
- certifications
- application deadline
- source date

Required copy:

- example market evidence only
- not universal career requirement
- job posting may expire

### Certification handbook

Detect when possible:

- issuing body
- credential
- eligibility
- prerequisites
- exam requirements
- fees
- renewal
- continuing education
- deadline
- effective date
- jurisdiction

Required copy:

- no eligibility certification
- strict review
- source freshness required

### Official page

Detect when possible:

- authority name
- source URL
- page title
- published/revised date
- jurisdiction
- official-domain candidate

Required copy:

- official label requires recognized authority/source proof
- official-looking page is not enough

### Generic text

Detect when possible:

- requirements language
- steps
- deadlines
- equipment
- proof
- unknowns

Required copy:

- user-provided / source unknown
- useful starter extraction only

### Legal / civic / professional source

Required handling:

- strict review
- no legal/professional advice
- no eligibility or compliance certification
- recommend official/professional review where appropriate

## Failure states

Every source type must support:

- import needs review
- extraction needs review
- partial extraction
- low-quality extraction
- source missing
- source stale
- source unsupported
- source private
- review skipped
- user deleted source
- user rejected claims
- no internet

## Required rendered proof

When UI is implemented, FVQ must capture:

- URL source review
- PDF text extraction review
- scanned PDF/OCR review
- screenshot/OCR review
- copied text review
- job posting example-only review
- school program strict-review state
- certification handbook strict-review state
- source-needed fallback
- private source shield
- stale/source-changed state
- low-confidence OCR state
- rejected claim state
- Dynamic Type / reduced-motion equivalent

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
