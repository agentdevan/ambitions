# Batch Conflict Action Workflow

Status: Active workflow
Owner: BATCH-LEDGER-001
Linear issue: AMB-39
Source inputs:
- `docs/ops/batch-ledger/batch-ledger.json`
- `docs/ops/batch-ledger/batch-ledger.md`
- `docs/ops/batch-ledger/conflict-report.md`
- `docs/ops/batch-ledger/conflict-report.json`
- `docs/ops/batch-ledger/implementation-proof-status-report.md`
- `docs/ops/batch-ledger/touchpoint-report.md`
- `docs/ops/batch-ledger/linear-summary-sync-report.md`

## Purpose

This workflow defines what happens after the batch ledger identifies duplicate, stale, partial, source-only, missing-proof, retired-language, or conflicting work.

The goal is not to create one Linear issue per conflict. The goal is to make every conflict actionable without turning Linear into a noisy mirror of the repo.

Repo truth wins. Linear is the control plane. The full conflict list remains in repo artifacts.

## Hard rules

- Do not bulk-create conflict issues.
- Do not auto-resolve conflicts.
- Do not delete, archive, rewrite, or retire active prompts automatically.
- Do not treat source-only work as complete.
- Do not treat audit-only proof as current build/test/release proof.
- Do not treat Linear status as repo truth.
- Do not start implementation work that relies on conflicting or stale batch authority until the conflict is explicitly actioned.
- Do not weaken claim safety to make a ledger item look Green.
- Do not convert historical or superseded work into active work unless repo truth explicitly promotes it.

## Required actions

Every AMB-28 recommended action must map to one of these workflow actions:

1. Retire
2. Expedite
3. Merge
4. Rewrite
5. Finish proof
6. Cancel
7. Keep planned

Each action below defines:

- meaning
- allowed when
- repo evidence required
- Linear state or issue type allowed
- files that may be changed
- claims not allowed
- closure proof

---

## Action: Retire

### Meaning

Retire means a batch, prompt, train, or work artifact remains in the repo for traceability but is no longer runnable or forward-driving.

Use Retire when an item is obsolete but still historically useful.

### Allowed when

Retire is allowed when:

- the item is superseded by installed repo truth
- the item references old IA or old product terminology and should not be executed
- the item belongs to a historical train that is not the active sequence
- the item duplicates newer work and does not contain unique implementation instructions
- the item is useful for audit/history but unsafe as runnable work

### Repo evidence required

At least one must be present:

- conflict report row showing `superseded`, `retired`, `historical`, or old terminology
- ledger item with `implementation_status: retired` or `current_status: retired`
- authoritative newer file that replaces the item
- docs/truth/HISTORICAL_POLICY.md supports the classification

### Linear handling

Allowed Linear handling:

- summary-level note only
- one owner-approved issue for a retirement batch if many items are affected
- no one-issue-per-retired-item creation

### Files that may be changed

Allowed:

- `docs/ops/batch-ledger/*`
- archive or historical index files
- affected prompt header/front matter if owner-approved
- repo truth references only if the truth file itself is being deliberately updated

Not allowed:

- deleting active source code
- deleting prompt history without explicit owner approval
- changing product truth to fit a retired artifact

### Claims not allowed

Do not claim:

- implementation was removed
- the underlying code changed
- release risk is resolved
- the item was validated
- all duplicates are gone

### Closure proof

Retire is closed when:

- the retired item is classified as retired or historical in the ledger
- the conflict/action is recorded in a report or commit message
- any active runner or sequence no longer treats the item as runnable
- no release/readiness claim is introduced

---

## Action: Expedite

### Meaning

Expedite means a conflict needs quick owner attention because it blocks sequencing, active train selection, or safe execution.

Expedite does not mean implement immediately. It means resolve priority, owner, or authority before downstream work depends on it.

### Allowed when

Expedite is allowed when:

- an active item has unknown status
- multiple active items touch the same high-risk surface or system
- a Red or high-priority conflict blocks the next sequence decision
- the conflict report identifies missing source-of-truth references in active work
- a proof/status gap is likely to mislead the runner

### Repo evidence required

At least one must be present:

- conflict report entry with recommended action `expedite`
- `implementation_status: unknown` on an active batch/prompt/train
- active IOS26 sequence summary showing unknown or partial items
- BATCH-LEDGER summary showing unresolved high-priority conflict counts

### Linear handling

Allowed Linear handling:

- one bounded summary issue
- one owner-approved triage issue
- status update on BATCH-LEDGER-001
- status update on the relevant downstream project

Not allowed:

- creating per-conflict issues by default
- creating hundreds of proof follow-ups
- marking as Done without repo artifact update

### Files that may be changed

Allowed:

- `docs/ops/batch-ledger/*`
- active sequence status docs
- selected prompt docs only when the action clarifies authority or status
- Linear summary issue descriptions

### Claims not allowed

Do not claim:

- conflict is fixed
- implementation is complete
- proof is Green
- source has changed
- test/build/release has passed

### Closure proof

Expedite is closed when:

