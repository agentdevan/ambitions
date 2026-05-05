# Ambitions App Intents / Shortcuts / Spotlight Strategy
<!-- markdownlint-disable MD013 -->

Status: Active PFC17 platform strategy; not implementation approval
Date: 2026-05-05

## Purpose

This strategy defines what Ambitions may expose through App Intents, Shortcuts,
Siri, and Spotlight-style system search surfaces.

It does not implement or approve new App Intent, Shortcut, Siri, Spotlight,
CoreSpotlight, `NSUserActivity`, route, persistence, entitlement, signing, or
external indexing behavior.

## Current Repo Reality

Current source includes:

- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`
- `Native/Ambitions/App/AppIntentLaunchRouter.swift`
- `Native/Ambitions/App/AppExternalRouting.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceContractModels.swift`
- `Native/Ambitions/Support/ExternalSurfaceVerificationChecklist.swift`
- focused App Intent, route, payload, external-surface, and verification tests

Current behavior proves source/test posture only:

- `OpenAmbitionsDestinationIntent` queues a canonical deep link and opens the
  app.
- `CreateAmbitionsCaptureIntent` stores text through the shared external
  creation queue and opens Capture for review.
- `AmbitionsShortcutsProvider` exposes a bounded shortcut set.
- mutation-capable shortcut descriptors require in-app confirmation and
  receipts before mutation is allowed.
- external contracts require privacy-safe labels and shared command-pipeline
  ownership.

Current evidence does not prove real Shortcuts/Siri invocation, device
discovery, Spotlight indexing, CoreSpotlight behavior, signed-archive behavior,
App Store review posture, public accessibility conformance, or release
readiness.

## Allowed Launch Candidate Set

The allowed future launch candidate set is:

| Candidate | Posture | Required boundary |
| --- | --- | --- |
| Capture text | Queues local capture, opens app | Text-first Capture; placement appears only after content exists |
| Open Today | Opens app | Top-level Today only |
| Open Plan | Opens app | Plan stays LifeShape-first; no calendar write |
| Open Capture | Opens app | Capture stays singular and text-first |
| Add something | Opens app overlay | User reviews before placement or mutation |
| What Ambitions Knows | Opens app overlay | You-owned trust/privacy posture |
| Start here | Opens app | Today-owned recommended step; no external mutation |
| Close the loop | Requires in-app confirmation | Receipt/proof only after user confirms |
| Make today doable | Requires in-app confirmation | Recovery posture, no shame or hidden edits |

The current repo also carries compatibility destination cases such as
`quickFocus`, `quickPlanPatch`, `quickRecovery`, and `captureInbox`. These may
remain internally for routing compatibility. They must not expand the public
launch contract without a named implementation/proof batch.

## App Intent Rules

App Intents must:

- use canonical routes owned by the app shell;
- preserve Today / Goals / Capture / Plan / You;
- open the app for context unless a later batch proves a safe local command;
- keep parameters sparse and privacy-safe;
- keep visible titles aligned with Product Experience Pack copy;
- send capture text to the shared external creation queue;
- require in-app confirmation for completion, recovery, plan edits, calendar
  effects, deletion, or any consequential mutation;
- produce receipts only after confirmed mutation;
- degrade with a clear local failure dialog when routing cannot be formed.

App Intents must not:

- silently complete, reschedule, delete, classify, or place user work;
- expose private goal, step, memory, receipt, calendar, or capture text by
  default;
- bypass the shared command pipeline;
- write calendar/reminder data;
- assume sync/account/network state;
- create a new top-level destination;
- use model-certainty language or fake platform readiness claims.

## Shortcuts Rules

Shortcuts may expose a small, useful command set only when:

- each shortcut has a clear user-facing name;
- the shortcut result makes clear whether Ambitions opened, queued a local
  capture, or requires review inside the app;
- mutation-capable shortcuts open Ambitions for confirmation;
- local capture keeps the raw text private and sends the user to Capture for
  review;
- failed routing returns calm, non-shaming copy.

Shortcuts must not become a remote automation layer, a background decision
engine, or a way to mutate commitments without user review.

## Siri Rules

Siri invocation may be considered only as a system presentation of the approved
Shortcut/App Intent set.

Siri must not:

- speak private details by default;
- summarize memory or receipts outside the app;
- make plan or goal changes without confirmation;
- imply Ambitions made a consequential decision on the user's behalf.

## Spotlight / System Search Rules

No launch CoreSpotlight indexing is approved by default.

Future Spotlight-style integration may be considered only for:

- opening Ambitions;
- opening top-level destinations;
- opening user-approved, privacy-safe app activities;
- finding public-safe app affordances such as Capture or Plan.

Future Spotlight-style integration must not index:

- raw capture text;
- private goals or steps;
- calendar event titles;
- memory or receipt history;
- source details;
- health, finance, legal, relationship, or private life context;
- generated recommendations;
- any content that would be surprising on the device search surface.

If a future batch cannot prove privacy, deletion/retraction, indexing scope,
accessibility, and device behavior, the safe launch decision is `no Spotlight
indexing`.

## Privacy Boundary

Required:

- details stay private until the app opens;
- visible titles and dialogs use sparse copy;
- capture text is stored locally for app review rather than echoed widely;
- external payloads may carry stable ids only when needed for routing;
- sensitive details never appear in shortcut phrases, dialog, Spotlight title,
  Spotlight subtitle, donated activity, or accessibility speech by default;
- app-open routes provide the full context.

## Accessibility Boundary

Future proof must include:

- clear parameter labels;
- clear result dialogs;
- VoiceOver-safe labels for visible confirmations;
- Dynamic Type review for any visible confirmation UI;
- no color-only meaning;
- privacy-safe spoken text.

## Performance / Battery Boundary

Future implementation must prove:

- no broad background indexing loop;
- no high-frequency donation/update behavior;
- lightweight route payload creation;
- no heavy computation during intent execution;
- no network dependency for launch-scope shortcuts;
- safe failure when the app group or local queue is unavailable.

## Required PFC18 Proof Before Implementation Claim

PFC18 or any later implementation batch must produce:

- focused tests for every approved App Intent and Shortcut;
- route compatibility proof for existing destination cases;
- confirmation proof for mutation-capable commands;
- capture queue proof for text-first capture;
- privacy/redaction proof for visible strings, dialogs, and accessibility text;
- Spotlight/CoreSpotlight proof if and only if indexing is introduced;
- Shortcuts/Siri/device proof or an explicit human/device proof stop;
- no-claim boundary for App Store, TestFlight, release, physical-device,
  legal/privacy, and public accessibility claims.

## Launch Decision

PFC17 strategy decision:

- Allowed future launch candidate set: bounded App Intents and Shortcuts for
  Capture, top-level open routes, Start here, Close the loop, Make today
  doable, Add something, and What Ambitions Knows.
- Deferred: any direct external mutation, plan edit, calendar/reminder effect,
  memory search, receipt search, or private object opening.
- Not authorized by default: CoreSpotlight indexing of user life content.

If the allowed set cannot meet privacy, confirmation, accessibility,
compatibility, rendering, and device proof gates later, the safe launch decision
is to keep App Intents / Shortcuts as app-opening affordances only and ship no
Spotlight indexing.
