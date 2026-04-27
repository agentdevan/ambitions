# Ambitions Free Workflow Operating System

This document is the free, non-agent, non-GitHub-Actions operating layer for building Ambitions with Codex and local validation.

It is not a product canon file, roadmap file, or replacement for the batch registry. It exists to keep the workflow clean, repeatable, and low-cost while the repo, roadmap, and implementation move quickly.

## Non-overlap contract

Use the existing repo truth instead of creating duplicate authorities:

| Need | Use |
| --- | --- |
| Active / queued / complete batch status | `docs/codex/BATCH_REGISTRY.md` |
| Read order and precedence | `docs/codex/CONTEXT_INDEX.md` |
| Codex behavior standards | `docs/codex/MASTER_CODEX_SYSTEM.md` |
| Codex execution rules and summary format | `docs/codex/Ambitions_2_0_Codex_Execution_Guide.md` |
| Product / visual / systems canon | `docs/canon/Ambitions_2_0_*.md` |
| Decisions | `docs/canon/Ambitions_2_0_Decision_Log.md` |
| Manual visual review | `docs/review/VISUAL_REVIEW_CHECKLIST.md` |
| Real testing friction | `docs/review/FRICTION_LOG.md` |

Do not create a second roadmap, second registry, second decision log, or second master product spec.

## Core operating principle

One active batch. One source-of-truth status file. One validation pass. One handoff. Then the next batch.

New ideas do not interrupt the active batch. Put them in the owning future batch, the idea bank if one exists, or the friction log if they were discovered during actual use.

## Batch lifecycle

Every batch must move through this lifecycle:

1. **Preflight** — read the required context and inspect the current implementation.
2. **Plan** — propose the smallest integrated change set.
3. **Implement** — change only files needed for the active batch.
4. **Validate** — run free local checks and targeted tests.
5. **Visual / UX review** — use the manual visual checklist for UI work.
6. **Docs sync** — update only the docs that objectively changed.
7. **Stale-reference audit** — search for outdated batch status, renamed surfaces, and superseded claims.
8. **Completion summary** — report changed files, validation, risks, and follow-ups.
9. **Human review** — do not move to the next batch until the summary is accepted.
10. **Next prompt** — generate the next implementation prompt only after wrap-up is complete.

A batch is not done just because code compiles. A batch is done only when implementation, validation, registry/doc truth, and handoff are aligned.

## Batch acceptance gate

A batch can be marked complete only when each relevant item is satisfied or explicitly documented as blocked:

- [ ] The active batch scope is clear and matches `BATCH_REGISTRY.md`.
- [ ] No unrelated future-batch work was implemented.
- [ ] The app builds locally or the exact build blocker is documented.
- [ ] Relevant unit tests passed or the exact failing tests are documented.
- [ ] UI tests passed when navigation, shell, or critical flows changed.
- [ ] Manual visual review was completed for visible UI changes or explicitly deferred.
- [ ] `BATCH_REGISTRY.md` status is updated only after validation or explicit user instruction.
- [ ] `CONTEXT_INDEX.md`, execution guide, and master Codex system do not contain stale active-batch references.
- [ ] No duplicate engines, duplicate canon docs, or parallel source-of-truth files were introduced.
- [ ] Completion summary lists files changed, validation performed, unverified claims, risks, and follow-ups.

## Free validation routine

Prefer local validation over paid automation. Before and after meaningful changes, run the cheapest relevant checks.

### Repo status

```bash
git status --short
git log --oneline -10
```

### Stale batch/status references

Adjust the batch numbers to the current registry state before running.

```bash
grep -R "Batch 86\|Batch 87\|Batch 88\|next queued\|next uncompleted\|Current execution status" docs AGENTS.md MASTER_PRODUCT_SPEC.md -n
```

### Xcode project generation

```bash
xcodegen generate
```

### Native build

Use the current known-good simulator from recent validation summaries when possible.

```bash
xcodebuild \
  -scheme Ambitions \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

### Targeted tests

Run focused tests for the batch-owned surface or domain first, then broaden.

```bash
xcodebuild \
  -scheme Ambitions \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test
