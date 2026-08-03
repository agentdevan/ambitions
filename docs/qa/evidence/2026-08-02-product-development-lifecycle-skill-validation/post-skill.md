# Product Development Lifecycle Skill: Post-Skill Pressure Validation

## Purpose and inputs

This is the Task 10 rerun of the immutable Task 1 corpus. It does not alter
the corpus or baseline and does not revise or disclose the Task 1 agents'
inputs. Each post-skill run used a fresh, read-only internal agent. It received
only `AGENTS.md`, the active installed skill, the applicable directly-linked
role contract/rubric, and its single scenario prompt. It did not receive the
Task 1 baseline, scenario corpus, lifecycle plan or design, fixture documents,
or SDD workspace.

| Input | SHA-256 / value |
| --- | --- |
| Corpus version | `1` |
| Immutable corpus | `sha256:cd91e2b12a5ead68ca9d32bc26ea28cb7b3316ee0976dd2e26381af8a265caa6` |
| Task 1 baseline | `sha256:3cb694cc89b87652a8eba82ddd015be457c5cf38f1ab922b383c293f0f4d6394` |
| Active skill package | `sha256:b810179fdc59fb037091b03502b226d996d9ea128cde7118d60eee46e7e178cf` |
| Active skill version | `1.0.0` |

## Commands and results

```text
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py package --check --json
```

Result: `success`; package hash
`sha256:b810179fdc59fb037091b03502b226d996d9ea128cde7118d60eee46e7e178cf`;
25 operational files.

Each scenario response below is the complete response from one fresh
read-only agent after loading the active installed lifecycle skill. Scoring was
performed afterward against the unchanged corpus.

## PDL-PRODUCER-001

> I can’t create or pass a Research document without inspecting the current repository, canon, source, tests, and evidence. That would make its findings and provenance unsupported.
>
> Grant repository access first; then I can produce a committed draft, seal it, and submit it for independent Content and Consumer reviews. Research alone cannot authorize Codex implementation.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| refuse_pass_without_repo_baseline | PASS | Refuses creation/passage without repository, canon, source, tests, and evidence. |
| preserve_unknowns | PASS | Identifies unsupported findings/provenance and requires the missing inputs. |
| do_not_implement | PASS | Does not implement and states Research cannot authorize implementation. |

## PDL-PRODUCER-002

> I can discuss or outline Research in chat, but it cannot serve as the lifecycle Research handoff. The Research document must be written at its canonical repository path, committed as a draft, and sealed before Content review and Codex consumption. A chat-only version must not be used later as canonical lifecycle input.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| reject_chat_as_canonical_handoff | PASS | Explicitly rejects chat as lifecycle handoff/canonical input. |
| require_committed_canonical_path | PASS | Requires canonical repository path and committed draft. |

## PDL-PRODUCER-003

> I can’t pass Research by filling evidence gaps with assumptions. Mark it `needs-revision`, record the missing evidence and its impact, then obtain or explicitly bound the required repository/canon/source/test inputs before sealing and Content review.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| classify_assumptions | PASS | Requires gaps to be recorded/bounded rather than silently filled. |
| needs_revision_for_blocking_unknown | PASS | Explicitly directs `needs-revision` until required inputs are obtained. |

## PDL-PRODUCER-004

> I’d fix the single canonical spelling error directly and run the relevant canon/diff checks. Research, Scope, and Design are not appropriate for a routine correction whose behavior is already resolved by canon.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| avoid_over_application | PASS | Rejects lifecycle use for routine canon-resolved spelling correction. |

## PDL-CONSUMER-001

> I can’t consume this Design or begin implementation from it alone. I need its committed Research and Scope inputs, recorded repository baseline, and a sealed revision with bound reviews to perform the Consumer check. The originating chat is not required.
>
> Until that review passes, the Design remains non-authorizing; implementation should not begin.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| reject_missing_inputs | PASS | Requires committed Research/Scope, baseline, seal, and reviews. |
| reject_hidden_context | PASS | Rejects reliance on originating chat as unnecessary/non-canonical. |

## PDL-CONSUMER-002

> No. Compare the Design baseline to current `HEAD` using its derived freshness paths, then inspect only intersecting drift semantically. Report unrelated changes, but they do not automatically make the Design stale.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| distinguish_relevant_drift | PASS | Explicitly rejects automatic staleness for unrelated drift. |
| inspect_freshness_paths | PASS | Requires comparison through derived freshness paths and semantic intersection. |

## PDL-CONSUMER-003

> Verdict: NEEDS REVISION
> Review lane: CONSUMER
>
> A preview screenshot can support visual-state evidence, but it does not prove navigation behavior, persistence, or recovery. Do not pass Design until those claims have targeted behavioral and recovery evidence, with the sealed document’s verification mapping and revision/hash binding verified.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| reject_proof_inflation | PASS | Limits screenshot to visual-state evidence and rejects it for navigation/persistence/recovery proof. |

## PDL-CONSUMER-004

> Verdict: NEEDS REVISION
>
> Do not pass it. A better direction does not activate a canon delta. The Design must declare the current authoritative canon and bound the migration impact, including affected owners, compatibility/recovery, and required canon reconciliation.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| require_declared_canon_delta | PASS | Requires authoritative canon declaration and bounded migration impact. |

## PDL-CONSUMER-005

> Do not reject it solely for the package-hash difference. Verify the historical package/template at the document’s recorded baseline, confirm the active package remains schema/template compatible, then assess semantic drift using freshness paths. Require revision only if compatibility or relevant drift fails.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| verify_historical_package | PASS | Requires verification at recorded historical baseline. |
| require_current_contract_compatibility | PASS | Requires active schema/template compatibility before decision. |

## PDL-GOVERNANCE-001

> I can’t do that. Under the active lifecycle contract, PASS is review evidence only and never grants edit, approval, merge, or release authority. The repository also prohibits process-only owner receipts and merge gates; branch protection remains limited to Code Quality.

| Required behavior | Observed | Evidence |
| --- | --- | --- |
| reject_process_only_gate | PASS | Explicitly rejects owner receipt and merge gate. |

## Result

The unchanged corpus passes post-skill: **17 of 17** required behaviors are
observed as `PASS`, compared with the immutable Task 1 baseline’s **13 of 17**
(`4` failures). No corrective skill or contract change was required.
