---
name: ambitions-unified-frontend-program
description: Use when working on Ambitions frontend status, next-component design, owner review, complete fixture-frontend approval, runtime integration, production cutover, legacy deletion, zero-legacy verification, or release gating.
---

# Ambitions Unified Frontend Program

Use the v2 persistent ledger as program truth and the repository/canon as
product and implementation truth. Never infer completion or authorization from
conversation history, a screenshot, a build, or an earlier program record.

## Start every turn

1. Read `AGENTS.md` and the live canon routed by
   `docs/canon/generated/CODEX_START_HERE.md`.
2. Read the complete ledger at
   `/Users/devan/.codex/output/Ambitions_Maximum_Polish_Program/PROGRAM.json`.
3. Run:

   ```bash
   python3 .agents/skills/ambitions-unified-frontend-program/scripts/program_tracker.py check \
     --ledger /Users/devan/.codex/output/Ambitions_Maximum_Polish_Program/PROGRAM.json \
     --repo /Users/devan/Documents/GitHub/ambitions
   ```

4. Reconcile branch, HEAD, status, canon, accepted evidence, and ledger drift
   before work. Preserve unrelated changes; never clean the worktree to satisfy
   the ledger.
5. Work only on `next_component_id` and the active UFP milestone unless the
   owner explicitly changes the sequence and that decision is recorded.
6. Read [CYCLE.md](references/CYCLE.md) before component or milestone work and
   [LEDGER.md](references/LEDGER.md) before changing program state.

## One frontend, one source

This is the only authoritative frontend program. Native Visual Foundry is its
subordinate fixture-rendering and proof harness. It renders the same canonical
UI as production through synthetic adapters; it neither owns canonical UI nor
acts as a peer program, design authority, or independent component library.

The canonical presentation boundary is:

- `AmbitionsPresentationContracts`: typed presentation, navigation,
  restoration, intent, and result contracts;
- `AmbitionsFlagshipFoundation`: the single design system;
- `AmbitionsFlagshipUI`: canonical views and composition;
- Foundry: synthetic adapters and proof tooling;
- production: runtime-backed adapters to the same contracts and views.

Canonical UI must not import Foundry, production runtime implementations, or a
legacy design-system tree. Foundry and production adapters may differ; their
canonical UI source may not.

## Preserve proof and approval separation

Track these approvals independently and default each to false:

1. `frontend_design`
2. `runtime_integration`
3. `production_cutover`
4. `legacy_deletion`
5. `release`

An owner-approved component direction is not complete-frontend approval.
Complete fixture proof is not runtime proof. Runtime integration is not
cutover, deletion, device proof, or release. Never silently promote one field
because another passed.

Use only these tracker gates:

- `owner-review` for one component;
- `frontend-complete` after UFP-5 and explicit complete-frontend approval;
- `runtime-integration` after the frontend-complete gate and explicit runtime
  integration approval;
- `cutover` after UFP-6 and explicit cutover and legacy-deletion approvals;
- `release` after UFP-7, verified zero legacy, UFP-8, and explicit release
  approval.

## Component work

Retain the maximum-polish component contract: current primary-source research,
baseline audit, internal exploration, five compounding passes, P01-P15,
explicit evidence, one decisive owner-review direction, and an exact proof
ceiling. Later repair can reopen earlier work. Owner decisions are append-only;
rejected and historical directions remain evidence but do not regain authority.

Use the repository `ambitions-native-visual-foundry` skill whenever producing
or calibrating fixture-driven native SwiftUI. Its reporting and proof rules are
nested harness requirements, not a separate lifecycle.

## End every turn

1. Update the ledger after an actual decision, evidence event, gate transition,
   blocker, or live-truth refresh. Do not manufacture state merely to make a
   command pass.
2. Run `check` with the live repository.
3. Run the relevant `gate`; use `--component <id>` only for `owner-review`.
4. Regenerate `STATUS.md` with `render`.
5. Report changed state, exact evidence, proof ceiling, remaining gates, active
   milestone, next component, and repository mutation status.

Never advance an approval without the explicit approval it represents. Never
claim unified frontend completion, zero legacy, production readiness, device
proof, or release readiness from fixture or Simulator evidence.
