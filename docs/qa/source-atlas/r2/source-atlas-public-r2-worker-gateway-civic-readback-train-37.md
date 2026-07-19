# Source Atlas Public Worker Gateway Civic HTTPS Readback Train 37

Status: green_for_bounded_public_civic_gateway_https_readback_yellow_overall_source_atlas
Source Atlas status ceiling: Green for bounded public civic Worker HTTPS readback only. Overall Source Atlas remains Yellow.

Allowed object readbacks:
- `civic_current`: status 200, sha256 `3c5d573292cc8b306a3563487ab095efba2f64c05a65ba6bfd04756a56c13b46`
- `civic_lkg`: status 200, sha256 `e9acd783151de03b2abdb47bb19a2e5b8270fca699d87c9349e04995c94ac9f4`
- `civic_revocations`: status 200, sha256 `c89d21078cd0d6f7c7ed6a5d11631500bf304e0562bbd2e986df0457a93f52dc`
- `civic_manifest`: status 200, sha256 `9f0910dbee38eb5a36e37eb74de2bc04ce01ff065ef59307d61e8820d0eaaa25`
- `civic_pack`: status 200, sha256 `bd6cb0923a4d438ad0a146c83908abf4c9be6301a51af92ccc32e037848115a6`
- `occupation_current`: status 200, sha256 `33eb11402140afb9e0cd44baa0f053021d2e8b04a4e8eca0b81b4b4e0ba2f498`

Blocked route proof:
- non-allowlisted claims slice: status 404
- allowlisted object with private query marker: status 404
- POST allowlisted civic object: status 405

Pack consistency:
- Pack IDs consistent: True
- Pack hash consistent: True
- Current pointer hash consistent: True

Non-claims:
- Not full Source Atlas Green.
- Not universal coverage.
- Not broad Runtime Green.
- Not Release Green.
- Not Visual Green.
- Not App Store readiness.
- Not outside legal approval.
- Not entitlement readiness.
- Not a private user-data backend.
- Not private life graph storage.
- Not a final user plan, schedule, or Step generator.
