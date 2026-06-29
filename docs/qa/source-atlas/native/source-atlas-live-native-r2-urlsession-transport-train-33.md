# Source Atlas Train 33 Live Native R2 URLSession Transport Proof

Status: Yellow, blocked. Public R2 HTTPS endpoint is not enabled.

Linear: AMB-1519

Created: 2026-06-28T03:28:06Z

## Scope Completed

- Inspected `SourceAtlasURLSessionPublicPackRemoteTransport`.
- Inspected the native public refresh target registry artifact.
- Verified the production R2 bucket exists and contains public/reference objects.
- Verified the production bucket has no custom domain.
- Verified r2.dev public access is disabled.
- Did not fabricate an endpoint or enable public bucket access.

## Read-Only Cloudflare Evidence

- `wrangler r2 bucket domain list ambitions-source-atlas-prod`
  - Passed.
  - Result: no custom domains connected.
- `wrangler r2 bucket info ambitions-source-atlas-prod`
  - Passed.
  - Result: bucket exists; `object_count` 68; `bucket_size` 734 kB.
- `wrangler r2 bucket dev-url get ambitions-source-atlas-prod`
  - Passed.
  - Result: public access via r2.dev is disabled.

## Validation Run

- Passed: `python3 -m json.tool docs/qa/source-atlas/native/source-atlas-live-native-r2-urlsession-transport-train-33.json >/dev/null`
- Passed: `python3 scripts/source-atlas-boundary-audit.py`
  - Source Atlas boundary audit: PASS (40 targets)
- Passed: `python3 scripts/source-atlas-no-private-graph-egress-audit.py`
  - Source Atlas no-private-graph egress audit: PASS
- Passed: `python3 scripts/ambitions-local-first-boundary-scan.py`
  - GREEN: local-first/account/R2/hosted-AI boundary checks passed in active authority files
- Passed: `git diff --check`

## Blocker

Live native URLSession proof requires an approved public HTTPS base URL. The production bucket currently has no custom domain and r2.dev public access is disabled.

Required to unblock:

- Choose custom domain or r2.dev policy for public/reference Source Atlas packs.
- Record owner/security/legal approval artifact for public HTTPS exposure.
- Enable/configure the approved endpoint in Cloudflare.
- Add a public endpoint entry to native refresh target configuration without private context.
- Run live native URLSession fetch against current pointer, manifest, revocations, LKG, and pack hash verification.

## Closeout

Status: Yellow, blocked for live native URLSession.

Scope completed: read-only native transport/config inspection plus Cloudflare endpoint status checks.

Files changed:

- `docs/qa/source-atlas/native/source-atlas-live-native-r2-urlsession-transport-train-33.json`
- `docs/qa/source-atlas/native/source-atlas-live-native-r2-urlsession-transport-train-33.md`

Product law preserved: yes. No private context was sent to R2. No endpoint exposure policy was changed.

Source Atlas status ceiling: Yellow for live native transport. Existing Train 29 R2 upload/readback proof remains valid; native URLSession against public HTTPS R2 remains unproven.

R2 request privacy proof: no native URLSession request was made because no approved public endpoint exists.

No private graph egress proof: read-only checks used only bucket/object infrastructure metadata and no user goals, captures, schedules, proof, receipts, private graph, account identifiers, or personalization context.

License/terms proof: no source, license, or pack output changed. Public endpoint exposure still requires explicit approval before release-facing Green.

Restricted-source exclusion proof: no source registry or pack output changed.

Provenance completeness proof: no claims were created or modified.

Freshness/revocation proof: no live native freshness/revocation fetch was run.

LKG/rollback proof: no R2 pointer or LKG object changed.

Native offline/no-account proof: no app behavior changed; Train 30 remains the current proof.

Production non-claims: not live native URLSession Green, not R2 release readiness, not endpoint approval, not entitlement readiness, not full Source Atlas Green, not Visual Green, not Release Green, not App Store readiness, not outside legal approval, and not universal coverage.

Rollback plan: no production R2 or native runtime state changed. Remove these blocker docs if a later live endpoint proof supersedes them.
