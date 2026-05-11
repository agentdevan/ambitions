# Proof & Recovery Lifecycle Map — MOAT-ALIGNMENT-01

This map captures the moat-facing lifecycle contracts currently modeled in domain scaffolding.

## Proof Lifecycle

1. Capture arrives as a routeable input (`raw`, `goal`, `proof` etc).
2. Capture routing classifies proof candidates for explicit proof handling.
3. Commitment and Step contexts attach proof references.
4. Closure state can be:
   - `Completed`
   - `Still Counts`
   - `Moved`
   - `Shortened`
   - `Waiting`
   - `Blocked`
   - `Needs Recovery`
   - `Needs Review`
   - `Held`
   - `Paused`
   - `Stalled`
   - `Too Large`
   - `No Longer True`
   - `Ready To Restart`
   - `Not Needed`
5. Proof can be retained when closure is honest and inspectable.

## Recovery Thread Lifecycle

- `RecoveryThread` includes:
  - trigger
  - priorProofRefs
  - whatChanged
  - newSmallestCommitment
  - status
  - receiptID
- Recovery thread status is active when a continuation path should be preserved and recoverable.
- A recoverable thread keeps continuity while reducing re-execution burden.

## Still Counts Behavior

- `Still Counts` is an explicit closure state.
- It is valid for partial progress and preserves continuity without shame language.
- It must preserve proof where available and support a next small continuation plan.

## Receipt Behavior

- Receipt behavior remains modeled elsewhere in the proof/closure stack.
- This phase only guarantees route-level and model-level shape:
  - proof IDs are attachable to commitment/goal thread context,
  - closure states are explicit and inspectable,
  - recommendation trace includes source controls and uncertainty.

## Non-Shaming Language Rules

- Avoid:
  - overdue
  - failed
  - streak broken
  - behind
- Prefer:
  - Reality changed
  - still counts
  - recover this thread
  - restart from the last honest point
