# ChatGPT Pro Project Upload Manifest

## Files to Upload (In Order)
1. `docs/codex/chatgpt-pro-ui-development-quick-brief.md`
2. `docs/codex/chatgpt-pro-ui-development-context-pack.md`
3. `docs/codex/chatgpt-pro-ui-canon-conflicts.md`
4. `docs/codex/ambitions-ui-primitives-inventory.md`
5. `docs/truth/PRODUCT_DESIGN_TRUTH.md` (Optional, only if deep design reasoning is required)

## First Message Paste
Paste the contents of `docs/codex/chatgpt-pro-ui-development-quick-brief.md` directly into the first message to establish immediate constraints.

## How to Start a Pro Reasoning Design Session
Use the **Current-Canon Verification Opener** prompt:
> "Use only current verified canon from the context pack. List unknowns before designing. Confirm you understand the 5 active tabs (Today, Goals, Time, Motion, You) and global Capture before proceeding."

## Refresh Protocol After Repo Changes
- Remove old context packs before uploading newer ones.
- Do not keep multiple contradictory IA packs in the same Project.
- Regenerate the context pack using the Antigravity context-pack generation prompt.
- Re-upload the newly generated `chatgpt-pro-ui-development-context-pack.md`.

## Do NOT Upload
- Generated registries or historical ledgers (`docs/codex/logs/*`).
- Large JSON/YAML evidence databases.
- `docs/truth/HISTORICAL_POLICY.md` (Unless specifically discussing old archive cleanup).
- Stale or archived UI spec files.

## Max Recommended Files
Keep the ChatGPT Project strictly limited to a maximum of **5-7 core context files** at a time to prevent context dilution and ensure the model relies on the most recent, highest-priority constraints.

## Stale-File Replacement Policy
When updating UI architecture or product truth, immediately delete the old file from the ChatGPT Project before uploading the new one. Never leave both the old and new version active in the Project, as this will trigger hallucinations and canon conflicts.
