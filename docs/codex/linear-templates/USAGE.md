# Linear Template Usage

Status: Active usage note.
Scope: How to use the Ambitions Linear template files efficiently.

Use these files as the source for Linear project and issue generation:

- `docs/codex/linear-templates/README.md`
- `docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml`
- `docs/codex/linear-templates/AMB-ISSUE-TEMPLATES.md`
- `docs/codex/linear-templates/AMB-PROJECT-TEMPLATE.md`

## Default Flow

1. Select the smallest matching template from the manifest.
2. Create one Linear issue for one bounded outcome.
3. Use exact repo paths for authority, scope, validation, and proof.
4. Keep the issue compact by referencing the manifest instead of repeating the full product law.
5. Ask Codex to execute only the issue contract.
6. Review the final report before merge readiness.

## Compact Issue Minimum

Every issue should include:

```text
Template:
Manifest:
Authority inspected:
Intent:
Scope:
Non-goals:
Requirements:
Validation:
Proof:
Stop conditions:
Final response:
```

## Ready for Codex Checklist

An issue is ready for Codex when it has:

- one clear outcome
- exact allowed files or folders
- explicit non-goals
- validation commands or a validation lane
- proof expectations
- clear stop conditions
- required Green/Yellow/Red final report

## Reuse Rule

When a future issue needs more detail, update these repo templates first, then use
the updated template in Linear. Do not let one-off Linear phrasing become the new
standard unless it is promoted back into this directory.
