# Codex OS Index

Active repo authority starts in [`../truth/README.md`](../truth/README.md). If this file conflicts with `docs/truth/*`, the truth files win.

Current consolidated Codex OS router: [`../../.codex/OPERATING_SYSTEM.md`](../../.codex/OPERATING_SYSTEM.md). This index remains supporting navigation.

Current repo map for future ChatGPT/Codex questions: [`../../.codex/REPO_INVENTORY.md`](../../.codex/REPO_INVENTORY.md). It is a routing index, not product truth or proof.

## Required read order

1. [`../truth/README.md`](../truth/README.md)
2. [`../truth/PRODUCT_DESIGN_TRUTH.md`](../truth/PRODUCT_DESIGN_TRUTH.md)
3. [`../truth/IMPLEMENTATION_TRUTH.md`](../truth/IMPLEMENTATION_TRUTH.md)
4. [`../truth/RELEASE_TRUTH.md`](../truth/RELEASE_TRUTH.md)
5. [`../truth/CODEX_PROCESS_TRUTH.md`](../truth/CODEX_PROCESS_TRUTH.md)
6. [`../truth/HISTORICAL_POLICY.md`](../truth/HISTORICAL_POLICY.md)
7. [`../../AGENTS.md`](../../AGENTS.md)
8. [`../../.codex/REPO_INVENTORY.md`](../../.codex/REPO_INVENTORY.md) for repo map / routing questions.
9. Current active-batch state, Codex docs, manifests, reports, and scripts as needed.

## Speed Train operating docs

Use these when the operator explicitly prioritizes batch completion speed:

- [`SPEED_TRAIN_OPERATING_MODEL.md`](./SPEED_TRAIN_OPERATING_MODEL.md)
- [`SPEED_TRAIN_QUICKSTART.md`](./SPEED_TRAIN_QUICKSTART.md)
- [`SPEED_TRAIN_LANE_POLICY.json`](./SPEED_TRAIN_LANE_POLICY.json)
- [`ambitions-hybrid-runner.md`](./ambitions-hybrid-runner.md)
- [`../audits/speed-train-autonomy-01-report.md`](../audits/speed-train-autonomy-01-report.md)

Commands:

```bash
make speed-status
make speed-next
make speed-once
MAX_BATCHES=10 make speed-train
make speed-final-gate
```

## Throughput operating docs

- [`BATCH_THROUGHPUT_OPERATING_MODEL.md`](./BATCH_THROUGHPUT_OPERATING_MODEL.md)
- [`BATCH_LANE_CLASSIFICATION_POLICY.md`](./BATCH_LANE_CLASSIFICATION_POLICY.md)
- [`BATCH_PREP_FACTORY.md`](./BATCH_PREP_FACTORY.md)
- [`BATCH_TEST_ROUTER.md`](./BATCH_TEST_ROUTER.md)
- [`KNOWN_YELLOW_QUARANTINE_LEDGER.md`](./KNOWN_YELLOW_QUARANTINE_LEDGER.md)

## OpenAI Build Suite (docs/tooling-only, non-runtime)

- [`OPENAI_BUILD_SUITE_USAGE_POLICY.md`](./OPENAI_BUILD_SUITE_USAGE_POLICY.md)
- [`OPENAI_BUILD_SUITE_ADOPTION_MATRIX.md`](./OPENAI_BUILD_SUITE_ADOPTION_MATRIX.md)
- [`CODEX_MULTI_AGENT_BUILD_SYSTEM.md`](./CODEX_MULTI_AGENT_BUILD_SYSTEM.md)
- [`REPO_INTELLIGENCE_LAYER.md`](./REPO_INTELLIGENCE_LAYER.md)
- [`OPENAI_EVAL_QA_LAYER.md`](./OPENAI_EVAL_QA_LAYER.md)
- [`PROMPT_REPAIR_LAYER.md`](./PROMPT_REPAIR_LAYER.md)
- [`BATCH_REPORT_LAYER.md`](./BATCH_REPORT_LAYER.md)
- [`VISUAL_CRITIQUE_LAYER.md`](./VISUAL_CRITIQUE_LAYER.md)
- [`LAUNCH_DOCUMENTATION_LAYER.md`](./LAUNCH_DOCUMENTATION_LAYER.md)

Tooling targets:

```bash
make openai-build-suite-validate
make openai-build-suite-dry-run
make openai-repo-brain-index
make openai-evals-dry-run
make openai-batch-report-dry-run
make openai-visual-critique-dry-run
make openai-launch-docs-dry-run
```

## Boundary

Codex OS files are operating context. They are not product source truth, shipped behavior proof, validation proof, release proof, or approval to change app behavior.

Speed Train increases throughput. It does not imply release, build, visual, device, accessibility, performance, privacy/legal, App Store, TestFlight, or global completion proof.

Historical Ambitions 3.0 / 4.0 / batch-train material remains supporting context only where compatible with `docs/truth/*`.
