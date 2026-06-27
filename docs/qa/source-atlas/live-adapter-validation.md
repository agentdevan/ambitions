# Source Atlas Live Adapter Validation

Status: Green

Live validation checks approved public/reference source reachability and minimized normalization evidence. It does not write raw live payloads to packs and does not promote production R2 objects.

| Adapter | Source | Fetched | Normalized | Blocked | Terms | Privacy | Result |
| --- | --- | ---: | ---: | ---: | --- | --- | --- |
| onet | `onet.database` | 1 | 1 | 0 | redistributable_with_attribution | True | Green |
| bls | `bls.public.data.api` | 1 | 1 | 0 | redistributable_with_attribution | True | Green |
| wikidata | `wikidata.crosswalk` | 1 | 1 | 0 | redistributable | True | Green |
| openalex | `openalex.dataset` | 5 | 5 | 0 | redistributable | True | Green |
| restricted | `usajobs.search` | 0 | 0 | 1 | lookup_only_not_packable | True | Green |

## Non-Claims

- does not create final user paths
- does not create final schedules
- does not create Step lists
- does not gather private user data
- does not claim legal/privacy approval
- does not claim production R2 promotion
- not a private user-data backend
- not private life graph storage
- not an official legal, medical, financial, or admissions decision
- not runtime recommendation proof by itself
- not R2 release readiness
- not accessibility, privacy, or legal approval
