# Codex Route Context Protocol

Status: Active context-routing protocol.  
Date: 2026-05-07  
Scope: Route files under `.codex/routes/`.

## Purpose

Route files reduce Codex usage by replacing broad repo discovery with small, task-owned read lists.

## Route File Contract

Each route must name:

- purpose
- read first
- relevant source paths
- relevant docs/canon
- likely tests
- required gates
- forbidden edits
- evidence requirements
- fallback if stale

## Selection Rule

Select one route per task. Add a second route only when a task crosses a real boundary, such as UI plus build failure or canon drift plus release claim.

## Staleness Rule

A route is a starting map, not source truth. If it conflicts with `AGENTS.md`, the peak protocol, current batch-train state, or active canon, trust the owner and update the route in a Codex OS maintenance pass.

## Route-First Boot

```bash
python3 scripts/ai/acx.py read .codex/routes/<route>.route.md
```

Then follow the route read list before broad search.
