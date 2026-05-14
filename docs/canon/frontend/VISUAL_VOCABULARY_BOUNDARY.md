# Visual Vocabulary Boundary

Status: Active canonical vocabulary boundary

This file classifies the most important frontend terms so active canon, historical support, and forbidden language do not blur together.

## Categories

- `user-facing allowed`: safe in current UI copy and active canon.
- `internal canon only`: allowed in docs/control-plane, not active top-level UI.
- `historical/supporting`: kept for traceability or compatibility only.
- `obsolete`: no longer active; keep only with explicit historical label.
- `forbidden`: must not appear as active user-facing canon.

## Boundary Table

| Term | Category | Rule |
|---|---|---|
| Today | user-facing allowed | Active top-level destination and current-state surface. |
| Goals | user-facing allowed | Active top-level destination and direction surface. |
| Capture | user-facing allowed | Active top-level destination and intake surface. |
| Time | user-facing allowed | Active top-level destination and LifeShape Field surface. |
| You | user-facing allowed | Active top-level destination and local runtime surface. |
| Plan | historical/supporting | Compatibility seam or contextual noun only; not top-level IA. |
| Start here | user-facing allowed | Preferred Today anchor. |
| Recommended step | user-facing allowed | Supporting Today copy. |
| Start now | user-facing allowed | Primary launch CTA when a step is ready. |
| Open step | user-facing allowed | Primary detail CTA for a step. |
| Hero Step Panel | historical/supporting | Old implementation alias only if an active recipe explicitly allows it. |
| DayTimelineRail | historical/supporting | Compatibility name for older Today rail language. |
| Reality Meridian | user-facing allowed | Today's dominant object. |
| Constellation Atlas | user-facing allowed | Goals' dominant object. |
| Atmosphere Composer | user-facing allowed | Capture's dominant object. |
| LifeShape Field | user-facing allowed | Time's dominant object. |
| User System Profile | user-facing allowed | You's dominant object. |
| QuietGlass | internal canon only | Semantic material primitive, not generic blur chrome. |
| GraphiteRecess | internal canon only | Semantic ground primitive, not card background. |
| LuminousTrace | internal canon only | Semantic state/source/proof line, not neon decoration. |
| CelestialField | internal canon only | Semantic background orientation layer, not starfield UI. |
| proof | user-facing allowed | Visible operating currency. |
| receipt | user-facing allowed | Closure and transaction evidence. |
| source | user-facing allowed | Source/freshness/trust disclosure. |
| local runtime | user-facing allowed | Plain-language control surface for on-device behavior. |
| Personal Runtime | internal canon only | Canon label for the You surface's runtime layer. |
| Still Counts | user-facing allowed | Non-shaming closure language. |
| closure | user-facing allowed | Loop-closing vocabulary. |
| protected time | user-facing allowed | Time / capacity vocabulary. |
| reflow | user-facing allowed | Time-shaping vocabulary. |
| confidence | forbidden | Do not expose model-confidence framing as active canon. |
| AI | forbidden | Do not use as core UX label for the native product. |
| assistant | forbidden | Do not frame the product as an assistant tab or assistant persona. |
| chatbot | forbidden | No chatbot UI as core product canon. |
| streak | forbidden | No streak mechanics or streak pressure. |
| score | forbidden | No productivity score / self-scoring canon. |
| ring | forbidden | No gamified rings as product canon. |
| dashboard | forbidden | No generic dashboard framing for active top-level surfaces. |
| card stack | forbidden | No generic card-stack shell as active canon. |

## Boundary Rules

- Use the user-facing terms in product copy first.
- Use the internal canon terms only where they explain the architecture or the control plane.
- Use historical/supporting terms only when preserving migration or traceability.
- Treat forbidden terms as hard-red leakage if they appear as active user-facing canon.
