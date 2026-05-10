# Truth Wiring Audit

Status: Green for T01/T01b docs-control-plane wiring  
Scope: Truth wiring and front-door authority reconciliation  
Date: 2026-05-09

## Completed

`docs/truth/` is now the active repo authority layer, with front-door routing added to:

- `docs/truth/README.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `.codex/README.md`
- `docs/codex/CODEX_OS_INDEX.md`

## Active Authority Hierarchy

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/IMPLEMENTATION_TRUTH.md`
4. `docs/truth/RELEASE_TRUTH.md`
5. `docs/truth/CODEX_PROCESS_TRUTH.md`
6. `docs/truth/HISTORICAL_POLICY.md`

## Scope Boundaries

- Docs/control-plane only.
- No Swift source changes.
- No app implementation changes.
- No feature work.
- No deletes.
- No moves or archive operations.
- No release/readiness claims.

## Validation

- GitHub accepted the truth index and front-door routing updates.
- No Markdown/link checker was run.
- No `xcodegen`, `xcodebuild`, unit test, UI test, archive, accessibility, performance, device, TestFlight, or App Store validation was run.

## Remaining Work

T02 — `.codex` / `.agents` skill inventory and active/candidate/historical/quarantine classification.
