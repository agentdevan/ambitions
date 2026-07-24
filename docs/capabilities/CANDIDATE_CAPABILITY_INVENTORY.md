# Candidate Capability Inventory

> Non-normative discovery output. Inclusion is not canonization, approval,
> implementation readiness, or evidence that current code fulfills the promise.

The complete evidence-preserving inventory is stored in deterministic JSON
shards referenced by `candidate-capabilities.json` and `discovery-sources.json`.

## Discovery summary

- Owner-originated seeds: **8**
- Repository-derived candidate hints: **3165**
- Fingerprinted source files: **3217**
- Candidate shards: **7**
- Source fingerprint shards: **3**
- Configured source families: **14**

## Source-family coverage

| Source family | Status | Paths | Candidate hints | Blockers |
|---|---:|---:|---:|---:|
| `SRC-ADRS` | covered | 8 | 31 | 0 |
| `SRC-AUDITS` | covered | 117 | 306 | 0 |
| `SRC-CONSTITUTION` | covered | 3 | 30 | 0 |
| `SRC-DESIGN-CANON` | covered | 52 | 1150 | 0 |
| `SRC-HISTORICAL` | covered | 4 | 6 | 0 |
| `SRC-LINEAR-MIRRORS` | covered | 4 | 40 | 0 |
| `SRC-NORMATIVE-SPECS` | covered | 57 | 788 | 0 |
| `SRC-OWNER-SEEDS` | covered | 1 | 8 | 0 |
| `SRC-PLATFORM` | covered | 5 | 14 | 0 |
| `SRC-PRODUCTION` | covered | 1803 | 304 | 0 |
| `SRC-QA-REMEDIATION` | covered | 927 | 352 | 359 |
| `SRC-RESEARCH` | covered | 4 | 8 | 1 |
| `SRC-STANDARDS` | covered | 8 | 22 | 0 |
| `SRC-TESTS` | covered | 584 | 114 | 0 |

## Owner-originated seeds

### CAND-SEED-003 — Alternate Career Path Simulation

- Owner wording: Alternate career pathing simulation
- Authority: `owner_seed`
- Disposition: `preserve_for_repository_reconciliation`

### CAND-SEED-005 — Ambitions Native Search and Command

- Owner wording: Raycast-like Ambitions native search
- Authority: `owner_seed`
- Disposition: `preserve_for_repository_reconciliation`

### CAND-SEED-002 — Contextual Generative Goal Pathing

- Owner wording: Unique generative goal pathing based on personal context and learned behaviors
- Authority: `owner_seed`
- Disposition: `preserve_for_repository_reconciliation`

### CAND-SEED-006 — First-Class Appearance Studio

- Owner wording: First class appearance studio
- Authority: `owner_seed`
- Disposition: `preserve_for_repository_reconciliation`

### CAND-SEED-007 — First-Class Content Share Studio

- Owner wording: First class content share studio
- Authority: `owner_seed`
- Disposition: `preserve_for_repository_reconciliation`

### CAND-SEED-008 — Goal-Attached File Storage

- Owner wording: File storage attached to goals
- Authority: `owner_seed`
- Disposition: `preserve_for_repository_reconciliation`

### CAND-SEED-001 — Skill Transference

- Owner wording: Skill transference
- Authority: `owner_seed`
- Disposition: `preserve_for_repository_reconciliation`

### CAND-SEED-004 — Step Placement Reflow

- Owner wording: Step reflow upon new step placement
- Authority: `owner_seed`
- Disposition: `preserve_for_repository_reconciliation`

## Repository-derived candidate families

### SRC-ADRS

