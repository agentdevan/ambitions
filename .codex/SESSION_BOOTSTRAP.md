<!-- markdownlint-disable MD013 -->

# Codex Session Bootstrap

Status: Active current bootstrap source
Date updated: 2026-05-10

## Authority

This file defines how future Codex sessions start, resume, recover, select
model tier, select skills, and avoid stale prompts. It is subordinate to
`docs/truth/*`, `AGENTS.md`, `.codex/OPERATING_SYSTEM.md`, and current repo
evidence.

## Current Start Sequence

1. Run `git status --short --branch`.
2. Record branch and HEAD.
3. Read `docs/truth/README.md`.
4. Read the truth files named by `docs/truth/README.md`.
5. Read `AGENTS.md`.
6. Read `.codex/OPERATING_SYSTEM.md`.
7. Read `.codex/REPO_INVENTORY.md` when it exists.
8. For batch work, read `.codex/GLOBAL_BATCH_TRAIN.md` and
   `.codex/BATCH_TRAIN_REGISTRY.md`.
9. For skill selection, read `.codex/SKILL_GOVERNANCE.md`.
10. For validation/tooling, read `.codex/TOOLING_AND_VALIDATION.md`.
11. For archive/delete decisions, read `docs/truth/HISTORICAL_POLICY.md` and
    `docs/status/archive-and-stale-material-ledger.md` when it exists.

If required files are missing, record Yellow or Red according to
`.codex/OPERATING_SYSTEM.md`.

## Model-Tier Policy

- Use `gpt-5.5` or stronger for judgment-heavy work.
- Mini is allowed only for bounded mechanical subpasses with explicit source
  truth, allowed paths, and validation.
- Unknown model tier follows Mini-safe restrictions.

Mini is forbidden for:

- destructive archive/delete decisions
- unresolved Yellow/Red decisions
- release, device, accessibility, performance, legal/privacy, App Store, or
  TestFlight claims
- source-truth conflicts
- architecture decisions
- source mutation decisions
- provider/backend/cloud activation
- dependency, signing, entitlement, hosted CI, or generated-project decisions

## Skill Selection Policy

- Auto-load only skills classified as active operating support by
  `.codex/SKILL_GOVERNANCE.md`.
- Candidate skills require explicit batch selection.
- Historical/deprecated skills may be read for context but must not govern
  active work.
- Deleted provider skills must not be recreated:
  `.agents/skills/supabase/` and
  `.agents/skills/supabase-postgres-best-practices/`.

## Resume Prompt Template

```text
Resume Ambitions from current repo evidence only.

Start by running git status, recording branch and HEAD, then reading:
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
AGENTS.md
.codex/OPERATING_SYSTEM.md
.codex/REPO_INVENTORY.md
.codex/GLOBAL_BATCH_TRAIN.md when batch work is requested
.codex/SKILL_GOVERNANCE.md when skills are selected
.codex/TOOLING_AND_VALIDATION.md when tools are run

Do not use Ambitions 3.0/4.0/PXOS/ACUI/SI/old prompt files as active truth
unless current truth files explicitly route there. Do not make release,
device, accessibility, performance, legal/privacy, hosted CI, App Store, or
TestFlight claims without current raw evidence. Close with Green/Yellow/Red,
validation run, validation not run, hard claims not made, and next exact
prompt.
```

## Old Prompt Policy

- Old copy/paste prompts are historical or supporting unless refreshed through
  this bootstrap.
- Old resume prompts must not be used as-is if they skip `docs/truth/*`.
- `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`, `RESUME_MINI`, and `RESUME_SENIOR`
  remain supporting aliases but are subordinate to this file and truth docs.
- Old Ambitions 3.0 master prompts are not active product truth.

## Recovery Policy

Recover from repo state, not chat memory:

1. Check `git status --short --branch`.
2. Record branch and HEAD.
3. Inspect active state:
   `.codex/state/active-batch.yml`,
   `.codex/reports/current-batch-train-state.md`, and
   `.codex/reports/current-run-state.md`.
4. Inspect the latest final/phase report.
5. Run claim scan on candidate changed files.
6. Stop if truth files are missing or conflicts cannot be resolved from repo
   evidence.
7. Continue only when the allowed paths and validation are explicit.

## Current Phase Resume Map

| If resuming... | Inspect first |
| --- | --- |
| Repo-control-plane cleanup | `docs/status/repo-control-plane-cleanup-final-report.md` |
| Batch work | `.codex/GLOBAL_BATCH_TRAIN.md` |
| Skill work | `.codex/SKILL_GOVERNANCE.md` |
| Tooling/proof work | `.codex/TOOLING_AND_VALIDATION.md` |
| Archive/delete work | `docs/status/archive-and-stale-material-ledger.md` |
| Repo question answering | `.codex/REPO_INVENTORY.md` |

## Phase 7 Gate Result

Phase 7 result: Green.

EFC applicability: invoked for Codex governance and continuation proof. This
file does not claim app implementation, build/test success, release readiness,
real-hardware validation, accessibility conformance, performance proof,
legal/privacy approval, hosted CI proof, App Store readiness, or TestFlight
readiness.

Resolved notes:

- Older prompt/resume docs are classified as historical/supporting in the stale
  ledger and retained because inbound references remain.
- `.codex/REPO_INVENTORY.md` exists.

## Release Evidence Firewall

Every resumed session must preserve the no-claim boundary: local validation is
local only; docs-only plans, batch closeouts, inventory files, and tool maps do
not prove release status, real-hardware validation, public accessibility
conformance, performance, legal/privacy signoff, hosted CI, TestFlight, App
Store submission, backend/provider activation, or implementation completeness.
