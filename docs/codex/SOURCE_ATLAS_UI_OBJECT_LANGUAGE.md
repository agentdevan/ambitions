# Source Atlas UI Object Language
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
- rollback/stale fallback if failed

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

- source dashboard
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

- legal/deadline dashboard
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
