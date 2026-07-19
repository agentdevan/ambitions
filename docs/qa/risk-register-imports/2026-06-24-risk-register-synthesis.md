# 2026-06-24 Risk Register Import Synthesis

Status: Evidence import mapped into existing Ambitions control planes  
Import evidence source: `Ambitions_Synthesized_Risk_Register.md`  
Canonical authorities: `docs/qa/KNOWN_ISSUES.md`, QA remediation dossiers, SCG artifacts, and `docs/truth/*`  
Scope: Docs/control-plane integration only

This artifact is a decision record and dedupe map. It is not a third project, not a parallel risk database, and not source of truth. The imported register is planning evidence only; it does not certify runtime behavior, device behavior, App Store posture, CloudKit behavior, accessibility, privacy, account readiness, R2 readiness, or owner acceptance.

## Executive Decision

- Feed the import into existing QA remediation rows first, SCG root causes/repair trains second, new repo-backed known issue rows third, and Linear proposals/comments last.
- Keep `docs/qa/KNOWN_ISSUES.md` as the canonical implementation/proof ledger.
- Keep QA remediation as owner for user-visible runtime, UI, visual, accessibility, device, route, and proof-failed work.
- Keep SCG as owner for root-cause maps, repair trains, stale-review, anti-gaming, test-strength, privacy boundary, persistence/concurrency, and systemic code-quality gates.
- Add live imported known-issue rows `AMB-ISSUE-2001` through `AMB-ISSUE-2012`.
- Keep `AMB-ISSUE-2013` proposal-only unless later app-group launch evidence proves it is not covered by `AMB-ISSUE-2002` or `AMB-ISSUE-2009`.
- Do not change production app code or generated SCG artifacts in this pass.
- Do not execute Linear updates in this pass.

## Proof Ceilings

| Evidence state | Maximum status |
|---|---|
| Risk imported, no source repair | Open |
| Source repair only | Source-repaired candidate |
| Simulator proof only | Runtime/Visual Yellow maximum |
| Automated accessibility contract only | Accessibility Yellow maximum |
| Screenshot paths without visual review | Not proof |
| Device proof without owner acceptance | Proof pending / not Closed-verified |
| SCG source/control Green | Governance Green only |
| QA device/runtime/owner proof complete | Eligible for Closed-verified review |

Non-claims:

- Source repair is not runtime proof.
- Simulator proof is not device proof.
- Visual proof is not owner acceptance.
- Governance Green is not product Green.
- No issue is Closed-verified without current proof and owner acceptance.

## Canon And Device-Review Alignment

The import reinforces existing Ambitions law rather than changing it:

- Persistent surfaces remain Today / Goals / Time / You.
- Capture remains global composer, not a root tab.
- Motion remains behavior, not a destination.
- Core value remains local-first/offline with no account required.
- R2/Source Atlas remain public/reference/freshness infrastructure only and must not receive the private life graph.
- Every meaningful action requires runtime mutation, visible stage mutation, accessible state change, safe fallback, and proof artifact.

The import also matches the prior device-review failure pattern already represented in `KNOWN_ISSUES.md`: Capture crash and composer proof gaps, non-mutating closure and Today recompute gaps, internal runtime jargon, duplicate shell chrome and dock overlap, Time layout/mutation weakness, weak native quality, and frontend/runtime validation blockers.

## Imported Risk Map

