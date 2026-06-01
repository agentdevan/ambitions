# Validation Commands

From this package root:

```bash
swift package dump-package >/tmp/ambitions_kernel_package.json
python Scripts/ambitions_kernel_lint.py
python Scripts/generate_release_report.py
```

From `agentdevan/ambitions` after installation:

```bash
make experience-kernel-lint
make experience-kernel-repo-truth
make experience-kernel-performance
make experience-kernel-visual-qa
make experience-kernel-release-report
make experience-kernel-release-check
```

Direct script equivalents from `agentdevan/ambitions`:

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