- Candidate hints: **31**
- Fingerprinted source files: **8**
- Representative sample:
  - Add/move/protect/delete placement | Time | Today/Search/Capture transfer — `docs/adr/ADR-2026-07-22-canonical-identity-ownership-projection.md:172`
  - Capability gating and tests — `docs/adr/ADR-2026-07-22-truth-mutation-and-global-authority.md:270`
  - Capability inventory and ownership — `docs/adr/ADR-2026-07-22-local-first-recovery-accessibility-platform.md:116`
  - Capture authority — `docs/adr/ADR-2026-07-22-truth-mutation-and-global-authority.md:168`
  - Capture Draft | Capture until transfer | Capture | Not canonical Search content | Capture — `docs/adr/ADR-2026-07-22-canonical-identity-ownership-projection.md:137`
  - Capture → owner | Typed owner-transfer envelope — `docs/adr/ADR-2026-07-22-canonical-identity-ownership-projection.md:157`
  - Commit Capture proposal | Destination owner | Capture transfers and awaits result — `docs/adr/ADR-2026-07-22-canonical-identity-ownership-projection.md:176`
  - Commit Search Act request | Destination owner | Search transfers and awaits result — `docs/adr/ADR-2026-07-22-canonical-identity-ownership-projection.md:177`
  - Create/edit/close/archive/restore Goal | Goals | Today/Search/Capture must transfer — `docs/adr/ADR-2026-07-22-canonical-identity-ownership-projection.md:170`
  - Current Evidence and Proof Ceiling — `docs/adr/ADR-2026-07-02-source-atlas-scope-freeze.md:288`
  - Edit Event/series/occurrence | Time and source adapter | Today/Search/Capture transfer — `docs/adr/ADR-2026-07-22-canonical-identity-ownership-projection.md:173`
  - Fuzzy Search consolidation without canonical linkage can merge distinct — `docs/adr/ADR-2026-07-22-canonical-identity-ownership-projection.md:221`

### SRC-AUDITS

- Candidate hints: **306**
- Fingerprinted source files: **117**
- Representative sample:
  - "command": "jq . docs/audits/amb-1764-search-find-act-inspect-acceptance.json", — `docs/audits/amb-1764-search-find-act-inspect-acceptance.json:131`
  - "command": "npx markdownlint-cli2 --no-globs docs/audits/amb-1764-search-find-act-inspect-acceptance.md", — `docs/audits/amb-1764-search-find-act-inspect-acceptance.json:135`
  - "command": "python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1764-search-find-act-inspect-acceptance.md docs/audits/am... — `docs/audits/amb-1764-search-find-act-inspect-acceptance.json:139`
  - "command": "scripts/no-unsupported-ai-claim-scan.sh docs/audits/amb-1764-search-find-act-inspect-acceptance.md docs/audits/amb-1764-searc... — `docs/audits/amb-1764-search-find-act-inspect-acceptance.json:175`
  - "command": "scripts/privacy-boundary-scan.sh docs/audits/amb-1764-search-find-act-inspect-acceptance.md docs/audits/amb-1764-search-find-... — `docs/audits/amb-1764-search-find-act-inspect-acceptance.json:179`
  - "command": "scripts/release-claim-safety-scan.sh docs/audits/amb-1764-search-find-act-inspect-acceptance.md docs/audits/amb-1764-search-f... — `docs/audits/amb-1764-search-find-act-inspect-acceptance.json:143`
  - "docs/audits/amb-1764-search-find-act-inspect-acceptance.json" — `docs/audits/amb-1764-search-find-act-inspect-acceptance.json:224`
  - "docs/audits/amb-1764-search-find-act-inspect-acceptance.json", — `docs/audits/amb-1771-search-functionality-repair-gate.json:21`
  - "docs/audits/amb-1764-search-find-act-inspect-acceptance.md", — `docs/audits/amb-1764-search-find-act-inspect-acceptance.json:223`
  - "docs/audits/amb-1764-search-find-act-inspect-acceptance.md", — `docs/audits/amb-1769-frontend-known-issue-mapping.json:23`
  - "docs/audits/amb-1764-search-find-act-inspect-acceptance.md", — `docs/audits/amb-1771-search-functionality-repair-gate.json:20`
  - "finding": "Search is unified Find / Act / Inspect and is not chatbot, shallow sheet, or generic text search." — `docs/audits/amb-1764-search-find-act-inspect-acceptance.json:22`

