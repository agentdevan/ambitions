# Command log

Phase 0 commands were run from the isolated B02 worktree.

```sh
git fetch origin
git rev-parse HEAD main origin/main codex/today-flagship-calibration-slice
git status --short --branch
shasum -a 256 <owner-reference> <B01-full-matrix>
python3 scripts/ambitions-canon.py query "Today"
python3 scripts/ambitions-canon.py query "Start Here"
python3 scripts/ambitions-canon.py query "Crowned Edge Dock"
python3 scripts/ambitions-canon.py query "Still counts"
swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' \
  build CODE_SIGNING_ALLOWED=NO
git diff --check
```

No `clean` command was used. XcodeGen produced ignored local project state from
the unchanged tracked `project.yml`.
