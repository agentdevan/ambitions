# Codex Canon Consumption Benchmark

> Deterministic offline benchmark evidence; not product, runtime, visual, accessibility, privacy, device, TestFlight, App Store, or release proof.

- Canon revision: `1`
- Canon SHA: `7613037640f38d7771c9efc3d922acd5978e2cc5a47d51ec91944bf5ad093865`
- Authority state: `shadow`
- Token estimate: deterministic four-characters-per-token ceiling

## Deterministic scenario measures

| Scenario | Characters (informational) | Estimated tokens | Budget class | Token ceiling | Requirement recall | Requirement precision | Shared laws | Contradictions | Owner recall | Owner precision | Verification | Validation | Proof | Result |
| --- | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- | --- |
| `today-swiftui` | 11454 | 2864 | `complex` | 30000 | 14/14 | 14/14 | 9/9 | 0 | 8/8 | 8/8 | exact | present | present | PASS |
| `time-recurrence` | 22574 | 5644 | `complex` | 30000 | 34/34 | 34/34 | 18/18 | 0 | 21/21 | 21/21 | exact | present | present | PASS |
| `capture-proposal` | 23331 | 5833 | `complex` | 30000 | 34/34 | 34/34 | 18/18 | 0 | 20/20 | 20/20 | exact | present | present | PASS |
| `local-runtime-mutation` | 15678 | 3920 | `complex` | 30000 | 20/20 | 20/20 | 17/17 | 0 | 15/15 | 15/15 | exact | present | present | PASS |
| `cloudkit-continuity` | 85383 | 21346 | `complex` | 30000 | 176/176 | 176/176 | 37/37 | 0 | 36/36 | 36/36 | exact | present | present | PASS |
| `source-atlas-boundary` | 82755 | 20689 | `complex` | 30000 | 171/171 | 171/171 | 37/37 | 0 | 36/36 | 36/36 | exact | present | present | PASS |
| `accessibility-repair` | 2772 | 693 | `complex` | 30000 | 2/2 | 2/2 | 2/2 | 0 | 3/3 | 3/3 | exact | present | present | PASS |
| `release-proof-claim` | 106853 | 26714 | `complex` | 30000 | 228/228 | 228/228 | 39/39 | 0 | 41/41 | 41/41 | exact | present | present | PASS |

## Resume-safe authorization checks

A stored pack fails closed after canon revision or content, Git HEAD or diff, intake or issue identity, source ownership, conflicts or known issues, and validation/proof posture changes.

## Semantic quality comparison

Semantic quality comparison is separate evidence and never a CI, network, or LLM dependency.

- Reviewer: `task21_final_score_v3`
- Model: `Ultra`
- Prompt SHA: `928a72050ce0f978e2827aa93654e11cda41cc0cfdccaaa55bff6e87bf3d69ec`
- Compiler input SHA: `654e4701084520ef2058fbd20473a7a2bd91005900369356d4396ab90917fd5b`
- Compiler input verification: independently recomputed from the current 16 framed pack files
- Canon SHA: `7613037640f38d7771c9efc3d922acd5978e2cc5a47d51ec91944bf5ad093865`
- Git base: `a9e4b7d1efc390d41bc4bb5a227c44fe7f91836c`
- Old evidence SHA: `dca20fc2ade0981a5aaa6554edd05d2f54ec2782cf18357b2fc8a0e1ad069c3a`
- New evidence SHA: `77616d5171d6cb2ab7fb81b8e02ee1dbfa9d88fc48072fd8622c863a7ec5bad3`
- Score evidence SHA: `c6172e41528ef4cd281aa5c995d6420f3fc8836eb57f0c9ffd646544489ebfb9`
- Tracked evidence directory: `tests/canon/fixtures/benchmark-semantic-evidence/`

| Response path | Score |
| --- | ---: |
| Old truth-file path | 63/96 |
| New task pack | 96/96 |

- Final semantic-ID recall: `856/856`
- Final semantic-ID precision: `856/856`
- Final missing/unexpected IDs: `0/0`
- Final owner false negatives/false positives: `0/0`

| Dimension | Old | New |
| --- | ---: | ---: |
| `relevant-semantic-id-recall-precision` | 0/16 | 16/16 |
| `contradiction-control` | 15/16 | 16/16 |
| `unauthorized-assumptions` | 16/16 | 16/16 |
| `source-owner-accuracy` | 8/16 | 16/16 |
| `validation-completeness` | 8/16 | 16/16 |
| `proof-discipline` | 16/16 | 16/16 |

| Scenario | Old | New |
| --- | ---: | ---: |
| `today-swiftui` | 8/12 | 12/12 |
| `time-recurrence` | 8/12 | 12/12 |
| `capture-proposal` | 8/12 | 12/12 |
| `local-runtime-mutation` | 8/12 | 12/12 |
| `cloudkit-continuity` | 8/12 | 12/12 |
| `source-atlas-boundary` | 8/12 | 12/12 |
| `accessibility-repair` | 8/12 | 12/12 |
| `release-proof-claim` | 7/12 | 12/12 |

Protocol deviations:


The final repaired pack response scores 96/96 versus 63/96 for the frozen old path. It has exact 856/856 semantic-ID recall and precision, exact source-owner mapping, exact required validation and proof fields, bounded assumptions and contradiction controls, and a shadow-only claim ceiling for all eight scenarios.

## Proof ceiling

Bounded, read-only, non-CI semantic comparison of the two exact response artifacts against the current eight benchmark fixtures and the 16 exact frozen shadow task-pack files only. It does not authorize source edits and does not prove generalized model quality or implementation, product, runtime, visual, accessibility, privacy, device, CloudKit, R2, account, TestFlight, App Store, or release readiness.
The deterministic benchmark separately proves only pack construction and the measured fixture assertions at the recorded shadow canon; it does not authorize implementation.
