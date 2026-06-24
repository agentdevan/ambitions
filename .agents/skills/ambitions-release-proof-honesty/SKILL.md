---
name: ambitions-release-proof-honesty
description: Use for Ambitions release/readiness wording, proof packets, App Store/TestFlight boundaries, and validation evidence honesty.
---

# Ambitions Release Proof Honesty

## Skill digest
- Use when: validation, readiness wording, proof packets, Green/Yellow/Red status, privacy/account/R2 proof, TestFlight/App Store, or public claim language is in scope.
- Do not use as: product canon, implementation proof, release approval, or permission to upgrade status without evidence.
- Required first read: `docs/truth/CODEX_START_HERE.md`.
- Owns: proof classification, unsupported-claim removal, status ceiling, and allowed wording.
- Does not own: product canon, source truth, Visual Green, Release Green, human approval, or device proof.
- Hard red: build/test/release/device/accessibility/performance/privacy/account/R2 claim without current evidence.
- Required output: verified, failed, not verified, blocked, human/device follow-up, forbidden claims removed, allowed wording.

This skill is operating support only. `docs/truth/RELEASE_TRUTH.md` is the release claim authority.

`docs/truth/*`, live source, tests, current logs, current proof artifacts, and current user or issue instructions win over this skill.

## Rule

If proof is absent, readiness is absent.

Never claim build success, test success, release readiness, TestFlight readiness, App Store readiness, device readiness, accessibility conformance, performance readiness, privacy/legal approval, CI proof, account readiness, or R2 readiness without current evidence.

## Workflow

1. Read `docs/truth/CODEX_START_HERE.md`.
2. Read `docs/truth/RELEASE_TRUTH.md`.
3. Read `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md` when visual, accessibility, device, split-status, or product-surface status is in scope.
4. Separate verified, failed, not verified, blocked, and human/device follow-up.
5. Treat old reports, screenshots, batch closeouts, and deleted artifacts as stale unless tied to the current commit and current logs.
6. Replace overclaims with proof-bound status.
7. Preserve explicit owner approval gates for signing, archive export, upload, legal/privacy, public claims, and distribution.

## Output

- Verified
- Failed
- Not verified
- Blocked
- Human/device follow-up
- Forbidden claims removed
- Allowed wording
