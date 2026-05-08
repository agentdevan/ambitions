# Codex Speed Engine

Status: Active Codex OS speed protocol.  
Date: 2026-05-08  
Scope: ACX bundles, changed-file impact routing, proof cache, and closeout acceleration.

## Purpose

The speed engine prevents Codex from manually deciding and rerunning the same preflight checks. It converts changed paths into route, bundle, gate, and proof expectations.

## Components

- `.codex/manifests/acx-bundles.yml` — reusable ACX Local profile bundles.
- `.codex/manifests/changed-file-impact-map.yml` — maps changed paths to routes/bundles/gates.
- `scripts/ai/acx_impact.py` — non-mutating changed-file impact planner.
- `scripts/ai/acx_closeout.py` — compact closeout packet generator.
- `scripts/ai/acx_sanitized_evidence.py` — sanitized proof-cache packet generator.
- `.codex/state/proof-cache.json` — local-only proof cache written by ACX Local and ignored by git.

## Standard Speed Flow

```bash
python3 scripts/ai/acx_local.py bundle quick
python3 scripts/ai/acx_impact.py <changed files>
python3 scripts/ai/acx_local.py bundle <suggested bundle>
python3 scripts/ai/acx_closeout.py
```

## Bundles

Use:

- `quick` for repo status and diff size.
- `docs` for docs/Codex OS passes.
- `codex-os` for scripts and Codex tooling.
- `ui` for UI-affecting preflight.
- `build-triage` for build/test documentation and project validation discovery.
- `batch-closeout` for global batch closeout.
- `repair-diagnosis` before repair proposal.

## Proof Cache

ACX Local writes a local proof-cache entry for executed profiles:

- timestamp
- commit
- profile
- exit code
- raw log path
- raw log SHA256

The proof cache is ignored by git. Generate a sanitized packet only when a committed handoff needs durable proof without raw logs.

## Claims

Speed engine output can reduce repeated validation work. It does not prove build/test/device/release/accessibility/legal/privacy readiness unless the relevant raw logs and owner evidence exist.
