# Visual command-contract canon amendment report

## Important review-docket repair: command resolution and trusted approval history — 2026-07-16

### Bounded scope and claim posture

- Repair base SHA: `57943fd21a3afa268ef5ad680b28f0d1efd085eb`.
- Review authority: the two Important findings in
  `.superpowers/sdd/visual-command-identity-review.md`.
- Canon content SHA after the repair:
  `eb0a44125ec4814cec2c5a53f14d72c96b6539bb46b7fca9b90418a7ed6cc57b`.
- Authority posture: shadow only. This repair does not approve visual
  authority, perform Gate B, activate Purchase, or authorize implementation.
- Excluded scope: semantic evaluation, Figma, production Swift, runtime,
  product requirements, owner cutover, and release state.

This repair closes only the machine-identity and approval-history defects. It
does not change the `567` specification-owned commands or their product
semantics. Instead, it gives every declared machine identity an independently
allocated, source-bound registry record, and it makes any future approval
transition prove an exact immutable Git base plus an owner attestation. The
current Purchase dependency remains withheld, revision `1`, with no mappings,
no receipt, no owner approval, and no activation authorization.

### Important finding I1: independent command-resolution authority

`COMMAND-RESOLUTION-REGISTRY-001` revision `1` now contains exactly `2,330`
immutable records:

- `567` destinations, `567` success-focus records, `567` failure-focus
  records, and `567` recovery records;
- `36` inverse-command records and `12` recovery-handoff records, both typed
  as declared recovery commands rather than formula-only IDs;
- `10` checkpoint records, `2` irreversible confirmations, and `2`
  irreversible receipts.

Registry source SHA:
`9c87cc81b0a28131a1c1f51212f312ede8f3ac85578068a1357a789ede620c9c`.
Every record carries its exact owner, command, state, requirement, source-text
digest, full structured behavior digest, and record digest. The behavior digest
binds the command contract rather than merely binding generated ID text.
Missing records, duplicate identities, wrong owners, wrong command bindings,
source contradictions, behavior drift, and undeclared mechanisms fail closed.

The parser no longer manufactures a state-command machine contract or treats a
bare command-derived ID formula as proof. UX blueprints and task packs consume
compact immutable `{resolution_id, record_sha256}` references backed by the
independent registry. Canon audit and build entry points validate the complete
live command-bearing corpus before reporting Green. Exact source-SHA keyed
loading, exact contract-set validation caching, and compact consumer references
remove the initially observed whole-registry reconstruction hot path without
weakening any binding.

### Important finding I2: immutable trusted approval history

The command-gate dependency compiler now separates three deterministic byte
streams: the dependency registry, approval-receipt registry, and owner-approval
attestation registry. `COMMAND-GATE-OWNER-APPROVAL-REGISTRY-001` is revision
`1` and intentionally contains zero approvals. Dependency registry source SHA:
`9e3a82a758b544ba7a8730bf575a8f9912982e2ae6c1e09c8314267c2d4c9dad`.

An approved or receipted candidate must now supply a trusted approval base
loaded from exact Git object bytes. The loader accepts only full
`refs/heads/...` or `refs/remotes/...` names, requires the caller's exact
expected merge-base SHA, rejects ambiguous merge bases and self-selected
ancestor expressions, and reads each registry from that exact commit. The
candidate must preserve the trusted dependency, receipt, and owner-approval
prefixes byte-for-byte; increment a changed dependency revision exactly once;
append exactly one linked receipt; preserve historical receipt Canon SHAs;
resolve the approval identity to a trusted owner attestation; and bind the
dependency, mapping, Canon content, approved scope, and prior history hashes.
Whole-history replacement, receipt deletion, revision reuse, stale expected
bases, and self-attested task-pack approval all fail closed.

Withheld dependencies need no trusted approval context and remain buildable but
non-authorizing. Task-pack generation accepts an explicit trusted base only for
an approval transition; it has no candidate-as-history fallback. This repairs
the trust boundary without adding a SKU, plan, price, mapping, owner decision,
or cutover.

### TDD and performance evidence

The architectural RED was observed before production implementation: the
original `7` I1 tests plus all `10` I2 tests ran `17` tests and failed `17`.
The exact executable path from that first observation was not retained across
context compaction, so this report does not invent or attribute one.

A separate post-hoc confirmation then loaded those unchanged test definitions
against a detached clean checkout of
`57943fd21a3afa268ef5ad680b28f0d1efd085eb`, with both imports and test `ROOT`
bound to the detached parent and the pinned executable:

```text
/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12
```

That confirmation ran the original seven
`CommandResolutionRegistryTests` methods and all ten
`CommandGateTrustedHistoryTests` methods in `0.483s`: `17` failures, zero
errors, expected process exit `1`. The parent lacks both the independent
resolution API and the owner-attestation API, which is the intended
architectural RED. This post-hoc confirmation is supplemental and is not
represented as the original pre-implementation run.

Focused Green evidence on the repaired candidate:

- `tests.canon.test_command_resolution_registry`: `9` tests, `OK`, `5.276s`.
- `tests.canon.test_command_gate_trusted_history`: `10` tests, `OK`, about
  `27.7s`.
- `tests.canon.test_command_gate_dependencies`: `9` tests, `OK`, `43.595s`.
- `tests.canon.test_task_pack`: `52` tests, `OK`, `32.248s`.

The first frozen covering attempt was intentionally interrupted with exit `130`
after approximately eight minutes when profiling exposed an avoidable
per-command `2,330`-record reconstruction path. No assertion failure had
surfaced. The repair added exact immutable caches and compact references, then
reran the identical frozen state under a captured session. The authoritative
covering result is:

```text
Ran 270 tests in 486.757s
OK (skipped=1)
```

That exit-`0` command covered both new suites; the frozen visual command,
state-semantics, rebaseline, UX-blueprint review and repair suites; parser and
task-pack suites; shadow-golden byte equality; whole-train repairs; and the live
shadow audit. Its embedded UX-blueprint check remained Green with `47` screens,
`47` state models, `423` taxonomy states, `433` state variants, `18` objects,
`12` journeys, `461` requirements, `336` visual dispositions, `125` nonvisual
dispositions, and shadow authority.

### Final deterministic gates

The complete post-report gate stack exited `0`:

- `scripts/ambitions-canon.py audit`: Green, `61` documents, `461`
  requirements, `461` concepts, shadow authority.
- `scripts/ambitions-canon.py build --check`: Green, generated outputs current.
- `scripts/ambitions-canon.py ux-blueprint --check`: Green with the frozen
  `47/47/423/433/18/12/461/336/125` counts and shadow authority.
- `scripts/ambitions-canon.py coverage --fail-on-p0-gap`: Green, `61`
  documents and `5` profiles.
- `scripts/ambitions-canon.py traceability --check`: Green, `461`
  requirements, `20` references, and `1,044` honest shadow posture gaps.
- `scripts/ambitions-canon.py external-authority --kind figma --check`: Green,
  `11` references, zero reconciliation entities, shadow authority.
- `scripts/ambitions-truth-path-vocabulary-audit.py`: Green.
- `scripts/ambitions-constitution-audit.py`: Green, `124` laws, `34` source
  maps, and `34` test maps.
- `scripts/ambitions-remediation-governance-check.py`: Green, `41` changed
  paths, no changed production Swift, no changed support Swift, and no changed
  file over the Swift hard-line cap.
- `scripts/canon-language-drift-scan.sh`: exit `0`. Its changed-file Yellow is
  the existing explicit prohibition on emotional labels, productivity scores,
  streak pressure, hidden profiling, and hosted-model dependency projected into
  the regenerated blueprint; it does not authorize that language.
- Pinned Python 3.12 `compileall` over `tools/ambitions_canon` and `tests/canon`:
  exit `0` with no diagnostic.
- `git diff --check`: exit `0` with no output.

### Architecture-tree closeout

- Final Architecture Tree inspected: yes.
- Canonical product/runtime owners touched: none; this is canon compiler,
  registry, schema, deterministic projection, and test scope only.
- New files: the command-resolution registry and schema, owner-approval
  registry and schema, their two focused test modules, and
  `tools/ambitions_canon/command_resolution_registry.py`.
