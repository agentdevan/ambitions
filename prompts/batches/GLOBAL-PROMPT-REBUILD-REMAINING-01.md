<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# GLOBAL-PROMPT-REBUILD-REMAINING-01 — Rebuild Remaining Global Train Prompts

## Batch ID

GLOBAL-PROMPT-REBUILD-REMAINING-01

## Runner command

```bash
scripts/ambitions-codex-train.sh GLOBAL-PROMPT-REBUILD-REMAINING-01 prompts/batches/GLOBAL-PROMPT-REBUILD-REMAINING-01.md
```

Equivalent:

```bash
make batch BATCH=GLOBAL-PROMPT-REBUILD-REMAINING-01 PROMPT=prompts/batches/GLOBAL-PROMPT-REBUILD-REMAINING-01.md
```

## Operating mode

This batch runs through the Ambitions runner only:

1. GPT-5.5 plan.
2. GPT-5.3-Codex-Spark bounded patch.
3. GPT-5.5 review, repair, and final commit readiness assessment.

Direct Codex execution is forbidden unless the user explicitly bypasses the Ambitions runner.

You are the Ambitions Senior Operating Council acting as senior product architect, iOS architecture lead, design systems director, QA/release lead, privacy/safety reviewer, and Codex OS control-plane engineer.

## Objective

Inspect the active queue truth and current prompt system state, identify every existing not-yet-completed batch prompt already in the global batch train, and rewrite each remaining prompt in place to a world-class Ambitions runner-compatible standard.

This is prompt-system work only. It must not implement product behavior.

The batch must:

1. Inspect active queue truth and current state.
2. Identify every existing not-yet-completed batch prompt in the global train.
3. Preserve canonical batch IDs and queue order.
4. Rewrite each remaining incomplete prompt in place.
5. Preserve PK17-PK41 as separate executable batch IDs.
6. Keep prompts compatible with `scripts/ambitions-codex-train.sh`.
7. Add inherited gates, validation requirements, final report requirements, rollback expectations, hard Red stop conditions, Accepted Yellow policy, and next-batch handoff rules to every remaining executable prompt.
8. Normalize Source Atlas titles from the SA train manifest.
9. Produce a final audit report at `docs/audits/global-prompt-rebuild-remaining-report.md`.

## Current live state

Treat the following as binding unless active repo truth proves a narrower correction is required:

- PK16 Trust History Query is Green.
- PK17 Today Read Model Extraction is next eligible.
- Completed batches must not be reactivated.
- The prompt rebuild targets PK17 onward and every remaining incomplete global-train prompt.
- Active top-level IA is Today / Goals / Capture / Time / You.
- Plan is superseded as a top-level destination.
- External/cloud LLMs are not part of core architecture.
- Core intelligence remains local-first and deterministic.
- Release, TestFlight, App Store, device, accessibility, performance, privacy, and legal claims require proof.
- Existing direct control-plane gates include:
  - `scripts/ambitions-queue-snapshot.py`
  - `scripts/ambitions-source-atlas-title-check.py`
  - `scripts/ambitions-final-report-gate.py`
  - `scripts/ambitions-control-plane-check.py`
  - `scripts/ambitions-batch-scope-guard.py`

## Active source truth to inspect

Before editing, inspect the repo for current authority. At minimum inspect:

```text
prompts/batches/**
prompts/templates/**
docs/codex/**
docs/audits/**
.codex/reports/current-batch-train-state.md
.codex/reports/current-run-state.md
scripts/ambitions-queue-snapshot.py
scripts/ambitions-source-atlas-title-check.py
scripts/ambitions-final-report-gate.py
scripts/ambitions-control-plane-check.py
scripts/ambitions-batch-scope-guard.py
```

Also inspect any active queue, manifest, batch index, Source Atlas manifest, train-state, or prompt-system authority files discovered under the allowed scope.

Do not rely on memory when repo truth is available.

