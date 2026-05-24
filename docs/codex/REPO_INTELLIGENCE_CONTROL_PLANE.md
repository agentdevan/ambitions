# Repo Intelligence Control Plane

Status: Supporting control-plane architecture note.
Scope: Local advisory developer tooling only; not product runtime.

## Architecture

Inputs:

- Repo files
- `docs/truth/*`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- iOS 26 runner prompts and frozen prompt boundaries
- Existing local indexes when manually created

Primary front door:

- `scripts/ios26-flagship-run-sequential.sh`

Canonical execution:

- `scripts/ambitions-codex-train.sh`

Advisory tools:

- CodeGraph
- Semble
- Understand Anything

Control gates:

- iOS 26 sequential preflight
- iOS 26 proof-packet check
- Runner status and final gate fields
- Direct file verification
- Validation scripts and tests
- Ambitions Proof MCP where available
- Claim scanners and audit reports

Outputs:

- Local evidence reports under `build/reports/repo-intelligence/`
- Shape-check reports under `build/reports/ios26-sequential-runner-shape/`
- Final gate fields that record tool usage, verification, fallback, and staged-artifact hygiene

## Anti-Patterns

- Treating graph output as truth
- Treating generated summaries as proof
- Running broad install scripts
- Committing caches, tool DBs, dashboards, generated graphs, or local indexes
- Bypassing the iOS 26 sequential runner for iOS 26 train execution
- Replacing `scripts/ambitions-codex-train.sh`
- Letting semantic confidence replace tests or direct validation
- Using Understand Anything as proof, source truth, or a runner gate
- Adding app runtime dependencies for developer repo-intelligence tooling

## Safety Model

Repo-intelligence tooling can accelerate finding likely relevant files. It cannot approve Green. Green still requires direct repo evidence, validation, and preserved runner gates.
