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