| Import ID | Original ref | Title | Severity | Disposition | Canonical mapping | Required proof |
|---|---|---:|---|---|---|---|
| IR-2026-06-24-001 | CR-P0-001 | Runtime authority fragmentation | P0 | Strengthen existing known issue; map SCG | AMB-ISSUE-0014; proposed AMB-ISSUE-2001; AMB-1301/1304; SCG-007C/L | End-to-end command spine, durable state, visible mutation, accessibility, proof artifact |
| IR-2026-06-24-002 | CR-P0-002 | End-to-end mutation proof gap | P0 | Strengthen existing rows | AMB-ISSUE-0014, 0004, 0305, 1401; AMB-1300/1304/1195/1197 | Before/action/after, persistence after restart, proof and undo IDs |
| IR-2026-06-24-003 | CR-P0-003 | Command validation and idempotency | P0 | Create new known issue row | AMB-ISSUE-2001; AMB-1301/1304; SCG-007C/L | Validation blocks mutation, duplicate replay, durable idempotency |
| IR-2026-06-24-004 | CR-P0-004 | Time mutation durability | P0 | Strengthen existing rows | AMB-ISSUE-0009, 0501-0507, 0913, 1401-1405; AMB-1197 | Device/simulator before/action/after, restart persistence, undo, Today recompute |
| IR-2026-06-24-005 | CR-P0-005 | Today / Time / Closure truth loop | P0 | Strengthen existing rows | AMB-ISSUE-0004, 0005, 0305, 1001-1007, 1201, 0014; AMB-1195/1300 | Close Step to proof to Today recompute to restart replay |
| IR-2026-06-24-006 | CR-P0-006 | Capture core input path | P0 | Strengthen existing rows | AMB-ISSUE-0003, 0008, 0012, 0201-0205, 1101-1111; AMB-1192 | Full-screen composer device proof, keyboard, offline save, no crash, proposal/receipt |
| IR-2026-06-24-007 | CR-P0-007 | External intake data loss | P0 | Create new known issue row | AMB-ISSUE-2002; AMB-1097/1034/1093/1100; SCG-007D/L | Append-only queue, ack after import, retry, failure UI, no data loss |
| IR-2026-06-24-008 | CR-P0-008 | Capture persistence identity | P0 | Create new known issue row | AMB-ISSUE-2003; AMB-1192/1304; SCG-007D/L | Direct ID fetch, more than 500 captures, restart, search/detail/open |
| IR-2026-06-24-009 | CR-P0-009 | Custom Ambitions account architecture | P0 | Create new known issue row | AMB-ISSUE-2004; AMB-1178/1039; SCG-007K/012 | SIWA/Google, Keychain, session recovery, deletion, logged-out offline core |
| IR-2026-06-24-010 | CR-P0-010 | Account-scoped storage and erasure | P0 | Create new known issue row | AMB-ISSUE-2005; AMB-1178/632/610; SCG-007K/012 | Sign-out/delete/export/reset across local store, app group, widgets, notifications, credentials |
| IR-2026-06-24-011 | CR-P0-011 | CloudKit sync engine | P0 | Create new known issue row | AMB-ISSUE-2006; AMB-632; SCG-012 | Schema, zones, tombstones, conflicts, retry, migration, multi-device proof |
| IR-2026-06-24-012 | CR-P0-012 | Local-first privacy boundary with accounts/R2 | P0 | Create new known issue row | AMB-ISSUE-2007; AMB-1178/610/632; SCG-007K/012 | Request-shape proof, no private graph egress, offline core, You/Privacy copy |
| IR-2026-06-24-013 | CR-P0-013 | External side effects | P0 | Create new known issue row | AMB-ISSUE-2008; AMB-1033/1095/1096/1142; SCG-007K/012 | Local transaction, external write, rollback/recovery, failure-visible UI, permission denial |
| IR-2026-06-24-014 | CR-P0-014 | Widget/App Intent/deep-link runtime bypass | P0 | Create new known issue row | AMB-ISSUE-2009; AMB-1092/1093/994/1028/1029/1142; SCG-007D/I/L | External action to command, target validation, stale-aware account-scoped snapshot |
| IR-2026-06-24-015 | CR-P0-015 | Persistence/import/export integrity | P0 | Create new known issue row | AMB-ISSUE-2010; AMB-1295/1178/610; SCG-012 | Transactional import/export, duplicate validation, rollback, corrupt-record visibility |
| IR-2026-06-24-016 | CR-P0-016 | Stage/shell/canon architecture | P0 | Already covered; strengthen rows | AMB-ISSUE-0806, 1011, 1701-1709, 0014; AMB-1194/1293 | Root/drilldown/overlay screenshot matrix, safe area, no duplicate shelf, no Motion root |
| IR-2026-06-24-017 | CR-P0-017 | Runtime jargon / trust theater | P0 | Already covered; strengthen rows | AMB-ISSUE-0010; AMB-1299; SCG-007H | Forbidden language audit plus rendered screenshot review |
| IR-2026-06-24-018 | CR-P0-018 | Release false-green and proof gap | P0 | Already covered; strengthen rows | AMB-ISSUE-0014, 0807, 1801, 1802; AMB-1199/1200/1304 | Exact SHA build, device screenshots, accessibility, archive entitlement/privacy, mutation proof |
| IR-2026-06-24-019 | CR-P0-019 | Security, privacy manifest, local authentication | P0 | Create new known issue row | AMB-ISSUE-2011; AMB-1295/1294/1178/634; SCG-011/012 | Archive privacy manifest audit, file protection, evaluatePolicy, least-privilege prompts |
| IR-2026-06-24-020 | CR-P0-020 | Source Atlas / R2 implementation boundary | P0 | Create new known issue row | AMB-ISSUE-2012; AMB-1178/1036/658/668/610; SCG-012 | Provider schema, local cache, public-only request proof, freshness/error/ranking tests |
| IR-2026-06-24-021 | CR-P1-021 | Persistence performance | P1 | Map to SCG; defer row unless measured blocker | AMB-ISSUE-0014; AMB-1295; SCG-012 | Large-store measured tests, fetch descriptors, memory/battery proof |
| IR-2026-06-24-022 | CR-P1-022 | Missing unit-of-work boundaries | P1 | Strengthen AMB-ISSUE-2001 | AMB-ISSUE-2001/0014; AMB-1304/1295 | Forced-failure rollback/safe-incomplete proof |
| IR-2026-06-24-023 | CR-P1-023 | Goal graph/detail integrity | P1 | Strengthen existing rows | AMB-ISSUE-0401-0405, 1301-1309; AMB-1193/1302/1303 | Reciprocal invariants, stale-save protection, persistence reload, Today feed |
| IR-2026-06-24-024 | CR-P1-024 | Capacity and fit credibility | P1 | Strengthen Time rows | AMB-ISSUE-0501-0507, 1401-1405; AMB-1197 | Fixed/open/protected/pressure/energy/transition or explicit unknowns |
| IR-2026-06-24-025 | CR-P1-025 | Notification behavior | P1 | Fold into side-effect row | AMB-ISSUE-2008; AMB-1033/1095/1096 | Two-phase replacement, unique IDs, sign-out clears prompts |
| IR-2026-06-24-026 | CR-P1-026 | Calendar/schedule semantics | P1 | Strengthen Time and side-effect rows | AMB-ISSUE-0503, 0506, 2008; AMB-1197/1033/1142 | Permission-denied fallback, local-vs-EventKit intent ledger |
| IR-2026-06-24-027 | CR-P1-027 | App-group / multi-process storage | P1 | Proposal-only fold | AMB-ISSUE-2013 proposal; fold into 2002/2009 unless launch evidence requires row | File coordination, protection class, corruption recovery, race tests |
| IR-2026-06-24-028 | CR-P1-028 | Today product surface | P1 | Already covered | AMB-ISSUE-0101-0108, 1001-1011, 0004, 0005; AMB-1195 | Live now, no-step/valid-step, closure mutation, no jargon, device proof |
| IR-2026-06-24-029 | CR-P1-029 | Time product surface | P1 | Already covered | AMB-ISSUE-0501-0507, 0913, 1401-1405; AMB-1197 | Life Calendar matrix, placement/protection proof, preview-vs-durable labeling |
| IR-2026-06-24-030 | CR-P1-030 | Goals product surface | P1 | Already covered | AMB-ISSUE-0401-0405, 1301-1309; AMB-1193 | Goal root/detail, area detail, creation no-crash, Today feed, device proof |
| IR-2026-06-24-031 | CR-P1-031 | You product surface | P1 | Already covered | AMB-ISSUE-0601-0607, 1501-1505; AMB-1198 | Native settings proof, actionable rows, detail routes, no dock overlap, device proof |
| IR-2026-06-24-032 | CR-P1-032 | Search / inspection actionability | P1 | Already covered | AMB-ISSUE-0701, 1601-1605; AMB-1196 | Bounded local index, route/action proof, local-only scan, screenshot/video |
| IR-2026-06-24-033 | CR-P1-033 | Undo and fallback honesty | P1 | Strengthen proof rows | AMB-ISSUE-0014, 0305, 1401, 1801, 1802; AMB-1300/1304 | Durable inverse, non-undo disclosure, forced-failure visible non-success |
| IR-2026-06-24-034 | CR-P1-034 | Heuristic over-inference | P1 | Strengthen Capture and R2 rows | AMB-ISSUE-1107, 2012; AMB-1192/1178/1036 | Tentative placement, clarification thresholds, correction persistence |
| IR-2026-06-24-035 | CR-P1-035 | Deep-link / route input safety | P1 | Strengthen external-surface row | AMB-ISSUE-2009; AMB-994/1093/1301 | Bounded parser, internal provenance, target validation, safe review state |
| IR-2026-06-24-036 | CR-P1-036 | Build composition/generated graph | P1 | Map SCG; no new row unless production artifact proves | AMB-ISSUE-0014; AMB-1295/1296; SCG-012/013 | Generated project membership audit, debug exclusions, archive target proof |
| IR-2026-06-24-037 | CR-P1-037 | Accessibility and Dynamic Type | P1 | Already covered; strengthen rows | AMB-ISSUE-0807, 1801, 1802, 0014; AMB-1199/1294 | VoiceOver, Dynamic Type, Reduce Motion/Transparency, Increase Contrast, device matrix |
| IR-2026-06-24-038 | CR-P1-038 | Deterministic time and replay | P1 | Map SCG; strengthen Time proof | AMB-ISSUE-0501/0502/0014; AMB-1163/1295/1304 | Injected clock across reducers/ledgers/exports/notifications; day-boundary tests |
| IR-2026-06-24-039 | CR-P1-039 | Data corruption crash surfaces | P1 | Strengthen AMB-ISSUE-2010 | AMB-ISSUE-2010; AMB-1295/1178 | Duplicate handling, typed validation, health warning, no silent audit loss |
| IR-2026-06-24-040 | CR-P1-040 | Repo governance/stale artifacts | P1 | Already covered in SCG, not QA | AMB-1288/1290/1298; SCG-007A/B | Schema/stale-review validation, inventory refresh, owner acceptance of Yellow |
| IR-2026-06-24-041 | CR-P2-041 | Command taxonomy drift | P2 | Strengthen AMB-ISSUE-0010 | AMB-ISSUE-0010; AMB-1299; SCG-007H | Forbidden/approved language scan and screenshots |
| IR-2026-06-24-042 | CR-P2-042 | Motion implementation shape | P2 | Covered by SCG and shell rows | AMB-ISSUE-0806/170x; AMB-1293/1299 | Typed StageMotionEvent, no root Motion, Reduce Motion proof |
| IR-2026-06-24-043 | CR-P2-043 | First-run / empty capacity behavior | P2 | Fold into account/offline row | AMB-ISSUE-2004/0014; AMB-1178/1304 | Offline Capture/Start flow without account/calendar/R2 |
| IR-2026-06-24-044 | CR-P2-044 | Source/status noise | P2 | Strengthen language/You rows | AMB-ISSUE-0010, 0601-0607, 1504-1505; AMB-1198/1299 | Status only in You/inspection/confirmation screenshots |
| IR-2026-06-24-045 | CR-P2-045 | Evidence source naming | P2 | Strengthen AMB-ISSUE-0010 | AMB-ISSUE-0010; AMB-1299 | AI/source label scan; no cloud-AI implication |
| IR-2026-06-24-046 | CR-P2-046 | Protocol defaults/no-op behavior | P2 | Map SCG and AMB-ISSUE-2001 | AMB-ISSUE-2001/0014; AMB-1301/1304/1295 | Production graph rejects no-op critical services outside preview/test |
| IR-2026-06-24-047 | CR-P2-047 | Widget/Live Activity design drift | P2 | Fold into external-surface row | AMB-ISSUE-2009; AMB-1092/1095/1028/1029 | Design tokens, account scope, stale labeling, placeholder prohibition |
| IR-2026-06-24-048 | CR-P2-048 | Permission UX / denial fallback | P2 | Strengthen existing rows | AMB-ISSUE-0003, 0503, 0506, 0807, 1801; AMB-1192/1197/1199 | Contextual prompts, denial fallback, least-privilege copy, device proof |
| IR-2026-06-24-049 | CR-P2-049 | Runtime gate rigidity | P2 | Map SCG | AMB-ISSUE-0014; AMB-1304/1298/1295 | Gate generated from executable scenarios; manual flows still usable |
| IR-2026-06-24-050 | CR-P2-050 | High-risk safety incompleteness | P2 | Strengthen AMB-ISSUE-2011 | AMB-ISSUE-2011; AMB-1294/1295/1178 | Sensitive-scenario and local-auth matrix; evaluatePolicy proof |
| IR-2026-06-24-051 | CR-P2-051 | App bootstrap sequencing | P2 | Fold into external intake and SCG | AMB-ISSUE-2002/2001; AMB-1100/1304/1295 | Ready UI vs pending imports, single-flight, measured cold start |
| IR-2026-06-24-052 | CR-P2-052 | User-facing copy budget | P2 | Strengthen AMB-ISSUE-0010 | AMB-ISSUE-0010 plus surface rows; AMB-1299 | Copy budget scan plus root screenshots |
| IR-2026-06-24-053 | CR-P2-053 | Visual grammar regression | P2 | Strengthen visual rows | AMB-ISSUE-0806, 1706, 1709, 1302, 0501, 0602 | Root screenshots prove one primary object; no card-dashboard root |
| IR-2026-06-24-054 | CR-P2-054 | History/proof parallel sources | P2 | Strengthen runtime proof and persistence row | AMB-ISSUE-0014, 2010; AMB-1300/1304/1295 | Source event to snapshot to receipt consistency/replay |
| IR-2026-06-24-055 | CR-P2-055 | Review/test realism | P2 | Already covered in SCG | AMB-ISSUE-0014, 1801, 1802; AMB-1304/1298 | Live persistent UI tests, SwiftData integration, mutation scenario tests |
| IR-2026-06-24-056 | CR-P2-056 | Release operational runbooks | P2 | Strengthen release proof rows | AMB-ISSUE-0014, 2004, 2006, 2011; AMB-634/632/1199/1200 | Archive, privacy, CloudKit schema promotion, account deletion, incident recovery runbooks |