- Old/non-canonical paths removed: none. The obsolete parser-owned formula
  projection was removed from its existing module.
- Compatibility shims left behind: none.
- Yellow architecture debt introduced: none. Product/runtime implementation
  remains outside this repair's claim ceiling.
- Next repair train: none for these two docket findings; any future Purchase
  approval is a separate owner-authorized transition with its own trusted Git
  base and evidence.
- Equivalent-folder/path interpretation used: no.

### Claim ceiling

Allowed claim: Green only for the exact deterministic command-resolution
registry, source/behavior binding, trusted command-gate history transition, and
shadow consumer projection scope proven here.

Forbidden claims: semantic review complete, Figma updated, visual authority
approved, Gate B passed, Purchase activated, production Swift implemented,
runtime Green, rendered-app Visual Green, accessibility Green, privacy/legal
approved, device ready, TestFlight ready, App Store ready, or Release Green.

## Visual R1 owner-approved completion amendment — 2026-07-16

### Scope and deterministic posture

- Branch: `codex/canon-visual-owner-workshop`
- Base SHA: `f4909c6a611414ce1782bfaaec32e528ecf14968`
- Consolidated review-repair base SHA: `d3a7e29fd6d8dc421e6608f70a652f9847c728cb`.
- Authority posture: shadow canon and frozen visual candidate only.
- Normative additions: `12` stable requirements in existing specification owners.
- Newly resolved state contracts: `166`; total structured state contracts: `433`.
- Structured commands: `567` (`47` new requirement-local records; `138`
  unique approved labels and `239` state-bound records in the twelve approved
  command laws).
- Requirement/concept owners: `461`.
- Visual requirement dispositions: `336`; nonvisual dispositions: `125`.
- Current authority-eligible state contracts after a future approved Gate B: `411`.
- Future-gated continuity state contracts: `22`.
- Current command-contract specification gaps: `0`.
- Canon content SHA: `865157d4d1a8ec074d7b4d233e2e1c021b2eea1aeda6ab9392d63481c6d7d611`.
- Independent semantic-equivalence review binding: intentionally `candidate` and unbound while this exact deterministic delta awaits review.

The amendment resolves the approved Account, launch/setup, deep-link, degraded,
permission, Search, Time Detail, calendar-import, entitlement, continuity,
diagnostics, and notification command-contract gaps. Every affected state is
bound to one parsed specification owner. The UX blueprint retains no live gap
record or state gap reference. The compiler still permits a future explicit gap
only through the same closed, fail-closed structure, and a synthetic negative
test proves action-implying copy remains rejected for such a state.

Continuity remains structurally closed. Four disabled explanatory/review
continuity states are active; 22 non-disabled continuity states are
future-gated. Every future-gated state and command carries nonempty resolved
gates, projects no active command, and retains exact non-authorizing command-ID
metadata. This amendment does not activate continuity, approve visual
authority, pass Gate B, select task-pack visual authority, change production
Swift, modify Figma, or perform destructive cleanup.

### TDD evidence

Initial integration RED:

```text
PYTHONPATH=. python3.12 -m unittest tests.canon.test_visual_r1_command_contracts
```

Exit `1`; `16` tests ran and the expected failure proved that the blueprint
still retained the twelve approved command-contract gaps before mechanical
rebinding.

Adversarial parser RED then proved five missing fail-closed checks: duplicate
in-state command labels, unresolved destination/focus placeholders, and a
mutating command without explicit rollback/Undo posture. The minimum parser
repair rejects those forms without weakening existing command-ID, state-ID,
closed-field, owner, or lexical checks. The four exact adversarial methods then
passed `4/4`.

Frozen focused GREEN before the stale-regression repair:

```text
PYTHONPATH=. python3.12 -m unittest \
  tests.canon.test_visual_r1_command_contracts \
  tests.canon.test_state_command_semantics \
  tests.canon.test_visual_authority_rebaseline
```

Exit `0`; `46` tests passed in `27.689s`.

The first full Python 3.12 discovery was intentionally run once against that
candidate. It exited `1`; `765` tests ran in `1743.800s`, with `30` failures,
`6` errors, and `2` skips. The docket consisted of pre-resolution
`449/267/166/263/12-gap` assertions, four reviewed-copy fixture postures,
fourteen stale shadow goldens, twenty-three mutable-posture wording hits, and
the expected stale model-assisted semantic receipt. No receipt was rebound.

The consolidated deterministic repair updates the reviewed expectations to
`461/433/0/411/22`, preserves the frozen Phase 1 matrices as historical evidence,
repairs the Search conjunction and stable posture language, refreshes the UX and
generated projections, and byte-matches all fourteen shadow goldens. The
grammatical Search change updates exactly four semantic clause-owner hash/span
records; their independent-review binding remains deliberately unclaimed until
an exact reviewer covers this delta.

### Current verification

The evidence-recovery run of the exact deterministic covering command exited
`1`; `147` tests ran in `124.710s`, with `5` failures and `1` error. The complete
docket was confined to stale negative harnesses: a removed gap-state lookup, two
older validator-error expectations, a no-op authority-posture mutation, a ban on
historical explanatory posture prose, and a candidate-ledger self-promotion case
that no longer supplied a conflicting review binding. No canon behavior defect
was found.

The six exact negative harnesses were repaired without adding a matrix, fixture,
semantic dimension, or product scope. Their smallest rerun exited `0`; `6` tests
passed in `16.483s`. The one authorized rerun of the identical covering command
then exited `0`; all `147` tests passed in `131.359s`. Its deterministic
UX-blueprint check was Green with `47` screens, `47` state models, `423` taxonomy
states, `433` state variants, `18` objects, `12` journeys, `461` requirements,
`336` visual dispositions, `125` nonvisual dispositions, and shadow authority.
`git diff --check` also exited `0`.

The model-assisted semantic receipt remains intentionally stale and is excluded
from this deterministic covering set. No second full discovery or semantic
comparison is run before independent review.

Controller inspection then found one stale hand-record Canon content SHA. A new
focused hand/machine parity regression failed as expected on the hand value
`748214a51baa7373b24374b0253c2bc1d3ce3aea295a9875f5d0c3b0b8d466ee`
versus the machine value
`37ca3d028309c10537e359cc5d9e95dbbc54b40b5a10557e1f34d08ffb90281c`;
the independently computed hand and machine count digests already matched at
`39c7e4e128b1a016a9f36d7fa73df42d7497a6a99ff7823e807f6f63d2e07406`.
After changing only that stale hand SHA, the focused regression exited `0` with
`1` test passed in `1.557s`. The identical covering command then exited `0` with
all `148` tests passed in `138.546s`; its count increased by exactly the new
regression and its UX-blueprint summary remained unchanged and Green.

### Consolidated Visual R1 review-docket closure

The independent docket identified one Critical and two Important defects: 47
approved requirement-local command labels were absent from their exact state
owners; unresolved target and rollback prose could launder incomplete command
contracts; and future-gated commands could leak as authorizing task-pack prose.
The bounded repair added the 47 records, made all 239 approved state-bound
records declare an explicit activation posture and exact gate IDs, introduced
typed mutation rollback posture, and made target and rollback validation fail
closed without rejecting legitimate named routes. A separate closed
machine-control dependency registry records the withheld StoreKit product
mapping posture without adding a product requirement, concept owner, SKU, plan,
price, or thirteenth monetization law.

The prior candidate did introduce requirement-wide lexical label substitution;
the exact re-review proved that it corrupted live mixed-posture `Done` and
`Review Continuity Status` laws and even common-noun prose. That transform is
removed. Task packs now preserve every canonical requirement body byte-for-byte
and project every selected active and future command in a separate deterministic
identity-bound authorization section keyed by requirement, state, command,
label, posture, requirement gates, and dependency posture. `Purchase` remains
future-gated and non-authorizing behind both `ENTITLEMENT-003`, its command law,
and the withheld StoreKit registry dependency; active `Restore Purchases`
remains separately authorizing.

The review RED covered the exact missing-command inventory, adversarial target
and rollback cases, active/future projection separation, stale visual-node
bindings, and candidate semantic-review lifecycle. The frozen repair's final
covering command was:

```text
PYTHONPATH=. /Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 -m unittest \
  tests.canon.test_visual_r1_command_contracts \
  tests.canon.test_state_command_semantics \
  tests.canon.test_visual_authority_rebaseline \
  tests.canon.test_ux_blueprint \
  tests.canon.test_ux_blueprint_review_repairs \
  tests.canon.test_ux_blueprint_whole_range_repair \
  tests.canon.test_ux_blueprint_semantic_repairs \
  tests.canon.test_ux_blueprint_independent_review \
  tests.canon.test_ux_blueprint_final_review \
  tests.canon.test_ux_blueprint_matrix_repairs \
  tests.canon.test_ux_blueprint_all_corpus_review \
  tests.canon.test_ux_blueprint_full_corpus_review \
  tests.canon.test_ux_blueprint_semantic_residual_docket \
  tests.canon.test_parser \
  tests.canon.test_task_pack \
  tests.canon.test_build.BuildTests.test_shadow_goldens_match_the_live_manifest_render \
  tests.canon.test_task19_whole_train_repairs \
  tests.canon.test_audit.AuditTests.test_live_shadow_cli_audit_is_green_and_deterministic
```

Exit `0`; `241` tests ran in `158.011s`, with one expected skip. The embedded
UX-blueprint check was Green for `47` screens, `47` state models, `423` taxonomy
states, `433` state variants, `18` objects, `12` journeys, `461` requirements,
`336` visual dispositions, `125` nonvisual dispositions, and shadow authority.
All 147 frozen visual candidate nodes resolve the current canon content SHA.

Post-repair governance gates all exited `0`:

- `scripts/ambitions-canon.py audit`: Green, `61` documents, `461`
  requirements, `461` concepts, shadow authority.
- `scripts/ambitions-canon.py build --check`: Green, generated outputs current.
- `scripts/ambitions-canon.py ux-blueprint --check`: Green with the counts above.
- `scripts/ambitions-canon.py coverage --fail-on-p0-gap`: Green, `61`
  documents and `5` profiles.
- `scripts/ambitions-canon.py traceability --check`: Green, `461`
  requirements, `20` references, and `1,044` honest shadow posture gaps.
- `scripts/ambitions-canon.py external-authority --kind figma --check`: Green,
  `11` references, `0` reconciliation entities, shadow authority.
- `scripts/ambitions-truth-path-vocabulary-audit.py`: Green.
- `scripts/ambitions-constitution-audit.py`: Green, `124` laws.
- `scripts/ambitions-remediation-governance-check.py`: Green, `61` changed
  paths and no changed production or support Swift.
- `scripts/canon-language-drift-scan.sh`: exit `0`; no Red. Its Yellow output
  names explicit anti-AI/anti-score prohibitions and their deterministic
  projections rather than newly authorized product language.
- `git diff --check`: exit `0` with no output.

Per controller scope, no new matrix, semantic dimension, semantic evaluation,
or full discovery run was added. The semantic-loss ledger and receipt remain
`candidate` and unbound; no stale semantic receipt was promoted or rebound.

### Claim ceiling

Allowed claim: governance/canon source is Green only for the exact deterministic
command-contract parsing, ownership, blueprint mapping, and shadow projection
scope after its required independent review is clean.

Forbidden claims: product complete, source UI implemented, runtime Green,
rendered-app Visual Green, Accessibility Green, privacy/legal approved, device
ready, TestFlight ready, App Store ready, or Release Green.

## Historical Train 4 scope and outcome

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

The final tracked receipt is bound to timeout-only commit `a338d77006c7e7c0399ed8d394194be85e8f404d`. Terminal semantic-repair commit `030cf73f38c6bab9a0096af7706e6a85644026a2` froze the earlier evaluated canon; validator commits `262327c04261deb43bfe3bd3e7ad1e9380c0c0ab` and `f11b414f342346dfd7200381d232045efb34de9a` closed proof-diff, deletion, and rename bypasses; final-regression commit `6e88b61414417cdaeaae9586c606f175de099e48` repaired the exact discovery failures; polished-repair commit `15beb501` closed the replacement docket; and final-review repair `f1a37b4f` made every non-structural slash grammatical, restored the unknown-verdict schema regression, and deterministically refreshed the canon, UX blueprint, and shadow goldens. Commit `a338d770` changes only the workflow timeout from 5 to 10 minutes. Canon, prompts, every task-pack byte, response evidence, comparison evidence, scores, verdicts, and claim ceiling are byte-identical to the approved `f1a37b4f` evidence.

The final polished independently reviewed result is old 22 / new 28 with overall verdict `new_better`. No dimension is `old_better`: semantic equivalence, relevant-law recall, contradiction control, unauthorized assumptions, source ownership, and proof discipline are `new_better`; validation completeness is equivalent. The receipt records only hashes, attribution, scores, verdicts, and the closed claim ceiling; it does not retain response prose or comparator rationale. This report is part of the final proof-only commit; that commit SHA remains pending until Git creates it and cannot be self-referenced by the commit's own bytes.

Evidence bindings:

```text
canon SHA-256: 050ad36b253bef7d0b6c53ab25d23483d1ebf1c9007210c653c68ad89aa68c9e
old prompt SHA-256: 338c2088cc6a74dc06a3fc087bc6848280b117b7638aefdb377b9649face56cb
new prompt SHA-256: e3eed47bc27559428cacbc1cb279f42b6a86c552c1c4124d114c28cb413419ac
old response SHA-256: f8e73052af92ad97e4f686730190e15532c5107328060c5c9ac8272aa9bd9834
new response SHA-256: 647515a442f05cbe9fc8ea099d04d9be68ece8e0826486b53f0d09a21475ddc4
comparison SHA-256: 7e45a2155823abdf96c902efe2ff4db2f23e28c837f07895ea1f0f28aecaacbb
comparison totals: old 22 / new 28
overall verdict: new_better
```

Strict timeout-rebind receipt TDD began from the unchanged tracked receipt at commit `a338d770`. `uv run --python 3.12 --no-project python -m unittest tests.canon.test_semantic_receipt` failed as expected with exit 1: 13 tests ran with one error, `SEMANTIC_RECEIPT_STALE`, naming the workflow as a non-proof path changed after the prior evaluated commit. The offline checked-in CLI, `uv run --python 3.12 --no-project python scripts/ambitions-canon.py semantic-review --check-receipt`, also failed closed with exit 1 and the same stale workflow path before the receipt was rebound. The synthetic `old_better` policy fixture remains aligned to the final comparison's 23/27 mutated arithmetic so it continues to reach `SEMANTIC_RECEIPT_POLICY` without weakening validation. Final Green results are recorded below after verification.

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

Strict focused TDD added one seven-spec regression. RED: exit 1; one test failed with `150 != 0`. The bounded mechanical repair replaced only literal `, /` with the token `, or` followed by one space in app/shell, global/capture, global/trust-inspection, and Goals, Time, Today, and You specifications. It rewrote no other slash alternatives or semantics. The UX validator's pre-existing broad `or` rejection then failed on grammatical effect prose; the minimum coupled repair retained rejection of combined command labels while narrowing the check to the parsed command label rather than the entire transition sentence. The duplicate unknown-verdict case was removed without weakening the remaining malformed-verdict and closed-schema coverage.

Focused GREEN: exit 0; the new regression passed with zero malformed occurrences. Covering state semantics, Task 19 posture, semantic repairs, golden render, parser, and UX checks passed 83 tests in 48.167 seconds with exit 0. The parsed inventory remained exactly 267 state contracts and 328 commands. Audit, deterministic build check, UX-blueprint check, and `git diff --check` were Green. All fourteen shadow goldens were regenerated and byte-matched the live outputs; thirteen produced tracked diffs. The receipt remained correctly stale after the canon change. Deterministic polished-repair commit: `15beb50106a641ab3eb02ed10679dd425de69913`, exactly 40 files, excluding the durable report and receipt JSON.

The polished semantic record binds canon `3b833fa7`, new prompt `c8966010`, all sixteen regenerated pack hashes, old response `f8e73052`, polished new response `4775ffde`, and polished comparison `766308d1`. The accepted comparison is old 26 / new 28, overall `new_better`, with relevant-law recall and source ownership `new_better`, the other five dimensions equivalent, and no `old_better` dimension.

