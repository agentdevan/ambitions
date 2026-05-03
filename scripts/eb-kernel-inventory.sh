#!/usr/bin/env bash
set -euo pipefail
for f in docs/canon/Ambitions_4_0_External_Brain_Foundation_Index.md docs/canon/Ambitions_4_0_Universal_Capture_Kernel.md docs/canon/Ambitions_4_0_Life_Memory_Graph_Kernel.md docs/canon/Ambitions_4_0_Trust_Privacy_And_User_Control_Kernel.md docs/canon/Ambitions_4_0_Product_Maturity_And_Onboarding_Kernel.md docs/canon/Ambitions_4_0_Accessibility_And_Cognitive_Load_Kernel.md; do test -f "$f"; done
rg -n "Status: Active planned Ambitions 4.0 scope" docs/canon/Ambitions_4_0_*External_Brain* docs/canon/Ambitions_4_0_*Kernel.md
