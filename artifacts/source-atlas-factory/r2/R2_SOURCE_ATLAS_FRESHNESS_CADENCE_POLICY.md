# R2 Source Atlas Freshness Cadence Policy

Status: Green for AMB-674 / PLOS-046 freshness cadence policy scope; Yellow for background task implementation, runtime freshness evaluator implementation, live R2 account proof, bucket provisioning, network validation, release tooling, privacy/legal approval, release readiness, device proof, accessibility proof, and measured battery/network performance proof.
Updated: 2026-06-12 America/New_York
Owning issue: AMB-674 / PLOS-046
Parent issue: AMB-612 / PLOS-M04

## Boundary

This artifact defines Source Atlas refresh windows, check cadence, urgency tiers, freshness classes, stale-state behavior, revocation precedence, and battery/network cost posture for future public Source Atlas R2 distribution.

It does not implement background tasks, runtime refresh scheduling, runtime freshness evaluation, network code, cache storage, manifest parsing, release tooling, pack publication, Cloudflare/R2 setup, credential creation, or live R2 writes.

Fetched material is public-reference-only. The app must never send private user data, user identifiers, device identifiers, raw private goal text, private source-needed requests, diagnostics, support bundles, secrets, account ids, or write-token material to R2.

## Precedence Rules

Freshness cadence is not an override path. Future implementation must evaluate cadence only after higher-priority safety gates remain satisfied.

Precedence order:

1. Revocation and emergency safety state.
2. Signature, hash, signer trust, schema, compatibility, rollback, and release receipt validity.
3. Source authority state and jurisdiction/high-risk policy.
4. Freshness class and cadence.
5. Battery, network, launch-cost, and user-context deferral policy.

A fresh artifact that fails revocation, trust, compatibility, source-authority, privacy-boundary, rollback, or receipt checks is not runtime-eligible. A stale artifact must be labeled as stale, degraded, source-needed, review-needed, or blocked instead of silently presented as current.

## Freshness Classes

Freshness classes describe how aggressively future runtime should check public Source Atlas control manifests and whether cached data may remain usable.

| Class | Intended use | Control check target | Soft stale | Hard expiry | Allowed stale behavior |
|---|---|---:|---:|---|
| `static_reference` | Stable definitions, evergreen explainers, low-change public reference material | 30 days | 90 days | Degraded use allowed if source authority, revocation, compatibility, and receipt gates still pass |
| `periodic_reference` | Policy, service, jurisdiction, pricing, process, or source metadata likely to change on a regular cadence | 7 days | 30 days | Degraded or source-needed; do not claim current |
| `high_change_reference` | Volatile public facts, fast-changing availability, public program rules, or operational eligibility data | 24 hours | 7 days | Source-needed or review-needed; current claims blocked |
| `high_risk_reference` | Medical, legal, financial, crisis/safety, regulated, minors/student, cannabis, or jurisdiction-sensitive public guidance | 12 hours | 72 hours | Block current use unless a verified fresh source or approved professional-boundary path exists |
| `emergency_revocation` | Compromise, unsafe source, pack withdrawal, signer incident, or public safety correction | Immediate on next control-manifest check | Immediate | Block/quarantine regardless of local cache age |

These windows are defaults for policy. Future pack manifests may choose stricter windows, but must not loosen high-risk, revocation, privacy, or release-receipt requirements without a new owning issue and proof.

## Urgency Tiers

Future refresh scheduling should use urgency tiers to avoid churn while preserving safety.

| Tier | Trigger | Expected future behavior | User-facing state |
|---|---|---|---|
| `calm` | Cached verified pack is inside freshness window and no revocation/safety signal exists | No launch-blocking fetch; opportunistic bounded control-manifest check only | Current or quiet verified |
| `routine` | Soft stale threshold reached for static or periodic material | Refresh compact control manifests when network and battery are reasonable; keep verified stale fallback explicit | Degraded or source age disclosed |
| `attention` | High-change material is stale, source authority changed, or compatibility/ring metadata points to newer pack | Prioritize control-manifest refresh before new current recommendations; avoid fetching full pack until manifests pass | Source-needed or review-needed |
| `urgent` | High-risk material is stale or nearing hard expiry, rollback target changed, or release receipt indicates safety correction | Check control manifests before using affected source for current advice; block if unable to verify | Blocked, source-needed, or professional-boundary |
| `stop` | Revocation, emergency safety, signer compromise, invalid control state, private-data contamination, or hard expiry | Quarantine/block immediately; do not rely on freshness grace | Blocked/quarantined |

## Cadence Rules

Future implementation should apply these cadence rules:

- App launch must prefer verified local state and must not block local-first startup on remote fetch.
- Compact control manifests are the normal refresh unit; immutable pack bytes are fetched only after current, compatibility, freshness, revocation, rollback, release receipt, and source authority gates pass.
- Cadence should be per affected pack/source family, not a global full-bucket sweep.
- Backoff should increase after repeated network or verification failures, but revocation and emergency safety signals remain stop-class conditions.
- Low Power Mode, constrained network, no connectivity, or foreground urgency can defer calm/routine checks, but must not convert stale or revoked material into current material.
- Offline grace is allowed only for verified last-known-good material whose freshness class permits stale behavior and whose revocation/safety state is not known unsafe.
- Future background refresh is owned by a later implementation issue. This policy only defines the required behavior and evidence boundaries.

## Stale State Contract

Stale state must be explicit and inspectable:

- `verified_current`: inside freshness window and all higher-priority gates pass.
- `verified_stale_allowed`: soft stale, still allowed for degraded use with source age disclosed.
- `source_needed`: source must be refreshed before current recommendation or schedule install.
- `review_needed`: high-risk, jurisdiction, conflict, or source-authority review is required.
- `hard_expired`: material is not runtime-eligible except as historical/proof context.
- `revoked_or_quarantined`: blocked regardless of age or cache state.

No future UI or runtime path may claim a stale Source Atlas object is current merely because it is cached. Prefer stale-but-explicit over unverified freshness claims.

## Battery And Network Cost

Cadence should support calm, not churn:

- Keep routine checks compact by refreshing control manifests before immutable packs.
- Avoid repeated full-pack downloads for unchanged `sha256` and release receipt state.
- Coalesce checks by ring, pack family, and source family where this does not weaken revocation precedence.
- Defer calm/routine checks under Low Power Mode, constrained network, active user execution, or launch pressure.
- Log local verification receipts for why a pack was used, degraded, blocked, or refreshed without sending private data outward.
- Future performance proof must measure startup impact, network bytes, retry count, battery-sensitive deferral behavior, and cache-hit behavior before any performance Green claim.

## Rollback And Failure Behavior

Rollback/failure behavior:

- Revocation or emergency safety beats rollback convenience.
- A rollback target must pass signature/hash, compatibility, freshness, revocation, source-authority, release receipt, and privacy-boundary gates before use.
- A missing, stale, revoked, incompatible, or unverifiable rollback target is blocked or source-needed, not silently accepted.
- Repeated refresh failure keeps the last-known-good state only within that freshness class's stale allowance.
- Hard-expired, high-risk, revoked, or contaminated material must fail closed.

## Non-Claims

This artifact does not implement background fetch, runtime freshness evaluation, runtime scheduling, network fetching, manifest parsing, cache/quarantine storage, release tooling, pack publication, Cloudflare/R2 setup, credential creation, live R2 writes, network validation, production-readiness proof, privacy/legal approval, release readiness, device proof, accessibility proof, or measured performance proof.
