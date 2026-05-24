# Supersession Ledger

Status: Active runner input. Replacements must be recorded here before weaker duplicates are retired.

Owner review accepted Yellow boundary for the Today, Capture, Runtime, Proof/Receipt/ReplayTrace, Time, and You owner roots. No retirements were approved in this phase; Champion Merge batches remain the implementation follow-up.

| Concept | Superseded path/type | Canonical owner | Reason for supersession | Useful behavior to rescue | Rescue status | Tests required | Retirement status | Owner review | Date/batch |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Today / Start Here preview references | `Sources/Previews/**` | today_root | Preview-state fixtures should be rescued, not allowed to drift into a parallel spine. | Preserve stronger visual states and accessibility fixtures. | owner_reviewed_yellow_boundary | Today UI tests and accessibility fixtures | keep_active_reference | accepted_yellow_boundary | AMB-CHAMPION-MERGE-OWNER-REVIEW-01 |
| Time / Plan compatibility | `Native/Ambitions/Features/Plan` | time_root | Plan is compatibility-only; Time is active IA. | Preserve any stronger availability or planning details after review. | owner_reviewed_yellow_boundary | Time surface and compatibility tests | keep_active_compatibility | accepted_yellow_boundary | AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01 |
