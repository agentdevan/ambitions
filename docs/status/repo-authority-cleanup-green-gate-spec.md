# Repo Authority Cleanup Green Gate Spec

Status: Installed.

Purpose: define the non-negotiable pass/fail contract for the Ambitions repo-authority cleanup train.

This spec applies to:

```text
AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL
AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT
AMB-REPO-AUTHORITY-01-FRONT-DOOR-PORTALS
AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA
AMB-REPO-AUTHORITY-03-BACKEND-HONESTY
AMB-REPO-AUTHORITY-04-CODEX-OS-CONSOLIDATION
AMB-REPO-AUTHORITY-05-HISTORICAL-ARCHIVE-MIGRATION
AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR
AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF
```

## GREEN

A phase may report GREEN only when all of the following are true:

- All required validation commands for that phase passed, or documented optional scripts were absent and not required for changed scope.
- No unresolved active contradiction remains.
- No active front door presents superseded canon as current truth.
- No active path presents Ambitions 2.0/3.0/4.0 as current authority.
- No active path presents `Plan` as a top-level destination.
- No unproofed release, TestFlight, App Store, device, accessibility, performance, privacy, legal, or production claim remains active.
- No active path describes external/cloud LLMs as required core architecture.
- No active path describes Supabase, Expo, Firebase, or another hosted provider as active personal-data backend architecture unless repo truth proves it.
- No broken active links remain in files touched by the phase.
- No dirty unrelated worktree state remains.
- No dirty unclassified generated artifacts remain.
- All moved files have updated links, redirect stubs, or archive disclaimers.
- Any deletion has pre-delete validation, dependency analysis, and rollback documentation.
- Any source-code change has the strongest available build/test proof.
- Rollback is documented.
- Required phase report exists.

## RED

A phase must report RED and stop immediately for any of the following:

- A required validation command fails.
- The phase cannot operate on `main`.
- Worktree safety cannot be proven.
- A required active truth anchor is missing with no current equivalent.
- A broken active link remains.
- An active obsolete canon reference remains unclassified.
- An unproofed release, TestFlight, App Store, device, accessibility, performance, privacy, legal, or production claim remains active.
- A source-code change lacks build/test proof.
- A file is deleted without pre-delete validation and rollback.
- A move/archive leaves active inbound links broken.
- Historical material remains visible as active guidance.
- `.codex/runs/` or generated run artifacts pollute the active worktree without classification.
- The phase report is missing.
- A rollback path is missing.
- The phase attempts to continue after RED or YELLOW.

## YELLOW

YELLOW is allowed only as a report classification for optional, non-executed improvements or deferred human-choice enhancements.

YELLOW may not permit phase continuation.

A phase with any required incomplete work is RED, not YELLOW.

## Phase continuation rule

Only GREEN unlocks the next phase.

```text
GREEN  → next phase may run
YELLOW → stop; optional/non-executed only; no continuation
RED    → stop immediately; repair or rollback before retry
```

## Deletion policy

Deletion is allowed only for true junk or safely recoverable generated/duplicate artifacts after:

1. Inbound references are checked.
2. Current purpose is classified.
3. Risk is recorded.
4. Rollback is documented.
5. The phase report lists exact paths.

Product/design history should be archived, not deleted, unless it is duplicate generated noise with no forward trace value.

## Archive policy

Moved historical Markdown must receive this header unless a stricter repo policy exists:

```markdown
> Historical material. This file is retained for traceability only and is not active Ambitions canon. Active authority starts at `/README.md`, `/docs/truth/README.md`, and the relevant root portal.
```

Historical material must not be linked from active front doors as active guidance.

## Source-change policy

Any app/source change requires the strongest available repo proof. Acceptable proof may include:

- Swift/unit tests if available.
- Xcode/iOS build if available.
- UI tests if the change affects user-facing copy or IA.
- Deterministic preview/screenshot proof if the repo supports it.

If proof cannot be produced, revert the source change unless the hit is documented as non-user-facing compatibility-only.

## Final GREEN requirement

`AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL` may report final GREEN only if:

- Phases 0–7 are GREEN.
- `docs/status/repo-authority-cleanup-final-report.md` exists.
- `docs/status/repo-authority-cleanup-active-path-allowlist.md` exists.
- Root README is clear.
- Frontend routes to the Visual Encyclopedia.
- Backend posture is honest and local-first.
- Codex OS has one human portal and preserved machine authority.
- Historical material is contained and non-authoritative.
- No visible active-path sprawl remains.
- Final rollback instructions are documented.
