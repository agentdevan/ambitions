# Source Atlas Gate Matrix

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active Source Atlas gate matrix for SA01-SA32, SAP composition/projection lock, and all Source Atlas-dependent work.
Date: 2026-05-06

## Purpose

This matrix prevents Source Atlas from becoming a brittle scraper, vague AI source system, source surface, privacy leak, unsupported official-requirement engine, static goal-template library, or one-pack-per-goal sprawl system.

Source Atlas must make Ambitions more trustworthy, more scalable, and more personal — not more claimy or more generic.

## Universal hard Red gates

| Gate | Hard Red condition |
|---|---|
| No Source Atlas surface Gate | Adds Source Atlas as a top-level tab, surface, marketplace, or database browser. |
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
| No One-Pack-Per-Goal Gate | Source Atlas creates isolated duplicate full packs for individual goals instead of composable domain/capability/overlay graph pieces. |
| Composable Pack Graph Gate | A pack lacks domain, pack type, reusable nodes, dependency packs, projection compatibility, and composition contract. |
| Goal Projection Gate | A user goal maps directly to a static pack/path instead of a GoalProjection and PersonalPathInstance. |
| Skill Slice Gate | Narrow skill goals load broad elite/pro paths instead of slicing relevant capability nodes. |
| Highest-Path Reuse Gate | Elite/pro paths duplicate lower-level beginner/intermediate nodes instead of reusing shared graph nodes. |
| Personal Path Instance Gate | Same goal/source projection cannot produce different outputs based on starting position, proof, constraints, time, source freshness, and privacy. |
| Alternative Path / Option Value Gate | Serious paths omit adjacent alternatives or transferable proof without an explicit no-known-alternative reason. |
| Steps Are Generated, Not Stored Gate | Source packs hardcode universal scheduled step plans rather than providing step candidate seeds for AOS/LDI/Plan. |
| Source Overlay Gate | Official/current requirements are stored in generic domain packs rather than source-sensitive RequirementOverlays. |
| Pack Duplication Gate | Duplicate claims/requirements appear across packs as copies rather than stable aliases or shared nodes. |
| Projection Receipt Gate | Generated paths lack a receipt explaining graph slice, sources used, sources excluded, uncertainty, and why the projection fits the user. |

## Composition and projection gates

Composition/projection is required before runtime pack creation scales.

Required objects:

- DomainPack
- SpecificDomainPack
- CapabilityGraph
- CapabilityNode
- CapabilityEdge
- LevelLadder
- RequirementOverlay
- RoleOverlay
- PathOverlay
- ProofMap
- AlternativePathSet
- OptionValueMap
- ProjectionRecipe
- GoalProjection
- ProjectionProfile
- PersonalPathInstance
- StepCandidateSeed

Required projection behavior:

1. User goal text is classified by intent.
2. Domain and ambition level are detected.
3. Relevant pack graph slices are selected.
4. Requirement overlays attach source/freshness/uncertainty.
5. User starting position, proof, time, constraints, privacy, and source state shape the PersonalPathInstance.
6. StepCandidateSeeds are produced; final steps are generated elsewhere.
7. AlternativePathSet and OptionValueMap are available for serious paths when meaningful.
8. Projection receipt explains why this graph slice was used and what source limits remain.

Forbidden projection behavior:

- one static path for every user with same goal
- using a pro-path pack as master owner of all lower paths
- creating separate full packs for every goal phrase
- duplicating official source claims across packs
- treating job postings or school pages as universal requirement paths
- generating final scheduled steps directly from packs

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
- projection compatibility when it can affect a path
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
- projection receipt
- alternative path / still-counts state
- narrow skill slice state
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
- ProjectionReceiptFold
- SkillSliceIndicator
- AlternativePathReceipt
- OptionValueFold

Forbidden UI patterns:

- source database surface
- pack marketplace UI
- giant source library as default surface
- AI chat source assistant
- KPI/source health surface on top-level tabs
- generic card stack of imported sources
- graph visualization as default top-level UI

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
- composition contract
- reusable capability node IDs
- overlay dependency declaration
- projection recipe validation
- duplicate claim alias validation

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

Source/freshness/projection state must not rely on color alone. Every badge/fold/drawer must have readable text, VoiceOver label, Dynamic Type behavior, and reduced-motion equivalent when animation is used.

## Closeout standard

SA32 cannot close until every Source Atlas gate is implemented, integrated into a later batch, or accepted Yellow with owner, repair path, and explicit user-facing claim block.

SAP cannot close until no one-pack-per-goal, graph composition, goal projection, skill slice, highest-path reuse, personal path instance, alternative path, and generated-step gates are implemented or explicitly owned by a later Source Atlas runtime batch.

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
