# Truth Wiring Audit

Status: Yellow  
Scope: T01 — Truth Wiring and Authority Reconciliation  
Date: 2026-05-09

## Purpose

Record the first docs/control-plane pass that makes `docs/truth/` the active authority layer for Ambitions.

## Scope Boundaries

- Docs/control-plane only.
- No Swift source changes.
- No app implementation changes.
- No feature work.
- No deletes.
- No moves or archive operations.
- No release/readiness claims.

## Files Inspected

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `README.md`
- `AGENTS.md`
- `docs/README.md`
- `.codex/README.md`
- `docs/codex/CODEX_OS_INDEX.md`
- `docs/status/current-implementation-map.md`
- `docs/status/release-evidence-packet.md`
- `docs/status/repo-cleanup-index.md`

## Files Changed

- `docs/truth/README.md` — added active truth authority index.
- `docs/status/truth-wiring-audit.md` — records T01 wiring state, stale front doors, and next cleanup path.

## Current Active Truth Hierarchy

1. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
2. `docs/truth/IMPLEMENTATION_TRUTH.md`
3. `docs/truth/RELEASE_TRUTH.md`
4. `docs/truth/CODEX_PROCESS_TRUTH.md`
5. `docs/truth/HISTORICAL_POLICY.md`

## Remaining Conflicts / Stale References

- `README.md` still contains legacy AmbitionsCanon-first routing unless separately patched.
- `AGENTS.md`, `docs/README.md`, `.codex/README.md`, and `docs/codex/CODEX_OS_INDEX.md` still require front-door reconciliation if they route through old canon/process files before `docs/truth/*`.
- `.codex/README.md` has historical Ambitions 3.0 framing and requires T02 inventory/classification.
- Legacy references to PXOS / ACUI / Ambitions 3.0 / Ambitions 4.0 / Plan / Profile / Captures may remain and require classification before cleanup.
- `.agents/skills/supabase*` or other provider-specific material requires local-first/core architecture classification before use.

## Platform Write Note

A broad `README.md` replacement was attempted during T01 but was blocked by the write layer before GitHub accepted it. This audit records that remaining front-door rewiring should be done as a smaller banner-level patch or from a local clone.

## Validation

- GitHub accepted creation of `docs/truth/README.md`.
- This audit is docs-only.
- No Markdown/link checker was run.
- No `xcodegen`, `xcodebuild`, unit test, UI test, archive, accessibility, performance, device, TestFlight, or App Store validation was run.

## Claims Not Made

- No Swift/app behavior changed.
- No release readiness claimed.
- No TestFlight or App Store readiness claimed.
- No physical-device validation claimed.
- No accessibility or performance conformance claimed.
- No privacy/legal signoff claimed.
- No historical file was deleted, moved, archived, or quarantined.
- No claim that all repo front doors are fully rewired.

## Next Recommended Step

T01b — add narrow truth-precedence banners to `README.md`, `AGENTS.md`, `docs/README.md`, `.codex/README.md`, and `docs/codex/CODEX_OS_INDEX.md`, then run T02: `.codex` / `.agents` skill inventory and active/candidate/historical/quarantine classification.
