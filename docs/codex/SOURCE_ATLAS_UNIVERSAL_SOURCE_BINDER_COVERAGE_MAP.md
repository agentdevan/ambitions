# Source Atlas Universal Source Binder Coverage Map
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

- import failed
- extraction failed
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
