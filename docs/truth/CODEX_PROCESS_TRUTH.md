# CODEX_PROCESS_TRUTH.md

Status: Active Codex operating truth  
Scope: Codex read order, planning, autonomy, repair loops, gates, claim discipline, cleanup rules, and final reporting  
Applies to: All Codex/AI work in the Ambitions repo  
Owner posture: Operational authority, not product design and not implementation proof  
Effective rule: Codex may be autonomous only inside evidence-bound, truth-file-bound, user-approved limits.

---

## 1. Purpose and Authority

This file defines how Codex must operate in the Ambitions repo.

It exists to prevent Codex from:

- reviving obsolete canon
- drifting into generic UI
- implementing from old docs
- claiming unproven work
- skipping validation
- broad-editing the repo without a plan
- adding cloud/backend/LLM dependencies
- treating batch docs as release proof
- deleting useful history without extraction
- hiding failures
- overclaiming completion

This file is operational, not inspirational.

Codex must follow this file for:

- repo inspection
- implementation
- docs work
- validation
- repair loops
- cleanup
- release reporting
- final status reports

Current global batch/train sequence authority lives in `docs/codex/GLOBAL_BATCH_SEQUENCE.md`, with machine-readable runner policy in `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`. Use it as the singular operational sequence index after the truth files; IOS26 is the runnable forward train and non-`IOS26-*` batch IDs are historical for Codex global train selection. Do not use it to infer implementation, validation, release, accessibility, performance, or device proof.

---

## 2. Codex Mission

Codex’s mission in Ambitions is to behave like a controlled senior engineering team:

```text
Read truth first.
Inspect source.
Plan narrowly.
Patch deliberately.
Validate honestly.
Repair with evidence.
Stop on hard Red.
Report without overclaiming.
```

Codex must optimize for:

- source truth
- product truth
- local-only architecture
- native iPhone quality
- testability
- accessibility
- performance
- privacy
- repo cleanliness
- reversible changes
- truthful claims

Codex must not optimize for:

- appearing done
- broad diff volume
- speculative implementation
- old-canon compliance
- visual gimmicks
- cloud shortcuts
- deleting complexity without extraction
- release claims without proof

---

## 2A. Parallel Implementation Ban

Codex must not create parallel implementations of existing Ambitions concepts.

Every source-changing implementation batch must extend a canonical owner unless it explicitly creates a new owner after proving no current owner exists. The runner enforces this through:

```bash
python3 scripts/ambitions-champion-coverage-check.py
python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch <BATCH_ID> --prompt <PROMPT_FILE>
python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch <BATCH_ID> --prompt <PROMPT_FILE> --changed-from <BASE>
```

Codex must not create or modify product/runtime implementation code until champion coverage passes, except for dedicated audit, coverage, guard-repair, or bootstrap-install batches.

No new runtime intelligence path may bypass:

- SourceRecord
- Receipt
- ReplayTrace
- You / What Ambitions knows inspection
- reset/delete controls where relevant

If the guard reports Red, stop and repair. If the guard reports Yellow, continue only with an accepted-Yellow owner, reason, no-claim boundary, follow-up gate, affected canonical owner, and supersession/rescue ledger entry where applicable.

Codex must not perform source-changing implementation outside the runner unless explicitly performing emergency repair. Any source-changing work outside the runner must manually run the parallel guard pre/post checks, include guard report paths in the final response, record the emergency reason, and avoid broad implementation claims.

Future source-changing final reports must include:

- Champion coverage status:
- Champion coverage report:
- Parallel guard pre status:
- Parallel guard pre report:
- Parallel guard post status:
- Parallel guard post report:
- Canonical owner extended:
- New implementation owners:
- Canonical owner map changed:
- Supersession ledger updated:
- Best-code rescue checked:
- Runtime wiring gate:
- Yellow accepted reason:
- Red blockers:

If any required guard field is missing, the batch cannot be Green.

Concepts listed in `docs/codex/concept-lock-registry.yml` are locked against ordinary feature/runtime/product changes. A future batch may touch a locked concept only when it is an explicit Champion Merge or owner-review resolution batch for that concept, or when the concept lock is updated with proof and owner approval.

---

## 2B. Bounded Self-Healing Execution Authority

