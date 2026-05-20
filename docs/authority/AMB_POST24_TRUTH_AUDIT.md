# AMB_POST24_TRUTH_AUDIT

## Scope

Post-24 authority audit for the installation batch.

This file is docs-only. It does not change app behavior, source wiring, or release proof.

## Source-truth precedence

Current precedence is:

1. `docs/truth/*`
2. live source, project, test, script, and proof evidence
3. supporting authority files under `docs/authority/`
4. historical docs, prompts, and batch material

`docs/truth/*` plus live source/test/proof evidence remain the active source-truth stack. Authority registry files only classify and route that truth; they do not override it.

## Classification

| Path | Status | Why |
| --- | --- | --- |
| `docs/truth/` | active | Canonical source-of-truth root |
| `docs/authority/AMB_ACTIVE_SOURCE_TRUTH.md` | supporting | Mirrors active precedence and root IA routing |
| `docs/authority/AMB_ROOT_IA_CANON.md` | supporting | Locks the active root IA and compatibility seam language |
| `docs/authority/AMB_OBSOLETE_AUTHORITY_REGISTER.md` | supporting | Tracks obsolete root-tab references for cleanup and routing |
| `docs/codex/BATCH_REGISTRY.md` | supporting | Queue, dependency, and train control |
| `docs/codex/CONTEXT_INDEX.md` | supporting | Navigation and historical mapping |
| `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md` | supporting | Execution ordering |
| `docs/PROJECT_STATUS.md` | archive-candidate | Informational if present and stale |
| `docs/codex/GLOBAL_*` planning docs | archive-candidate | Historical overlays after this phase |
| `docs/AmbitionsCanon/*` | historical | Historical reference only |
| `prompts/` existing pre-installer prompts | historical | Source of execution context, not active source truth |

## Conflict checks

- `Plan` is compatibility/context only, not active top-level IA.
- `Habits` is not an active root and remains historical/obsolete for root navigation.
- `Insights` is not an active root and remains historical/obsolete for root navigation.
- `Profile` is compatibility/context only and must not be promoted above `You` or `User System Profile`.
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- No active cloud-first, analytics-first, or AI-wrapper claim was found in the active truth stack for this audit boundary.

## Active, supporting, historical, obsolete, archive-candidate, delete-candidate

- Active: `docs/truth/*`, live source, project files, tests, scripts, and current proof.
- Supporting: `docs/authority/*`, `docs/codex/*`, `AGENTS.md`, and other routing or status docs that stay subordinate to active truth.
- Historical: `docs/AmbitionsCanon/*`, older prompts, and older batch or handoff material that only provide traceability.
- Obsolete: root-tab claims for `Plan`, `Habits`, `Insights`, and `Profile` when presented as user-facing destinations.
- Archive-candidate: stale project status or planning overlays that no longer carry active authority.
- Delete-candidate: duplicate or no-longer-useful prompts or reports only after historical value has been extracted and retained where required.

## Known unknowns

- Unproven in this audit: current runtime, build, and test evidence.
- Unproven in this audit: current accessibility proof, performance proof, and release proof.
- Unproven in this audit: whether any adjacent docs outside this boundary still repeat obsolete root-tab language.

## Outcome

**Classification result:** Green for docs-only truth alignment in this batch boundary.

**Proof boundary:** No app behavior changed, and no release or validation claim is made by this file alone.

## Validation notes

- Expected validation for this batch: `python3 scripts/ambitions_validate_authority_drift.py`
- Expected validation for this batch: `python3 scripts/ambitions_validate_prompt_headers.py`
- Follow-up checks after edit: `git diff --check` and `git status --short`

## Rollback

Restore this file if needed:

```bash
git restore -- docs/authority/AMB_POST24_TRUTH_AUDIT.md
```
