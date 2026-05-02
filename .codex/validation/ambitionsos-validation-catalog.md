# Ambitionsos Validation Catalog

Status: Consolidated AmbitionsOS operating asset catalog

Validation packs catalog. Consolidates requested AmbitionsOS, AOS, maintainability, compatibility, large-file, migration, log preservation, doc dedupe, and human-made validation packs to avoid placeholder sprawl. Each future implementation may split a named pack only when it becomes train-critical.

## Standard Fields For Every Split-Out Asset

- purpose
- required source docs
- checks
- allowed files
- forbidden files
- Green/Yellow/Red gates
- validation commands
- report requirements
- stop conditions

## Split Rule

Create a separate file only when a future train names it as required for execution, evidence, or repair. Until then, this catalog prevents one-file-per-idea sprawl.
