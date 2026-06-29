# Source Atlas Public R2 Worker Gateway Owner Approval

Status: Approved for bounded Worker gateway live transport proof.

Linear: AMB-1520

Created: 2026-06-28T03:35:40Z

## Approval Scope

This approval covers a Cloudflare Worker gateway for Source Atlas public/reference transport proof only.

Approved:

- Deploy `ambitions-source-atlas-public-gateway`.
- Bind it to R2 bucket `ambitions-source-atlas-prod`.
- Expose only explicit allowlisted production stable `occupation_foundation` object keys.
- Use the endpoint for live native URLSession proof.
- Preserve a no-private-context request shape.

Approved object keys:

- `source-atlas/v1/production/stable/occupation_foundation/current.json`
- `source-atlas/v1/production/stable/occupation_foundation/lkg.json`
- `source-atlas/v1/production/stable/occupation_foundation/revocations.json`
- `source-atlas/v1/production/stable/occupation_foundation/20260628T000000Z/manifest.json`
- `source-atlas/v1/production/stable/occupation_foundation/20260628T000000Z/pack.json`

## Explicit Blocks

- Do not enable bucket-wide r2.dev public access in this train.
- Do not expose a bucket listing route.
- Do not expose arbitrary `source-atlas/*` object keys.
- Do not expose private user context, goals, captures, schedules, proof, receipts, account identifiers, device identifiers, or private graph data.
- Do not claim production custom-domain readiness from workers.dev proof.

## Reasoning

`wrangler r2 bucket info ambitions-source-atlas-prod` reported 68 objects. Current generated proof artifacts identify 41 unique object keys. Bucket-wide r2.dev would expose unknown object keys if guessed. The Worker gateway allowlist exposes only the public/reference object keys needed for live native transport proof.

Cloudflare R2 public bucket docs describe r2.dev as public development access. A Worker gateway with an R2 binding allows narrower object-key control while preserving public HTTPS fetch proof.

## Non-Claims

- Not outside legal approval.
- Not privacy/legal owner release signoff.
- Not Release Green.
- Not App Store readiness.
- Not Visual Green.
- Not universal goal coverage.
- Not entitlement readiness.
- Not a private user-data backend.
- Not private life graph storage.
- Not a final user plan, schedule, or Step generator.

## Rollback

- Disable or delete the Cloudflare Worker gateway if public endpoint exposure must be revoked.
- No bucket-wide r2.dev setting should be enabled by this train.
- R2 objects remain managed by existing revocation/LKG/rollback proof.
