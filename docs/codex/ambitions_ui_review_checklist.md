# Ambitions UI Review Checklist

Status: Active AOR reviewer protocol mirror
Scope: Ambitions Active Runtime UI Reconstruction source-changing UI issues
Authority: Mirrors Linear project document `AOR Reviewer Checklist`; subordinate to `docs/truth/*` and `AGENTS.md`.

This document is process guidance only. It is not implementation proof, visual approval, accessibility proof, release proof, privacy/legal approval, or product completeness proof.

## Required Use

Every source-changing AOR issue after AMB-527 must point the reviewer to:

- Linear project document `AOR Reviewer Checklist`
- `docs/codex/ambitions_ui_review_checklist.md`

Developer Codex may use this checklist to prepare evidence, but the reviewer pass is review-only. Reviewer Codex must not write feature code in the same review pass.

## Reviewer Prompt

```text
You are the reviewer agent for Ambitions Active Runtime UI Reconstruction.
Do not write feature code. Review only.
Check:
1. Did Developer Codex prove active runtime path?
2. Did it delete/demote old root UI?
3. Did it reuse existing primitives?
4. Did it avoid new material systems?
5. Did it avoid root card stacks?
6. Did screenshot silhouette materially change?
7. Does the primary object own the screen?
8. Is the primary action obvious?
9. Are source/trust/receipt compact and reachable?
10. Does Dynamic Type preserve primary action?
11. Does Reduce Motion preserve meaning?
12. Does Increase Contrast reduce atmosphere and strengthen boundaries?
13. Are banned terms absent?
14. Is old UI still reachable?
15. Is final status honest?
Return: Green / Yellow / Red, blockers, exact files/lines to revisit.
```

## Required Output Format

```markdown
Verdict: Green / Yellow / Red
Blocking issues:
Risky files:
Screenshot assessment:
Runtime path assessment:
Deletion proof assessment:
Primitive reuse assessment:
Accessibility assessment:
Required next action:
```

## Green Gate

Green requires all of the following:

- Active runtime path is proven from source.
- Old root UI is deleted, demoted, or explicitly classified as non-runtime support.
- Existing primitives are reused where they fit the product surface.
- No new material system is introduced without explicit scoped authority.
- Root screens avoid generic card-stack or dashboard composition.
- Current screenshots exist and show the intended silhouette change.
- The primary object owns the screen.
- The primary action is obvious.
- Source, trust, and receipt information is compact and reachable.
- Dynamic Type, Reduce Motion, and Increase Contrast considerations are addressed honestly.
- Banned terms and stale canon are absent from active user-facing UI.
- Final status separates verified proof from unverified follow-up.

## Yellow Conditions

Use Yellow when the scoped source change is directionally correct but evidence remains incomplete, including:

- Screenshot proof is partial, stale, or unavailable.
- Human visual review has not happened.
- Accessibility behavior was considered in code but not manually proven.
- Deletion/demotion evidence is source-backed but needs a later cleanup batch.
- The issue is complete only with an explicit follow-up gate.

Yellow must include owner, reason, proof boundary, and next eligible action.

## Red Conditions

Use Red when any of the following occurs:

- Developer marks a visual issue Green without reviewer and human visual review.
- Reviewer edits feature code in the same review pass.
- Review accepts no screenshots as visual Green.
- Active product truth is contradicted.
- Old `Capture` tab, `Pulse`, `Plan`, `Review`, `Profile`, `Calendar`, `Inbox`, or a sixth tab is reintroduced as active top-level IA.
- Motion becomes analytics, XP, score, streak, activity feed, productivity report, or dashboard.
- Time becomes a generic calendar clone, free/busy optimizer, productivity score, or resource-allocation surface.
- Final closeout claims build, test, screenshot, accessibility, performance, privacy/legal, device, TestFlight, App Store, CI, or release proof without current evidence.

## Non-Claims

Reviewer Green is not human visual approval unless a human explicitly provides it. Reviewer Green is not accessibility proof, device proof, performance proof, privacy/legal approval, TestFlight proof, App Store proof, release readiness, or product completeness proof.

Screenshots are visual proof artifacts only. They do not prove accessibility, performance, privacy, release readiness, or real-device behavior.
