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

Current frozen-candidate evidence:

### Fresh semantic comparison receipt

The deterministic task-pack commit is `1e81d170e997e6895b92cdc080563b28b60ac636`. The controller regenerated the ignored semantic-review bundle from that commit and supplied independently authored old-path, new-pack, and comparison evidence. The tracked receipt records only hashes, attribution, scores, verdicts, and the closed claim ceiling; it does not retain response prose or comparator rationale.

Evidence bindings:

```text
canon SHA-256: 542b43f356bfdca724a808681dbe91f0cfed1923a8e5aab683c50f7114779399
old prompt SHA-256: 338c2088cc6a74dc06a3fc087bc6848280b117b7638aefdb377b9649face56cb
new prompt SHA-256: a9e72e32d36bb9db1d00e95df3c76a91d8fb3c4abba80e23f542c992c8a371e6
old response SHA-256: f8e73052af92ad97e4f686730190e15532c5107328060c5c9ac8272aa9bd9834
new response SHA-256: 5468e8424bcaf9164ba8389105c42276e6b6485e99dfe42dd7a5e16909ca038a
comparison SHA-256: 49606fe860d37d39e6966e97480dc007818333e1386f077981a0218a47f88ac4
comparison totals: old 26 / new 28
overall verdict: new_better
```

Strict receipt TDD began from the unchanged historical receipt. `uv run --python 3.12 --no-project python -m unittest tests.canon.test_semantic_receipt` failed as expected with exit 1: 8 tests ran, producing 10 failures and 1 error headed by `SEMANTIC_RECEIPT_STALE`. The requested literal path `uv run --python 3.12 --no-project python tools/ambitions-canon.py semantic-review --check-receipt` does not exist in this repository and exited 2. The actual checked-in CLI path, `uv run --python 3.12 --no-project python scripts/ambitions-canon.py semantic-review --check-receipt`, then failed closed with exit 1 and `SEMANTIC_RECEIPT_STALE` before the receipt was updated.

The first focused post-update run correctly made the CLI Green but exposed one stale negative-test total inherited from the previous 25/28 receipt: 8 tests ran with one failure because schema validation preceded the intended `SEMANTIC_RECEIPT_POLICY` assertion. Updating that fixture total to the current 26/28 arithmetic preserved the negative policy case. The final focused unittest passed all 8 tests in 36.108 seconds with exit 0. The actual CLI then reported `GREEN ambitions canon semantic-review receipt packs=8 verdict=new_better scores=26/28` with exit 0, and `git diff --check` exited 0.

The receipt claim ceiling remains exactly: "This receipt records an explicit non-CI shadow comparison only. It does not authorize implementation or claim product, runtime, source, visual, accessibility, privacy, device, TestFlight, App Store, or release Green."

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
| `git show 3c0957e:<receipt> \| cmp - <receipt>` | 0 | tracked receipt bytes exactly equal the historical base receipt |
| `ambitions-canon.py semantic-review --check-receipt` | 1 expected | `SEMANTIC_RECEIPT_STALE`; pack-defining Today benchmark fixture bytes changed |
| `git diff --check` | 0 | clean |

The tracked semantic receipt is deliberately historical. It was restored byte-for-byte from `3c0957e` and MUST remain stale until the controller performs a fresh blinded old/new comparison against the frozen candidate. The receipt is not updated, rebound, or used to claim current semantic superiority in this repair.

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

### Frozen candidate file list

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
docs/canon/migration/ux-blueprint-requirement-dispositions.json
docs/canon/migration/ux-blueprint.json
docs/canon/schemas/specification.schema.json
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
tests/canon/test_benchmark.py
tests/canon/test_parser.py
tools/ambitions_canon/parser.py
tests/canon/test_state_command_semantics.py
```

## Generated outputs

The deterministic canon build and UX-blueprint writer refresh the canon index, requirement graph, ownership/source/test/proof maps, coverage and benchmark projections, visual-authority manifest, UX blueprint Markdown, and requirement-disposition projection. Outputs contain no volatile timestamp and remain newline-terminated.

## Review and findings

Independent review of `3c0957e..b2324b2`: two Critical and one Important finding repaired in the frozen candidate. Specification-compliance and code-quality re-review remain required before commit.

Residual Minor finding: add further focused duplication assertions if later schema evolution permits semantically equal but byte-distinct cross-document command records. The current inline global duplicate-ID regression is Green.

## Rollback and claim ceiling

Rollback before commit: discard the bounded worktree diff and return to base SHA `3c0957ebb2202f10de53975b2cb74e8f35253808`. Rollback after commit: revert the single amendment commit.

Allowed claim before fresh semantic evaluation and re-review: deterministic shadow-canon review-repair candidate frozen; parser/state/schema/UX-blueprint covering evidence Green for the exact commands above, with four continuity variants structured but future-gated.

Forbidden claims: active authority cutover; source UI implemented; Runtime Green; rendered-app Visual Green; Accessibility Green; privacy/legal approval; device readiness; TestFlight readiness; App Store readiness; Release Green.