### SRC-CONSTITUTION

- Candidate hints: **30**
- Fingerprinted source files: **3**
- Representative sample:
  - "specifications/journeys/search-find-act-inspect.md", — `docs/canon/MANIFEST.toml:23`
  - "specifications/journeys/search-find-ask-act-inspect.md", — `docs/canon/MANIFEST.toml:24`
  - CONST-PROOF-EVIDENCE-001 — Executable evidence establishes behavior — `docs/canon/CONSTITUTION.md:876`
  - CONTROL-UNDO-RECOVERY-001 — Undo, rollback, and humane recovery — `docs/canon/CONSTITUTION.md:557`
  - External-only calendar items MUST NOT appear as Ambitions Events before user-approved import or link, but Time MUST preserve an explicit... — `docs/canon/CONSTITUTION.md:661`
  - LAW-IA-TRUST-001 — Contextual trust ownership — `docs/canon/CONSTITUTION.md:470`
  - LAW-SEARCH-PRIVATE-COMMAND-LAYER-001 — Private understanding and command layer — `docs/canon/CONSTITUTION.md:437`
  - Maintain one canonical local identity graph — `docs/canon/CONSTITUTION.md:622`
  - MISSION-CAPABILITIES-001 — Capability layers serve orchestration — `docs/canon/CONSTITUTION.md:220`
  - MISSION-CAPABILITY-MEANING-001 — Capability semantics — `docs/canon/CONSTITUTION.md:231`
  - MISSION-MOAT-CONTINUITY-001 — Continuity scope — `docs/canon/CONSTITUTION.md:354`
  - MISSION-REFLOW-001 — Schedule adaptation is core — `docs/canon/CONSTITUTION.md:253`

### SRC-DESIGN-CANON

- Candidate hints: **1150**
- Fingerprinted source files: **52**
- Representative sample:
  - "accessibility_focus": "VoiceOver announces that creation will continue in Capture, names the preserved intent, and moves focus to the Ca... — `docs/canon/migration/ux-blueprint.json:35533`
  - "behaviorauthorityrationale": "The Ask failure contract is owned by the exact Search command requirement and preserves deterministic resu... — `docs/canon/migration/ux-blueprint.json:34962`
  - "behaviorauthorityrationale": "The recovered Ask contract is owned by the exact Search command requirement and restores inspectable evide... — `docs/canon/migration/ux-blueprint.json:35197`
  - "behaviorauthorityrationale": "UX-STATE-VARIANT-TIME-DEGRADED-PARTIAL-IMPORT is governed by independently parsed requirement SPEC-SURFACE... — `docs/canon/migration/ux-blueprint.json:42241`
  - "behaviorauthorityrationale": "UX-STATE-VARIANT-TIME-IMPORT-COMMITTING-IMPORT is governed by independently parsed requirement JOURNEY-CAL... — `docs/canon/migration/ux-blueprint.json:44702`
  - "behaviorauthorityrationale": "UX-STATE-VARIANT-TIME-IMPORT-EXTERNAL-SOURCE-UNCHANGED is governed by independently parsed requirement JOU... — `docs/canon/migration/ux-blueprint.json:44815`
  - "behaviorauthorityrationale": "UX-STATE-VARIANT-TIME-IMPORT-EXTERNAL-WRITE-FAILURE is governed by independently parsed requirement JOURNE... — `docs/canon/migration/ux-blueprint.json:44926`
  - "behaviorauthorityrationale": "UX-STATE-VARIANT-TIME-IMPORT-IMPORT-FAILED is governed by independently parsed requirement JOURNEY-CALENDA... — `docs/canon/migration/ux-blueprint.json:45034`
  - "behaviorauthorityrationale": "UX-STATE-VARIANT-TIME-IMPORT-IMPORT-UNDO-UNAVAILABLE is governed by independently parsed requirement JOURN... — `docs/canon/migration/ux-blueprint.json:45188`
  - "behaviorauthorityrationale": "UX-STATE-VARIANT-TIME-IMPORT-NATIVE-IMPORT-UNDO is governed by independently parsed requirement JOURNEY-CA... — `docs/canon/migration/ux-blueprint.json:45301`
  - "behaviorauthorityrationale": "UX-STATE-VARIANT-TIME-IMPORT-PARTIAL-IMPORT is governed by independently parsed requirement JOURNEY-CALEND... — `docs/canon/migration/ux-blueprint.json:45465`
  - "behaviorauthorityrationale": "UX-STATE-VARIANT-TIME-IMPORT-RECONCILING is governed by independently parsed requirement JOURNEY-CALENDAR-... — `docs/canon/migration/ux-blueprint.json:45620`