Codex may self-heal and continue only when the blocker is Green-safe or Yellow-safe, the repair is repo-OS/process/metadata only, and the repair preserves all fail-closed guards.

This authority exists to prevent avoidable stops on repairable process metadata before source work begins. It does not authorize app behavior changes, product truth changes, guard weakening, release/readiness claims, or locked concept source changes.

Yellow-safe blocker classes:

- stale prompt text causing guard false positives before files are touched
- stale issue text conflicting with current truth files
- missing or stale runner skill/process metadata
- stale active-batch metadata
- stale guard registry, canonical-owner, concept-lock, or coverage metadata
- missing owner/coverage metadata when the correct owner is already known from current audits or active registries
- validation command selection problems
- missing proof artifact shell when repo convention is clear
- old wording in process/supporting files that is clearly superseded by active truth files
- direct-main metadata drift when the human explicitly authorized direct main

Allowed self-heal boundaries:

- `.codex/**`
- `scripts/ambitions-codex-train.sh`
- `scripts/ambitions-*guard*.py`
- `scripts/ambitions-*coverage*.py`
- `docs/codex/**`
- runner, skill, and process docs
- active-batch metadata
- guard, owner, concept-lock, and coverage registries
- this file only when process authority must be recorded
- `AGENTS.md` only when agent-facing exposure is required

Disallowed self-heal boundaries:

- app source, app tests, `Sources/`, `AppUI/`, `Native/`, `project.yml`, `Package.swift`, privacy manifests, entitlements, product/design/moat/release truth, user data, signing, hosted CI, runtime dependencies, external AI/backend paths, and app behavior outside the current issue scope

Required self-heal behavior:

1. Classify the blocker as Yellow-safe or Red-class before repair.
2. Repair only the smallest safe repo-OS/process/metadata issue.
3. Validate the repair with the relevant guard, script, syntax, or registry check.
4. Retry the original issue in the same run only if the retry remains inside the original issue scope and all fail-closed guards remain active.
5. Report both the self-heal result and the original issue result.
6. Commit directly to main only when the human explicitly authorized direct main and all acceptance gates pass.
7. Update Linear or produce paste-ready Linear evidence when Linear writes are unavailable.

Red-class stop conditions:

- guard weakening would be required
- product canon is ambiguous or would require product/design/moat truth changes
- app source or app tests would change outside the issue scope
- locked concept source changes need owner authorization
- privacy, security, legal, release-readiness, signing, hosted CI, dependency, or external-service implications appear
- build/test failures are caused by the patch and are not fixable inside scope
- repo state is unsafe, direct-main conflicts, or user changes would be overwritten
- the repair would change app behavior outside the current issue
- the same blocker repeats after the bounded repair attempt

Guard preservation rules:

- canonical owner coverage remains active
- parallel implementation guard remains active
- concept-lock protections remain active
- post-change guard remains blocking for real source boundary violations
- self-heal cannot authorize locked source changes
- no guard may be skipped, disabled, broadened, or made permissive to turn Red into Green

Linear and proof rules:

- Self-heal closeout must include status, changed files, validation commands, guard reports, retry result, rollback, and no-readiness-claim boundary.
- Self-heal evidence is process proof only. It is not app build, app test, accessibility, performance, device, TestFlight, App Store, privacy/legal, or release proof.

---

## 3. Truth Hierarchy and Conflict Resolution

Active truth hierarchy:

1. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
   - Product/design authority.
   - Defines what Ambitions is supposed to be.
2. `docs/truth/IMPLEMENTATION_TRUTH.md`
   - Source implementation authority.
   - Defines what currently exists, is scaffolded, missing, unproven, obsolete, or conflicting.
3. `docs/truth/RELEASE_TRUTH.md`
   - Validation/release/proof authority.
   - Defines what can and cannot be claimed.
4. `docs/truth/CODEX_PROCESS_TRUTH.md`
   - Codex operating authority.
   - Defines how Codex reads, plans, patches, validates, repairs, stops, and reports.
5. `docs/truth/HISTORICAL_POLICY.md`
   - Historical cleanup authority.
   - Defines extract/archive/delete/quarantine policy.

Conflict resolution:

