# Source Atlas Train 34 Public Worker Gateway And Live Native URLSession Proof

Status: Green for bounded Worker gateway live transport and native lifecycle refresh proof; Yellow overall Source Atlas.

Linear: AMB-1520

Created: 2026-06-28T03:54:54Z

## Scope Completed

- Added `ambitions-source-atlas-public-gateway`, a bounded Cloudflare Worker gateway for production stable `occupation_foundation` public/reference pack objects.
- Bound the Worker to R2 bucket `ambitions-source-atlas-prod`.
- Did not enable bucket-wide r2.dev public access.
- Recorded owner approval scoped to this bounded Worker gateway proof.
- Deployed the Worker to `https://ambitions-source-atlas-public-gateway.devanwarner.workers.dev`.
- Verified public HTTPS readback and SHA-256 for `current.json`, `revocations.json`, `lkg.json`, `manifest.json`, and `pack.json`.
- Verified root, non-allowlisted object, query-bearing request, and POST probes are blocked.
- Wired native default app container transport to the public gateway endpoint and active production stable `occupation_foundation` refresh target.
- Added live env-gated URLSession and lifecycle-service XCTest proof.

## Worker Gateway

- Name: `ambitions-source-atlas-public-gateway`
- URL: `https://ambitions-source-atlas-public-gateway.devanwarner.workers.dev`
- R2 bucket: `ambitions-source-atlas-prod`
- R2 binding: `SOURCE_ATLAS_BUCKET`
- Deployed version: `302c92c0-cba8-4837-be7e-36acd0f14732`
- Approval artifact: `docs/qa/source-atlas/r2/source-atlas-public-r2-worker-gateway-owner-approval-train-34.md`

Allowed object keys:

- `source-atlas/v1/production/stable/occupation_foundation/current.json`
- `source-atlas/v1/production/stable/occupation_foundation/lkg.json`
- `source-atlas/v1/production/stable/occupation_foundation/revocations.json`
- `source-atlas/v1/production/stable/occupation_foundation/20260628T000000Z/manifest.json`
- `source-atlas/v1/production/stable/occupation_foundation/20260628T000000Z/pack.json`

## Readback Hashes

- `current.json`: `33eb11402140afb9e0cd44baa0f053021d2e8b04a4e8eca0b81b4b4e0ba2f498`
- `lkg.json`: `0bdce7b2eb6406f2234bd62f24101a44795d5d0a689fc88d28bb1ae930e4f12a`
- `manifest.json`: `6f8f394a912b4983c4b19512c776b21844834fd1df5713cf435816c0864ffe06`
- `pack.json`: `55f2ae4593e40e30fe9aa48d0dab4988f186bc889cf225b3db2676b77e1d1ea3`
- `revocations.json`: `0fb96e65856b9f53bf32d10e07cadc164618c3c9f6909aca069fafedbfd0db03`

## Endpoint Control Proof

- `GET current.json`: 200.
- `GET /`: 404.
- `GET claims.json`: 404.
- `GET current.json?goal_text=private`: 404.
- `POST current.json`: 405.

Observed allowed-object headers included:

- `content-type: application/json; charset=utf-8`
- `x-source-atlas-public-reference: true`
- `x-source-atlas-gateway: production-stable-occupation-foundation`

## Validation Run

- Passed: `node --check tools/source-atlas/r2-public-gateway/src/worker.js`
- Passed: `python3 -m json.tool tools/source-atlas/r2-public-gateway/wrangler.jsonc >/dev/null`
- Passed: `python3 -m json.tool docs/qa/source-atlas/r2/source-atlas-public-r2-worker-gateway-owner-approval-train-34.json >/dev/null`
- Passed: `wrangler deploy --config tools/source-atlas/r2-public-gateway/wrangler.jsonc --dry-run`
- Passed: `wrangler deploy --config tools/source-atlas/r2-public-gateway/wrangler.jsonc`
- Passed: public HTTPS readback plus SHA-256 for current, LKG, manifest, pack, and revocations.
- Passed: blocked-route probes for root, non-allowlisted object, private query marker, and POST.
- Passed: live URLSession focused test.
  - `SourceAtlasPublicPackRemoteTransportTests/testLiveProductionWorkerGatewayFetchesPublishedPackWithURLSessionWhenEndpointIsProvided`
  - 1 passed, 0 warnings.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T03-38-21-727Z_pid24471_3881d6fb.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T03-38-21-727Z_pid24471_66063b31.xcresult`
- Passed: affected native app factory, registry loader, transport, and lifecycle service set.
  - 22 passed, 0 warnings.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T03-53-02-672Z_pid24471_ff283403.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T03-53-02-672Z_pid24471_a9cadefe.xcresult`
- Passed: `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests`
  - 145 passed.
