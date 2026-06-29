# Source Atlas Public R2 Worker Gateway Business Readback Train 43

Status: green_for_bounded_business_gateway_https_readback_yellow_overall_source_atlas
Gateway: `https://ambitions-source-atlas-public-gateway.devanwarner.workers.dev`
Worker version: `4bb3453e-4df4-4c02-ba65-1401faa807d3`

Allowed readback:
- business_current: 200 sha256=619d5fb25138130f43985bbf18cfb2f7c3cb073aa962265fb9fc65fb4b7e9047
- business_lkg: 200 sha256=5e29adade31c1c83454640af3ccc6b068b663aa906f95f92746a91fd0193b431
- business_revocations: 200 sha256=bdb2d5daae988b2ac8dc66fd514f56c44c543aa0a2c26706c3da6aed49749fec
- business_manifest: 200 sha256=1b68d185137aad5fa89a23f9fcb94d85b2c9dcbe3975d445157a47eeda23f9fb
- business_pack: 200 sha256=04d9eaf6f96b1271982a356664a570c74ed946e3145be96bcf636e7f1e561af6

Blocked probes:
- blocked_business_claims: 404
- blocked_private_query: 404
- blocked_post: 405

Proof:
- Current pointer, manifest, and pack hashes match publisher/local artifacts.
- Non-allowlisted `claims.json` is blocked.
- Private query marker is blocked.
- POST is blocked.
- Existing occupation, civic, and education current endpoints still return 200.

Non-claims:
- not outside legal approval
- not universal goal coverage
- not full Source Atlas Green
- not broad Runtime Green
- not Release Green
- not App Store readiness
- not legal advice
- not tax advice
