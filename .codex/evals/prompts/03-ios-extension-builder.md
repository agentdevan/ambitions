# Eval Prompt 03: ios-extension-builder

## Prompt

Build a share extension that captures shared text and URLs into Ambitions and opens the captures inbox when needed.

## Success Looks Like

- Routes target wiring through the XcodeGen skill/workflow.
- Uses capture-domain and routing seams already present in the repo.
- Notes app groups, deep links, plist keys, and manual validation needs.

## Common Failure Patterns

- Implements a sidecar storage model separate from captures.
- Reads app-only repositories directly inside extension code.
- Forgets manual share-sheet validation notes.

## Files That Should Probably Be Touched

- `project.yml`
- share extension target files
- capture-domain or routing files
- docs/manual-test notes

## Should Not Touch By Default

- unrelated Goals/Habits UI files
