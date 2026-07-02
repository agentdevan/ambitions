# Source Atlas Launch-Floor Governance Renewal LFF-M06

Status: Source Green for launch-floor governance renewal tooling
Overall readiness: governance_renewal_ready
Source Atlas status ceiling: Yellow overall Source Atlas; governance renewal only, external release gates remain blocked until real proof exists

## Current Proved Capability

- Launch source lanes with renewal coverage: 15
- Accepted launch domains covered by governed source lanes: 500
- Accepted launch subdomains covered by governed source lanes: 5000
- API policies with renewal metadata: 11 / 11
- Legal entries with renewal metadata: 27 / 27
- Source lanes with renewal metadata: 34 / 34
- Expired source/API/legal postures: 0
- Unknown or blocking launch postures: 0
- Outside approval claims without artifacts: 0

## Launch Source Lane Coverage

| Source lane | Domains | Subdomains | Source status | API status | Legal status | Approval posture |
|---|---:|---:|---|---|---|---|
| bls.public.data.api | 50 | 500 | reviewed | reviewed | not_claimed | source=reviewed; legalOutside=not_claimed; api=owner_technical_reviewed_no_outside_approval_claim |
| cfpb.adult_financial_education | 50 | 500 | reviewed | reviewed | not_claimed | source=reviewed; legalOutside=not_claimed; api=owner_technical_reviewed_no_outside_approval_claim |
| college-scorecard.api | 50 | 500 | reviewed | reviewed | not_claimed | source=reviewed; legalOutside=not_claimed; api=reviewed_low_volume_high_volume_requires_separate_approval; high_volume_review_required |
| creative-commons.licenses | 80 | 800 | reviewed | reviewed | not_claimed | source=reviewed; legalOutside=not_claimed; api=owner_technical_reviewed_no_outside_approval_claim |
| data.gov.catalog | 460 | 4600 | candidate_only | reviewed | not_claimed | source=candidate_only; legalOutside=not_claimed; api=owner_technical_reviewed_no_outside_approval_claim; outside_legal_required_before_release_claim |
| irs.when_to_file | 50 | 500 | reviewed | reviewed | not_claimed | source=reviewed; legalOutside=not_claimed; api=owner_technical_reviewed_no_outside_approval_claim |
| loc.primary_sources | 300 | 3000 | reviewed | reviewed | not_claimed | source=reviewed; legalOutside=not_claimed; api=owner_technical_reviewed_no_outside_approval_claim |
| nara.constitution.presidency | 460 | 4600 | reviewed | reviewed | not_claimed | source=reviewed; legalOutside=not_claimed; api=owner_technical_reviewed_no_outside_approval_claim |
| nih.medlineplus.wellness | 300 | 3000 | reviewed | reviewed | not_claimed | source=reviewed; legalOutside=not_claimed; api=owner_technical_reviewed_no_outside_approval_claim |
| openalex.dataset | 50 | 500 | reviewed | reviewed | not_claimed | source=reviewed; legalOutside=not_claimed; api=reviewed_low_volume_high_volume_requires_separate_approval; high_volume_review_required |
| openalex.works | 50 | 500 | reviewed | reviewed | not_claimed | source=reviewed; legalOutside=not_claimed; api=reviewed_low_volume_high_volume_requires_separate_approval; high_volume_review_required |
| sba.business_guide.start_business | 460 | 4600 | reviewed | reviewed | not_claimed | source=reviewed; legalOutside=not_claimed; api=owner_technical_reviewed_no_outside_approval_claim |
| usa.gov.benefits | 460 | 4600 | reviewed | reviewed | not_claimed | source=reviewed; legalOutside=not_claimed; api=owner_technical_reviewed_no_outside_approval_claim |
| w3c.web-standards | 80 | 800 | reviewed | reviewed | not_claimed | source=reviewed; legalOutside=not_claimed; api=owner_technical_reviewed_no_outside_approval_claim |
| westpoint.redbook.computer_science_major | 300 | 3000 | reviewed | reviewed | not_claimed | source=reviewed; legalOutside=not_claimed; api=owner_technical_reviewed_no_outside_approval_claim |

## Checks

- `governance_registries_valid`: pass
- `launch_taxonomy_valid`: pass
- `input_privacy_scan_passed`: pass
- `registry_privacy_scan_passed`: pass
- `launch_source_lanes_have_coverage`: pass
- `launch_domains_have_source_lane_coverage`: pass
- `launch_subdomains_have_source_lane_coverage`: pass
- `source_lane_legal_api_renewal_complete`: pass
- `api_renewal_metadata_complete`: pass
- `legal_renewal_metadata_complete`: pass
- `source_lane_renewal_metadata_complete`: pass
- `expired_or_unknown_posture_blocks_coverage`: pass
- `outside_approval_not_claimed_without_artifacts`: pass
- `no_claims_r2_native_or_final_outputs_emitted`: pass

## External Release Gates

| Gate | Status | Required artifact |
|---|---|---|
| outside_legal_privacy_signoff | blocked_missing_external_artifact | qualified outside legal/privacy approval covering launch corpus, R2 posture, source terms, API policy, and no-private-graph boundary |
| physical_device_accessibility_visual_proof | blocked_missing_external_artifact | current physical-device run, independent accessibility review, and independent visual review for affected Source/Trust/Runtime flows |
| app_store_testflight_owner_approval | blocked_missing_external_artifact | App Store Connect validation, TestFlight validation, and explicit owner release approval |

## Allowed Claims

- `source_atlas_launch_floor_governance_renewal_tooling_green`
- `launch_source_lanes_have_legal_api_owner_renewal_posture`
- `launch_source_lanes_have_domain_subdomain_coverage_map`
- `external_release_gates_remain_blocked_without_real_artifacts`

## Blocked Claims

- `accessibility_approval`
- `app_store_readiness`
- `final_user_plans_schedules_steps_from_source_atlas_or_r2`
- `independent_visual_approval`
- `launch_floor_complete`
- `outside_legal_approval`
- `owner_release_approval`
- `physical_device_readiness`
- `privacy_legal_release_signoff`
- `r2_production_ready`
- `release_green`
- `source_atlas_launch_floor_ready`
- `testflight_readiness`

## Product Law Preserved

- Source Atlas/R2 remain public/reference/freshness infrastructure only.
- The renewal verifier emits governance evidence, not claims, packs, R2 writes, or native activation.
- Source-to-domain/subdomain coverage is derived from the public launch taxonomy only.
- Source Atlas does not receive private user context and does not generate final plans, schedules, or Steps.
- Outside legal/privacy, physical-device, accessibility, visual, App Store, TestFlight, and owner approval gates remain blocked until real external artifacts exist.

## Non-Claims

- not outside legal approval
- not privacy/legal release signoff
- not physical-device proof
- not accessibility approval
- not independent visual approval
- not App Store Connect validation
- not TestFlight validation
- not owner release approval
- not production R2 write or readback proof
- not launch-floor complete by itself
- not final user plans, schedules, Steps, priority order, or personalized paths from Source Atlas/R2
- not a private user-data backend
- not private life graph storage
- not an official legal, medical, financial, or admissions decision
- not runtime recommendation proof by itself
- not R2 release readiness
- not accessibility, privacy, or legal approval

## Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: Source Atlas Foundry tooling, Source Atlas governance registries, and Source Atlas QA evidence only.
- App behavior mutated: no.
- Compatibility shims left behind: none.
- Placeholder proof introduced: none.
