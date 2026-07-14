# Visual command-contract canon amendment report

## Scope and outcome

- Branch: `codex/canon-visual-authority-rebaseline`
- Base SHA: `3c0957ebb2202f10de53975b2cb74e8f35253808`
- Authority posture: shadow canon only; no active-authority, Swift, Linear, Figma, network, account, persistence, runtime, or release-state mutation.
- Normative ownership: eight requirements in the existing Shell, Today, Capture, Goals, Time, You, and Trust owner specifications.
- Structured state contracts: 267.
- Structured commands: 330.
- Future-gated continuity contracts: 4.
- Authority-eligible active states: 263.
- Retained specification gaps: 12.
- Canon requirements and concept owners: 449.

The eight approved command-contract gaps are removed only after every affected state is bound to a parsed specification-owned `state_command_contracts` record. The compiler rejects missing, duplicate, unknown, unsorted, non-local, lexically unowned, or blueprint-drifted contracts. The four Time/You continuity variants remain structured but ineligible while `SYSTEM-CONTINUITY-DISABLED-001` is active. The You continuity-disabled state exposes review only and does not authorize enablement or sync.

## TDD evidence

Observed RED command:

```text
uv run --python 3.12 --no-project python -m unittest \
  tests.canon.test_parser \
  tests.canon.test_model \
  tests.canon.test_ux_blueprint \
  tests.canon.test_ux_blueprint_whole_range_repair
```

Observed RED result: exit 1; 70 tests ran with seven failures and one error. The parser rejected `state_command_contracts` as unknown, the requirement/disposition count remained 441 instead of 449, the gap count remained 20 instead of 12, and no state had independent structured command ownership.

Focused GREEN command:

```text
uv run --python 3.12 --no-project python -m unittest \
  tests.canon.test_parser \
  tests.canon.test_model \
  tests.canon.test_ux_blueprint \
  tests.canon.test_ux_blueprint_whole_range_repair
```

Focused GREEN result: exit 0; 71 tests ran in 23.206 seconds, all passed. The embedded deterministic UX-blueprint check reported 47 screens, 47 state models, 423 taxonomy rows, 433 state variants, 18 objects, 12 journeys, 449 requirements, 324 visual dispositions, 125 nonvisual dispositions, and shadow authority.

Negative coverage includes closed/missing fields, duplicate command IDs in one specification, unsorted arrays, blueprint self-assertion, exact structured-contract drift, missing independent structured ownership, invalid evidence, future-gated ineligibility, and preservation of the unrelated twelve-gap inventory.

### Independent-review repair TDD

Independent review of `3c0957e..b2324b2` found two Critical defects and one Important defect: all 267 state rows and 330 commands still shared formulaic/self-referential semantics; the semantic-comparison receipt had been rebound without a fresh blinded evaluation; and the schema did not enforce unique state/command arrays or the sole no-command exception. The repair treated those three findings as one fail-closed change.

The review-repair RED command was:

```text
uv run --python 3.12 --no-project python -m unittest \
  tests.canon.test_state_command_semantics
```

RED result: exit 1; 11 tests ran with 91 semantic subtest failures and one schema error. The failures proved the state-ID interpolation, indistinguishable command semantics, Shell/Capture/Goals/Time/Today/You/Trust consequence gaps, missing global cross-specification command-ID rejection, and missing schema closure.

The minimum repair rewrote all 267 state narratives and all 330 command records across the eight owner families with exact destinations, effects, commit posture, durable results, rollback/recovery, privacy, accessibility focus, and state-specific visible evidence. It added parser rejection for generic/self-referential semantics and indistinguishable in-state commands, global duplicate-command coverage, schema `uniqueItems`, and the conditional empty-command exception only for Trust no-disclosure. No code-owned semantic policy registry was added.

Focused semantic/parser/schema GREEN command:

```text
uv run --python 3.12 --no-project python -m unittest \
  tests.canon.test_state_command_semantics \
  tests.canon.test_parser \
  tests.canon.test_model \
  tests.canon.test_manifest.ManifestTests.test_all_schema_documents_are_valid_closed_json_objects
```

GREEN result: exit 0; 56 tests ran in 0.460 seconds, all passed. A later controller covering run exposed four exact copy/authority regressions; the four failing methods were repaired and rerun first, passing 4 tests in 2.894 seconds.

### Hard semantic-gate source-owner repair

The valid frozen-input comparison scored old/new 27/27 and identified only `source_ownership` as `old_better` (4 versus 3). The bounded repair changed no command semantics, concept ownership, task-pack selection logic, registry, runtime source, or model evidence.

