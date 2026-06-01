# AFEP-015 Reopen Routing Packet

Batch: AFEP-015

## Exact Reopen Paths

| Object | Exact route source | Fallback if exact object is missing |
| --- | --- | --- |
| Today | `OpenAmbitionsDestinationIntent(destination: .today)` | `Today` root |
| Goals | `OpenAmbitionsDestinationIntent(destination: .goals)` | `Goals` root |
| Capture | `OpenAmbitionsDestinationIntent(destination: .captureInbox)` and `CreateAmbitionsCaptureIntent` landing | `Capture` root / Capture inbox |
| Time | `OpenAmbitionsDestinationIntent(destination: .time)` | `Time` root |
| You | `OpenAmbitionsDestinationIntent(destination: .you)` | `You` root |
| Goal detail | `AppExternalRoute.openGoalDetail(goalID:)` | `Goals` root if no identifier is available |
| Current step | `OpenAmbitionsCurrentStepIntent` / `StartAmbitionsCurrentStepIntent` / `GuardedCloseAmbitionsStepIntent` | `Today` focus route if goal or step identifiers are unavailable |
| Receipt inspection | `ShowAmbitionsReceiptIntent` | Memory Lens inspection surface |
| Local knowledge inspection | `InspectAmbitionsLocalKnowledgeIntent` | Memory Lens inspection surface |

## Routing Rules Verified

- Canonical tab routes are exact when the destination exists.
- Legacy `plan`, `habits`, `profile`, and `insights` paths remain compatibility-only.
- App Intent and widget/notification payloads stay on canonical tab keys and opaque IDs.
- The router falls back to canonical roots when it cannot prove a more exact reopen.

## Notes

- No private note text, raw capture text, or proof content is embedded in the route URLs.
- Step and receipt routes carry identifiers only, not the underlying private text.
