<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

AMB-REPO-AUTHORITY-CLEANUP-INSTALL-00

# Objective

Install and verify the Ambitions repo-authority cleanup train. This prompt exists as the bootstrap / traceability prompt for the installed suite.

This batch is not the cleanup execution pass. The cleanup execution pass is:

```bash
make batch BATCH=AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL PROMPT=prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL.md
```

# Required installed artifacts

Codex must verify that these files exist before this install batch may report GREEN:

```text
prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL.md
prompts/batches/AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT.md
prompts/batches/AMB-REPO-AUTHORITY-01-FRONT-DOOR-PORTALS.md
prompts/batches/AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA.md
prompts/batches/AMB-REPO-AUTHORITY-03-BACKEND-HONESTY.md
prompts/batches/AMB-REPO-AUTHORITY-04-CODEX-OS-CONSOLIDATION.md
prompts/batches/AMB-REPO-AUTHORITY-05-HISTORICAL-ARCHIVE-MIGRATION.md
prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md
prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md
docs/codex/batch-trains/AMB-REPO-AUTHORITY-CLEANUP-SEQUENCE.md
docs/status/repo-authority-cleanup-green-gate-spec.md
docs/status/repo-authority-cleanup-install-report.md
```

# Active source truth to inspect

Inspect these first. If any are missing, record the absence; do not invent replacement authority.

```text
README.md
AGENTS.md
docs/AGENTS.md
docs/README.md
docs/truth/README.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/status/current-implementation-map.md
docs/status/repo-cleanup-index.md
docs/status/archive-and-stale-material-ledger.md
docs/status/quarantine-archive-folder-plan.md
docs/status/visual-canon-moat-installation-report.md
docs/AmbitionsCanon/README.md
docs/AmbitionsCanon/20_Visual_Canon_Moat_Implementation_Spec.md
docs/canon/README.md
docs/canon/frontend/README.md
docs/canon/frontend/AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md
.codex/OPERATING_SYSTEM.md
.codex/REPO_INVENTORY.md
.codex/SKILL_GOVERNANCE.md
docs/codex/CODEX_OS_INDEX.md
docs/codex-os/
prompts/
scripts/
build/reports/
project.yml
Package.swift
Native/Ambitions/App/AppTab.swift
Native/Ambitions/App/AmbitionsRootView.swift
Native/AmbitionsUITests/AmbitionsUITests.swift
Native/AmbitionsWidgetExtension/NextStepWidget.swift
.env.example
skills-lock.json
```

# Canon this train must enforce

- Ambitions is a premium native iPhone-first, local-first life operating system.
- Active top-level IA is exactly: Today / Goals / Capture / Time / You.
- Plan is superseded as a top-level destination.
- Primary object mapping: Today → Reality Meridian; Goals → Constellation Atlas; Capture → Atmosphere Composer; Time → LifeShape Field; You → User System Profile.
- Visual direction: Apple quiet luxury, living on-device intelligence, executive command clarity, graphite/warm dark luxury, native iPhone believability, restrained celestial orientation.
- Core intelligence is local-first and deterministic through the Private Life Runtime / Intelligence Kernel.
- External/cloud LLMs are not part of the core product architecture.
- Release/TestFlight/App Store/device/accessibility/performance/privacy/legal claims require proof.
- The Visual Encyclopedia is the frontend front door.
- Historical material is non-authoritative unless explicitly promoted by active truth.

# Allowed scope

This install batch may only inspect the repo and verify the installed prompt suite. If repair is required, it may only touch:

```text
prompts/batches/AMB-REPO-AUTHORITY*.md
docs/codex/batch-trains/AMB-REPO-AUTHORITY-CLEANUP-SEQUENCE.md
docs/status/repo-authority-cleanup-green-gate-spec.md
docs/status/repo-authority-cleanup-install-report.md
```

# Forbidden scope

Do not execute cleanup. Do not rewrite README. Do not move Visual Encyclopedia files. Do not archive or delete files. Do not modify app source. Do not modify runner scripts. Do not create a replacement runner.

# Validation expectations

Run all commands that exist in this repo and record results:

```bash
git status --short
test -f scripts/ambitions-codex-train.sh
test -f README.md
test -f AGENTS.md
test -d prompts/batches
test -f prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL.md
test -f prompts/batches/AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT.md
test -f prompts/batches/AMB-REPO-AUTHORITY-01-FRONT-DOOR-PORTALS.md
test -f prompts/batches/AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA.md
test -f prompts/batches/AMB-REPO-AUTHORITY-03-BACKEND-HONESTY.md
test -f prompts/batches/AMB-REPO-AUTHORITY-04-CODEX-OS-CONSOLIDATION.md
test -f prompts/batches/AMB-REPO-AUTHORITY-05-HISTORICAL-ARCHIVE-MIGRATION.md
test -f prompts/batches/AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR.md
test -f prompts/batches/AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF.md
test -f docs/codex/batch-trains/AMB-REPO-AUTHORITY-CLEANUP-SEQUENCE.md
test -f docs/status/repo-authority-cleanup-green-gate-spec.md
test -f docs/status/repo-authority-cleanup-install-report.md
grep -R "<!-- AMBITIONS_RUNNER_REQUIRED: true -->" prompts/batches/AMB-REPO-AUTHORITY*.md
grep -R "<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->" prompts/batches/AMB-REPO-AUTHORITY*.md
grep -R "<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->" prompts/batches/AMB-REPO-AUTHORITY*.md
grep -R "scripts/ambitions-codex-train.sh" prompts/batches/AMB-REPO-AUTHORITY*.md
grep -R "make batch BATCH=" prompts/batches/AMB-REPO-AUTHORITY*.md
```

# Hard Red stop conditions

- Missing runner script.
- Missing any installed prompt file.
- Any installed prompt lacks the required header.
- RUN-ALL permits Yellow continuation.
- RUN-ALL lacks phase gates or rollback expectations.
- Install diff touches cleanup scope.
- Install report is missing.

# Rollback expectations

If this install batch changes files, report the commit hash and rollback command. If uncommitted, list exact files to remove.

# Runner command

```bash
make batch BATCH=AMB-REPO-AUTHORITY-CLEANUP-INSTALL-00 PROMPT=prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-INSTALL-00.md
```

# Final response format

```text
Status: GREEN or RED
Batch: AMB-REPO-AUTHORITY-CLEANUP-INSTALL-00
Installed files:
Validation:
Commit:
Rollback:
Next command:
make batch BATCH=AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL PROMPT=prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL.md
```