The four primary benchmark fixture arrays were strengthened first. This exact focused command then proved the omissions:

```text
uv run --python 3.12 --no-project python -m unittest \
  tests.canon.test_benchmark.BenchmarkTest.test_fixture_semantics_trace_to_separately_authored_scenario_intent
```

RED result: exit 1; one test produced four subtest failures for `today-swiftui`, `time-recurrence`, `capture-proposal`, and `accessibility-repair`. The diffs contained only the newly required owner roots. After extending only the existing Today, Event, Step, Capture, and Accessibility `source_owners` arrays, the same command passed one test in 0.195 seconds. The release-proof fixture was then mechanically aligned because it directly includes `STANDARD-ACCESSIBILITY`.

The first focused `tests.canon.test_benchmark` run exposed one remaining stale hard-coded accessibility owner assertion: 40 tests ran in 82.151 seconds with one failure. Aligning that existing assertion, including its two absent-path checks by owner path rather than array index, produced the final focused result: 40 tests in 82.312 seconds, all passed.

## Verification

The 714-test discovery and broad audit rows previously recorded for implementation commit `b2324b2` are historical pre-review evidence. Per controller instruction, they were not rerun after the independent-review repair and are not presented as current-final proof.

Historical frozen-candidate evidence and current repair status:

### Fresh semantic comparison receipt

The final tracked receipt is bound to deterministic validator/evaluated commit `262327c04261deb43bfe3bd3e7ad1e9380c0c0ab`. Terminal semantic-repair commit `030cf73f38c6bab9a0096af7706e6a85644026a2` froze the evaluated canon and task-pack bytes; `262327c` then strengthened only the offline receipt validator and its focused tests. Regeneration at `262327c` proved the canon, old/new prompts, all sixteen pack hashes, old/new response hashes, comparison hash, scores, and verdict byte-identical to the already approved final evidence, so no model was rerun.

The independently reviewed result is old 26 / new 28 with overall verdict `new_better`. No dimension is `old_better`: relevant-law recall and unauthorized-assumption control are `new_better`; semantic equivalence, contradiction control, source ownership, validation completeness, and proof discipline are equivalent. The receipt records only hashes, attribution, scores, verdicts, and the closed claim ceiling; it does not retain response prose or comparator rationale. This report is part of the final proof-only commit; that commit SHA remains pending until Git creates it and cannot be self-referenced by the commit's own bytes.

Evidence bindings:

```text
canon SHA-256: 9f56bdf001a9ec6d33a9c383b6457e2ef2af3e52fa7b207eb168f16c873ed752
old prompt SHA-256: 338c2088cc6a74dc06a3fc087bc6848280b117b7638aefdb377b9649face56cb
new prompt SHA-256: 6a42ffa78634043744efd8866d1eb90302f7ad2da56338907d4c1e54e084978a
old response SHA-256: f8e73052af92ad97e4f686730190e15532c5107328060c5c9ac8272aa9bd9834
new response SHA-256: 15bd77ef9bb199644058a85ff6dff0b2d48b75fc0a2f1955971ba5b5a221e7c4
comparison SHA-256: 60e994110892cf84de35ed7ec3da6b1da361470bf6b11f1c5a02481d9e5eb884
comparison totals: old 26 / new 28
overall verdict: new_better
```

Strict final receipt TDD began from the unchanged stale receipt after validator commit `262327c`. `uv run --python 3.12 --no-project python -m unittest tests.canon.test_semantic_receipt` failed as expected with exit 1: 11 tests ran with five failures and one error headed by `SEMANTIC_RECEIPT_STALE`. The offline checked-in CLI, `uv run --python 3.12 --no-project python scripts/ambitions-canon.py semantic-review --check-receipt`, also failed closed with exit 1 and `SEMANTIC_RECEIPT_STALE` before the receipt was updated. Final Green results are recorded below after verification.

The receipt claim ceiling remains exactly: "This receipt records an explicit non-CI shadow comparison only. It does not authorize implementation or claim product, runtime, source, visual, accessibility, privacy, device, TestFlight, App Store, or release Green."

### Final contract-repair TDD and verification

The focused RED command was:

```text
uv run --python 3.12 --no-project python -m unittest \
  tests.canon.test_state_command_semantics
```

RED result: exit 1; 13 tests ran with seven intended failures. The failures proved the stale 330-command inventory, both cited malformed prose strings, and the four impossible terminal commands: repeated permanent deletion, restoration without a Trash identity, correction after completion, and correction controls in a state whose visible copy explicitly withholds them.

