# Repo-Wide Cleanup Report

Status: completed documentation/source-truth cleanup pass.

Date: 2026-05-08

## Scope

This pass cleaned the repo-wide documentation front door, source-truth routing, cleanup posture, and validation evidence posture.

It did not implement app features, refactor Swift source, change app IA, modify persistence/schema, add dependencies, add hosted CI, or claim build/test/release proof.

## Completed changes

| Area | Action | Status |
| --- | --- | --- |
| Root README | Replaced the old front-door document with a clean product/developer landing page | Complete |
| Source truth | Routed current product/design truth to `docs/AmbitionsCanon/README.md` | Complete |
| Implementation status | Added `docs/status/current-implementation-map.md` | Complete |
| Cleanup posture | Added `docs/status/repo-cleanup-index.md` | Complete |
| Release evidence | Added `docs/status/release-evidence-packet.md` | Complete |
| Docs index | Simplified `docs/README.md` around current front-door/status docs | Complete |
| AI/Codex guidance | Updated `AGENTS.md` to follow current source routing and local validation | Complete |
| 3.0 source override | Marked `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md` as preserved baseline/history, not highest active canon | Complete |
| Hosted CI | Removed the GitHub Actions iOS workflow and locked the repo posture to local VM/Mac validation | Complete |

## Current front-door source hierarchy

Use this order for current repo orientation:

1. `README.md`
2. `docs/README.md`
3. `docs/AmbitionsCanon/README.md`
4. `docs/status/current-implementation-map.md`
5. `docs/status/repo-cleanup-index.md`
6. `docs/status/release-evidence-packet.md`
7. `docs/native-build-and-release.md`
8. target source files and tests

## Current validation posture

Ambitions uses local VM/Mac validation as the source of truth.

There is no active hosted CI workflow in this repo.

Primary local validation evidence may come from:

- `xcodegen generate`
- `./scripts/build-local.sh`
- focused `xcodebuild` simulator builds
- focused `xcodebuild` unit tests
- focused `xcodebuild` UI tests
- unsigned archive sanity checks
- raw local command logs

## Retained but quarantined material

The following material is intentionally retained but is not the public repo front door or current implementation proof by itself:

- `.codex/`
- `.agents/`
- `docs/codex/`
- `docs/audits/`
- `docs/handoff/`
- older `docs/canon/Ambitions_3_0*` and `Ambitions_4_0*` files
- PXOS / SI / FCP / PFC / AOS / LDI batch materials

These files may remain useful for traceability, Codex execution, historical context, or stricter proof gates where compatible.

## Safety decisions

- No production Swift files were modified.
- No tests were modified.
- No project/build configuration was modified, except the hosted CI workflow removal.
- No Codex/batch-train files were deleted.
- No historical audit or handoff files were deleted.
- No hosted validation provider was added.
- No release-readiness language was added.

## Remaining optional cleanup

The following are intentionally left for future explicit approval:

1. Destructive archive/removal pass for obsolete docs.
2. Generated doc inventory that tags every Markdown file as active, supporting, historical, future, or archived.
3. Targeted removal or archival of backend/provider-specific skill material that is not active native-iOS truth.
4. Scripted claim scan that fails on unsupported hosted-CI, release-ready, TestFlight-ready, App Store-ready, device-verified, public-accessibility-compliant, or legal/privacy-approved language in front-door docs.
5. Deeper cleanup of old batch-train status files once global batch-train continuity no longer depends on them.

## Current non-claims

This cleanup does not prove:

- app build success
- test success
- UI test success
- preview success
- signed archive correctness
- TestFlight readiness
- App Store readiness
- physical-device behavior
- public accessibility conformance
- legal/privacy compliance
- human release approval

## Result

Green for documentation/source-truth cleanup.

Yellow for repo-wide historical bloat because retained historical/Codex/batch material still exists by design. It is now routed and quarantined instead of presented as public/source-truth front-door material.
