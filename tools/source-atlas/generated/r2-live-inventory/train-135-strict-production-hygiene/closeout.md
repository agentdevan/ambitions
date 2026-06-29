# Source Atlas Live R2 Inventory

Status: Red for live R2 inventory reconciliation
Bucket: `ambitions-source-atlas-prod`
Prefix: `source-atlas/`

Counts:
- Live objects: 264
- Live bytes: 1544481
- Expected current objects: 196
- Expected current bytes: 938632
- Expected present: 196
- Expected missing: 0
- Unexpected live objects: 68
- Size mismatches: 0
- Checksum reads: 196
- Checksum mismatches: 0
- Privacy issues: 0
- Hygiene violations: 68
- Hygiene Red objects: 68
- Hygiene Yellow objects: 0
- Approved non-current retained objects: 0

Domain coverage:
| Domain | Expected | Present | Missing | Unexpected under domain | Expected bytes | Live expected bytes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| business_entrepreneurship | 14 | 14 | 0 | 0 | 48584 | 50320 |
| creative_project_reference | 14 | 14 | 0 | 0 | 58168 | 59908 |
| education_credentialing | 14 | 14 | 0 | 0 | 90785 | 92513 |
| finance_public_reference | 14 | 14 | 0 | 0 | 56650 | 58382 |
| health_wellness_reference | 14 | 14 | 0 | 0 | 49302 | 51038 |
| health_wellness_reference_ca_statistics | 14 | 14 | 0 | 0 | 38603 | 40395 |
| hobbies_recreation | 14 | 14 | 0 | 0 | 48097 | 49805 |
| home_life_admin | 14 | 14 | 0 | 0 | 65631 | 67327 |
| occupation_foundation | 14 | 14 | 0 | 0 | 214844 | 216564 |
| personal_growth | 14 | 14 | 0 | 0 | 51449 | 53145 |
| public_civic_requirements | 14 | 14 | 0 | 0 | 36114 | 37850 |
| relationships_family | 14 | 14 | 0 | 0 | 76655 | 78371 |
| travel_relocation | 14 | 14 | 0 | 0 | 53517 | 55221 |
| volunteering_public_reference | 14 | 14 | 0 | 0 | 50233 | 51985 |

Boundaries:
- Read-only inventory and optional readback only.
- No writes, deletes, current-pointer changes, harvests, or production promotions.
- Secret values are not printed or stored in the report.
- R2 remains public/reference/freshness infrastructure only.

Hygiene semantics:
- Current configured production objects are the only Green production objects.
- Non-current production, staging, validation, and legacy stable objects in the production bucket are Red unless an explicit retention approval matches them.
- Retention approvals must be prefix-bound, reasoned, and dated in the hygiene policy.

Hygiene findings:
| Classification | Severity | Count | Bytes |
| --- | --- | ---: | ---: |
| legacy_stable_noncurrent | Red | 26 | 134576 |
| staging_candidate_in_production_bucket | Red | 14 | 70005 |
| validation_in_production_bucket | Red | 28 | 377076 |

Non-claims:
- not a private user-data backend
- not private life graph storage
- not an official legal, medical, financial, or admissions decision
- not runtime recommendation proof by itself
- not R2 release readiness
- not accessibility, privacy, or legal approval
- not a private user-data backend
- not private life graph storage
- not full Source Atlas Green
- not literal universal coverage
- not a production writer
- not a deletion or rollback command
