# Fixture Contract

Family: `today-flagship/preparing-for-baby/still-counts/v1`

## Stable identities

- Step: `step.nursery-ready-for-crib`
- Goal: `goal.welcome-baby-home`
- revealed Start Here: `step.send-launch-brief`
- Receipt: `receipt.step.nursery-ready-for-crib.still-counts`
- History: `history.step.nursery-ready-for-crib`
- return anchor: `today.settled.step.nursery-ready-for-crib`
- recovery continue: `recovery.continue-saved-progress`
- recovery defer: `recovery.keep-step`

## Accepted narrative

- Present truth: `The corner is cleared and the paint sample is chosen.`
- Proposed/settled truth: `I primed the wall and tested the new color.`
- Consequence: the Step leaves Start Here, remains visible in Today, updates
  `Welcome our baby home`, and records local History.
- Nursery availability: now, before the 2:00 PM handoff.
- Fixed handoff: `Send the launch brief`, 2:00 PM.
- Optional open lane: 3:30 PM where the supporting state requires it.
- Protected family time: 5:30 PM.
- Open time: after 6:30 PM.

## State family

Initial, focused, reviewing, saving, failed settlement, settled, returned,
interrupted, recovery review, cancelled unchanged, offline, stale external
context, blocked consequence, conflict transfer, and exact inverse available
are deterministic fixture states. Offline retains the source-supported local
Still counts closure while separating external context. Conflict transfer does
not move or edit chronology in Today. Only the exact inverse variant exposes
Undo.

## Adapter boundary

The eventual runtime adapter must be able to create equivalent immutable
snapshots without changing view semantics. No fixture owns durable mutation,
persistence, runtime latency, scheduling, network, or product-decision logic.
