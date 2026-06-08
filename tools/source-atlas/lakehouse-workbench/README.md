# Source Atlas Lakehouse Workbench 🪐

A standalone local developer workbench for generating, validating, deduplicating, warehousing, compiling, and publishing Source Atlas goal intent and domain knowledge.

## Setup Requirements

- **Python 3.12+**
- **Wrangler CLI** (optional, for remote R2 catalog uploads)
- **Local Settings File**: Create a `.env` file in this directory based on the `.env.example` template:
  ```bash
  GEMINI_API_KEY=your_key_here
  CLOUDFLARE_ACCOUNT_ID=your_id_here
  CLOUDFLARE_R2_ACCESS_KEY_ID=your_key_here
  CLOUDFLARE_R2_SECRET_ACCESS_KEY=your_secret_here
  CLOUDFLARE_R2_BUCKET_NAME=source-atlas-staged
  ```

---

## Local Directory Structure

All run files, cache, and warehouses are stored inside local runs directories to prevent credential leakage or dirty Git commits:
`C:\Users\Devan\SourceAtlasFactory\runs\<run_id>\`
- `raw/`: Raw JSONL batch requests and Gemini Batch API downloads.
- `clean/`: Validated, expanded, and deduplicated goal intent records.
  - `parquet/`: Warehouse tables in Parquet formats.
- `rejected/`: Records containing shaming language, private PII, credentials, or invalid runtime parameters.
- `reports/`: Local DuckDB file (`qa_warehouse.db`) and audit JSON/markdown reports.
- `publish/`: App-facing staged JSON/JSONL index artifacts ready to upload.

---

## Data Safety Compliance Gates

The workbench strictly enforces data safety policies to guarantee no leak of private information or invalid matching parameters:
1. **Runtime Eligibility Lock**: A goal intent record can only have `runtime_eligible: true` if:
   - `runtime_role` is exactly `"intent_matching_only"`.
   - `blocked_for_step_generation` is exactly `true`.
   - Seeds and source-backed records (`evidence_quality` matches `seed_archetype`, `peer_reviewed`, `professional_guidance_required`) must remain runtime ineligible.
2. **PII and Secret Filters**:
   - Matches intent phrase text against regex patterns for email addresses, phone numbers, and potential credentials (like `sk-...` API keys).
   - If any violation is found, `private_data_flag` is set and the record is written to `rejected/`.
3. **No Shaming Urgency**:
   - Intent phrases containing terms that produce guilt or shame (e.g. "streak broken", "productivity dropped", "shame") are rejected.

---

## How to Launch

On a Windows system using PowerShell:

### 1. Launch Streamlit UI
This script creates a local Python virtual environment, installs dependencies, and runs the Streamlit server:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_workbench.ps1
```
The app will open automatically in your browser at `http://localhost:8501`.

### 2. Run Verification Suite
Runs full syntax compilation, Pytest unit tests, sample run validation, DuckDB SQL audits, staged index compilation, and Wrangler dry-run object uploads:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate_workbench.ps1
```
Verify the output scorecard reports `Status: GREEN`.
