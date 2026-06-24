# SCG-007 Repair Train Plan

Issue: `AMB-1290 / SCG-007`
Status: `Green - plan generated only`

SCG-007 converts SCG-001 through SCG-006 evidence into a dependency-ordered repair train plan. No production code was repaired, no production behavior changed, SCG-007A was not started, SCG-008 was not started, no flow/file was marked Green, and senior-readiness is not claimed.

## Required Answer

`SCG-007A is required before SCG-008.` SCG-007A must verify SCG findings are synced/deduped, resolve or explicitly accept the review-ledger schema/staleness gaps, and reconcile known issues before production repair begins.

## Coverage

- scg_003_unknown_ownership_layer_classifications: `117`
- scg_003_yellow_inventory_risks: `299`
- scg_004_real_yellow_findings: `13`
- scg_004_fixture_only_findings: `16`
- scg_005_yellow_file_review_entries: `361`
- scg_005_unknown_entries: `117`
- scg_005_b3_findings: `602`
- scg_005_b4_findings: `6`
- scg_005_missing_schema: `['docs/quality/senior-review/schemas/review_ledger.schema.json']`
- scg_006_yellow_flows: `16`
- scg_006_root_causes: `10`
- scg_006_b3_root_causes: `9`
- scg_006_b4_root_causes: `1`
- scg_bg_001: `resolved; preserve as resolved`
- Root causes mapped: `RC-SCG006-001, RC-SCG006-002, RC-SCG006-003, RC-SCG006-004, RC-SCG006-005, RC-SCG006-006, RC-SCG006-007, RC-SCG006-008, RC-SCG006-009, RC-SCG006-010`
- Root causes unmapped: `none`

## Dependency Order

1. `SCG-007A` - Control-plane schema and stale-review hardening gate
2. `SCG-007B` - Ownership/layer unknowns and inventory hygiene
3. `SCG-007C` - Runtime action, proof, mutation, and undo contract hardening
4. `SCG-007D` - Capture global composer save, keyboard, proposal, and receipt hardening
5. `SCG-007E` - Goals creation to Today Start here coupling hardening
6. `SCG-007F` - Time Life Calendar mutation, Today recompute, and permission fallback hardening
7. `SCG-007G` - Search and inspection local Find / Act / Inspect proof hardening
8. `SCG-007H` - Surface/root UI copy and forbidden-language exposure hardening
9. `SCG-007I` - SwiftUI composition, shell geometry, and design-token hardening
10. `SCG-007J` - Accessibility and static interaction proof hardening
11. `SCG-007K` - Privacy, local-first, offline/no-account, and diagnostics proof hardening
12. `SCG-007L` - Test-strength and 16-flow behavior-proof closure
13. `SCG-007M` - Visual/device proof readiness gate

## Proposed Linear Child Issue Recommendations

These are recommendations only. They were not created in Linear during SCG-007.

### SCG-007A - Control-plane schema and stale-review hardening gate

Scope: Control-plane schema/staleness and known-issues sync only.

Root causes: RC-SCG006-008
Finding IDs: SCG-004-012
Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16

Boundaries:
- Control-plane schema/staleness and known-issues sync only.
- Do not repair production behavior.
- Do not start SCG-008.

Required outputs:
- review_ledger.schema.json or explicit accepted-Yellow waiver
- stale-review gate evidence
- known-issues sync/dedupe report preserving SCG-BG-001 resolved