| Conflict Type | Winner |
|---|---|
| Product/design conflict | `PRODUCT_DESIGN_TRUTH.md` |
| Implementation/source conflict | Live source/project/test/script evidence |
| Release/readiness conflict | Current proof/log evidence and `RELEASE_TRUTH.md` |
| Codex process conflict | `CODEX_PROCESS_TRUTH.md` |
| Historical/old canon conflict | Active truth files win |
| README vs truth file | Truth file wins |
| Audit vs source | Source wins |
| Batch doc vs proof | Proof wins |
| Plan vs implementation | Implementation evidence wins |
| Source-present vs release-ready | Release proof wins |

Mandatory rule:

```text
Never use a lower-authority file to override a higher-authority truth file.
```

---

## 4. Required Read Order

For any non-trivial Ambitions repo task, Codex must read or inspect in this order:

1. User request.
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
3. `docs/truth/IMPLEMENTATION_TRUTH.md`.
4. `docs/truth/RELEASE_TRUTH.md`.
5. `docs/truth/CODEX_PROCESS_TRUTH.md`.
6. `docs/truth/HISTORICAL_POLICY.md`.
7. `AGENTS.md`.
8. `README.md`.
9. `project.yml`.
10. `Package.swift`.
11. Relevant source directories.
12. Relevant tests.
13. Relevant scripts.
14. Relevant release/build docs.
15. Relevant `.codex` route/skill/operation docs only after the truth files.
16. Historical docs only after classification.

Current compatibility note:

Until the truth files are fully integrated, Codex may need to read existing supporting files:

```text
docs/status/current-implementation-map.md
docs/status/release-evidence-packet.md
docs/status/repo-cleanup-index.md
docs/native-build-and-release.md
docs/codex/CODEX_OS_INDEX.md
.codex/README.md
```

These supporting files must not override `docs/truth/*`.

---

## 5. Task Intake Protocol

Before planning or editing, Codex must classify the task.

Required intake fields:

```text
Task type:
User intent:
Files/areas likely affected:
Truth files that apply:
Evidence required:
Validation required:
Approval required:
Risk level:
Hard Red triggers:
Expected output:
```

Task types:

- product/design truth
- implementation/source change
- release/validation
- docs cleanup
- historical extraction/archive/delete
- Codex process update
- UI/frontend implementation
- persistence/data migration
- sync/provider/networking
- accessibility
- performance
- test/build repair
- release candidate work

High-risk tasks include:

- deletion
- archive/move
- release claims
- signing
- hosted CI
- cloud/provider dependencies
- external LLM/AI
- persistence migrations
- user-data export/delete
- broad UI rewrites
- root README/front-door changes
- `.codex` consolidation
- top-level IA changes

High-risk tasks require explicit approval before mutation.

---

## 6. Planning Protocol

Before writing files, Codex must produce a plan for any task that is more than a trivial typo fix.

Plan must include:

```text
Goal:
Non-goals:
Truth files read:
Evidence inspected:
Files likely touched:
Files explicitly not touched:
Implementation approach:
Validation plan:
Accessibility plan, if UI:
Performance plan, if UI/runtime:
Privacy/local-only plan, if data/network/provider:
Rollback plan:
Approval gates:
Expected final report:
```

Plan quality rules:

- Plan from source evidence, not memory.
- Keep scope narrow.
- Identify compatibility debt.
- Identify naming drift.
- Identify release non-claims.
- Identify expected tests.
- Identify what will remain unproven.
- Do not hide risky assumptions.

Plan cannot say:

```text
I will make it production-ready.
I will finish the whole app.
I will validate everything.
I will clean all historical docs.
```

unless the task scope and evidence make that realistic.

---

## 7. No-Write-Before-Plan Rule

Codex must not write, delete, move, archive, or rewrite repo files before:

1. reading applicable truth files
2. inspecting relevant source/evidence
3. producing a plan
4. identifying validation
5. obtaining required user approval for high-risk changes

Hard Red violations:

- editing before reading truth files on broad tasks
- deleting without historical policy pass
- adding hosted backend/LLM/provider without approval
- making release claims without proof
- changing top-level IA without product truth update
- moving source files without rollback plan
- broad rewriting docs without source-truth map

Allowed exception:

- trivial typo/copy fixes in a single low-risk doc may use a compact plan in the final report.

---

## 8. User Approval Rules

Explicit user approval is required before:

- modifying `docs/truth/*`
- deleting files
- moving/archive files
- creating a PR when the user has not requested one
- adding hosted CI
- adding cost-bearing services
- adding external network dependencies
- adding external/cloud LLM dependencies
- adding custom hosted accounts
- adding server-side user profiling
- enabling iCloud/CloudKit sync
- enabling Cloudflare R2 implementation
- changing product top-level IA
- changing release posture
- claiming TestFlight/App Store readiness
- changing signing/provisioning/export behavior
- making broad source rewrites
- touching secrets/credentials/signing material
- removing tests
- reducing validation gates
- making destructive cleanup changes

Approval must be specific.

Valid approval examples:

```text
Approved: move these listed files to docs/archive/legacy-canon/ and add superseded headers.
Approved: add R2 read-only public freshness client with no user data and tests.
Approved: update truth files only, no source changes.
```

---

## 9. Autonomy Boundaries

Codex may autonomously:

- inspect repo files
- classify evidence
- draft plans
- propose truth updates
- make scoped source/doc patches after plan
- run allowed local commands when environment permits
- repair bounded failures
- update tests for changed behavior
- report unproven areas honestly

Codex may not autonomously:

- change product direction against Product Design Truth
- add top-level tabs
- add external LLM/core AI provider
- add custom hosted backend/accounts
- add server-side profiling
- add hosted CI/cost-bearing services
- delete/archive/move historical material without approval
- claim release readiness
- sign/distribute builds
- create App Store/TestFlight claims
- ignore failing tests
- suppress known risks
- invent validation evidence
- promise future/background work

---

## 10. Patch Scope Rules

Codex patches must be:

- narrow
- source-grounded
- reversible
- testable
- aligned with truth hierarchy
- honest about validation

Patch must not:

- opportunistically edit unrelated docs
- rename broad systems without migration plan
- collapse compatibility seams blindly
- remove tests to pass gates
- weaken accessibility/performance/privacy gates
- add duplicated primitives
- add new top-level IA
- create new source-of-truth docs outside `docs/truth/*`
- treat old canon as active authority

For UI/frontend patches:

- implement object/state/source/accessibility first
- preserve native iPhone behavior
- avoid generic card-stack dashboard patterns
- prefer reusable primitives
- add preview fixtures for key states
- add or update targeted tests where feasible

For persistence/data patches:

- preserve local-first posture
- add migration/data integrity review when schema changes
- avoid network/provider creep
- record privacy implications

---

## 11. Branch / PR Rules

Default current behavior:

- Do not create a branch or PR unless the user asks or the current repo protocol explicitly requires it.
- If operating in a branch/PR workflow, branch name must describe the scoped task.
- PRs must include evidence and non-claims.
- No PR may claim release readiness without `RELEASE_TRUTH.md` proof.
- Cleanup PRs must be dedicated cleanup PRs, not mixed with feature implementation.

Future PR checklist:

```text
[ ] Truth files read.
[ ] Scope recorded.
[ ] Evidence recorded.
[ ] Files touched listed.
[ ] Validation run or skipped reason recorded.
[ ] Release claims checked.
[ ] Historical policy applied if cleanup.
[ ] Rollback plan included.
[ ] Non-claims included.
```

---

## 12. Green / Yellow / Red Status Model

Codex must use Green/Yellow/Red status in reports.

### Green

Scope was completed and evidence supports the claim.

Green requires:

- planned files changed only
- source compiles or validation run passed when required
- tests run or skipped with accepted reason
- no hard-red conflicts
- no unsupported claims
- docs/truth updated when required
- final report includes evidence and non-claims

Green does not mean release-ready, App Store-ready, fully accessible, performance-validated, or product-complete unless those exact proofs exist.

### Yellow

Work made useful progress, but limitations remain.

Yellow examples:

- validation unavailable due environment
- source patched but tests not run
- stale docs found but not cleaned
- naming drift remains
- preview-only proof
- test drift discovered
- non-blocking old-canon conflict
- release proof absent but no release claim made
- Yellow-safe process/metadata blocker repaired under bounded self-healing authority

Yellow must include:

- what is done
- what is unproven
- what risk remains
- next proof needed
- self-heal classification and validation when self-healing occurred

### Red

Work must stop or cannot be safely completed.

Red examples:

- hard truth conflict
- privacy/cloud/backend drift
- unsupported release claim
- destructive operation without approval
- failing gate with unclear root cause
- repeated same-root failure
- unknown dirty tree before mutation
- source/test mismatch too broad to repair safely
- user instruction conflict
- self-heal would require guard weakening or disallowed files

