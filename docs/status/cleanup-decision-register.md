# Cleanup Decision Register

Status: Green through T07c-closeout provider skill deletion state  
Date: 2026-05-09

## Authority

Active repo authority starts in `docs/truth/README.md`. Historical cleanup policy is `docs/truth/HISTORICAL_POLICY.md`. If this register conflicts with `docs/truth/*`, the truth files win.

Phase 11 reconciliation note, 2026-05-10: this register remains supporting
cleanup context. For current repo map and stale/archive decisions, inspect
`.codex/REPO_INVENTORY.md` and
`docs/status/archive-and-stale-material-ledger.md` after `docs/truth/*`.

## Scope

Cleanup classification/status only. No Swift source changes, app implementation changes, app feature work, build/test/device validation, or release/readiness claims.

## Classification Legend

- Active: current authority or current source/proof owner.
- Supporting: useful operating, implementation, or traceability material that does not override truth files.
- Historical: retained for traceability, not current authority.
- Quarantine: retained but blocked from default use because it can cause drift.
- Deleted from active path: removed from active repo path; do not recreate without explicit approval.
- Deletion-candidate: candidate for a later approved extract/link-check/delete pass.

## Active

| Area | Decision | Reason |
| --- | --- | --- |
| `docs/truth/` | Active | Current authority layer for product/design, implementation/source, release/proof, Codex process, and historical policy. |
| `README.md`, `docs/README.md`, `AGENTS.md` | Active front doors | Route through `docs/truth/*` first. |
| `docs/status/current-implementation-map.md` | Active supporting implementation map | Evidence-based implementation posture. |
| `docs/status/release-evidence-packet.md` | Active supporting release/proof posture | Release and validation non-claim boundary. |
| `docs/native-build-and-release.md` | Active supporting validation workflow | Local VM/Mac validation procedure. |
| live source, tests, `project.yml`, `Package.swift`, scripts, resources, entitlements, privacy manifest | Active implementation/proof surfaces | Do not classify for cleanup in docs-only passes. |

## Supporting

| Area | Decision | Rule |
| --- | --- | --- |
| `docs/AmbitionsCanon/` | Supporting product/design canon | Use only where compatible with `docs/truth/*`. |
| `docs/codex/` | Supporting Codex process material | Operating support only; not product source truth or release proof. |
| `.codex/README.md` | Supporting Codex entry | Truth-first routing point. |
| `.codex/manifests/skills-routing-map.yml` | Supporting route map | Routing support; truth files win conflicts. |
| `.codex/skills/` | Supporting operating skill library | Active only as scoped support; builder skills remain candidate until selected by active batch. |
| `.codex/checklists/`, `.codex/operations/`, `.codex/playbooks/`, `.codex/templates/`, `.codex/validation/` | Supporting control-plane material | Keep for now; consolidate later if duplicate or stale. |
| Native subfolder `AGENTS.md` files | Supporting local contributor guidance | Must remain subordinate to root `AGENTS.md` and `docs/truth/*`. |

## Historical

| Area | Decision | Rule |
| --- | --- | --- |
| `docs/canon/` old Ambitions 2.0 / 3.0 / 4.0 / PXOS / ACUI / SI material | Historical | Mine only for compatible durable decisions; not active authority. |
| `docs/audits/` | Historical/supporting evidence | Use for traceability, not current proof unless tied to current commit/logs. |
| `docs/handoff/` | Historical/supporting handoff trail | Use for traceability; extract durable decisions before archive/delete. |
| old batch-train reports and closeouts | Historical/process history | Batch Green does not prove current source or release readiness. |
| one-off prompts and old implementation plans | Historical | Candidate for extract-then-delete if no durable current value remains. |

## Deleted From Active Paths

| Area | Decision | Reason |
| --- | --- | --- |
| `.agents/skills/supabase/` | Deleted from active skills path | Hosted provider workflow is not active Ambitions core architecture. Do not recreate without explicit approval. |
| `.agents/skills/supabase-postgres-best-practices/` | Deleted from active skills path | External database/provider reference is not active Ambitions architecture. Do not recreate without explicit approval. |

## Quarantine

| Area | Decision | Reason |
| --- | --- | --- |
| provider/backend/cloud assumption docs | Quarantine | Must not imply active user-data backend, account sync, or provider architecture. |
| old release-readiness/App Store/TestFlight/device-proof reports without current proof | Quarantine | Release claims require current evidence. |
| stale context packs that revive old Plan/Profile/Captures/PXOS/ACUI language | Quarantine until reconciled | Can cause Codex drift. |

## Deletion Candidates — No Deletion Approved Yet

| Area | Candidate Action | Required Before Deletion |
| --- | --- | --- |
| stale tracked-file inventories such as `docs/audits/tracked-files.txt` | Replace with generated/current inventory or archive minimal trace | Confirm no active links depend on it; extract current classification value; record rollback path. |
| obsolete one-off prompts | Extract durable decisions, then delete | Link search, useful-content extraction, owner approval. |
| duplicate closeout reports with no unique current value | Extract final decision, then archive/delete | Confirm no release/proof dependency. |
| duplicate `.codex` checklists/templates that restate truth files | Consolidate then delete duplicates | Map replacement authority and update links. |

## Hard Stops

Do not delete or move production Swift, tests, project config, package manifests, scripts, resources, entitlements, privacy manifests, current proof logs, or active truth files as part of docs cleanup.

Do not delete `.codex` or batch-train material opportunistically. Classify first, extract value, update links, get approval, then perform a dedicated cleanup pass.

## Next Recommended Step

Retire or regenerate stale inventory files such as `docs/audits/tracked-files.txt`, then continue with approved historical prompt/canon archive planning.
