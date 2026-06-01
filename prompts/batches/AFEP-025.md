<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-025 - Executable Architecture Manifest

You are Codex operating in repo `agentdevan/ambitions`.

Create and run a gate-safe implementation batch for:

`AFEP-025 - Executable Architecture Manifest`

Linear issue: `AMB-419`

## Batch ID

AFEP-025

## Objective

Make AFEP architecture governance machine-readable and enforceable without letting any manifest override `docs/truth/*`, live source, or current proof evidence.

## Active source truth

Inspect current repo truth before editing:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`
- current architecture, canon, release-boundary, claim-scan, obsolete-authority, batch-runner, and repo MCP scripts/docs
- recent AFEP evidence artifacts, especially AFEP-019A through AFEP-024
- current runtime provenance owners and inspection language for `SourceRecord`, `Receipt`, `ReplayTrace`, and `You / What Ambitions knows`, as references only

## Product Law

Ambitions remains a premium native iPhone-first, local-first Personal Life OS.

Canonical IA is exactly:

`Today / Goals / Capture / Time / You`

Canonical primary objects:

- Today -> Reality Meridian / Start Here
- Goals -> Constellation Atlas
- Capture -> Atmosphere Composer
- Time -> LifeShape Field
- You -> User System Profile

The Private Life Runtime remains local-first and deterministic. External/cloud LLMs are not core architecture. CloudKit is optional continuity only and never the source of truth. The manifest must encode these boundaries as governance checks, not as product/runtime implementation.

## Allowed scope

Gate-safe architecture governance/support only:

- Add a machine-readable architecture manifest in an appropriate governance/docs/config location.
- Add a repo-local validator script for the manifest.
- Encode canonical IA, object grammar, dependency gates, privacy boundaries, local-first authority, CloudKit optional-continuity limits, release proof boundaries, and hard Red architecture drift conditions.
- Encode artifact classification such as active, supporting, deprecated, archived, historical, generated, local-only, and proof-only.
- Encode `SourceRecord`, `Receipt`, `ReplayTrace`, and `You / What Ambitions knows` only as provenance/inspection concepts that the manifest must respect; do not modify those runtime owners.
- Ensure the manifest explicitly states that `docs/truth/*`, live source, and current proof evidence remain higher authority.
- Add drift simulations or fixtures proving the validator catches:
  - top-level `Plan` reintroduction;
  - required cloud/core LLM dependency;
  - custom hosted personal-data backend as launch requirement;
  - analytics/telemetry SDK introduction without explicit approval;
  - CloudKit as source of truth;
  - release/readiness claims without proof;
  - privacy boundary drift.
- Add proof artifacts:
  - `docs/audits/afep025-executable-architecture-manifest-report.md`
  - `docs/audits/afep025-architecture-validator-report.md`
  - `docs/audits/afep025-drift-simulation-report.md`
  - `docs/audits/afep025-rollback-to-narrative-governance.md`
- Preserve rollback to narrative governance if the validator is unstable.

## Forbidden scope

- Do not modify production app/runtime behavior.
- Do not implement or alter `SourceRecord`, `Receipt`, `ReplayTrace`, or `You / What Ambitions knows` runtime behavior; they are inspection/provenance references for this governance batch only.
- Do not add hosted CI, GitHub Actions, external runners, cloud storage, backend, analytics, telemetry, signing, notarization, App Store upload, TestFlight upload, or paid/external service dependencies.
- Do not make the manifest a higher authority than `docs/truth/*`, live source, or current proof evidence.
- Do not claim release readiness, accessibility conformance, privacy/legal approval, performance readiness, device validation, TestFlight readiness, App Store readiness, CI proof, or production readiness.
- Do not change canonical IA or reintroduce `Plan` as a user-facing top-level destination.
- Do not turn CloudKit into source of truth or silently sync user data.
- Do not mark AFEP complete unless all AFEP issue, project, validation, and proof closeout gates are explicitly Green.

## Validation

Run the strongest available scoped validation commands. Prefer:

- manifest validator self-test or fixture test;
- drift simulation command/report;
- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-025`;
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-025 --prompt prompts/batches/AFEP-025.md --batch-type source-changing`;
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-025 --prompt prompts/batches/AFEP-025.md --changed-from <BASE_SHA> --batch-type source-changing`;
- relevant claim-scan/release-proof/obsolete-authority scripts if present;
- `python3 tools/mcp/ambitions_repo_mcp/server.py --self-test`;
- `git diff --check`;
- Xcode build/test only if app/test source is touched.

## Acceptance gates

Green only if:

- executable architecture manifest exists and is deterministic/repo-local;
- validator catches the required drift cases;
- manifest stays subordinate to `docs/truth/*`, live source, and current proof evidence;
- canonical IA and product law are encoded correctly;
- release/readiness claims remain separated from local validation;
- rollback to narrative governance is documented;
- guard post status is Green, or accepted Yellow is fully documented with owner, safety reason, no-claim boundary, and follow-up gate;
- no production runtime behavior or user data behavior changes were introduced.

## Hard Red

Stop and report Red if the batch:

- makes the manifest higher authority than truth files, live source, or current proof;
- introduces required cloud/core LLM behavior;
- introduces hosted backend, analytics, telemetry, hosted CI, signing/upload automation, or paid/external services;
- reintroduces `Plan` as top-level IA;
- weakens privacy/local-first claims or CloudKit optional-continuity boundaries;
- makes release, accessibility, privacy/legal, performance, device, TestFlight, App Store, CI, or production readiness claims without matching proof;
- changes app/runtime behavior outside explicitly approved scope.

## Rollback

Rollback must be exact:

- remove the manifest;
- remove the validator and fixtures;
- remove AFEP-025 proof artifacts;
- keep narrative governance in `docs/truth/*`, `AGENTS.md`, and supporting docs as the active path;
- rerun claim scans and `git diff --check`.

## Report Format

At the end, produce:

GREEN / YELLOW / RED

Changed files:
- ...

Validation:
- command -> result

Proof artifacts:
- ...

What AFEP can do next:
- ...

What remains blocked:
- ...

Rollback:
- exact steps to disable/remove AFEP-025 automation and return to narrative governance.

## Commit Behavior

Create a clean commit if validations are Green or accepted Yellow with documented boundary. Do not commit Red implementation.
