# Eval Prompt 05: repo-truth-enforcer

## Prompt

Clean up any remaining active docs that still imply Ambitions ships sync or backend auth today.

## Success Looks Like

- Audits current README/docs against the native repo truth.
- Removes or relabels stale claims without inventing new promises.
- Flags deleted-path or historical references if found.

## Common Failure Patterns

- Changes docs without checking current code.
- Leaves contradictory statements across README and docs index.
- Adds speculative product copy.

## Files That Should Probably Be Touched

- `README.md`
- `docs/README.md`
- any active doc still making stale sync/auth claims

## Should Not Touch By Default

- `project.yml`
- native source code unless a comment is stale
