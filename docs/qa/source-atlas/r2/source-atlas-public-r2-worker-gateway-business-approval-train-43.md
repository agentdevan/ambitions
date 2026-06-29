# Source Atlas Public R2 Worker Gateway Business Approval Train 43

Status: approved for bounded public business gateway allowlist.

Allowed keys:
- `source-atlas/v1/production/stable/business_entrepreneurship/current.json`
- `source-atlas/v1/production/stable/business_entrepreneurship/lkg.json`
- `source-atlas/v1/production/stable/business_entrepreneurship/revocations.json`
- `source-atlas/v1/production/stable/business_entrepreneurship/20260628T000000Z/manifest.json`
- `source-atlas/v1/production/stable/business_entrepreneurship/20260628T000000Z/pack.json`

Controls:
- GET and HEAD only
- no query string or URL fragment
- exact object-key allowlist
- private marker rejection
- public/reference response headers
- no claims, sources, or auxiliary slices exposed through Worker allowlist

Non-claims:
- not outside legal approval
- not release readiness
- not App Store readiness
- not broad runtime Green
- not universal coverage
- not private graph storage
- not final user plan, schedule, or Step generation
- not a public browsing surface
- not legal advice
- not tax advice
