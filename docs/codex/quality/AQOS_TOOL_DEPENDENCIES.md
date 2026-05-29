# AQOS Tool Dependencies

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite
> Dispositions: rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active AQOS dependency policy.
Date: 2026-05-05

## Purpose

AQOS should improve quality without turning the repo into a fragile tool zoo. Dependencies must be minimal, local, reproducible, and justified.

## Default Dependencies

Required baseline tools already expected in the repo environment:

- macOS shell
- Bash
- Git
- grep / sed / awk / find / wc
- Python 3 standard library
- Xcode command-line tools
- xcodebuild
- xcrun simctl
- xcodegen, if already used by the repo

## Optional Tools

Optional only when already available or explicitly installed by a dedicated toolchain batch:

- XcodeBuildMCP for simulator build/run/screenshot automation
- SwiftFormat / SwiftLint if already part of repo workflow
- Periphery or equivalent dead-code tool only if approved by dependency policy
- xcbeautify only if already approved
- ImageMagick or perceptual diff tooling only if dependency policy approves

## Dependency Rules

- Do not add third-party dependencies casually.
- Do not add network services for quality checks.
- Do not add paid tools.
- Do not add binary-only tools.
- Do not add tools that require secrets.
- Prefer shell/Python standard library first.
- Any new dependency requires PFC dependency/supply-chain approval.

## Script Philosophy

AQOS scripts should be:

- non-mutating by default
- advisory by default
- strict when `AQOS_STRICT=1`
- deterministic where possible
- safe on CI and local machines
- understandable to a senior engineer
- documented with expected inputs/outputs

## Screenshot / Simulator Tools

Preferred stack:

1. xcodebuild
2. xcrun simctl
3. XcodeBuildMCP if available
4. manual operator proof checklist if automation unavailable

## Metal / Advanced Rendering Dependencies

Metal does not require external dependencies but does require MEG01 approval before use.

AQOS must not introduce Metal or shader tooling as part of quality infrastructure unless a specific rendering primitive is approved.

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
