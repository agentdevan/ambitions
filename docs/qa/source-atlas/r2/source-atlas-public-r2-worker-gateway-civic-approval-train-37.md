# Source Atlas Public R2 Worker Gateway Civic Approval Train 37

Status: approved for bounded public civic gateway live transport proof

Approval scope:
- Update the existing `ambitions-source-atlas-public-gateway` Worker.
- Keep the Worker bound to R2 bucket `ambitions-source-atlas-prod`.
- Expose only explicit allowlisted production stable `occupation_foundation` and `public_civic_requirements` object keys.
- Use the endpoint for HTTPS readback proof for `public_civic_requirements`.
- Preserve no-private-context request shape.

Approved civic object keys:
- `source-atlas/v1/production/stable/public_civic_requirements/current.json`
- `source-atlas/v1/production/stable/public_civic_requirements/lkg.json`
- `source-atlas/v1/production/stable/public_civic_requirements/revocations.json`
- `source-atlas/v1/production/stable/public_civic_requirements/20260628T041500Z/manifest.json`
- `source-atlas/v1/production/stable/public_civic_requirements/20260628T041500Z/pack.json`

Blocked exposure modes:
- No bucket-wide r2.dev public access.
- No bucket listing route.
- No arbitrary `source-atlas/*` object keys.
- No pack slices beyond current pointer, LKG pointer, revocations, manifest, and pack objects for this train.
- No private user context, goals, captures, schedules, proof, receipts, account identifiers, device identifiers, or private graph data.

Non-claims:
- Not outside legal approval
- Not privacy/legal owner release signoff
- Not Release Green
- Not App Store readiness
- Not Visual Green
- Not universal goal coverage
- Not entitlement readiness
- Not a private user-data backend
- Not private life graph storage
- Not a final user plan, schedule, or Step generator
