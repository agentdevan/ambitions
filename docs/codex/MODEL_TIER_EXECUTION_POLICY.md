# Model Tier Execution Policy

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active Codex OS policy for model-tier-aware global batch execution.
Date: 2026-05-08
Scope: Codex OS governance, global batch-train execution, model-tier escalation, model-tier deferral, and no-claim safety.

This policy lets Ambitions run a cost-efficient `gpt-5.4-mini` global batch train while preserving a separate senior judgment train for `gpt-5.5` or a stronger explicitly selected model.

## Purpose

Ambitions Codex OS is mature enough for many remaining batches to be executed by a smaller model when work is tightly bounded by source truth, allowed files, tests, gates, and proof artifacts.

The target is not identical model behavior. The target is identical gate discipline.

## Operating Principle

`gpt-5.4-mini` may operate as an implementation team only inside explicit rails:

1. repo evidence beats chat memory
2. current source-truth files beat older plans
3. allowed files are named before edits
4. smallest safe slice wins
5. focused validation runs before broad claims
6. Green requires proof, not confidence
7. Yellow requires owner, safety reason, follow-up, and recheck condition
8. Red stops or defers; it is never guessed through
9. no release, legal/privacy, device, accessibility, human visual, or App Store/TestFlight claim is made without matching evidence
10. judgment-heavy batches transfer to the senior train instead of being diluted

## Model Tier Detection

Codex must not hallucinate its active model.

Acceptable model-tier sources are:

- explicit model name visible in the Codex UI, CLI, IDE extension, or session header
- explicit user invocation phrase, such as `resume mini global batch train` or `resume senior global batch train`
- explicit local run metadata written by the operator for the active session
- a checked-in or local-only run note that names the active model and date

If the actual model is not visible, Codex records `model tier: operator-declared` when the alias phrase provides the tier, or `model tier: unknown` when no reliable tier source exists.

Unknown tier uses Mini-safe execution rules. Unknown tier may not make senior-only judgments.

## Tier Names

| Tier | Models / invocation | Role |
| --- | --- | --- |
| Mini Execution Tier | `gpt-5.4-mini`, `resume mini global batch train`, or unknown model under Mini-safe rules | Bounded execution, repair loops, docs/tooling/source-truth updates, narrow Swift/domain work, focused validation. |
| Senior Judgment Tier | `gpt-5.5`, explicitly stronger selected model, or `resume senior global batch train` | Architecture/product judgment, source-truth conflict resolution, final visual/founder/release/legal/device/handoff gates, deferred-batch resolution. |

## Mini Execution Tier: Allowed Green Closures

Mini may close a batch Green only when all are true:

- batch objective is explicit in current source truth or batch prompt
- source hierarchy is not contradictory
- allowed files are named before edits
- touched files stay inside the allowed boundary
- platform, storage, route, dependency, signing, entitlement, workflow, sync, AI runtime, release, device, accessibility, and legal/privacy boundaries are not crossed unless explicitly authorized by the active batch
- focused validation passes, or the gap is recorded as Yellow/Red with owner and recheck
- report separates verified, needs review, not-run, and human/device follow-up
- no unsupported claim language is introduced
- next eligible batch is selected from repo evidence

Mini is suited for docs-only source-truth locks, registry/context/run-state reconciliation, Codex OS policy upgrades, narrow copy/object-language alignment, bounded owner-file implementation from an explicit spec, additive value-model/domain-contract files with focused tests, focused test repair, no-claim scans, report generation, and proof inventory updates.

## Mini Execution Tier: Senior-Only Gates

Mini must not close Green or silently continue when the active batch requires:

