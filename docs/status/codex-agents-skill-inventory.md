# Codex / Agents Skill Inventory

Status: Green for T07c-closeout provider skill deletion state  
Date: 2026-05-09

## Authority

Active repo authority starts in `docs/truth/README.md`. If this inventory conflicts with `docs/truth/*`, the truth files win.

## Scope

Docs/control-plane status only. No Swift changes, app implementation, app feature work, or release/readiness claims.

## Current Provider Skill State

The previously quarantined external provider skill packages are no longer present at their active `.agents/skills/` paths:

- `.agents/skills/supabase/` — deleted from active skills path.
- `.agents/skills/supabase-postgres-best-practices/` — deleted from active skills path.

This means they must not be auto-loaded for Ambitions core work. Any future Supabase/Postgres/provider material must be reintroduced only through explicit owner approval and `docs/truth/*`-compatible architecture review.

## Classification

| Area | Status | Decision |
| --- | --- | --- |
| `.agents/skills/supabase/` | Deleted from active skills path | External hosted-provider workflow is not active Ambitions source truth. Do not recreate without explicit approval. |
| `.agents/skills/supabase-postgres-best-practices/` | Deleted from active skills path | External database/provider reference is not active Ambitions architecture. Do not recreate without explicit approval. |
| `.codex/skills/` source-truth, evidence, build, validation, privacy, accessibility, copy, and scope-control skills | Active operating support | May be used when compatible with `docs/truth/*`, active batch scope, and evidence boundaries. |
| `.codex/skills/` product or implementation builder skills | Candidate | Use only when an active batch explicitly selects them. Do not treat them as shipped behavior. |
| `.codex/skills/README.md` historical Ambitions 3.0 framing | Historical | Subordinate to `.codex/README.md` and `docs/truth/*`. |
| `.codex/manifests/skills-routing-map.yml` | Supporting routing map | Useful routing context, subordinate to `docs/truth/*`. |

## Decisions

1. Provider-specific `.agents/skills/supabase*` material is removed from active skill paths.
2. `.codex/skills` remains operating support where compatible with active truth files.
3. Implementation-builder skills are candidate-only unless selected by an active batch.
4. Historical Ambitions 3.0/4.0/PXOS/SI phrasing inside skill/control-plane material does not override `docs/truth/*`.

## Validation

Direct path checks returned `404 Not Found` for representative files under both provider packages after deletion. No Markdown/link checker, build, test, archive, accessibility, performance, device, TestFlight, or App Store validation was run.

## Next Recommended Step

Update or retire stale audit inventories such as `docs/audits/tracked-files.txt`, which still preserve old provider paths as historical inventory output.
