# Codex Speed Engine

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
