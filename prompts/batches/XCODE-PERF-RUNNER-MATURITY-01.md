<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# XCODE-PERF-RUNNER-MATURITY-01 - Install mature Xcode/Codex performance intelligence

You are operating inside `agentdevan/ambitions`.

## Mission

Install a mature, low-risk performance layer for Ambitions' Codex runner, autonomous train, Xcode validation wrappers, and operator guidance so local Mac VM + Xcode + Codex workflows become faster, more measurable, and more intelligent without weakening proof honesty.

This is a tooling/governance/performance batch only. Do not change product behavior, app UI, domain behavior, privacy claims, release claims, or Ambitions product canon.

The expected outcome is:

1. Codex/autonomous train can discover and use the Xcode benchmark helper.
2. Runner and speed-train paths prefer the fastest validation lane that proves the touched scope.
3. Slow Xcode validation is diagnosed with timing evidence before cache deletion or full-suite escalation.
4. Build/test commands preserve repo-local DerivedData and warm simulator strategy.
5. Heavy Xcode validation remains available, but not accidentally run for every batch.
6. Performance evidence is written to ignored `.codex/` artifacts, summarized clearly, and never misrepresented as release proof.

## Non-negotiable constraints

- Start from active truth files.
- Do not reintroduce `Plan` as top-level IA.
- Do not add external services, paid tools, hosted CI, analytics, AI SDKs, or cloud dependencies.
- Do not add product runtime dependencies.
- Do not clean global DerivedData.
- Do not erase all simulators.
- Do not make build/test/release/accessibility/device/App Store claims without current evidence.
- Do not commit generated benchmark output, `.xcresult` bundles, logs, DerivedData, or `.codex/runs/` noise.
- Preserve the existing Ambitions runner architecture.
- Prefer small, surgical integration points over broad rewrites.

## Mandatory first read

Read these before editing:

1. `docs/truth/README.md`
2. `docs/truth/CODEX_PROCESS_TRUTH.md`
3. `docs/truth/IMPLEMENTATION_TRUTH.md`
4. `docs/truth/RELEASE_TRUTH.md`
5. `AGENTS.md`
6. `.agents/skills/ambitions-ios-validation-xcode-wrapper/SKILL.md`
7. `docs/codex/XCODE_BUILD_LAB_PROTOCOL.md`
8. `docs/codex/SPEED_TRAIN_QUICKSTART.md`
9. `docs/codex/SPEED_TRAIN_LANE_POLICY.json`
10. `scripts/ambitions-codex-train.sh`
11. `scripts/ambitions-autonomous-train.sh`
12. `scripts/ambitions-speed-train.sh`
13. `scripts/ambitions-xcode-validate.sh`
14. `scripts/ambitions-xcode-build-for-testing.sh`
15. `scripts/ambitions-xcode-test-focused.sh`
16. `scripts/ambitions-xcode-test-plan.sh`
17. `scripts/ambitions-xcode-sim-health.sh`
18. `scripts/ambitions-deriveddata-manager.sh`
19. `Makefile`
20. `.gitignore`

## Existing benchmark helper

A benchmark helper may already exist:

```bash
scripts/ambitions-xcode-benchmark.sh
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
