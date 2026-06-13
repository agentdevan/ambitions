# R2 Connector Capability Audit

Status: Green for AMB-973 staging activation because Cloudflare connector supports live bucket/object write and list operations, and owner-updated staging `r2.dev` settings allowed public non-private canary HEAD/GET body verification with SHA-256 hash match.
Date: 2026-06-13 America/New_York
Connector: Cloudflare API MCP

## Capabilities Verified

Cloudflare documentation and OpenAPI spec were queried during AMB-973. The connector exposes:

- `GET /accounts/{account_id}/r2/buckets`
- `POST /accounts/{account_id}/r2/buckets`
- `GET /accounts/{account_id}/r2/buckets/{bucket_name}`
- `GET /accounts/{account_id}/r2/buckets/{bucket_name}/cors`
- `PUT /accounts/{account_id}/r2/buckets/{bucket_name}/cors`
- `GET /accounts/{account_id}/r2/buckets/{bucket_name}/domains/managed`
- `PUT /accounts/{account_id}/r2/buckets/{bucket_name}/domains/managed`
- `GET /accounts/{account_id}/r2/buckets/{bucket_name}/domains/custom`
- `GET /accounts/{account_id}/r2/buckets/{bucket_name}/lifecycle`
- `PUT /accounts/{account_id}/r2/buckets/{bucket_name}/lifecycle`
- `GET /accounts/{account_id}/r2/buckets/{bucket_name}/objects`
- `PUT /accounts/{account_id}/r2/buckets/{bucket_name}/objects/{object_key}`
- `GET /accounts/{account_id}/r2/buckets/{bucket_name}/objects/{object_key}`
- `DELETE /accounts/{account_id}/r2/buckets/{bucket_name}/objects/{object_key}`
- `POST /accounts/{account_id}/r2/temp-access-credentials`

AMB-973 did not call temporary credential creation and did not print, store, or request secrets.

## Operations Used

| Operation | Result |
|---|---|
| List buckets | Success |
| Get staging bucket | Success |
| Get CORS | Success for staging; one GET rule for local development |
| Get managed domain | Success for staging; managed `r2.dev` enabled |
| List custom domains | Success; none |
| Get lifecycle | Success; default multipart abort rule |
| Upload object | Success for 10 refreshed canaries |
| List objects | Success for 10 refreshed canaries |
| Public staging `r2.dev` HEAD | Success for all 10 refreshed canaries |
| Public staging `r2.dev` GET body | Success for all 10 refreshed canaries |
| SHA-256 body hash compare | Success for all 10 refreshed canaries |

## Historical Connector Limitation

The Cloudflare REST object GET endpoint returns raw object bodies, not the normal Cloudflare JSON envelope. The connector raises `Cloudflare API error: 200` on these successful raw responses. AMB-973 therefore records object upload response metadata, list response metadata, ETags, sizes, and content-addressed keys, but does not claim raw body re-download verification.

That limitation is now historical context only. It is not acceptable Green evidence after this repair. AMB-973 Green depends on the selected public staging `r2.dev` read model, which returned HEAD and GET body responses and allowed SHA-256 body-hash comparison without printing or persisting secrets.

## Non-Claims

This audit does not prove Wrangler CLI auth, S3-compatible SDK auth, presigned URL behavior, custom-domain read access, app runtime fetch, production promotion, or runtime consumption.
