# Visual command-contract canon amendment report

## Scope and outcome

- Branch: `codex/canon-visual-authority-rebaseline`
- Base SHA: `3c0957ebb2202f10de53975b2cb74e8f35253808`
- Authority posture: shadow canon only; no active-authority, Swift, Linear, Figma, network, account, persistence, runtime, or release-state mutation.
- Normative ownership: eight requirements in the existing Shell, Today, Capture, Goals, Time, You, and Trust owner specifications.
- Structured state contracts: 267.
- Structured commands: 328.
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

The final tracked receipt is bound to deterministic polished-repair commit `15beb50106a641ab3eb02ed10679dd425de69913`. Terminal semantic-repair commit `030cf73f38c6bab9a0096af7706e6a85644026a2` froze the earlier evaluated canon; validator commits `262327c04261deb43bfe3bd3e7ad1e9380c0c0ab` and `f11b414f342346dfd7200381d232045efb34de9a` closed proof-diff, deletion, and rename bypasses; final-regression commit `6e88b61414417cdaeaae9586c606f175de099e48` repaired the three exact discovery failures; polished-repair commit `15beb501` then closed the replacement review's malformed prose and duplicate-test docket and deterministically refreshed the canon, UX blueprint, and shadow goldens. Every receipt bound to an earlier evaluated commit is historical and was invalidated by the later non-proof change.

The polished independently reviewed result is old 26 / new 28 with overall verdict `new_better`. No dimension is `old_better`: relevant-law recall and source ownership are `new_better`; semantic equivalence, contradiction control, unauthorized assumptions, validation completeness, and proof discipline are equivalent. The receipt records only hashes, attribution, scores, verdicts, and the closed claim ceiling; it does not retain response prose or comparator rationale. This report is part of the final proof-only commit; that commit SHA remains pending until Git creates it and cannot be self-referenced by the commit's own bytes.

Evidence bindings:

```text
canon SHA-256: 3b833fa70f1d8de70e1f737062e5b13c3bef4a5b3f1092ac23d0a4082f8ac172
old prompt SHA-256: 338c2088cc6a74dc06a3fc087bc6848280b117b7638aefdb377b9649face56cb
new prompt SHA-256: c896601011527dd8a744ce5886f71f31b6d363323cbaad4d378d9828afa4e495
old response SHA-256: f8e73052af92ad97e4f686730190e15532c5107328060c5c9ac8272aa9bd9834
new response SHA-256: 4775ffde298474605060b6d6a1e824e7319ea15eac030cb3cd1fee923297b0e9
comparison SHA-256: 766308d15fd75bf1c083f545ea2cc64c134daeb12fe9f426377d87e584970bf8
comparison totals: old 26 / new 28
overall verdict: new_better
```

Strict polished receipt TDD began from the unchanged stale receipt after deterministic commit `15beb501`. `uv run --python 3.12 --no-project python -m unittest tests.canon.test_semantic_receipt` failed as expected with exit 1: 13 tests ran with five failures and one error headed by `SEMANTIC_RECEIPT_STALE`; canon, new prompt, and all pack bindings differed. The offline checked-in CLI, `uv run --python 3.12 --no-project python scripts/ambitions-canon.py semantic-review --check-receipt`, also failed closed with exit 1 and `SEMANTIC_RECEIPT_STALE` before the receipt was updated. The synthetic `old_better` policy fixture was mechanically realigned to the polished comparison's unchanged 26/28 arithmetic so it continues to reach `SEMANTIC_RECEIPT_POLICY` without weakening validation. Final Green results are recorded below after verification.

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

### Fail-closed evaluated-commit validator repairs

The existing validator incorrectly equated the evaluated checkout with the latest commit touching a partial hard-coded task-pack path set. That resolved `1e81d170` even though terminal semantic repair `030cf73f` changed canon and generated bytes. The stronger law permits an evaluated commit only when it is an ancestor and every tracked path changed after it is in the exact closed proof-only allowlist: this report, the tracked receipt, and the receipt test. Existing evaluated-byte, ancestor, and deterministic regenerated-binding checks remain mandatory.

Focused validator RED: exit 1. Three tests proved that proof-only ancestor acceptance failed under the old latest-path rule and that changed canon/compiler paths produced the wrong invalid verdict rather than `SEMANTIC_RECEIPT_STALE`. Focused GREEN: exit 0; 3 tests passed in 0.005 seconds. Benchmark/parser regression: exit 0; 64 tests passed in 81.958 seconds. `git diff --check` exited 0 before deterministic validator commit `262327c04261deb43bfe3bd3e7ad1e9380c0c0ab` was created.

The ignored semantic bundle was regenerated at `262327c`: command exit 0, 22 files, status `comparison_recorded`. Canon hash, both prompt hashes, all sixteen task-pack hashes, both response hashes, comparison hash, 26/28 scores, and `new_better` verdict were byte-identical to the approved evidence. No model was rerun.

