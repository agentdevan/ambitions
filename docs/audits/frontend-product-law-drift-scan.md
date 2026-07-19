# AMB-1768 Frontend Product-Law Drift Scan

Status: Implemented Yellow / drift ledger
Date: 2026-07-05
Scope: AMB-1768
Baseline SHA: `95e6bd882284b91135564ceac91693eb5432d9f0`

## Purpose

AMB-1768 scans the Ambitions Flagship Frontend Recovery control plane and
current repo evidence for stale root-surface language before AMB-1735 and
search/front-end acceptance work continue.

This file is a drift ledger only. It does not change source, rename Linear
labels, prove runtime UI, prove screenshots, prove accessibility, or close any
Visual Green, release, device, or App Store claim.

## Inputs

Live Linear inputs fetched on 2026-07-05:

- project: `Ambitions Flagship Frontend Recovery`
- project resources:
  - `Frontend Recovery Program Charter`
  - `Frontend Codex Execution Index`
  - `Frontend Quality Rubric`
  - `Frontend Parent Feature Closeout Standard`
- current project issue list: 26 issues from AMB-1733 through AMB-1776
- Ambitions team label list, two pages
- blocking context for AMB-1735 and AMB-1768

Repo inputs inspected:

- `docs/audits/frontend-screen-route-registry.md`
- `docs/audits/frontend-journey-registry.md`
- `docs/audits/frontend-deletion-quarantine-candidates.md`
- `docs/audits/frontend-missing-screen-audit.md`
- `docs/audits/amb-1747-stage-shell-frontend-reality-audit.md`
- scoped text scans over `docs/audits/frontend-*.md`, `Native/Ambitions`,
  `Native/AmbitionsTests`, and `Native/AmbitionsUITests`

## Result Summary

The active frontend recovery project name, summary, charter, execution index,
quality rubric, and parent closeout standard are aligned with current product
law:

- Today / Goals / Time / You are the only persistent surfaces.
- Capture is a global composer/action layer, not a tab.
- Motion is Stage behavior, not a destination.
- Proof / Source / Privacy / History / Receipts remain inspection details.

The current project issue titles and descriptions are mostly aligned. Terms
like `dashboard`, `chatbot`, `Motion tab`, and `Capture tab` appear mainly as
explicit forbidden examples or no-fake-Green guardrails, not as active product
claims.

Actual drift remains in the wider Linear label taxonomy and a few repo naming
areas:

- `motion-surface`, `pulse`, and `surface: pulse` are stale IA labels.
- `surface:capture` and `surface: capture` are misleading because Capture is
  not a persistent surface.
- non-root labels such as `surface: widgets`, `surface: onboarding`,
  `surface: settings-privacy`, and `surface: step` should be treated as legacy
  taxonomy unless a scoped issue uses them only as area tags.
- repo terms such as `YouTrustPulseState` and `YouFeatureServiceDashboard...`
  are copy/naming review candidates, not root IA proof.

## Drift Ledger

