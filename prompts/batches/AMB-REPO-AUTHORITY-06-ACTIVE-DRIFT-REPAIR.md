<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR

# Objective

Repair active-path vocabulary drift, user-facing copy drift, stale architecture claims, and misleading active guidance without creating uncontrolled implementation churn.

This phase must distinguish active blockers from compatibility seams, historical references, supporting references, and false-claim risks. It must not blindly rename large feature directories or remove compatibility code.

# Runner command

```bash
make batch BATCH=AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR PROMPT=prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md
```

# Active source truth to inspect

```text
docs/status/repo-authority-cleanup-baseline.md
docs/status/repo-authority-cleanup-front-door-report.md
docs/status/repo-authority-cleanup-frontend-visual-encyclopedia-report.md
docs/status/repo-authority-cleanup-backend-honesty-report.md
docs/status/repo-authority-cleanup-codex-os-report.md
docs/status/repo-authority-cleanup-historical-archive-report.md
README.md
frontend/README.md
frontend/installed-canon.md
frontend/intended-canon.md
frontend/visual-encyclopedia/
backend/README.md
codex-os/README.md
product-canon/README.md
validation/README.md
history/README.md
docs/truth/README.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/status/current-implementation-map.md
Native/AmbitionsWidgetExtension/NextStepWidget.swift
Native/Ambitions/Features/Plan/PlanScreen.swift
Native/Ambitions/App/AppTab.swift
Native/Ambitions/App/AmbitionsRootView.swift
Native/AmbitionsUITests/AmbitionsUITests.swift
docs/AGENTS.md
docs/canon/README.md
.env.example
skills-lock.json
```

# Allowed scope

```text
README.md
frontend/**
backend/README.md
codex-os/README.md
product-canon/README.md
validation/README.md
history/README.md
docs/README.md
docs/AGENTS.md
docs/canon/README.md
docs/truth/**
docs/status/current-implementation-map.md
Native/AmbitionsWidgetExtension/NextStepWidget.swift
Native/Ambitions/Features/Plan/PlanScreen.swift
Native/Ambitions/App/AppTab.swift
Native/Ambitions/App/AmbitionsRootView.swift
Native/AmbitionsUITests/AmbitionsUITests.swift
.env.example
skills-lock.json
.codex/SKILL_GOVERNANCE.md
.codex/REPO_INVENTORY.md
docs/status/repo-authority-cleanup-active-drift-report.md
```

Touch Swift source only when the drift is user-facing or a false active proof claim, and only with build/test proof.

# Forbidden scope

- Do not redesign UI.
- Do not rename large feature directories unless build/tests prove safety and the final report justifies it.
- Do not remove compatibility seams blindly.
- Do not add hosted backend/provider setup.
- Do not introduce chatbot UI or top-level AI assistant framing.
- Do not claim source is corrected unless tests pass or no source change was made.
- Do not change runner scripts.
- Do not continue if any prior phase is not GREEN.

# Required active-path scans

Search active paths for:

```text
Ambitions 2.0
Ambitions_2_0
Ambitions 3.0
Ambitions_3_0
Ambitions 4.0
Ambitions_4_0
Plan as top-level destination
Plan is a top-level
Start now
Start now
Open Focus
Recommended step
Your Recommended step
Recommended step
generic AI assistant
generic chatbot
chatbot UI
external/cloud LLM
external LLM
cloud LLM
Supabase
SUPABASE
Expo
EXPO
Firebase
OPENAI_API_KEY
TestFlight
App Store
device tested
production ready
release ready
```

# Classification required for every hit

Each hit must be classified as exactly one:

- active blocker
- compatibility-only
- historical-only
- supporting reference
- false-claim risk
- unknown / human decision required

# Required actions

1. Confirm Phases 0–5 are GREEN or stop RED.
2. Run the active-path scans.
3. Build a drift table with path, line/context, classification, action, risk, and validation proof needed.
4. Repair active blockers first.
5. Prefer docs/copy repairs before source changes.
6. For Swift source, prefer user-facing copy corrections only:
   - replace `Start now`, `Start now`, or `Open Focus` with `Start now` or `Open step` according to destination behavior
   - replace `Recommended step` / `Your Recommended step` / `Recommended step` with `Start here`, `Recommended step`, or neutral active canon language
   - ensure visible top-level IA is Today / Goals / Capture / Time / You
7. Internal names such as `Plan` may remain only if documented as compatibility seams and not visible as top-level IA.
8. If source changes are made, run the strongest available build/test proof.
9. If build/test proof cannot run, revert source changes and report RED unless the drift is non-user-facing and classified compatibility-only.
10. Write `docs/status/repo-authority-cleanup-active-drift-report.md` with scans, classifications, repairs, validation, rollback, and allowlist candidates for Phase 7.

# Validation expectations

Run and record:

```bash
git status --short
test -f docs/status/repo-authority-cleanup-active-drift-report.md
```

Run available validators if they exist:

```bash
python scripts/ambitions-vocabulary-drift-scan.py
python scripts/ambitions-moat-drift-scan.py
python scripts/ambitions-authority-supersession-check.py
```

Run active-path scans over root portals and active frontend/backend/codex/product/validation docs. Remaining hits are GREEN only if they are documented compatibility/supporting references or historical paths excluded from active scans.

If Swift source changed, run the strongest available repo build/test commands, for example:

```bash
swift test
xcodebuild -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 15' build
```

Use the repo’s documented commands if different.

# Visual proof expectations

If UI source changes are made, provide at least one of:

- build/test proof plus affected source citation
- screenshot/preview proof if the repo supports deterministic visual preview generation
- explicit note that visual proof could not be produced and RED if user-facing UI drift cannot otherwise be proven fixed

# Hard Red stop conditions

- Any prior phase is not GREEN.
- Any active blocker remains unclassified.
- Any active front door still presents Ambitions 2.0/3.0/4.0 as current truth.
- User-facing `Start now`, `Start now`, `Open Focus`, or `Recommended step` language remains without allowlisted reason.
- Plan remains visible as top-level IA.
- External/cloud LLMs or hosted providers remain described as required core architecture.
- Unproofed release/TestFlight/App Store/device/performance/privacy/legal claims remain active.
- Swift source changes occur without build/test proof.
- Report is missing.

# Rollback expectations

If committed, rollback is:

```bash
git revert <commit>
```

If uncommitted, provide exact `git checkout --` commands for every touched file and any manual restoration steps.

# GREEN criteria

- All active-path drift is either repaired or explicitly classified as compatibility/supporting/historical.
- No banned user-facing CTA/copy remains active.
- No false provider/backend or external LLM core claim remains active.
- No unproofed release/device claim remains active.
- Source changes, if any, have build/test proof.
- Active drift report exists with rollback.

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
