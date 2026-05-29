<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

CODEX-RUNNER-READ-ONLY-AUDIT-MODE-01

## Objective

Add a safe read-only audit mode or clearly documented operator path for Ambitions runner-mediated audits that must not create branches, commits, pushes, or mutable `.codex/runs` artifacts unexpectedly.

This is Codex OS/tooling only. Do not modify app source or product behavior.

## Active Source Truth To Inspect

- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `scripts/ambitions-codex-train.sh`
- `scripts/ambitions-runner-self-check.sh`
- `scripts/ambitions-prompt-audit.sh`
- `Makefile`
- `.codex/README.md`
- docs/codex runner docs if present

## Allowed Scope

- `scripts/ambitions-codex-train.sh`
- `scripts/ambitions-runner-self-check.sh`
- `scripts/ambitions-prompt-audit.sh`
- `Makefile`
- `.codex/README.md`
- `docs/codex/**` runner/operator docs
- focused tests/self-check fixtures for runner behavior

## Required Work

- Provide a deterministic way to run audit/report-only batches without branch creation, commit creation, push, or surprise tracked source mutation.
- Ensure self-check or a focused dry-run check proves the read-only audit posture.
- Keep default safety conservative and backwards-compatible.

## Validation Expectations

- `scripts/ambitions-codex-train.sh --self-check`
- `scripts/ambitions-prompt-audit.sh`
- `bash -n scripts/ambitions-codex-train.sh`
- `git diff --check`

## Forbidden Scope

- No app source changes.
- No git mutation during validation.
- No hosted CI, provider, network, shell-MCP, or secret-reading tooling.

## Runner Command

```bash
make batch BATCH=CODEX-RUNNER-READ-ONLY-AUDIT-MODE-01 PROMPT=prompts/batches/CODEX-RUNNER-READ-ONLY-AUDIT-MODE-01.md
```

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
