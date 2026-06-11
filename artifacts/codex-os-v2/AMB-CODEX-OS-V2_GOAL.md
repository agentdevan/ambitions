# AMB-CODEX-OS-V2 GOAL

Program: CODEX-OS
Active issues: AMB-CODEX-OS-V2-001 through AMB-CODEX-OS-V2-013
Execution model: Goal Mode
Branch policy: main only, no branches, no force-push, no rebase, no squash
Scope: docs, scripts, skills, artifacts, process authority, proof ledger, reviewer board, Linear closeout validator
Forbidden scope: Swift app source, Xcode project files, `project.yml`, `Package.swift`, entitlements, resources, runtime behavior, dependencies, generated Xcode projects

## Goal

Install Goal Mode as the active default for new Ambitions autonomous work, demote the old runner to legacy/supporting/historical for new Goal Mode programs, and add mature adapters for UIQL, PLOS, and SAF without implementation or release claims.

## Work Item Order

1. AMB-CODEX-OS-V2-001 audit current validator/doctor expectations.
2. AMB-CODEX-OS-V2-002 patch category framing in active authority docs.
3. AMB-CODEX-OS-V2-003 install Program Registry v2.
4. AMB-CODEX-OS-V2-004 install Run-State Standard.
5. AMB-CODEX-OS-V2-005 install Proof Artifact Standard and Proof Ledger.
6. AMB-CODEX-OS-V2-006 install Reviewer Board skill.
7. AMB-CODEX-OS-V2-007 install Script Output Standard.
8. AMB-CODEX-OS-V2-008 install Goal-Mode Program Execution Interface.
9. AMB-CODEX-OS-V2-009 install Linear Closeout Validator.
10. AMB-CODEX-OS-V2-010 install mature UIQL Program Kit.
11. AMB-CODEX-OS-V2-011 install mature PLOS Program Kit.
12. AMB-CODEX-OS-V2-012 install mature Source Atlas Factory Program Kit.
13. AMB-CODEX-OS-V2-013 final red-team audit.

## Gates

Green requires docs/scripts/skills/artifacts-only changes, no app source touch, valid program scripts, proof index, process docs patched away from runner-as-default conflict, mature UIQL/PLOS/SAF adapters, and honest validation reports.

Yellow is allowed for pre-existing validator/doctor drift or unavailable Linear access only when documented with no-claim boundaries.

Red requires stop before push if app source changed, Goal Mode and runner authority conflict remains in active front doors, scripts mutate forbidden paths, validation failure is caused by install, or release/owner approval claims appear.

## Linear Closeout

After push to main, update Linear if issues and access exist. Otherwise use manual closeout text in `docs/codex-os/CODEX_OS_V2_INSTALL_REPORT.md`.
