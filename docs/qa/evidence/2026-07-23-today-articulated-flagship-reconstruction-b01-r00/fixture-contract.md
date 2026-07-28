# Fixture and state inventory

Family: `today-flagship/preparing-for-baby/still-counts/v1`

Stable identities:

- primary Step: `step.nursery-ready-for-crib`
- parent Goal: `goal.welcome-baby-home`
- revealed Start Here: `step.send-launch-brief`
- Receipt: `receipt.step.nursery-ready-for-crib.still-counts`
- History: `history.step.nursery-ready-for-crib`
- return anchor: `today.settled.step.nursery-ready-for-crib`
- recovery commands: `recovery.continue-saved-progress`, `recovery.keep-step`

State sequence preserved exactly:

`todayInitial → focusedCurrent → reviewingProposal → savingAcceptedTruth → settled → todayReturned`

Degraded sequence preserved exactly:

`focusedCurrent → interrupted → recoveryReview → recoveredContinuation` or
`recoveryReview → interrupted` on safe deferral/dismissal.

Snapshots remain small immutable adapters. Fixture copy is evaluation content,
not canon or production localization. No fixture object owns product policy,
persistence, mutation, runtime timing, or universal Start Here anatomy.

The existing dense, long-content, `ar-SA`, accessibility-size, and Increased
Contrast variants remain the stress inventory. No fixture truth changes merely
to improve layout.