The minimum repair assigns `Done` only to those four terminal dismissal states, with state-specific return destinations and focus targets. Every replacement command is non-mutating, creates no Receipt, makes no canonical commit, and cannot reissue deletion, invent a restore identity, or reopen/commit correction. The owning requirement bodies name `Done`; the prior destructive/correction labels remain authorized only for states where the action is possible. The two reviewer-cited malformed strings and their byte-identical repetitions were repaired without a broad prose rewrite.

Focused GREEN: exit 0; 13 tests passed in 0.163 seconds. The final bounded parser/model/schema/UX-blueprint covering command passed 100 tests in 37.772 seconds with exit 0. Deterministic canon build and UX-blueprint writers refreshed the checked-in projections. Audit, traceability, build check, and UX-blueprint check are Green. Commit `030cf73f` is the terminal semantic repair: no later commit changes canon, specification, generated, fixture, or semantic evidence bytes.

### Fail-closed evaluated-commit validator repair

The existing validator incorrectly equated the evaluated checkout with the latest commit touching a partial hard-coded task-pack path set. That resolved `1e81d170` even though terminal semantic repair `030cf73f` changed canon and generated bytes. The stronger law permits an evaluated commit only when it is an ancestor and every tracked path changed after it is in the exact closed proof-only allowlist: this report, the tracked receipt, and the receipt test. The validator obtains the changed paths offline with `git diff --name-only --diff-filter=ACMRTUXB <evaluated>..HEAD --`; any canon, specification, generated, tool, compiler, fixture, malformed, duplicate, or other path fails `SEMANTIC_RECEIPT_STALE`. Existing evaluated-byte, ancestor, and deterministic regenerated-binding checks remain mandatory.

Focused validator RED: exit 1. Three tests proved that proof-only ancestor acceptance failed under the old latest-path rule and that changed canon/compiler paths produced the wrong invalid verdict rather than `SEMANTIC_RECEIPT_STALE`. Focused GREEN: exit 0; 3 tests passed in 0.005 seconds. Benchmark/parser regression: exit 0; 64 tests passed in 81.958 seconds. `git diff --check` exited 0 before deterministic validator commit `262327c04261deb43bfe3bd3e7ad1e9380c0c0ab` was created.

The ignored semantic bundle was regenerated at `262327c`: command exit 0, 22 files, status `comparison_recorded`. Canon hash, both prompt hashes, all sixteen task-pack hashes, both response hashes, comparison hash, 26/28 scores, and `new_better` verdict were byte-identical to the approved evidence. No model was rerun.

| Command | Exit | Result |
| --- | ---: | --- |
| focused semantic/parser/model/schema unittest | 0 | 56 tests passed in 0.460 seconds |
| four exact controller-failure methods | 0 | 4 tests passed in 2.894 seconds |
| parser/state semantics/UX blueprint/whole-range covering set | 0 | 125 tests passed in 65.775 seconds |
| exact benchmark owner-trace TDD | 0 | 1 test passed in 0.195 seconds after four-scenario Red |
| focused `tests.canon.test_benchmark` | 0 | 40 tests passed in 82.312 seconds |
| `ambitions-canon.py audit` | 0 | Green; 61 documents, 449 requirements, 449 concepts, shadow authority |
| `ambitions-canon.py traceability --check` | 0 | Green; 449 requirements, 19 references, 1,044 shadow posture gaps |
| `ambitions-canon.py build --check` | 0 | Green; generated outputs current |
| `ambitions-canon.py benchmark` | 0 | Green; 8 scenarios, deterministic report, 16 representative pack files |
| `ambitions-canon.py ux-blueprint --check` | 0 | Green; 47 screens, 47 state models, 423 taxonomy rows, 433 variants, 18 objects, 12 journeys, 449 requirements, 324 visual and 125 nonvisual dispositions |
| final receipt unittest before update | 1 expected | 11 tests; 5 failures and 1 error headed by `SEMANTIC_RECEIPT_STALE` |
| final receipt check before update | 1 expected | `SEMANTIC_RECEIPT_STALE`; prior receipt predates evaluated commit `262327c` |
| final focused receipt unittest | 0 | 11 tests passed in 35.976 seconds against the exact final bindings and closed proof-only diff |
| final `ambitions-canon.py semantic-review --check-receipt` | 0 | Green; 8 packs, `new_better`, scores 26/28 |
| `git diff --check` | 0 | clean |

The final proof-only receipt update changes no canon, specification, compiler, generated, fixture, or response-evidence bytes. It records the controller-supplied final blinded comparison against evaluated validator commit `262327c` and remains a non-CI shadow comparison only.