## Live Known-Issue Rows Added

| Known issue | Title | Status ceiling |
|---|---|---|
| AMB-ISSUE-2001 | Canonical runtime command spine, validation, idempotency, and unit-of-work proof missing | Open until command, mutation, idempotency, rollback, and device/runtime proof exist |
| AMB-ISSUE-2002 | External intake queue can lose user-submitted content | Open until no-data-loss queue/ack/retry proof exists |
| AMB-ISSUE-2003 | Capture direct-ID persistence lookup is not proven for older captures | Open until direct lookup, search/detail, and restart proof exist |
| AMB-ISSUE-2004 | Optional Ambitions Account launch architecture is not proof-ready | Open until account/offline proof exists |
| AMB-ISSUE-2005 | Account-scoped storage, sign-out, delete-account, and erasure proof missing | Open until account-scope and erasure proof exists |
| AMB-ISSUE-2006 | CloudKit sync engine is not launch-proof | Open until production sync proof exists; no sync claim allowed |
| AMB-ISSUE-2007 | Local-first privacy boundary with account/R2 is not proven | Open until request-shape and no-private-graph proof exists |
| AMB-ISSUE-2008 | External side-effect unit-of-work is not proven | Open until local transaction/external side-effect rollback proof exists |
| AMB-ISSUE-2009 | Widgets, App Intents, and deep links may bypass command/runtime safety | Open until external actions normalize through canonical command safety |
| AMB-ISSUE-2010 | Persistence, import/export, reset, store health, and audit graph integrity not proven | Open until transactional and corrupt-record proof exists |
| AMB-ISSUE-2011 | Security, privacy manifest, local auth, and app-group protection proof missing | Open until archive/privacy/local-auth protection proof exists |
| AMB-ISSUE-2012 | Source Atlas / R2 provider, cache, freshness, ranking, and public-only boundary not proven | Open until public-only Source Atlas/R2 proof exists |

