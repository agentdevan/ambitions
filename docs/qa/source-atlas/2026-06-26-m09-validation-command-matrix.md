# Source Atlas M09 Validation Command Matrix

Status: canonical M09 local validation matrix.
Train: Source Atlas Implementation Train 05, M09.
Issues: AMB-1364 through AMB-1369.

This matrix records real commands or explicit not-available reasons. It is not release proof, R2 production proof, account readiness proof, known-issue closure, parent-feature closure, or Source Atlas project closeout.

Canonical machine-readable matrix: `docs/qa/source-atlas/2026-06-26-m09-validation-command-matrix.json`

## Required Commands

| Area | Command | Availability | Proof expectation |
|---|---|---|---|
| Patch integrity | `git diff --check` | Available | Whitespace and patch integrity check. |
| Local PR review | `bash scripts/ci/ambitions-pr-review-local.sh --continue` | Available | Local PR review stack output. |
| Green standard | `python3 scripts/ambitions-green-standard-audit.py` | Available | Green-standard source audit output. |
| Boundary | `python3 scripts/source-atlas-boundary-audit.py` | Available | Source Atlas public/reference boundary audit output. |
| No-private-egress | `python3 scripts/source-atlas-no-private-graph-egress-audit.py` | Available | No-private-graph egress audit output. |
| Foundry | `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests` | Available | Foundry and Source Atlas Python test output. |
| Schema | `python3 tools/source-atlas/source-atlas-foundry.py r2-contracts --output-root tools/source-atlas/foundry/contracts --prefix source-atlas/v1` | Available | Schema and R2 object-layout contract generation result. |
| Cache | `scripts/ambitions-xcode-test-focused.sh --batch SOURCE_ATLAS_M09_FOCUSED --only-testing AmbitionsTests/SourceAtlasPublicArtifactPrivacyBoundaryTests --timeout 15m --kill-after 60s` | Available | Focused cache/public artifact privacy boundary native test result. |
| Runtime | `scripts/ambitions-xcode-test-focused.sh --batch SOURCE_ATLAS_M09_FOCUSED --only-testing AmbitionsTests/SourceAtlasNoPrivateGraphEgressAuditTests --timeout 15m --kill-after 60s` | Available | Focused runtime no-private-graph egress native test result. |
| Inspection UI | `scripts/ambitions-xcode-test-focused.sh --batch SOURCE_ATLAS_M09_FOCUSED --only-testing AmbitionsTests/SourceInspectionPresentationTests --timeout 15m --kill-after 60s` | Available | Focused Source inspection presentation native test result. |
| Accessibility | `scripts/ambitions-xcode-test-focused.sh --batch SOURCE_ATLAS_M09_FOCUSED --only-testing AmbitionsTests/SourceInspectionAccessibilityProofTests --timeout 15m --kill-after 60s` | Available | Focused Source inspection accessibility contract test result. |
| Xcode build-for-testing | `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard` | Available | Xcode build-for-testing summary. |
| M09 validation matrix | `python3 tools/source-atlas/source-atlas-m09.py validation-matrix --output output/source-atlas/m09/validation-command-matrix-result.json` | Available | Machine validation of this command matrix. |
| M09 golden benchmarks | `python3 tools/source-atlas/source-atlas-m09.py golden-benchmarks --output output/source-atlas/m09/golden-benchmark-result.json` | Available | 17-scenario benchmark contract result. |
| M09 source-state repair | `python3 tools/source-atlas/source-atlas-m09.py source-state-repair --output output/source-atlas/m09/source-state-repair-result.json` | Available | Repair fixture result for unsafe source states. |
| M09 known issue router | `python3 tools/source-atlas/source-atlas-m09.py known-issue-router --output output/source-atlas/m09/known-issue-router-result.json` | Available | Known-issue routing result; no known issues closed. |
| M09 evidence pack | `python3 tools/source-atlas/source-atlas-m09.py evidence-pack --output-root output/source-atlas/m09` | Available | Repeatable evidence pack JSON and Markdown with non-claims. |
| Production R2 upload | None | Not available | Production R2 upload is explicitly out of scope for M09 and must not be run or claimed. |

## Non-Claims

- No release readiness is claimed.
- No TestFlight or App Store readiness is claimed.
- No production R2 upload is run or claimed.
- No account readiness is claimed.
- No known issue is closed.
- No parent feature, Source Atlas project, or M10 closeout is claimed.
