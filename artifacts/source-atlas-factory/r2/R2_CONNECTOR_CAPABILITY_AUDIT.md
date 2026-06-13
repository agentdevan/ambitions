# R2 Connector Capability Audit

Status: Yellow for AMB-973 because Cloudflare connector supports live bucket/object write and list operations, but raw object body GET cannot be consumed by this connector.
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
| Get CORS | Yellow; no CORS policy exists |
| Get managed domain | Success; disabled |
| List custom domains | Success; none |
| Get lifecycle | Success; default multipart abort rule |
| Upload object | Success for 10 canaries |
| List objects | Success for 10 canaries |
| Get object body | Yellow connector limitation: `Cloudflare API error: 200` |

## Connector Limitation

The Cloudflare REST object GET endpoint returns raw object bodies, not the normal Cloudflare JSON envelope. The connector raises `Cloudflare API error: 200` on these successful raw responses. AMB-973 therefore records object upload response metadata, list response metadata, ETags, sizes, and content-addressed keys, but does not claim raw body re-download verification.

## Non-Claims

This audit does not prove Wrangler CLI auth, S3-compatible SDK auth, presigned URL behavior, public `r2.dev` read access, custom-domain read access, app runtime fetch, production promotion, or runtime consumption.
