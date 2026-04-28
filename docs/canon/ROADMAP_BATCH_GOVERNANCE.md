# Ambitions Roadmap, Batch Governance, And No-Drift Execution

Status: Active canon consolidation layer.

Purpose: Consolidate roadmap governance, batch execution rules, no-drift behavior, canon proposal handling, acceptance gates, validation expectations, and shipped/planned/deferred status discipline into one implementation-readable reference. This document reflects Wave 18 product decisions.

## Core Roadmap Doctrine

Roadmap should optimize for:

```text
Completing coherent product loops.
```

Roadmap governance north star:

```text
No drift from the product Ambitions is becoming.
```

Rules:

- The roadmap should make Ambitions more coherent, not simply larger.
- Batches should complete loops before expanding breadth.
- Roadmap order should respect dependencies.
- Product quality should not be sacrificed for feature count.

## Batch Canon Boundary

Batches may introduce new canon only when:

```text
Explicitly labeled as a canon proposal.
```

Rules:

- Normal implementation batches should follow existing canon.
- If a batch discovers a gap, it should create a canon proposal or decision-log entry rather than silently inventing product behavior.
- Codex should not casually reinterpret Ambitions' identity, IA, naming, trust model, data posture, or launch scope.

## Canon Conflict Handling

When a batch conflicts with canon:

```text
Pause and resolve conflict.
```

Rules:

- Do not implement through known canon conflict.
- Do not let Codex choose between conflicting docs silently.
- Do not assume the newest doc wins unless source-of-truth precedence says so.
- Conflict resolution should update the relevant canon or decision log before implementation continues.

## Batch Completion Requirements

Batch completion requires:

```text
Acceptance gates pass and docs/status updated.
```

Completion is not enough when only:

- code compiles
- visuals look good
- a commit exists
- user says done without acceptance review
- happy path works but error/empty/accessibility/status is missing

Rules:

- Batches should update status docs/registry where applicable.
- Completion summaries should distinguish shipped, planned, and deferred work.
- Validation command expectations should be recorded or reported.

## Roadmap Ordering

Roadmap order should prioritize:

```text
Dependencies.
```

Dependency types:

- product dependency
- data/model dependency
- design-system dependency
- navigation/IA dependency
- trust/privacy dependency
- accessibility dependency
- platform integration dependency
- launch acceptance dependency

Rules:

- Do not build advanced surfaces before their trust and data foundations exist.
- Do not build broad UI polish before required shared components/tokens where that causes inconsistency.
- Do not build widgets/Live Activities before Today/Plan truth is stable.
- Do not build sync before export/trust/failure states are strong.

## Shipped / Planned / Deferred Discipline

Future roadmap docs should distinguish:

```text
Shipped.
Planned.
Deferred.
```

Rules:

- Do not blur planned canon with shipped capability.
- Do not market deferred behavior as available.
- Completion summaries should explicitly call out deferred items.
- Roadmap docs should keep advanced canon visible without pretending it is launch scope.

## Codex Prompt Requirements

Codex prompts should always include:

```text
Relevant canon docs.
Acceptance gates.
No-drift rules.
Validation command expectations.
```

A good Codex prompt should include:

- current batch name and scope
- current repo truth
- relevant source-of-truth docs
- explicit non-goals
- acceptance gates
- validation commands or expected validation behavior
- docs/status updates required
- no-drift rules
- shipped/planned/deferred handling

## Never During Batch Execution

Batch execution must never:

```text
Add tabs casually.
Rename canon casually.
Implement fake capability.
Skip validation/status updates.
```

Additional red flags:

- introduces a new object type without canon backing
- changes top-level IA without explicit canon change
- claims sync/export/AI capability before implementation
- hides unresolved product decisions inside code comments
- duplicates object ownership across surfaces
- adds visual novelty that weakens readability or action clarity

## Unresolved Questions

Unresolved questions become:

```text
Canon proposals or decision log entries.
```

Rules:

- Do not leave unresolved questions as random TODOs.
- Do not implement unresolved decisions as if settled.
- Use proposal language until decision is made.
- Once decided, update the decision log and focused canon doc where applicable.

## No-Drift Review Checklist

Before accepting a batch, verify:

- Does this follow the locked top-level IA?
- Does this preserve local-first/data truth?
- Does this avoid fake capability claims?
- Does this strengthen a coherent product loop?
- Does this respect accessibility and Focus Support rules?
- Does this preserve user control and trust boundaries?
- Does this update docs/status if scope or state changed?
- Does this clearly mark shipped/planned/deferred behavior?

## QA Acceptance Criteria

Roadmap/batch governance is acceptable when:

- Roadmap optimizes for coherent product loops.
- Batches introduce new canon only as explicitly labeled canon proposals.
- Canon conflicts pause implementation until resolved.
- Batch completion requires acceptance gates and docs/status updates.
- Roadmap order prioritizes dependencies.
- Roadmap docs distinguish shipped, planned, and deferred.
- Codex prompts include relevant canon docs, acceptance gates, no-drift rules, and validation command expectations.
- Batch execution never casually adds tabs, renames canon, implements fake capability, or skips validation/status updates.
- Unresolved questions become canon proposals or decision log entries.
- Governance prevents drift from the product Ambitions is becoming.

## Open Questions For Future Waves

- Should every batch have a standardized completion-summary template?
- Should canon proposals live in their own folder or inside decision docs?
- What exact validation commands should be required by batch type?
- Should shipped/planned/deferred status be added to every roadmap row?
- Should batch registry enforce dependency blocking rules?
