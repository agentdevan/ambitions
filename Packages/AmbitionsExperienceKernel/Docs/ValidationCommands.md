# Validation Commands

From this package root:

```bash
swift package dump-package >/tmp/ambitions_kernel_package.json
python Scripts/ambitions_kernel_lint.py
python Scripts/generate_release_report.py
```

From `agentdevan/ambitions` after installation:

```bash
python Packages/AmbitionsExperienceKernel/Scripts/repo_truth_audit.py .
xcodebuild -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17 Pro" build
xcodebuild -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17 Pro" test
```

Release proof required:
- validation logs
- screenshot matrix
- accessibility notes
- performance notes
- rollback note per batch
