# OpenAI Build Suite Usage Policy

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-82439366, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748, AMB28-stale_or_unknown_active_status-21513953

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Purpose

This policy establishes a constrained, developer-tooling boundary for OpenAI capabilities inside the Ambitions repo.

- Install local tooling that helps Codex/engineers build, inspect, and report on the repo.
- Keep Ambitions runtime behavior unchanged unless a future user-approved product architecture change explicitly requires it.

## Allowed Dev-Only Uses

1. Repository intelligence and retrieval workflows.
2. Prompt drafting/repair assistance for batch prompts and closeout summaries.
3. Eval scaffolding and grading simulation for local checks.
4. Batch report extraction and consistency checks.
5. Visual critique simulations that validate documentation packets and checklist structure.
6. Launch packet drafting from existing evidence artifacts.

These uses are explicitly **developer control-plane support only**.

## Forbidden Runtime Uses

OpenAI shall **never** be added to the Ambitions app runtime by this batch. In particular, this policy forbids:

- OpenAI runtime import or SDK usage in `Native/Ambitions/**`.
- OpenAI calls from app runtime entrypoints, services, domain logic, repositories, or tests.
- Requiring API keys in application startup or launch.
- Runtime network calls to OpenAI from the active product surfaces.
- Any change that moves core decisions for Today/Goals/Capture/Time/You into a hosted model loop.

## Privacy Boundaries

- OpenAI tooling outputs are local temporary artifacts unless explicitly promoted.
- Personal screenshots, personal notes, raw user journals, schedule history, and private receipts are treated as sensitive by default.
- No personal data is sent in this batch.
- Redaction policies must remove private identifiers before any external transfer.

## Redaction Requirements

All OpenAI tooling paths must apply redaction rules before reading user-like data:

- `tools/openai/config/redaction_rules.json`
- `tools/openai/repo_brain/build_repo_manifest.py` (path filtering and artifact exclusions)
- `scripts/openai-build-suite-validate.py` (fails on likely keys/secrets and sensitive-path mentions)

## API Key Handling

- Do not add keys to source files.
- Do not add defaults that set keys in env files or scripts.
- Do not add environment variables carrying keys unless explicitly gated and operator-authorized.
- This batch only supports developer-local opt-in runtime key usage for manual runs, and only when invoked intentionally outside app runtime.

## Local-First Ambitions Boundary

Ambitions architecture remains local-first and on-device-first for core behavior.

This policy explicitly protects:

- Core recommendation logic
- Recommendation explainability and trust seams
- Capture placement and closure flows
- Receipt, proof, and persistence behavior

No OpenAI dependency is permitted in these boundaries unless a future batch updates product architecture and all product/trust gates.

## Optional Future Extension Rules

Future extensions may add:

1. User-controlled cloud-assisted review mode only.
2. Explicit opt-in consent UI.
3. Offline-first fallback first, cloud optional second.
4. No behavior changes without release gate updates and claim-boundary updates.

These remain future work and are **not active in this batch**.

## No-Claim Boundaries

Do not claim:

- OpenAI-enabled runtime intelligence.
- completion of core platform intelligence.
- release, TestFlight, App Store, device, accessibility, privacy, performance, or legal readiness.

This batch claims only scaffolding, validation gates, and local dry-run capability.

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
