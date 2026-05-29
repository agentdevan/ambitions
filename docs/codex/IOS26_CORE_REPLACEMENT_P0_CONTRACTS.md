# IOS26 Core Replacement P0 Contracts

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: installation contract; not implementation proof
Batch: IOS26-CORE-LIFE-OPERATIONS-FOUNDATION-INSTALL-01

## 1. Purpose
Create the non-negotiable functional floor for Ambitions replacing Calendar, Reminders, Todoist, Things 3, and Notion through Ambitions-native local objects. This document is strict, testable, and implementation-facing.

## 2. Product rule
Replacing Calendar, Reminders, Todoist, Things 3, and Notion is the floor. The Private Life Runtime is the moat above that floor. This document does not prove that floor is implemented.

## 3. Replacement philosophy
Ambitions replaces the user jobs of these apps, not their UI:

- Calendar job -> Time Operations + LifeShape Field
- Reminders job -> ReminderTrigger + Commitment + Step + closure
- Todoist job -> GoalThread + Commitment hierarchy + SavedViews + filters + dependencies
- Things 3 job -> Start Here + Today + Upcoming + Scheduled + Open + Held + Life Areas
- Notion job -> Life Knowledge Operations + ContextEntry + Collections + Relations + Templates + local search

Ambitions must not copy those products. It must replace their jobs through local-first Ambitions-native objects, receipts, proof, replay, and user-controlled source use.

## 4. Calendar replacement P0
Green requires the user can create one-time and recurring scheduled blocks; view today, week, and month/horizon availability; see busy/free/protected/overloaded/conflict states; mirror external calendar events through EventKit when permission exists; continue locally when EventKit permission is denied; add buffers, commute, and prep blocks where supported; detect conflicts before committing schedule changes; move/delete local scheduled blocks with receipts; show how schedule reality affects Start here; export/delete schedule data safely; and replay schedule decisions deterministically.

Calendar Red conditions: Time root is only a calendar grid; no recurrence; no conflict preview; no protected time; no free-time calculation; schedule mutation without receipt; external calendar write without explicit approval; Today ignores schedule reality.

## 5. Reminders replacement P0
Green requires the user can capture “remind me tomorrow at 9”; create date/time and recurring reminders; attach reminders to Commitment or Step; receive local-notification scheduling through a repo-supported abstraction; snooze, reschedule, move, or hold reminders; mark completed, Still counts, Waiting, Blocked, Not needed, or Needs recovery; see reminders in Today/Time/Goal context; inspect why a reminder appears now; export/delete reminder data; and replay reminder decisions deterministically.

Reminders Red conditions: reminder is only a text row; no recurrence; no local notification hook/abstraction; no closure state; missed reminders become shame or needs closure copy; reminder cannot connect to Goals/Time/Proof; no receipt for material changes.

## 6. Todoist replacement P0
Green requires the user can create GoalThread/Commitment group equivalents to projects; create Step/Commitment equivalents to tasks; add due dates, deadlines, recurrence, dependencies, labels/tags as local metadata; filter by Life Area, GoalThread, label, status, date, and source; use SavedViews for Today, Upcoming, Open, Scheduled, Waiting, Blocked, Held, Proof Needed; bulk move/hold/reschedule selected commitments where repo UI supports it or define a downstream contract; see deterministic sort/ranking and project pressure; connect proof to completion; and replay project/task state.

Todoist Red conditions: projects are cosmetic; labels/filters do not work; dependencies do not affect recommendations; recurrence incomplete; no saved views; no source/explainability for surfaced Step; generic task-list-only architecture.

## 7. Things 3 replacement P0
Green requires the user can capture instantly; see Start here, Today, Upcoming, Scheduled, Open/Anytime equivalent, Held/Someday equivalent; organize by Life Area and GoalThread; move items between Today/Scheduled/Open/Held; use low-friction closure; and plan today without managing a surface.

Things Red conditions: Today is generic task list; Held/Future/Someday does not exist; Areas/Life Areas missing; Upcoming missing; Scheduled missing; Start here not connected to real local state; UI requires too much management before action.

