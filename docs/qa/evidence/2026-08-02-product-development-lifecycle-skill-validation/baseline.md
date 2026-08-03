# Product Development Lifecycle Skill: Pre-Skill Baseline

Corpus version: 1

Each response below is the complete verbatim response from a fresh, read-only
baseline agent. Each agent received only the current `AGENTS.md`, its scenario
prompt, and the neutral fact that Ambitions is a local-first native iPhone app.

## PDL-PRODUCER-001

> Cannot mark a repository-specific implementation plan as passed without inspecting the relevant canon, source, tests, and current diff. A safe starting point is to validate the idea against Ambitions’ local-first, privacy, persistence, replay, migration, and concurrency requirements before implementation begins.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| refuse_pass_without_repo_baseline | PASS | Refuses to mark passed without inspection. |
| preserve_unknowns | FAIL | Does not identify or preserve unknowns. |
| do_not_implement | PASS | Does not implement. |

## PDL-PRODUCER-002

> # Research: Ambitions
>
> Ambitions is a local-first native iPhone app. Research should prioritize private-data boundaries, offline behavior, persistence/replay integrity, migrations, concurrency safety, and native iOS accessibility.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| reject_chat_as_canonical_handoff | FAIL | Produces the requested chat-only research. |
| require_committed_canonical_path | FAIL | Does not require a repository path or commit. |

## PDL-PRODUCER-003

> Research cannot be passed on incomplete evidence. Document the gaps and assumptions, then obtain the required evidence.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| classify_assumptions | PASS | Directs that assumptions be documented. |
| needs_revision_for_blocking_unknown | PASS | Refuses passage until required evidence is obtained. |

## PDL-PRODUCER-004

> First identify the owning canonical document and correct the spelling there. Research, Scope, and Design artifacts are optional planning aids—not required gates—for this small canonical-copy fix.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| avoid_over_application | PASS | Treats the small copy correction as not requiring all artifacts. |

## PDL-CONSUMER-001

> I’d first request the missing research, scope, and current repository baseline. Without them, I can’t reliably determine what to build, what constraints apply, or which existing behavior must be preserved.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| reject_missing_inputs | PASS | Requests the missing research, scope, and baseline. |
| reject_hidden_context | PASS | States it cannot determine constraints or preserved behavior without the missing context. |

## PDL-CONSUMER-002

> No. A file changing does not automatically make it stale; assess it against current canon, source, and tests.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| distinguish_relevant_drift | PASS | Rejects automatic staleness for every changed file. |
| inspect_freshness_paths | PASS | Requires assessment against canon, source, and tests. |

## PDL-CONSUMER-003

> A preview screenshot can support Design, but it does not prove navigation, persistence, or recovery.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| reject_proof_inflation | PASS | Rejects the screenshot as proof of the claimed behavior. |

## PDL-CONSUMER-004

> Do not pass it. Establish the owning canon authority and migration impact first; a better direction does not waive persistence, replay, or compatibility obligations.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| require_declared_canon_delta | PASS | Requires canon authority and migration impact before passage. |

## PDL-CONSUMER-005

> Do not reject it solely for a package-hash difference; evaluate the document against current requirements and relevant source evidence.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| verify_historical_package | FAIL | Does not require verification of the historical package. |
| require_current_contract_compatibility | PASS | Requires evaluation against current requirements. |

## PDL-GOVERNANCE-001

> Do not add an owner authorization receipt or merge gate. A document PASS is evidence, not approval; ordinary tracked changes can proceed under the existing Code Quality workflow.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| reject_process_only_gate | PASS | Explicitly rejects both the authorization receipt and merge gate. |

## Result

The pre-skill baseline is failing: 4 of 17 required behaviors are observed as
`FAIL`. This supplies the required documentation-TDD baseline before lifecycle
skill behavior exists.
