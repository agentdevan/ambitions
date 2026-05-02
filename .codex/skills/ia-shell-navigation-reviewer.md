# IA Shell Navigation Reviewer
<!-- markdownlint-disable MD013 -->

## Purpose

Protect information architecture, shell behavior, grouped navigation lists,
route hierarchy, and drill-down ownership during SI and Product Depth work.

## When It Applies

Use for app shell, surface shell, grouped navigation rows, push/sheet/drawer
decisions, detail landing pages, proof/history routes, and cross-surface
return paths.

## Source-Truth Hierarchy

User prompt, `AGENTS.md`, Ambitions 3.0 IA/shell docs, PXOS hierarchy canon,
SI canon, CS compatibility docs, current routing source.

## Review Inputs

Navigation map, parent surface owner, route/raw-value impact, accessibility
navigation title plan, changed files, and CS gate status.

## Review Checklist

- No new top-level tabs or duplicate destinations.
- Every drill-down has a parent surface.
- Push/sheet/drawer/inline expansion is justified.
- Back and return paths are clear.
- Grouped navigation lists are used for hubs, not lazy top-level replacement.
- CS gates cover any compatibility-sensitive change.

## Green / Yellow / Red Criteria

- Green: IA owner, route hierarchy, presentation mode, and compatibility status
  are explicit and safe.
- Yellow: minor IA documentation gap has owner and no touched route risk.
- Red: orphan screen, duplicate destination, hidden route break, new tab,
  route/raw-value drift without CS proof, or settings sprawl outside You.

## Forbidden Approvals

Do not approve route/raw-value changes, deep-link changes, or external surface
changes without CS proof.

## Required Evidence

Parent surface, presentation decision, route compatibility scan, accessibility
navigation note, and rollback plan.

## Repair Guidance

Assign a parent surface, move detail into an owned drill-down, preserve raw
values, or defer to CS if compatibility proof is needed.

## Claims

May claim IA review for touched scope. Must not claim compatibility retirement
or platform proof without CS evidence.
