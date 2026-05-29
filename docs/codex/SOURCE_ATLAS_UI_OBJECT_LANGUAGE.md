# Source Atlas UI Object Language

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-97667743, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, terminology-quarantine
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active UI object language for Source Atlas visible states.
Date: 2026-05-06

## Purpose

Source Atlas must appear as Ambitions-native trust chrome inside existing surfaces, not as a separate source-management app. This file defines the UI objects that may represent source, freshness, user-imported documents, OCR, review, and impact states.

## Product law

Source Atlas UI must be:

- quiet
- source-grounded
- progressively disclosed
- privacy-aware
- review-first
- accessible
- reduced-motion safe
- never dashboard-like
- never a source database default view
- never an AI chat surface

## Allowed objects

### SourceBadge

Compact label that communicates source state.

Allowed labels:

- Source-backed
- Official source
- User-provided
- Inferred
- Source needed
- Stale source
- Review needed
- Private source

Must include VoiceOver text and not rely on color alone.

### FreshnessBadge

Compact label for freshness state.

Allowed labels:

- Current
- Aging
- Stale
- Critical stale
- Source changed
- Unknown freshness
- User-provided
- Revoked

### SourceNeededFold

Progressive disclosure object shown when exact official/current source is missing.

Required copy posture:

> I can create a general starter path, but official requirements need a source.

### RequirementSourceFold

Expandable detail object attached to a requirement or path claim.

Must show:

- claim text
- source state
- freshness state
- source locator when available
- review status
- risk class when relevant
- last verified/retrieved date when available

### ClaimReviewDrawer

Review object for extracted claim candidates.

Required actions:

- confirm
- edit
- reject
- mark private
- needs official review
- do not use for recommendations
- delete source

### SourceBinderReviewSheet

Larger review flow for imported URL/PDF/image/text sources.

Must show extraction quality, source container, document category, privacy state, and extracted candidates. It must never auto-save high-impact claims.

### PackUpdateReceipt

Receipt shown after pack/freshness updates.

Required posture:

- what changed
- what claims were affected
- whether user goals may be impacted locally
- review action if needed
- rollback/stale fallback if needs review

### PrivateSourceShield

Privacy notice for sensitive source material.

Required behavior:

- clear private label
- no external surface projection by default
- no logging/analytics copy
- delete/hide/correct path

### OCRReviewNotice

Notice shown for OCR-derived text.

Required posture:

> Text was recognized from an image or scanned page. Review before saving.

OCR output is always review-required.

### SourceImpactReceipt

Receipt shown when a changed claim affects a local goal/path/recommendation.

Must be local/private and must not imply server-side knowledge of user goals.

## Surface placement

### Today

Allowed:

- one compact source/freshness line inside Start Here
- source-needed fold when recommendation depends on missing source
- receipt drawer detail

Forbidden:

- source surface
- list of all packs
- source health KPI card

### Goals

Allowed:

- source/freshness badge on requirement/proof/path claims
- proof/source fold inside Goal Detail / Mission Control
- source impact receipt after pack change

Forbidden:

- project-management source board
- wall of requirement cards
- source-pack browser

### Capture

Allowed:

- source attach affordance in Capture composer
- Universal Source Binder route
- review sheet
- source-needed fallback

Forbidden:

- Capture becoming source inbox
- hidden claim/goal promotion

### Plan

Allowed:

- stale/deadline/source warning when it affects scheduling or reflow
- review-before-schedule fold

Forbidden:

- legal/deadline surface
- calendar clone of source events

### You

Allowed:

- source/privacy controls
- imported source history
- pack/freshness settings
- delete/correct/reject controls

Forbidden:

- all-source database default
- admin console feel
- marketplace/storefront

## Required rendered proof states

Every UI batch touching Source Atlas must capture:

- source-backed
- source-needed
- user-provided
- stale
- source-changed
- disputed
- revoked
- private source
- OCR low-confidence
- partial PDF extraction
- review-needed
- no internet / last-known-good
- high-risk strict-review
- Dynamic Type-adjacent
- reduced-motion equivalent

## Copy rules

Use:

- "Based on a source you added"
- "Needs official review"
- "Last checked"
- "Source changed"
- "I can help from the last saved source"
- "Official requirements need a source"

Do not use:

- "Verified by Ambitions" unless actual verification exists
- "Guaranteed"
- "Complete requirements"
- "Always up to date"
- "You are eligible"
- "Legally compliant"
- "Professional advice"
- "AI found the truth"

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