## Required queue discovery procedure

Run or inspect available queue tooling before editing.

Use these where possible:

```bash
python3 scripts/ambitions-queue-snapshot.py || true
python3 scripts/ambitions-control-plane-check.py || true
```

Then determine:

1. Which batches are completed.
2. Which batches are incomplete.
3. Which batch is next eligible.
4. Canonical batch IDs.
5. Canonical queue order.
6. Which prompts are historical, obsolete, do-not-run, archive-candidate, or active executable prompts.
7. Whether any existing prompt is missing runner headers, final report expectations, rollback expectations, or hard Red conditions.
8. Whether any Source Atlas titles still use generic labels instead of canonical SA train manifest titles.

Record queue evidence in the final report.

## Binding queue rules

- PK16 is completed Green and must not be reactivated.
- PK17 is next eligible.
- PK17-PK41 must remain separate executable batch IDs.
- Do not renumber canonical batch IDs.
- Do not collapse multiple PK prompts into one executable batch.
- Do not change queue order unless repo evidence proves the current prompt system already authoritatively changed it.
- If queue evidence conflicts, stop and report Red unless the conflict is narrow and can be resolved by a clearly cited active authority file.
- Do not mark incomplete prompts complete.
- Do not create new implementation batches unless required only as non-executable documentation of this prompt rebuild.
- Do not execute the remaining implementation prompts as part of this batch.

## Required prompt rewrite standard

For every existing not-yet-completed global-train prompt, rewrite in place so it meets the Ambitions senior standard.

Each remaining executable prompt must include, at minimum:

1. Required Ambitions runner header:

```html
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
```

2. Canonical batch ID.
3. Runner command.
4. Operating mode: GPT-5.5 plan → GPT-5.3-Codex-Spark bounded patch → GPT-5.5 review/repair/final commit.
5. Objective.
6. Active source truth to inspect.
7. Allowed scope.
8. Forbidden scope.
9. Required inherited gates.
10. Batch-specific validation expectations.
11. Visual proof expectations if UI is touched.
12. Source Atlas source/freshness expectations if source claims are touched.
13. AIR fold-in obligations if local intelligence is touched.
14. EFC proof obligations if final experience/release/readiness claims are touched.
15. Hard Red stop conditions.
16. Accepted Yellow policy.
17. Rollback expectations.
18. Final report requirements.
19. Next-batch handoff rule.
20. Claims-not-made discipline.
21. Explicit instruction not to make release, TestFlight, App Store, device, accessibility, performance, privacy, legal, or readiness claims without proof.
22. Explicit instruction not to introduce external/cloud LLMs into core architecture.
23. Explicit instruction to preserve active top-level IA as Today / Goals / Capture / Time / You.
24. Explicit instruction that Plan is superseded as a top-level destination.
25. Explicit instruction that core intelligence remains local-first and deterministic.

## Prompt inheritance requirements

Add the following inherited obligations to every remaining executable prompt, adapted to that batch’s scope.

### Release Truth inheritance

Every remaining prompt must state:

- No release, TestFlight, App Store, device, production readiness, accessibility compliance, performance, privacy, legal, or security claims may be made without direct proof from allowed validation artifacts.
- Claims must distinguish implemented, validated, partially validated, not validated, not touched, and deferred.
- “Ready,” “complete,” “shippable,” “production-ready,” “device-proven,” “App Store-ready,” and equivalent claims are forbidden unless backed by explicit validation evidence in the final report.

### Codex Process Truth inheritance

Every remaining prompt must state:

- Execute only through the Ambitions runner unless explicitly bypassed by the user.
- Use bounded patches.
- Do not widen scope to unrelated files.
- Do not hide defects.
- Do not mark Red issues as Green.
- Record validation commands and exit codes.
- Record defects found, repaired, deferred, and not assessed.
- Preserve canonical queue order and next-batch handoff.

