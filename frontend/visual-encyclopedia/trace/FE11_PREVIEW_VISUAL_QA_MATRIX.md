# FE-11 Preview Visual QA Matrix

Status: fixture-backed, screenshot not captured

This matrix is the FE-11 inventory ledger for the SI16 preview catalog. It is
deliberately honest about what is backed by deterministic fixtures and what
remains unproven.

| Artifact | Fixture-backed scope | Screenshot status | Accessibility status | Release/device status |
|---|---|---|---|---|
| SI16 preview fixture catalog | 21 deterministic fixtures across Today, Goals, Capture, Time, and You; 5 surface rows; 9 future LDI visual hooks | not captured | checklist scaffolded in source notes and preview variants | not release or device proof |
| Screenshot proof matrix | exact five top-level surfaces with fixture IDs | not captured | accessibility checklist scaffolded | not release or device proof |
| Visual regression readiness gate | future snapshot target names only | not captured | target names only; no measured conformance claim | not snapshot/device proof |
| FE-11 report | authored proof ledger and boundary statement | not captured | report keeps accessibility claims bounded to notes and checklist scaffolding | not proof |

## Surface Coverage

| Surface | Fixture IDs | Coverage note |
|---|---|---|
| Today | `today.normal`, `today.disabled`, `today.waiting`, `today.recovery` | Start Here and recovery coverage stays visible without a screenshot claim. |
| Goals | `goals.selected`, `goals.degraded`, `goals.staleSource`, `goals.needsReview` | Mission control, source drift, and review states stay fixture-backed only. |
| Capture | `capture.focused`, `capture.noDataYet`, `capture.blocked`, `capture.dynamicType` | Composer routing and large-text coverage stay in preview fixtures. |
| Time | `time.loading`, `time.partialSource`, `time.deniedSource`, `time.overwhelmingDay`, `time.reducedMotion` | Capacity, source, denial, overwhelm, and motion-reduction states stay explicit. |
| You | `you.empty`, `you.privacySensitive`, `you.setupNeeded`, `you.offlineLocalOnly` | Trust, privacy, setup, and local-only states remain in the settings-style shell. |

## Non-Claims

- No screenshot capture is claimed.
- No device proof is claimed.
- No accessibility conformance is claimed.
- No release readiness is claimed.