### Final exact-range review repair

The final exact-range reviewer returned 0 Critical, 2 Important, and 0 Minor findings. The first Important finding showed that the comma-only regression was too narrow: the seven owner specifications still contained non-structural prose slashes even though the literal comma-slash count was zero. The second Important finding required the receipt schema/policy suite to retain exactly one unknown-verdict negative case and to isolate schema/policy validation from an intentionally stale external receipt binding.

Strict TDD replaced the narrow assertion with a parsed seven-spec normative-prose law. RED: exit 1; one test failed with 150 repeated-space artifacts caused by doubled spaces after the token `, or` and 526 disallowed prose slashes. The first semantic pass reduced the counts to 0 repeated-space artifacts and 4 residual slashes; inspection then repaired those four duplicated transition/command phrases. Final focused GREEN: exit 0 with 0/0. The test preserves every exact `explicit state contract / State` structural delimiter and the locked `Contextual Proof / Source / Privacy / History / Receipts` heading while rejecting every other prose-level ` / ` occurrence.

The seven owner specifications now use explicit conjunctions by meaning: alternative actions, focus targets, and negative verbs use `or`; paired durable Receipt and History records use `and`; reads, paging, cancellation, unavailable-state, proof, privacy, and recovery phrases are grammatical and unambiguous. Command labels, lifecycle, commit posture, durable behavior, and the four future-gated continuity variants did not change. Exactly one `better` unknown-verdict case is present and must raise `SEMANTIC_RECEIPT_INVALID`.

Focused and covering verification was Green: full state semantics passed 14 tests; the isolated receipt schema/policy method passed; Task 19 posture, UX semantic repairs, and the all-fourteen-golden byte comparison passed 46 tests with one skip; parser and UX checks passed 37 tests; and the post-commit state-plus-schema run passed 15 tests. The parsed inventory remains exactly 267 state contracts and 328 commands, with four future-gated variants. Audit reported 61 documents, 449 requirements, and 449 concepts in shadow authority. Deterministic build, UX-blueprint check, and `git diff --check` were Green. All fourteen shadow goldens were regenerated and exact; thirteen changed tracked bytes. Full discovery was intentionally not rerun. The receipt remained correctly stale until this proof-only update.

Deterministic final-review repair commit: `f1a37b4f4ffdefb0788d1149bbf2c61393e71a94`, exactly 39 changed files and no report or receipt JSON. The final semantic record binds canon `050ad36b`, new prompt `e3eed47b`, all sixteen regenerated pack hashes, old response `f8e73052`, final new response `647515a4`, and final comparison `7e45a215`. The accepted comparison is old 22 / new 28, overall `new_better`, with six `new_better` dimensions, validation completeness equivalent, and no `old_better` dimension.

### CI timeout-only repair and SHA-bound evidence reuse

PR #32 run `29376295161` attempts 1 through 3 were cancelled at approximately five minutes. Attempt 3 had already completed compiler tests, authority tests, Python compileall, semantic-receipt validation, and canon audit before the job timed out during coverage. Owner-authorized commit `a338d77006c7e7c0399ed8d394194be85e8f404d` changes exactly one workflow line: Canon shadow integrity `timeout-minutes` from 5 to 10. `actionlint`, YAML parsing, and `git diff --check` were Green. Successful push run `29376292783` and dispatch `29376905509` ran at `680aa8a` under the original five-minute bound; they validate unchanged content but not the `a338d770` timeout repair. Final 10-minute CI validation remains pending push at `24d5b691`.

The approved speed amendment permits SHA-bound evidence reuse when semantic inputs are unchanged. The controller regenerated the bundle at `a338d770` and ingested the exact previously reviewed old response, new response, and comparison files. Canon `050ad36b`, old prompt `338c2088`, new prompt `e3eed47b`, all sixteen pack hashes, old response `f8e73052`, new response `647515a4`, comparison `7e45a215`, scores 22/28, `new_better`, and zero `old_better` dimensions are byte-identical to the `f1a37b4f` evidence. No model was rerun and no semantic claim was changed.

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
| prior polished receipt unittest | 0 | Historical: 13 tests passed in 36.589 seconds against evaluated commit `15beb501` |
| final exact normative-prose TDD | 1 expected, then 0 | Red 150 repeated-space / 526 disallowed-slash; intermediate 0/4; final 0/0 |
| final state semantics and receipt schema/policy | 0 | 14 state tests and the isolated schema/policy method passed; post-commit covering run passed 15 tests |
| Task 19 / UX semantics / all fourteen goldens | 0 | 46 tests passed with one skip; all golden bytes exact |
| parser and UX checks | 0 | 37 tests passed; embedded UX check Green |
| prior final receipt unittest | 0 | Historical: 13 tests passed in 34.724 seconds against evaluated commit `f1a37b4f` |
| timeout-rebind receipt unittest before update | 1 expected | 13 tests; one `SEMANTIC_RECEIPT_STALE` error naming the workflow path |
| timeout-rebind receipt check before update | 1 expected | `SEMANTIC_RECEIPT_STALE`; prior receipt predates evaluated commit `a338d770` |
| final focused receipt unittest | 0 | 13 tests passed in 34.449 seconds against the timeout-rebound proof-only diff |
| final `ambitions-canon.py semantic-review --check-receipt` | 0 | Green; 8 packs, `new_better`, scores 22/28 |
| `git diff --check` | 0 | clean |

The final proof-only receipt update changes no canon, specification, compiler, generated, fixture, workflow, or response-evidence bytes. It rebinds the unchanged controller-supplied final polished comparison to evaluated timeout-only commit `a338d770` and remains a non-CI shadow comparison only.

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

Mechanically generated with `git diff --name-only 3c0957ebb2202f10de53975b2cb74e8f35253808` for the complete `3c0957e..HEAD` repair range: 72 tracked paths. The timeout-only workflow is the sole path added after the prior 71-path union. A mechanical tuple comparison confirms that the 72 listed paths equal Git's sorted output exactly.

