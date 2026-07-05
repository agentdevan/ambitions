# AMB-1798 Domain Classification Leaf

Status: Linear source remediation proof packet
Date: 2026-07-05T07:58:31Z
Baseline main SHA: `75b504097a936b25c3f2037aeb1d9f5e8b754749`
Project: Architecture Simplification + Flagship Readiness Remediation (`59c3917f-f662-4ca3-b412-b532613f3a7a`)
Issue: `AMB-1798` Domain Classification Leaf - Split AmbitionsOS model families
Parent: `AMB-1676` Parent Feature - Domain object classification

## Scope

This packet records the first bounded AMB-1798 cleanup against the current
`docs/audits/domain-object-classification.{json,md}` inventory.

The selected target was the isolated obsolete vertical-slice proof family:

- `Native/Ambitions/Core/Domain/AmbitionsOSVerticalSliceProofModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSVerticalSliceProofModelsTests.swift`

The family had no references outside its own production file and test file.
The leaf therefore retired the obsolete bucket pair instead of splitting or
renaming it into new `+02`, `+03`, or broad `Models.swift` files.

## Live Inputs Inspected

- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `.agents/skills/README.md`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- `.agents/skills/ambitions-runtime-contract-engineering/SKILL.md`
- `docs/audits/domain-object-classification.json`
- `docs/audits/domain-object-classification.md`
- Live Linear state for `AMB-1798`

## Source Changes

Deleted obsolete Domain family:

- `Native/Ambitions/Core/Domain/AmbitionsOSVerticalSliceProofModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSVerticalSliceProofModelsTests.swift`

Regenerated classifier artifacts:

- `docs/audits/domain-object-classification.json`
- `docs/audits/domain-object-classification.md`

Tooling hardening required for current local validation:

- `scripts/ambitions-xcode-build-for-testing.sh` now retries retryable simulator
  preflight failures with `--repair --kill-active-xcode`.
- `scripts/ambitions-bounded-xcodebuild.sh` now quarantines the exact local
  self-hosted Actions-runner Ambitions `xcodebuild` process family while a local
  bounded Xcode validation is running. This targets Runner.Worker ancestry,
  `artifacts/strict-build-launch`, and paths under
  `actions-runner/_work/_temp/ambitions-local-runtime-proof` or
  `actions-runner/_work/ambitions/ambitions`, while excluding the current
  wrapper's own process tree.

## Classifier Delta

After regeneration:

- Total Core/Domain Swift files: `217` (down from `218`).
- Obsolete bucket debt files: `40` (down from `41`).
- `obsolete` category count: `40` (down from `41`).
- `AmbitionsOSVerticalSliceProofModels.swift` is absent from the generated
  classifier inventory.

Reference scan:

- `rg -n "AmbitionsOSVerticalSliceProof|ambitionsOSVerticalSliceProof" -S Native Sources Packages AppUI Package.swift project.yml`
  returned no remaining references.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched:
  - `Core/Domain` obsolete bucket cleanup.
  - `Native/AmbitionsTests/Domain` obsolete test pair cleanup.
  - local validation tooling under `scripts/`.
- Files moved or created: no source files moved; one proof packet created.
- Old/non-canonical paths removed:
  - `Native/Ambitions/Core/Domain/AmbitionsOSVerticalSliceProofModels.swift`
  - `Native/AmbitionsTests/Domain/AmbitionsOSVerticalSliceProofModelsTests.swift`
- Compatibility shims left behind: none.
- New `+02`, `+03`, or `+04` split files added: none.
- New broad `Models.swift` files added: none.
- New runtime, persistence, projection, receipt, or mutation authority added:
  none.
- No "equivalent" folder/path interpretation was used.

Remaining Yellow architecture debt:

- AMB-1676 is not Green. The classifier still reports:
  - `40` obsolete bucket files.
  - `77` mechanical suffix debt files.
  - `8` UI model debt files still in Domain.
  - `97` low-confidence default classifications.

Next repair train:

- Continue AMB-1676 via the next bounded Domain classification leaf, selecting
  another concrete `AmbitionsOS*` family or a focused canonical owner migration
  from the regenerated inventory.

