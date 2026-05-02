# CS01-CS10 Compatibility Seam Retirement Train

<!-- markdownlint-disable MD013 -->

Status: Active Ambitions 4.0 train manifest; CS01 audit evidence, CS07 external compatibility proof, CS08 import/export/persistence proof, and CS02A/CS02B Profile/You compatibility evidence complete; CS03 is next if global continuation gates pass.

## Start Rule

This train starts only when the user explicitly approves it after Ambitions 3.0/F17-F30 truth is Green and `docs/codex/BATCH_REGISTRY.md` records the selected train as active. Required user approval phrase: `Start CS Train`.

Current global execution note: the active prompt phrase `Run Global Batch Sequence Until Blocked` preauthorizes routine Ambitions 4.0 train transitions when global order and gates are Green or accepted Yellow. CS01 was selected by global order after ME12 and completed as audit-only evidence without retiring seams. CS07 completed focused external route/widget/App Intent compatibility proof without retiring seams. CS08 completed focused import/export/persistence compatibility proof without retiring seams.

## What Does Not Start This Train

Reading this manifest, updating future canon, completing AmbitionsOS docs, finishing F30, or selecting a roadmap lane does not start the train. AOS/ME/CS/Product Depth/Release Evidence Closure do not start each other by implication.

## Historical Truth To Preserve

Ambitions 3.0 is complete by F30 closeout evidence. F17-F30 remains a complete historical train. AmbitionsOS remains future canon until implementation evidence exists. Release, App Store, TestFlight, physical-device, public accessibility, signed archive, App Store Connect, and rendered external-platform claims remain unmade unless a later train produces proof.

## Train Safety Gates

- Batch order is sequential unless this manifest names an explicit dependency exception.
- Green may continue only after evidence, report, registry/context/run-state update, commit, and push.
- Yellow stops unless the manifest says the next batch may proceed with documented risk.
- Red stops immediately and opens a repair or user-decision prompt.
- Build/test requirements are batch-specific: docs-only batches use doc and registry checks; app-code batches require focused tests and advisory build at minimum; release-claim batches require evidence-ledger proof and explicit claim review.
- No second batch starts from this manifest unless the active batch is Green and train rules allow continuation.
- Repair-train triggers: unclassified validation failure, forbidden file drift, claim overreach, privacy/source/compatibility uncertainty, or behavior regression.
- Every batch must be committed before continuation.

## File Boundaries

Allowed files are the files named by each batch prompt. Forbidden across the train: `.github/workflows/**`, dependencies, lockfiles, signing/project release config, persistence/schema files unless a migration batch explicitly owns them, broad app refactors, new top-level navigation, backend/sync/account/telemetry/runtime AI additions, and release/platform claims without evidence.

## Batch Order And Gates

- CS01: Compatibility Seam Registry And Risk Map. Action: maps. Seam: all Lane 3 candidate seams. Gate: replacement map and compatibility proof before deletion. Status: complete as audit-only evidence; no seam retired.
- CS02: Profile To You Compatibility Seam Repair And Narrow Retirement. Action: staged map/prove/retire. Seam: Profile internal naming, `profile` raw/default compatibility, You user-facing display, and accessibility identifiers. Status: CS02A and CS02B complete with accepted Yellow; CS02C retirement remains blocked/deferred. Formal count remains 113.
- CS03: Insights Compatibility Retirement. Action: retires. Seam: Insights route/model compatibility for contextual intelligence. Gate: replacement map and compatibility proof before deletion.
- CS04: Habits Ritual Plan Compatibility Retirement. Action: retires. Seam: Habits route/model compatibility for Ritual/Plan continuity. Gate: replacement map and compatibility proof before deletion.
- CS05: ActiveFocus TodayFocus Retirement. Action: retires. Seam: activeFocus, TodayFocus*, and .focus Today compatibility. Gate: replacement map and compatibility proof before deletion.
- CS06: Internal Failed Taxonomy Retirement. Action: retires. Seam: internal .failed taxonomy where visible language stays humane. Gate: replacement map and compatibility proof before deletion.
- CS07: External Route Widget AppIntent Compatibility Proof. Action: proves. Seam: external routes, widget payloads, App Intent/Shortcut payloads. Gate: replacement map and compatibility proof before deletion. Status: complete as focused simulator/unit proof; no seam retired.
- CS08: Import Export Persistence Compatibility Proof. Action: proves. Seam: import/export payloads and persistence/schema compatibility views. Gate: replacement map and compatibility proof before deletion. Status: complete as focused simulator/unit proof; no seam retired.
- CS09: Compatibility Regression Repair. Action: repairs. Seam: files named by failed CS evidence. Gate: replacement map and compatibility proof before deletion.
- CS10: Compatibility Retirement Handoff. Action: hands off. Seam: docs/audits, docs/codex, .codex/reports. Gate: replacement map and compatibility proof before deletion.

## Validation Matrix

Each batch report must include: command evidence, log paths when available, pass/fail/partial status, what the proof covers, what it does not prove, privacy/accessibility/performance/compatibility/release impacts, rollback/repair path, and next allowed batch.

## Auto-Continuation

Auto-continuation is disabled by default outside global execution mode. In global execution mode, continuation is allowed only when the active batch is Green or accepted Yellow, committed, pushed, and the next batch is selected by the global order. Yellow must be classified and owned; Red blocks continuation.

## Release Claim Boundary

This train does not create release readiness, App Store readiness, TestFlight readiness, final RC lock, physical-device proof, public accessibility conformance, signed archive validation, App Store Connect validation, or rendered external-platform proof unless a batch explicitly produces and records that evidence.

## Closeout

Closeout requires an audit report, registry/context/run-state updates, evidence ledger entry, diff boundary check, and exact next-user-decision statement. CS closeout must also update the compatibility seam sunset log, migration impact review, and rollback registry.
