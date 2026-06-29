# Source Atlas Public R2 Worker Gateway Education Readback - Train 42

Status: Source Green for bounded education Worker HTTPS readback / Yellow overall Source Atlas
Valid: true
Gateway URL: https://ambitions-source-atlas-public-gateway.devanwarner.workers.dev
Deployed version ID: c6d98458-d8fa-415c-949c-b3bf0a568026
Pack ID: source-atlas/v1/domain/education_credentialing/20260628T000000Z
Manifest SHA-256: 7443bc2846c6ba6700bffe4f2361a7d1c6eb0305cd7261aee9d797574627543b
Pack SHA-256: 95e7809997ba010db59cee5925bf9f713d85b70bf7e9e84eae961bd615919b3e

## HTTP Proof

| Request | Expected | Actual | SHA-256 |
|---|---:|---:|---|
| education_current | 200 | 200 | `ead323b660476ea2d5156cbde38705e41db7183be6628c3ca8e17deaa175b448` |
| education_lkg | 200 | 200 | `89f044c7511cfc709a0af553f50ab473342d0e9b6ff267c70dfe68ecb72d684f` |
| education_revocations | 200 | 200 | `373b2b3011cbd6806e6dae4a206a4641dd37a163d9ffb074df0cfdcd4fea42ae` |
| education_manifest | 200 | 200 | `7443bc2846c6ba6700bffe4f2361a7d1c6eb0305cd7261aee9d797574627543b` |
| education_pack | 200 | 200 | `95e7809997ba010db59cee5925bf9f713d85b70bf7e9e84eae961bd615919b3e` |
| occupation_current | 200 | 200 | `33eb11402140afb9e0cd44baa0f053021d2e8b04a4e8eca0b81b4b4e0ba2f498` |
| civic_current | 200 | 200 | `3c5d573292cc8b306a3563487ab095efba2f64c05a65ba6bfd04756a56c13b46` |
| blocked_education_claims | 404 | 404 | `e3ebaa16dd9d9b9fc107c42183fb6cf9d22927e1af03dbbdfa0ccc38e4e4ac31` |
| blocked_private_query | 404 | 404 | `e3ebaa16dd9d9b9fc107c42183fb6cf9d22927e1af03dbbdfa0ccc38e4e4ac31` |
| blocked_post | 405 | 405 | `371b26886bee5e559d5016b17b1479cb7a9154865da5a0f11563580ea99ff033` |

## Hash Checks

- currentPointerSHA256MatchesPublisherReport: true
- currentManifestSHA256MatchesBody: true
- manifestSHA256MatchesBody: true
- currentPackSHA256MatchesBody: true
- manifestPackSHA256MatchesCurrentPointer: true
- packIDMatchesCurrentPointer: true
- packIDMatchesManifest: true
- lkgPackIDMatchesCurrentPointer: true
- revocationsManifestKeyIsEducation: true
- revocationsLKGKeyIsEducation: true
- revocationsHaveNoCurrentRevocations: true

## Header Checks

- allowedResponsesCarryPublicReferenceHeader: true
- allowedResponsesCarryGatewayHeader: true
- blockedRoutesDoNotExposePublicReferenceHeader: true

## Privacy Boundary

- Request shape is fixed public object-key GET/HEAD only.
- Private query marker proof returned 404.
- Non-allowlisted education pack slice returned 404.
- POST returned 405.

## Non-Claims

- not outside legal approval
- not universal goal coverage
- not full Source Atlas Green
- not broad Runtime Green
- not Release Green
- not App Store readiness
- not account or entitlement readiness
- not a Source Atlas product center or pack browser
- not a final user plan, schedule, Step list, or personalized path generator
