# HPS02 Human Progress Graph API Architecture Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow as docs-domain architecture.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade Train
Owner: AOS / Found Life / Data Architecture

## Purpose

Define the Human Progress Graph and API architecture that AOS, LDI, Source
Atlas, Found Life, proof, source, recommendation, memory, option-value, and
external-surface work must inherit.

HPS02 is docs-domain architecture only. It does not implement runtime models,
persistence, schema, migration, sync, source packs, AI runtime, or UI.

## Allowed Files

- HPS02 canon/prompt/report docs
- HPS train status
- global-order, registry, context, dependency, and run-state docs

## Forbidden Files

- Production Swift
- Persistence/schema/migration files
- Runtime graph store
- Sync/cloud/account/backend
- Hosted AI or model adapter implementation
- Top-level navigation or visible graph surface
- Source Atlas runtime, PDF/OCR, URL import, pack download/update, or official
  source behavior
- Release/App Store/TestFlight/device/accessibility/acquisition claims

## Required Acceptance

- Minimal graph node and edge taxonomy exists.
- API contract families exist for read, mutation proposal, receipt, and
  projection.
- Privacy, source, freshness, and review states exist.
- Silent mutation is forbidden.
- External surfaces are private/redacted by default.
- Source Atlas is required for real-world/source-backed requirements.

## Validation

Run docs-only validation and targeted CQS scans. Missing HPS physical advisory
scripts remain accepted Yellow under the HPS Codex OS owner until implemented.
