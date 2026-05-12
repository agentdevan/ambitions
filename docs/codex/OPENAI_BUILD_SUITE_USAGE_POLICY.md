# OpenAI Build Suite Usage Policy

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
