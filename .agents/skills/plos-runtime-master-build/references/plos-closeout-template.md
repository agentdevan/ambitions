# PLOS Linear Closeout Template

Use this template for PLOS Linear comments or project closeouts. Fill it with actual evidence. Validate with:

```bash
python3 scripts/codex/linear-closeout-validate.py --program plos <closeout-file>
```

## Template

PLOS autonomous readiness hardening

Linear project: Ambitions Personal Life OS Runtime Master Build Program (`3cd7ed7e-96ca-4d18-ba27-60d533b4364c`)

Issues covered:
AMB-608 / PLOS-M00
AMB-609 / PLOS-M01
AMB-610 / PLOS-M02
AMB-611 / PLOS-M03
AMB-612 / PLOS-M04
AMB-613 / PLOS-M05
AMB-614 / PLOS-M06
AMB-615 / PLOS-M07
AMB-616 / PLOS-M08
AMB-627 / PLOS-M09
AMB-617 / PLOS-M10
AMB-618 / PLOS-M11
AMB-619 / PLOS-M12
AMB-620 / PLOS-M13
AMB-621 / PLOS-M14
AMB-622 / PLOS-M15
AMB-623 / PLOS-M16
AMB-624 / PLOS-M17
AMB-625 / PLOS-M18
AMB-628 / PLOS-M19
AMB-629 / PLOS-M20
AMB-630 / PLOS-M21
AMB-631 / PLOS-M22
AMB-632 / PLOS-M23
AMB-633 / PLOS-M24
AMB-634 / PLOS-M25
AMB-635 / PLOS-M26

Green/Yellow/Red status: `<Green/Yellow/Red for exact scope>`

Pushed to main: `<yes/no>`

Push hash: `<commit sha or not pushed>`

App source changed: no

Runtime features implemented: no

PLOS-M00 executed: no

Linear identifiers used: AMB issue identifiers only

Validation run:
- `<command>` - `<result>`

Red blockers: `<none or list>`

Yellow limits: `<none or list, including owner review if execution remains blocked>`

Owner approval claimed: no

Release/TestFlight/App Store readiness claimed: no

Next recommended action: owner review, then `AMB-608` / `PLOS-M00` if accepted.

## Child Template

Validate with:

```bash
python3 scripts/codex/linear-closeout-validate.py --program plos --scope child <closeout-file>
```

PLOS child closeout

Linear issue: `AMB-###`

Parent issue: `AMB-608`

Green/Yellow/Red status: `<Green/Yellow/Red for exact child scope>`

Pushed to main: `<yes/no>`

Push hash: `<commit sha or not pushed>`

App source changed: no

Runtime features implemented: no

PLOS-M00 executed: yes, parent gate in progress only

Linear identifiers used: AMB issue identifiers only

Validation run:
- `<command>` - `<result>`

Red blockers: `<none or list>`

Yellow limits: `<none or list>`

Owner approval claimed: no

Release/TestFlight/App Store readiness claimed: no

Next recommended action: `<next AMB child or parent gate>`