Proposal-only:

- `AMB-ISSUE-2013` app-group and multi-process storage race/corruption proof. Fold into `AMB-ISSUE-2002` and `AMB-ISSUE-2009` unless later launch-scope evidence proves a separate app-group row is required.

## Existing Rows Strengthened

| Existing row group | Imported evidence | Strengthening |
|---|---|---|
| AMB-ISSUE-0014 | IR-001/002/003/018/040/055/056 | Add import as false-green, proof, device, accessibility, privacy, release, and owner-acceptance evidence. |
| AMB-ISSUE-0010 | IR-017/041/044/045/052 | Require forbidden-language scan plus rendered screenshot review; string scan alone is not enough. |
| Today / Closure rows | IR-005/028/033 | Require restart-proof Today mutation, proof/undo artifact IDs, and before/action/after evidence. |
| Capture rows | IR-006/007/008/034/048 | Require composer, keyboard, offline save, direct-ID lookup, external queue ack, proposal, and receipt proof. |
| Time rows | IR-004/024/026/029/033/038/048 | Require durable-vs-preview distinction, injected clock, restart proof, Today recompute, undo, and permission-denied fallback. |
| Goals rows | IR-023/030 | Require graph invariants, persistence reload, Today feed, Goal/Area detail, and step-chain proof. |
| You rows | IR-031/044 | Require account/R2/settings actionability proof and no unsupported account/sync claims. |
| Search rows | IR-032/035 | Require local-only bounded index, route/action proof, target validation, and no network proof. |
| Shell rows | IR-014/016/042/047/053 | Require root/drilldown/overlay matrix, no overlap, no stale external state, no Motion root. |
| Accessibility/final-proof rows | IR-018/019/037/050/055 | Require manual/device accessibility, privacy-trust, and archive/security proof; automated contracts are not enough. |