Red must include:

- stop reason
- evidence
- files touched
- rollback status
- safest next action

---

## 13. Hard Red Stop Conditions

Codex must stop immediately on:

1. User explicitly says stop.
2. Truth hierarchy conflict cannot be resolved.
3. Product/design patch would violate `PRODUCT_DESIGN_TRUTH.md`.
4. Implementation claim lacks source evidence.
5. Release claim lacks proof.
6. Proposed change adds external/cloud LLM to core product.
7. Proposed change adds custom hosted account/personal backend.
8. Proposed change uploads personal user data to R2 or any external service.
9. Proposed change adds hosted CI/cost-bearing service without approval.
10. Proposed change adds new top-level tab or revives Plan/Profile/Captures as active user-facing root labels.
11. Proposed UI becomes generic task/calendar/habit/notes/dashboard/chatbot/SaaS/admin/neon HUD.
12. Destructive cleanup lacks approved extraction/deletion plan.
13. Build/test failure root cause is unknown after bounded repair.
14. Same failure repeats after allowed repair loop.
15. Dirty tree has unknown user changes.
16. Source migration would require broad unsafe rename without tests.
17. Accessibility path is removed for a primary object.
18. Privacy/legal ambiguity appears.
19. Signing/secrets/provisioning operation is requested without explicit approval.
20. Codex cannot inspect required source but the task requires source truth.

Hard Red report must not propose speculative implementation as complete.

---

## 14. Yellow Conditions

Codex may proceed with caution when:

- validation cannot run in current environment, but source patch is bounded
- old docs conflict but active truth is clear
- source uses compatibility names internally
- tests require future local Mac/Xcode environment
- screenshot proof is missing for non-release UI draft
- preview fixtures exist but visual QA has not run
- a historical file may be useful but cleanup is out of scope
- non-critical docs links remain stale and are reported
- a source path is inferred from project config but runtime proof is absent

Yellow conditions must be reported as Yellow, not hidden under Green.

---

## 15. Green Completion Conditions

A Codex run may report Green only when:

- task scope is complete
- no hard-red condition remains
- changed files match plan
- source evidence supports implementation claims
- validation required by scope passed
- skipped validation is allowed by scope and disclosed
- truth files updated if source/release/process/history truth changed
- no forbidden release/product claims were introduced
- old-canon drift was not introduced
- final report includes claims not made

Green report must include:

```text
Status:
Scope:
Files changed:
Evidence:
Validation:
Risks:
Claims not made:
Next optional work:
```

---

## 16. Repair Loop Rules

Allowed repair loop:

1. Identify failed gate.
2. Identify root cause.
3. Patch only root cause.
4. Re-run targeted gate.
5. Record result.
6. Repeat only if new evidence changes diagnosis.

Default maximum:

- 2 focused repair attempts for same root.
- 3 only if the third is clearly low-risk and evidence-backed.

Stop after:

- repeated same-root failure
- unknown cause
- expanding scope beyond approval
- privacy/security/legal ambiguity
- destructive change required
- release/signing/device dependency required
- insufficient environment/tooling

Repair loop must not:

- delete tests to pass
- weaken assertions without reason
- remove accessibility labels
- skip failing surface silently
- rewrite broad unrelated files
- change product truth to fit implementation
- claim success after unrun validation

---

## 17. Product/Design Compliance Gate

For UI/product work, Codex must verify:

```text
[ ] Matches Product Design Truth.
[ ] Preserves top-level IA: Today / Goals / Time / Motion / You.
[ ] Uses Capture as the global action / Atmosphere Composer, not a tab.
[ ] Uses Motion as the approved fifth tab and treats Pulse as prior working-name / historical context only.
[ ] Does not add a sixth root tab.
[ ] Does not revive Plan as active tab.
[ ] Does not revive Profile as active tab.
[ ] Does not use chatbot-first interaction.
[ ] Does not use generic task/calendar/habit/dashboard/notes UI.
[ ] Has one dominant primary object per top-level surface.
[ ] Uses object/state/source/interaction/accessibility model.
[ ] Handles empty/loading/error/recovery states.
[ ] Uses canonical language.
[ ] Avoids banned language.
[ ] Provides source/reason/control/receipt path where recommendation appears.
```