- Passed: `python3 scripts/source-atlas-boundary-audit.py`
  - Source Atlas boundary audit: PASS (40 targets).
- Passed: `python3 scripts/source-atlas-no-private-graph-egress-audit.py`
  - Source Atlas no-private-graph egress audit: PASS.
- Passed: `python3 scripts/ambitions-green-standard-audit.py`
  - GREEN: no disallowed architecture-as-UI strings found in active primary UI source.
- Passed: `python3 scripts/ambitions-local-first-boundary-scan.py`
  - GREEN: local-first/account/R2/hosted-AI boundary checks passed in active authority files.
- Passed: `python3 -m json.tool docs/qa/source-atlas/native/source-atlas-live-worker-gateway-urlsession-train-34.json >/dev/null`
- Passed: `git diff --check`
- Passed: `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard`
  - Test Build Succeeded.
  - `FAILURE_CLASS=passed`
  - Summary: `.codex/xcode-summaries/green-standard/20260628T035744Z/extract/summary.json`

## Closeout

Status: Green for bounded Worker gateway live transport and native lifecycle refresh proof; Yellow overall Source Atlas.

Scope completed: bounded public Worker gateway, public HTTPS readback/hash proof, blocked route proof, native live URLSession test, app factory wiring, active refresh target artifact, and lifecycle-service live proof.

Files changed:

- `Native/Ambitions/App/AppContainerFactory.swift`
- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackRemoteTransportAdapters.swift`
- `Native/Ambitions/Resources/source-atlas-public-refresh-targets.json`
- `Native/AmbitionsTests/App/AppContainerFactoryTests.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackLifecycleRefreshServiceTests.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackRefreshTargetRegistryArtifactLoaderTests.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackRemoteTransportTests.swift`
- `docs/qa/source-atlas/native/source-atlas-live-worker-gateway-urlsession-train-34.json`
- `docs/qa/source-atlas/native/source-atlas-live-worker-gateway-urlsession-train-34.md`
- `docs/qa/source-atlas/r2/source-atlas-public-r2-worker-gateway-owner-approval-train-34.json`
- `docs/qa/source-atlas/r2/source-atlas-public-r2-worker-gateway-owner-approval-train-34.md`
- `tools/source-atlas/r2-public-gateway/src/worker.js`
- `tools/source-atlas/r2-public-gateway/wrangler.jsonc`

Product law preserved: yes. R2 remains public/reference/freshness infrastructure only. The Worker exposes only allowlisted public object keys. Native requests carry no private user context.

Source Atlas status ceiling: Green for bounded public Worker gateway and live native URLSession/lifecycle refresh proof. Overall Source Atlas remains Yellow.

R2 request privacy proof: live native requests used the public gateway base URL plus public Source Atlas object keys only.

No private graph egress proof: no user goals, captures, schedules, proof, receipts, account identifiers, device identifiers, private graph data, personalization, or final user paths were sent in requests, object keys, query strings, or test inputs.

License/terms proof: Train 34 owner approval is endpoint-exposure approval only. It is not outside legal approval and does not change source licenses or terms.

Restricted-source exclusion proof: the Worker exposes only the approved production stable `occupation_foundation` object keys, with no bucket listing and no arbitrary object access.

Provenance completeness proof: no new claims were produced. The downloaded production pack hash matched the existing R2-published pack SHA-256.

Freshness/revocation proof: live native path fetched current pointer, revocations, manifest, LKG manifest, and pack objects, then accepted the pack through the existing manifest/hash pipeline.

LKG/rollback proof: the live native object request sequence includes LKG. No R2 object contents were modified by this train.

Native offline/no-account proof: app factory remains usable without account. This train proves the active online public refresh target path; prior offline/cache tests remain in the affected set.

Production non-claims: not full Source Atlas Green, not Release Green, not Visual Green, not App Store readiness, not outside legal approval, not privacy/legal owner release signoff, not production custom-domain readiness, not universal goal coverage, not entitlement readiness, not a private user-data backend, not private life graph storage, and not a final user plan, schedule, or Step generator.

Final Architecture Tree inspected: yes.

Canonical owners touched: `App`, `Core/Persistence`, `Resources`, `AmbitionsTests`, `tools/source-atlas`, and `docs/qa/source-atlas`.

Old/non-canonical paths removed: none.

Compatibility shims left behind: none.

Yellow architecture debt: none introduced by this train.

Next repair train if debt remains: not applicable.

No equivalent folder/path interpretation used: confirmed.

Known risks: workers.dev proof is not custom-domain production endpoint proof; outside legal approval remains unproven; full release proof remains outside this train; overall Source Atlas remains Yellow.

Rollback plan: disable or delete the Worker gateway, revert native default endpoint/refresh target wiring, and keep the app on bundled/offline baseline or safe LKG. No bucket-wide r2.dev setting was enabled.
