# AMB-1776 Copy / State Language Audit

Status: Implemented Yellow / source copy cleanup and audit
Date: 2026-07-05
Scope: AMB-1776
Baseline SHA: `cf478400de1dfa5f0bc18868957cea7ef75b7c2a`

## Purpose

AMB-1776 audits and repairs user-facing copy that could revive stale root
surfaces, guilt framing, dashboard framing, fake AI certainty, or deprecated
state language before Today, Goals, Time, You, Capture, and Search acceptance
work continues.

This packet includes source copy cleanup plus residual classification. It does
not prove rendered UI, screenshots, accessibility behavior, device behavior, or
release readiness.

## Truth And Source Inputs

- `AGENTS.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- `.agents/skills/ambitions-runtime-contract-engineering/SKILL.md`
- Linear AMB-1776, AMB-1737 blocker context, and AMB-1768 drift ledger
- Current source under `Native/Ambitions/Language`, `Stage`, `Surfaces`,
  `DesignSystem`, `Scenarios`, and `Core/LocalRuntimeOS`

## Source Cleanup Summary

The cleanup is string-only. It does not change command routing, persistence,
projection ownership, runtime authority, model enum cases, or source paths.

Changed copy categories:

- Naked `Profile` user-facing labels were replaced with `Personal system`,
  `Personal context`, or the canonical `User System Profile` object name.
- Naked `Plan` as stale destination language was replaced with `Goals`,
  `Path`, `Goal path`, or `Ambitions` depending on context.
- `Captures` as a stale plural destination label was replaced with
  `Captured items` where it appeared as a visible filter or source row.
- `Default landing tab` became `Default starting surface`.
- Visible `dashboard` copy became `detached reporting` or `abstract number`.
- Visible `shame` and `guilt` copy became `blame` or `pressure`.

Representative source paths:

- `Native/Ambitions/Language/ProductCopy.swift`
- `Native/Ambitions/Language/ActivationContract.swift`
- `Native/Ambitions/Stage/Overlays/QuietCommandSheetView.swift`
- `Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService+02-RepositoryBackedTodayService+Repository03-openWindows.swift`
- `Native/Ambitions/Surfaces/Goals/Projection/GoalsFeatureService+07-pathBuilderState.swift`
- `Native/Ambitions/Surfaces/Time/Projection/TimeRitualsMetrics.swift`
- `Native/Ambitions/Surfaces/You/YouRootSurface.swift`
- `Native/Ambitions/Surfaces/You/Projection/YouFeatureServiceDashboardProjection.swift`
- `Native/Ambitions/Surfaces/You/Projection/YouFeatureServiceLifeContextProfileProjection.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/ExecutionResilienceProjector+02-normalizedAssessments.swift`

## Residual Classification

| Residual | Classification | Reason |
| --- | --- | --- |
| `User System Profile` | Allowed | Canonical You primary object from product truth. |
| `ForbiddenTopLevelTerms` entries for `Plan tab`, `Profile tab`, `Capture tab`, `Motion tab`, and `Captures tab` | Allowed policy guard | The strings are explicit forbidden-term rules, not product copy. |
| `CaptureCopyPolicy` entries for `guilt`, `shame`, `streak`, and `score` | Allowed policy guard | The strings are banned-input terms used to reject unsafe copy. |
| `AccessibilityLabelPolicy` entries for `dashboard`, `chatbot`, `ai`, `score`, and `streak` | Allowed policy guard | The strings are negative accessibility-label checks. |
| `YouDashboard`, `InsightsDashboard`, and `TimeRitualsDashboard` identifiers | Internal naming debt | These are model/type identifiers, not visible copy. Rename only in a scoped naming-debt train because it would touch broad APIs. |
| Lowercase `dashboard` in code comments | Internal commentary debt | Not visible copy; not a blocker for AMB-1776 source-copy acceptance. |

## Source Claim

Claim status: Implemented Yellow.

Supported claim:

- Current user-facing source copy has been scanned and directly cleaned for the
  AMB-1776 banned-language classes where the strings were visible surface,
  accessibility, source-row, or state-label copy.

Unsupported claims:

- Rendered copy proof.
- Screenshot proof.
- VoiceOver order proof.
- Dynamic Type proof.
- Reduce Motion proof.
- Reduce Transparency proof.
- High Contrast proof.
- Runtime behavior proof.
- Full internal naming cleanup.
- Visual Green.
- Release Green.

## Architecture Closeout

- `Final Architecture Tree` inspected: yes.
- Canonical owners touched: `Language`, `Stage/Overlays`,
  `Surfaces/Today`, `Surfaces/Goals`, `Surfaces/Time`, `Surfaces/You`,
  `Scenarios`, and `Core/LocalRuntimeOS`.
- Non-canonical owners touched: none.
- Files moved or created: this audit packet only.
- Old or non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: existing internal `Dashboard` type names remain naming
  debt and are not user-facing copy.
- Next repair train if debt remains: a separate internal naming collapse train
  can rename broad `Dashboard` model APIs if product law requires it.
- No equivalent folder or path interpretation was used.

## Private Life Orchestration Relationship

This work protects the loop:

```text
Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning
```

The cleanup keeps user-facing copy centered on current surfaces, goal paths,
local context, recovery, and proof without stale root destinations, guilt
framing, dashboard framing, or fake certainty.

## Proof Ceiling

No runtime/device/test proof was run under the current no-testing authorization.
Static validation commands are recorded in the companion JSON packet and Linear
closeout. This packet cannot upgrade AMB-1776 beyond Implemented Yellow.
