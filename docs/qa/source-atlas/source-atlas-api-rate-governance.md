# Source Atlas API Rate Governance

Status: Green

This packet governs live Source Atlas adapters. It does not approve unbounded high-volume production use.

| Adapter | Source IDs | Budget | Timeout | Retry/backoff | Missing-key behavior | Rate-limit handling |
|---|---|---|---|---|---|---|
| official_bls_public_api | bls.public.data.api | daily=200; perRun=10 | 120 | exponential_jitter | fallback_to_v1_no_key | captureHeaders=True; backoffOn429=True; respectRetryAfter=True |
| official_college_scorecard_api | college-scorecard.api | daily=100; perRun=9 | 120 | exponential_jitter | use_demo_key_until_rate_limited_then_block_with_env_name | captureHeaders=True; backoffOn429=True; respectRetryAfter=True |
| official_datagov_v4_search | data.gov.catalog | daily=100; perRun=9 | 120 | exponential_jitter | use_demo_key_until_rate_limited_then_block_with_env_name | captureHeaders=True; backoffOn429=True; respectRetryAfter=True |
| official_onet_text_database | onet.database | daily=20; perRun=3 | 120 | exponential_jitter | use_public_database_route | captureHeaders=False; backoffOn429=True; respectRetryAfter=True |
| official_openalex_api | openalex.works | daily=100; perRun=6; freeKey:daily=1000,perRun=20; noKey:daily=100,perRun=6 | 60 | exponential_jitter | use_no_key_low_budget_lane | captureHeaders=True; backoffOn429=True; respectRetryAfter=True |
| official_static_page | nara.constitution.presidency, nasa.astronaut.requirements, nasa.astronaut.selection | daily=50; perRun=6 | 120 | exponential_jitter | no_key_required | captureHeaders=False; backoffOn429=True; respectRetryAfter=True |
| official_usajobs_authenticated_search | usajobs.search | daily=50; perRun=5 | 60 | exponential_jitter | block_lookup_only_route | captureHeaders=True; backoffOn429=True; respectRetryAfter=True |
| official_wikidata_entity_crosswalk | wikidata.structured_crosswalk | daily=100; perRun=9 | 60 | exponential_jitter | no_key_required | captureHeaders=True; backoffOn429=True; respectRetryAfter=True |

## Non-Claims

- not a private user-data backend
- not private life graph storage
- not an official legal, medical, financial, or admissions decision
- not runtime recommendation proof by itself
- not R2 release readiness
- not accessibility, privacy, or legal approval
- not release readiness
- not App Store readiness
- not outside legal approval
- not unbounded high-volume production approval
