# Source Atlas Coverage Universe Runbook

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite
> Dispositions: rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

> Supporting note: This file supports current Ambitions work but does not override `docs/truth/`.

Status: Active runbook  
Scope: Local deterministic Source Atlas Coverage Universe commands

## Generate Scenarios

Dry run:

```bash
make source-atlas-coverage-dry-run
```

Generate a bounded scenario set:

```bash
make source-atlas-generate-scenarios RECIPE=core_runtime_minimum MAX=250
```

Generate a trust-destroyer set:

```bash
make source-atlas-generate-scenarios RECIPE=launch_trust_destroyers MAX=100
```

Large local output should go to `.generated/source-atlas`:

```bash
make source-atlas-generate-scenarios RECIPE=scale_candidate_generation MAX=10000 OUTPUT=.generated/source-atlas/scenarios.json
```

## Paste ChatGPT ScenarioSpecs

Use `source-atlas/coverage/chatgpt-scenario-generation-template.md`.

ChatGPT must generate ScenarioSpec JSON only, not source packs directly. Save pasted JSON locally, then validate:

```bash
python3 tools/source-atlas/coverage.py validate --input path/to/pasted-scenarios.json
```

## Validate Scenarios

```bash
make source-atlas-validate-scenarios INPUT=source-atlas/generated/proof/scenarios-with-mutations.json
```

Validation fails or rejects rows when dimensions are unknown, derivative/proof boundary fields are missing, local-only/privacy/receipt/closure/recovery expectations are missing, generated evidence is treated as proof, cloud-runtime language appears, secrets appear, or active IA language is violated.

## Generate Candidates

```bash
make source-atlas-generate-candidates INPUT=source-atlas/generated/accepted/accepted-scenarios.json MAX=50
```

Candidates are derivative source-context stubs. They are not source truth and cannot satisfy proof alone.

## Score Candidates

```bash
make source-atlas-score-candidates CANDIDATES=source-atlas/generated/candidates/candidates.json SCENARIOS=source-atlas/generated/accepted/accepted-scenarios.json
```

Scores use `source-atlas/coverage/quality-scoring.yaml`.

## Dedupe Candidates

```bash
make source-atlas-dedupe-candidates CANDIDATES=source-atlas/generated/candidates/scored-candidates.json
```

Outputs include duplicate and contradiction reports.

## Promote Fixtures

```bash
make source-atlas-promote-fixtures CANDIDATES=source-atlas/generated/candidates/scored-candidates.json SCENARIOS=source-atlas/generated/accepted/accepted-scenarios.json MAX=25
```

Promotion writes deterministic fixture inputs under `source-atlas/fixtures/` and receipts under `source-atlas/generated/receipts/`.

## Read The Heatmap

```bash
make source-atlas-coverage-report
```

Green means a value is covered by a promoted fixture or tested pack. Yellow means scenario/candidate only. Red means not covered or unsafe/incomplete. Gray means intentionally out of scope.

## Run A Gap-Fill Pass

Use a recipe aimed at the weakest Red/Yellow areas, then validate, score, dedupe, and promote a small fixture subset. Do not commit mass generated files.

## Avoid Mass Junk

- Keep high-volume runs in `.generated/source-atlas`.
- Commit schemas, configs, runbooks, reports, and small promoted fixtures only.
- Require receipts for every generation and promotion run.
- Reject generic productivity language and duplicate cells with weak variation.

## Preserve Boundaries

- Source packs are context substrate, not proof.
- Generated content is derivative, not canon.
- Runtime Green requires deterministic tests/logs/replay/validation proof.
- Ambitions stays local-first and does not gain app runtime network or cloud LLM behavior from this tooling.

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
