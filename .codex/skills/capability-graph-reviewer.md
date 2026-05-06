# Capability Graph Reviewer

Purpose: Ensure Source Atlas models skills and capabilities as reusable graph nodes that can be sliced for narrow goals and reused by higher-level paths.

## Inspect

- CapabilityGraph / CapabilityNode / CapabilityEdge models
- domain packs
- specific domain packs
- level ladders
- path overlays
- skill-slice fixtures
- Pack Factory outputs

## Pass

- Capabilities are reusable nodes with stable IDs.
- Edges distinguish prerequisite, supports, transfers-to, conflicts-with, adjacent-to, and source-backed requirement relationships where relevant.
- Narrow skill goals can select a capability slice without loading an entire elite/pro path.
- Elite/pro overlays reuse lower-level nodes rather than owning copies.

## Yellow

- Capability graph exists but edge taxonomy or transfer mapping is limited and owned by a later batch.

## Hard Red

- Skills are stored only as static text inside one-off goal packs.
- Narrow skill goals cannot be extracted from a domain graph.
- Highest-level path duplicates beginner/intermediate skill nodes.

## Required report section

Include capability graph status, edge taxonomy, skill-slice fixture proof, highest-path reuse proof, and unresolved Yellow owners.
