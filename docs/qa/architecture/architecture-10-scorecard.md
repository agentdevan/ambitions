# Ambitions Architecture 10/10 Earned-Score Baseline

**Status:** Red baseline, captured on `main` at `b123ea6f569ecfa61f354a22251c31382b07f019` on 2026-07-09.

This ledger freezes the starting point for the owner-approved architecture modernization program. Scores are working estimates, not proof. A dimension can become Green only when its score is 10, it links current evidence, and every mandatory gate passes on the same commit. The fail-closed machine authority is `architecture-10-scorecard.json` and is checked by `scripts/ambitions-architecture-10-scorecard-check.py`.

Mandatory gates are validator-owned, not scorecard-authored. A future Green row must match the scorer's exact gate set and link one repo-relative JSON artifact per gate through `gateEvidence`. Each artifact must contain the exact gate name, `status: pass`, and the scored commit SHA. Missing, malformed, unlinked, nonexistent, or commit-mismatched gate evidence fails closed.

## Working scores

| Dimension | Advisory score | Status | Current ceiling |
| --- | ---: | --- | --- |
| Overall architecture | 4/10 | Red | Canonical folders exist, but intended target boundaries and single mutation authority are not proven. |
| Runtime foundations | 4.5/10 | Red | Prior runtime evidence exists, but the current audit has three blockers and comprehensive restart/fault proof is absent. |
| Compile-time modularity | 2/10 | Red | The package exposes only DesignSystem and WidgetUI; most app code remains one compile boundary. |
| Dependency discipline | 3/10 | Red | App-only live composition and prohibited dependency patterns are not yet proven. |
| Proof/test integrity | 4/10 | Red | Current strict quality validation fails and critical real-store/restart lane integrity is not established. |

## Current module graph

`current-module-graph.json` records the XcodeGen and Swift package graph. The current app target compiles most of `Native/Ambitions`, and widget/share targets cherry-pick selected application source. This is baseline evidence, not approval of that ownership.

The intended target graph remains the program contract. Task 1 does not create package boundaries or claim the graph is acyclic in its intended form.

## Validator baseline

| Validator | Result |
| --- | --- |
| Remediation governance | Pass: no findings in the changed scope. |
| Architecture inventory | Fail: parser still targets an obsolete truth heading. |
| Strict quality gate | Fail: action proof, design token, inventory, language, and hosted-AI-boundary findings remain. |
| LocalRuntimeProof audit | Red: architecture inventory plus two side-effect commit-receipt blockers. |

Structural scorecard validation may pass while these product/runtime validators remain Red. That distinction is intentional: the scorer verifies honest shape and fail-closed evidence requirements; it does not convert a failing gate into Green.

## Proof ceiling

Allowed claim: the Task 1 baseline is structurally recorded and mechanically rejects prose-only Green.

Forbidden claims include architecture 10/10, comprehensive command-only mutation, complete restart/fault proof, compiler-enforced canonical ownership, physical-device behavior, manual VoiceOver quality, independent Visual Green, TestFlight readiness, App Store readiness, and Release Green.

Physical-device execution is foregone for this architecture program by owner direction. That changes the program validation plan; it does not manufacture device or release proof.

## Mission and ownership relationship

This infrastructure-only ledger does not change product behavior. It protects the `Proof` portion of `Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning` by preventing architecture status from outrunning executable evidence.

Final Architecture Tree inspected: yes. Canonical source owners touched: none. Non-canonical source owners touched: none. Source files moved or created: none. Compatibility shims: none. No equivalent-folder interpretation was used.
