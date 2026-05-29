# Global Train Supervisor

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-10542241

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active Codex OS runbook
Authority: Supporting process doc subordinate to `docs/truth/*`

The global train should be run by the external supervisor script, not by a long-lived nested Codex conductor phase.

For non-recursive continuation after autonomy-hardening, prefer:

```bash
make autonomous-train
```

The existing supervisor remains available for compatibility and manual scoped operations.

## Why This Exists

The previous recursive conductor model could start a parent prompt, generate or select a child batch, launch the child through the runner, see incomplete/Yellow/Unknown artifacts, and then launch another attempt before the first path was finalized. That caused repeated same-root retries, Phase 02 reruns when final GPT-5.5 review was needed, and overlapping validation/Xcode lock risk.

The repair is a single-owner loop:

```text
one batch -> one runner lifecycle -> inspect result -> update ledger -> continue or stop
```

## Commands

```bash
make global-train-status
make global-train-next
make global-train-once
make global-train-until-complete
```

Direct script equivalents:

```bash
scripts/ambitions-global-train-supervisor.sh --status
scripts/ambitions-global-train-supervisor.sh --next
scripts/ambitions-global-train-supervisor.sh --once
scripts/ambitions-global-train-supervisor.sh --until-complete
```

Default script mode is `--once`.

## Attempt Ledger

The supervisor consults `.codex/state/global-train-attempt-ledger.md`.

Supported unresolved states:

- `running`
- `yellow-unresolved`
- `red-unresolved`
- `unknown-unresolved`
- `repair-required`
- `finalization-required`
- `blocked`

Continuation states:

- `green`
- `accepted-yellow`

An unresolved state blocks a normal rerun. The next step must be a separately named finalization or repair prompt, such as `PK15-FINALIZE-01`.

## Yellow Handling

Yellow may continue only when all of this is recorded:

- owner
- reason
- no-claim boundary
- retirement condition
- resume path
- proof path
- why continuation is safe

Missing Yellow acceptance data keeps the state unresolved and stops the supervisor.

## Red And Unknown Handling

Red stops. Unknown is treated as unresolved unless artifact inspection proves otherwise.
A build lock or active conflicting runner/Codex/Xcode process also stops.

Hard-red process conflict gate rule:

- Do not use broad `pgrep` patterns as a hard red gate.
- Use `scripts/ambitions-process-preflight.sh --assert-clear` instead.
- `xcodebuildmcp` is not a real `xcodebuild` validation process and is ignored by the shared preflight helper.

The supervisor does not kill processes automatically. It reports process IDs and exits.

## Finalization Prompts

Use `prompts/_BATCH_FINALIZE_TEMPLATE.md` to create finalization prompts. A finalization prompt reviews existing diff/artifacts and must not rerun the GPT-5.4-mini bounded implementation phase or the original batch from scratch.

Current unresolved PK15 work is routed through:

```bash
make batch BATCH=PK15-FINALIZE-01 PROMPT=prompts/batches/PK15-FINALIZE-01.md
```

## Non-Claims

Supervisor Green means the operating model and local script checks passed. It does not prove app build success, full test success, release readiness, visual quality, accessibility conformance, performance validation, physical-device validation, TestFlight readiness, App Store readiness, legal/privacy approval, or global train completion.

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
