<!-- AMBITIONS_RUNNER_REQUIRED: true -->
# Batch ALIGN-01-NAMING: Foundation Alignment (Naming & IA)

## Goal
Align internal source names with the active Product Design Truth IA (`Today / Goals / Capture / Time / You`).

## Truth Files
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`

## Instructions
1. **Phase 1: Tab & Route Alignment**
   - Modify `Native/Ambitions/App/AppTab.swift`:
     - Rename enum cases: `plan` -> `time`, `profile` -> `you`, `captures` -> `capture`.
     - Update all switches and usages within this file.
   - Update `Native/Ambitions/App/AmbitionsRootView.swift` to handle the renamed cases.

2. **Phase 2: Folder & File Migration**
   - Rename:
     - `Native/Ambitions/Features/Plan` -> `Native/Ambitions/Features/Time`
     - `Native/Ambitions/Features/Profile` -> `Native/Ambitions/Features/You`
     - `Native/Ambitions/Features/Captures` -> `Native/Ambitions/Features/Capture`
   - Rename primary screen files:
     - `Native/Ambitions/Features/Plan/PlanScreen.swift` -> `Native/Ambitions/Features/Time/TimeScreen.swift`
     - `Native/Ambitions/Features/Profile/ProfileScreen.swift` -> `Native/Ambitions/Features/You/YouScreen.swift`

3. **Phase 3: Internal Symbol Refactoring**
   - Refactor `PlanScreen` -> `TimeScreen` and `ProfileScreen` -> `YouScreen`.
   - Update all references in the project.

4. **Phase 4: Validation**
   - Run `xcodegen generate` to verify project configuration.
   - Run `scripts/build-local.sh` to ensure the app compiles.
   - Run UI tests to confirm navigation.

## Non-claims
- No claim of full visual completion.
- No claim of performance validation.
- No claim of App Store readiness.
