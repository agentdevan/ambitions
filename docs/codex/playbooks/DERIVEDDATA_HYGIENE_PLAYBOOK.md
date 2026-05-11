# Playbook: DerivedData Hygiene

## Default policy

- Use `.codex/DerivedData/Ambitions` only.
- Do not delete global Xcode DerivedData folders.

## Commands

- Check: `scripts/ambitions-deriveddata-manager.sh status`
- Path: `scripts/ambitions-deriveddata-manager.sh path`

## When to clean

- `xcodegen_project_drift` or `stale_derived_data` class mapping (validator exit 23).

## Clean action

- `scripts/ambitions-deriveddata-manager.sh clean --batch <BATCH_ID> --reason "<reason>"`

## Recovery note

- Keep lane failures and mapped classification in the batch summary for reproducible reruns.
