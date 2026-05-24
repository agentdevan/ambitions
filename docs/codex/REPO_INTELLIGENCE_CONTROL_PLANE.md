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
- `docs/codex/canonical-owner-map.yml`
- `docs/codex/existing-code-champion-coverage.yml`
- `docs/codex/concept-lock-registry.yml`
- Proof roots and validation commands referenced by the active prompt

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
- Repo-intelligence packet shape/budget check
- Champion coverage check
- Parallel implementation guard pre/post checks
- Runner status and final gate fields
- Direct file verification
- Validation scripts and tests
- Ambitions Proof MCP where available
- Claim scanners and audit reports

Outputs:

- Local evidence reports under `build/reports/repo-intelligence/`
- Per-batch Implementation Intelligence Packets under `build/reports/repo-intelligence/`
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

The active speed path is:

1. Sequential runner preflights tool availability.
2. Sequential runner builds a per-batch Implementation Intelligence Packet from the frozen prompt, CodeGraph/Semble output, owner maps, Champion coverage, concept locks, and proof roots.
3. Sequential runner validates packet shape and budgets without treating advisory Red rows as proof.
4. Child runner injects the full packet into Phase 01.
5. Phase 01 uses the packet to reduce broad search, propose a narrower boundary, and explicitly accept only directly verified owner/proof/wiring findings.
6. Phase 02 receives only the Phase 01 accepted bounded subset.
7. Review/final gates compare accepted findings to the actual diff, guard reports, validation output, and proof artifacts.
8. No advisory-only row may be used as source truth, validation proof, release proof, accessibility proof, privacy proof, performance proof, or completion proof.
