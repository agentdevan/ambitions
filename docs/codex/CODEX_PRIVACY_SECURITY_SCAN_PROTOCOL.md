# Codex Privacy Security Scan Protocol

Status: Active privacy/security scan protocol.  
Date: 2026-05-08  
Scope: Privacy, security, secrets, sensitive logs, and unsupported compliance claims.

## Components

- CQS privacy/security/release claim scan
- `python3 scripts/ai/acx_local.py run cqs-release-claims`
- `python3 scripts/ai/acx_local.py bundle batch-closeout`
- `docs/codex/CODEX_EVIDENCE_STANDARD.md`

## Required Checks

- No committed secrets or credential-shaped values.
- No private user content in developer logs.
- No unsupported privacy/legal/compliance claims.
- No App Store/TestFlight/release readiness claim without proof.
- No hidden remote analytics/telemetry claim unless implemented and reviewed.

## Claim Boundary

A passing scan is advisory. It does not prove legal compliance, privacy compliance, security certification, or App Store readiness.
