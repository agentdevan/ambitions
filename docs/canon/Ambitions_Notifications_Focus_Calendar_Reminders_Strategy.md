# Ambitions Notifications / Focus / Calendar / Reminders Strategy
<!-- markdownlint-disable MD013 -->

Status: Active PFC19 platform strategy; not implementation approval
Date: 2026-05-05

## Purpose

This strategy defines Ambitions boundaries for notifications, system Focus
surfaces, Calendar, Reminders, EventKit, permission copy, and fallback behavior.

It does not implement or approve new notification, Focus Filter, Calendar,
Reminders, EventKit, permission prompt, entitlement, signing, route, persistence,
schema, workflow, release, App Store, or legal/privacy behavior.

## Current Repo Reality

Current source includes:

- `Native/Ambitions/Notifications/LocalNotificationFoundation.swift`
- `Native/Ambitions/Notifications/NotificationRuntime.swift`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- `Native/Ambitions/Features/Plan/PlanCalendarAwarenessSupport.swift`
- focused notification, EventKit, Calendar/Reminders action, and payload tests

Current behavior proves source/test posture only:

- local notification categories include open, snooze, and done actions;
- notification scheduling reads the privacy-safe external snapshot;
- notification payloads route back through canonical app routes;
- notification authorization is requested only through explicit opt-in API;
- Today does not request Calendar permission or write calendar blocks;
- Plan owns calendar-aware planning copy and Calendar access posture;
- EventKit services support reminders, calendar events, conflict reads, and
  Plan-owned derived busy-window reads behind authorization state.

Current evidence does not prove physical notification delivery, Focus Filter
behavior, real Calendar/Reminders device behavior, signed-archive behavior, App
Store review posture, legal/privacy signoff, public accessibility conformance,
or release readiness.

## Integration Decision Record

| Integration | Launch posture | Owner | Decision |
| --- | --- | --- | --- |
| Local notifications | Conditional | Today / You / Notifications | Allow only sparse, privacy-safe next-step or ritual cues after explicit opt-in |
| Notification actions | Conditional | Notifications / command pipeline | Open app by default; mutation actions require confirmation before receipt |
| System Focus | Deferred | You / Plan / Accessibility | No Focus Filter implementation by default |
| Calendar read | Conditional | Plan | Allow only after explicit Plan action |
| Calendar write | Conditional | Plan | Allow only after explicit user confirmation |
| Reminders write | Conditional | Plan / Goals / Today owner proof | Allow only after explicit user action and permission |
| Calendar-derived memory | Deferred / confirmation required | You / Trust | Calendar-derived patterns require confirmation before becoming memory |

## Notification Rules

Notifications may be considered only when all are true:

- the user has chosen notification value;
- authorization is available;
- the content is sparse and privacy-safe;
- the notification has a clear app route;
- the notification can be removed or replaced when no current step exists;
- the copy is operational, calm, and specific;
- sensitive details are hidden by default.

Notifications must not:

- ask for permission during onboarding;
- nag, shame, or pressure the user;
- reveal private goal, step, memory, receipt, calendar, or capture details by
  default;
- become an analytics or status surface;
- silently complete, reschedule, recover, delete, or mutate user work;
- claim delivery reliability without device proof.

## Notification Permission Copy

Approved permission posture:

- "Ambitions can remind you about the next step you chose."
- "Details stay private until you open Ambitions."
- "You can turn this off anytime."
- "Plan and Today still work without notifications."

Rejected permission posture:

- permission before first value;
- shame, urgency, or pressure language;
- language implying Ambitions watches the user;
- language implying delivery or timing is guaranteed.

## Notification Action Rules

Allowed future actions:

- Open Today;
- Not now;
- open the app to close the loop;
- open the app to adjust Plan;
- open the app to review a recovery path.

Not allowed without a later proof batch:

- direct external completion;
- direct external calendar write;
- direct external reminder write;
- direct external deletion;
- direct external placement;
- private-detail preview.

## Focus Surface Rules

No launch Focus Filter implementation is approved by default.

Future Focus work may be considered only for:

- accessibility focus behavior inside the app;
- user-selected quiet emphasis;
- app-opening routes that preserve user control;
- Plan/You-owned control over interruption posture.

System Focus integration must not:

