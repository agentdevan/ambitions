# Flake Management Protocol

Use when a test is suspected to be intermittent.

## Steps

1. Preserve exact failing command and error.
2. Rerun the narrowest failing test once if useful.
3. Compare failure signature.
4. Classify with `docs/canon/Ambitions_3_0_Flake_Management_Protocol.md`.
5. Create a flake report when nondeterminism remains.
6. Do not mark release validation PASS while a relevant flake is unresolved.

## Output Artifacts

- `.codex/templates/flake-report-template.md` filled into a closeout or audit report.

## Stop Conditions

Stop after two informed repair/rerun attempts without new evidence.
