<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`<BATCH_ID>-FINALIZE-01`

# Objective

Finalize an existing unresolved batch attempt from live repo evidence.

This is a review/finalization attempt, not an implementation restart. Inspect the current diff, latest run artifacts, source truth, and validation notes. Run only focused, sequential validation needed to decide whether the existing bounded patch is safe to commit with accepted Yellow notes or must stop Red.

# Required Behavior

- Inspect the existing diff before editing.
- Inspect the latest `.codex/runs/<BATCH_ID>/*/final-summary.md` and phase finals.
- Do not rerun the GPT-5.4-mini bounded implementation phase.
- Do not rerun the original batch from scratch.
- Do not invoke the global conductor.
- Do not invoke nested `make batch`.
- Do not run concurrent `xcodebuild`.
- Do not run raw `xcodebuild` from nested Codex phases unless the unresolved
  batch explicitly requires raw command proof.
- Prefer `make xcode-focused-test BATCH=<BATCH_ID> TEST=<test-id>` or
  `scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane focused-test --test <test-id>`.
- If XcodeBuildMCP timed out, treat that as not XCTest proof and recover through
  the wrapper lane instead of retrying the same MCP timeout path.
- Do not broaden cleanup.
- Do not fix unrelated failures unless the existing batch caused them.
- Commit only if the bounded patch is safe, validation is Green or accepted Yellow, and all no-claim boundaries are recorded.
- Update queue/state only when evidence supports it.

# Process Locks

Before validation, check for process blockers with the shared preflight helper:

```bash
scripts/ambitions-process-preflight.sh --assert-clear
```

If helper output is `STATUS: BLOCKED`, report blockers and stop with `STATUS: RED` or unresolved Yellow. Do not kill processes unless a separate repair prompt explicitly authorizes it.
If helper output is `STATUS: UNKNOWN`, classify conservatively and stop with `STATUS: RED` until uncertainty is resolved.
`xcodebuildmcp` is not a blocker; it is ignored by the shared preflight helper.

# Validation Shape

Use focused sequential validation. Prefer the smallest proof that exercises the changed seam. For simulator build/test proof, use the Ambitions Xcode Build Lab wrapper so the run gets stable simulator selection, derived-data reuse, log capture, summary output, and failure classification. If a broader suite fails, classify whether the failure is caused by this batch. Do not convert unrelated failures into proof of success.

# Final Output

End with:

```text
STATUS: GREEN
```

or

```text
STATUS: YELLOW
```

or

```text
STATUS: RED
```

Include files changed, commands run with exit codes, proof paths, accepted Yellow owner/reason/no-claim boundary/retirement condition/resume path when applicable, and claims not made.
