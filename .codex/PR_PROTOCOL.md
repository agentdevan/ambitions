<!-- markdownlint-disable MD013 -->

# Codex PR Protocol

Status: Active Codex patch/PR discipline  
Date updated: 2026-05-10  
Authority: Subordinate to `docs/truth/*`, `AGENTS.md`, and current repo evidence

This protocol defines how Codex prepares senior-quality patches. It does not
add hosted CI, branch requirements, release claims, or approval to change app
source outside the active scope.

## 1. Patch Intake

Every non-trivial patch must record:

- task type
- goal
- non-goals
- allowed paths
- forbidden paths
- truth files read
- evidence inspected
- validation packs selected
- rollback path
- hard Red triggers

## 2. Scope Rules

Codex must:

- touch the smallest owning seam
- preserve app/source boundaries unless implementation is explicitly scoped
- keep docs-only passes docs-only
- avoid dependency, hosted CI, provider/backend, signing, or entitlement changes
  unless explicitly approved
- avoid broad refactors attached to narrow fixes

Codex must not:

- use `git add .`, `git add -A`, or `git commit -a`
- hide unrelated dirty work
- revert user changes without explicit instruction
- claim implementation or release proof from docs-only work

## 3. Evidence Requirements

Every patch closeout must separate:

- verified
- failed
- not verified
- advisory findings
- human/device/legal follow-up
- non-claims

Evidence must include commands and exit codes where commands ran.

## 4. Validation Requirements

Minimum validation by patch type:

| Patch type | Required validation |
| --- | --- |
| Docs/control-plane | `git diff --check`, forbidden-claim scan, docs QA when safe |
| Script/tooling | self-test or scoped dry run, forbidden-claim scan if docs touched |
| Source implementation | focused build/tests, claim scan, EFC applicability |
| UI/visual | visual proof ledger entry, accessibility/motion gates, focused tests if source changes |
| Performance | selected budget, measurement or explicit not verified |
| Release/proof | release truth, raw evidence packet, claim firewall |

## 5. Screenshot Rules

Screenshots are required when a patch claims:

- visual layout correctness
- visual polish
- no overlap/clipping
- Dynamic Type visual fit
- Reduce Motion visual equivalent
- visual regression repair

Screenshots must be current or explicitly labeled historical/supporting.

## 6. Risk And Rollback

Every patch must state rollback:

- docs-only: revert commit or path-limited revert
- source: revert commit plus test rerun
- script/tooling: disable or revert script, rerun self-test
- archive/delete: restore path from commit/archive and rerun link/reference check

High-risk changes require owner approval before mutation.

## 7. Commit Discipline

- Commit Green phases separately when the user requests phased work.
- Commit accepted Yellow only when safe additions/classification are complete
  and the Yellow reason/retirement condition is recorded.
- Do not commit Red work unless the commit is a safe diagnostic/report required
  by the owner.
- Keep staged paths exact.

## 8. PR / Push Discipline

If asked to push:

- fetch first
- confirm ahead/behind
- stop if remote advanced and reconciliation is unsafe
- push only the requested branch
- report pushed commit SHA

Hosted CI workflows must not be added or activated as part of this protocol.

## 9. PR Description Template

```text
Summary:
- 

Scope:
- 

Validation:
- 

Not run:
- 

Screenshots / visual proof:
- 

Risk:
- 

Rollback:
- 

Non-claims:
- 
```

## 10. Phase 8 Gate Result

Phase 8 result: Green.

Validation:

- docs-only PR protocol artifact
- no hosted CI, workflow, app/source, dependency, or release mutation
- no release/device/accessibility/performance proof claimed

