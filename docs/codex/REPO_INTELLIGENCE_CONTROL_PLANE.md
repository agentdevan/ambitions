# Repo Intelligence Control Plane

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-59159814, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-69734110, AMB28-same_surface_multiple_active_batches-66075429, AMB28-stale_or_unknown_active_status-70208158

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Supporting control-plane architecture note.
Scope: Local advisory developer tooling only; not product runtime.

## Architecture

Inputs:

- Repo files
- `docs/truth/*`
- `docs/codex/LINEAR_CONTROL_PLANE.md` when mirroring repo work into Linear
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
- Linear workflow mirrors, only when they point back to exact repo authority,
  source, prompt, proof, and log paths

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
- Treating Linear issue status as repo truth, proof, release evidence, or train
  selection authority
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
