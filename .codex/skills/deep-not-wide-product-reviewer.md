# Deep Not Wide Product Reviewer

## Purpose

Reusable AmbitionsOS / Beyond 3.0 review skill for future Codex runs. It prevents one-off role prompts from becoming untracked process.

## When To Invoke

Invoke when a future batch touches this skill's concern, when an AOS/ME/CS manifest names it, or when validation evidence shows risk in this domain.

## Required Source Docs

- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/AmbitionsOS_Index.md`
- `docs/canon/AmbitionsOS_Runtime_Contract.md`
- `docs/codex/AMBITIONSOS_AOS_TRAIN_CONTROL_SYSTEM.md`
- `docs/codex/BATCH_REGISTRY.md`

## Required Inputs

- user prompt and batch manifest
- current git status, branch, HEAD, and latest commit
- allowed and forbidden files
- affected primitive, kernel, surface, and train gate
- validation commands and logs
- known release-claim, privacy, accessibility, performance, maintainability, and compatibility impact

## Review Checklist

- purpose fit
- source truth read
- allowed files respected
- forbidden files untouched
- privacy/trust reviewed
- accessibility reviewed
- performance reviewed
- compatibility reviewed
- release claims bounded
- validation evidence recorded

## Common Failure Modes

- canon treated as implementation
- broad refactor mixed with product behavior
- release claim inferred from simulator proof
- source-sensitive fact treated as memory
- external surface receives raw sensitive state
- prompt lacks stop conditions or validation
- compatibility seam removed without migration proof

## Green / Yellow / Red Gates

Green: source truth is read, scope is bounded, required evidence exists, and no forbidden file or claim changed.

Yellow: evidence is advisory, optional tools are missing, failure is classified, or scope is broader than expected but still docs/planning only.

Red: forbidden files touched, dependency/workflow/app behavior changed outside scope, privacy/source/release overclaim, unclassified validation failure, or compatibility uncertainty.

## Stop Conditions

Stop on Red, untrusted validation, missing source-truth owner, release-claim ambiguity, privacy ambiguity, or train dependency violation.

## Output Format

Result; files reviewed; findings; evidence; Green/Yellow/Red; required repair or next gate.

## Validation Evidence Expected

Command, timestamp, log path when available, pass/fail/partial status, proof scope, and what the proof does not claim.

## Examples Of What To Reject

- a chatbot tab proposal
- app implementation in a docs-only batch
- top-level surface addition by implication
- platform readiness without rendered/source proof
- generated-looking docs with no owner, gate, or consequence

## Ambitions-Specific Operating Focus

Surface width guard. Reject one-off surfaces where Today/Goals/Capture/Plan/You can own the job.

## Distinct Rejection Examples

- Future canon presented as current app behavior.
- Broad app edits in a docs/protocol/status batch.
- Unsupported release, platform, source-truth, privacy, accessibility, or performance claim.
- Generic productivity, chatbot, analytics-dashboard, calendar-clone, or habit-streak drift.

## Required Output Detail

Name the exact source docs read, files reviewed, evidence checked, Green/Yellow/Red verdict, rejection reason for any unsafe work, and the next allowed gate.
