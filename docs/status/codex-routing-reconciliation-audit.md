# Codex Routing Reconciliation Audit

Status: Green for T03 docs-control-plane reconciliation  
Date: 2026-05-09

## Purpose

Record the T03 pass that reconciled stale Codex skill framing and stale routing names after T02 classified `.codex` / `.agents` skills.

## Scope

Docs/control-plane only. No Swift source changes, app implementation changes, deletes, moves, archive operations, or release/readiness claims.

## Files Changed

- `.codex/skills/README.md`
- `.codex/manifests/skills-routing-map.yml`
- `docs/status/codex-routing-reconciliation-audit.md`

## Decisions

1. `.codex/skills/README.md` now routes through `docs/truth/*` and `docs/status/codex-agents-skill-inventory.md` before any skill file.
2. `.codex/manifests/skills-routing-map.yml` is now version 2 and explicitly subordinate to `docs/truth/*`.
3. Stale phantom skill names were removed from the routing map and replaced with tracked `.codex/skills` names.
4. `.agents/skills/supabase/` and `.agents/skills/supabase-postgres-best-practices/` are listed as forbidden skill roots for Ambitions core work.
5. Product/implementation builder skills remain candidate support unless selected by an active batch.

## Validation

GitHub accepted the docs/control-plane file updates. No Markdown/link checker, `xcodegen`, `xcodebuild`, unit test, UI test, archive, accessibility, performance, device, TestFlight, or App Store validation was run.

## Next Recommended Step

T04 — create a cleanup decision register for historical docs and control-plane material, identifying what is active, supporting, historical, quarantine, and deletion-candidate without moving or deleting files yet.