## 8. Notion replacement P0
Green requires the user can store notes, references, ideas, decisions, proof, resources, and people/place/context entries where appropriate; create structured ContextEntries and lightweight Collections; attach files/links through repo-supported abstractions; relate entries to LifeAreas, GoalThreads, Steps, Proof, and Sources; search locally; convert a note/capture into Step, Commitment, GoalThread, Proof, ContextEntry, or Held item; use templates; inspect source usage; export/delete knowledge data; and replay knowledge-source effects deterministically.

Notion Red conditions: Capture is only an inbox; notes cannot relate to goals/steps/proof; no local search; no templates; no relation graph; knowledge cannot affect recommendations; Life Knowledge UI becomes a Notion database clone.

## 9. Cross-app replacement journeys
Green requires these flagship journeys pass once trains execute: half-marathon training; move/apartment setup; career growth goal; relationship/life balance goal; creative release project; and admin/health/legal-sensitive context with sensitive review and no silent use.

## 10. Momentum Reflow / Step Time Reallocation P0 Contract
Momentum Reflow is a Private Life Runtime behavior, not just a UI action or schedule edit. It lets the user intentionally move planned time from one Step to another active or recently active Step when real-life momentum makes that better, while preserving goal coherence, receipts, replay, learning controls, and non-shaming language.

Green requires:

- User can select a planned Step and choose "Use this time elsewhere."
- User can select an active/recent Step and choose "Ride momentum."
- User can choose how to handle the displaced Step:
  - Move
  - Shorten
  - Hold
  - Mark Not needed today
  - Mark Needs recovery
  - Keep deadline
  - Adjust timeline
- Ambitions shows impact on both affected Goal Threads.
- Ambitions shows impact on Time / LifeShape Field.
- Ambitions creates a receipt.
- Ambitions creates a replay trace.
- Ambitions creates a local runtime learning event.
- Ambitions updates future recommendation ranking.
- Ambitions exposes the learned signal in You / What Ambitions knows.
- User can reset/delete/disable this learned behavior.
- No schedule mutation happens silently.
- No shame/needs closure/failure copy appears.

Red conditions:

- Original Step is deleted instead of reallocated.
- Continued Step is not linked to prior proof or session context.
- No impact is shown.
- No receipt exists.
- No replay trace exists.
- No runtime learning event exists.
- Future recommendations ignore the reflow.
- Learning is hidden from You / What Ambitions knows.
- User cannot reset/delete the learned signal.
- Time changes silently.
- UI uses skip/failure/needs closure language as judgment.

## 11. Red / Yellow / Green contract gates
Green means all relevant P0 contract tests, source behavior, proof artifacts, and no-claim checks pass with current logs. Yellow means bounded gaps have an owner, reason, no-claim boundary, and post-batch gate. Red means a hard Red condition appears, proof is missing for a broad claim, or the implementation violates local-first/privacy/trust rules.

## 12. Claims allowed
Only if the corresponding P0 is Green: Ambitions can replace core Calendar jobs locally; Ambitions can replace core Reminders jobs locally; Ambitions can replace core Todoist jobs locally; Ambitions can replace core Things 3 jobs locally; Ambitions can replace core personal Notion jobs locally; Ambitions can operate the user’s life from local objects and receipts.

## 13. Claims forbidden
Forbidden unless all replacement P0 and runtime gauntlets are Green: Ambitions replaces every productivity app; Ambitions fully replaces Calendar/Reminders/Todoist/Things/Notion; Ambitions understands your whole life; Ambitions is fully autonomous; Ambitions is release-ready; Ambitions is App Store-ready; Ambitions is fully accessible; Ambitions performance is validated; Ambitions privacy is approved.

## 14. Downstream train requirements
T04E installs contract harnesses. T04F proves Time Operations. T04G proves Reminder Operations. T04H proves Project/Step Operations. T04I proves Life Knowledge Operations. T04J proves unified capture/search/command obviousness. T04K proves Private Life Runtime integration over the replacement foundation before T05 proceeds as final flagship Today work.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