- force a device Focus mode;
- change notification delivery without explicit user control;
- mutate work because the device mode changed;
- infer sensitive life context from Focus state;
- become hidden navigation.

## Calendar Rules

Calendar belongs to Plan.

Calendar read may happen only after:

- the user takes an explicit Plan action such as "Make Plan calendar-aware" or
  "Find real open windows";
- permission is available;
- Ambitions reads derived busy time locally rather than exposing raw event
  titles broadly;
- Plan remains useful when permission is denied or unavailable.

Calendar write may happen only after:

- the user confirms the specific block;
- the block has a concrete time;
- permission can write;
- a receipt can explain what changed;
- undo/review posture is clear where supported.

Calendar must not:

- request permission from Today, Capture, Goals, You, onboarding, or ambient
  surfaces;
- read raw event titles into broad app surfaces;
- write blocks silently;
- clone the Calendar app;
- claim replacement or reliability without proof.

## Calendar Permission Copy

Approved read-copy posture:

- "Plan works without access."
- "With your confirmation, Plan can read derived busy time locally to find real
  open windows."
- "Calendar access is unavailable, so Plan uses Ambitions data and baseline
  windows."

Approved write-copy posture:

- "Create this confirmed Plan block in Calendar."
- "Calendar write is available."
- "Plan can write confirmed blocks, but it cannot read availability until read
  access is granted."

Rejected posture:

- permission before a Plan action;
- claiming Ambitions sees or uses all events;
- copying raw event titles into external surfaces;
- automatic calendar repair.

## Reminders Rules

Reminders may be considered only for explicit user-selected reminders tied to a
specific step or Plan block.

Reminders must:

- ask permission only when the user requests a reminder;
- use the selected step title and minimal notes;
- preserve local-first receipt posture;
- degrade safely when no default list exists or authorization is denied.

Reminders must not:

- mirror every step;
- create reminders automatically from recommendations;
- expose private goal context in notification previews by default;
- become a replacement for Ambitions proof or receipts.

## Privacy Boundary

Required:

- sensitive details hidden in notifications by default;
- raw calendar titles stay out of broad app and external-surface copy;
- Calendar-derived busy time is summarized for planning decisions;
- Calendar-derived memory requires confirmation;
- notification and EventKit payloads stay sparse;
- external actions route back into Ambitions for review.

## Accessibility / Reduced Motion Boundary

Future proof must include:

- notification content and action labels that make sense with VoiceOver;
- privacy-safe spoken text;
- Dynamic Type review for in-app permission and confirmation surfaces;
- non-color meaning for permission, denied, unavailable, and stale states;
- Reduce Motion-safe confirmation and receipt presentation.

## Performance / Battery Boundary

Future implementation must prove:

- no high-frequency notification refresh loop;
- no broad background calendar scan;
- bounded EventKit fetch windows;
- no heavy computation during notification handling;
- no network dependency for launch-scope integrations;
- safe failure when authorization, default lists, or writable calendars are
  unavailable.

## Required PFC20 Proof Before Implementation Claim

PFC20 or any later implementation batch must produce:

- focused tests for notification authorization, scheduling, replacement,
  unavailable state, and payload parsing;
- focused tests for Calendar read and write permission boundaries;
- focused tests for Reminders permission and default-list fallback;
- proof that Today does not request Calendar access;
- proof that Plan owns Calendar permission copy;
- privacy/redaction proof for notification text, action labels, EventKit notes,
  and accessibility text;
- rendered proof or operator checklist for notification and permission surfaces;
- physical-device proof or explicit human/device proof stop for notification
  delivery and platform permission sheets;
- no-claim boundary for App Store, TestFlight, release, physical-device,
  legal/privacy, and public accessibility claims.

## Launch Decision

PFC19 strategy decision:

- Allowed future launch candidate set: sparse next-step or ritual notifications,
  Plan-owned Calendar read, confirmed Calendar write, and explicit Reminders
  creation.
- Deferred: Focus Filter implementation and Calendar-derived memory.
- Not authorized by default: permission during onboarding, hidden mutation,
  broad notification surface, automatic Calendar/Reminders repair, or raw event
  detail exposure.

If any integration cannot meet privacy, permission, accessibility, performance,
and device proof gates later, the safe launch decision is to defer that
integration and keep the app fully useful without it.
