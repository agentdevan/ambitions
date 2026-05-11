# Xcode Toolchain Pinning

Date: 2026-05-11

## Pin files

- `.xcode-version` holds the active Xcode line used by local runners.
- `.mise.toml` pins local helper runtimes (python/node/ruby) and is non-blocking for Xcode checks unless strict.
- `Brewfile.ambitions-build-lab` captures local helper tooling requirements.

## Tool matrix

- Required: `xcodebuild`, `xcode-select`, `xcodegen` (for generated project mode)
- Optional: `xcbeautify`, `xcparse`, `yq`, `jq`, `watchman`, `mise`, `tmux`

## Runtime checks

- `scripts/ambitions-xcode-version-check.sh` validates:
  - `xcode-select -p`
  - `xcodebuild -version`
  - `.xcode-version` presence and match when present
- Fails hard only in `--strict` mode.

## Runner policy

- No mandatory internet installs are required during normal wrapper operation.
- `scripts/ambitions-build-lab-doctor.sh` prints required/missing optional tools and recommended lane.
- Missing optional tools are not treated as validation hard stops unless the active lane requires them.