```text
.github/workflows/ambitions-canon-shadow-audit.yml
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

## Visual Authority Revision 1 semantic refresh

The owner-approved Revision 1 design contract and its deterministic fixture repair are frozen at `1b31c0f8eafd179865575a5fcf42e7ff482e77c1`. The design-spec SHA-256 is `f579a8d15094161afc8c060419c1dee597ffd4d498f67f37bddf194ac58dfa80`. The exact fixture/golden review returned 0 Critical, 0 Important, and 2 residual Minor portability-hardening notes; all fourteen shadow goldens byte-match the live render.

The final pre-refresh Python 3.12 discovery run executed 743 tests in 1,424.357 seconds. It passed 739 tests, skipped 2, and failed exactly the four stale-receipt assertions expected after frozen non-proof changes: regenerated new-prompt hash, regenerated pack hashes, evaluated `task_pack.py` bytes, and the tracked current-receipt check. No compiler, fixture, golden, UX-blueprint, visual-authority, traceability, or task-pack test failed.

A fresh blinded semantic evaluation used the frozen old prompt and new task-pack prompt. The evaluators could not inspect the other path or the prior receipt/comparison. The independent comparator could inspect only both responses, both symmetric prompts, and the new semantic record. Exact evidence:

```text
evaluated commit: 1b31c0f8eafd179865575a5fcf42e7ff482e77c1
canon SHA-256: 050ad36b253bef7d0b6c53ab25d23483d1ebf1c9007210c653c68ad89aa68c9e
old prompt SHA-256: 338c2088cc6a74dc06a3fc087bc6848280b117b7638aefdb377b9649face56cb
new prompt SHA-256: 7b4e439b6689a09cf771f5b251240e5d4a33229b71b507fed9a73ea7aae8aa9e
old response SHA-256: c7d5794e0c2625db29bcbb92d9282c83d5058c1b1509ce9fe436ff7147b05f04
new response SHA-256: 7cb1847fbd2360120f23b409f363de21effa717dde5ca0440dd9399053c964c8
comparison SHA-256: 24a75acb7e448c46a5e4481ffccc3b77748c79f84e96df2a2670b2b0e6570e5d
comparison totals: old 25 / new 28
overall verdict: new_better
old_better dimensions: 0
```

Semantic equivalence, relevant-law recall, source ownership, and validation completeness are equivalent; contradiction control, unauthorized-assumption control, and proof discipline are `new_better`. This remains explicit non-CI shadow comparison evidence only and does not authorize implementation or raise any product, runtime, source, visual, accessibility, privacy, device, distribution, or release claim.

## Generated outputs

The deterministic canon build and UX-blueprint writer refresh the canon index, requirement graph, ownership/source/test/proof maps, coverage and benchmark projections, visual-authority manifest, UX blueprint Markdown, and requirement-disposition projection. Outputs contain no volatile timestamp and remain newline-terminated.

## Review and findings

The exact review of `3c0957e..bc5e1e82` returned one Critical semantic-contract finding, one Important report/evidence finding, and one Minor prose finding. Semantic-repair commit `030cf73f` addresses the semantic docket; validator commit `262327c` closes the evaluated-commit binding defect; Important-repair commit `f11b414f` closes deletion and rename bypasses; final-regression commit `6e88b614` closes the exact full-discovery failures and refreshes all fourteen shadow goldens. The replacement review then returned 0 Critical, 2 Important, and 1 Minor findings, closed by `15beb501`. The final exact-range review returned 0 Critical, 2 Important, and 0 Minor findings: the remaining non-structural prose slashes needed semantic conjunctions, and the receipt suite needed exactly one isolated unknown-verdict regression. Deterministic repair `f1a37b4f` closes both Important findings with 0/0 malformed prose and the restored fail-closed schema case. The final proof-only commit records the fresh independently supplied comparison. Specification-compliance and code-quality re-review of `3c0957e..HEAD` remain required after commit.

Residual Minor findings: none from the final exact-range review. The current inline global duplicate-ID regression remains Green.

## Exact re-review docket repair candidate

The exact independent re-review of `d3a7e29..d7fe80dc` returned one Critical
and two Important findings. This bounded repair starts from clean base
`d7fe80dc8e70a4a8cda08b6acde5139753b8b0d3` and addresses only that docket:

- canonical requirement bodies are no longer lexically rewritten by command
  labels;
- every selected active and future command has a deterministic machine-readable
  authorization record keyed by requirement ID, state ID, command ID, exact
  label, activation posture, requirement gates, dependency posture, and final
  activation authorization;
- the five active and one future `Done` records under
  `APP-ACCOUNT-COMMAND-CONTRACT-001` remain distinct, as do the one active and
  three future `Review Continuity Status` records under
  `SYSTEM-CONTINUITY-COMMAND-CONTRACT-001`;
- route/focus validation now uses a token-state classifier that rejects every
  reviewed placeholder, deferred, and unresolved declaration while permitting
  concrete names such as `the pending route requests list` and
  `the unknown route diagnostics`;
- every mutation rollback posture, external-result command, and non-mutating
  command rejects placeholder, future, or negated recovery while the current
  433-state / 567-command corpus remains valid;
- `Purchase` remains future-gated and non-authorizing behind the closed
  `GATE-STOREKIT-PRODUCT-REGISTRY-001` machine dependency. Owner approval is
  withheld, exact product mappings are empty, freshness is absent, and
  activation authorization is false. The registry is not a normative manifest
  entry, requirement, concept owner, SKU declaration, plan, price, or product
  law;
- task-pack requirement closure now embeds `ENTITLEMENT-003`, while dependency
  IDs remain separate machine-control identities;
- shadow task packs keep every command's `activation_authorized` value false;
  active command authorization requires active canon authority, an active
  command posture, satisfied requirement gates, and authorized machine
  dependencies;
- the shadow visual-rebaseline freshness refresh changes exactly the top-level
  canon content SHA plus the same field on all 147 existing candidate nodes.
  A normalized non-hash digest regression freezes every frame/node mapping,
  approval, eligibility, status, classification, Gate B posture, rollback
  posture, and Figma reference.

Strict TDD observed the expected Python 3.12 RED before implementation: 14
selected tests produced 65 failures and 5 errors covering every reviewed target
and rollback bypass, both named-route false positives, missing structured task
pack authorization, and the absent dependency registry/API. The frozen focused
sets then passed 7/7 I1 adversarial document/blueprint tests, 82/82 parser/task
pack/dependency tests, and 55/55 visual-command/state/UX-blueprint tests.

The final frozen-candidate covering regression exited `0`: 271 tests ran in
192.106 seconds,
270 passed, and one expected test was skipped. No semantic evaluation was run or
bound for this repair. Exact deterministic gates then returned:

```text
exit 0 — ambitions-canon.py audit: 61 documents, 461 requirements/concepts, shadow
exit 0 — ambitions-canon.py build --check: generated outputs current
exit 0 — ambitions-canon.py ux-blueprint --check: 47 screens, 433 variants, 461 requirements
exit 0 — ambitions-canon.py coverage --fail-on-p0-gap: 61 documents, five profiles
exit 0 — ambitions-canon.py traceability --check: 461 requirements, 20 references, 1,044 honest posture gaps
exit 0 — ambitions-canon.py external-authority --kind figma --check: 11 references, zero reconciliation entities
exit 0 — ambitions-truth-path-vocabulary-audit.py: Green
exit 0 — ambitions-constitution-audit.py: 124 laws, 34 source maps, 34 test maps
exit 0 — ambitions-remediation-governance-check.py: 51 changed paths, zero production/support Swift changes, Green
exit 0 — canon-language-drift-scan.sh: Yellow prohibition/backlog evidence only
exit 0 — git diff --check
```

Independent exact-range specification-compliance and code-quality re-review is
still required after this repair commit. Critical and Important findings remain
non-waivable.

### Final Important I1/I2 repair against `59e1d41c`

The exact independent re-review of
`d7fe80dc8e70a4a8cda08b6acde5139753b8b0d3..59e1d41c05a0b9f60db1ea5fc23bf686166d5415`
returned `0 Critical / 2 Important / 0 Minor`. This one-commit candidate starts
from clean base `59e1d41c05a0b9f60db1ea5fc23bf686166d5415` and addresses only
those two Important findings.

I1 no longer lets route, focus, or recovery prose establish machine closure.
All `433` structured states and all `567` commands now project closed
destination, success-focus, failure-focus, and recovery identities with an
explicit `current / deferred / unavailable` posture. Active authorization
requires every one of those postures to be `current`. Recovery additionally
binds the canonical owner and the posture-specific mechanism identity:

- `36` inverse-command mutations bind an exact inverse command ID;
- `10` checkpoint-restore mutations bind an exact checkpoint ID;
- `12` owner-handoff mutations bind an exact recovery-handoff command ID and
  canonical owner;
- `2` confirmed-irreversible mutations bind exact confirmation and Receipt IDs;
- the remaining `507` non-mutating or external-result commands bind a closed
  recovery identity/owner without inventing a mutation mechanism.

The human destination, focus, and recovery clauses remain unchanged detail.
They are projected beside, but cannot replace, the closed identities. The JSON
UX blueprint, Markdown blueprint, and JSON/Markdown task-pack projections expose
the exact machine contract for every active and future command. Concrete names
such as `the pending route requests list` and
`the unknown route diagnostics` remain accepted, while the reviewed grammatical
and modal/deferred equivalents fail closed.

I2 replaces arbitrary `owner_approval_evidence` with an independently loaded
approval-receipt registry. An approved dependency must now bind all of:

- dependency ID and revision;
- exact mapping-record ID, mapping list, and mapping SHA-256;
- dependency SHA-256;
- the non-circular compiler canon-content SHA-256;
- approval identity, closed approval state, exact owner/requirement/state/command
  scope, and scope SHA-256;
- deterministic receipt ID/revision, receipt SHA-256, and the prior receipt hash
  for revisions after `R0002`.

Receipt history starts at dependency revision `2`, must be contiguous,
append-only, and hash-chained, and the dependency must reference the latest
receipt. A mapping/content substitution invalidates the old receipt; a later
mapping requires the next dependency revision and a new matching receipt. Task
packs expose the exact product mapping list, mapping-record identity, receipt
identity, receipt-registry identity/revision/source hash, and the complete
resolved receipt rather than a count or arbitrary evidence string.

The tracked current posture remains deliberately empty and non-authorizing:
`Purchase` is `future_gated`; dependency revision is `1`; owner approval is
`withheld`; mapping and receipt identities are `null`; exact mappings and the
approval-receipt registry are empty; freshness is `absent`; posture is
`blocked`; activation authorization is `false`. No SKU, product identifier,
price, plan, trial, paywall, paid-feature boundary, or monetization law was
added. The registry files remain outside the normative manifest and own no
requirement or product concept. The exact current compiler content binding is
`eb0a44125ec4814cec2c5a53f14d72c96b6539bb46b7fca9b90418a7ed6cc57b`.

Strict TDD was observed before production edits. The first selected I1 RED
exited `1` with `13` failures and `1,002` subtest errors across seven selected
tests, proving the modal target/recovery bypasses and missing machine fields and
projections. The I2-specific RED then ran nine dependency tests and produced
eight errors, proving that canon-content, receipt, stale-content,
mapping-substitution, and approval-hash controls were absent. The authoritative
pinned Python 3.12 focused suite then exited `0`: `131` tests ran in `118.823s`.

The first frozen covering run correctly exposed two test-harness field-set
drifts and no production defect: `260` tests ran in `449.005s`, with two
failures and one expected skip. The two exact harness repairs passed `2/2` in
`15.253s`. The complete frozen command was restarted from zero under
`/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12`
and exited `0`: `260` tests ran in `393.113s`; all passed with one expected
skip. No semantic evaluation or semantic receipt was run, changed, or rebound.

Final deterministic gates all exited `0`:

```text
ambitions-canon.py audit: 61 documents, 461 requirements/concepts, shadow
ambitions-canon.py build --check: generated outputs current
ambitions-canon.py ux-blueprint --check: 47 screens, 433 variants, 461 requirements
ambitions-canon.py coverage --fail-on-p0-gap: 61 documents, five profiles
ambitions-canon.py traceability --check: 461 requirements, 20 references, 1,044 posture gaps
ambitions-canon.py external-authority --kind figma --check: 11 references, zero reconciliation entities
ambitions-truth-path-vocabulary-audit.py: Green
ambitions-constitution-audit.py: 124 laws, 34 source maps, 34 test maps
ambitions-remediation-governance-check.py: 68 changed paths, zero production/support Swift changes, Green
canon-language-drift-scan.sh: exit 0; Yellow prohibition/backlog evidence only
git diff --check: exit 0
```

Architecture closeout: Final Architecture Tree inspected: yes. This bounded
canon/compiler repair creates no production owner, runtime authority, package,
Swift source, or compatibility shim. Canonical production owners touched: none.
New durable files are only the command-gate approval-receipt registry and its
closed schema. Old/non-canonical production paths removed: none. Yellow
architecture debt introduced: none. No equivalent-folder or approximate-owner
interpretation was used.

Allowed claim before independent re-review: deterministic shadow-canon repair
candidate with the exact machine-command, approval-receipt, task-pack,
generated-projection, and governance evidence above Green. Independent exact
specification-compliance and code-quality re-review is still required. Visual
approval, semantic-evaluation readiness, Gate B, authority cutover, source UI,
runtime/device/accessibility/privacy/distribution, TestFlight, App Store, and
Release Green remain explicitly unclaimed.

## Final recovery-command identity repair — 2026-07-16

This bounded follow-up closes only the remaining I1 recovery-command identity
defect. The exact normative corpus now declares `48` source-grounded recovery
commands: `36` inverse commands and `12` non-mutating owner recovery handoffs.
Each command owns distinct effect, destination, success focus, failure focus,
preconditions, and the same closed safety/privacy law. The registry binds those
commands as `48` actual-command records and resolves their `192` nested
destination, success-focus, failure-focus, and recovery identities. The complete
registry therefore contains `2,522` resolution records and has source SHA-256
`2f7af6329a6ac779dbb224447e8e615cd9dac43a44629b949706a128ab2a8c8b`.

The corpus rejects the former generic inverse, generic destination, and generic
handoff templates. Exact inverse behavior is declared only when the existing
canon proves it; otherwise the recovery command is an explicit non-mutating
handoff that names the retained, completed, failed, or artifact scope. The
resolver now supplies the registered recovery-command hashes when validating
primary command projections, so UX-blueprint and task-pack references bind the
same actual command records instead of failing as stale.

Strict TDD evidence:

- The new corpus negative first failed on all `48` generic recovery records.
- The nested-identity test first errored on all `192` missing identities.
- The parser generic-template negative first failed because the old template
  was accepted.
- The complete focused command-resolution run initially exited `1` with `567`
  stale blueprint-reference subtest failures and one resolver error, exposing
  the missing registered recovery-hash input.
- After the bounded repair and deterministic projection refresh, the exact
  focused command exited `0`: `16` tests ran in `7.339s`, all passed.

The single frozen covering command ran `291` tests in `671.605s`. It reported
exactly three mechanical freshness failures: the frozen visual-rebaseline SHA
constant, its hand record, and the shadow-golden copies. No command behavior,
parser, owner binding, task-pack, UX-blueprint, or product-law assertion failed.
The bounded freshness bundle changed only those three classes of tracked bytes;
the exact three covering assertions then exited `0` in `12.140s`. Per the
owner-approved fast-safe limit, the complete expensive covering command was not
run a second time.

The current canon-content SHA-256 is
`9cf5640da51cc6d0702b69626bf8aa1af11a337cbf4ec930f9ff5c4fa57ea92a`.
All final deterministic governance commands exited `0`:

```text
/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-canon.py audit
GREEN: 61 documents, 461 requirements, 461 concepts, shadow authority

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-canon.py build --check
GREEN: generated outputs current

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-canon.py ux-blueprint --check
GREEN: 47 screens, 433 variants, 461 requirements, shadow authority

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-canon.py coverage --fail-on-p0-gap
GREEN: 61 documents, five profiles

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-canon.py traceability --check
GREEN: 461 requirements, 20 references, 1,044 honest shadow posture gaps

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-canon.py external-authority --kind figma --check
GREEN: 11 references, zero reconciliation entities, shadow authority

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-truth-path-vocabulary-audit.py
GREEN

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-constitution-audit.py
GREEN: 124 laws, 34 source maps, 34 test maps

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-remediation-governance-check.py
GREEN: 68 changed paths; zero production/support Swift changes