### SRC-HISTORICAL

- Candidate hints: **6**
- Fingerprinted source files: **4**
- Representative sample:
  - Record skill transference, contextual generative goal pathing, alternate career-path simulation, step reflow, native search, Appearance S... — `docs/superpowers/plans/2026-07-24-capability-atlas-program.md:86`
  - Task 11: Install the Approved Canonical Capability Atlas — `docs/superpowers/plans/2026-07-24-capability-atlas-program.md:262`
  - Task 1: Install the Non-Normative Capability Program Foundation — `docs/superpowers/plans/2026-07-24-capability-atlas-program.md:64`
  - Task 2: Wire and test canon projection — `docs/superpowers/plans/2026-07-23-vc14-native-foundry-bootstrap.md:90`
  - Task 3: Create and validate the single repository-local skill — `docs/superpowers/plans/2026-07-23-vc14-native-foundry-bootstrap.md:137`
  - Task 4: Execute Phase B Capability Extraction — `docs/superpowers/plans/2026-07-24-capability-atlas-program.md:148`

### SRC-LINEAR-MIRRORS

- Candidate hints: **40**
- Fingerprinted source files: **4**
- Representative sample:
  - "app_aspect": "Time/capacity/reflow", — `docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json:365`
  - "currentrepoevidence": "App Intent search hits are present — `docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json:522`
  - "currentrepoevidence": "TimeEngine directory exists under LocalRuntimeOS and Time surface references time placement/reflow services.", — `docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json:369`
  - "currentrepoevidence": "Truth docs approve optional Ambitions Account — `docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json:743`
  - "lifedataboundary_risk": "High: raw capture payloads may contain any private life data.", — `docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json:391`
  - "lifedataboundary_risk": "High: raw capture text can contain the most sensitive private life data.", — `docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json:221`
  - "lifedataboundary_risk": "High: search indexes can concentrate private life graph content.", — `docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json:238`
  - "localfirstboundary": "Calendar assumptions, protected time, recovery, and capacity must remain local unless explicit external adapter ac... — `docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json:186`
  - "localfirstboundary": "Exports must be user-controlled and sanitized — `docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json:764`
  - "localfirstboundary": "Search index must remain local and derived from local projections.", — `docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json:237`
  - "localfirstboundary": "Today must compute usable Start here value from local projections without account or network.", — `docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json:152`
  - "missinglinearobject": "Codex leaves for Today runtime receipt, reflow, accessibility, and screenshot proof.", — `docs/linear/current-state/2026-07-01-linear-coverage-map.json:115`

### SRC-NORMATIVE-SPECS

