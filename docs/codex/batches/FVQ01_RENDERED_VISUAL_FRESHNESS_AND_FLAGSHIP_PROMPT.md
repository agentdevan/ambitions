# FVQ01 Rendered Visual Freshness And Flagship Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Queued Codex prompt. Use when global order selects FVQ01 or when visual proof must be inserted after the currently running batch.
Date: 2026-05-05

```markdown
You are operating in the Ambitions repo as a FAANG-caliber iOS visual quality lead, Apple Design Award product reviewer, Staff SwiftUI architect, QA automation owner, accessibility reviewer, and Codex OS repair operator.

Mission:
Run FVQ01 — Rendered Visual Freshness And Flagship Gate.

This batch exists because the simulator Today view after FCP05/FCP07/FCP13A/FCP08 may still look prototype-like: large explanatory Reality Rail card, internal pills, muddy hierarchy, scaffold/proof language, and weak premium shell execution.

Do not dismiss this as taste.
Do not call contract implementation Green if rendered visual output is below bar.
Do not continue broad later trains while Today’s flagship surface visually fails.

============================================================
LIVE-STATE RULE
============================================================

The global train may be running when this prompt is inserted.

Before doing anything:

1. Pull latest remote.
2. Read current run-state.
3. Determine the latest completed batch.
4. Determine whether FCP09 is already complete or currently uncommitted.
5. Do not overwrite active uncommitted work.
6. If the worktree contains an active in-progress batch, finish/validate/commit that batch first if safe, then run FVQ01 immediately afterward.
7. If FCP09 is complete by the time this prompt runs, FVQ01 still runs before PFC13 or any later broad visual/platform strategy batch.

============================================================
PRIMARY SOURCE TRUTH
============================================================

Read:

1. README.md
2. AGENTS.md
3. docs/codex/visual-quality/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE.md
4. docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md
5. docs/canon/Ambitions_Found_Life_Layer.md
6. docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md
7. docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md
8. docs/codex/FOUND_LIFE_LAYER_GATE_MATRIX.md
9. docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
10. docs/codex/GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md
11. docs/audits/fcp05-start-here-surface-report.md
12. docs/audits/fcp07-reality-rail-continuity-report.md
13. docs/audits/fcp13a-action-closure-diamond-report.md
14. docs/audits/fcp08-ambition-meridian-shell-report.md
15. docs/audits/fcp09-motion-haptics-reduced-motion-proof-report.md if it exists
16. Native/Ambitions/App/AppMeridianShell.swift
17. Native/Ambitions/App/AppShellPresentationMode.swift
18. Native/Ambitions/Features/Today/
19. Native/Ambitions/PreviewSupport/ if screenshots/previews depend on fixtures
20. relevant CQS scripts and skills

============================================================
STARTUP COMMANDS
============================================================

Run:

```bash
git status --short
git branch --show-current
git rev-parse HEAD
git fetch origin
git rev-parse origin/main
git pull --ff-only origin main
```

If `git pull --ff-only` fails because another local batch is in progress:

- inspect the diff;
- preserve active batch work;
- do not discard human or Codex work;
- finish the active batch if recoverable;
- only stop on Hard Red.

============================================================
FRESHNESS PROOF REQUIREMENTS
============================================================

FVQ01 must prove the screenshot is from the current app build.

Record in `docs/audits/visual-evidence/fvq01/screenshot-freshness.json`:

- repo HEAD SHA
- origin/main SHA
- branch
- scheme
- build configuration
- simulator device
- simulator runtime
- build timestamp
- app version/build number if available
- app build SHA if available
- whether the app was freshly installed or reset
- command used to build
- command/tool used to capture screenshots

If the app does not expose build SHA, add the smallest safe debug/test-only freshness proof mechanism, such as:

- generated or static `BuildInfo` provider that tests can inspect;
- debug-only About/System row;
- launch log line;
- test-only accessibility identifier/value;
- screenshot sidecar metadata.

Do not expose secrets, signing identifiers, private user data, or sensitive device details.

If build SHA cannot be proven after repair attempt, classify FVQ01 at least Accepted Yellow and do not use screenshot evidence as final visual proof.

============================================================
CLEAN BUILD / FRESH INSTALL
============================================================

Use the strongest available local process:

```bash
xcodegen generate
scripts/build-local.sh
```

Then, using available simulator tooling:

- boot iPhone 17 simulator if needed;
- uninstall the app or reset app data where safe;
- build and run the app;
- capture screenshots after launch from the current HEAD.

If XcodeBuildMCP is available, use it for build/run/screenshot.
If not, use `xcrun simctl` and `xcodebuild`.
If screenshot automation is unavailable, document the limitation as Yellow and create operator screenshot checklist.

============================================================
DURABLE SCREENSHOT EVIDENCE
============================================================

Save durable evidence under:

`docs/audits/visual-evidence/fvq01/`

Required where tooling/fixtures permit:

- `today-default.png`
- `today-private.png`
- `today-overloaded.png`
- `today-stale-source.png`
- `today-recovery-closure.png`
- `today-dynamic-type.png`
- `today-reduce-motion.png`
- `today-accessibility-summary.md`
- `screenshot-freshness.json`

If a fixture/state does not exist, record:

- missing fixture;
- owner batch;
- why safe to continue or why not;
- exact future repair requirement.

============================================================
FLAGSHIP VISUAL RUBRIC
============================================================

Score Today screenshots numerically and honestly.

Required pass bars:

- Native iPhone believability: 9/10
- Premium material quality: 9/10
- Start Here dominance: 9/10
- Reality Rail continuity: 9/10
- Ambition Meridian shell: 9/10
- Found Life alignment: 9/10
- Receipt/trust expression: 9/10
- Cognitive load: 9/10
- No dashboard/card-stack drift: 10/10
- No scaffold/debug language: 10/10
- Accessibility/readability: 9/10
- Reduced Motion equivalent: 9/10
- Screenshot freshness proof: 10/10

If any required category is below pass bar, FVQ01 cannot be Green.

============================================================
HARD VISUAL RED CONDITIONS
============================================================

Classify Hard Visual Red if any persist after one focused repair attempt:

- Today looks like a component demo or proof screen.
- A giant explanatory Reality Rail card dominates.
- Internal pills like `Start here`, `Now / Next / Later`, or `Close the loop` are primary UI scaffolding.
- Start Here is not the unmistakable primary daily decision surface.
- UI reads as generic SwiftUI card stack.
- UI reads as surface.
- Meridian shell feels rough/prototype-like.
- App screenshot cannot be proven fresh against current HEAD.
- Codex would need to weaken canon, delete tests, fake screenshots, or ignore source truth to pass.

============================================================
RECOVERABLE VISUAL RED CONDITIONS
============================================================

Recoverable Red must be repaired or split into narrow repair batch:

- stale simulator likely;
- temp-only screenshot path;
- missing screenshot fixture;
- visual hierarchy flat but repairable;
- scaffold labels removable;
- material hierarchy weak but repairable using existing primitives;
- Start Here and Reality Rail disconnected but repairable in Today composition;
- shell/chrome not fully premium but repairable in AppMeridianShell scope.

============================================================
REPAIR SCOPE
============================================================

Allowed focused repairs:

- Today composition and visual hierarchy;
- StartHereSurface presentation;
- Reality Rail presentation;
- Action Closure Diamond presentation inside Today;
- Receipt Drawer seam presentation;
- AppMeridianShell chrome/safe-area/global action presentation;
- preview fixtures and visual evidence infrastructure;
- debug/test-only freshness proof;
- focused tests for Today/AppShell visual state contracts;
- audit docs and visual evidence.

Forbidden unless explicitly required and scoped:

- route/raw value changes;
- persistence/schema changes;
- sync/cloud/account changes;
- monetization changes;
- legal/privacy policy changes;
- signing/workflow/entitlement changes;
- new top-level tab;
- AI runtime/AOS/LDI runtime behavior;
- deleting tests to pass;
- weakening canon or visual standards.

============================================================
VISUAL EXECUTION TARGET
============================================================

Today should not explain its components. It should feel like the day begins here.

Target qualities:

- Start Here is a quiet, expensive, unmistakable decision surface.
- Reality Rail is a connected execution spine, not an explanatory module.
- Closure is a mature interaction, not status pills.
- Receipt/trust is discoverable and calm.
- Found Life is present through meaning and continuity, not surface density.
- Materials are rich but restrained.
- Header and tab shell feel native and intentional.
- Text is sparse, purposeful, and user-facing.
- No prototype/debug/component-proof language is visible.

============================================================
REQUIRED TESTS / VALIDATION
============================================================

Run:

```bash
git status --short
git diff --check
xcodegen generate
scripts/build-local.sh
```

Run focused tests touching the repaired/validated scope, such as:

```bash
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/TodayTests -only-testing:AmbitionsTests/AppShellNavigationTests -only-testing:AmbitionsTests/AppShellChromeTests
```

Adjust focused test targets to actual available test names. Do not fail solely because the sample command names are stale; find the closest real tests.

Run advisory CQS scans:

```bash
scripts/cqs-product-drift-scan.sh . || true
scripts/cqs-prompt-built-smell-scan.sh . || true
scripts/cqs-accessibility-motion-scan.sh . || true
scripts/cqs-privacy-security-claim-scan.sh . || true
```

If any advisory scan reveals a relevant touched-scope issue, repair it or classify it. Do not hide it behind `|| true`.

============================================================
REQUIRED REPORT
============================================================

Write:

`docs/audits/fvq01-rendered-visual-freshness-and-flagship-report.md`

Report must include:

- Result
- Current global batch state when FVQ01 was inserted
- Whether current batch was allowed to finish first
- Repo HEAD SHA
- origin/main SHA
- app build SHA/freshness proof
- simulator/device/runtime
- clean build/fresh install proof
- screenshots saved
- visual rubric table with numeric scores
- direct comparison to Ambitions canon
- visual issues found
- repairs made
- tests run
- remaining Yellow items
- Red classification if any
- rollback path
- next eligible batch

============================================================
COMMIT RULES
============================================================

Commit FVQ01 only if:

- Green; or
- Accepted Yellow with no Hard Visual Red and clear owner/repair path.

Do not commit unresolved Hard Visual Red.
Do not mark FVQ01 Green without durable screenshot/freshness evidence unless tooling makes screenshots impossible and a stronger operator proof checklist is added with Yellow classification.

Commit message:

`FVQ01: Add rendered visual freshness flagship proof`

============================================================
NEXT BATCH
============================================================

After FVQ01:

- If FCP09 already completed, resume with PFC13 or next eligible global order batch.
- If FCP09 has not completed, resume with FCP09.
- If FVQ01 creates a repair batch, run the repair batch before continuing.

Begin now.
```

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
