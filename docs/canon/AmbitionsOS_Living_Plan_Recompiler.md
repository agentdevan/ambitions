# AmbitionsOS Living Plan Recompiler

<!-- markdownlint-disable MD013 -->

Status: Future source truth. No runtime recompiler implementation is claimed.

## Mutation Permission Defaults

- Source state may update automatically.
- Suggestions may recalculate automatically.
- Commitments never move without user review.
- Privacy-sensitive notifications are off unless user enables them.

Every plan has permissions for `auto_update_source_state`, `auto_recalculate_suggestions`, `auto_move_commitments`, `notify_on_major_source_change`, `privacy_sensitive_notifications`, `sync_allowed`, `archive_allowed`, `source_refresh_allowed`, and `professional_boundary_review_required`.

## Blast Radius Index

The local dependency index tracks dependencies between plans, paths, milestones, source claims, requirements, scheduled commitments, receipts, user facts, jurisdiction, pack versions, privacy state, proof state, goal seriousness, life context, availability, and capacity.

## Impact Levels

| Level | Meaning | Required handling |
| --- | --- | --- |
| 0 | No user impact | Silent metadata update only. |
| 1 | Source refreshed | Passive receipt. |
| 2 | Suggestion changed | Review suggested. |
| 3 | Requirement/timeline changed | Review required. |
| 4 | Commitment affected | Explicit approval required. |
| 5 | Legal/safety/professional boundary changed | Stop and verify. |

## Receipts

Major inference, route, source, activation, mutation, and refusal events should create receipts that show what Ambitions understood, assumed, source-backed, stale, user-confirmed, unverified, changed, why the plan changed, what requires approval, what cannot be claimed, privacy state, undo availability, source freshness, and professional boundary.

## Non-Negotiable Boundary

No silent commitment mutation. Recompiled plans may suggest changes locally, but user commitments move only after explicit user approval.