- Candidate hints: **788**
- Fingerprinted source files: **57**
- Representative sample:
  - "global.search.find", — `docs/canon/specifications/global/search.md:17`
  - # Search Find Act Inspect — `docs/canon/specifications/journeys/search-find-act-inspect.md:15`
  - # Search Find Ask Act Inspect — `docs/canon/specifications/journeys/search-find-ask-act-inspect.md:15`
  - A Step is work the user can actually do. It is distinct from an Event commitment, Reminder notification intent, Note information, Schedul... — `docs/canon/specifications/objects/step.md:209`
  - A Today object row MUST expose object identity, relevant context and state, primary action, secondary controls, and nonvisual semantics w... — `docs/canon/specifications/surfaces/today.md:1036`
  - Accessibility_focus = "VoiceOver announces that creation will continue in Capture, names the preserved intent, and moves focus to the Cap... — `docs/canon/specifications/global/search.md:378`
  - After import, an external calendar item MUST become an Ambitions-native Event and MUST default to Fixed — `docs/canon/specifications/objects/event.md:82`
  - After several days of plan divergence, Ambitions MAY ask one necessary non-shaming question and MUST keep any response contextual, inspec... — `docs/canon/specifications/journeys/missed-work-recovery.md:38`
  - Alerts, schedule/reflow rule, time zone, transition buffers, and import-source — `docs/canon/specifications/surfaces/you.md:2423`
  - An External Calendar Candidate MUST NOT appear as an Ambitions Event before import — `docs/canon/specifications/journeys/external-calendar-import.md:1387`
  - An offline Capture MUST use the same local validation, confirmation, commit, Receipt, replay, and recovery path as online use — `docs/canon/specifications/journeys/capture-to-placement.md:66`
  - And user-entered intent preserved. Search MUST NOT duplicate Capture policy or — `docs/canon/specifications/global/search.md:1354`

### SRC-PLATFORM

- Candidate hints: **14**
- Fingerprinted source files: **5**
- Representative sample:
  - App Clips | Not relevant now | Capture must remain within core app unless future distribution strategy approves — `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md:1646`
  - App Intents | App Intents Documentation | https://developer.apple.com/documentation/appintents | System actions for Capture, Start Step,... — `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md:93`
  - Atoms are the closest match to the user's "building-block stockpile" idea. They are small enough to reuse across many goals and specific... — `docs/platform/SOURCE_ATLAS_FOUNDRY_BLUEPRINT.md:182`
  - Capture-specific interop — `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md:469`
  - Deterministic source-specific code that fetches, parses, normalizes, and emits typed records. An adapter must not emit private user conte... — `docs/platform/SOURCE_ATLAS_FOUNDRY_BLUEPRINT.md:123`
  - If a user leaves an astronaut, football, medicine, music, or civic path, Ambitions should preserve useful progress through shared atoms a... — `docs/platform/SOURCE_ATLAS_FOUNDRY_BLUEPRINT.md:312`
  - If Source Atlas is unavailable, Ambitions must still support local planning. It may use generic starter paths, ask clarifying questions,... — `docs/platform/SOURCE_ATLAS_FOUNDRY_BLUEPRINT.md:582`
  - No Hard-Coded Pathing Law — `docs/platform/SOURCE_ATLAS_FOUNDRY_BLUEPRINT.md:539`
  - Privacy manifest and App Store privacy — `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md:1109`
  - Privacy rules — `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md:711`
  - Proof and history — `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md:602`
  - Proof Boundary — `docs/platform/SOURCE_ATLAS_FOUNDRY_BLUEPRINT.md:584`

### SRC-PRODUCTION

