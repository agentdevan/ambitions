# AFEP-014 Vault Screenshot Packet

Batch: AFEP-014
Scope: Personal Vault projection in `You`

## Intended Screenshot Targets

- `You` -> `What Ambitions knows`
- `You` -> `Trust Center`
- `you.personal-vault-card`

## Rendered UI Objects

- Personal Vault title and subtitle
- Two sections:
  - Sensitive local signals
  - Permissions center
- Five visible rows:
  - Personal defaults
  - Local learning signals
  - Proof and receipts
  - Permission matrix
  - Protected storage boundary

## Accessibility Hooks

- The card exposes a panel accessibility label and value.
- Each row exposes visible labels for storage, export, reset, delete, provenance, privacy policy, and permission.

## Capture Status

- Visual screenshot proof was not captured in this phase.
- This packet records the intended capture target and the currently implemented render surface.
- Do not treat this file as rendered screenshot evidence.

## Validation Evidence

- Source projection is implemented in `Native/Ambitions/Features/You/YouScreen.swift`.
- Data projection is implemented in `Native/Ambitions/Features/You/YouFeatureService.swift`.
- The focused You feature service test lane passed.
