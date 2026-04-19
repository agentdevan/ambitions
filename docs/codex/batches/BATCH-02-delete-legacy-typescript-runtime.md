# Batch 02 — Delete Legacy TypeScript Runtime

## Status

Completed

## Goal

Remove any remaining legacy TypeScript / Expo / React Native runtime artifacts and stale backend/runtime docs so the repo truth is fully Swift-native and future Codex runs do not inherit dead-path assumptions.

## In Scope

- delete remaining legacy TS / Expo / React Native root/runtime files if present
- delete old node-based runtime scripts if present and truly unused
- remove stale backend/runtime docs that only supported the deleted path
- update `README.md` so it clearly states the repo is Swift-only
- update `docs/README.md` to remove deleted entries and stale references
- preserve all native app code paths, Swift packages, and current canon docs
- verify the repo truth now reflects native SwiftUI + XcodeGen only

## Out Of Scope

- any Batch 01 product/runtime changes
- domain foundation work
- capture enhancements beyond what already exists
- App Intents
- widgets / Live Activities
- sync
- planning/recovery/time-orchestration work
- any later canon batches

## Current Repo Notes

- The classic legacy root runtime files called out for deletion are already absent at the repo root.
- Batch 02 should therefore verify those absences, delete only the legacy/runtime artifacts that still remain, and clean up repo-truth references that still imply an active Expo/React Native/TypeScript runtime path.
- Native app code, Swift packages, canon docs, and iOS validation workflow must remain untouched except for truthful reference cleanup.

## Exit Criteria

- No active repo docs or control files imply a live TypeScript / Expo / React Native runtime path.
- Remaining legacy runtime artifacts are either deleted or explicitly justified as still needed.
- `README.md` and `docs/README.md` describe the repo as Swift-native / XcodeGen-driven.
- Native validation surfaces remain intact.

## Completion Note

- Batch 02 is complete as a bounded repo-truth pass.
- The live repo no longer carries root TypeScript / Expo runtime artifacts, and active docs already describe the project as Swift-native / XcodeGen-driven.
- Canon Batch 1 / Domain foundation is now the active implementation batch.
