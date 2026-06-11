# uiql-closeout-template

Use this reference during UIQL closeout. It reinforces no product Yellow, screenshot path is not proof, read-only reviewers, exact proof paths, rollback, Linear closeout, and no release/owner approval claims.

Linear identifier rule: Codex must never fetch, update, close, or comment on Linear using synthetic `UIQL-*` labels. Codex must always use the mapped `AMB-*` issue ID for Linear operations. `UIQL-*` is a title/sequence label only, not a Linear identifier. The closeout title may include both, for example `AMB-962 / UIQL-007 - Today Reconstruction`, but the Linear parent must be `AMB-962`.

If the AMB issue cannot be fetched, stop and include exact manual comment text for that AMB issue. Do not fall back to `UIQL-*`.

Required firewall references:

- `docs/codex/ui-quality-firewall.md`
- `docs/codex/uiql-issue-template.md`

Every UIQL closeout must include the UIQL firewall verdict block:

```markdown
UIQL firewall verdict: Green / Yellow / Red
Actual Linear issue:
UIQL sequence label:
Active root/source dependency:
Product object:
Surface owner:
Existing primitives inspected:
Screenshot visual evaluation:
Accessibility variant evidence:
Copy/canon scan:
Card/list/dashboard anatomy scan:
Shell/safe-area/dock proof:
Focused validation:
Changed files:
Proof artifacts:
Red blockers:
Yellow tooling/device limits:
No-claim boundary:
Next dependency:
```

Green is forbidden when based only on artifact existence, screenshot paths, renamed components, focused tests, or Codex self-approval. Product Yellow is forbidden for ugly UI, unsafe geometry, unreadable dock, clipped text, generic anatomy, weak copy, or missing accessibility semantics.
