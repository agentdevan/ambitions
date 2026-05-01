# Ambitions 3.0 State Projection Extraction Rules

Path: docs/canon/Ambitions_3_0_State_Projection_Extraction_Rules.md
Status: Active architecture canon


## Purpose
These rules decide when state and projection logic should leave a large feature file before Codex adds more behavior.

## Extraction Is Recommended When
- a feature state file exceeds 700 lines
- five or more top-level state model families share one file
- a new batch would add another state family to an already broad file
- compatibility aliases hide user-facing behavior
- tests must infer product copy from deeply nested state helpers

## Extraction Is Required When
- a feature state file exceeds 1000 lines and the next batch adds behavior
- projection, SwiftUI rendering, compatibility, and copy all live in one file family
- privacy projection and full-detail projection are hard to distinguish
- route compatibility changes risk persisted, deep-link, or App Intent behavior

## Behavior Preservation
Extraction must preserve public initializers where needed, accessibility identifiers, route/deep-link compatibility, previews, focused tests, and user-visible copy unless the batch explicitly owns copy migration.
