# AFRI-020 Surface Route Map

Batch: AMB-372 / AFRI-020
Date: 2026-05-31

## Active Surface Contract

| Surface | Canonical raw route | Primary object | App owner |
|---|---|---|---|
| Today | `today` | Reality Meridian | `AppTab.today` |
| Goals | `goals` | Constellation Atlas | `AppTab.goals` |
| Capture | `capture` | Atmosphere Composer | `AppTab.capture` |
| Time | `time` | LifeShape Field | `AppTab.time` |
| You | `you` | User System Profile | `AppTab.you` |

## Route Surfaces Audited

| Surface area | Active authority | Evidence path |
|---|---|---|
| Shell tabs | `AppTab.allCases` and `AmbitionsSurfaceContractRegistry` | `Native/Ambitions/App/AppTab.swift`, `Native/Ambitions/App/AmbitionsRootView.swift` |
| Meridian shell accessibility identifiers | canonical `AppTab.rawValue` | `Native/Ambitions/App/AppShellPresentationMode.swift`, `Native/Ambitions/App/AppMeridianShell.swift` |
| Shell utility accessibility identifiers | canonical `AppTab.rawValue` | `Native/Ambitions/App/AmbitionsRootView.swift` |
| External routes and deep links | `LegacyIARouteCompatibility.externalRoute` funnels compatibility names into canonical routes | `Native/Ambitions/App/AppExternalRouting.swift`, `Native/Ambitions/App/AppTab.swift` |
| App Intents destination routing | active `time` destination naming, no competing `plan` destination case | `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift` |
| Screenshot fixtures | `ShellPreviewMatrix` derives rows from `AppTab.allCases` | `Native/Ambitions/PreviewSupport/ShellPreviewMatrix.swift` |
| Proof artifacts | AFRI-005 and AFRI-019 proof packets name the active surfaces and objects | `docs/proof/afri/afri-005-shell-preview-screenshot-proof.md`, `docs/proof/afri/afri-019-surface-contract-proof.md` |

## Compatibility Routes

These routes remain adapter-bounded for persistence, deep-link, and historical inbound compatibility. They are not active top-level destinations.

| Compatibility raw route | Canonical route | Boundary |
|---|---|---|
| `captures` | `capture` | inbound compatibility only |
| `plan` | `time` | inbound compatibility only |
| `habits` | `time` | Time-owned secondary route |
| `profile` | `you` | inbound compatibility only |
| `insights` | `you` | You-owned history route |

## Lint Gate

Run:

```bash
python3 scripts/ambitions-surface-contract-lint.py
```

The lint validates active surface references across app tabs, shell tabs, App Intents, external routing, deep-link compatibility, accessibility identifier patterns, screenshot fixtures, and proof artifacts.

## Claim Boundary

This route map is contract proof only. It does not prove rendered visual quality, accessibility conformance, device behavior, signed archive readiness, TestFlight readiness, App Store readiness, or final surface integration.
