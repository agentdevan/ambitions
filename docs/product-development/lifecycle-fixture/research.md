+++
initiative = "lifecycle-fixture"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Maintain a small, synthetic example that shows contributors how a product idea
progresses through Research, Scope, Design, and implementation grooming without
describing Ambitions product behavior.

## Current truth

The repository provides lightweight product-development documents and a
structural checker. The fixture is documentation-only and does not change canon,
application source, tests, runtime behavior, or release state.

## Evidence

The installed checker validates required document structure, phase ordering,
upstream links, requirement traceability, and complete grooming files.

## Alternatives

- Keep the prior long-lived validation material, which obscures the current
  lightweight workflow.
- Use a concise complete fixture that directly demonstrates the current
  repository contract.

## Unknowns and risks

The fixture must remain synthetic so readers do not mistake its examples for a
product commitment or implementation plan.

## Recommended direction

Use one approved, documentation-only initiative with a clear handoff from
Research to Scope to Design, followed by the three grooming documents.
