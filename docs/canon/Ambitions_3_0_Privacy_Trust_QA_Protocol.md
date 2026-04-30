# Ambitions 3.0 — Privacy Trust QA Protocol

Status: Active privacy/trust QA protocol

## Triggers

Run for sensitive data, memory, recommendations, personalization, receipts,
external surfaces, export/import, permissions, calendar, notifications, sync,
auth, account, or dependency changes.

## Required Docs

- `Ambitions_3_0_Privacy_Threat_Model.md`
- `Ambitions_3_0_Personalization_Consent_Model.md`
- `Ambitions_3_0_Evidence_Hierarchy.md`
- `Ambitions_3_0_Recommendation_Eligibility_Engine.md`

## Checks

- Local-first posture remains true.
- Consent and correction are visible for sensitive inference.
- External surfaces hide sensitive details by default.
- Calendar writes and destructive actions require confirmation.
- No backend/account/sync claim appears without implementation evidence.

## Stop Conditions

Stop for privacy model changes, sync/auth/account architecture, or sensitive
external-surface changes without human approval.