- owner decision is recorded
- next action is one of Retire, Merge, Rewrite, Finish proof, Cancel, or Keep planned
- affected item status is updated in repo artifacts
- no ambiguity remains about whether the item can block or proceed

---

## Action: Merge

### Meaning

Merge means multiple batches/prompts/trains overlap and should become one coherent authority or execution path.

Merge does not mean Git merge. It means scope consolidation.

### Allowed when

Merge is allowed when:

- duplicate stable IDs exist
- same source file is targeted by multiple active batches
- same surface has overlapping active batch ownership
- two prompts describe the same implementation outcome
- old and new work can be consolidated without losing unique instructions

### Repo evidence required

At least one must be present:

- conflict report entry with `duplicate_stable_id`
- conflict report entry with same source file targeted by multiple active batches
- conflict report entry with same surface touched by multiple active batches
- owner review confirming overlap

### Linear handling

Allowed Linear handling:

- one merge-planning issue for the group
- summary issue update
- no one-issue-per-duplicate pair creation

### Files that may be changed

Allowed:

- batch prompt files
- train manifest references
- sequence docs
- conflict report follow-up docs
- ledger outputs

Not allowed:

- deleting unique instructions without preserving them somewhere
- changing current product truth as a side effect
- merging conflicting old IA into active truth

### Claims not allowed

Do not claim:

- all overlap is resolved
- implementation is completed
- proof is current
- runtime/source behavior changed
- release readiness improved

### Closure proof

Merge is closed when:

- chosen surviving authority is named
- superseded artifacts are marked retired/superseded/historical
- unique instructions are preserved or intentionally rejected
- sequence references point to the surviving authority
- the ledger/conflict report reflects the new state on regeneration

---

## Action: Rewrite

### Meaning

Rewrite means a batch/prompt/train remains potentially useful, but its wording or authority references are stale, unsafe, or misleading.

Rewrite is the correct action for retired IA, old terminology, missing source-of-truth references, or release overclaims.

### Allowed when

Rewrite is allowed when:

- old IA language appears, such as Plan tab, Profile tab, Captures tab, Habits tab, Insights tab, or Momentum tab
- retired product language appears, such as next best move, best next move, Begin Focus, Start Focus, overdue, failed, streak, productivity score, dashboard
- source-of-truth references are missing
- implementation/release claims are too strong
- prompt can be safely preserved with updated authority and wording

### Repo evidence required

At least one must be present:

- conflict report entry with retired IA or terminology
- conflict report entry with missing source-of-truth references
- claim scan finding
- owner-approved canon update

### Linear handling

Allowed Linear handling:

- one rewrite issue for a bounded set of files
- status update in BATCH-LEDGER-001
- summary issue update

Not allowed:

- creating a rewrite issue for every stale phrase by default
- silently rewriting active prompt intent without proof
- changing source code unless explicitly scoped

### Files that may be changed

Allowed:

- affected prompt docs
- affected repo authority reference sections
- batch/train descriptions
- docs/ops/batch-ledger outputs

Not allowed:

- unrelated product truth rewrites
- historical documents unless policy says they are active and confusing
- source implementation files unless separately scoped

### Claims not allowed

Do not claim:

- implementation changed
- product behavior changed
- tests passed
- release readiness improved
- all old language has been purged repo-wide unless a scanner proves it

### Closure proof

Rewrite is closed when:

- affected file paths are listed
- exact authority references are present
- retired language is removed or intentionally quarantined
- claim scan passes for the scoped files
- ledger/conflict report can be regenerated cleanly for those items

---

## Action: Finish proof

### Meaning

Finish proof means source or work exists, but the evidence is incomplete. The work cannot be treated as complete until focused proof exists.

### Allowed when

Finish proof is allowed when:

- implementation_status is `partial_implementation`
- proof state is `source-only`, `none`, `audit`, or weak proof
- a report says source landed but test/build/release proof is missing
- a batch appears completed but lacks exact validation artifacts

### Repo evidence required

At least one must be present:

- AMB-27 implementation/proof status report marks item partial
- AMB-28 conflict report marks source-only or missing proof
- current proof path is missing, stale, historical, or insufficient
- source files exist but test/build artifacts do not

### Linear handling

Allowed Linear handling:

- one finish-proof issue for a coherent group of items
- summary issue update
- project status update

Not allowed:

- marking source-only work as Done
- marking audit-only proof as current proof
- pretending local build/test/device validation happened

### Files that may be changed

Allowed:

- focused proof scripts
- validation reports
- exact proof artifact outputs
- batch ledger reports

Not allowed:

- broad implementation changes unless explicitly scoped
- release truth changes that overstate evidence
- deleting a Yellow/Red proof artifact instead of addressing it

### Claims not allowed

Do not claim:

- Green without current evidence
- test pass without logs
- build pass without logs
- device validation without device proof
- release readiness from source-only proof

### Closure proof

Finish proof is closed when:

- exact command is documented
- exact output path is saved
- status is Green, Accepted Yellow, or Red with reason
- source-only no longer appears as complete
- no release/readiness claim is introduced

---

## Action: Cancel

### Meaning

Cancel means the work should not proceed and does not need to be preserved as a runnable future batch.