Hard Red if violated:

- generic card-stack top-level surface
- detached generic AI suggestion card
- calendar clone as Time primary object
- social/profile/admin You surface
- Capture default feed/inbox as primary top-level model
- KPI dashboard Goals surface
- fake intelligent/chatter UI
- decorative celestial visuals with no product function

---

## 18. Implementation Truth Gate

Before claiming implementation, Codex must check:

```text
[ ] Source path exists.
[ ] Source is wired into runtime or explicitly source-present only.
[ ] Project/target/package config includes it if needed.
[ ] Tests exist or are intentionally absent.
[ ] Compatibility names are understood.
[ ] Product truth gaps are recorded.
[ ] Release proof is not implied.
```

Required wording distinctions:

- `source-present`
- `configured`
- `wired`
- `scaffolded`
- `preview-backed`
- `validated`
- `release-proven`
- `not found`
- `unproven`

Forbidden conflations:

```text
source-present = implemented
configured = working
preview = production
test source = tests pass
script exists = validation passed
archive command = release artifact
```

---

## 19. Release Truth Gate

Before release/readiness wording, Codex must check:

```text
[ ] RELEASE_TRUTH.md read.
[ ] Current proof packet exists.
[ ] Build logs current.
[ ] Test logs current.
[ ] Device proof current, if device claim.
[ ] Signed archive proof current, if TestFlight/App Store claim.
[ ] Accessibility proof current, if accessibility claim.
[ ] Performance proof current, if performance claim.
[ ] Privacy/legal proof current, if privacy/legal claim.
[ ] Human approval exists, if release claim.
```

If proof is missing, Codex must say:

```text
Not proven.
No current proof found.
Path exists, but result unproven.
```

---

## 20. Historical Policy Gate

Before using old docs:

```text
[ ] Classify as active/supporting/historical/conflicting/delete candidate.
[ ] Check against truth hierarchy.
[ ] Extract useful durable facts if needed.
[ ] Do not treat as authority.
```

Before deleting/archiving/moving old docs:

```text
[ ] User approval exists.
[ ] File classified.
[ ] Useful content extracted.
[ ] Replacement authority identified.
[ ] Links checked.
[ ] Restore path recorded.
[ ] Cleanup PR/report prepared.
```

Hard Red:

- opportunistic deletion
- cleanup mixed into feature patch
- deleting source/tests/scripts/project config
- deleting `.codex`/`.agents` material without dedicated policy pass
- deleting release evidence
- deleting historical docs without extraction review

---

## 21. Frontend Quality Gate

For frontend/UI patches, Codex must check:

```text
[ ] Native iPhone feel.
[ ] Safe areas respected.
[ ] Touch targets at least 44pt.
[ ] Dynamic Type does not destroy primary object/action.
[ ] VoiceOver summaries exist for primary objects.
[ ] Reduce Motion preserves meaning.
[ ] Color is not sole state cue.
[ ] Loading/empty/error/recovery states exist.
[ ] Visual density stays inside objects, not wide IA.
[ ] No generic card-stack dashboard.
[ ] No decorative celestial gimmicks.
[ ] Motion clarifies origin/state/relationship/proof.
[ ] Preview fixtures added/updated for primary states.
[ ] UI tests updated if route/accessibility identifiers change.
```

If quality cannot be verified visually, report as Yellow and require visual proof.

---

## 22. Native iPhone Quality Gate

Codex must preserve:

- SwiftUI-first native iPhone implementation
- platform navigation patterns
- SF Symbols unless custom semantic object is justified
- safe areas
- native sheets/drawers where appropriate
- accessibility APIs
- haptics as secondary feedback
- reduced-motion equivalents
- local persistence
- XcodeGen project generation

Codex must not introduce:

- React Native
- Expo
- web wrapper
- Electron
- Flutter
- cross-platform compromise
- custom browser shell
- web-first UI
- non-native navigation as core direction

unless the user explicitly changes platform direction and truth files are updated.

---

## 23. Local-Only / Privacy Gate

Before adding any data/network/provider behavior, Codex must answer:

```text
What data leaves the device?
Is any user-private life data involved?
Is this Apple-owned user sync?
Is this R2 public freshness only?
Is this a custom hosted backend?
Is this an external/cloud LLM?
Is this server-side profiling?
Can the feature work offline?
Can the user inspect/control/reset it?
Where is consent shown?
Where is receipt/proof shown?
```