### Generated representative-pack owner sets

`today-swiftui`:

```text
Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/
Native/Ambitions/Core/LocalRuntimeOS/Projections/
Native/Ambitions/Core/LocalRuntimeOS/Scheduling/
Native/Ambitions/DesignSystem/
Native/Ambitions/Quality/
Native/Ambitions/Stage/
Native/Ambitions/Surfaces/Today/
```

`time-recurrence`:

```text
Native/Ambitions/Core/Domain/
Native/Ambitions/Core/LocalRuntimeOS/Commands/
Native/Ambitions/Core/LocalRuntimeOS/EventJournal/
Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/
Native/Ambitions/Core/LocalRuntimeOS/Inspection/
Native/Ambitions/Core/LocalRuntimeOS/Planning/
Native/Ambitions/Core/LocalRuntimeOS/Projections/
Native/Ambitions/Core/LocalRuntimeOS/Scheduling/
Native/Ambitions/Core/LocalRuntimeOS/State/
Native/Ambitions/Core/LocalRuntimeOS/Storage/
Native/Ambitions/Core/LocalRuntimeOS/Transactions/
Native/Ambitions/Core/Time/
Native/Ambitions/Quality/
Native/Ambitions/Surfaces/Goals/
Native/Ambitions/Surfaces/Time/
Native/Ambitions/Surfaces/Today/
```

`capture-proposal`:

```text
Native/Ambitions/Composer/Capture/
Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/
Native/Ambitions/Core/LocalRuntimeOS/Commands/
Native/Ambitions/Core/LocalRuntimeOS/EventJournal/
Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/
Native/Ambitions/Core/LocalRuntimeOS/Inspection/
Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/
Native/Ambitions/Core/LocalRuntimeOS/Projections/
Native/Ambitions/Core/LocalRuntimeOS/Scheduling/
Native/Ambitions/Core/LocalRuntimeOS/State/
Native/Ambitions/Core/LocalRuntimeOS/Storage/
Native/Ambitions/Core/LocalRuntimeOS/Transactions/
Native/Ambitions/Quality/
```

`accessibility-repair`:

```text
Native/Ambitions/Composer/
Native/Ambitions/DesignSystem/
Native/Ambitions/Interaction/Accessibility/
Native/Ambitions/Quality/Accessibility/
Native/Ambitions/Rendering/
Native/Ambitions/Stage/
Native/Ambitions/Surfaces/
```

Mechanically affected `release-proof-claim`:

```text
Native/Ambitions/Composer/
Native/Ambitions/DesignSystem/
Native/Ambitions/Diagnostics/
Native/Ambitions/Interaction/Accessibility/
Native/Ambitions/Quality/
Native/Ambitions/Quality/Accessibility/
Native/Ambitions/Rendering/
Native/Ambitions/Stage/
Native/Ambitions/Surfaces/
docs/canon/
scripts/
tools/ambitions_canon/
```

### Exact full-range changed-file list

Mechanically generated with `git diff --name-only 3c0957ebb2202f10de53975b2cb74e8f35253808` for the complete `3c0957e..HEAD` repair range: 70 tracked paths.

