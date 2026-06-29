# Source Atlas Legal Release Claim Gate

Status: Source Green for release-claim gate
Source Atlas status ceiling: Yellow overall Source Atlas; see per-claim evaluations

| Claim | Allowed | Scope | Issues |
| --- | --- | --- | --- |
| `source_atlas_terms_gate_green` | yes | bounded internal Source Atlas terms-review gate for listed sources |  |
| `unqualified_legal_approval` | no | blocked; only bounded internal terms-review may be claimed | unqualified legal approval requires a current source-specific legal/privacy approval artifact and cannot be inferred from internal terms review |
| `outside_legal_approval` | no | blocked | outside legal approval is not proven by a source-specific artifact and hash |
| `bounded_production_r2_write` | yes | specific production stable occupation_foundation R2 upload/readback proof |  |
| `bounded_live_native_transport` | yes | bounded production stable occupation_foundation Worker gateway and native URLSession/lifecycle proof |  |
| `bounded_production_target` | yes | specific production stable occupation_foundation pack target |  |
| `source_atlas_runtime_green` | no | blocked; requires full runtime scenario proof across Source Atlas composition, offline fallback, inspection, and release gates | current evidence proves bounded transport/lifecycle behavior, not broad Source Atlas Runtime Green |
| `release_green` | no | blocked | Codex cannot self-certify Release Green; release umbrella/device/accessibility/privacy/legal approval evidence is missing |
| `universal_coverage` | no | blocked | literal or unbounded universal coverage is not proven; use governed coverage-frontier scope instead |

## Allowed Claims

- `source_atlas_terms_gate_green`
- `bounded_production_r2_write`
- `bounded_live_native_transport`
- `bounded_production_target`

## Blocked Claims

- `unqualified_legal_approval`
- `outside_legal_approval`
- `source_atlas_runtime_green`
- `release_green`
- `universal_coverage`

## Non-Claims

- not outside legal approval unless an outside approval artifact is validated
- not unqualified legal approval
- not Release Green
- not Visual Green
- not App Store readiness
- not universal coverage
- not entitlement readiness
- not a private user-data backend
- not private life graph storage
- not an official legal, medical, financial, or admissions decision
- not runtime recommendation proof by itself
- not R2 release readiness
- not accessibility, privacy, or legal approval
