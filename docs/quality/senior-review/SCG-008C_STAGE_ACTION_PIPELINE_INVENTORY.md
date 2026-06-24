# SCG-008C Stage Action Pipeline Inventory

Status: Source contract installed for AMB-1301 / SCG-008C only.

Baseline: `28b660bbc937ef32d517aa88726e64df395b4bd8`

## Taxonomy

`shell_navigation_overlay` covers shell route changes, overlays, Search / Memory Lens presentation, opening Capture, opening Goal Detail, opening Time, and posture navigation. These actions may record continuity route context, but they must not claim runtime mutation, mutation proof, or mutation undo.

`product_runtime` covers actions that attempt to change local product state: Capture save and Today Step actions in this train. These actions must expose command validation, runtime mutation or blocked non-mutation, visible mutation or blocked non-mutation, proof/receipt state, accessibility announcement state, and fallback/undo state.

## Pipeline Contract

The contract source is `Native/Ambitions/Projection/Commands/StageActionPipelineContract.swift`.

Required fields:

- `commandValidation`
- `runtimeMutation`
- `shellRouteChange`
- `visibleMutation`
- `proofReceipt`
- `accessibilityAnnouncement`
- `fallbackUndo`
- `scopedFlowIDs`
- `knownIssueIDs`

Shell-only traces require `runtimeMutation`, `visibleMutation`, and `proofReceipt` to be `not_applicable`.

Product/runtime traces require a command kind and must not complete as a shell-only route change. If proof or receipt is unavailable at the boundary, the trace uses `unavailable` instead of claiming mutation proof.

## Touched Action Inventory

| Action | Taxonomy | Flow IDs | Pipeline proof state |
|---|---|---|---|
| Shell quick Capture save | `product_runtime` | `SCG006-F03` | Valid save proves validation, local Capture creation, visible Capture composer handoff, accessibility/fallback trace; typed MutationProof/MutationReceipt remains `unavailable` at the shell router boundary. |
| Shell quick Capture empty text | `product_runtime` | `SCG006-F03` | Invalid save is blocked before Capture creation and returns fallback trace. |
| External complete Step | `product_runtime` | `SCG006-F07`, `SCG006-F08`, `SCG006-F09`, `SCG006-F14` | Valid target proves runtime executor path; Today command handler source/test path records command execution and event-ledger proof where repository-backed. |
| External missing-target Step | `product_runtime` | `SCG006-F07`, `SCG006-F08`, `SCG006-F09`, `SCG006-F14` | Missing target is blocked before Today mutation handler and records blocked command execution. |
| Open Capture / Search / Memory Lens / Goal route / Time route | `shell_navigation_overlay` | `SCG006-F05`, `SCG006-F10`, `SCG006-F11`, `SCG006-F12`, `SCG006-F13` | Route or overlay is visible shell state only; no runtime mutation/proof/undo claim. |

## Known-Issue Mapping

Rows referenced by pipeline traces only; no row is marked closed by SCG-008C.

- Capture handoff rows: `AMB-ISSUE-0003`, `AMB-ISSUE-0008`, `AMB-ISSUE-0012`, `AMB-ISSUE-1101`-`AMB-ISSUE-1107`
- Today action rows: `AMB-ISSUE-0004`, `AMB-ISSUE-0005`, `AMB-ISSUE-1001`-`AMB-ISSUE-1007`
- Time handoff rows: `AMB-ISSUE-0009`, `AMB-ISSUE-0501`-`AMB-ISSUE-0507`, `AMB-ISSUE-0913`, `AMB-ISSUE-1401`-`AMB-ISSUE-1404`
- Search / inspection handoff rows: `AMB-ISSUE-0701`, `AMB-ISSUE-1601`-`AMB-ISSUE-1605`
- Final proof / accessibility rows: `AMB-ISSUE-0014`, `AMB-ISSUE-0807`, `AMB-ISSUE-1801`, `AMB-ISSUE-1802`

## Status Ceiling

Source Green is claimable only for the touched Stage action pipeline contracts if validation passes. Runtime Green is limited to tested command-validation and non-bypass behavior for touched product/runtime actions. Visual Green, Release Green, senior-readiness, and app release-ready are not claimed.