- Candidate hints: **304**
- Fingerprinted source files: **1803**
- Representative sample:
  - "A person should review this source before Ambitions uses it to change a recommendation." — `Native/Ambitions/Trust/SourceInspectionModels.swift:52`
  - "Activated Capture should recover full-screen height after keyboard dismissal." — `Native/AmbitionsUITests/BootstrapShellUITests.swift:414`
  - "Ambitions can show this source as older context, but it should not silently change what you do next." — `Native/Ambitions/Trust/SourceInspectionModels.swift:40`
  - "Capture can keep the text local and wait for placement review instead of saving silently." — `Native/Ambitions/Surfaces/SurfaceLaw/FlagshipObjectStateMatrix.swift:93`
  - "Capture proposal must not expose classifier or holding-bin language: \(forbidden)" — `Native/AmbitionsUITests/CaptureComposerUITests.swift:111`
  - "Current step, Today pressure, protected time, capture entry, and recovery variants must remain snapshot-derived and privacy-bounded" — `Native/Ambitions/Support/ExternalSurfaceVerificationChecklist.swift:83`
  - "Goals can retry without changing the path, decisions, or proof." — `Native/Ambitions/Surfaces/SurfaceLaw/FlagshipObjectStateMatrix.swift:89`
  - "Interpretation: Learning goals should start with low-pressure signal.", — `Native/Ambitions/Scenarios/SurfaceScenarios/GoalsScenarios+Helpers.swift:194`
  - "Local search and MemoryLens source must be owned by Core/LocalRuntimeOS/Search." — `Native/AmbitionsTests/LocalRuntimeOS/Search/SearchTests.swift:33`
  - "Time stays contour-first with reviewed reflow and grounded time language." — `Native/Ambitions/Surfaces/SurfaceLaw/FlagshipObjectStateMatrix.swift:159`
  - "time.life-shape-field must exist before screenshot capture." — `Native/AmbitionsUITests/DeterministicScreenshotLaneUITests.swift:12`
  - "Today will not request Calendar permission or write calendar blocks. Open Time to make planning calendar-aware from there." — `Native/AmbitionsTests/App/CalendarReminderActionFlowTests.swift:138`

### SRC-QA-REMEDIATION

- Candidate hints: **352**
- Fingerprinted source files: **568**
- Representative sample:
  - "accessibility": "Accessibility-size Today uses materially larger type, full vertical reflow, the same information/order, no horizontal s... — `docs/qa/evidence/2026-07-14-canon-visual-owner-workshop/OWNER_REVIEW_PACKAGE.json:280`
  - "accessibility": "Accessibility-size Today uses materially larger type, numbered vertical reflow, the same information/order, no horizont... — `docs/qa/evidence/2026-07-14-canon-visual-owner-workshop/OWNER_REVIEW_PACKAGE.json:509`
  - "name": "Accessibility-size Today reflow", — `docs/qa/evidence/2026-07-14-canon-visual-owner-workshop/OWNER_REVIEW_PACKAGE.json:947`
  - "name": "Accessibility-size Today reflow", — `docs/qa/evidence/2026-07-14-canon-visual-owner-workshop/OWNER_REVIEW_PACKAGE.json:715`
  - "name": "Accessibility-size Today reflow", — `docs/qa/evidence/2026-07-14-canon-visual-owner-workshop/OWNER_REVIEW_PACKAGE.json:486`
  - "outcome": "Search Act prepares and transfers to the canonical owner for revalidation, confirmation, commit, and settlement.", — `docs/qa/frontend-flagship-shippability-remediation/rp-reconciliation-index.json:69`
  - "path": "docs/qa/evidence/2026-07-14-canon-visual-owner-workshop/screens/direction-a-quiet-spatial-stage/12-accessibility-today-reflow.png", — `docs/qa/evidence/2026-07-14-canon-visual-owner-workshop/OWNER_REVIEW_PACKAGE.json:490`
  - "path": "docs/qa/evidence/2026-07-14-canon-visual-owner-workshop/screens/direction-b-editorial-native/12-accessibility-today-reflow.png", — `docs/qa/evidence/2026-07-14-canon-visual-owner-workshop/OWNER_REVIEW_PACKAGE.json:719`
  - "path": "docs/qa/evidence/2026-07-14-canon-visual-owner-workshop/screens/direction-c-atmospheric-temporal-field/12-accessibility-today-re... — `docs/qa/evidence/2026-07-14-canon-visual-owner-workshop/OWNER_REVIEW_PACKAGE.json:951`
  - "requirement": "Capture accepted input must be durably journaled before classification, attachment staging, promotion, and restart lookup.", — `docs/qa/local-runtime-proof/current-local-runtime-proof.json:138`
  - "requirement": "Capture accepted input must be durably journaled before classification, attachment staging, promotion, and restart lookup.", — `docs/qa/local-runtime-proof/amb-1599-local-runtime-proof.json:138`
  - "requirement": "Command, event, projection, replay, search, and outbox integration points must be source-present.", — `docs/qa/local-runtime-proof/amb-1599-local-runtime-proof.json:38`

