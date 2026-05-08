# PK01 Package/Module Boundary Scaffold

<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow
Date: 2026-05-08
Owner train: PK00-PK41 Platform Kernel Train
Next eligible batch: PK02 Architecture Boundary Scanner

## Goal

Name package/module boundaries before extraction or project/package mutation.

## Work Completed

- Added `docs/codex/platform-kernel-module-boundary-scaffold.md`.
- Mapped current `Package.swift` and `project.yml` build shape.
- Named future Domain, Persistence, Runtime, Feature Engines, External
  Surfaces, and App Shell boundaries.
- Defined dependency direction and forbidden preconditions for later PK package
  moves.
- Defined PK02 scanner requirements.

## Decision Record

PK01 is docs-only. It intentionally does not edit `Package.swift`,
`project.yml`, production Swift, tests, targets, schemes, app extensions,
entitlements, signing, resources, or generated project files.

## Result

Accepted Yellow. The scaffold exists and is safe to use as source truth for
PK02, but package/module safety is not Green until PK02 adds scanner coverage
and later PK38-PK41 move code with focused build/test proof.

## Validation

Minimum validation:

```bash
git diff --check
python3 scripts/ai/acx_impact.py <changed files>
python3 scripts/ai/acx_local.py bundle docs
python3 scripts/ai/acx_local.py bundle batch-closeout
python3 scripts/ai/acx_repair.py diagnose
scripts/global-train-next-batch.sh
```

## Non-Claims

No production code change, package split, build-system refactor, module
extraction, backend completion, migration safety, sync readiness,
side-effect isolation, privacy compliance, CI green, release readiness,
physical-device proof, public accessibility conformance, or performance-budget
proof is claimed.
