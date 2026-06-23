# ADR-2026-06-22 — Runtime Remediation Canon and Codex Dossier System

## Status

Accepted.

## Context

The 2026-06-22 runtime device review and the prior app testing report showed systemic failures across shell, Today, Capture, Goals, Time, Search, You, visual hierarchy, copy, interaction depth, state mutation, accessibility proof, and runtime inspectability.

The app was not failing because of isolated polish. It was failing because product objects were not translated into native, user-facing, runtime-backed, inspectable surfaces.

The Linear project `Ambitions Runtime QA Remediation — 2026-06-22 Device Review` now tracks the remediation queue, but Linear is not product canon and issue titles are not sufficient implementation instructions.

Codex must not infer product behavior from vague tickets.

## Decision

Install a repo-backed remediation canon and dossier system:

- full decision register in `docs/truth/2026-06-22-runtime-remediation-decision-register.md`
- global remediation law in `docs/qa/remediation/2026-06-22-codex-remediation-law.md`
- per-bundle Codex dossiers in `docs/qa/remediation/dossiers/`
- remediation index in `docs/qa/remediation/README.md`
- ChatGPT Project Source file in `docs/project-source/CHATGPT_AMBITIONS_PROJECT_SOURCE.md`
- Linear execution bundles linked to matching dossiers

Codex works from the global remediation law plus one execution-bundle dossier at a time. QA leaves remain acceptance criteria.

## Consequences

Positive:

- Codex receives precise product, architecture, runtime, visual, copy, and proof law.
- Linear remains readable and operational.
- Repo canon remains authoritative.
- QA closure requires proof and known-issues register update.
- Future ChatGPT conversations can reference a compact source file instead of rediscovering decisions.

Tradeoffs:

- More upfront documentation.
- More explicit proof burden.
- Some implementation flexibility is intentionally removed.
- Dossier maintenance becomes required when canon changes.

## Non-negotiables

- Runtime paths must be real.
- No fake success.
- No fake placement.
- No dead controls.
- No root internal architecture names.
- No source-only closure.
- Owner acceptance required for Done.
- `docs/qa/KNOWN_ISSUES.md` must update after every execution train.