```text
.superpowers/sdd/visual-command-contract-amendment-report.md
docs/canon/generated/CODEX_START_HERE.md
docs/canon/generated/INDEX.md
docs/canon/generated/canon-index.json
docs/canon/generated/codex-consumption-benchmark.md
docs/canon/generated/concept-ownership.json
docs/canon/generated/external-reference-impact.md
docs/canon/generated/law-proof-map.json
docs/canon/generated/law-source-map.json
docs/canon/generated/law-test-map.json
docs/canon/generated/object-boundary-matrix.md
docs/canon/generated/requirement-graph.json
docs/canon/generated/specification-coverage.md
docs/canon/generated/supersession-manifest.json
docs/canon/generated/unresolved-conflicts.md
docs/canon/generated/visual-authority-manifest.json
docs/canon/migration/UX_BLUEPRINT.md
docs/canon/migration/impact-reference-index.json
docs/canon/migration/ux-blueprint-requirement-dispositions.json
docs/canon/migration/ux-blueprint.json
docs/canon/schemas/specification.schema.json
docs/canon/schemas/ux-blueprint.schema.json
docs/canon/specifications/app/shell.md
docs/canon/specifications/global/capture.md
docs/canon/specifications/global/trust-inspection.md
docs/canon/specifications/objects/event.md
docs/canon/specifications/objects/step.md
docs/canon/specifications/surfaces/goals.md
docs/canon/specifications/surfaces/time.md
docs/canon/specifications/surfaces/today.md
docs/canon/specifications/surfaces/you.md
docs/canon/standards/accessibility.md
docs/qa/evidence/2026-07-13-train-4-semantic-comparison/receipt.json
tests/canon/fixtures/benchmarks/01-today-swiftui.json
tests/canon/fixtures/benchmarks/02-time-recurrence.json
tests/canon/fixtures/benchmarks/03-capture-proposal.json
tests/canon/fixtures/benchmarks/07-accessibility-repair.json
tests/canon/fixtures/benchmarks/08-release-proof-claim.json
tests/canon/fixtures/ux-blueprint-final-all-corpus-copy-fixtures.json
tests/canon/golden/shadow/CODEX_START_HERE.md
tests/canon/golden/shadow/INDEX.md
tests/canon/golden/shadow/canon-index.json
tests/canon/golden/shadow/concept-ownership.json
tests/canon/golden/shadow/law-proof-map.json
tests/canon/golden/shadow/law-source-map.json
tests/canon/golden/shadow/law-test-map.json
tests/canon/golden/shadow/object-boundary-matrix.md
tests/canon/golden/shadow/requirement-graph.json
tests/canon/golden/shadow/specification-coverage.md
tests/canon/golden/shadow/supersession-manifest.json
tests/canon/golden/shadow/unresolved-conflicts.md
tests/canon/golden/shadow/visual-authority-manifest.json
tests/canon/test_audit.py
tests/canon/test_benchmark.py
tests/canon/test_parser.py
tests/canon/test_semantic_receipt.py
tests/canon/test_state_command_semantics.py
tests/canon/test_ux_blueprint.py
tests/canon/test_ux_blueprint_all_corpus_review.py
tests/canon/test_ux_blueprint_final_review.py
tests/canon/test_ux_blueprint_full_corpus_review.py
tests/canon/test_ux_blueprint_independent_review.py
tests/canon/test_ux_blueprint_matrix_repairs.py
tests/canon/test_ux_blueprint_review_repairs.py
tests/canon/test_ux_blueprint_semantic_repairs.py
tests/canon/test_ux_blueprint_whole_range_repair.py
tools/ambitions_canon/benchmark.py
tools/ambitions_canon/model.py
tools/ambitions_canon/parser.py
tools/ambitions_canon/ux_blueprint.py
```

## Generated outputs

The deterministic canon build and UX-blueprint writer refresh the canon index, requirement graph, ownership/source/test/proof maps, coverage and benchmark projections, visual-authority manifest, UX blueprint Markdown, and requirement-disposition projection. Outputs contain no volatile timestamp and remain newline-terminated.

## Review and findings

The exact review of `3c0957e..bc5e1e82` returned one Critical semantic-contract finding, one Important report/evidence finding, and one Minor prose finding. Terminal semantic-repair commit `030cf73f` addresses the exact semantic docket; validator commit `262327c` closes the evaluated-commit binding defect without changing evaluated semantic bytes. The final proof-only commit records the independently supplied comparison. Specification-compliance and code-quality re-review of `3c0957e..HEAD` remain required after commit.

Residual Minor finding: add further focused duplication assertions if later schema evolution permits semantically equal but byte-distinct cross-document command records. The current inline global duplicate-ID regression is Green.

## Rollback and claim ceiling

Rollback before the proof-only commit: discard the three-file bounded worktree diff and return to `262327c04261deb43bfe3bd3e7ad1e9380c0c0ab`. Rollback of only the final proof-only commit after creation: revert `HEAD`. Rollback of the complete multi-commit amendment range: revert the final proof-only `HEAD`, then `262327c04261deb43bfe3bd3e7ad1e9380c0c0ab`, then `030cf73f38c6bab9a0096af7706e6a85644026a2`, then `bc5e1e82dbbc506b562fc763e9ea92dba965b88d`, then `1e81d170e997e6895b92cdc080563b28b60ac636` in reverse order, restoring base SHA `3c0957ebb2202f10de53975b2cb74e8f35253808` without rewriting published history.

Allowed claim after final receipt verification and before re-review: deterministic shadow-canon repair candidate only; focused parser/state/schema/UX-blueprint/build, validator, and explicit non-CI semantic-receipt evidence is Green for the exact commands above, and independent re-review remains pending. Four continuity variants remain structured but future-gated.

Forbidden claims: active authority cutover; source UI implemented; Runtime Green; rendered-app Visual Green; Accessibility Green; privacy/legal approval; device readiness; TestFlight readiness; App Store readiness; Release Green.
