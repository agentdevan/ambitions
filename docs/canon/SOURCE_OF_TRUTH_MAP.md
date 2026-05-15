# Ambitions Source of Truth Map

Status: Supporting repo authority map  
Authority: Subordinate to `docs/truth/README.md` and `docs/truth/*`  
Last repaired directly through GitHub API: 2026-05-15

This file is a routing map only. It does not override the active truth files, live source, tests, scripts, or current proof artifacts.

## Mandatory read order

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `README.md`
9. `docs/README.md`
10. Relevant current source, tests, scripts, validation reports, and proof artifacts
11. Supporting docs only after the truth files
12. Historical material only when needed for traceability or extraction

## Current IA

The current top-level IA is:

`Today / Goals / Capture / Time / You`

`Plan` is compatibility-only and is not a top-level destination.

## Current primary objects

| Surface | Primary object |
|---|---|
| Today | Reality Meridian |
| Goals | Constellation Atlas |
| Capture | Atmosphere Composer |
| Time | LifeShape Field |
| You | User System Profile |

## Active authority

| Area | Active authority |
|---|---|
| Product/design | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Moat | `docs/truth/PRODUCT_MOAT_TRUTH.md` |
| Implementation/source status | `docs/truth/IMPLEMENTATION_TRUTH.md` plus live source/tests/scripts |
| Release/proof claims | `docs/truth/RELEASE_TRUTH.md` plus current proof artifacts |
| Codex process | `docs/truth/CODEX_PROCESS_TRUTH.md` |
| Historical cleanup | `docs/truth/HISTORICAL_POLICY.md` |
| Frontend portal | `frontend/README.md` |
| GitHub automation policy | `.github/README.md` |

## Supporting material

Supporting material can guide work but cannot override `docs/truth/*`.

| Area | Classification |
|---|---|
| `frontend/` | Active/supporting frontend authority |
| `product-canon/` | Supporting product/design portal |
| `docs/AmbitionsCanon/` | Supporting product/design canon |
| `docs/codex/` | Supporting process and execution history |
| `.codex/` | Supporting control-plane material |
| `docs/status/` | Supporting status context |
| `docs/audits/` | Historical/supporting evidence |
| `docs/handoff/` | Historical/supporting handoff trail |
| `build/reports/` | Generated supporting reports, only proof when current and explicitly scoped |

## Historical material

The following are not active authority by default:

- `docs/canon/Ambitions_2_0*`
- `docs/canon/Ambitions_3_0*`
- `docs/canon/Ambitions_4_0*`
- `docs/canon/PXOS_*`
- `docs/canon/ACUI_*`
- old batch-train reports
- old handoff packets
- stale inventory files
- one-off prompts not routed through the active process

Historical files may contain useful decisions. Those decisions must be extracted into active truth or compatible supporting docs before the old file is used as guidance.

## Active-language guardrails

Do not revive these in active authority:

- `Plan` as a top-level destination
- `Profile` as a top-level destination
- `Captures` as a top-level destination
- `DayTimelineRail` as active product language
- `Hero Step Panel` as user-facing language
- `Start Focus` or `Begin Focus`
- `Your best next move` or `next best move`

## Conflict resolution

| Conflict | Winner |
|---|---|
| Old canon vs truth files | `docs/truth/*` |
| Old IA vs current IA | `Today / Goals / Capture / Time / You` |
| Old Plan tab references vs Time tab | Time tab |
| Old implementation status vs live source/tests/scripts | Live source/tests/scripts |
| Old release claim vs current proof | Current proof and `RELEASE_TRUTH.md` |
| Old process direction vs Codex truth | `CODEX_PROCESS_TRUTH.md` |
| Old cleanup direction vs historical policy | `HISTORICAL_POLICY.md` |

## Direct repair note

This file previously promoted older canon and contained Plan-era source-truth ordering. The 2026-05-15 direct GitHub API repair restores truth-first routing and the current `Time` IA.

## Non-proof boundary

This file does not prove build success, tests passing, accessibility conformance, visual QA, device validation, TestFlight readiness, App Store readiness, or release readiness. Those claims require current evidence governed by `docs/truth/RELEASE_TRUTH.md`.