| Area | Finding | Owning object | Correction | Blocks Codex? |
| --- | --- | --- | --- | --- |
| Project name | `Ambitions Flagship Frontend Recovery` is aligned and does not introduce stale roots. | Linear project | No correction. | No. |
| Project summary and description | Uses the four-surface law and proof ceilings correctly. | Linear project | No correction. | No. |
| Project documents | Charter, execution index, rubric, and closeout standard preserve Capture global composer, Motion behavior, and inspection-detail boundaries. | Linear project documents | No correction. | No. |
| Project issue titles/descriptions | AMB-1735 through AMB-1776 use stale terms mainly as guard text: `not a dashboard`, `no chatbot`, `not a tab`, or no-fake-Green proof requirements. | Linear project issues | Preserve as guard language. Do not treat guard text as drift. | No. |
| `surface:capture` / `surface: capture` labels | Misleading taxonomy. Capture is a global composer/action layer, not a persistent surface. | Linear labels | Prefer `capture-global` or a future `composer:capture` label. Keep existing issue bodies explicit until labels can be renamed. | No for AMB-1735. Yes for future label hygiene before broad automation trusts labels as truth. |
| `motion-surface` label | Stale with current canon. Motion is Stage/Motion behavior, not a surface or root destination. | Linear label | Replace future use with `stage-motion` or `motion-behavior`. | Yes if used to mature root IA or surface implementation. Not blocking current source-route audit. |
| `pulse` / `surface: pulse` labels | Historical root-surface language. Pulse is not active top-level IA. | Linear labels | Replace with the actual owner: `trust`, `history`, `proof`, `stage-motion`, or issue-specific behavior labels. | Yes if used as active product authority. No if retained only as historical label debt. |
| `surface: widgets`, `surface: onboarding`, `surface: settings-privacy`, `surface: step` | These can read as root-surface taxonomy even when they mean platform, setup, settings, or Step detail areas. | Linear labels | Prefer `area: platform`, `area: onboarding`, `privacy-trust`, or `surface: today/goals/time/you` plus detail labels. | Not immediate. Review before promoting related frontend leaves. |
| Repo stale-root tests | `Plan`, `Pulse`, `Profile`, `Captures`, `Capture tab`, and `Motion tab` appear in tests mostly as negative assertions or compatibility inputs. | `Native/AmbitionsTests`, `Native/AmbitionsUITests` | Retain negative assertions. Do not cite them as active surface evidence. | No. |
| Active stale destination blocker | `ShellCommandDestination.staleIADestinationBlockers` blocks exact stale labels such as `plan`, `pulse`, `profile`, `calendar`, and `inbox`. | `Native/Ambitions/App/ShellCommandDestination.swift` | Retain until replaced by an equal or stricter guard. | No. |
| You trust `pulse` naming | `YouTrustPulseState` and related copy can imply historical Pulse semantics. | `Native/Ambitions/Surfaces/You/Projection/`, `Native/Ambitions/Core/Domain/YouModels.swift` | AMB-1776 should review user-facing copy and naming without claiming runtime proof. | Blocks You copy Green, not AMB-1735 source acceptance. |
| Dashboard naming | `Dashboard` appears in internal You/Time model names and many tests; current project docs use `dashboard` mainly as forbidden framing. | `Native/Ambitions/Surfaces/You/Projection/`, `Native/Ambitions/Surfaces/Time/Projection/`, tests | AMB-1776 should classify user-facing copy separately from internal model names and negative tests. | Blocks copy Green only. |

## AMB-1735 Impact

AMB-1768 no longer blocks AMB-1735 as a product-law drift unknown. Current
source-route evidence and the AMB-1751 registries can be used for an AMB-1735
Implemented Yellow closeout as long as the closeout states:

- no screenshot proof was run
- no accessibility proof was run
- no device proof was run
- no Visual Green or release claim is made
- AMB-1479 remains a separate visual specification authority blocker

## AMB-1764 Impact

AMB-1768 provides product-law routing for Search / Find / Act / Inspect:

- Search must remain local-only.
- Search must not be framed as chatbot or cloud search.
- Search handoffs must route to Today, Goals, Time, You, Capture overlay, or
  remain blocked.
- Screenshot, accessibility, offline, and no-account proof still block Green.

## Follow-Up Routing

- AMB-1735: may continue as root IA / Stage shell source acceptance with Yellow
  proof ceilings.
- AMB-1764: may use this ledger as product-law input for search acceptance.
- AMB-1776: should own user-facing copy and state-language cleanup, including
  `pulse`, `dashboard`, `profile`, shame/guilt copy, chatbot framing, and fake
  certainty.
- AMB-1742: should use the quarantine registry for stale labels in tests,
  previews, historical screenshots, and evidence artifacts.
- AMB-1479: still blocks visual-authority Green and broad UI implementation
  claims until repaired.

## Proof Ceiling

Claim status for AMB-1768: Implemented Yellow.

Allowed claim:

- Current Linear/project docs/issues/labels and scoped repo scans have a drift
  ledger with owner, correction, and Codex-blocking classification.

Forbidden claims from this packet:

- frontend implementation Green
- Visual Green
- accessibility conformance
- screenshot/device proof
- App Store readiness
- release readiness
- stale label cleanup completed
- source copy cleanup completed
