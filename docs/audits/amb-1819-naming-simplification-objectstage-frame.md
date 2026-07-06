# AMB-1819 Naming Simplification ObjectStage Frame

Status: Implemented Yellow / one layout-primitive owner collapsed without
runtime testing

Date: 2026-07-06

Baseline SHA: `059a062c5ab105345d6a6d0cd8a54274d96a8d38`

Linear state before source work: `Needs Repair`, then `In Progress`

## Scope

AMB-1819 is a bounded child of AMB-1698. The selected source-present owner name
was the ObjectStage layout primitive family because:

- `CommandSpine`, `TransactionKernel`, `ProjectionEngine`, `TrustSystem`,
  `SideEffectSystem`, `SearchRecall`, and `SyncContinuity` no longer had live
  production/test owner directories in the active source tree.
- `PrivateLifeRuntimeKernel` remains a broad runtime subtree and is not safe to
  collapse in this leaf.
- `ObjectStageSurface`, `ObjectStageGlance`, `ObjectStageHero`, and the unused
  `FlagshipObjectStage*` package primitives were active source-present layout
  names, while the Final Architecture Tree already names the canonical owner as
  `DesignSystem/StagePrimitives/ProductObjectFrame.swift`.

This packet covers only that layout primitive collapse. It does not rename all
`ObjectStagePrimitiveContract` source/test contracts or screenshot identifiers.
Those names remain out of scope because they are product-object proof contracts,
not the selected package layout primitive owner.

## Source Changes

Canonical owner used:

- `Native/Ambitions/DesignSystem/StagePrimitives/ProductObjectFrame.swift`

Old package source removed:

- `Sources/Components/ObjectStageSurfaces.swift`
- `Sources/Components/FlagshipObjectStagePrimitives.swift`

The canonical `ProductObjectFrame` now owns the prior surface/glance/hero
rendering variants through `ProductObjectFrameRole`:

- `.rootPrimaryObject` replaces `ObjectStageSurface`
- `.detailObject` replaces `ObjectStageGlance`
- `.overlayObject` replaces `ObjectStageHero`

Call sites updated under:

- `Native/Ambitions/DesignSystem/ProductObjects/`
- `Native/Ambitions/Surfaces/You/`

Active provenance paths updated:

- `docs/design/provenance/vsp-provenance.json`
- `docs/qa/evidence/2026-06-29-vsp-code-connect-readiness/manifest.json`

## Validation

Validation status: static guards passed / tests not run / post-commit XcodeGen
drift check clean.

Commands completed:

- `rg -n "ObjectStageSurfaces|FlagshipObjectStagePrimitives|ObjectStageSurface|ObjectStageGlance|ObjectStageHero|FlagshipObjectStage|FlagshipStepToken|FlagshipInspectionDisclosure|TrustSeamDisclosure|NativeGroupedControlSurface|InstrumentField" Native/Ambitions Native/AmbitionsTests Sources AppUI docs/design/provenance/vsp-provenance.json docs/qa/evidence/2026-06-29-vsp-code-connect-readiness/manifest.json docs/truth docs/qa project.yml Package.swift -S`
  - returned no active hits before this packet was added.
- `jq -e . docs/design/provenance/vsp-provenance.json`
  - passed.
- `jq -e . docs/qa/evidence/2026-06-29-vsp-code-connect-readiness/manifest.json`
  - passed.
- `git diff --check`
  - passed.
- `jq -e . docs/audits/amb-1819-naming-simplification-objectstage-frame.json`
  - passed.
- `npx markdownlint-cli2 --no-globs docs/audits/amb-1819-naming-simplification-objectstage-frame.md`
  - passed with `0` errors.
- `python3 scripts/ambitions-unsupported-claim-scan.py ...`
  - passed.
- `scripts/release-claim-safety-scan.sh ...`
  - passed.
- `xcodegen generate --spec project.yml`
  - passed and wrote the generated project.
- `python3 scripts/ambitions-remediation-governance-check.py`
  - passed with `changed_paths=21`, `suffixSplitFiles=224`,
    `blockedSuffixSplitFiles=182`, `architectureNounFiles=357`, and
    `overHardLineCapFiles=0`.
- `python3 scripts/ambitions-architecture-inventory.py`
  - passed with final-tree parity.
- `python3 scripts/ambitions-vocabulary-drift-scan.py`
  - passed.
- `python3 scripts/ambitions-truth-path-vocabulary-audit.py`
  - passed.
- `python3 scripts/ambitions-green-standard-audit.py`
  - passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py`
  - passed.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py`
  - passed.
- `python3 scripts/ambitions-screenshot-artifact-audit.py`
  - passed as a static guard; no screenshot artifact was produced.
- `python3 scripts/ambitions-device-proof-required.py`
  - passed as a static guard; no device proof was produced.
- `scripts/no-unsupported-ai-claim-scan.sh ...`
  - completed with advisory hits reviewed as context and non-claims.
- `scripts/privacy-boundary-scan.sh ...`
  - completed with advisory hits reviewed as context and non-claims.
- `scripts/ambitions-xcodegen-needed.sh`
  - pre-commit output was `XCODEGEN_NEEDED=1` because tracked Swift source
    files were still dirty; post-commit rerun returned `XCODEGEN_NEEDED=0`
    with reason `project build inputs unchanged`.

Commands not run by current user authorization:

- focused owner XCTest
- full XCTest
- build
- simulator
- screenshot capture
- physical device
- performance
- signed archive
- App Store Connect validation

## Proof Ceiling

Allowed claims:

- AMB-1819 collapsed one selected ObjectStage layout primitive owner into the
  canonical `ProductObjectFrame` owner.
- Active source/provenance references to the selected old package layout
  primitive symbols were removed.
- No new runtime authority was added.

Forbidden claims:

- full AMB-1698 naming campaign Green
- `PrivateLifeRuntimeKernel` collapse
- full ObjectStage vocabulary elimination
- focused tests passed
- build validation passed
- simulator validation passed
- device proof exists
- release proof exists
- TestFlight readiness
- App Store readiness
- Release Green

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `DesignSystem/StagePrimitives`,
  `DesignSystem/ProductObjects`, `Surfaces/You`, provenance docs.
- Files moved or created: audit packet only.
- Old/non-canonical paths removed:
  `Sources/Components/ObjectStageSurfaces.swift` and
  `Sources/Components/FlagshipObjectStagePrimitives.swift`.
- Compatibility shims left behind: none for the deleted package primitives.
- Yellow architecture debt remains: full AMB-1698 naming simplification,
  `PrivateLifeRuntimeKernel` collapse, remaining `ObjectStagePrimitiveContract`
  contract names, and runtime/device/release proof.
- Next repair train if debt remains: continue AMB-1698 with either a bounded
  `PrivateLifeRuntimeKernel` collapse plan or a separate
  `ObjectStagePrimitiveContract` contract rename leaf.
- Equivalent folder/path interpretation used: no.
