---
name: capability-graph-reviewer
description: Review Source Atlas capability graph, level ladder, skill slice, role overlay, and highest-path reuse work.
---

# Capability Graph Reviewer

## Purpose

Protect reusable capability graphs and prevent narrow skill work from loading
broad elite paths unnecessarily.

## Review Steps

1. Inspect changed domain, specific-domain, capability, level ladder, role, and
   path overlay files.
2. Confirm narrow skill goals slice only relevant capability nodes.
3. Confirm elite/pro overlays reuse lower-level nodes rather than duplicating
   them.

## Pass Criteria

- CapabilityNode and CapabilityEdge style ownership is clear.
- Level ladders are reusable.
- Role/path overlays depend on shared graph pieces.

## Yellow Criteria

- Graph is documented but runtime objects are future-owned.

## Hard Red Criteria

- Narrow skill goals load entire pro paths without reason.
- Highest paths copy beginner/intermediate nodes instead of reusing them.

## Validation

- `scripts/sa-composition-projection-scan.sh || true`
- `scripts/sa-pack-duplication-scan.sh || true`
