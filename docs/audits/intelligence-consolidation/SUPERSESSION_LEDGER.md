# Supersession Ledger

Status: Active runner input. Replacements must be recorded here before weaker duplicates are retired.

Owner review accepted Yellow boundary for the Today, Capture, Runtime, Proof/Receipt/ReplayTrace, Time, and You owner roots. Today champion merge work has now landed on the canonical `today_root`; the ledger keeps the legacy hero/rail names visible as retired-active labels rather than pretending they still own the surface.

| Concept | Superseded path/type | Canonical owner | Reason for supersession | Useful behavior to rescue | Rescue status | Tests required | Retirement status | Owner review | Date/batch |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Today / Start Here legacy hero and rail labels | `Native/Ambitions/Features/Today/TodayDayRailPanels.swift; Native/Ambitions/Features/Today/TodayHeroStepSignaturePrimitives.swift` | today_root | The live Start Here surface now exposes the rescued source, reason, receipt, proof, and replay/inspection labels; the old helper file is retired instead of renamed into a new implementation type. | Preserve the canonical Today labels and accessibility copy in the live surface. | merged_to_today_root | Today UI tests and accessibility fixtures | retired_as_active_labels | merged | AMB-CHAMPION-MERGE-TODAY-01 |
| Today / Start Here preview references | `Sources/Previews/**` | today_root | Preview-state fixtures should be rescued, not allowed to drift into a parallel spine. | Preserve stronger visual states and accessibility fixtures. | owner_reviewed_yellow_boundary | Today UI tests and accessibility fixtures | keep_active_reference | accepted_yellow_boundary | AMB-CHAMPION-MERGE-OWNER-REVIEW-01 |
| Time / Plan compatibility | `Native/Ambitions/Features/Plan` | time_root | Plan is compatibility-only; Time is active IA. | Preserve any stronger availability or planning details after review. | owner_reviewed_yellow_boundary | Time surface and compatibility tests | keep_active_compatibility | accepted_yellow_boundary | AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01 |