### Local-first / privacy gate inheritance

Every remaining prompt must state:

- Core intelligence is local-first and deterministic.
- No external/cloud LLM dependency may be introduced into the core architecture.
- No telemetry, analytics, network sync, cloud storage, remote inference, or external service dependency may be introduced unless the batch’s active source truth explicitly allows it.
- Privacy claims require proof.
- Data minimization and on-device posture must be preserved.

### No external/cloud LLM core rule

Every remaining prompt must state:

- External/cloud LLMs are not part of the core Ambitions architecture.
- Do not add, authorize, imply, or scaffold external/cloud LLM behavior for core product intelligence.
- If a discovered prompt suggests external/cloud LLM core behavior, rewrite it to local-first deterministic behavior or mark the conflicting portion as removed.

### FET/FVQ visual proof gates

For prompts that touch UI, visual design, interaction design, navigation, screen composition, components, FET, or FVQ:

- Require simulator or equivalent visual proof only when the batch is actually allowed to touch UI implementation files.
- If the prompt is not allowed to touch production UI files, require it to specify the visual proof that the later implementation batch must produce.
- Require before/after screenshots or explicit explanation if screenshots cannot be generated.
- Require accessibility-relevant visual checks where applicable.
- Require no premium UI claims without visual evidence.
- Require no native iPhone-first claims without visual evidence and validation.

### Source Atlas source/freshness gates

For prompts that touch sources, Source Atlas, provenance, source claims, titles, freshness, trust history, citation surfaces, source read models, or source-backed UI:

- Normalize titles using the SA train manifest.
- Forbid generic labels such as placeholder “Source 1,” “Doc,” “Reference,” “Untitled,” or equivalent where canonical Source Atlas titles are available.
- Require source/freshness proof in final reports.
- Require explicit distinction between source data, derived read model data, and UI labels.
- Require no source freshness claims without evidence.

### AIR fold-in obligations

For prompts that touch local intelligence, ranking, suggestions, deterministic reasoning, automations, recommendation logic, planning logic, summaries, read models, interpretation, or assistant-like behavior:

- AIR must be folded into the appropriate existing global-train batch.
- AIR must not become a standalone train.
- Require local-first deterministic implementation.
- Require no external/cloud LLM core behavior.
- Require deterministic fixtures or test evidence where applicable.
- Require clear boundary between model/read-model extraction, ranking logic, and UI presentation.
- Require privacy and data-minimization review.

### EFC proof obligations

For prompts that touch final experience, release confidence, App Store/TestFlight readiness, end-to-end flows, user-visible polish, premium experience claims, or completion claims:

- EFC obligations must be proof-bound and narrow.
- EFC must not become broad sprawl.
- Require explicit validation artifacts.
- Require final reports to distinguish polish implemented from polish validated.
- Require no release/readiness claims without release-grade proof.

## Batch-type validation matrix

Add exact validation requirements to each remaining prompt based on its type. Use the narrowest matching set plus any inherited gates.

### Prompt-system / control-plane batches

Required validation:

```bash
git status --short
git diff --check
make prompt-audit || true
make batch-self-check || true
python3 scripts/ambitions-control-plane-check.py || true
python3 scripts/ambitions-source-atlas-title-check.py --strict || true
```

If final report gate applies:

```bash
python3 scripts/ambitions-final-report-gate.py <batch-final-report-path> --strict || true
```

Also require JSON validation for any JSON touched.

### Source Atlas / trust / freshness / provenance batches

Required validation:

```bash
git status --short
git diff --check
python3 scripts/ambitions-source-atlas-title-check.py --strict || true
python3 scripts/ambitions-control-plane-check.py || true
make batch-self-check || true
```

Add source-specific tests or scripts discovered in repo truth. Require final report to include source title normalization proof, source/freshness evidence, and any unresolved provenance defects.

### Read model / model extraction / persistence-adjacent batches

Required validation:

```bash
git status --short
git diff --check
make batch-self-check || true
python3 scripts/ambitions-control-plane-check.py || true
```

Add repo-discovered Swift/package/model tests only if the batch is allowed to touch those files. Require explicit proof that no persistence/schema/model behavior was changed unless that batch’s allowed scope permits it.

### UI / FET / FVQ / design-system / screen batches

Required validation:

```bash
git status --short
git diff --check
make batch-self-check || true
python3 scripts/ambitions-control-plane-check.py || true
```

Add UI/build/snapshot/accessibility validation discovered in repo truth when the implementation batch allows production UI files.

Require visual proof expectations:

- screenshots
- screen recording where interaction is material
- accessibility notes
- device/simulator target used
- explicit list of visual claims not made if proof is absent

### Local intelligence / AIR-fold-in batches

Required validation:

```bash
git status --short
git diff --check
make batch-self-check || true
python3 scripts/ambitions-control-plane-check.py || true
```

Add deterministic fixture/unit validation discovered in repo truth. Require proof that logic remains local-first, deterministic, and non-cloud.

### Final experience / EFC / release-confidence batches

Required validation:

```bash
git status --short
git diff --check
make batch-self-check || true
python3 scripts/ambitions-control-plane-check.py || true
```

Add only the release, E2E, accessibility, performance, or device validation explicitly available and allowed by repo truth. Require proof-bound language. Forbid TestFlight/App Store/device/release claims unless validation artifacts exist.

### Device / DPTG batches

DPTG00 must remain terminal or pre-device-gate-dependent.

Required prompt rule:

- Do not run DPTG00 until all pre-device gates are closed.
- Do not make DPTG00 non-terminal.
- Do not allow DPTG00 to bypass proof gates.
- Do not authorize device/TestFlight/App Store proof generation in earlier prompt rebuild batches.

## Accepted Yellow policy to add per batch

Every remaining executable prompt must include an Accepted Yellow policy.

The policy must state:

- Accepted Yellow is permitted only for non-blocking, fully documented issues.
- Accepted Yellow must include specific defect, why it is non-blocking, affected files/scope, validation performed, risk assessment, rollback or follow-up path, and next eligible batch impact.
- Accepted Yellow is forbidden when the defect affects safety, privacy, data loss, persistence/schema correctness, release/readiness claims, external/cloud LLM core behavior, queue integrity, completed-batch reactivation, canonical batch ID integrity, Source Atlas title normalization, DPTG terminal sequencing, or production app files in this prompt-only batch.

## Hard Red stop conditions to add per batch

Every remaining executable prompt must contain Hard Red stop conditions appropriate to its type.

At minimum, every prompt must stop Red if:

- completed batches are reactivated
- canonical IDs are renumbered
- queue order is changed without evidence
- prompts authorize forbidden production code
- prompts authorize external/cloud LLM core behavior
- prompts authorize release/readiness claims without proof
- Source Atlas generic labels remain where canonical titles are available
- AIR becomes a standalone train
- EFC becomes broad sprawl
- RHC broad cleanup is pulled early
- DPTG00 is made non-terminal
- production app files are touched outside the batch’s allowed scope
- validation failures are hidden
- final report omits required status, evidence, defects, or rollback notes

For this batch specifically, stop Red if:

- any file outside allowed scope is modified
- any production app file is modified
- any completed batch is reactivated
- PK17 is no longer next eligible without active repo evidence
- PK17-PK41 are collapsed, renumbered, deleted, or made non-executable
- a standalone AIR train is created
- broad EFC sprawl is introduced
- broad RHC cleanup is pulled earlier than queue order
- DPTG00 is made non-terminal
- Source Atlas title normalization remains incomplete after this batch
- final audit report is missing or fails the final-report gate

## Rollback expectations to add per batch

Every remaining executable prompt must include rollback expectations.

At minimum:

- Identify every file changed.
- State how to revert the batch safely.
- Preserve queue order and canonical IDs during rollback.
- Do not partially roll back prompt inheritance in a way that leaves prompts unsafe.
- If production files are touched in future implementation batches, require rollback notes specific to app behavior, persistence, UI, and tests.
- If prompt-system files are touched, require rollback notes specific to prompt compatibility and queue integrity.
- If validation fails, record whether rollback is required or whether Accepted Yellow is justified.

## Final report requirements to add per batch

Every remaining executable prompt must require a batch final report.

Each batch final report must include:

```text
Status: Green / Accepted Yellow / Red
Batch ID
Objective
Files changed
Files intentionally not changed
Queue evidence
Source truth inspected
Validation commands and exit codes
Defects found
Defects repaired
Defects deferred
Accepted Yellow rationale, if any
Claims made
Claims not made
Privacy/local-first assessment
External/cloud LLM assessment
Source Atlas assessment, if applicable
AIR fold-in assessment, if applicable
EFC proof assessment, if applicable
FET/FVQ visual proof, if applicable
Rollback notes
Next eligible implementation batch
```

For this batch, the final report must be:

```text
docs/audits/global-prompt-rebuild-remaining-report.md
```

## Next-batch handoff rule to add per batch

Every remaining executable prompt must include a next-batch handoff rule.

At minimum:

- The final report must identify the next eligible implementation batch.
- The next batch must follow canonical queue order.
- Completed batches must not be reactivated.
- If the batch finishes Green, the next eligible batch advances according to active queue truth.
- If the batch finishes Accepted Yellow, the final report must state whether the next batch may proceed and why.
- If the batch finishes Red, the next batch must not proceed until Red conditions are resolved.
- DPTG00 must not become eligible until all pre-device gates close.

## Specific instructions for historical / completed / do-not-run prompts

Do not rewrite completed, historical, obsolete, archived, or do-not-run prompts except as narrowly needed to add a clear historical/do-not-run header.

If such a prompt lacks a clear status header, add or normalize a header similar to:

```html
<!-- AMBITIONS_HISTORICAL_OR_COMPLETED_PROMPT: true -->
<!-- DO_NOT_RUN_WITHOUT_EXPLICIT_USER_REACTIVATION: true -->
<!-- COMPLETED_BATCHES_MUST_NOT_BE_REACTIVATED: true -->
```

Only add this when needed for safety and clarity.

Do not change the substantive completed-batch instructions unless active repo truth proves the prompt is mislabeled and unsafe.

## Source Atlas title normalization

Normalize Source Atlas titles from the SA train manifest.

Required behavior:

1. Locate the active SA train manifest under allowed scope.
2. Treat manifest titles as canonical.
3. Replace generic labels in remaining prompts where canonical titles exist.
4. Preserve meaning and source identity.
5. Do not invent titles.
6. If a title cannot be resolved, mark it explicitly as unresolved in the relevant prompt and in the final report.
7. Run strict Source Atlas title validation.

Generic labels that must not remain where canonical titles exist include:

```text
Source 1
Source 2
Doc
Document
Reference
Untitled
Generic Source
Placeholder Source
SA item
source TBD
```

Equivalent generic labels are also forbidden.

## AIR / EFC / RHC / DPTG constraints

### AIR

- Do not create a standalone AIR train.
- Fold AIR obligations into the appropriate existing global-train prompts where local intelligence is touched.
- Keep AIR local-first and deterministic.
- Do not add external/cloud LLM core behavior.

### EFC

- Do not create broad EFC sprawl.
- Add EFC proof obligations only where final experience, release confidence, user-visible polish, or readiness claims are touched.
- Keep EFC obligations narrow, evidence-based, and tied to specific batches.

### RHC