Important re-review then found that the changed-path command excluded deletions and could allow rename detection to hide a forbidden source behind an allowed proof destination. Strict focused RED used temporary tracked repositories: deletion of a canon specification and rename of a forbidden Swift source into an allowlisted proof path both raised no error under the old command, so 2 tests failed with exit 1. The minimum deterministic repair changed the offline inspection to `git diff --name-only --no-renames --diff-filter=ACMDRTUXB <evaluated>..HEAD --`. Deletions are now included, and a rename is exposed as source deletion plus destination addition; both paths must independently belong to the exact three-path proof allowlist.

Focused validator GREEN: exit 0; 5 tests passed in 0.300 seconds, including the prior ancestor, non-proof, non-ancestor, and evaluated-byte coverage. Full receipt GREEN before commit: exit 0; 13 tests passed in 36.561 seconds. Benchmark/parser regression: exit 0; 64 tests passed in 83.539 seconds. `git diff --check` exited 0 before deterministic Important-repair commit `f11b414f342346dfd7200381d232045efb34de9a` was created.

The ignored semantic bundle was regenerated again at `f11b414f`: command exit 0, 22 files, status `comparison_recorded`. Canon hash, both prompt hashes, all sixteen task-pack hashes, both response hashes, comparison hash, 26/28 scores, `new_better` verdict, and semantic-review record hash `318d4ac4c484b4db69d46f59fa9b60d32b290b74881299058778fa5314abbaf4` were byte-identical. No model was rerun.

### Final discovery regression repair

The final Python 3.12 discovery run was Red: exit 1; 732 tests ran with three failures and two skips. The failures were exactly mutable implementation-posture language in one Time precondition and three repeated You permanent-deletion consequences, omission of the explicit `irreversible` token from the non-mutating permanent-delete `Done` durable effect, and fourteen stale shadow render goldens.

The bounded repair changed the Time precondition to stable normative phrasing and made all three repeated permanent-delete consequences state that the existing irreversible deletion result keeps the destroyed scope unavailable. `Done` remains non-mutating, creates no Receipt or canonical commit, and cannot repeat deletion, invent restore authority, or reopen correction. The canon build and UX-blueprint writer regenerated deterministic projections, and all fourteen shadow golden files were refreshed byte-for-byte from the live `render_outputs` projection. No test expectation was weakened.

The three exact former failures passed in 1.083 seconds with exit 0 before commit and in 1.079 seconds with exit 0 after commit. Covering state semantics, Task 19, semantic-repair, and shadow-golden tests passed 59 tests in 31.730 seconds with one skip and exit 0. Audit, build check, UX-blueprint check, and `git diff --check` were Green. The receipt check remained intentionally stale after the non-proof canon change. Deterministic repair commit: `6e88b61414417cdaeaae9586c606f175de099e48`, exactly 33 files: two specifications, fourteen canon-generated projections, three UX-blueprint files, and fourteen shadow goldens. Per controller instruction, full discovery was not rerun after the exact repair.

The fresh semantic record binds canon `fb9d0e3a`, new prompt `9723a35f`, all sixteen regenerated pack hashes, old response `f8e73052`, final-regression new response `064e5e1f`, and final-regression comparison `a8728725`. The accepted comparison remains old 26 / new 28, overall `new_better`, with no `old_better` dimension.

### Replacement review repair

The replacement exact-range review returned 0 Critical, 2 Important, and 1 Minor findings. The first Important finding identified 150 literal malformed `, /` separators across the seven normative command-contract specifications. The second Important finding required the durable summary and generated projections to use the current parsed inventory of 267 state contracts and 328 commands rather than retaining 330 as current. The Minor finding identified one duplicate identical unknown-verdict malformed case in the semantic-receipt test.

Strict focused TDD added one seven-spec regression. RED: exit 1; one test failed with `150 != 0`. The bounded mechanical repair replaced only literal `, /` with grammatical `, or ` in app/shell, global/capture, global/trust-inspection, and Goals, Time, Today, and You specifications. It rewrote no other slash alternatives or semantics. The UX validator's pre-existing broad `or` rejection then failed on grammatical effect prose; the minimum coupled repair retained rejection of combined command labels while narrowing the check to the parsed command label rather than the entire transition sentence. The duplicate unknown-verdict case was removed without weakening the remaining malformed-verdict and closed-schema coverage.

