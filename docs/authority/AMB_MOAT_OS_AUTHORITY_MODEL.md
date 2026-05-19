# AMB_MOAT_OS_AUTHORITY_MODEL

## Product category

- Category: **Personal Life OS**
- Positioning: local-first life reality system, not productivity wrapper.

## Top-level authority

- Root IA: `Today / Goals / Capture / Time / You`
- Legacy names: `Plan` is compatibility seam only.

## Ownership model

| Layer | Owner |
| --- | --- |
| Runtime truth | `Native/Ambitions/Domain` + Private Life Runtime docs |
| Bridge contracts | `docs/contracts/*` and bridge implementation owners |
| Frontend projection | `Native/Ambitions/Features/*` and visual instruments |
| Trust and receipts | `docs/trust/*` and trust runtime contracts |
| Accessibility | `docs/accessibility/*` and UI implementations |
| Continuity | `docs/continuity/*` |
| Release governance | `docs/release/*` and Codex claim registry |
| Codex governance | `docs/codex/AMB_CODEX_GOVERNANCE_SPEC.md` |

## Forbidden authority regressions

- Do not move Start Here/source freshness/receipt truth to frontend ownership.
- Do not mark release claims Green without proof evidence.
- Do not reintroduce task/calendar/productivity/tabbed generic IA as active roots.

## State model

- `active`: in force for this batch and train.
- `supporting`: valid context but not authoritative.
- `historical`: valid for trace, not current behavior.
- `obsolete`: intentionally deprecated and should be retired in prompts.
- `archive-candidate`: clean-up candidate after migration.
- `delete-candidate`: dangerous, manual safe-review required before removal.

## Moat owners

Each moat in `docs/moats/AMB_MOAT_OS_IMPLEMENTATION_MAP.md` has a runtime owner, projection owner, visual owner, trust owner, and claim owner.
