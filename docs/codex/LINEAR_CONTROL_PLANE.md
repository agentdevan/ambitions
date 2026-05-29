# Linear Control Plane

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

> Supporting note: This file supports current Ambitions work but does not override `docs/truth/`.

Status: Supporting workflow control-plane design
Scope: Repo-to-Linear sync, Linear issue generation, and Linear status interpretation
Issue: AMB-40

This file defines how Linear may sit on top of the existing Ambitions repo
authority stack. It does not create a new product, implementation, release, or
batch-train authority.

## Authority Order

Every Linear sync, generated issue, generated project, and status update must
read repo authority in this order:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `README.md`
10. `docs/codex/GLOBAL_BATCH_SEQUENCE.md`
11. `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
12. `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
13. `docs/codex/IOS26_FLAGSHIP_SEQUENTIAL_RUNBOOK.md`
14. Relevant prompts, source files, scripts, proof roots, and current logs

If Linear data conflicts with this repo order, the repo order wins.

## Train Selection Rule

Linear must treat `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json` as the
machine-readable train-selection authority.

Current selection interpretation:

- Runnable global train batch IDs must use the `IOS26-` prefix.
- Non-`IOS26-*` batch IDs are historical for global train selection unless a
  human explicitly creates a scoped IOS26-compatible repair.
- `docs/codex/GLOBAL_BATCH_SEQUENCE.md` is the human-readable authority doc.
- `.codex/state/active-batch.yml` and `.codex/reports/*` are useful mirrors and
  historical context, not a stronger selection authority.

Linear-generated work must not reopen PK, SA, EFC, CS, PXOS, or other
historical batch rows as runnable global train work unless the repo authority
files first establish a new scoped IOS26-compatible batch.

## IOS26 Manifest Rule

Linear must treat `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml` as the
installed IOS26 train manifest.

Current manifest interpretation:

- `status: installed_not_run`
- `runner_required: true`
- `run_with: scripts/ambitions-codex-train.sh`
- `direct_codex_execution: forbidden_unless_user_explicitly_bypasses_runner`
- Proof roots live under the manifest `proof_artifact_roots` list.

Linear may mirror train, batch, dependency, proof-root, and status data from the
manifest, but it must not claim IOS26 implementation, build, test, accessibility,
performance, device, TestFlight, App Store, privacy, or release readiness from
manifest presence alone.

## Canon Delta Detection

Linear sync must flag external planning decisions that are not installed in repo
truth.

Current required flag:

- Pulse/global Capture is an external canon-change proposal, not active repo
  truth.
- Active repo truth still names top-level IA as
  `Today / Goals / Capture / Time / You`.
- `Capture` remains singular and top-level.
- Any Linear issue that proposes Pulse, global Capture, a sixth top-level
  destination, or replacement root IA must be marked as a canon-change proposal
  requiring a truth-file update before implementation.

Until `docs/truth/*` changes, Linear must not generate implementation work that
treats Pulse/global Capture as already installed canon.

## Generated Work Requirements

Any Linear-generated issue or project item must include exact repo links for:

- authority files inspected
- source files or directories affected
- prompt files or runner commands when execution is requested
- proof roots expected for validation
- logs or reports that support any status claim
- no-claim boundaries for release, accessibility, performance, privacy, device,
  TestFlight, App Store, and CI readiness

Use repo paths, not vague references. Examples:

- `docs/truth/README.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `prompts/batches/IOS26-T00-B01-repo-source-inventory.md`
- `build/reports/ios26-baseline/`

## Status Mapping

Linear status is a workflow mirror only.

| Linear Meaning | Repo Requirement |
| --- | --- |
| Todo | Work is requested but not proven or executed. |
| In Progress | Work is being inspected or patched; repo truth still wins. |
| Done | Acceptance criteria were satisfied in repo files or Linear metadata, with proof/no-claim boundaries recorded. |
| Blocked | A repo truth conflict, runner gate, missing proof, or human approval gate prevents safe continuation. |

Do not convert Linear `Done` into implementation, validation, release, or
product-completeness proof. Current source, current logs, and current proof
artifacts remain required.

## AMB-40 Acceptance Trace

- Linear sync reads `docs/truth/*` first: covered by Authority Order.
- Linear sync treats `GLOBAL_BATCH_SEQUENCE_AUTHORITY.json` as train selection
  authority: covered by Train Selection Rule.
- Linear sync treats `IOS26_FLAGSHIP_TRAIN_MANIFEST.yml` as installed train
  manifest: covered by IOS26 Manifest Rule.
- Linear catches Pulse/global Capture as not yet installed repo canon: covered by
  Canon Delta Detection.
- Linear-generated work links to exact repo files and proof paths: covered by
  Generated Work Requirements.

## Non-Claims

This file does not prove:

- Linear API sync implementation exists
- Linear issue upsert scripts exist
- IOS26 train execution
- app build or test success
- accessibility, performance, device, TestFlight, App Store, privacy, legal, or
  release readiness

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
