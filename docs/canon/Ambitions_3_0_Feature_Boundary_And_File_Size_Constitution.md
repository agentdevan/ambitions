# Ambitions 3.0 Feature Boundary And File Size Constitution

Path: docs/canon/Ambitions_3_0_Feature_Boundary_And_File_Size_Constitution.md
Status: Historical supporting canon; subordinate to `docs/truth/*`


## Constitution
Feature files are organized by responsibility, not by convenience. Ambitions can keep compatibility seams, but every compatibility seam needs an owner, a reason, and a migration or retirement path.

## Boundaries
- Screens own composition and navigation handoff.
- Panels own reusable SwiftUI rendering within the feature.
- View state owns renderable facts only.
- Projectors own deterministic translation from domain facts to view state.
- Actions own user-intent names and route handoff.
- Tests own behavior preservation and contract evidence.

## File Size Gates
400 lines: review responsibility. 700 lines: extraction recommended. 1000 lines: extraction required before adding more behavior unless justified in the batch report. These gates are risk signals, not blind style rules.

## Stop Conditions
Stop when a batch would add new behavior to a feature file already over 1000 lines, when a file mixes projection/rendering/compatibility/copy, or when extraction becomes a prerequisite for safe implementation.
