# Playbook: Xcode Simulator Sickness Recovery

## Symptoms

- simulator boot failures or non-discoverable destination
- intermittent `xcodebuild` failures that clear after simulator reboot

## Actions

1. Run `scripts/ambitions-xcode-sim-health.sh --json`.
2. Re-run validation lane with repair:
   - `scripts/ambitions-xcode-validate.sh --batch <BATCH> --lane focused-test --test ...`
3. If still failing, run:
   - `scripts/ambitions-xcode-sim-health.sh --json --repair`
4. Re-run once:
   - `scripts/ambitions-xcode-validate.sh --batch <BATCH> --lane focused-test --test ...`
5. If repeated failures continue, classify as `simulator_boot_failure` and stop with code 22.

## Stop conditions

- Persistently failing destination
- Repeating non-simulator failure classes (route through normal failure class)
- Missing simulator binary/tools in environment
