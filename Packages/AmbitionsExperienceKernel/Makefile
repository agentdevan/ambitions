lint:
	python Scripts/ambitions_kernel_lint.py

report:
	python Scripts/generate_release_report.py

manifest:
	swift package dump-package >/tmp/ambitions_experience_kernel_package.json

validate: manifest lint report

performance:
	python Scripts/performance_budget_scan.py .

snapshots:
	python Scripts/generate_snapshot_matrix.py

validate-strong: validate performance snapshots
