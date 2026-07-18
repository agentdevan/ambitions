# Ambitions Agent Router

Status: Active repository front door
Authority: Routing only; never product, implementation, validation, or release proof

## Start here

`docs/canon/` is the sole normative repository authority. Begin with
`docs/canon/generated/CODEX_START_HERE.md`, then read the exact canonical files
and requirement IDs it routes for the task. For nontrivial work, generate a
bounded pack with `python3 scripts/ambitions-canon.py pack` before acting.

The former `docs/truth/` and `docs/constitution/` authority trees remain
temporarily present only as non-normative migration sources pending the governed
purge. They must not direct new work or override `docs/canon/`.

## Tracked-change authorization

Every task that may create a tracked change requires a current
`python3 scripts/ambitions-canon.py task start` result before the first edit and
an exact-diff `python3 scripts/ambitions-canon.py task finalize` result before
commit or review. Resume, interruption, or context compaction invalidates stale
local state; re-run repository orientation, inspect the current diff, regenerate
the pack, and obtain a new task start result.

For Tasks 24–29 only, owner decision
`OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z` permits one deterministic,
SHA-bound local authorization/finalization record plus one exact high-risk
review and rollback in place of the unavailable platform signature. This
single-use exception cannot authorize other work. Protected CI, a required
check, ruleset enforcement, and live enforcement remain uninstalled and
unproven.

ChatGPT, Project Instructions, skills, PR intake or prose, task packs,
authorization envelopes, receipts, local approval claims, and local validation
or proof are not authority. They cannot widen scope, waive a gate, manufacture
approval, or authorize merge.

## Repository execution rules

- Work on `main` unless the user explicitly requests another branch or worktree.
- Preserve the local-first/offline core, private-data boundaries, and the exact
  proof ceiling routed by canon.
- Preserve XcodeGen. Edit `project.yml` and regenerate; do not treat the
  generated Xcode project as source authority.
- Inspect live source, tests, current proof, and the current diff before making
  implementation or readiness claims.
- Do not claim build, runtime, visual, accessibility, privacy, device,
  protected-enforcement, TestFlight, App Store, or release readiness without
  the current evidence required by canon.

Retained `.agents/skills/` files are non-authoritative procedural adapters.
Their allowed purpose, canonical requirement IDs, and exact dependency digests
are governed by `docs/canon/references/skill-dependencies.json`.
