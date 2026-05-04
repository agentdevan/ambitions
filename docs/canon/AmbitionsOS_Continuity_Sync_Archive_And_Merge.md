# AmbitionsOS Continuity Sync Archive And Merge

<!-- markdownlint-disable MD013 -->

Status: Future source truth. No CloudKit entitlement, signing, backend, sync runtime, account, or archive runtime implementation is claimed.

## Continuity Model

The durable model is local database first, user private iCloud / CloudKit for user-owned state where allowed, encrypted local export/import archive, schema migration ladder, conflict review, new-phone restore, and local-only fallback.

## User-Owned Sync Records

Captures, goals, plans, user facts, receipts, preferences, source dependency index, review schedules, handling receipts, user confirmations, and privacy settings may be user-owned sync records when allowed.

## Non-User Sync Data

Static packs, global source graph, caches, temporary suggestions, non-personal manifests, and downloadable pack assets are not synced as user data.

## Sync States

Local only, Sync available, Sync paused, iCloud unavailable, iCloud full, Restoring, Conflict review needed, Archive backup available, Sensitive goal excluded from sync.

## Personal Data Vault And Sensitivity Modes

Goal privacy modes include normal, discreet, private, local-only, no notifications, no widgets, no iCloud sync, encrypted archive only, hidden from summaries, crisis-sensitive, legal-sensitive, medical-sensitive, relationship-sensitive, identity-sensitive, financial-sensitive, and immigration-sensitive.

Sensitive local data must not leak into logs, previews, widgets, screenshots, notifications, or generic receipts.

## Multi-Device Merge Policies

Receipts are append-only. User confirmations are never silently deleted. Source dependencies use union. Note text uses latest edit with history. Goal title uses latest edit with undo. Plan milestones merge if non-conflicting. Scheduled commitments require conflict review. Privacy settings use most restrictive wins. Deleted sensitive item deletion wins with tombstone. Source pack version latest verified wins. Plan mutation permission most restrictive wins. Source-stale state stays stale until refreshed.
