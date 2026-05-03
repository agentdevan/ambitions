# Global Train Health Dashboard

Status: Active dashboard snapshot
Date: 2026-05-03

| Field | Current value |
| --- | --- |
| Current global order | 070 |
| Current active batch | EB20 Value Based Onboarding And First Week Success |
| Last completed batch | DAV15 Dynamic Adaptive Visual System Closeout |
| Next eligible batch | EB20 |
| Dirty / clean expectation | Clean before EB20 starts |
| Blockers | None recorded after DAV15 |
| Result posture | PASS WITH YELLOW |

## Open Yellow Owners

| Yellow | Owner batch / lane | Required proof |
| --- | --- | --- |
| Rendered DAV screenshot export absent | Future screenshot automation or human visual QA | Named preview screenshots or equivalent visual evidence. |
| Human visual review absent | Future visual QA board | Human-reviewed rendered Today, Capture, Plan, Goals, You, Memory, and Trust states. |
| Physical-device proof absent | Future device QA / release evidence lane | Device model, OS, build, scenario, and result record. |
| Manual VoiceOver traversal absent | Future accessibility QA | Per-surface traversal notes and repair list. |
| Contrast measurement absent | Future accessibility/visual QA | Measured contrast evidence for DAV surfaces. |
| Instruments/FPS/thermal/battery proof absent | Future performance QA | Instruments or equivalent measured performance evidence. |
| Docs QA backlog | Future docs hygiene lane | Reduced or classified stale-guidance, deprecated-language, and markdownlint logs. |

## Last Validation Commands

- `git diff --check`
- `bash scripts/photo-matched-reference-assets-check.sh || true`
- `bash scripts/dav-product-experience-scorecard.sh || true`
- `bash scripts/dav-preview-fixture-check.sh || true`
- `bash scripts/dav-visual-performance-risk-scan.sh || true`
- `bash scripts/sig-product-experience-scorecard.sh || true`
- `bash scripts/transformative-motion-boundary-check.sh || true`
- `bash scripts/transformative-motion-state-meaning-check.sh || true`
- `bash scripts/run-doc-qa.sh || true`
- `bash scripts/batch-train-gate-check.sh || true`

## Update Rule

Update this dashboard after any train closeout, hard Red, or accepted Yellow
that changes the next eligible batch, blocker state, or proof owner.
