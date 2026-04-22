# Known Flakes

Use this file to avoid rediscovering already-understood instability during batch closeout.

Only list flakes that are:

- reproducible enough to describe
- bounded in impact
- understood well enough to guide the next narrow step
- explicitly accepted, fixed, or still open

## Active Known Flakes

### Today quick-focus combined UI closeout flake

- area: shell / Today closeout proof
- symptom: a combined closeout UI slice can remain timing-sensitive around the Today quick-focus guard even when the user-facing flow is healthy and isolated reruns pass
- affected proof: `testQuickRecoveryAndQuickFocusReturnToTodayWithExplicitReentry`
- likely seam: shell timing / overlay dismissal / reentry coordination rather than planner logic
- current policy: do not treat this as an automatic batch blocker if:
  - isolated reruns pass
  - the normal runtime flow is manually reviewed
  - the batch completion note documents the residual caveat truthfully
- escalation rule: if isolated reruns start failing or the runtime flow regresses, treat it as a real bug and reopen the shell/Today seam narrowly

## Maintenance

When a known flake changes state, update this file with one of:

- fixed
- still active and accepted
- no longer reproducible
- no longer bounded and must be treated as a real blocker
