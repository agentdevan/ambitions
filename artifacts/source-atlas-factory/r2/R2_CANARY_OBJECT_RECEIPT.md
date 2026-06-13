# R2 Canary Object Receipt

Status: Green for AMB-973 / PLOS-M05-R2 because refreshed staging canaries passed upload, list, HEAD, GET body read, ETag, size, and SHA-256 body-hash verification.
Date: 2026-06-13 America/New_York
Bucket: `ambitions-source-atlas-staging`
Release ring: `staging`
Read model: public staging `r2.dev` read for non-private canary objects only
Proof run: `amb-973-r2-green-repair-20260613T183742Z`

## Canary Payload Contract

Every refreshed canary object uses the same non-private schema:

```json
{
  "artifact_id": "source-atlas-staging-canary",
  "artifact_role": "<role>",
  "canary_id": "<canary>",
  "data_classification": "generic-public-staging-canary",
  "generated_at_utc": "2026-06-13T18:37:42Z",
  "issue_id": "AMB-973",
  "plos_label": "PLOS-M05-R2",
  "proof_run_id": "amb-973-r2-green-repair-20260613T183742Z",
  "release_ring": "staging",
  "schema_version": 1,
  "source_scope": "synthetic non-private Source Atlas staging verification",
  "privacy_boundary": {
    "contains_private_user_data": false,
    "contains_realistic_private_goal_text": false,
    "contains_runtime_write_credentials": false,
    "contains_secret_material": false
  },
  "verification_contract": {
    "expected_read_model": "public staging r2.dev read for non-private canary only",
    "production_readiness_claim": false,
    "runtime_consumption_claim": false
  }
}
```

No canary contains private user data, realistic private goal text, secrets, account ids, user identifiers, device identifiers, diagnostics, support bundles, source-needed private text, or runtime write credentials.

## Refreshed Canary Objects

| Role | Size | ETag | SHA-256 | Key |
|---|---:|---|---|---|
| manifest | 1039 | `430a2227f51bd85b52890d17df06bf6e` | `e566417aea3de6acbe5fa3b19f8c32f67646db4f6dfab3c900b4dae7f0412ee3` | `staging/manifests/current/global/schema-v1/source-atlas-staging-canary/2026-06-13/e566417aea3de6acbe5fa3b19f8c32f67646db4f6dfab3c900b4dae7f0412ee3/source-atlas-staging-canary.2026-06-13.manifest.json` |
| source-pack | 1037 | `7d04ce2381dd133064db9bdff358b8b7` | `67e0b286b57c0738c54320d0515dfc290832064fa943c60f75da59bfd12811f4` | `staging/packs/source/global/schema-v1/source-atlas-staging-canary/2026-06-13/67e0b286b57c0738c54320d0515dfc290832064fa943c60f75da59bfd12811f4/source-atlas-staging-canary.2026-06-13.pack.json` |
| seed-pack | 1033 | `e18038cc91054eeb2a242680f2d8f224` | `0445812decf276407d124714610c1b2ee9c1dbe519028af95981c841bd92b94c` | `staging/packs/seeds/global/schema-v1/source-atlas-staging-canary/2026-06-13/0445812decf276407d124714610c1b2ee9c1dbe519028af95981c841bd92b94c/source-atlas-staging-canary.2026-06-13.seed.json` |
| freshness-list | 1043 | `7db51314b14040d81f870e5fb6237a59` | `ac32bf7dd27913ac9d36346e1a738fa3766cf70f3b4dfcf7c21064d7ef3884a6` | `staging/freshness/global/schema-v1/source-atlas-staging-canary/2026-06-13/ac32bf7dd27913ac9d36346e1a738fa3766cf70f3b4dfcf7c21064d7ef3884a6/source-atlas-staging-canary.2026-06-13.freshness.json` |
| revocation-list | 1045 | `fa83b22e9e6d1d4414d73565b87495a9` | `6520b9716fe28a95a2ca5b15e3040cae45c1535debaaf9caacbe318683cd2ec0` | `staging/revocations/global/schema-v1/source-atlas-staging-canary/2026-06-13/6520b9716fe28a95a2ca5b15e3040cae45c1535debaaf9caacbe318683cd2ec0/source-atlas-staging-canary.2026-06-13.revocation.json` |
| compatibility-table | 1053 | `0fb4c3267a28a3b7bc9069208021f7e2` | `5ca3b2db43fb3435d946f02615cbf4a7a9e7df30067bc03d5accadb02243191c` | `staging/compatibility/global/schema-v1/source-atlas-staging-canary/2026-06-13/5ca3b2db43fb3435d946f02615cbf4a7a9e7df30067bc03d5accadb02243191c/source-atlas-staging-canary.2026-06-13.compatibility.json` |
| validation-report | 1049 | `5c1c8ffe3b0b13765bf0073639a7176c` | `7ee30004aa64bb55ba7de485c88faf057ccaf9b894e6e4af443e5fe8c207c107` | `staging/validation-reports/global/schema-v1/source-atlas-staging-canary/2026-06-13/7ee30004aa64bb55ba7de485c88faf057ccaf9b894e6e4af443e5fe8c207c107/source-atlas-staging-canary.2026-06-13.validation.json` |
| release-receipt | 1045 | `0c48cb35ff18ef589c4f4df75db3347e` | `bc452a01b7f8940d30c3e2bc8fd998de2dbe0c01aeb2ec68047dccb527a69347` | `staging/release-receipts/global/schema-v1/source-atlas-staging-canary/2026-06-13/bc452a01b7f8940d30c3e2bc8fd998de2dbe0c01aeb2ec68047dccb527a69347/source-atlas-staging-canary.2026-06-13.receipt.json` |
| rollback-manifest | 1049 | `bbb10c2e83a89bc43129477772bcef1a` | `e789caec79dc4d547e3d0c17a460df53966a47735cb23e2b1e27454c45fd676b` | `staging/rollback-manifests/global/schema-v1/source-atlas-staging-canary/2026-06-13/e789caec79dc4d547e3d0c17a460df53966a47735cb23e2b1e27454c45fd676b/source-atlas-staging-canary.2026-06-13.rollback.json` |
| generic-canary | 1043 | `8deb7c7dd494dbcf632f81944cc65f85` | `bf6dc4d48f28917838eefdb2b6de8b7b7b2a57fdbaade70421cde71ad721b7b2` | `staging/canary-objects/global/schema-v1/source-atlas-staging-canary/2026-06-13/bf6dc4d48f28917838eefdb2b6de8b7b7b2a57fdbaade70421cde71ad721b7b2/source-atlas-staging-canary.2026-06-13.canary.json` |

## Verification

- PUT upload: success for all 10 refreshed objects.
- LIST `staging/`: success; all 10 refreshed objects listed with size and ETag.
- Public staging `r2.dev` HEAD: success for all 10 refreshed objects.
- Public staging `r2.dev` GET body read: success for all 10 refreshed objects.
- SHA-256 body hash: every downloaded body matched the recorded SHA-256.
- Size check: every downloaded body size matched `Content-Length` and the listed size.
- ETag check: every public HEAD ETag matched the listed ETag.
- Content type: every public HEAD response returned `application/json`.

These canaries are staging proof only. They do not make any pack runtime-eligible.