Validation commands:
- `python3 -m json.tool docs/quality/senior-review/REPAIR_TRAINS.json`
- `python3 -m json.tool docs/quality/senior-review/ROOT_CAUSE_MAP.json`
- `python3 -m json.tool docs/quality/senior-review/FLOW_TRACE_AUDIT.json`
- `python3 -m json.tool docs/quality/senior-review/SENIOR_CODE_REVIEW_LEDGER.json`
- `python3 -m json.tool docs/quality/senior-review/AUTOMATED_FINDINGS.json`
- `python3 -m json.tool docs/quality/senior-review/FILE_INVENTORY.json`
- `YAML parse validation for docs/quality/senior-review/OWNERSHIP_MAP.yaml if available`
- `python3 scripts/ambitions-senior-code-audit.py`
- `python3 scripts/ambitions-senior-code-audit.py --json`
- `git diff --name-only -- Native Sources Packages AppUI project.yml Package.swift Ambitions.xcodeproj Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `git status --short --branch`

Do not claim senior-readiness, Visual Green, Release Green, app readiness, or flow/file Green without current proof.

### SCG-007B - Ownership/layer unknowns and inventory hygiene

Scope: Classify ownership and layer risks only.

Root causes: RC-SCG006-008
Finding IDs: SCG-004-001, SCG-004-002, SCG-004-003
Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16

Boundaries:
- Classify ownership and layer risks only.
- Do not move or edit production source.
- Do not mark file Green without current owner/proof evidence.

Required outputs:
- refreshed ownership map
- unknown disposition table
- inventory hygiene summary
- ledger update preserving proof limits

Validation commands:
- `python3 -m json.tool docs/quality/senior-review/REPAIR_TRAINS.json`
- `python3 -m json.tool docs/quality/senior-review/ROOT_CAUSE_MAP.json`
- `python3 -m json.tool docs/quality/senior-review/FLOW_TRACE_AUDIT.json`
- `python3 -m json.tool docs/quality/senior-review/SENIOR_CODE_REVIEW_LEDGER.json`
- `python3 -m json.tool docs/quality/senior-review/AUTOMATED_FINDINGS.json`
- `python3 -m json.tool docs/quality/senior-review/FILE_INVENTORY.json`
- `YAML parse validation for docs/quality/senior-review/OWNERSHIP_MAP.yaml if available`
- `python3 scripts/ambitions-senior-code-audit.py`
- `python3 scripts/ambitions-senior-code-audit.py --json`
- `git diff --name-only -- Native Sources Packages AppUI project.yml Package.swift Ambitions.xcodeproj Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `git status --short --branch`

Do not claim senior-readiness, Visual Green, Release Green, app readiness, or flow/file Green without current proof.

### SCG-007C - Runtime action, proof, mutation, and undo contract hardening

Scope: Repair only typed mutation/proof/undo contracts for identified flows.

Root causes: RC-SCG006-001, RC-SCG006-004, RC-SCG006-007
Finding IDs: SCG-004-004
Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16

Boundaries:
- Repair only typed mutation/proof/undo contracts for identified flows.
- No visual restyling.
- Flow Green waits for flow proof.

Required outputs:
- mutation path inventory
- typed proof/receipt/undo contract repairs
- safe fallback behavior

Validation commands:
- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/TodayCommandHandlerTests CODE_SIGNING_ALLOWED=NO`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/TimeFieldMutationCoordinatorTests CODE_SIGNING_ALLOWED=NO`
- `git diff --name-only -- Native Sources Packages AppUI project.yml Package.swift Ambitions.xcodeproj Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `git status --short --branch`

Do not claim senior-readiness, Visual Green, Release Green, app readiness, or flow/file Green without current proof.

### SCG-007D - Capture global composer save, keyboard, proposal, and receipt hardening

Scope: Keep Capture global composer only.

Root causes: RC-SCG006-002, RC-SCG006-001, RC-SCG006-010
Finding IDs: SCG-004-004, SCG-004-005, SCG-004-006, SCG-004-008, SCG-004-011, SCG-004-013
Affected flows: SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F12, SCG006-F01, SCG006-F02, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16

Boundaries:
- Keep Capture global composer only.
- Repair save/proposal/receipt/keyboard paths only.
- Do not broaden into other surface repairs except handoff assertions.

Required outputs:
- full-screen composer state-machine proof
- local save receipt path
- route correction fallback
- keyboard/focus accessibility behavior

Validation commands:
- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/CaptureViewModelTests CODE_SIGNING_ALLOWED=NO`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/CaptureRuntimeReceiptTests CODE_SIGNING_ALLOWED=NO`
- `git diff --name-only -- Native Sources Packages AppUI project.yml Package.swift Ambitions.xcodeproj Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `git status --short --branch`

