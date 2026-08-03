# Cross-product drift validation

## Purpose and isolation

This evidence records two disposable, committed Git drift probes against the passed lifecycle-fixture Design. Both ran in an isolated sparse linked worktree created from `de69bc47d5eaecf26988007db2a634eef81e5c4f`; its temporary branch and worktree were removed after collecting the results. The probes never changed this feature branch, fixture documents, the skill implementation, workflow configuration, or SDD ledger.

The consumed document was `docs/product-development/lifecycle-fixture/design.md`, revision `1`, contract hash `sha256:30b689731623644dc2a19873418f25fa425b56c28930e3a67af52661a8257224`. Its declared repository baseline is the passed Scope commit `0cd783b2cf25e32f21e9f2b24fd7891c5062f76b`; consequently, the subsequently created `design.md` is correctly reported as an unrelated changed path in both probes.

## Unrelated committed drift

Temporary commit `5ed31dc1d7f32f2316b6f28ab0d20e4d27f5781b` added only `notes/task10-drift-unrelated.md`.

```sh
PYTHONDONTWRITEBYTECODE=1 python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py consume docs/product-development/lifecycle-fixture/design.md --json
```

Result: exit `0`; JSON status `success`; verdict `pass`; `relevant_paths` was `[]`; `unrelated_paths` was `[
"docs/product-development/lifecycle-fixture/design.md", "notes/task10-drift-unrelated.md"]`; diagnostics was `[]`; next action was `canon-reconciliation`.

## Declared-owner committed drift

Temporary commit `967b68aee51969d5533ec4e73dfef7b4d42c639e` appended only a disposable comment to the Design-declared owner and freshness path `.agents/skills/ambitions-product-development-lifecycle/tests/test_ambitions_product_docs.py`.

```sh
PYTHONDONTWRITEBYTECODE=1 python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py consume docs/product-development/lifecycle-fixture/design.md --json
```

Result: exit `1`; JSON status `failure`; verdict `needs-revision`; `relevant_paths` was `[
".agents/skills/ambitions-product-development-lifecycle/tests/test_ambitions_product_docs.py"]`; `unrelated_paths` remained `[
"docs/product-development/lifecycle-fixture/design.md", "notes/task10-drift-unrelated.md"]`; diagnostics contained only `semantic-review-required`; next action was `revision`.

## Diff hygiene

The disposable-worktree check `git diff --check de69bc47d5eaecf26988007db2a634eef81e5c4f HEAD` passed after the owner-path probe. The temporary worktree and branch were then removed exactly; the feature branch retains only this evidence record.
