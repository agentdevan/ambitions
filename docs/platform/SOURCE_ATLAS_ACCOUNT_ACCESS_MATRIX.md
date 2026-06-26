# Source Atlas Account Access Matrix

Status: M06 implementation support
Scope: Source Atlas public/reference artifact access, optional Ambitions Account posture, entitlement state, cache fallback, and no-account unavailable states
Owner posture: Platform support, not product canon, account readiness proof, entitlement readiness proof, R2 production proof, privacy/legal approval, or release proof

Source Atlas is public/reference/freshness infrastructure. It is not the Private Life Runtime, not a private user-data backend, and not an account wall for Today / Goals / Time / You.

## Access Inputs

| Input | Allowed values | Private runtime data allowed |
|---|---|---|
| Account session | no account, signed out, signed in, expired, restricted, unknown | no |
| Entitlement | bundled only, entitled, expired, denied, restricted, unknown | no |
| Network | online, offline, constrained | no |
| Artifact tier | bundled core, public freshness, entitlement reference pack | no |
| Cache state | bundled public artifact, cached public artifact, last-known-good public artifact | no |

## Decision Matrix

| Scenario | Route | Remote request | Cache read | Core local planning |
|---|---|---:|---:|---|
| No account + offline + bundled core available | bundled local | no | yes | unblocked |
| Signed in + entitled + online entitlement pack | remote public reference | yes | no | unblocked |
| Signed in + expired entitlement + cached public artifact | cached public | no | yes | unblocked |
| Signed out + bundled-only entitlement + cached public artifact | cached public | no | yes | unblocked |
| No account + denied entitlement + offline + no public cache | unavailable | no | no | unblocked |
| Public freshness + offline + last-known-good available | last-known-good | no | yes | unblocked |

## Hard Boundaries

- Ambitions Account state must not be treated as iCloud/CloudKit account state.
- Account or entitlement failure may block live/public reference refresh, not offline core use.
- Source Atlas cache may hold public/reference artifacts, manifests, hashes, freshness state, revocation state, and last-known-good pointers.
- Source Atlas cache must not hold locally joined personalized output, goals, captures, schedule/capacity, proof payloads, receipts, private graph nodes/edges, account secrets, user IDs, or inferred priorities.
- Sign-in, sign-out, entitlement changes, and offline transitions must not erase or upload the private life graph.

## Implemented Model

Current scoped implementation path:

```text
Native/Ambitions/Core/Runtime/SourceAtlasAccessBoundary.swift
Native/AmbitionsTests/Runtime/SourceAtlasAccessBoundaryTests.swift
Native/Ambitions/Core/Persistence/SourceAtlasLocalPackCache.swift
Native/AmbitionsTests/Persistence/SourceAtlasLocalPackCacheTests.swift
```

## Non-Claims

This matrix does not prove Sign in with Apple, Google Sign-In, Ambitions Account readiness, account recovery, entitlement service readiness, deployed R2 access, production freshness, privacy/legal approval, App Store readiness, or Source Atlas project closeout.