Do not claim senior-readiness, Visual Green, Release Green, app readiness, or flow/file Green without current proof.

### SCG-007E - Goals creation to Today Start here coupling hardening

Scope: Repair Create Goal, Goal Detail route, Today feed, and Start here coupling only.

Root causes: RC-SCG006-003, RC-SCG006-004, RC-SCG006-001
Finding IDs: SCG-004-004, SCG-004-005, SCG-004-011, SCG-004-013
Affected flows: SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F13, SCG006-F08, SCG006-F09, SCG006-F14, SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F15, SCG006-F16

Boundaries:
- Repair Create Goal, Goal Detail route, Today feed, and Start here coupling only.
- No broad Goals redesign.
- No Green claim until current runtime proof.

Required outputs:
- create goal runtime path
- Goal detail route evidence
- Today feed recompute evidence
- Goals plus no-crash proof

Validation commands:
- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/CreateGoalViewModelTests CODE_SIGNING_ALLOWED=NO`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/TodayFreshGoalVisibilityTests CODE_SIGNING_ALLOWED=NO`
- `git diff --name-only -- Native Sources Packages AppUI project.yml Package.swift Ambitions.xcodeproj Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `git status --short --branch`

Do not claim senior-readiness, Visual Green, Release Green, app readiness, or flow/file Green without current proof.

### SCG-007F - Time Life Calendar mutation, Today recompute, and permission fallback hardening

Scope: Repair Time placement/protection/correction and Today recompute only.

Root causes: RC-SCG006-005, RC-SCG006-007, RC-SCG006-009, RC-SCG006-001
Finding IDs: SCG-004-004, SCG-004-007, SCG-004-010, SCG-004-011, SCG-004-013
Affected flows: SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F14, SCG006-F16, SCG006-F08, SCG006-F15, SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F12, SCG006-F13

Boundaries:
- Repair Time placement/protection/correction and Today recompute only.
- No external calendar/cloud sync dependency.
- Permission-denied fallback must be safe and honest.

Required outputs:
- injected-clock cleanup
- real-step-only mutation proof
- Today recompute evidence
- permission-denied fallback evidence

Validation commands:
- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/TimeTodayCouplingTests CODE_SIGNING_ALLOWED=NO`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/TimeFieldMutationCoordinatorTests CODE_SIGNING_ALLOWED=NO`
- `git diff --name-only -- Native Sources Packages AppUI project.yml Package.swift Ambitions.xcodeproj Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `git status --short --branch`

Do not claim senior-readiness, Visual Green, Release Green, app readiness, or flow/file Green without current proof.

### SCG-007G - Search and inspection local Find / Act / Inspect proof hardening

Scope: Repair Search overlay route, result action, inspection handoff, and local-only proof only.

Root causes: RC-SCG006-006, RC-SCG006-007, RC-SCG006-009, RC-SCG006-001
Finding IDs: SCG-004-004, SCG-004-010, SCG-004-011, SCG-004-013
Affected flows: SCG006-F12, SCG006-F13, SCG006-F08, SCG006-F10, SCG006-F11, SCG006-F14, SCG006-F15, SCG006-F16, SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F09

Boundaries:
- Repair Search overlay route, result action, inspection handoff, and local-only proof only.
- Do not add network search or chatbot behavior.
- Do not turn Search into a root surface.

Required outputs:
- local index route proof
- typed result action proof
- inspection handoff proof
- privacy/local-only assertion

