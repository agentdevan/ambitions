# Antigravity Manifest Rerun Start Here

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active Antigravity entry point  
Date: 2026-05-15  
Authority: Supporting entry point for `docs/codex/SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE.md`

## Stop condition

Do not continue to FCP27.

The current required work is to rerun these ranges correctly against their manifests:

- SA28-SA32
- LDI15-LDI22
- AOS24-AOS30

Existing commits are retained as supporting evidence. Do not revert by default. Do not treat prior Green closeouts as sufficient unless the manifest acceptance criteria are satisfied.

## First file to read

```text
docs/codex/SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE.md
```

Then read:

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
```

## Frontend authority rule

If any rerun batch touches frontend, UI, SwiftUI surfaces, visual QA, rendered proof, preview fixtures, navigation, copy, accessibility labels, widgets, Live Activities, App Intents presentation, screenshots, or frontend-facing reports, read and follow:

```text
frontend/README.md
frontend/installed-canon.md
frontend/intended-canon.md
frontend/visual-encyclopedia/README.md
frontend/visual-encyclopedia/ENCYCLOPEDIA_TO_FRONTEND_OS.md
frontend/visual-encyclopedia/ACTIVE_IA_AND_SURFACE_MAP.md
```

Active IA is exactly:

```text
Today / Goals / Capture / Time / You
```

Plan is not a top-level destination.

## Required branch

Use a local branch:

```bash
git checkout main
git pull
git checkout -b ai/manifest-rerun-sa28-ldi15-aos24
```

Do not perform this rerun directly on `main`.

## Required closeout file

Create and maintain:

```text
docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md
```

Every affected batch must list:

- manifest requirement
- prior evidence retained
- whether prior work was valid, partial, wrong-scope, build-risk, or stale-state evidence
- files changed in rerun
- validation commands and results
- frontend encyclopedia inheritance status when frontend was touched
- final status: Green, Accepted Yellow with owner, Blocked, or Needs Repair

## Required validation floor

Run or explicitly record why unavailable:

```bash
git status --short
git diff --check
make batch-self-check
python3 scripts/ambitions-source-atlas-title-check.py --strict
scripts/codex-forbidden-claim-scan.sh <changed-files> || true
```

For Swift changes:

```bash
xcodegen generate
xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO
```

## Hard Red

Stop if:

- FCP27 is started before rerun closeout
- a batch is marked Green without satisfying its manifest
- frontend-touching work ignores the encyclopedia
- generic TailGate files are substituted for manifest work
- Swift compile risk is ignored
- release, device, TestFlight, App Store, public accessibility, privacy/legal, or global train completion is claimed without proof

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