### SRC-RESEARCH

- Candidate hints: **8**
- Fingerprinted source files: **3**
- Representative sample:
  - Branch inspection projection — `docs/canon/references/research/cebr-01/CEBR-01_Codex_Design_Technical_Manual.md:173`
  - Changed-reality detection | Time reality reflow projection | Heuristic reason and local actions — `docs/canon/references/research/cebr-01/CEBR-01_Codex_Design_Technical_Manual.md:895`
  - End-to-end scenario — `docs/canon/references/research/cebr-01/CEBR-01_Codex_Design_Technical_Manual.md:803`
  - Events and Commands — `docs/canon/references/research/cebr-01/CEBR-01_Codex_Design_Technical_Manual.md:610`
  - Failure and recovery matrix — `docs/canon/references/research/cebr-01/CEBR-01_Codex_Design_Technical_Manual.md:663`
  - Privacy and authority — `docs/canon/references/research/cebr-01/CEBR-01_Codex_Design_Technical_Manual.md:643`
  - Recommendation policy — `docs/canon/references/research/cebr-01/CEBR-01_Codex_Design_Technical_Manual.md:161`
  - Recommendation policy — `docs/canon/references/research/cebr-01/CEBR-01_Codex_Design_Technical_Manual.md:557`

### SRC-STANDARDS

- Candidate hints: **22**
- Fingerprinted source files: **8**
- Representative sample:
  - A11Y-INPUT-EQUIVALENCE-001 — No gesture-only command — `docs/canon/standards/accessibility.md:105`
  - A11Y-PROOF-MATRIX-001 — Accessibility evidence matrix — `docs/canon/standards/accessibility.md:140`
  - Abuse-case proof — `docs/canon/standards/security-and-privacy.md:98`
  - Business policy MUST receive an injectable clock, calendar, locale, and time-zone context — `docs/canon/standards/native-ios-engineering.md:118`
  - Complete budget context — `docs/canon/standards/performance-and-energy.md:38`
  - CONCURRENCY-007 — Injected temporal context — `docs/canon/standards/native-ios-engineering.md:110`
  - CONCURRENCY-009 — Race proof — `docs/canon/standards/native-ios-engineering.md:138`
  - DETERMINISM-005 — Policy version capture — `docs/canon/standards/native-ios-engineering.md:190`
  - Deterministic privacy-safe fixtures — `docs/canon/standards/testing-and-fixtures.md:46`
  - Dismissal MUST preserve validated user intent, restore the originating context and focus, and never report an uncommitted action as durable — `docs/canon/standards/swiftui-and-design-system.md:368`
  - Each changed scope MUST execute the applicable domain, projection, UI, accessibility, migration, recurrence, time-zone, import, sync, and... — `docs/canon/standards/testing-and-fixtures.md:210`
  - Equivalent canonical inputs, policy version, user rules, temporal context, and seed MUST produce equivalent decisions independent of coll... — `docs/canon/standards/native-ios-engineering.md:156`

### SRC-TESTS

