# Capture Runtime Gauntlet

Batch: `IOS26-T04D-B06`
Status: GREEN
Scenario count: 153
Category count: 17
Green scenarios: 54
Yellow scenarios: 99
Red scenarios: 0

## Summary
- Every capture was preserved.
- Useful captures were factored or held for review.
- No weak match was forced.
- No silent scheduled commit was made.
- No sensitive fact was silently used.
- Every material decision had a receipt.
- Replay was deterministic.
- Future context remained queryable in the local You-visible projection.
- No cloud or LLM dependency was introduced.

## Failing Scenarios
- scenario.facility_access.5: Facility access should factor to facility access.
- scenario.facility_access.5: Facility access should surface the facility-access future context.
- scenario.facility_access.6: Facility access should factor to facility access.
- scenario.facility_access.6: Facility access should surface the facility-access future context.
- scenario.facility_access.8: Facility access should factor to facility access.
- scenario.facility_access.8: Facility access should surface the facility-access future context.
- scenario.blocker.4: Blocker context should factor to blocker.
- scenario.blocker.4: Blocker context should surface access-constraint future context.
- scenario.blocker.4: Blocker context should remain review-aware.
- scenario.blocker.5: Blocker context should factor to blocker.
- scenario.blocker.5: Blocker context should surface access-constraint future context.
- scenario.blocker.5: Blocker context should remain review-aware.
- scenario.blocker.6: Blocker context should factor to blocker.
- scenario.blocker.6: Blocker context should surface access-constraint future context.
- scenario.blocker.6: Blocker context should remain review-aware.
- scenario.blocker.8: Blocker context should factor to blocker.
- scenario.blocker.8: Blocker context should surface access-constraint future context.
- scenario.blocker.8: Blocker context should remain review-aware.
- scenario.recurring_commitment.5: Learning-flavored recurring commitments should surface skill context.
- scenario.plan_conflict.1: Plan conflict should preserve medium time confidence when recurrence is the main issue.
- scenario.plan_conflict.2: Plan conflict should preserve medium time confidence when recurrence is the main issue.
- scenario.plan_conflict.3: Plan conflict should preserve medium time confidence when recurrence is the main issue.
- scenario.plan_conflict.4: Plan conflict should preserve medium time confidence when recurrence is the main issue.
- scenario.plan_conflict.5: Plan conflict should preserve medium time confidence when recurrence is the main issue.
- scenario.plan_conflict.6: Plan conflict should preserve medium time confidence when recurrence is the main issue.
- scenario.plan_conflict.7: Plan conflict should preserve medium time confidence when recurrence is the main issue.
- scenario.plan_conflict.8: Plan conflict should preserve medium time confidence when recurrence is the main issue.
- scenario.plan_conflict.9: Plan conflict should preserve medium time confidence when recurrence is the main issue.

## Category Coverage
- ambiguous_goal_relevance: 9
- ambiguous_time: 9
- blocker: 9
- equipment_access: 9
- facility_access: 9
- future_useful_context: 9
- high_risk_sensitive: 9
- paused_deleted_context: 9
- plan_conflict: 9
- proof_event: 9
- protected_time_conflict: 9
- recovery_injury: 9
- recurring_commitment: 9
- replay: 9
- scheduled_activity: 9
- social_support: 9
- user_correction: 9