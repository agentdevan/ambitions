# AmbitionsOS Template Catalog

Status: Consolidated AmbitionsOS operating asset catalog
Owner: Codex OS Continuity / Governance Kernel

## Purpose

Keep AmbitionsOS operating assets useful without creating one-file-per-idea sprawl. This catalog owns proposed templates until a future train proves an item is required for execution, evidence, repair, or repeated review.

## When An Item Stays Cataloged

An item stays in this catalog when it is future-only, advisory, referenced by one train but not yet used, or not yet backed by evidence. Cataloged items guide prompts but do not create current implementation obligations.

## When An Item Becomes A Split-Out Asset

Split an item into its own file only when a train manifest names it as required, a batch cannot safely execute without it, a repair needs a dedicated checklist, or repeated evidence would become ambiguous inside the catalog. The split must name owner, source docs, allowed files, forbidden files, validation evidence, Green/Yellow/Red gates, and stop conditions.

## Required Fields

Every cataloged or split-out template must include: required fields, evidence slots, claim-boundary slots, rollback slots.

## Minimum Validation Evidence

At minimum, evidence must include command run, timestamp or log path when available, pass/fail/partial status, scope of proof, what it does not prove, release-claim impact, and related train/batch.

## Relationship To Future Trains

- AOS trains use this catalog for kernel, invariant, privacy, source-truth, model-boundary, and performance checks.
- ME trains use it for extraction, large-file, behavior-preservation, rollback, and architecture-scan checks.
- CS trains use it for route/raw-value/import-export/persistence/external-payload compatibility checks.
- Release Evidence Closure uses it for claim-boundary and evidence-ledger checks.

## No-Sprawl Rules

Prefer one durable catalog entry over a placeholder file. Do not split assets merely to make a prompt look complete. Do not let catalog status imply a train has started or a proof exists. Remove or merge duplicated entries during the next train that actively uses them.

## Current Yellow Advisory

This catalog is intentionally consolidated after the AmbitionsOS future-canon batch. It is operational enough for train prompts, but individual items should split only when a future batch names them and produces evidence.