## Partial Coverage Only

No consolidated imported risk is marked Resolved with evidence.

- Motion-as-root and Capture-as-tab subrisks remain source/not-observed improvements only; broad Stage/Motion and Capture composer proof remains pending.
- Old hardcoded Today time is improved, but deterministic clock and replay proof remains open.
- Duplicate bottom shelf and closure visual direction have source repairs only; device/runtime proof is pending.
- SCG-009B typed closure classification is source/test evidence only for the touched seam.
- SCG-BG-001 remains the one build-graph subcase resolved by package-relative path audit; broader build graph risk remains Yellow.

## Prepared Linear Comments

Do not execute these updates without explicit owner authorization.

### AMB-1181 / AMB-1200

2026-06-24 risk-register import reviewed. This is an evidence import only. It does not create a third control plane and does not replace `docs/qa/KNOWN_ISSUES.md`. Canonical updates are limited to strengthened existing rows, new `AMB-ISSUE-2001` through `AMB-ISSUE-2012`, proposal-only `AMB-ISSUE-2013`, and supplemental SCG mapping. Status ceiling remains Red/Yellow: source repair is not runtime proof, simulator proof is not device proof, visual proof is not owner acceptance, and governance Green is not product Green.

### AMB-1199 / AMB-1190

Risk import adds CR-P0-018 and related proof-gap evidence. Keep non-Done. No Runtime Green, Visual Green, Accessibility Green, Release Green, or owner acceptance is unlocked. Missing proof remains device, Light/System, Capture/Search, full drilldown, manual accessibility, privacy/security/account/R2 boundary, and owner review.

