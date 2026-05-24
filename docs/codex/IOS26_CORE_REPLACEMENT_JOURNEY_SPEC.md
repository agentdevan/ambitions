# IOS26 Core Replacement Journey Spec

Status: journey contract; not implementation proof
Batch: IOS26-CORE-LIFE-OPERATIONS-FOUNDATION-INSTALL-01

## Purpose
Define concrete end-user journeys that prove Ambitions improves productivity and life organization by replacing user jobs from Calendar, Reminders, Todoist, Things 3, and Notion through local Ambitions-native objects.

Each journey must include normal path, ambiguous input path, correction path, permission denied path where applicable, source stale path, delete/reset path, replay path, and proof artifact path.

## Journey 1 - Half-marathon life goal
Input: “Every Tuesday and Thursday at 6, remind me to train for the half marathon. I also need to protect Friday nights for Alexandra. My knee has been bothering me, so start lighter. Goal is to run the race in October.”

Required local outputs: GoalThread for half marathon; recurring ScheduledBlock candidates; recurring Commitment/ReminderTrigger candidates; protected Friday night block; sensitive/recovery ContextEntry requiring review for knee context; lighter-path recommendation; deadline-preserving alternative path; proof-first alternative path; SourceRecords for each extracted meaning; receipts for material placements; deterministic replay after relaunch; export/delete/reset behavior.

Apps replaced: Calendar recurring training schedule and protected Friday night; Reminders recurring training reminders; Todoist goal/project with commitments and dependencies; Things 3 Today/Upcoming/Open/Held execution states; Notion recovery note and race context as structured knowledge; Private Life Runtime recommended Step and multiple paths.

## Journey 2 - Move/apartment setup
Input: “We move in July 1. Need to set up electric, gas, internet, renters insurance, change address, pack kitchen, and protect the weekend before move-in.”

Required outputs: Move GoalThread; scheduled protected move prep blocks; commitments with due dates; checklist groups; recurring bill/admin context candidates; reference ContextEntries; Waiting states for vendor responses; Today Start here recommendation based on time pressure; receipts/replay.

## Journey 3 - Career/product growth
Input: “I want to become product manager ready by Q4. Capture notes from this PM article, schedule study twice a week, remind me to update portfolio Sunday, and track proof.”

Required outputs: Career LifeArea/GoalThread; knowledge/reference entry; recurring study ScheduledBlocks; Sunday reminder; proof requirements; project steps; recommended Step based on capacity; search result linking note to goal.

## Journey 4 - Creative release
Input: “Release a song by August. Need lyrics draft, mix notes, cover art idea, distribution checklist, and two work sessions a week.”

Required outputs: creative GoalThread; recurring work blocks; checklist/dependency path; ContextEntries for lyrics/mix/cover art; proof for completed drafts; multiple paths when deadline tightens.

## Journey 5 - Relationship/life balance
Input: “Protect Wednesday dinner with Alexandra, remind me to plan date night monthly, and don’t schedule deep work there.”

Required outputs: protected time; recurring reminder; scheduling exclusion; source ledger explanation; conflict warning if a Step tries to use protected time.

## Journey 6 - Sensitive context
Input: “My knee hurts after running. Maybe don’t suggest hard running tomorrow.”

Required outputs: sensitive/recovery ContextEntry held for review; no medical advice; no diagnosis; lighter Step path if user approves use; clear source explanation; reset/delete option.

## Required paths for every journey
Normal path proves expected local object extraction and user-approved placement. Ambiguous path holds reviewable candidates. Correction path updates SourceRecords and receipts. Permission denied path continues locally without blocked core behavior. Source stale path downgrades confidence without silent mutation. Delete/reset path removes user-owned data and disables source use. Replay path proves deterministic reconstruction. Proof artifact path records status, files changed, tests run, validation not run, claims allowed, and claims forbidden.