- Do not pull broad RHC hygiene earlier.
- Only permit narrow RHC intervention when a hard-red blocker prevents the current or next eligible batch from executing safely.
- If a narrow RHC blocker exists, document blocker, evidence, why narrow intervention is required now, files touched, validation, rollback, and why this does not become broad cleanup.

### DPTG00

- Do not run DPTG00 in this batch.
- Do not make DPTG00 non-terminal.
- Do not make DPTG00 eligible before all pre-device gates close.
- Do not authorize premature device/TestFlight/App Store proof claims.

## Allowed scope

This batch may modify only:

```text
prompts/batches/**
prompts/templates/**
docs/codex/**
docs/audits/**
scripts/**
.codex/reports/current-batch-train-state.md
.codex/reports/current-run-state.md
```

But `scripts/**` is read-only except for prompt validators/checkers. Modify scripts only if all of the following are true:

1. The script is a prompt validator/checker.
2. The modification is required to validate the rebuilt prompt system.
3. The change does not affect production app behavior.
4. The change is documented in the final report with rollback notes.

Use `.codex/reports/current-batch-train-state.md` and `.codex/reports/current-run-state.md` only if needed to record prompt-system state.

## Forbidden scope

Do not modify:

```text
Native/**
AppUI/**
Sources/**
Package.swift
project.yml
.github/**
entitlements
signing
generated Xcode project files
production Swift behavior
persistence/schema/model behavior
top-level IA changes
release artifact generation
TestFlight/App Store/device proof
```

Also forbidden:

- production app files
- production Swift behavior
- persistence/schema/model behavior
- top-level IA changes
- release artifact generation
- TestFlight proof generation
- App Store proof generation
- device proof generation
- external/cloud LLM core behavior
- broad repo cleanup
- broad RHC hygiene
- standalone AIR train
- broad EFC train/sprawl

## Required work plan

### Phase 1 — Discover active prompt system truth

1. Inspect allowed scope.
2. Run queue/control-plane checks where available.
3. Identify active queue order.
4. Identify completed prompts.
5. Identify incomplete prompts.
6. Confirm PK16 Green and PK17 next eligible.
7. Identify all remaining global-train prompts.
8. Identify PK17-PK41 prompt files and ensure each remains separate.
9. Locate SA train manifest.
10. Identify generic Source Atlas labels needing normalization.
11. Identify existing prompt templates that should be upgraded for inheritance consistency.

Do not edit until this discovery is complete.

### Phase 2 — Classify prompts

Classify every discovered prompt as one of:

```text
active executable incomplete
completed Green
historical
obsolete
do-not-run
archive-candidate
delete-candidate
supporting template
unknown/conflicted
```

For active executable incomplete prompts, also classify by batch type:

```text
prompt-system/control-plane
Source Atlas/trust/freshness/provenance
read model/model extraction/persistence-adjacent
UI/FET/FVQ/design-system/screen
local intelligence/AIR-fold-in
final experience/EFC/release-confidence
device/DPTG
repo hygiene/RHC
mixed
```

If a prompt is mixed, apply all relevant validation and gate requirements.

If classification is unknown or conflicted, do not guess silently. Either resolve using active repo truth or mark Red if the ambiguity affects queue safety.

### Phase 3 — Rewrite remaining prompts in place

For every active executable incomplete prompt:

1. Preserve canonical batch ID.
2. Preserve queue position.
3. Preserve legitimate objective, but upgrade it to senior Ambitions specificity.
4. Add required runner header.
5. Add operating mode.
6. Add active source truth to inspect.
7. Add allowed/forbidden scope.
8. Add inherited gates.
9. Add batch-specific validation.
10. Add final report requirements.
11. Add rollback expectations.
12. Add hard Red stop conditions.
13. Add Accepted Yellow policy.
14. Add next-batch handoff rule.
15. Add proof and claims discipline.
16. Add Source Atlas, AIR, EFC, FET/FVQ obligations where applicable.
17. Remove or rewrite unsafe authorization for external/cloud LLM core behavior.
18. Remove or rewrite unsafe release/readiness claims.
19. Remove or rewrite instructions that would bypass proof gates.
20. Remove or rewrite instructions that would alter top-level IA away from Today / Goals / Capture / Time / You.
21. Remove or rewrite instructions that restore Plan as a top-level destination.