### AMB-1192 / AMB-1183

Risk import adds Capture evidence CR-P0-006, CR-P0-007, and CR-P0-008. Existing Capture rows now also require external intake queue no-data-loss proof and direct-ID capture lookup proof. Keep status source-repaired/proof pending until full-screen composer, keyboard, offline save, proposal/receipt, external queue ack, and direct lookup proof exist.

### AMB-1195 / AMB-1186

Risk import adds CR-P0-005 and Today/closure mutation evidence. Existing Today/Closure rows now require restart-proof Today recompute, before/action/after mutation, proof/undo artifact IDs, and accessible state-change evidence. Keep status proof pending.

### AMB-1197 / AMB-1188

Risk import adds CR-P0-004 and Time durability/fake-mutation evidence. Existing Time rows now require durable-or-explicit-preview labeling, restart persistence, injected-clock regression coverage, Today recompute, undo proof, and permission-denied fallback proof. Keep status proof pending.

### AMB-1194 / AMB-1185

Risk import adds CR-P0-016 plus external route-depth/stale snapshot implications. Existing shell rows now require root/drilldown/overlay screenshot matrix, route-depth safe-area proof, no duplicate chrome, no root Motion, and no stale external-state display. Keep visual proof capped.

### AMB-1193 / AMB-1184