bash scripts/canon-language-drift-scan.sh
exit 0: Yellow prohibition/backlog evidence only; no Red

git diff --check
exit 0: no output
```

Architecture closeout remains unchanged: Final Architecture Tree inspected;
no production Swift, runtime owner, package boundary, Figma node, compatibility
shim, authority state, or CI surface changed. No semantic evaluation was run.
Independent exact-range specification-compliance and code-quality re-review is
still required before merge.

Allowed claim: deterministic shadow-canon recovery-command identity repair
candidate Green for the exact tested scope. Visual approval, Gate B, authority
cutover, product/runtime/accessibility/privacy/device/distribution, TestFlight,
App Store, and Release Green remain unclaimed.

## Exact four-Important review repair — 2026-07-16

The consolidated review docket contained exactly four Important findings and
no authorized scope beyond them. This bounded repair closes those findings as
one bundle:

- all `36` inverse recovery commands now bind redo to the exact original
  trigger command and require the current inverse Receipt, current revision,
  and fresh task authorization; the deterministic registry hash-binds those
  fields and task packs project the complete recovery-command behavior rather
  than only IDs and hashes;
- the two setup skip inverses atomically clear the exact chapter or question
  skip marker and commit the supplied answer to its exact setup field, while
  preserving accepted answers, History, and both trigger and inverse Receipts;
- every approval receipt is now symmetrically bound to its exact owner
  attestation across dependency revision/hash, mapping identity/list/hash,
  canon SHA, approval state, and approved scope/hash; changed dependencies
  cannot launder appended approval history through withheld/deactivated state,
  and unreferenced attestations fail closed;
- the bounded rollback is the exact
  `57943fd21a3afa268ef5ad680b28f0d1efd085eb..HEAD` range below, distinct from
  the separately listed historical rollback.

Strict TDD began with the six selected review regressions. The initial command
exited `1` with `42` intended failures and one test-harness error. Correcting
only that harness to reach the intended assertion left the end-to-end
task-pack recovery projection Red. After the bounded implementation and
deterministic projection refresh, the exact six-test command exited `0`:
`6` tests ran in `15.600s`, all passed. The end-to-end method builds a real
release task pack for the setup command requirement and asserts the full
inverse behavior plus the fail-closed redo authorization posture.

The one frozen covering command exercised command resolution, trusted approval
history, command-gate dependencies, state-command semantics, the parser,
task-pack generation, UX-blueprint validation, visual-rebaseline validation,
the closed schema inventory, and the shadow goldens. It exited `1`: `197`
tests ran in `356.339s`, with exactly four failures and no command, parser,
task-pack, approval-history, or product-law failure. The complete docket was
mechanical: two frozen visual SHA/hand-record assertions, stale shadow goldens,
and one closed-schema assertion for the new conditional discriminator. The
bounded freshness/closure repair changed only those bytes. The exact four
failed methods then exited `0`: `4` tests ran in `13.957s`, all passed. Per the
fast-safe limit, the expensive covering command was not restarted.

The current canon-content SHA-256 is
`6e836710d8ed26bae3f01f5207438ebba67831b0f90cc7bded7a6368ecb51f67`.
The complete command-resolution registry contains `2,522` records and has
SHA-256
`864a4e373cf8897d4d5093ad4b3ff30f1fe9974f758388277d0187d3f220bda0`.
All final deterministic governance commands exited `0`:

```text
/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-canon.py audit
GREEN: 61 documents, 461 requirements, 461 concepts, shadow authority

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-canon.py build --check
GREEN: generated outputs current

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-canon.py ux-blueprint --check
GREEN: 47 screens, 433 variants, 461 requirements, shadow authority

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-canon.py coverage --fail-on-p0-gap
GREEN: 61 documents, five profiles, shadow authority

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-canon.py traceability --check
GREEN: 461 requirements, 20 references, 1,044 honest shadow posture gaps

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-canon.py external-authority --kind figma --check
GREEN: 11 references, zero reconciliation entities, shadow authority

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-truth-path-vocabulary-audit.py
GREEN

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-constitution-audit.py
GREEN: 124 laws, 34 source maps, 34 test maps

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-remediation-governance-check.py
GREEN: 56 changed paths; zero production/support Swift changes

