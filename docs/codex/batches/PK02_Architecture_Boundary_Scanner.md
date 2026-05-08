# PK02 Architecture Boundary Scanner

<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow
Date: 2026-05-08
Owner train: PK00-PK41 Platform Kernel Train
Next eligible batch: PK03 AppUnitOfWork Foundation

## Goal

Turn the PK01 boundary scaffold into a repeatable scanner before larger module
moves, package splits, or backend/platform extraction.

## Work Completed

- Added `scripts/ai/pk_boundary_scan.py`.
- Scanner checks Domain blocked imports, Persistence UI/platform imports,
  Runtime/Services SwiftUI imports, ExternalSnapshots direct SwiftData context
  risk, and unexpected package products.
- Default mode is non-mutating and non-strict: Yellow findings are reported but
  do not stop the train.
- `--strict` mode is available for future hard-gate use.

## Decision Record

PK02 is tooling-only. It does not move code, edit package/project files, change
app behavior, change persistence/schema, add dependencies, add hosted CI, or
create release/device/accessibility claims.

## Result

Accepted Yellow. The scanner exists and runs. Current repo findings are Yellow
boundary drift evidence that later PK batches can repair or narrow.

## Validation

Minimum validation:

```bash
python3 -m py_compile scripts/ai/pk_boundary_scan.py
python3 scripts/ai/pk_boundary_scan.py
git diff --check
python3 scripts/ai/acx_impact.py <changed files>
python3 scripts/ai/acx_local.py bundle docs
python3 scripts/ai/acx_local.py bundle batch-closeout
python3 scripts/ai/acx_repair.py diagnose
scripts/global-train-next-batch.sh
```

## Non-Claims

No boundary cleanliness, package split safety, module extraction, backend
completion, migration safety, sync readiness, side-effect isolation, privacy
compliance, CI green, release readiness, physical-device proof, public
accessibility conformance, or performance-budget proof is claimed.