Risk import adds CR-P1-023 and CR-P1-030. Existing Goals rows now require graph invariant proof, persistence reload, Today feed coupling, area detail, goal detail, creation no-crash, and step-chain proof. Keep runtime/device proof pending.

### AMB-1198 / AMB-1189

Risk import adds CR-P1-031 and CR-P2-044. Existing You rows now require account/R2/settings clarity, actionable rows or honest unavailable states, detail route proof, no unsupported sync/account claims, and device proof.

### AMB-1304

Risk import adds behavior-proof risks CR-P0-001, CR-P0-002, CR-P0-003, and CR-P2-055 to SCG-009C context. Tests must prove behavior, persistence, mutation, fallback, and undo, not file existence, source strings, or ceremonial gates.

### AMB-1295

Risk import adds persistence/import/export/security/local-auth risks CR-P0-015, CR-P0-019, CR-P1-021, and CR-P1-039 to SCG-012 context. Required proof includes store health, migration/rollback, corruption quarantine, privacy manifest review, and local-auth/file-protection proof.

### AMB-1294

Risk import adds accessibility/privacy-trust proof risks CR-P1-037 and CR-P0-019 to SCG-011 context. Automated contracts are not manual/device accessibility proof. Manual VoiceOver, Dynamic Type, Reduce Motion/Transparency, Increase Contrast, and privacy-trust proof remain required.

### AMB-1178

Risk import adds CR-P0-009, CR-P0-010, CR-P0-012, and CR-P0-020 as account/R2/local-first boundary evidence. Offline core, no private graph egress, request-shape proof, account entitlement copy, and Source Atlas/R2 public-only proof remain required.

### AMB-632

Risk import adds CR-P0-011 CloudKit sync engine launch-gate evidence. Keep CloudKit claims capped until schema, zones, stable IDs, tombstones, conflicts, retry/backoff, migration, and multi-device proof exist.

### AMB-1097 / AMB-1034 / AMB-1093

Risk import adds CR-P0-007, CR-P0-014, and CR-P1-035 external intake/deep-link command-safety evidence. Required proof includes append-only queue, command normalization, target validation, stale/account-safe snapshot behavior, and safe failure UI.

## Rollback

Revert the docs-only integration commit. Remove only:

- `docs/qa/risk-register-imports/2026-06-24-risk-register-synthesis.md`
- `docs/qa/risk-register-imports/2026-06-24-risk-register-synthesis.json`
- `docs/quality/senior-review/risk-imports/2026-06-24-root-cause-risk-map.json`
- approved edits to `docs/qa/KNOWN_ISSUES.md`
- approved edits to `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`

No production rollback is needed because this pass does not touch production app code.
