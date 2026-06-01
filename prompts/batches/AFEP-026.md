<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-026 - Archive and Tombstone Lifecycle Policy

You are Codex operating in repo `agentdevan/ambitions`.

Create and run a gate-safe implementation batch for:

`AFEP-026 - Archive and Tombstone Lifecycle Policy`

Linear issue: `AMB-420`

## Batch ID

AFEP-026

## Objective

Define an enforceable archive and tombstone lifecycle policy for Ambitions artifacts without deleting historical material, changing runtime behavior, or allowing historical/supporting material to override active truth.

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
- `docs/codex/AFEP_EXECUTABLE_ARCHITECTURE_MANIFEST.json`
- `scripts/afep025_architecture_manifest_validate.py`
- current archive, cleanup, stale-material, claim-scan, batch-runner, and repo MCP scripts/docs
- recent AFEP proof artifacts, especially AFEP-002 and AFEP-025

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

The Private Life Runtime remains local-first and deterministic. External/cloud LLMs are not core architecture. CloudKit is optional continuity only and never the source of truth.

Historical, archived, tombstoned, deprecated, generated, and supporting material may never override `docs/truth/*`, live source, or current proof evidence.

Lifecycle governance may reference `SourceRecord`, `Receipt`, `ReplayTrace`, and `You / What Ambitions knows` only as provenance, recovery, and inspection concepts. Do not modify their runtime owners or behavior in this batch.

## Allowed scope

Gate-safe lifecycle governance/support only:

- Define lifecycle states for repo artifacts and product data concepts:
  - active
  - supporting
  - deprecated
  - archived
  - historical
  - tombstoned
  - delete-candidate
  - generated
  - local-only
  - proof-only
- Distinguish code, docs, proof artifacts, projections, object records, generated reports, and local-only developer artifacts.
- Add a repo-local validator or simulation script if useful and deterministic.
- Encode historical-policy alignment with `docs/truth/HISTORICAL_POLICY.md`.
- Encode recoverability, finalization, export-safe archive views, and rollback requirements.
- Add fixtures or simulations proving:
  - active truth cannot be superseded by historical/supporting material;
  - archived material remains traceable but non-authoritative;
  - tombstoned material requires recovery metadata;
  - delete-candidate material requires extract-then-delete evidence and rollback;
  - generated/local-only artifacts cannot become proof by default;
  - proof-only material cannot become release readiness without current evidence;
  - lifecycle policy rejects unrecoverable tombstones and historical authority drift.
- Add proof artifacts:
  - `docs/audits/afep026-archive-tombstone-lifecycle-report.md`
  - `docs/audits/afep026-historical-policy-alignment-report.md`
  - `docs/audits/afep026-recovery-export-simulation-report.md`
  - `docs/audits/afep026-rollback-to-existing-historical-policy.md`
- Preserve rollback to the existing narrative historical policy if machine-readable lifecycle governance is unstable.

## Forbidden scope

- Do not delete historical material.
- Do not tombstone or delete active source, current tests, current scripts, entitlements, privacy manifest, Xcode project files, or current proof artifacts.
- Do not modify production app/runtime behavior.
- Do not implement or alter runtime object storage, sync, migration, projection finalization, or user-data deletion behavior.
- Do not silently migrate, delete, archive, or tombstone user data.
- Do not add hosted CI, GitHub Actions, external runners, cloud storage, backend, analytics, telemetry, signing, notarization, App Store upload, TestFlight upload, or paid/external service dependencies.
- Do not make lifecycle governance a higher authority than `docs/truth/*`, live source, or current proof evidence.
- Do not claim release readiness, accessibility conformance, privacy/legal approval, performance readiness, device validation, TestFlight readiness, App Store readiness, CI proof, or production readiness.
- Do not change canonical IA or reintroduce `Plan` as a user-facing top-level destination.
- Do not mark AFEP complete unless all AFEP issue, project, validation, and proof closeout gates are explicitly Green.

## Validation

Run the strongest available scoped validation commands. Prefer:

- lifecycle validator self-test or fixture test;
- recovery/export simulation command/report;
- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-026`;
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-026 --prompt prompts/batches/AFEP-026.md --batch-type source-changing`;
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-026 --prompt prompts/batches/AFEP-026.md --changed-from <BASE_SHA> --batch-type source-changing`;
- relevant claim-scan/release-proof/obsolete-authority scripts if present;
- `python3 tools/mcp/ambitions_repo_mcp/server.py --self-test`;
- `git diff --check`;
- Xcode build/test only if app/test source is touched.

## Acceptance gates

Green only if:

- lifecycle states are distinct and deterministic;
- no historical/supporting/archived/tombstoned/delete-candidate material can override active truth;
- tombstoned and delete-candidate states require recoverability, provenance, finalization, and rollback metadata;
- generated/local-only/proof-only material cannot become proof or authority by default;
- export-safe archive view behavior is documented or simulated;
- rollback to existing historical policy is documented;
- guard post status is Green, or accepted Yellow is fully documented with owner, safety reason, no-claim boundary, and follow-up gate;
- no production runtime behavior, user-data behavior, or destructive repo cleanup is introduced.

## Hard Red

Stop and report Red if the batch:

- deletes historical material;
- introduces unrecoverable tombstones;
- lets historical/supporting material override active truth;
- makes lifecycle governance higher authority than truth files, live source, or current proof;
- changes runtime storage, sync, migration, projection finalization, or user-data deletion behavior;
- introduces hosted backend, analytics, telemetry, hosted CI, signing/upload automation, or paid/external services;
- reintroduces `Plan` as top-level IA;
- makes release, accessibility, privacy/legal, performance, device, TestFlight, App Store, CI, or production readiness claims without matching proof.

## Rollback

Rollback must be exact:

- remove lifecycle manifest/policy automation added by this batch;
- remove AFEP-026 fixtures/simulations;
- remove AFEP-026 proof artifacts;
- keep `docs/truth/HISTORICAL_POLICY.md`, `docs/truth/*`, `AGENTS.md`, and supporting docs as the active path;
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
- exact steps to disable/remove AFEP-026 automation and return to existing historical policy.

## Commit Behavior

Create a clean commit if validations are Green or accepted Yellow with documented boundary. Do not commit Red implementation.
