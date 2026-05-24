# IOS26 Momentum Reflow Contract Fixtures

Status: contract fixture catalog; not implementation proof
Batch: IOS26-MOMENTUM-REFLOW-RUNTIME-WIRING-ADDENDUM-01

## Purpose
Define the minimum contract fixtures for Momentum Reflow / Step Time Reallocation. These fixtures must become deterministic tests in the owning T04F, T04H, T04J, and T04K implementation batches before any Green runtime claim.

## Scenario A - Creative momentum over planned workout

Setup: Workout Step planned at 6 PM. Music Step is recently active with proof/session context.

Action: User chooses "Use this time elsewhere" from the workout Step or "Ride momentum" from the music Step, reallocates the workout block to music, and chooses an explicit disposition for the workout Step.

Expected contract:

- Fitness GoalThread remains active and coherent.
- Music GoalThread updates.
- Music Step gains proof opportunity.
- Time / LifeShape Field shows the reassigned block.
- Receipt links original Step, destination Step, scheduled block, disposition, and impact.
- Replay trace restores the same effect.
- StepReallocationEvent feeds runtime source adapters.
- PersonalRuntimeLearningSignal records creative momentum preference.
- Future Start Here candidate ranking considers the local momentum preference.

## Scenario B - High-pressure displaced deadline

Setup: Workout Step has high deadline pressure or deadline-protecting context.

Action: User attempts to reallocate the workout block to an active/recent Step.

Expected contract:

- Ambitions shows deadline impact before approval.
- User can keep deadline or adjust timeline explicitly.
- Reallocation proceeds only after approval.
- Displaced Step pressure remains visible.
- Receipt records deadlinePolicy and pressureImpact.
- Future recommendations preserve the displaced goal's deadline pressure.

## Scenario C - Protected, health-related, or sensitive original Step

Setup: Original Step is protected, health-related, or sensitive.

Action: User attempts Momentum Reflow.

Expected contract:

- Ambitions requires review.
- Protected time is not consumed silently.
- The system does not infer medical advice.
- User-facing copy stays non-shaming and non-clinical.
- Receipt records review and sensitivity boundaries.
- Learning signal is bounded and inspectable.

## Scenario D - User resets learned momentum preference

Setup: A momentum_reflow PersonalRuntimeLearningSignal exists and affects future candidate ranking.

Action: User resets or disables the learned momentum preference in You / What Ambitions knows.

Expected contract:

- Signal confidenceState becomes reset or disabled.
- Future recommendations stop using that signal.
- Reset/delete route is recorded.
- Receipt/replay remain truthful about historical decisions without reapplying disabled learning.

## Scenario E - Replay after relaunch

Setup: Completed Momentum Reflow decision has receipt, replay trace, source event, and learning signal.

Action: Relaunch and replay from the same source state.

Expected contract:

- Same reflow receipt is restored.
- Same recommendation impact is restored.
- Future ranking effect matches the pre-relaunch state unless source state changed.
- No schedule mutation occurs silently during replay.

## Scenario F - Export/delete learning signal and source

Setup: Momentum Reflow source event, receipt, replay trace, and learning signal exist.

Action: User exports or deletes according to data-control choice.

Expected contract:

- Export includes the learning signal and related source when selected.
- Delete removes or tombstones the learning signal and related source according to user choice.
- Future recommendations stop using deleted learning.
- Receipt and replay behavior respect the user's data-control choice.

## Green gate
Momentum Reflow cannot close Green until these fixtures are represented as deterministic tests or contract harness cases, the runtime learning signal affects future Private Life Runtime recommendation ranking, and the signal is inspectable/resettable/deletable in You / What Ambitions knows.

## Non-claims
This fixture catalog does not prove implementation, tests, accessibility, privacy approval, performance, release readiness, TestFlight readiness, or App Store readiness.