- source-truth conflict resolution not decidable from repo evidence
- roadmap/order reinterpretation
- founder acceptance or founder override judgment
- final visual quality scoring or human taste call
- public accessibility conformance judgment
- legal/privacy compliance judgment
- App Store, TestFlight, release, signed archive, provisioning, export, or physical-device readiness judgment
- route/raw-value compatibility retirement
- persistence/schema migration or data-loss risk
- CloudKit/sync/account/backend runtime implementation
- dependency, package, signing, entitlement, hosted workflow, or generated-project boundary change not explicitly authorized
- hosted AI/model runtime/tool-bus implementation
- safety, privacy, memory, or source ambiguity that needs human or senior judgment
- performance/battery safety claim without measured evidence
- deletion, rename, or cleanup where owner proof is incomplete
- repeated same-root failure after two scoped repair attempts
- any batch where Mini cannot state the exact owner, safety reason, and recheck condition for a Yellow

When one of these appears, Mini must use the deferral protocol instead of guessing.

## Model-Tier Deferral Protocol

A model-tier deferral is not a success state. It is a controlled skip for the Mini train and a queued obligation for the Senior train.

Mini may defer and continue only when:

1. the batch is senior-only, or Mini cannot safely close it with evidence
2. the batch is not a minimum safety prerequisite for the next executable batch
3. order, registry, and current-state docs allow later resolution
4. the deferral is recorded in `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`
5. the batch report or current-state note says `Deferred by Mini; Senior train required`
6. no implementation claim, Green claim, release claim, or proof claim is made for the deferred batch

Mini must stop instead of deferring when the batch is blocking, skipping would invert dependency order, skipping would allow false claims, or skipping would leave a dirty tree or half-implemented source change.

## Senior Train Responsibilities

The Senior Judgment Tier must begin by reading:

1. `docs/codex/MODEL_TIER_EXECUTION_POLICY.md`
2. `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`
3. `.codex/reports/current-run-state.md`
4. `.codex/reports/current-batch-train-state.md`
5. `docs/codex/BATCH_REGISTRY.md`
6. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
7. target source truth and batch prompt

The Senior train resolves pending model-tier deferrals before normal order when the deferral is blocking, release-relevant, or required for truthful closeout.

Senior may accept, implement, split, supersede, or Red-stop a deferral. Senior may not erase Mini deferral history.

## Alias Behavior

When the user says `resume mini global batch train`, Codex declares Mini Execution Tier or operator-declared Mini Execution Tier, reads `docs/codex/RESUME_MINI_GLOBAL_BATCH_TRAIN.md`, reads this policy, executes Mini-safe batches, defers senior-only batches when safe, and stops on blocking senior-only prerequisites or Hard Red.

When the user says `resume senior global batch train`, Codex declares Senior Judgment Tier or operator-declared Senior Judgment Tier, reads `docs/codex/RESUME_SENIOR_GLOBAL_BATCH_TRAIN.md`, reads this policy and the deferral ledger, resolves blocking deferrals, runs final judgment gates, and preserves no-claim boundaries unless proof exists.

## Senior Implementation Packet

Every nontrivial implementation batch must record:

- exact goal, non-goals, allowed files, and forbidden files
- smallest safe implementation change
- focused validation first, broader validation where scoped
- safety/privacy review
- product/design canon review
- explicit non-claims for release, device, App Store/TestFlight, public accessibility, legal/privacy, and human approval
- Green/Yellow/Red classification with evidence

## Batch Report Additions

Every batch report created after this policy must include:

- Model tier used
- Model-tier source: actual / operator-declared / unknown
- Mini-safe classification: yes / no / not applicable
- Senior-only gates encountered
- Deferrals created or closed
- Why continuing is safe, or why stopping is required

## Hard Red Additions

The following are Hard Red unless resolved by repo evidence:

- Mini closes a senior-only gate Green
- Mini skips a blocking prerequisite
- Mini continues after a source-truth conflict that requires judgment
- model tier is unknown and a senior-only decision is required
- deferral ledger is required but not updated
- Green is claimed for screenshot, device, release, legal/privacy, public accessibility, or founder acceptance proof without evidence

## No-Claim Boundary

This policy does not claim that `gpt-5.4-mini` is equivalent to `gpt-5.5`. It creates execution boundaries so lower-cost Codex runs can move quickly without corrupting evidence or senior judgment gates.

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
