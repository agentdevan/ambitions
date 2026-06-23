# AMB-1196 — Search Find / Act / Inspect

## Objective

Rebuild Search into a mature shell-scoped full-screen Find / Act / Inspect surface backed by deterministic local indexing.

## Covered Linear issues

- `AMB-1187`
- `AMB-1196`
- Search QA leaves attached to `AMB-1187`

## Covered repo issue IDs

- `AMB-ISSUE-0701`
- `AMB-ISSUE-1601`
- `AMB-ISSUE-1602`
- `AMB-ISSUE-1603`
- `AMB-ISSUE-1604`
- `AMB-ISSUE-1605`

## Product law

Search is a unified local-only Find / Act / Inspect surface. It is not a chatbot, shallow sheet, or cloud/LLM query path.

## Architecture law

Use a deterministic local SearchIndex. Search opens as a full-screen Stage takeover, ranks globally with origin bias, and passes creation intent into Capture rather than creating objects directly.

## Runtime honesty law

Do not return abstract implementation labels as if they are user-meaningful results. Mutations must be state-gated and receipt-backed.

## Visual law

- full-screen Stage takeover
- command field with optional tokens
- mature overlay treatment
- result rows with glyph/title/source/state/action/inspect
- minimal empty state with one contextual action

## Copy and iconography law

No internal result labels like `Handoff`, `Global Capture`, `owning surfaces`, or route implementation wording. Keep rows icon-first and human-readable.

## State model

- origin-biased global scope
- empty/no-result state
- dense result state
- open vs action vs inspect behavior
- Search-to-Capture prefilling
- receipt-backed mutations only

## Required deletion / replacement

- replace shallow search sheet/card
- remove internal route/result labels
- replace weak field/button treatment with native-quality search entry
- remove any cloud/LLM dependency for query path

## Required implementation

- full-screen Stage takeover
- Find / Act / Inspect
- global gesture/keyboard/App Shortcut/VoiceOver path
- command field with optional tokens
- local deterministic SearchIndex
- no cloud/LLM query path
- result rows with glyph/title/source/state/action/inspect
- global with origin-biased ranking
- Search passes query to Capture
- mutations state-gated and receipt-backed
- persistence/reload proof

## Files likely in scope

Codex must inspect current source before editing. Likely areas include Search presentation, local index/query models, result-row rendering, routing/actions, Search-to-Capture handoff, and `docs/qa/KNOWN_ISSUES.md`. Unexpected files must be justified in closeout.

## Files forbidden unless explicitly justified

- cloud/LLM service code
- unrelated capture/goal/time internals beyond routing/action connections
- product canon files other than required cross-links

## Accessibility requirements

Support VoiceOver invocation path, accessible result rows/actions, and list equivalence for visual states.

## Testing / audit requirements

Run build/tests plus empty/dense/no-result cases, route proof, reload proof, and string audit for internal labels.

## Screenshot / device proof requirements

Provide Search opened from multiple root surfaces, result tap route proof, empty/dense/no-result screenshots, and privacy/source boundary notes.

## docs/qa/KNOWN_ISSUES.md update requirements

Update Search rows to reflect overlay maturity, local index behavior, result actionability, and proof state.

## Status ceiling

Without device proof and routing proof, Search remains Yellow.

## Closeout template

```text
Status:
Bundle:
Linear issues covered:
Repo issue IDs covered:
Files changed:
Product law implemented:
Architecture law implemented:
Runtime honesty proof:
Validation run:
Validation not run:
Screenshots/videos:
Accessibility proof:
docs/qa/KNOWN_ISSUES.md updates:
Status ceiling:
Known risks:
Rollback plan:
```
