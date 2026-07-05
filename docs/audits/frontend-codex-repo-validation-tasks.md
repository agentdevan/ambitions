# Frontend Codex Repo Validation Tasks

Status: Frontend validation task list / Implemented Yellow
Date: 2026-07-05
Scope: AMB-1733
Baseline SHA: `e30f3f40043ab995f295643c8d054343b86d15a8`

## First Repo-Validation Tasks

| Task ID | Purpose | Owner paths | Non-test validation | Test/proof validation when allowed |
| --- | --- | --- | --- | --- |
| FVT-001 | Refresh root shell source-owner proof before shell implementation. | `Native/Ambitions/App/`, `Native/Ambitions/Stage/` | `git diff --check`; `python3 scripts/ambitions-quality-gate.py`; `python3 scripts/ambitions-architecture-inventory.py` | root shell screenshot lane and focused UI route proof |
| FVT-002 | Validate Capture remains global composer before Capture implementation. | `Native/Ambitions/Composer/Capture/`, `Native/Ambitions/Stage/Overlays/`, `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift` | source scan for Capture root/tab language; release claim scan | Capture keyboard/screenshot/accessibility journey |
| FVT-003 | Validate Today route and state gates before Today implementation. | `Native/Ambitions/Surfaces/Today/`, `Native/Ambitions/DesignSystem/ProductObjects/Today*` | registry classification check; green-standard audit | Today Start here and closure journey proof |
| FVT-004 | Validate Goals route and detail owners before Goals implementation. | `Native/Ambitions/Surfaces/Goals/`, `Native/Ambitions/Stage/StageRoute.swift` | registry classification check; stale root label scan | Goals root, life area, and goal detail journeys |
| FVT-005 | Validate Time Life Calendar owner paths before Time implementation. | `Native/Ambitions/Surfaces/Time/`, `Native/Ambitions/DesignSystem/ProductObjects/LifeShape*` | local-first boundary scan; release claim scan | Time screenshot, Dynamic Type, Reduce Motion, and permission proof |
| FVT-006 | Validate You/Trust owner paths before You implementation. | `Native/Ambitions/Surfaces/You/`, `Native/Ambitions/Trust/` | privacy-boundary advisory scan; release claim scan | You detail, privacy, source, history, and receipt journeys |
| FVT-007 | Validate Search as local-only Find / Act / Inspect before Search implementation. | `Native/Ambitions/Stage/Overlays/`, `Native/Ambitions/App/ShellCommandRouter.swift`, `Native/Ambitions/Surfaces/You/Projection/SearchLens.swift` | no-unsupported-AI scan; local-first boundary scan | Search result, no-result, and trusted-handoff journey proof |
| FVT-008 | Validate external route boundaries before widget/share/app-intent frontend claims. | `Native/Ambitions/App/AppDeepLinkRegistry.swift`, `Native/Ambitions/App/AppExternalRouting.swift`, `Native/Ambitions/Projection/ExternalSnapshots/` | privacy-boundary advisory scan; release claim scan | per-source external-route runtime proof |

## Bootstrap Prompt

Use this prompt before promoting any frontend implementation leaf to Ready For
Codex:

```text
Start from current main, not memory. Read AGENTS.md, docs/truth/CODEX_START_HERE.md,
docs/truth/PRODUCT_DESIGN_TRUTH.md, docs/truth/IMPLEMENTATION_TRUTH.md,
docs/truth/RELEASE_TRUTH.md, docs/audits/frontend-evidence-intake.md,
docs/audits/frontend-recovery-current-state.md, docs/audits/frontend-screen-route-registry.md,
docs/audits/frontend-journey-registry.md, docs/audits/frontend-missing-screen-audit.md,
and docs/audits/frontend-deletion-quarantine-candidates.md.

For the named frontend leaf, verify exact current source-owner paths, route
classification, required screenshot states, accessibility requirements, non-claims,
rollback path, and validation commands before editing. Preserve Today / Goals /
Time / You as the only persistent surfaces, Capture as global composer, Motion
as behavior, and Trust details as contextual inspection. If testing remains
disabled, complete only the non-test validation and keep proof Yellow.
```

## Non-Claims

This task list does not run the validations and does not prove implementation,
rendered UI, accessibility conformance, device behavior, App Store readiness,
release readiness, or frontend completion.
