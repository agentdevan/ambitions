# Validation Runbook

1. Regenerate the project when `project.yml` or target wiring changed:
   - `xcodegen generate`
2. Run an unsigned simulator build:
   - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
3. Run unit tests when native logic changed:
   - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:AmbitionsTests test`
4. Run UI tests when flows or routing changed:
   - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:AmbitionsUITests test`
5. Run archive sanity when release/build graph changes are in scope:
   - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -configuration Release -destination "generic/platform=iOS" -archivePath output/Ambitions.xcarchive CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY=\"\" archive`
