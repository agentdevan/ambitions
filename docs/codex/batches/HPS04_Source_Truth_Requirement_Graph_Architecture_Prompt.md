# HPS04 Source Truth Requirement Graph Architecture Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow as docs-domain architecture.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade Train
Owner: Source Truth / Goal Path / LDI

## Purpose

Define the Source Truth and Requirement Graph architecture that AOS, LDI,
Source Atlas, Goals, proof, recommendations, option value, export/import, and
external-surface work must inherit.

HPS04 is docs-domain architecture only. It does not implement source packs,
scraping, OCR, PDF or URL import, source refresh, claim extraction,
requirement runtime, schema, persistence, sync, hosted service, AI runtime, or
UI.

## Allowed Files

- HPS04 canon/prompt/report docs
- HPS train status
- global-order, registry, context, dependency, and run-state docs

## Forbidden Files

- Production Swift
- Persistence/schema/migration files
- Runtime source truth or requirement graph store
- Source Atlas runtime, PDF/OCR, URL import, pack download/update, or official
  source behavior
- Scraping, source refresh, source certification, or requirement extraction
- Sync/cloud/account/backend
- Hosted AI or model adapter implementation
- Official career/education/professional requirement database
- Verifier, credential, marketplace, API, school, workforce, or professional
  advice product implementation
- Top-level navigation or visible requirement control surface
- Release/App Store/TestFlight/device/accessibility/acquisition claims

## Required Acceptance

- Requirement object families exist.
- Requirement state fields exist.
- Claim, source quality, freshness, and uncertainty states exist.
- Requirement edge families exist.
- Source conflict behavior exists.
- Recommendation boundary exists for source/freshness/uncertainty gates.
- API contract families exist for read, proposal, conflict, and projection.
- Silent requirement creation, promotion, supersession, or officialization is
  forbidden.
- Source Atlas inheritance exists for real-world requirements.
- No official requirement, professional advice, eligibility certainty, or
  source-certification claim is made.

## Validation

Run docs-only validation and targeted CQS scans. Missing HPS physical advisory
scripts remain accepted Yellow under the HPS Codex OS owner until implemented.