```

If the available simulator name changes, document the actual destination used.

## Codex prompt modes

Use one of these modes in every prompt. Do not blend them unless explicitly necessary.

### Mode: Plan

Purpose: inspect and produce a scoped implementation plan.

Required instruction:

```text
MODE: PLAN
Do not modify files. Inspect the repo, identify the smallest safe implementation path, list files likely to change, call out risks, and stop before coding.
```

### Mode: Implement

Purpose: execute the active batch.

Required instruction:

```text
MODE: IMPLEMENT
Work only on the active batch from BATCH_REGISTRY.md. Do not implement future-batch work. After changes, run relevant free local validation and produce the required completion summary.
```

### Mode: Review

Purpose: verify a completion summary or changed state.

Required instruction:

```text
MODE: REVIEW
Do not change files. Audit whether the batch is actually complete, whether docs and registry truth are synchronized, whether validation evidence is adequate, and what must be fixed before wrap-up.
```

### Mode: Wrap-up

Purpose: finalize status/docs after human approval.

Required instruction:

```text
MODE: WRAP-UP
Only update objectively stale status, registry, changelog, and execution docs. Do not add features. Run a stale-reference audit and report remaining drift.
```

## Required completion summary

Codex must return this shape after implementation or wrap-up:

```markdown
# Completion Summary

## Batch
Batch XX — Name

## Scope
What was supposed to change.

## Files changed
- ...

## Implementation summary
- ...

## Validation performed
- Command:
- Result:

## Visual / UX review
- Completed / Not applicable / Deferred with reason

## Docs and registry sync
- ...

## Not verified
- ...

## Risks
- ...

## Follow-ups
- ...

## Completion claim
Complete / Not complete / Blocked
```

## Roadmap reconciliation cadence

After every 5-10 batches, run a docs-only reconciliation pass.

The reconciliation pass should:

1. Confirm completed, active, queued, and future batches from `BATCH_REGISTRY.md`.
2. Search for stale status lines across `docs/`, `AGENTS.md`, and `MASTER_PRODUCT_SPEC.md`.
3. Identify features documented as planned that are now implemented.
4. Identify implemented surfaces still described as unbuilt.
5. Identify duplicate concepts or names introduced by recent batches.
6. Update only objectively stale execution docs.
7. Produce a short drift report.
8. Avoid new product features.

## Idea containment rule

Ambitions needs invention, but active implementation needs containment.

When a new idea appears during a batch:

1. If it is required for the active batch to work, implement the smallest safe version.
2. If it improves the product but is not required, document it as a follow-up.
3. If it changes roadmap scope, place it into the owning future batch or canon planning doc only after explicit user approval.
4. If it came from hands-on testing friction, add it to `docs/review/FRICTION_LOG.md`.

## Manual review before accepting Codex work

Before moving to the next batch, ask:

- Does the implemented change match the active batch, not a future batch?
- Does the top-level app remain calm and minimal?
- Is the next action visually obvious?
- Does the work preserve goal -> plan -> task -> proof clarity?
- Did Codex update docs because truth changed, or because it wanted to sound complete?
- Are validation claims backed by commands and results?
- Are there stale references to an older active batch?

## Anti-cost rule

Do not add paid infrastructure unless explicitly authorized.

Avoid by default:

- GitHub Actions workflows that may consume paid minutes.
- Scheduled agents.
- Paid cloud runners.
- External paid QA or visual regression services.
- New SaaS dependencies for project management.

Prefer:

- local Xcode validation,
- local grep/search audits,
- manual visual review,
- focused docs,
- repo-native Markdown checklists,
- explicit Codex prompt modes.

## Final workflow standard

The repo should always be able to answer:

1. What batch is next?
2. What is already complete?
3. What source of truth controls this decision?
4. What changed?
5. What was validated?
6. What remains risky or unverified?
7. What should Codex do next?

If the answer requires reading five conflicting docs, the workflow has drifted and needs a reconciliation pass before feature work continues.