Validation commands:
- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/MemoryLensServiceTests CODE_SIGNING_ALLOWED=NO`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test -only-testing:AmbitionsTests/ShellCommandRouterTests CODE_SIGNING_ALLOWED=NO`
- `git diff --name-only -- Native Sources Packages AppUI project.yml Package.swift Ambitions.xcodeproj Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `git status --short --branch`

Do not claim senior-readiness, Visual Green, Release Green, app readiness, or flow/file Green without current proof.

### SCG-007H - Surface/root UI copy and forbidden-language exposure hardening

Scope: Remove/gate only evidence-backed forbidden/internal user-facing copy.

Root causes: RC-SCG006-010, RC-SCG006-001
Finding IDs: SCG-004-006
Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F16, SCG006-F15

Boundaries:
- Remove/gate only evidence-backed forbidden/internal user-facing copy.
- Use locked language: Start here, Recommended step, Step, Start now, Open step.
- Do not rewrite product canon.

Required outputs:
- forbidden-language scan evidence
- copy policy tests
- known-issues reconciliation for AMB-ISSUE-0010

Validation commands:
- `python3 scripts/ambitions-senior-code-audit.py`
- `python3 scripts/ambitions-senior-code-audit.py --json`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test CODE_SIGNING_ALLOWED=NO`
- `git diff --name-only -- Native Sources Packages AppUI project.yml Package.swift Ambitions.xcodeproj Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `git status --short --branch`

Do not claim senior-readiness, Visual Green, Release Green, app readiness, or flow/file Green without current proof.

### SCG-007I - SwiftUI composition, shell geometry, and design-token hardening

Scope: Repair only flagged composition/shell geometry risks.

Root causes: RC-SCG006-010, RC-SCG006-001
Finding IDs: SCG-004-005, SCG-004-009
Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F16, SCG006-F15

Boundaries:
- Repair only flagged composition/shell geometry risks.
- Do not create duplicate material systems/root shells/dashboard anatomy.
- Do not claim Visual Green.

Required outputs:
- composition refactor or accepted-Yellow disposition
- StageSafeAreaPolicy shell proof
- design-token hardening for touched visible files

Validation commands:
- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test CODE_SIGNING_ALLOWED=NO`
- `python3 scripts/ambitions-senior-code-audit.py`
- `git diff --name-only -- Native Sources Packages AppUI project.yml Package.swift Ambitions.xcodeproj Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `git status --short --branch`

Do not claim senior-readiness, Visual Green, Release Green, app readiness, or flow/file Green without current proof.

### SCG-007J - Accessibility and static interaction proof hardening

Scope: Repair static accessibility semantics and interaction proof only.

Root causes: RC-SCG006-010, RC-SCG006-001
Finding IDs: SCG-004-008, SCG-004-011, SCG-004-013
Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F16, SCG006-F15

Boundaries:
- Repair static accessibility semantics and interaction proof only.
- Dynamic Type/VoiceOver/Reduce Motion/Reduce Transparency/Increase Contrast/tap target notes required where touched.
- Do not claim full accessibility conformance without manual/current proof.

Required outputs:
- accessibility marker repairs
- semantic mirror tests
- Dynamic Type/Reduce Motion/Contrast checklist

Validation commands:
- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test CODE_SIGNING_ALLOWED=NO`
- `python3 scripts/ambitions-senior-code-audit.py`
- `git diff --name-only -- Native Sources Packages AppUI project.yml Package.swift Ambitions.xcodeproj Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `git status --short --branch`

Do not claim senior-readiness, Visual Green, Release Green, app readiness, or flow/file Green without current proof.

### SCG-007K - Privacy, local-first, offline/no-account, and diagnostics proof hardening

Scope: Prove offline/no-account/local-only behavior and diagnostics redaction only.

Root causes: RC-SCG006-009, RC-SCG006-001
Finding IDs: SCG-004-010
Affected flows: SCG006-F15, SCG006-F16, SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14

Boundaries:
- Prove offline/no-account/local-only behavior and diagnostics redaction only.
- Do not implement account/sync/R2/cloud behavior unless future scoped issue authorizes it.
- Do not claim privacy/legal approval.

Required outputs:
- offline launch/use proof
- account-absent core flow proof
- request-shape review
- diagnostics redaction assertions

Validation commands:
- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test CODE_SIGNING_ALLOWED=NO`
- `python3 scripts/ambitions-senior-code-audit.py`
- `git diff --name-only -- Native Sources Packages AppUI project.yml Package.swift Ambitions.xcodeproj Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `git status --short --branch`

Do not claim senior-readiness, Visual Green, Release Green, app readiness, or flow/file Green without current proof.

### SCG-007L - Test-strength and 16-flow behavior-proof closure

Scope: Replace weak proof with behavior proof for F01-F16 only.

Root causes: RC-SCG006-001, RC-SCG006-002, RC-SCG006-003, RC-SCG006-004, RC-SCG006-005, RC-SCG006-006, RC-SCG006-007, RC-SCG006-008, RC-SCG006-009, RC-SCG006-010
Finding IDs: SCG-004-011, SCG-004-013
Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16

Boundaries:
- Replace weak proof with behavior proof for F01-F16 only.
- Do not repair production behavior inside this proof train unless a minimal hook is explicitly scoped.
- Flow Green requires behavior proof, not source-string tests.

Required outputs:
- behavior-proof test matrix for F01-F16
- updated flow audit/root cause map preserving Yellow where proof missing
- known-issues reconciliation

Validation commands:
- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test CODE_SIGNING_ALLOWED=NO`
- `python3 scripts/ambitions-senior-code-audit.py`
- `python3 scripts/ambitions-senior-code-audit.py --json`
- `git diff --name-only -- Native Sources Packages AppUI project.yml Package.swift Ambitions.xcodeproj Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `git status --short --branch`

Do not claim senior-readiness, Visual Green, Release Green, app readiness, or flow/file Green without current proof.

### SCG-007M - Visual/device proof readiness gate

Scope: Collect/evaluate visual/device proof only after upstream runtime, copy, accessibility, privacy, and behavior-proof gates.

Root causes: RC-SCG006-001, RC-SCG006-010
Finding IDs: SCG-004-013
Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16

Boundaries:
- Collect/evaluate visual/device proof only after upstream runtime, copy, accessibility, privacy, and behavior-proof gates.
- Do not self-certify Visual Green or Release Green.
- Do not start SCG-008 until known-issues sync/dedupe is complete.

Required outputs:
- visual/device proof matrix
- target-versus-actual critiques
- accessibility/device proof index
- Ready for Visual Review or Yellow/Red closeout

Validation commands:
- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test CODE_SIGNING_ALLOWED=NO`
- `python3 scripts/ambitions-senior-code-audit.py`
- `git diff --name-only -- Native Sources Packages AppUI project.yml Package.swift Ambitions.xcodeproj Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `git status --short --branch`

Do not claim senior-readiness, Visual Green, Release Green, app readiness, or flow/file Green without current proof.

## Validation Commands for SCG-007 Closeout

- `python3 -m json.tool docs/quality/senior-review/REPAIR_TRAINS.json`
- `python3 -m json.tool docs/quality/senior-review/ROOT_CAUSE_MAP.json`
- `python3 -m json.tool docs/quality/senior-review/FLOW_TRACE_AUDIT.json`
- `python3 -m json.tool docs/quality/senior-review/SENIOR_CODE_REVIEW_LEDGER.json`
- `python3 -m json.tool docs/quality/senior-review/AUTOMATED_FINDINGS.json`
- `python3 -m json.tool docs/quality/senior-review/FILE_INVENTORY.json`
- `YAML parse validation for docs/quality/senior-review/OWNERSHIP_MAP.yaml if available`
- `python3 scripts/ambitions-senior-code-audit.py`
- `python3 scripts/ambitions-senior-code-audit.py --json`
- `git diff --name-only -- Native Sources Packages AppUI project.yml Package.swift Ambitions.xcodeproj Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `git status --short --branch`

## Closeout Posture

- Red findings discovered by SCG-007: `0`
- Yellow findings carried forward: SCG-003/004/005/006 Yellow evidence mapped into trains
- Known-issues updates: `none`; no new real Red/B0/B1/B2 discovered in SCG-007
- Production behavior changed: `no`
- Rollback: revert the three generated SCG-007 planning artifacts