Do not homogenize all prompts into generic language. Each prompt must retain its specific implementation target, evidence path, validation path, and queue handoff.

### Phase 4 — Handle completed / historical / do-not-run prompts

For prompts that are completed, historical, obsolete, or do-not-run:

1. Do not reactivate.
2. Do not rewrite substantive implementation content.
3. Add a clear historical/do-not-run header only if missing and needed.
4. Preserve completion evidence.
5. Record intentionally not changed prompts in the final report.

### Phase 5 — Normalize Source Atlas titles

1. Use the SA train manifest as canonical title authority.
2. Replace generic labels in remaining active prompts.
3. Avoid invented titles.
4. Record unresolved titles.
5. Run strict title validation.
6. If generic labels remain where canonical titles exist, stop Red.

### Phase 6 — Update prompt templates / docs if needed

Update `prompts/templates/**` and `docs/codex/**` only when needed to preserve consistency and prevent future prompt drift.

Do not create broad documentation sprawl.

Any template/doc change must be directly tied to:

- runner compatibility
- prompt inheritance
- queue safety
- Source Atlas title normalization
- final report consistency
- validation consistency

### Phase 7 — Final audit report

Create or update:

```text
docs/audits/global-prompt-rebuild-remaining-report.md
```

The report must include:

```text
Status: Green / Accepted Yellow / Red
Batch ID: GLOBAL-PROMPT-REBUILD-REMAINING-01
Objective
Prompt files changed
Prompts intentionally not changed
Template/doc/report files changed
Queue evidence
Completed batches confirmed not reactivated
PK17 next eligible evidence
PK17-PK41 preservation evidence
Source Atlas title normalization evidence
AIR standalone-train prevention evidence
EFC sprawl prevention evidence
RHC early-pull prevention evidence
DPTG00 terminal/pre-device-gate evidence
Validation commands and exit codes
Defects found
Defects repaired
Defects deferred
Accepted Yellow rationale, if any
Claims made
Claims not made
Rollback notes
Next eligible implementation batch
```

The final report must explicitly state that this batch did not make release, TestFlight, App Store, device, accessibility, performance, privacy, legal, or production-readiness claims unless such claims are directly supported by validation evidence.

## Required validation for this batch

Run all of the following before final response:

```bash
git status --short
git diff --check
make prompt-audit || true
make batch-self-check || true
python3 scripts/ambitions-control-plane-check.py || true
python3 scripts/ambitions-source-atlas-title-check.py --strict || true
python3 scripts/ambitions-final-report-gate.py docs/audits/global-prompt-rebuild-remaining-report.md --strict || true
```

Also run JSON validation for any JSON touched.

Use appropriate validation commands, for example:

```bash
python3 -m json.tool <path-to-json> >/dev/null
```

or an equivalent repo-standard JSON validator.

Record every validation command and exit code in the final audit report.

Do not hide failures behind `|| true`; the command may use `|| true` to keep the runner moving, but the actual failure must be recorded and assessed.

## Final review requirements

Before finalizing, perform a self-review:

1. Confirm no production app files were touched.
2. Confirm all modified files are inside allowed scope.
3. Confirm completed batches were not reactivated.
4. Confirm canonical IDs were not renumbered.
5. Confirm queue order was preserved.
6. Confirm PK17 remains next eligible unless active repo truth proves otherwise.
7. Confirm PK17-PK41 remain separate executable batch IDs.
8. Confirm every remaining executable prompt has runner headers.
9. Confirm every remaining executable prompt has validation, final report, rollback, hard Red, Accepted Yellow, and next-batch handoff sections.
10. Confirm Source Atlas titles are normalized from the SA train manifest.
11. Confirm AIR is not standalone.
12. Confirm EFC is not broad sprawl.
13. Confirm RHC broad cleanup was not pulled early.
14. Confirm DPTG00 remains terminal/pre-device-gate-dependent.
15. Confirm no prompt authorizes external/cloud LLM core behavior.
16. Confirm no prompt authorizes release/readiness claims without proof.
17. Confirm final report passes the final-report gate or records the failure as Red.