## Validation

The `.codex` result and summary paths below are local working evidence for
build/test execution only. They are not visual acceptance, accessibility
acceptance, release acceptance, or rendered-product acceptance artifacts.

Completed before closeout:

- `python3 scripts/ambitions-domain-object-classification.py --self-test`
- `python3 scripts/ambitions-domain-object-classification.py --write`
- `bash -n scripts/ambitions-xcodebuildmcp-stdio.sh`
- `bash -n scripts/ambitions-xcode-build-for-testing.sh`
- `bash -n scripts/ambitions-bounded-xcodebuild.sh`
- `scripts/ambitions-xcode-sim-health.sh --json --repair --kill-active-xcode --timeout 30s`
  passed with selected simulator `iPhone 17 Pro Max`
  `0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`, one booted simulator, and zero active
  Xcode processes after repair.
- `scripts/ambitions-xcode-build-for-testing.sh --batch AMB-1798-domain-classification --scheme Ambitions --timeout 60m --kill-after 60s`
  passed.
  - Summary: `.codex/xcode-summaries/AMB-1798-domain-classification/20260705T073921Z-bft-44929-6554/build-for-testing-summary.json`
  - Result bundle: `.codex/xcode-results/AMB-1798-domain-classification/20260705T073921Z-bft-44929-6554/build-for-testing.xcresult`
  - Duration: `859.073` seconds.
- `scripts/ambitions-xcode-test-focused.sh --batch AMB-1798-domain-classification --test AmbitionsTests/CoreDomainCanonicalOwnershipTests --scheme AmbitionsUnitTests --timeout 20m --kill-after 60s --without-building --skip-prebuild`
  passed.
  - Summary: `.codex/xcode-summaries/AMB-1798-domain-classification/20260705T075353Z-AmbitionsTests-CoreDomainCanonicalOwnershipTests-53021-14242/focused-test-summary.json`
  - Result bundle: `.codex/xcode-results/AMB-1798-domain-classification/20260705T075353Z-AmbitionsTests-CoreDomainCanonicalOwnershipTests-53021-14242/focused-test.xcresult`
  - Executed tests: `15`
  - Duration: `178.701` seconds.
- `git diff --check`
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py`: valid, zero
  invalid Accepted Yellow issues.
- `python3 scripts/ambitions-remediation-governance-check.py`: Green
  remediation governance guard passed.
- `python3 scripts/ambitions-quality-gate.py`: Green all strict quality gates
  passed.

Observed warnings during Xcode compilation were pre-existing test warnings and
were not introduced by this leaf.

## Tooling Note

The first AMB-1798 build-for-testing attempt timed out after 30 minutes while
compiling. During investigation, a self-hosted local Actions-runner job under
`/Users/devan/actions-runner/_work/_temp/ambitions-local-runtime-proof...`
reappeared and contended for CoreSimulator/Xcode resources. After the final push,
an additional runner-side `artifacts/strict-build-launch` Xcode process appeared;
the quarantine matcher was extended to catch that family by Runner.Worker ancestry
without killing the current wrapper's own child process. The final validation used
the hardened wrapper path above and completed successfully.

This packet does not claim the already-running Codex MCP host namespace was
hot-reloaded. The XcodeBuildMCP wrapper repair is recorded in the AMB-1757
packet; the current host may still need a Codex app-server reload before
`mcp__xcodebuildmcp.*` calls use the repaired transport in-process.

## Non-Claims

- No AMB-1676 parent Green is claimed.
- No full Domain cleanup is claimed.
- No runtime behavior change is claimed from deleting the isolated obsolete
  vertical-slice proof family.
- No Visual Green, accessibility conformance, physical device proof,
  privacy/legal approval, TestFlight/App Store readiness, R2 readiness, or
  release readiness is claimed.

## Rollback

If this leaf must be reverted, restore the deleted production/test pair, rerun
`python3 scripts/ambitions-domain-object-classification.py --write`, and revert
this proof packet plus the local Xcode preflight hardening if it is no longer
wanted.
