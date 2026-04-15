# Eval Prompt 07: design-system-guard

## Prompt

Polish the Captures screen so it feels like the rest of Ambitions without redesigning unrelated tabs.

## Success Looks Like

- Reuses current theme/primitives and preserves the premium dark-first feel.
- Limits changes to the captures surface and any truly necessary shared UI seam.
- Avoids clutter and keeps the screen readable.

## Common Failure Patterns

- Broad restyling of unrelated features.
- Generic card spam or enterprise dashboard styling.
- Ignoring existing shared UI primitives.

## Files That Should Probably Be Touched

- `Native/Ambitions/Features/Captures/CapturesScreen.swift`
- possibly a small shared primitive in `Sources/Components/`

## Should Not Touch By Default

- domain/persistence files
- unrelated tabs