Focused GREEN: exit 0; the new regression passed with zero malformed occurrences. Covering state semantics, Task 19 posture, semantic repairs, golden render, parser, and UX checks passed 83 tests in 48.167 seconds with exit 0. The parsed inventory remained exactly 267 state contracts and 328 commands. Audit, deterministic build check, UX-blueprint check, and `git diff --check` were Green. All fourteen shadow goldens were regenerated and byte-matched the live outputs; thirteen produced tracked diffs. The receipt remained correctly stale after the canon change. Deterministic polished-repair commit: `15beb50106a641ab3eb02ed10679dd425de69913`, exactly 40 files, excluding the durable report and receipt JSON.

The polished semantic record binds canon `3b833fa7`, new prompt `c8966010`, all sixteen regenerated pack hashes, old response `f8e73052`, polished new response `4775ffde`, and polished comparison `766308d1`. The accepted comparison is old 26 / new 28, overall `new_better`, with relevant-law recall and source ownership `new_better`, the other five dimensions equivalent, and no `old_better` dimension.

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
| polished receipt unittest before update | 1 expected | 13 tests; 5 failures and 1 error headed by `SEMANTIC_RECEIPT_STALE` |
| polished receipt check before update | 1 expected | `SEMANTIC_RECEIPT_STALE`; prior receipt predates evaluated commit `15beb501` |
| final focused receipt unittest | 0 | 13 tests passed in 36.589 seconds against the polished bindings and closed proof-only diff |
| final `ambitions-canon.py semantic-review --check-receipt` | 0 | Green; 8 packs, `new_better`, scores 26/28 |
| `git diff --check` | 0 | clean |

The final proof-only receipt update changes no canon, specification, compiler, generated, fixture, or response-evidence bytes. It records the controller-supplied polished comparison against evaluated deterministic commit `15beb501` and remains a non-CI shadow comparison only.

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

Mechanically generated with `git diff --name-only 3c0957ebb2202f10de53975b2cb74e8f35253808` for the complete `3c0957e..HEAD` repair range: 71 tracked paths. Thirteen shadow-golden paths were already present in the earlier range; the deterministic fourteen-golden refresh adds only the previously unchanged `external-reference-impact.md` path, so Git's exact union increases by one rather than fourteen.

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
tests/canon/golden/shadow/external-reference-impact.md
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

The exact review of `3c0957e..bc5e1e82` returned one Critical semantic-contract finding, one Important report/evidence finding, and one Minor prose finding. Semantic-repair commit `030cf73f` addresses the semantic docket; validator commit `262327c` closes the evaluated-commit binding defect; Important-repair commit `f11b414f` closes deletion and rename bypasses; final-regression commit `6e88b614` closes the three exact full-discovery failures and refreshes all fourteen shadow goldens. The replacement exact-range review then returned 0 Critical, 2 Important, and 1 Minor findings; polished-repair commit `15beb501` closes all three by repairing 150 malformed separators, replacing stale current inventory counts with 267 state contracts and 328 commands, removing the duplicate test case, and refreshing every affected deterministic projection. The final proof-only commit records the fresh independently supplied comparison. Specification-compliance and code-quality re-review of `3c0957e..HEAD` remain required after commit.

Residual Minor finding: add further focused duplication assertions if later schema evolution permits semantically equal but byte-distinct cross-document command records. The current inline global duplicate-ID regression is Green.

## Rollback and claim ceiling

Rollback before the proof-only commit: discard the three-file bounded worktree diff and return to `15beb50106a641ab3eb02ed10679dd425de69913`. Rollback of only the final proof-only commit after creation: revert `HEAD`. Rollback of the complete multi-commit amendment range: revert the final proof-only `HEAD`, then `15beb50106a641ab3eb02ed10679dd425de69913`, then prior proof commit `d0461881077f8ddc9f01520c31b67b82c01aa247`, then `6e88b61414417cdaeaae9586c606f175de099e48`, then prior proof commit `4cbdfcc9c1ef7018b208255a65f6051ff9ec9d92`, then `f11b414f342346dfd7200381d232045efb34de9a`, then earlier proof commit `534941616edc1dac34d94fc184435b51593e3c79`, then `262327c04261deb43bfe3bd3e7ad1e9380c0c0ab`, then `030cf73f38c6bab9a0096af7706e6a85644026a2`, then `bc5e1e82dbbc506b562fc763e9ea92dba965b88d`, then `1e81d170e997e6895b92cdc080563b28b60ac636` in reverse order, restoring base SHA `3c0957ebb2202f10de53975b2cb74e8f35253808` without rewriting published history.

Allowed claim after final receipt verification and before re-review: deterministic shadow-canon repair candidate only; focused parser/state/schema/UX-blueprint/build, validator, and explicit non-CI semantic-receipt evidence is Green for the exact commands above, and independent re-review remains pending. Four continuity variants remain structured but future-gated.

Forbidden claims: active authority cutover; source UI implemented; Runtime Green; rendered-app Visual Green; Accessibility Green; privacy/legal approval; device readiness; TestFlight readiness; App Store readiness; Release Green.