bash scripts/canon-language-drift-scan.sh
exit 0: Yellow prohibition/backlog evidence only; no Red

git diff --check
exit 0: no output
```

No semantic evidence, Figma node, production Swift, CI, `AGENTS.md`, skill,
authority state, Gate B state, or destructive artifact changed. Independent
exact-range specification-compliance and code-quality re-review remains
required before merge. The allowed claim remains deterministic shadow-canon
repair candidate Green only for the exact tested scope.

## Authenticated protected-base approval repair — 2026-07-16

The exact-range re-review returned one remaining Important finding: the prior
Git context accepted a caller-selected ref and merge-base SHA, while the owner
attestation and its consuming receipt could be introduced without a separately
validated protected-base staging transition. This bounded repair replaces only
that trust and transition boundary.

The authorization input is now a typed externally authenticated CI context
bound to the fixed `refs/remotes/origin/main` ref, an exact protected SHA, an
exact candidate `HEAD` SHA, the closed
`github-protected-branch-required-check-v1` provenance, and a deterministic
context digest over all four fields. At load and again at authorization time,
the fixed ref must resolve exactly to the authenticated protected SHA, actual
`HEAD` must equal the authenticated candidate SHA, and the protected SHA must
be a strict ancestor and never `HEAD`. A local heads ref, same-HEAD base,
changed ref, substituted protected SHA, changed candidate head, stale digest,
or local provenance fails closed.

Owner approval is now an explicit two-step transition. The first candidate may
append exactly one `pending` attestation and increment only the append-only
owner registry by one revision. Dependency and receipt registries must remain
byte-identical to the authenticated protected base. The pending record binds
the exact future dependency revision/hash, mapping identity/list/hash, canon
SHA, command-owner scope/hash, current dependency-registry hash,
receipt-registry hash, and prior receipt head; it grants no activation. After
that staging commit becomes the protected base, a later candidate may consume
the exact pending record once through the matching approval receipt and future
dependency. Consumption cannot mutate the owner registry, cannot mix staging
with consumption, cannot reuse an already consumed attestation, and cannot
retain an untyped approved attestation or unmatched receipt history.

Strict TDD began with four new security/transition methods. The exact focused
RED exited `1`: `4` tests ran in `0.020s`, all four failing on the absent typed
authenticated CI context before production edits. The first bounded GREEN
exited `0`: `4` tests ran in `16.770s`, all passed. The full existing trusted
history module then exposed only five legacy harness/expectation updates for
the removed raw fields and new pending state; after those bounded updates it
exited `0`: `21` tests ran in `73.963s`, all passed. The existing dependency
module exited `0`: `9` tests ran in `44.233s`, all passed. A final focused run
including fixed-ref/SHA/HEAD revalidation, provenance/digest negatives,
positive protected-base staging/consumption, and closed-schema validation
exited `0`: `5` tests ran in `16.772s`, all passed.

The single covering command exercised command resolution, complete trusted
approval history, command-gate dependencies, task-pack generation, and schema
closure. It exited `0`: `103` tests ran in `176.361s`, all passed. Generated
task packs remained shadow and explicitly non-authorizing.

All deterministic governance gates remained Green: audit reported `61`
documents and `461` requirements/concepts in shadow authority; build check
reported current generated output; UX-blueprint check reported `47` screens,
`433` variants, and `461` requirements; coverage reported five profiles;
traceability reported `20` references and `1,044` honest shadow posture gaps;
Figma external-authority check reported `11` references and zero reconciliation
entities; truth-path/vocabulary and Constitution audits were Green; the drift
scan reported no changed-file candidate and only existing Yellow backlog.

Current tracked Purchase remains revision `1`, `withheld`, empty, blocked, and
non-authorizing. No semantic evidence, Figma node, production Swift, generated
canon output, CI, `AGENTS.md`, skill, authority state, Gate B state, or
destructive artifact changed. The allowed claim remains deterministic
shadow-canon repair candidate Green only for this exact trust boundary, pending
independent exact-range specification-compliance and code-quality re-review.

## Visual R1 build-current semantic proof projection — 2026-07-16

### Frozen deterministic preconditions

The semantic evaluation is bound to the clean, build-current commit
`dbdc72ce90f14369aa900dbb2cd13741af2e1b83`. The exact independent visual
review of
`201f1e1451a295b53fcfcefb6ba4c0acce207d45..6b275edef2029de5a1af6b787990f139624d972f`
returned `0 Critical / 0 Important / 1 Minor`. The exact independent generated-
projection refresh review of
`ab53c4a906d56306b4ab2a063f76fbef90d8c8c8..dbdc72ce90f14369aa900dbb2cd13741af2e1b83`
returned `0 Critical / 0 Important / 0 Minor`. Both reviews covered
specification compliance and code quality. The residual visual-review Minor is
non-authorizing and does not upgrade the visual, accessibility, device, or
release posture.

An earlier comparison prepared after merge commit
`ab53c4a906d56306b4ab2a063f76fbef90d8c8c8` is explicitly invalidated and
non-authorizing. Its comparison artifact SHA-256 was
`a1b7551c903c93e60c544d0cce6395a3183981f1a8b8e7408fbf229b6ef48f0f`
with old/new totals `26 / 28`, but the subsequent deterministic build check
found P0-stale generated source-traceability projections. Commit
`dbdc72ce90f14369aa900dbb2cd13741af2e1b83` refreshed the nine generated
projections and their nine shadow goldens. The invalidated comparison was not
projected into the tracked receipt and proves nothing about the build-current
candidate.

### Fresh build-current evidence

The controller prepared and ingested the build-current bundle through the
offline deterministic CLI. The three semantic-review commands exited `0` in
sequence: prepare with no response files, ingest the two isolated responses,
then ingest the blinded comparison. Their terminal states were respectively
`awaiting_independent_responses`,
`responses_recorded_pending_blinded_comparison`, and `comparison_recorded`.
The operator identity was `Visual R1 build-current semantic bundle operator`
and the operator model was `deterministic-no-model-execution`.

```text
$PY scripts/ambitions-canon.py semantic-review --reviewer "Visual R1 build-current semantic bundle operator" --model "deterministic-no-model-execution"
$PY scripts/ambitions-canon.py semantic-review --reviewer "Visual R1 build-current semantic bundle operator" --model "deterministic-no-model-execution" --old-response /tmp/ambitions-visual-r1-build-current-old-response.json --new-response /tmp/ambitions-visual-r1-build-current-new-response.json
$PY scripts/ambitions-canon.py semantic-review --reviewer "Visual R1 build-current semantic bundle operator" --model "deterministic-no-model-execution" --old-response /tmp/ambitions-visual-r1-build-current-old-response.json --new-response /tmp/ambitions-visual-r1-build-current-new-response.json --comparison /tmp/ambitions-visual-r1-build-current-comparison.json
```

The old-path and new-pack evaluator roles were assigned as Sol High work and
the blinded-comparator role as Sol Max work. The active runtime did not expose
a tier identifier, so all three evidence artifacts honestly record
`gpt-5-codex-runtime-identifier-not-exposed`. This report does not claim that a
`gpt-5-sol-high` or `gpt-5-sol-max` runtime executed.

Exact build-current evidence:

```text
evaluated commit: dbdc72ce90f14369aa900dbb2cd13741af2e1b83
canon SHA-256: c7a5026b051abcf3951a73bc855179e4ecd9c26b87c490d4bf16ce2fc02de6a2
old prompt SHA-256: 338c2088cc6a74dc06a3fc087bc6848280b117b7638aefdb377b9649face56cb
new prompt SHA-256: 58f9ae1ea9d509ef2dc5e261ce25e9dff823f0bd2c53daf054ba08573ffe2718
old response reviewer: Visual R1 Build-Current Old Path Evaluator
old response SHA-256: f93d3fb9bbb276b7228ca4aa6b428a6432cfcc184af9fef5307efb56ad63d5bd
new response reviewer: Visual R1 Build-Current New Pack Evaluator
new response SHA-256: 94b93cc8ab2ead337237f5fd8897843bf1dc86411dc60ae205861aa13cd688a0
comparison reviewer: Visual R1 Build-Current Blinded Comparator
comparison SHA-256: 3b513798f1932b2768a1eafe7b3defc501d73c6260603000571fc7d6ba543aa5
comparison totals: old 25 / new 28
overall verdict: new_better
old_better dimensions: 0
```

Ordered comparison dimensions:

```text
semantic_equivalence: equivalent, 4 / 4
relevant_law_recall: new_better, 3 / 4
contradiction_control: new_better, 3 / 4
unauthorized_assumptions: equivalent, 4 / 4
source_ownership: new_better, 3 / 4
validation_completeness: equivalent, 4 / 4
proof_discipline: equivalent, 4 / 4
```

The owner hard gate passed without score mutation: no dimension is
`old_better`, and the new total is greater than the old total. Raw evaluator
prose and comparator rationales remain ignored and untracked; the tracked
receipt contains only the closed hashes, attribution, ordered scores, verdict,
shadow posture, and claim ceiling.

### Strict receipt TDD

The pinned Python 3.12 receipt module first exited `1`: `13` tests ran in
`121.368s`, with `4` failures and `1` error. The failures proved the stale
canon hash, new-prompt hash, all ordered pack hashes, evaluated task-pack bytes,
and old evaluated commit. The offline receipt CLI separately exited `1` with
`P0_BLOCKER SEMANTIC_RECEIPT_STALE`, naming `Makefile` as the first non-proof
path changed after the old evaluated commit. Bare `python3.12` was not on this
shell's `PATH`; all authoritative test and verification execution therefore
uses the pinned Python 3.12 interpreter at
`/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12`.

This proof-only projection changes exactly the report, tracked receipt, and
receipt test. It changes no canon source, compiler, generated output, Figma
node, production Swift, CI, `AGENTS.md`, skill, authority state, or Gate B
state.

The final pre-commit focused receipt suite exited `0`: `13` tests ran in
`1088.497s`, all passed. The offline receipt check exited `0` and printed
`GREEN ambitions canon semantic-review receipt packs=8 verdict=new_better
scores=25/28`. The deterministic build check exited `0` and printed
`GREEN ambitions canon generated outputs`. The exact commands were:

```text
PYTHONPATH=. $PY -m unittest tests.canon.test_semantic_receipt
$PY scripts/ambitions-canon.py semantic-review --check-receipt
$PY scripts/ambitions-canon.py build --check
git diff --check
```

### Claim ceiling

The receipt authority remains `shadow`. Allowed claim: the fresh explicit
non-CI semantic comparison is deterministically bound to the exact
build-current commit and satisfies the no-`old_better` / non-decreasing-new-
score gate for the eight representative task-pack scenarios.

Forbidden claims: implementation authorization; product, source, Runtime,
rendered-app Visual, Accessibility, privacy/legal, device, TestFlight, App
Store, Release, Gate B, or authority-cutover Green.

## Rollback and claim ceiling

### Bounded candidate rollback

The exact recovery-command repair range is
`57943fd21a3afa268ef5ad680b28f0d1efd085eb..HEAD`. At the frozen candidate,
`git rev-list --count 57943fd21a3afa268ef5ad680b28f0d1efd085eb..HEAD`
must return `1`; `HEAD` is that single reviewable candidate commit. Before
publication, discard only the working-tree repair and reset the isolated branch
to `57943fd21a3afa268ef5ad680b28f0d1efd085eb`. After publication, create a
non-rewriting rollback commit with:

```text
git revert --no-commit 57943fd21a3afa268ef5ad680b28f0d1efd085eb..HEAD
git diff --check
git commit -m "revert: remove recovery-command identity repair"
```

That range reverts only the recovery-command identities, redo bindings, exact
task-pack projection, trusted approval-history hardening, generated shadow
projections, tests, and this report added above the named repair base.

### Broader historical rollback

The earlier visual-command amendment history is outside the bounded candidate
range and must not be swept into the command above. A separately approved
broader rollback reverts the prior commits in reverse order—
`a338d77006c7e7c0399ed8d394194be85e8f404d`,
`680aa8a160c6fdd0c11238f427396212e63f2fe0`,
`23f480c4de5cb7d921c0ae5485f4587e704eb2f4`,
`f1a37b4f4ffdefb0788d1149bbf2c61393e71a94`,
`d8278db7eda86221037d97996f1473498dce5b83`,
`15beb50106a641ab3eb02ed10679dd425de69913`,
`d0461881077f8ddc9f01520c31b67b82c01aa247`,
`6e88b61414417cdaeaae9586c606f175de099e48`,
`4cbdfcc9c1ef7018b208255a65f6051ff9ec9d92`,
`f11b414f342346dfd7200381d232045efb34de9a`,
`534941616edc1dac34d94fc184435b51593e3c79`,
`262327c04261deb43bfe3bd3e7ad1e9380c0c0ab`,
`030cf73f38c6bab9a0096af7706e6a85644026a2`,
`bc5e1e82dbbc506b562fc763e9ea92dba965b88d`, and
`1e81d170e997e6895b92cdc080563b28b60ac636`—to restore
`3c0957ebb2202f10de53975b2cb74e8f35253808` without rewriting published
history. That destructive breadth is not authorized by this bounded repair.

Current allowed claim before exact re-review: deterministic shadow-canon repair
candidate only; the exact parser, dependency registry, task-pack authorization,
generated projections, UX-blueprint, traceability, and governance checks above
are Green, and independent re-review remains pending. The visual candidate,
Gate B, task-pack visual selection, and authority cutover remain blocked.

Forbidden claims: active authority cutover; source UI implemented; Runtime Green; rendered-app Visual Green; Accessibility Green; privacy/legal approval; device readiness; TestFlight readiness; App Store readiness; Release Green.