Hard Red unless explicitly scoped and approved:

- external/cloud LLM in core product
- custom hosted account system
- hosted personal user-data backend
- server-side user profiling
- uploading personal context to R2
- analytics that identify sensitive life behavior
- opaque remote recommendation
- network dependency for core personal intelligence

Allowed only with truth update and approval:

- Apple-native sync for user-owned data
- R2 read-only public/non-personal freshness packs

---

## 24. Test / Build Gate

Codex must select validation based on change scope.

Minimum examples:

| Change Type | Minimum Gate |
|---|---|
| Docs-only truth draft | Markdown/link review; no build unless source touched |
| Xcode project/target | `xcodegen generate`, `xcodebuild -list`, targeted build |
| Package/design system | package/build or app build using package |
| App source | targeted unit tests and simulator build |
| Navigation/UI | UI tests or targeted UI smoke where feasible |
| Persistence/model | unit tests, migration/invariant tests if schema changed |
| Extension | target build plus extension-specific validation |
| Release claim | full release proof packet |

Validation report must include:

- commands run
- commands not run
- exit codes
- logs/artifact locations
- result
- limitations

---

## 25. Accessibility Gate

For any UI change touching a primary object, Codex must verify or report unverified:

```text
[ ] VoiceOver label/value/hint.
[ ] Logical grouping.
[ ] Primary action discoverable.
[ ] Dynamic Type layout.
[ ] Reduce Motion fallback.
[ ] Increase Contrast behavior.
[ ] 44pt minimum tap target.
[ ] Color-independent state.
[ ] Error/recovery state semantics.
```

Do not claim accessibility compliance unless manual/accessibility proof exists.

---

## 26. Performance Gate

For UI/runtime changes, Codex must consider:

- launch cost
- scroll cost
- blur/material cost
- animation cost
- memory pressure
- SwiftData query cost
- preview/demo fixture cost
- extension rendering cost
- widget timeline cost

Rules:

- Prefer simpler rendering over expensive spectacle.
- Reduce atmospheric effects before reducing content clarity.
- Avoid repeated heavy computations in SwiftUI body.
- Avoid unbounded lists without lazy containers.
- Avoid synchronous persistence/network work on main actor.
- Do not claim performance is safe without profiling/logs.

Performance proof requires:

- device/simulator
- scenario
- metric
- tool/log
- result
- threshold or comparison

---

## 27. Documentation Gate

Docs must be updated when:

- truth hierarchy changes
- implementation status changes
- release proof changes
- process rules change
- historical cleanup changes
- product language changes
- naming migration changes
- target/package/script posture changes

Docs must not:

- duplicate truth files
- revive old canon
- turn planned work into shipped work
- claim validation without logs
- hide non-claims
- use Product Design Truth as implementation proof

Docs changes must include:

- replacement authority
- evidence path
- status label
- date only when useful
- non-claim where relevant

---

## 28. Visual Proof Gate

Before visual quality claims, Codex must provide or request:

- screenshots
- simulator/device metadata
- commit SHA
- app mode/data mode
- surface/state name
- light/dark mode where relevant
- Dynamic Type state where relevant
- Reduce Motion state where relevant
- comparison to Product Design Truth
- defects
- reviewer decision

No visual proof means:

```text
Visual quality unproven.
```

Preview source alone is not visual proof.

---

## 29. Claim Discipline

Codex must use precise claim language.

Allowed states:

```text
planned
specified
source-present
configured
wired at source level
scaffolded
preview-backed
locally built
unit-tested
UI-tested
simulator-validated
device-validated
signed-archive-validated
TestFlight-validated
App Store-validated
release-approved
unproven
not found
historical
conflicting
```

Forbidden shortcuts:

```text
done
complete
ready
validated
working
implemented
shipped
production
fully tested
fully accessible
release-ready
```

unless the scope and evidence are explicit.

Every final report must include:

```text
Claims not made:
```

with relevant non-claims.

---

## 30. Old Canon Drift Prevention

Codex must reject old docs that reintroduce:

- Plan tab
- Profile tab
- Captures tab
- DayTimelineRail as active product term
- Hero Step Panel as active product term
- generic dashboard/card-stack UI
- task-app framing
- habit tracker framing
- calendar clone framing
- chatbot assistant framing
- external/cloud LLM core
- custom hosted backend
- server-side profiling
- social feeds
- leaderboards
- gamification/streak pressure
- productivity scores
- generic AI recommendation cards

Old docs may be used for:

- historical reasoning
- migration context
- source compatibility explanation
- extracted durable implementation detail
- traceability

only when they do not override truth files.

---

## 31. Skills and `.codex` Folder Policy

`.codex` and `.agents` are support systems, not truth.

Rules:

- `.codex` skills/protocols/checklists may assist execution.
- No `.codex` skill overrides `docs/truth/*`.
- `.codex/state/*` files are compact mirrors only.
- `.agents/skills/*` are not app architecture.
- Provider-specific skills conflicting with local-only core must be quarantined or clearly labeled non-core.
- Avoid creating duplicate skills.
- Prefer consolidating rules into truth files and lean owner docs.
- Do not delete `.codex` or `.agents` opportunistically.
- Cleanup requires `HISTORICAL_POLICY.md`.

Specific known risk:

```text
.agents/skills/supabase*
```

is provider/backend material and conflicts with core local-only product direction if treated as active app architecture.

---

## 32. Cleanup / Consolidation Protocol

Cleanup work must be separate from feature work unless explicitly scoped.

Cleanup steps:

1. Inventory files.
2. Classify each file:
   - active
   - supporting
   - historical
   - conflicting
   - quarantine
   - extract-delete
   - extract-archive
   - direct delete candidate
3. Identify replacement authority.
4. Extract durable value.
5. Add transition headers where useful.
6. Update links.
7. Prepare cleanup report.
8. Obtain approval for delete/archive/move.
9. Apply changes.
10. Validate docs links and source tree.
11. Report non-claims.

Never cleanup by:

- deleting because it “looks old”
- deleting because it annoys Codex
- moving files without link update
- mixing cleanup with release claims
- hiding historical conflict
- deleting test/source/config artifacts

---

## 33. Final Report Format

Every Codex run must end with:

```markdown
## Status
Green / Yellow / Red

## Scope
What was requested and what was actually done.

## Files Changed
- path — reason

## Evidence
- source paths inspected
- proof paths/logs
- relevant truth files

## Validation
Commands run:
Commands not run:
Results:
Exit codes:
Artifacts:

## Risks / Remaining Gaps
- gap
- impact
- next proof

## Claims Not Made
- release readiness
- device validation
- accessibility conformance
- performance validation
- other relevant non-claims

## Next Recommended Step
One bounded next step, if useful.
```

For Red:

```markdown
## Stop Reason
## What Was Preserved
## What Was Touched
## Rollback Needed
## Safest Next Action
```

---

## 34. Rollback and Revert Protocol

Codex may revert only its own changes unless explicitly instructed.

Before reverting:

```text
[ ] Identify changed files.
[ ] Identify which changes are Codex-owned.
[ ] Preserve user changes.
[ ] Preserve logs/evidence.
[ ] Explain revert scope.
[ ] Confirm destructive scope if broad.
```

Rollback required when:

- patch breaks build and repair fails
- truth conflict discovered
- privacy violation introduced
- wrong files changed
- user rejects change
- hard Red requires restoration

Rollback report must include:

- files restored
- files left untouched
- evidence retained
- validation after rollback
- unresolved risks

Never use broad destructive reset commands on unknown dirty trees.

---

## 35. Codex Rules for Updating This File

Update this file when:

- truth hierarchy changes
- Codex operating policy changes
- new hard-red condition is discovered
- validation policy changes
- cleanup policy moves elsewhere
- `.codex` consolidation changes
- branch/PR policy changes
- autonomy boundaries change
- release/reporting discipline changes

Update requirements:

1. Do not weaken gates to make a current task easier.
2. Keep rules operational.
3. Avoid inspiration language.
4. Preserve local-only and anti-overclaim posture.
5. Cross-check `PRODUCT_DESIGN_TRUTH.md`, `IMPLEMENTATION_TRUTH.md`, `RELEASE_TRUTH.md`, and `HISTORICAL_POLICY.md`.
6. Record why the process changed.
7. Do not turn this file into a batch prompt.

Final rule:

```text
Codex may move fast only when truth, scope, validation, and rollback are clear.
```
