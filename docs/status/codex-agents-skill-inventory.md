# Codex / Agents Skill Inventory

Status: Green for T02 docs-control-plane classification  
Date: 2026-05-09

## Authority

Active repo authority starts in `docs/truth/README.md`. If this inventory conflicts with `docs/truth/*`, the truth files win.

## Scope

Docs/control-plane only. No Swift changes, app implementation, deletes, moves, archive operations, or release/readiness claims.

## Evidence Inputs

- `docs/audits/tracked-files.txt`
- `.codex/skills/README.md`
- `.codex/manifests/skills-routing-map.yml`
- `.agents/skills/supabase/SKILL.md`
- `.agents/skills/supabase-postgres-best-practices/SKILL.md`

## Classification

| Area | Status | Decision |
| --- | --- | --- |
| `.agents/skills/supabase/` | Quarantine | Do not auto-load for Ambitions core work. External hosted-provider workflow is not active Ambitions source truth. |
| `.agents/skills/supabase-postgres-best-practices/` | Quarantine / candidate reference | Do not auto-load. May be manually referenced only if a future approved database task exists. |
| `.codex/skills/` source-truth, evidence, build, validation, privacy, accessibility, copy, and scope-control skills | Active operating support | May be used when compatible with `docs/truth/*`, active batch scope, and evidence boundaries. |
| `.codex/skills/` product or implementation builder skills | Candidate | Use only when an active batch explicitly selects them. Do not treat them as shipped behavior. |
| `.codex/skills/README.md` Ambitions 3.0 framing | Historical | Subordinate to `.codex/README.md` and `docs/truth/*`. |
| `.codex/manifests/skills-routing-map.yml` | Candidate / needs reconciliation | Useful routing context, but stale names must be reconciled before relying on it as a complete skill map. |

## Decisions

1. `.agents/skills/supabase*` is restricted from automatic Ambitions use.
2. `.codex/skills` remains operating support where compatible with active truth files.
3. Implementation-builder skills are candidate-only unless selected by an active batch.
4. Historical Ambitions 3.0/4.0/PXOS/SI phrasing inside skill/control-plane material does not override `docs/truth/*`.
5. No skills were deleted, moved, archived, or edited.

## Validation

GitHub accepted creation of this inventory file. No Markdown/link checker, build, test, archive, accessibility, performance, device, TestFlight, or App Store validation was run.

## Next Recommended Step

T03 — reconcile stale skill routing names and stale Ambitions 3.0 framing in `.codex/skills/README.md` and `.codex/manifests/skills-routing-map.yml` without changing app source.
