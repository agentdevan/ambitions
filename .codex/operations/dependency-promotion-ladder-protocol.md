# Dependency Promotion Ladder Protocol

Use when proposing, adopting, promoting, deprecating, or removing a tool/dependency.

## Required Inputs

- `docs/canon/Ambitions_3_0_Dependency_Management_Policy.md`
- `docs/canon/Ambitions_3_0_Dependency_Promotion_Ladder.md`
- `docs/canon/Ambitions_3_0_Build_Skills_And_Dependency_Management.md`
- `Brewfile`, `Brewfile.optional-later`, `project.yml`, `Package.swift`

## Steps

1. Classify current and target state.
2. Check forbidden dependency list.
3. Write a promotion record for any move beyond docs-only.
4. Update setup docs and validation scripts if adopted.
5. Run dependency drift validation.
6. Record rollback/removal path.

## Stop Conditions

Stop for human approval before app-runtime dependencies, paid services, signing automation, sync/auth/account architecture, or CI-blocking promotion.
