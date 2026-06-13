# R2 Canary Object Receipt

Status: Yellow for AMB-973 / PLOS-M05-R2 because canary upload/list/ETag evidence is live, while raw object body GET/hash re-download is limited by the connector.
Date: 2026-06-13 America/New_York
Bucket: `ambitions-source-atlas-staging`
Release ring: `staging`

## Canary Payload Contract

Every canary object uses the same non-private schema:

```json
{
  "artifact_id": "source-atlas-staging-canary",
  "artifact_role": "<role>",
  "schema_version": "schema-v1",
  "release_ring": "staging",
  "generated_at_utc": "2026-06-13T05:35:00Z",
  "source_binding": "synthetic-public-canary-only",
  "contains_private_user_data": false,
  "contains_secret_material": false,
  "runtime_eligible": false,
  "runtime_consumption_claimed": false,
  "production_readiness_claimed": false,
  "owner_issue": "AMB-973",
  "note": "Synthetic non-private Source Atlas staging canary for R2 prefix verification only."
}
```

No canary contains private user data, realistic private goal text, secrets, account ids, user identifiers, device identifiers, diagnostics, support bundles, source-needed private text, or runtime write credentials.

## Live Canary Objects

| Role | Size | ETag | SHA-256 | Key |
|---|---:|---|---|---|
| current-manifest-canary | 567 | `8821ebe41914cbe45990c2033077d2a9` | `f49ae2185af703a88ace02681286c5152141d69c19a7abce6cff587b618809ca` | `staging/manifests/current/global/schema-v1/source-atlas-staging-canary/2026-06-13/f49ae2185af703a88ace02681286c5152141d69c19a7abce6cff587b618809ca/source-atlas-staging-canary.2026-06-13.manifest.json` |
| source-pack-canary | 562 | `2d3131bf61252d5d3f7d4f6e84cd04b2` | `1e4f0ea3ff729144d8690c4bfcd12fc75a78759676bb5a04d9bf5ffdef226e6f` | `staging/packs/source/global/schema-v1/source-atlas-staging-canary/2026-06-13/1e4f0ea3ff729144d8690c4bfcd12fc75a78759676bb5a04d9bf5ffdef226e6f/source-atlas-staging-canary.2026-06-13.pack.json` |
| seed-pack-canary | 560 | `01795391ca86d90f82d8b51959721bcc` | `c039c23f97d98c5ad45909b7608c46bd8e83f23a5fcf7f9a1e3fb3305806e7b3` | `staging/packs/seeds/global/schema-v1/source-atlas-staging-canary/2026-06-13/c039c23f97d98c5ad45909b7608c46bd8e83f23a5fcf7f9a1e3fb3305806e7b3/source-atlas-staging-canary.2026-06-13.seed.json` |
| freshness-list-canary | 565 | `98fc0350d8e873b03513d88a94351b11` | `c8353fcba0e67a71e8309c62226c490025223532733dd28b0cb8c982113c5803` | `staging/freshness/global/schema-v1/source-atlas-staging-canary/2026-06-13/c8353fcba0e67a71e8309c62226c490025223532733dd28b0cb8c982113c5803/source-atlas-staging-canary.2026-06-13.freshness.json` |
| revocation-list-canary | 566 | `bce8f6c7105dd3dcd557025e066bd622` | `a06668e5df68ef8b1880bd79177af39c6ae9d0b9f83c0d6fc68d32fb6eadf342` | `staging/revocations/global/schema-v1/source-atlas-staging-canary/2026-06-13/a06668e5df68ef8b1880bd79177af39c6ae9d0b9f83c0d6fc68d32fb6eadf342/source-atlas-staging-canary.2026-06-13.revocation.json` |
| compatibility-table-canary | 570 | `0c77b6066495ca2cbd6374a9b1079d4e` | `45c6b9da7b0f8cd5a1e780f265342a41e08a4c6cd8688cf44ba8fdb56a783a56` | `staging/compatibility/global/schema-v1/source-atlas-staging-canary/2026-06-13/45c6b9da7b0f8cd5a1e780f265342a41e08a4c6cd8688cf44ba8fdb56a783a56/source-atlas-staging-canary.2026-06-13.compatibility.json` |
| validation-report-canary | 568 | `b5ab1bfeb2e61ffaf704b7cc4247071e` | `13b81636c47c6fe51987664bab95a37797a50e3cfcbad39510a2b4cc0cf2270a` | `staging/validation-reports/global/schema-v1/source-atlas-staging-canary/2026-06-13/13b81636c47c6fe51987664bab95a37797a50e3cfcbad39510a2b4cc0cf2270a/source-atlas-staging-canary.2026-06-13.validation.json` |
| release-receipt-canary | 566 | `b248d0e8c60b0f365db0146624d768e8` | `9afc4b2220c148332653f9788c8030808abc13d3b49cea98aeb81761414b41ff` | `staging/release-receipts/global/schema-v1/source-atlas-staging-canary/2026-06-13/9afc4b2220c148332653f9788c8030808abc13d3b49cea98aeb81761414b41ff/source-atlas-staging-canary.2026-06-13.receipt.json` |
| rollback-manifest-canary | 568 | `8bca1760e34a17050b9daf39cc71576e` | `66e32c7ba98ac4a14604eac6bed83821f0e5ef5e08435d84427a810fa5c6b680` | `staging/rollback-manifests/global/schema-v1/source-atlas-staging-canary/2026-06-13/66e32c7ba98ac4a14604eac6bed83821f0e5ef5e08435d84427a810fa5c6b680/source-atlas-staging-canary.2026-06-13.rollback.json` |
| generic-canary-object | 565 | `ffe0f4cf724666b2d8f261ebdc4e9eb6` | `4c0aec0ba1a0436026a6a6444678115475969fa0332bba18b52dfbd2af9d0ee7` | `staging/canary-objects/global/schema-v1/source-atlas-staging-canary/2026-06-13/4c0aec0ba1a0436026a6a6444678115475969fa0332bba18b52dfbd2af9d0ee7/source-atlas-staging-canary.2026-06-13.canary.json` |

## Verification

- PUT upload: success for all 10 objects.
- LIST `staging/`: success, all 10 objects listed with size and ETag.
- Object body GET: Yellow connector limitation; raw body response throws `Cloudflare API error: 200`.

These canaries are staging proof only. They do not make any pack runtime-eligible.