Use Cancel when the work is invalid, unsafe, duplicated without unique value, or no longer aligned with repo truth.

### Allowed when

Cancel is allowed when:

- the work conflicts with current truth and has no useful salvage value
- owner explicitly rejects the work
- the work duplicates another active item with no unique scope
- the work depends on an abandoned IA or architecture
- the work would create harmful repo noise

### Repo evidence required

At least one must be present:

- conflict report entry showing duplicate/superseded/stale state
- owner decision
- active truth conflict
- replacement item named

### Linear handling

Allowed Linear handling:

- cancel the issue
- update summary issue
- record cancellation rationale

Not allowed:

- deleting repo history
- canceling active implementation without owner approval
- silently removing an item from the ledger

### Files that may be changed

Allowed:

- ledger status outputs
- cancellation notes
- active sequence references if the item was referenced

Not allowed:

- source deletion
- product truth changes
- proof deletion

### Claims not allowed

Do not claim:

- work completed
- implementation removed
- risk resolved globally
- release readiness improved

### Closure proof

Cancel is closed when:

- cancellation reason is recorded
- replacement or no-replacement decision is explicit
- sequence no longer treats it as active
- ledger status reflects canceled/non-forward state

---

## Action: Keep planned

### Meaning

Keep planned means the item remains valid future work, but should not be run yet.

Use Keep planned when the item is directionally valid, not stale, and not blocking current sequence execution.

### Allowed when

Keep planned is allowed when:

- the item is aligned with current truth
- no stale source-of-truth references are present
- the item is future-facing
- it does not duplicate active near-term work
- it does not need immediate proof repair

### Repo evidence required

At least one must be present:

- active manifest lists it as future work
- owner decision to keep it
- conflict report shows no Red conflict for the item
- current source-of-truth references are present

### Linear handling

Allowed Linear handling:

- leave in Backlog or Todo
- attach to future project/milestone
- summarize in batch ledger records

Not allowed:

- treating planned as implemented
- running it ahead of active sequence authority
- moving to Done without execution/proof

### Files that may be changed

Allowed:

- sequence docs
- backlog docs
- ledger status docs

Not allowed:

- implementation source unless the item is actually started
- proof outputs unless validation is run

### Claims not allowed

Do not claim:

- implementation exists
- proof exists
- build/test/release readiness exists
- the item is active unless sequence authority says so

### Closure proof

Keep planned is closed when:

- item remains in future queue or backlog
- owner/project decision is visible
- active sequence is not blocked by it
- no current implementation/proof claim is made

---

## Conflict handling matrix

| Conflict type | Preferred action | Alternate action | Notes |
|---|---|---|---|
| duplicate_stable_id | Merge | Retire | Preserve unique instructions before retiring duplicates. |
| same_surface_multiple_active_batches | Expedite | Merge | Clarify owner/sequence before more implementation. |
| same_source_file_targeted_by_multiple_active_batches | Merge | Expedite | Avoid competing patches to the same file. |
| retired_ia_or_terminology_reference | Rewrite | Retire | Red if old IA affects active execution. |
| missing_source_of_truth_reference | Rewrite | Expedite | Add authority references before execution. |
| source_only_implementation_missing_proof | Finish proof | Expedite | Never mark complete from source-only. |
| stale_or_unknown_active_status | Expedite | Keep planned | Clarify status before execution. |
| release_overclaim | Rewrite | Cancel | Remove unsafe claims immediately. |
| implementation_overclaim | Rewrite | Finish proof | Correct claim or add real proof. |
| historical_only | Retire | Keep planned | Historical cannot become active by default. |

## Linear issue creation policy

Linear issues may be created only when they represent bounded, owner-useful work.

Allowed:

- one issue for a group of related retirements
- one issue for a high-priority rewrite group
- one issue for a proof-finishing bundle
- one issue for a merge/reconciliation bundle
- one issue for a sequence clarification decision

Not allowed:

- one issue per ledger item by default
- one issue per conflict by default
- one issue per file path by default
- generated spam that exceeds workspace limits
- issue creation without stable sync key or clear owner value

## Required issue template for action work

Each generated or manual action issue must include:

- Action: Retire / Expedite / Merge / Rewrite / Finish proof / Cancel / Keep planned
- Source conflict IDs
- Involved stable IDs
- Involved repo paths
- Governing truth or authority files
- Expected repo output
- Validation command
- No-claim boundary
- Closure proof

## No-claim boundary

Linear status is not repo truth.

This workflow does not prove:

- implementation exists
- implementation is correct
- build success
- test success
- accessibility validation
- performance validation
- device validation
- privacy/legal approval
- TestFlight readiness
- App Store readiness
- release readiness

## AMB-39 Green criteria

AMB-39 is Green when:

- this workflow exists
- every AMB-28 recommended action maps to a workflow definition
- no action allows silent auto-resolution
- no action allows source-only work to count as complete
- no action allows bulk conflict issue creation by default
- retire/expedite/merge/rewrite/finish proof/cancel/keep planned are distinct
- workflow is Linear-ready without creating issue spam
