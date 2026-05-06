# HPS03 Verified Proof Ledger Proof Portability Architecture Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow as docs-domain architecture.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade Train
Owner: Proof Trust / Source Truth

## Purpose

Define the Verified Proof Ledger and proof portability architecture that
Ambitions, AOS, LDI, Source Atlas, Found Life, Goal paths, Action Closure,
export/import, and external-surface work must inherit.

HPS03 is docs-domain architecture only. It does not implement a runtime ledger,
schema, persistence, export format, verifier product, public credential,
marketplace, sync, cloud, account, AI runtime, or UI.

## Allowed Files

- HPS03 canon/prompt/report docs
- HPS train status
- global-order, registry, context, dependency, and run-state docs

## Forbidden Files

- Production Swift
- Persistence/schema/migration files
- Runtime proof ledger store
- Export/import implementation
- Sync/cloud/account/backend
- Hosted AI or model adapter implementation
- Verifier roles, public credentials, marketplace, API product, or institution
  workflow implementation
- Top-level navigation or visible all-proof control surface
- Source Atlas runtime, PDF/OCR, URL import, pack download/update, or official
  source behavior
- Release/App Store/TestFlight/device/accessibility/acquisition claims

## Required Acceptance

- Proof object families exist.
- Proof state fields exist.
- Proof strength and portability states exist.
- Proof-to-requirement mapping exists.
- Privacy and redaction rules exist.
- Future verifier boundary exists without product implementation.
- API contract families exist for proof read, proposal, portability, and
  receipt.
- Silent proof creation, promotion, export, or externalization is forbidden.
- Proof remains user-owned and never becomes a score, feed, marketplace, public
  credential, or official validation claim.

## Validation

Run docs-only validation and targeted CQS scans. Missing HPS physical advisory
scripts remain accepted Yellow under the HPS Codex OS owner until implemented.
