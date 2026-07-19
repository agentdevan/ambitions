# AMB-1195 — Today Reality Window

## Objective

Rebuild Today into a visually rich, actionable Reality Window with state-gated actions, real step fit, and no menu-like CTA stack behavior.

## Covered Linear issues

- `AMB-1186`
- `AMB-1195`
- Today QA leaves attached to `AMB-1186`

## Covered repo issue IDs

- `AMB-ISSUE-0001`
- `AMB-ISSUE-0004`
- `AMB-ISSUE-0005`
- `AMB-ISSUE-0016`
- `AMB-ISSUE-0101`
- `AMB-ISSUE-0102`
- `AMB-ISSUE-0103`
- `AMB-ISSUE-0104`
- `AMB-ISSUE-0105`
- `AMB-ISSUE-0106`
- `AMB-ISSUE-0107`
- `AMB-ISSUE-0108`
- `AMB-ISSUE-1001`
- `AMB-ISSUE-1002`
- `AMB-ISSUE-1003`
- `AMB-ISSUE-1004`
- `AMB-ISSUE-1005`
- `AMB-ISSUE-1006`
- `AMB-ISSUE-1007`
- `AMB-ISSUE-1008`
- `AMB-ISSUE-1009`
- `AMB-ISSUE-1010`
- `AMB-ISSUE-1011`
- `AMB-ISSUE-1201`

## Product law

Today root is a visually rich, actionable Reality Window. The token itself is the primary action. Actions are state-gated. Free-floating steps are equal to goal-linked steps.

## Architecture law

Today shares placement/protection truth with Time. Time Fit and Protect Window are focused subflows. Review/explanation behavior belongs behind inspection glyphs or long press, not dead buttons.

## Runtime honesty law

Do not show `Record outcome`, `Protect this window`, or other mutation affordances when there is no valid state behind them. No fake placement or fake closure path.

## Visual law

- token-in-window behavior
- recovery state when no valid step
- no fixed CTA row
- no menu-like root
- no rail copy
- no nonsemantic icons
- subtle live/current-node behavior instead of `Live now`

## Copy and iconography law

Delete `Start Here` / `Meridian` toggle copy, `No source change yet`, `All from work context`, `Capture what changed`, and `Review context` as visible root copy. Use semantic glyphs and progressive disclosure.

## State model

- valid-step state
- no-valid-step recovery state
- low-capacity state
- too-little-time state
- proof-eligible closure state
- protected-window state
- free-floating and goal-linked steps both participate in fit

## Required deletion / replacement

- remove `Capture what changed`
- remove `Review context` button
- remove `Start Here` / `Meridian` toggle
- replace root-Time jumps with focused Time Fit / Protect Window flows
- remove decorative timeline icons and redundant helper text

## Required implementation

- visually rich actionable Reality Window
- token-in-window behavior
- recovery state when no valid step
- state-gated actions only
- token itself is primary action
- closure only when started/proof-eligible
- remove Capture what changed
- Time Fit scoped flow
- Protect Window scoped flow
- no Review Context button
- no Start Here/Meridian toggle
- no rail copy
- no nonsemantic icons
- free-floating steps equal to goal-linked steps

## Files likely in scope

Codex must inspect current source before editing. Likely areas include Today root/action cluster, closure access gating, Time Fit/Protect Window entry points, current-step rendering, inspection affordances, and `docs/qa/KNOWN_ISSUES.md`. Unexpected files must be justified in closeout.

## Files forbidden unless explicitly justified

- unrelated Time root rebuild files
- unrelated shell/nav rewrites outside Today entry behavior
- product canon files other than required cross-links

## Accessibility requirements

Provide accessible `Begin` or equivalent primary action, semantic labels for current state and fixed points, and honest disabled/unavailable states.

## Testing / audit requirements

Run build/tests plus no-step and valid-step state checks, closure gating checks, focused protection flow checks, and mutation-before/action/after proof.

## Screenshot / device proof requirements

Provide Today root screenshots in dark and light, no-step state, valid-step state, protection flow proof, and closure before/action/after mutation proof.

## docs/qa/KNOWN_ISSUES.md update requirements

Update Today rows for action gating, rail copy removal, protection routing, and proof state.

## Status ceiling

Without valid-state and no-step proof, Today cannot exceed Yellow.

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