- Candidate hints: **114**
- Fingerprinted source files: **584**
- Representative sample:
  - "// Ambitions can provide contextual search commands without making code authoritative.\n", — `tools/tests/test_capability_atlas_discovery.py:93`
  - "// Ambitions can provide fake search capability from dependencies.\n", — `tools/tests/test_capability_atlas_discovery.py:97`
  - "\n\nAmbitions must help the person find goals, steps, attachments, and actions through private local search.\n", — `tools/tests/test_capability_atlas_discovery.py:89`
  - "Activated Capture should recover full-screen height after keyboard dismissal." — `Native/AmbitionsUITests/BootstrapShellUITests.swift:414`
  - "Capture proposal must not expose classifier or holding-bin language: \(forbidden)" — `Native/AmbitionsUITests/CaptureComposerUITests.swift:111`
  - "Local search and MemoryLens source must be owned by Core/LocalRuntimeOS/Search." — `Native/AmbitionsTests/LocalRuntimeOS/Search/SearchTests.swift:33`
  - "Native/Ambitions/App/AppRoot.swift": "import SwiftUI\nstruct AppRoot: View {}", — `scripts/tests/test_ambitions_source_disposition_audit.py:58`
  - "time.life-shape-field must exist before screenshot capture." — `Native/AmbitionsUITests/DeterministicScreenshotLaneUITests.swift:12`
  - "Today will not request Calendar permission or write calendar blocks. Open Time to make planning calendar-aware from there." — `Native/AmbitionsTests/App/CalendarReminderActionFlowTests.swift:138`
  - .appendingPathComponent("ambitions-calendar-p0-export-delete-\(scenario.id)") — `Native/AmbitionsTests/Domain/IOS26CalendarP0ContractHarnessTests.swift:765`
  - ApprovalSummary: "User approved the local reflow decision.", — `Native/AmbitionsTests/Domain/ProjectStepOperationModelsTests.swift:454`
  - ApprovalSummary: "User reviewed but did not approve the reflow decision.", — `Native/AmbitionsTests/Domain/ProjectStepOperationModelsTests.swift:467`

## Candidate shard manifest

- `docs/capabilities/candidates/repository-0001.json` — 500 candidates — SHA-256 `9a77d21cce5bfab1cc5d039088a3d5fc068477c69bd6a321323e2b836be388db`
- `docs/capabilities/candidates/repository-0002.json` — 500 candidates — SHA-256 `44720ae2abb9f4b9cc8ecda86c0d29f92b8bb439aee402da808c57e15f2630d7`
- `docs/capabilities/candidates/repository-0003.json` — 500 candidates — SHA-256 `8470eab7322955b493781d5d1f348595d1f93170c12e8f6be89805b827e3029c`
- `docs/capabilities/candidates/repository-0004.json` — 500 candidates — SHA-256 `e4070acae96b6f0ce79b6a8c7cebefe7e1df591a6ca6adf7ac11d87d5f03e7f5`
- `docs/capabilities/candidates/repository-0005.json` — 500 candidates — SHA-256 `b7539fa0133ac48f364b75f84cc7a8dd3d8cc62fae3d498cf1c5cbdf9a531802`
- `docs/capabilities/candidates/repository-0006.json` — 500 candidates — SHA-256 `a54b9df46dd3742520761e451d683ac71e77f9d3b859593b0e30c0ae0bdb91ae`
- `docs/capabilities/candidates/repository-0007.json` — 165 candidates — SHA-256 `7b64845424ad103e91a16a94979f3034fdec435b43f5575e570c3fec8de5edc8`

## Source fingerprint shard manifest

- `docs/capabilities/sources/source-files-0001.json` — 1500 files — SHA-256 `48fcaa688ba2f6a5261e624e44f1d667ea456b8bfe8d81721c0ace8d23bac0e9`
- `docs/capabilities/sources/source-files-0002.json` — 1500 files — SHA-256 `3f1f81de03df2780554f4941a5c10489d051cad922f7d10b4b4398bdf7a3ec70`
- `docs/capabilities/sources/source-files-0003.json` — 217 files — SHA-256 `c39cd56ce2d3e732f0c70ee2f272dca2ccd9400941e3b1bacdb2b1258694744a`