## Hard Red conditions for this batch

Stop and report Red if any of the following occur:

- completed batches are reactivated
- canonical IDs are renumbered
- queue order is changed without evidence
- prompts authorize forbidden production code
- prompts authorize external/cloud LLM core behavior
- prompts authorize release/readiness claims without proof
- Source Atlas generic labels remain after this batch where canonical titles exist
- AIR becomes a standalone train
- EFC becomes broad sprawl
- RHC broad cleanup is pulled early
- DPTG00 is made non-terminal
- production app files are touched
- files outside allowed scope are touched
- PK17 is no longer next eligible without active repo evidence
- PK17-PK41 are not preserved as separate executable batch IDs
- prompt inheritance is missing from remaining executable prompts
- final audit report is missing
- final audit report omits required evidence
- final-report gate fails and the batch is still reported Green
- validation failures are hidden or misrepresented

## Accepted Yellow policy for this batch

Accepted Yellow is permitted only if all of the following are true:

1. The issue is non-blocking.
2. The issue does not affect queue safety.
3. The issue does not reactivate completed batches.
4. The issue does not renumber canonical IDs.
5. The issue does not alter queue order.
6. The issue does not touch production app files.
7. The issue does not authorize external/cloud LLM core behavior.
8. The issue does not authorize release/readiness claims without proof.
9. The issue does not leave generic Source Atlas labels unresolved where canonical titles are available.
10. The issue does not make AIR standalone.
11. The issue does not create EFC sprawl.
12. The issue does not pull broad RHC cleanup early.
13. The issue does not make DPTG00 non-terminal.
14. The final report documents specific defect, why it is non-blocking, affected files/scope, validation performed, risk assessment, rollback or follow-up path, and next eligible batch impact.

If any condition is not met, report Red.

## Rollback expectations for this batch

The final report must include rollback notes that identify:

1. Every file changed.
2. Whether the file is a prompt, template, doc, script checker, or state report.
3. How to revert the prompt rebuild safely.
4. How to preserve completed-batch non-reactivation during rollback.
5. How to preserve canonical queue order during rollback.
6. How to restore previous prompt text if needed.
7. Whether rollback would reintroduce unsafe prompt defects.
8. Whether rollback would reintroduce generic Source Atlas labels.
9. Whether rollback would affect PK17 next eligibility.

Do not perform rollback unless necessary to recover from a hard Red modification.

## Claims not to make

Do not claim:

- production app behavior changed
- app is release-ready
- app is TestFlight-ready
- app is App Store-ready
- app is device-proven
- app is accessibility-compliant
- app meets performance targets
- privacy/legal/security status is proven
- PK17 or later implementation work was completed
- DPTG00 can run now
- broad RHC cleanup has been completed
- AIR is complete as a standalone train
- EFC release confidence is proven

This batch may claim only prompt-system changes that were actually made and validated.

## Final response requirements

The final Codex response must summarize:

```text
Status: Green / Accepted Yellow / Red
Prompt files changed
Prompts intentionally not changed
Queue evidence
Validation commands and exit codes
Defects found
Defects repaired
Defects deferred
Claims not made
Rollback notes
Next eligible implementation batch
```

The final response must not make release/readiness claims.

The final response must not claim production app behavior changed.

The final response must not omit validation failures.

The final response must identify the final audit report path:

```text
docs/audits/global-prompt-rebuild-remaining-report.md
```
