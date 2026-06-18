---
name: ambitions-release-proof-honesty
description: Use for Ambitions release/readiness wording, proof packets, App Store/TestFlight boundaries, and validation evidence honesty.
---

# Ambitions Release Proof Honesty

This skill is operating support only. `docs/truth/RELEASE_TRUTH.md` is the release claim authority.

## Rule

If proof is absent, readiness is absent.

Never claim build success, test success, release readiness, TestFlight readiness, App Store readiness, device readiness, accessibility conformance, performance readiness, privacy/legal approval, CI proof, account readiness, or R2 readiness without current evidence.

## Workflow

1. Read `docs/truth/RELEASE_TRUTH.md`.
2. Separate verified, failed, not verified, blocked, and human/device follow-up.
3. Treat old reports, screenshots, batch closeouts, and deleted artifacts as stale unless tied to the current commit and current logs.
4. Replace overclaims with proof-bound status.
5. Preserve explicit owner approval gates for signing, archive export, upload, legal/privacy, public claims, and distribution.
