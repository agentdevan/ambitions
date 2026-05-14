<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

AMB-REPO-AUTHORITY-03-BACKEND-HONESTY

# Objective

Make the backend story honest and remove root-visible false hosted-backend/provider signals.

Ambitions core architecture is local-first. A hosted personal-data backend, external/cloud LLM dependency, Supabase setup, Expo setup, or sync provider may not appear active unless current repo truth proves it.

# Runner command

```bash
make batch BATCH=AMB-REPO-AUTHORITY-03-BACKEND-HONESTY PROMPT=prompts/batches/AMB-REPO-AUTHORITY-03-BACKEND-HONESTY.md
```

# Active source truth to inspect

```text
docs/status/repo-authority-cleanup-baseline.md
docs/status/repo-authority-cleanup-front-door-report.md
backend/README.md
docs/truth/README.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
.codex/SKILL_GOVERNANCE.md
.codex/REPO_INVENTORY.md
.env.example
skills-lock.json
Package.swift
project.yml
Native/Ambitions/
```

# Allowed scope

```text
backend/README.md
.env.example
skills-lock.json
.codex/SKILL_GOVERNANCE.md
.codex/REPO_INVENTORY.md
README.md
docs/README.md
validation/README.md
docs/status/repo-authority-cleanup-backend-honesty-report.md
```

Only touch `.codex/SKILL_GOVERNANCE.md` or `.codex/REPO_INVENTORY.md` if they explicitly advertise stale provider truth or need routing updates.

# Forbidden scope

- Do not add a hosted backend.
- Do not add Supabase, Firebase, Expo, or any other provider setup.
- Do not imply sync exists unless current repo truth proves it.
- Do not delete operational files without inbound-reference validation and rollback notes.
- Do not modify app source unless absolutely required; source changes require build/test proof.
- Do not modify runner scripts.

# Required actions

1. Confirm Phases 0–2 are GREEN or record RED and stop.
2. Inspect `.env.example` and classify it as active config, stale provider residue, supporting sample, historical artifact, or delete/archive candidate.
3. Inspect `skills-lock.json` and classify every root-visible provider/skill reference.
4. Inspect `.codex/SKILL_GOVERNANCE.md` and ensure deleted or inactive skills/providers are not presented as active architecture.
5. Rewrite or confirm `backend/README.md` so it states:
   - no active hosted personal-data backend exists unless current truth proves otherwise
   - active backend-equivalent is local domain/service/persistence/runtime code
   - core intelligence is local-first and deterministic
   - external/cloud LLMs are not required core architecture
   - future backend/sync/provider work must be promoted through active truth before becoming active
6. If `.env.example` is stale Supabase/Expo/provider residue, either delete/archive it according to repo policy or replace it with a local-first placeholder. Prefer the safest option supported by inbound-reference analysis.
7. If `skills-lock.json` is stale deleted-skill/provider residue with no active use, delete/archive it. If it must remain, rewrite/relocate it so it is not root-visible active provider truth.
8. Update any touched docs that pointed to stale provider files as active backend configuration.
9. Write `docs/status/repo-authority-cleanup-backend-honesty-report.md` with classification, decisions, validation, and rollback.

# Validation expectations

Run and record:

```bash
git status --short
test -f backend/README.md
test -f docs/status/repo-authority-cleanup-backend-honesty-report.md
grep -n "local-first" backend/README.md
grep -n "no active hosted" backend/README.md || grep -n "No active hosted" backend/README.md
grep -n "external/cloud LLM" backend/README.md || true
```

Run an active-path provider scan. The scan must classify any remaining hits for:

```text
SUPABASE
Supabase
EXPO
Expo
Firebase
hosted backend
cloud LLM
external LLM
OPENAI_API_KEY
```

Remaining hits are GREEN only if documented as historical, supporting, optional, or non-active. Active/root-visible provider setup is RED.

If source code changes are made, run the strongest available build/test proof, for example:

```bash
swift test
xcodebuild -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 15' build
```

Use the repo’s actual documented build commands if different.

# Visual proof expectations

None unless UI source is changed. UI source changes should not occur in this phase.

# Hard Red stop conditions

- Phase 0, 1, or 2 is not GREEN.
- Root-visible `.env.example` still advertises Supabase/Expo/provider setup as active architecture.
- `skills-lock.json` still advertises deleted/inactive provider skills as active architecture.
- Backend portal implies hosted personal-data backend or sync exists without proof.
- External/cloud LLMs are described as required core architecture.
- A file is deleted without inbound-reference validation and rollback.
- Source changes occur without build/test proof.

# Rollback expectations

If committed, rollback is:

```bash
git revert <commit>
```

If uncommitted, list exact `git checkout --` and restore/move-back commands for touched files.

# GREEN criteria

- `backend/README.md` is honest and local-first.
- No root-visible stale hosted-provider setup remains active.
- Provider residue is classified and either removed, archived, or explicitly non-active.
- Validation passes.
- Rollback is documented.
