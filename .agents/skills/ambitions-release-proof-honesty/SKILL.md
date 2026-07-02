---
name: ambitions-release-proof-honesty
description: Use for Ambitions release/readiness wording, proof packets, App Store/TestFlight boundaries, and validation evidence honesty.
---

# Ambitions Release Proof Honesty

## Skill digest
- Use when: validation, readiness wording, proof packets, Green/Yellow/Red status, privacy/account/R2 proof, TestFlight/App Store, or public claim language is in scope.
- Do not use as: product canon, implementation proof, release approval, or permission to upgrade status without evidence.
- Required first read: `docs/truth/CODEX_START_HERE.md`.
- Owns: proof classification, unsupported-claim removal, proof artifact closeout requirements, status ceiling, and allowed wording.
- Does not own: product canon, source truth, Visual Green, Release Green, human approval, or device proof.
- Hard red: build/test/release/device/accessibility/performance/privacy/account/R2 claim without current evidence.
- Required output: proof-claim labels used, verified, failed, not verified, blocked, human/device follow-up, forbidden claims removed, allowed wording.

This skill is operating support only. `docs/truth/RELEASE_TRUTH.md` is the release claim authority.

`docs/truth/*`, live source, tests, current logs, current proof artifacts, and current user or issue instructions win over this skill.

## Rule

If proof is absent, readiness is absent.

Never claim build success, test success, release readiness, TestFlight readiness, App Store readiness, device readiness, accessibility conformance, performance readiness, privacy/legal approval, CI proof, account readiness, R2 readiness, Source Atlas production readiness, or broad remediation Green without current evidence.

Proof automation outranks prose: current scripts, logs, artifacts, owner approvals, and accepted review evidence set the claim ceiling. A Linear comment, truth-doc change, closeout summary, screenshot path, or old report may summarize evidence; it cannot upgrade absent, stale, failed, or not-run proof.

Accepted Yellow is forbidden for incomplete required remediation scope. Release,
device, privacy/legal, or production-environment risk may be deferred only when
it is outside the issue's required source/runtime/test acceptance, explicitly
owner-accepted, linked to a blocker, and not used by any Green claim.

## Workflow

1. Read `docs/truth/CODEX_START_HERE.md`.
2. Read `docs/truth/RELEASE_TRUTH.md`.
3. Read `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md` when visual, accessibility, device, split-status, or product-surface status is in scope.
4. Separate verified, failed, not verified, blocked, and human/device follow-up.
5. Label proof-sensitive claims as Release-proof, Device-proof, Privacy-proof, Accessibility-proof, or Performance-proof when those claim types are in scope.
6. Treat old reports, screenshots, batch closeouts, and deleted artifacts as stale unless tied to the current commit and current logs.
7. Replace overclaims with proof-bound status: Implemented Yellow, Partial, Aspirational, Blocked, or Unknown when linked evidence is missing.
8. Preserve explicit owner approval gates for signing, archive export, upload, legal/privacy, public claims, and distribution.
9. For Source Atlas/R2 wording, require public-reference/no-private-life-graph boundary evidence before any growth, readiness, entitlement, privacy, or production claim.
10. Reject Accepted Yellow wording when it closes required source/runtime/test remediation instead of leaving the issue `In Progress`, moving it to `Needs Repair`, or waiting for `Ready For Review` proof.

## Output

- Proof-claim labels used
- Verified
- Failed
- Not verified
- Blocked
- Human/device follow-up
- Forbidden claims removed
- Allowed wording
- Proof artifacts required for any future status upgrade
