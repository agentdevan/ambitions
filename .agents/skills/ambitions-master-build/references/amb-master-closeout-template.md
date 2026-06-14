# Ambitions Master Build Closeout Template

Validate with:

```bash
python3 scripts/codex/linear-closeout-validate.py --program amb-master --scope child <closeout-file>
```

## Child / Train Closeout

Ambitions Master Build train closeout

Linear project: Ambitions Personal Life OS Runtime + Native iPhone App Master Build Program (`ca716546-e3d4-4d5b-a399-03076ccba9ee`)

Linear issue: `AMB-####`

Train label: `M##.T##`

Parent or umbrella issue: `AMB-1046` or `<AMB parent>`

Green/Yellow/Red status: `<Green/Yellow/Red for exact scope>`

Pushed to main: `<yes/no>`

Push hash: `<commit sha or not pushed>`

App source changed: `<yes/no>`

Runtime behavior changed: `<yes/no>`

Linear identifiers used: AMB issue identifiers only

Files changed:
- `<path>` - `<why>`

Validation run:
- `<command>` - `<exit/result/artifact>`

Reviewer passes:
- `<reviewer or not applicable with reason>`

Proof artifacts:
- `<path>`

Red blockers: `<none or list>`

Yellow limits: `<none or list>`

Owner approval claimed: no

Release/TestFlight/App Store readiness claimed: no

Accessibility certification claimed: no

Privacy/legal approval claimed: no

Rollback:
- `<specific revert command or path-level rollback>`

Next train: `<next AMB issue / train label>`

## Project Closeout

Ambitions Master Build project closeout

Linear project: Ambitions Personal Life OS Runtime + Native iPhone App Master Build Program (`ca716546-e3d4-4d5b-a399-03076ccba9ee`)

Issues covered:
- `<AMB issue list>`

Baseline SHA: `<sha>`

Final SHA: `<sha>`

Pushed SHAs:
- `<sha>` - `<train>`

Implemented work:
- `<summary>`

Validation run:
- `<command>` - `<result>`

Changed files by train/subsystem:
- `<train>` - `<paths>`

Authority/canon updates:
- `<paths or none>`

Stale canon superseded:
- `<summary or none>`

Proof artifacts:
- `<paths>`

Remaining Yellow limits: `<none or list>`

Red blockers: `<none or list>`

Rollback commands:
- `<commands>`

Release/TestFlight/App Store readiness claimed: no unless current release proof exists

Next smallest safe repair train: `<AMB issue / train label or none>`
