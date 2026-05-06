# Ambitions Source Atlas
<!-- markdownlint-disable MD013 -->

Status: Active source truth / pre-AOS and pre-LDI implementation layer.
Date: 2026-05-06
Train: SA01-SA32 Source Atlas Full Maturity Train

## Thesis

Source Atlas is Ambitions’ signed, offline-first, claim-level world-source system.

It exists so Ambitions can evolve with the user’s life and the world without becoming a brittle online app, hallucinated AI planner, expensive backend, or vague legal/professional advice engine.

Core law:

> Ambitions may always help. Ambitions may only be authoritative when source proof exists.

Source Atlas turns external sources and user-provided sources into reviewable claim candidates, sourced requirements, proof maps, starter kits, freshness states, and receipts that AOS, LDI, Start Here, Goals, Capture, Plan, and You can consume without pretending to know more than they do.

## Non-negotiable boundaries

Source Atlas must not create:

- a sixth tab
- a Source Atlas dashboard
- a source-pack marketplace
- an official education/career database claim
- a user-data server
- hosted AI dependency
- account/sync requirement
- live-API dependency for core app behavior
- legal/career/education/professional certainty claim
- hidden goal/requirement/proof/memory mutation
- sensitive document leakage to logs, analytics, widgets, Live Activities, notifications, or screenshots by default

Source Atlas must preserve:

- local-first operation
- offline fallback
- user-owned source review
- source/freshness/uncertainty labels
- user-provided-is-not-official distinction
- OCR review-required behavior
- no-claim language
- HPS no-sprawl and FVQ rendered-proof gates

## System components

### 1. Source Pack Runtime

The app-side runtime loads bundled and cached source packs, validates schema/hash/signature state, indexes claims/requirements/starter kits/proof maps, resolves freshness, and exposes query results to existing Ambitions surfaces.

It must work without internet using bundled or last-known-good packs. Missing, stale, invalid, corrupt, or revoked packs must degrade into source-needed, stale, or fallback starter states rather than crashing or hallucinating.

### 2. Universal Source Binder

Universal Source Binder imports user-provided sources and converts them into reviewable local claim candidates.

Supported input containers:

- URL
- PDF
- screenshot/image
- copied/plain text
- local file
- official source pack
- user mini-pack

Supported document categories:

- rulebook
- school program page
- job posting
- certification handbook
- official page
- generic source text
- high-risk/legal/civic/professional source

Document categories are not import mechanisms. They are classifications after extraction.

### 3. Pack Factory

Pack Factory is repo/tooling-side infrastructure that compiles hand-authored, official, API-derived, PDF-derived, and curated sources into source packs.

Pipeline:

source -> normalized source record -> atomic claim candidates -> requirement graph -> starter kit -> proof map -> freshness policy -> risk policy -> fixtures -> validation -> hash/signature -> pack artifact.

The app consumes compiled packs. It should not treat raw API output or model output as source truth.

### 4. Claim Review System

Every imported claim candidate must be reviewable before it can affect a goal, recommendation, requirement graph, proof map, memory, or Start Here decision.

Required actions:

- confirm
- edit
- reject
- mark private
- mark needs official review
- do not use for recommendations
- delete source

### 5. Freshness Broker

Freshness Broker is a public, non-personal manifest/diff system.

It publishes pack versions, changed claim IDs, hashes, signatures, revocation notices, and rollback pointers. It must not receive user goals, user identifiers, private sources, proof, memories, or personal life context.

The device privately joins changed claim IDs to local user goals.

### 6. AOS / LDI Integration

AOS and LDI must consume Source Atlas for source-backed requirements, dream/path claims, Start Here recommendation source lines, proof mapping, source freshness, and user-source review state.

AOS/LDI must not hallucinate official requirements when Source Atlas lacks a current source.

## Source container support

### URL

Full support requires pasted URL, Share Sheet URL, HTML/text/PDF detection, fetch failure fallback, canonical URL, redirect tracking, source snapshot hash, title extraction, text extraction, source authority candidate, user review, stale/freshness state, and no official claim by default.

### PDF

Full support requires local PDF import, PDF URL support, PDFKit embedded-text extraction, page-level references, metadata extraction when available, encrypted/locked/corrupt/huge/partial extraction states, Vision OCR fallback for scanned/image pages, low-confidence OCR labels, sensitive/private document state, and review-required claim candidates.

### Screenshot / image

Full support requires image import/share route, Vision OCR, text quality label, manual correction, review-required claims, private source handling, and no official label by default.

### Copied/plain text

Full support requires paste support, text normalization, document classification, review candidates, user-provided label, optional source URL attachment, and user correction.

### Rulebook

Rulebook support is category support over URL/PDF/text/image containers. The system must detect rules, equipment, scoring, eligibility, effective date, version, governing body, and source freshness where available. Official labels require official source proof.

### School program page

School program support is category support over URL/PDF/text/image containers. The system must detect institution, program, degree/certificate, prerequisites, deadlines, tuition/cost, credits, admissions requirements, residency/state rules, accreditation notes, contact office, and source date where available. It must use education-risk labels and avoid admission/eligibility certainty.

### Job posting

Job posting support is category support over URL/PDF/text/image containers. The system must detect employer, role, location, salary if listed, skills, responsibilities, years experience, certifications, education, deadline, and source date where available.

A job posting is example market evidence, not universal career truth.

### Certification handbook

Certification handbook support is category support over URL/PDF/text/image containers. The system must detect issuing body, credential, eligibility, prerequisites, exams, fees, renewal, continuing education, deadlines, effective date, jurisdiction, and source version where available. It requires strict review and cannot certify eligibility.

## Claim states

- official
- semiOfficial
- expert
- community
- maintainerCurated
- userProvided
- userConfirmed
- imported
- inferred
- ocrDerived
- stale
- staleCritical
- sourceChanged
- disputed
- revoked
- unsupported
- private
- unknown

## Freshness states

- current
- aging
- stale
- staleCritical
- sourceChanged
- disputed
- revoked
- unknown
- userProvided
- needsReview

## Risk classes

- lowRiskSkill
- hobby
- sportRules
- careerContext
- educationEligibility
- certificationEligibility
- legalCivic
- financial
- healthMedical
- crisisSafety
- minorStudentData
- professionalBoundary
- deadlineSensitive
- sensitivePrivate

## UI object law

Source Atlas UI must be a restrained object layer inside existing surfaces, never a new top-level destination.

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

Surface placement:

- Today: compact source/freshness line inside Start Here when relevant.
- Goals: source/proof/option-value states inside LifePath, Mission Control, and Proof Spine drill-downs.
- Capture: Universal Source Binder entry and review flow without replacing text-first Capture.
- Plan: source/stale/deadline warning only when it affects scheduling or reflow.
- You: source/privacy/history controls inside Personal System Center; no source database default view.

## Completion standard

Source Atlas is fully mature only when:

- source truth and gates exist
- Universal Source Binder supports all scoped input containers and document categories
- PDFKit extraction and Vision OCR fallback are implemented with review-required behavior
- pack schema and validators exist
- bundled core packs exist
- Source Needed Mode exists
- user mini-pack creation exists
- claim review UI exists
- pack factory tooling exists
- freshness manifest/diff/revocation contracts exist
- source/freshness UI primitives exist
- no-claim scanner exists
- offline fallback is tested
- AOS/LDI integration maps are updated
- FVQ rendered proof covers source states
- no release/legal/cloud/AI-runtime/current-data claim exceeds evidence
