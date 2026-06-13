# R2 Pathing-Data Download Language

Status: Green for AMB-675 / PLOS-047 approved copy-set scope; Yellow for UI implementation, onboarding copy system, runtime download behavior, live R2 account proof, network validation, privacy/legal approval, release readiness, device proof, accessibility proof, and measured performance proof.
Updated: 2026-06-12 America/New_York
Owning issue: AMB-675 / PLOS-047
Parent issue: AMB-612 / PLOS-M04

## Boundary

This artifact defines calm, privacy-safe, screen-reader-friendly copy for future public Source Atlas pathing-data download and refresh behavior.

It does not implement onboarding copy, runtime UI, networking, R2 fetching, cache/quarantine behavior, background refresh, Cloudflare/R2 setup, credential creation, live R2 writes, pack publication, or privacy/legal/release approval.

## Copy Principles

Future product copy should say what matters without exposing internal machinery:

- Keep the top-level line short.
- Use "Source Atlas" only where the user needs the trust context.
- Prefer "source data" or "public source data" over "pathing data" in user-facing text.
- Say "downloads" only for public reference/source material.
- State that private goals, schedule, proof, and life context stay on the device or user-owned iCloud when sync is in scope.
- Avoid marketing language, privacy theater, and vague AI/cloud wording.
- Provide one clear review route when source data is stale, unavailable, or blocked.

## Approved Short Copy

Top-level copy options:

| Context | Approved copy |
|---|---|
| First public source download | Ambitions downloads public source data to help shape goal paths. |
| Routine refresh | Ambitions checks for fresh public source data. |
| Verified current | Source data is current. |
| Stale but usable | Source data is older. Review before relying on it. |
| Source needed | Ambitions needs fresh source data before this can be source-backed. |
| Offline fallback | Using verified local source data for now. |
| Revoked or unsafe | This source is blocked. Review the path before continuing. |
| Privacy boundary | Your goals, schedule, proof, and life context stay private. |
| Drill-down privacy line | Public source data can download; your private life data is not sent to R2. |
| Local-first reassurance | Ambitions works from local state first. |
| Download failed | Source data could not be refreshed. Keep using verified local data or review later. |

## Approved Detail Copy

Use detail copy only after the user opens a trust, source, privacy, or download explanation.

| Context | Approved detail copy |
|---|---|
| What downloads | Ambitions can download public Source Atlas packs: public rules, requirements, source references, and reusable pathing guidance. |
| What does not download | Your goals, captures, schedule, proof, receipts, and personal context are not part of public Source Atlas downloads. |
| Why refresh exists | Fresh source data helps Ambitions avoid stale rules, revoked sources, and outdated pathing guidance. |
| Stale handling | If source data is stale, Ambitions should label it clearly and avoid claiming it is current. |
| Review route | Open source details to review freshness, source state, and fallback behavior. |
| R2 boundary | R2 is a public source mirror, not personal storage. |
| iCloud boundary | If user-owned iCloud sync is enabled in a future scope, that is separate from public Source Atlas downloads. |
| Failure behavior | If a download or verification fails, Ambitions should use verified local source data, ask for review, or block unsafe paths. |

## VoiceOver And Accessibility Copy

Accessible labels should name the state, not the implementation subsystem.

| UI element or state | Accessible label guidance |
|---|---|
| Current source state | Source data current. |
| Stale source state | Source data older. Review recommended. |
| Source-needed state | Fresh source data needed. |
| Privacy boundary | Private goals and schedule stay on this device unless user-owned sync is enabled. |
| Download action | Refresh public source data. |
| Review action | Open source details. |
| Blocked state | Source blocked. Review before continuing. |

## Forbidden Copy

Do not use:

- Cloud learns your life.
- Uploaded for personalization.
- R2 stores your goals.
- Anonymous personalization, unless no private identifiers or context are sent.
- AI downloads your plan.
- We train on your life data.
- Fully privacy approved.
- Source data is always current.
- Best next move.
- Begin Focus.
- Dashboard, admin, debug, or spec wording in user-facing copy.

## Copy State Rules

State rules:

- Use `current` only when freshness, revocation, compatibility, source authority, rollback, and release receipt gates pass.
- Use `older`, `needs review`, `fresh source needed`, or `blocked` when current proof is not available.
- Do not say "safe" when the scoped proof is only freshness or source status.
- Do not say "private" as a broad promise without the specific boundary: private user life data is not sent to R2.
- Do not mention Cloudflare or R2 in top-level copy unless the user opened a technical/privacy detail.

## Non-Claims

This artifact does not implement user-facing UI, onboarding copy system, runtime download behavior, network fetching, cache/quarantine behavior, background refresh, Cloudflare/R2 setup, credential creation, live R2 writes, pack publication, privacy/legal approval, release readiness, device proof, accessibility proof, or measured performance proof.
