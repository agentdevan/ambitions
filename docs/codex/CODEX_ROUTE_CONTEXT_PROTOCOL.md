# Codex Route Context Protocol

Status: Active Codex OS protocol; not product canon.
Date: 2026-05-07

## Purpose

Route Context prevents broad repo rediscovery. Every non-trivial session selects a route, reads the route map, and loads the smallest owner-doc/source set needed to act safely.

## Protocol

1. Read `AGENTS.md` and `docs/codex/CODEX_OS_INDEX.md`.
2. Select one primary route from `.codex/routes/README.md`.
3. Add a second route only for real cross-boundary ownership.
4. Read the route’s owner docs, likely source paths, and required gates.
5. Name forbidden edits before implementation.
6. Use ACX or `rg` to inspect targeted files before broad search.
7. If route and owner docs conflict, trust owner docs/source, record the conflict, and update the route later.

## Route Fields

Each route must define purpose, read first, relevant docs/canon, likely source paths, likely tests, required gates, forbidden edits, evidence requirements, and stale fallback.

## Non-Override Rule

Routes are maps. They do not override product canon, architecture owners, source code, raw logs, human/device proof boundaries, or `docs/codex/BATCH_REGISTRY.md`.
