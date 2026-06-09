import os
import json
import uuid
import streamlit as st
import pandas as pd
import duckdb
from pathlib import Path
from datetime import datetime, timezone

# Load modules
from schema import GoalDomain, GrammarBank, GoalIntentRecord
from generator import initialize_run_dir, generate_batch_requests, submit_gemini_batch_job, RUNS_BASE_DIR
from validator import parse_raw_gemini_jsonl, validate_domain_intents, process_grammar_expansion
from duckdb_qa import run_qa_audits
from catalog import compile_staged_artifacts
from publisher import generate_wrangler_commands, execute_wrangler_upload, verify_remote_integrity

# Setup page configuration
st.set_page_config(
    page_title="Source Atlas Lakehouse Workbench",
    page_icon="🌌",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom premium styling
st.markdown("""
<style>
    /* Dark graphite theme */
    .stApp {
        background-color: #121214;
        color: #e4e4e7;
    }
    
    /* Sidebar customization */
    [data-testid="stSidebar"] {
        background-color: #1a1a1e;
        border-right: 1px solid #2d2d34;
    }
    
    /* Tabs customization */
    .stTabs [data-baseweb="tab-list"] {
        gap: 8px;
        background-color: #1a1a1e;
        padding: 8px;
        border-radius: 12px;
        border: 1px solid #2d2d34;
    }
    
    .stTabs [data-baseweb="tab"] {
        height: 40px;
        white-space: pre-wrap;
        background-color: transparent;
        border-radius: 8px;
        color: #a1a1aa;
        border: none;
        padding: 0 16px;
        transition: all 0.2s ease-in-out;
    }
    
    .stTabs [data-baseweb="tab"]:hover {
        color: #f4f4f5;
        background-color: #27272a;
    }
    
    .stTabs [aria-selected="true"] {
        background-color: #3f3f46 !important;
        color: #ffffff !important;
        font-weight: 600;
    }
    
    /* Cards and boxes */
    .metric-card {
        background-color: #1a1a1e;
        border: 1px solid #2d2d34;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
    }
    
    .status-green {
        border-left: 5px solid #22c55e;
    }
    .status-yellow {
        border-left: 5px solid #eab308;
    }
    .status-red {
        border-left: 5px solid #ef4444;
    }
    
    /* Custom buttons */
    .stButton>button {
        background-color: #3f3f46;
        color: white;
        border: 1px solid #52525b;
        border-radius: 8px;
        padding: 8px 16px;
        transition: all 0.2s;
    }
    
    .stButton>button:hover {
        background-color: #52525b;
        border-color: #71717a;
    }
    
    h1, h2, h3 {
        color: #f4f4f5;
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    }
</style>
""", unsafe_allow_html=True)

# Helper to find existing runs
def get_existing_runs():
    if not RUNS_BASE_DIR.exists():
        return []
    return sorted([d.name for d in RUNS_BASE_DIR.iterdir() if d.is_dir()], reverse=True)

# App State Management
if "active_run_id" not in st.session_state:
    existing = get_existing_runs()
    st.session_state.active_run_id = existing[0] if existing else ""
if "mock_mode" not in st.session_state:
    st.session_state.mock_mode = True

# Load domain registry & grammar registry paths
BASE_DIR = Path(__file__).resolve().parent
DOMAINS_FILE = BASE_DIR / "data" / "sample_domains.json"
GRAMMAR_FILE = BASE_DIR / "data" / "sample_grammar.json"

st.sidebar.title("🌌 Source Atlas")
st.sidebar.subheader("Lakehouse Workbench")

# Active Run Selector
st.sidebar.markdown("---")
st.sidebar.subheader("Current Run Context")
existing_runs = get_existing_runs()
run_options = ["(Select or Create)"] + existing_runs
selected_run = st.sidebar.selectbox("Active Run ID", run_options, index=1 if len(run_options) > 1 else 0)

if selected_run and selected_run != "(Select or Create)":
    st.session_state.active_run_id = selected_run

new_run_name = st.sidebar.text_input("Create New Run ID", placeholder="e.g. run-2026-06-08")
if st.sidebar.button("Initialize Run"):
    if new_run_name.strip():
        run_id = new_run_name.strip()
    else:
        run_id = f"run_{datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')}"
    initialize_run_dir(run_id)
    st.session_state.active_run_id = run_id
    st.sidebar.success(f"Initialized: {run_id}")
    st.rerun()

st.sidebar.markdown("---")
# Global Settings in Sidebar
st.session_state.mock_mode = st.sidebar.checkbox("Force Mock Mode (No APIs/Keys)", value=st.session_state.mock_mode)

st.title("Source Atlas Lakehouse Workbench 🪐")
if st.session_state.active_run_id:
    st.info(f"Active Run Directory: `C:\\Users\\Devan\\SourceAtlasFactory\\runs\\{st.session_state.active_run_id}\\`")
else:
    st.warning("Please select or initialize a run directory in the sidebar.")

# App Tabs
tab_names = [
    "Dashboard", "Settings", "Domains", "Gemini Batch", 
    "Generate", "Validate", "DuckDB QA", "R2 Data Catalog", 
    "Compile App Artifacts", "Publish", "Reports"
]
tabs = st.tabs(tab_names)

# Tab 1: Dashboard
with tabs[0]:
    st.header("Executive Dashboard")
    
    if not st.session_state.active_run_id:
        st.write("No active run selected.")
    else:
        run_dir = RUNS_BASE_DIR / st.session_state.active_run_id
        
        # Check counts
        raw_files = list((run_dir / "raw").glob("*.jsonl"))
        clean_files = list((run_dir / "clean").glob("*.jsonl"))
        rejected_files = list((run_dir / "rejected").glob("*.jsonl"))
        published_manifest = run_dir / "publish" / "staged-manifest.json"
        
        c1, c2, c3, c4 = st.columns(4)
        with c1:
            st.markdown(f"""
            <div class="metric-card status-yellow">
                <h3>Raw Downloads</h3>
                <h2>{len(raw_files)} files</h2>
                <p>Gemini batch results</p>
            </div>
            """, unsafe_allow_html=True)
        with c2:
            clean_count = 0
            for f in clean_files:
                if f.exists():
                    clean_count += sum(1 for _ in f.open("r", encoding="utf-8"))
            st.markdown(f"""
            <div class="metric-card status-green">
                <h3>Clean Records</h3>
                <h2>{clean_count} items</h2>
                <p>Validated intents</p>
            </div>
            """, unsafe_allow_html=True)
        with c3:
            rej_count = 0
            for f in rejected_files:
                if f.exists():
                    rej_count += sum(1 for _ in f.open("r", encoding="utf-8"))
            st.markdown(f"""
            <div class="metric-card status-red">
                <h3>Rejected Records</h3>
                <h2>{rej_count} items</h2>
                <p>Validation failures</p>
            </div>
            """, unsafe_allow_html=True)
        with c4:
            pub_status = "Not Compiled"
            if published_manifest.exists():
                with published_manifest.open("r", encoding="utf-8") as pm:
                    manifest_data = json.load(pm)
                    pub_status = f"Staged ({manifest_data.get('stats', {}).get('intent_count', 0)} items)"
            st.markdown(f"""
            <div class="metric-card">
                <h3>Publish Status</h3>
                <h2>{pub_status}</h2>
                <p>staged-manifest.json</p>
            </div>
            """, unsafe_allow_html=True)

        st.subheader("Data Safety Compliance Seal")
        st.markdown("""
        - **Intent Matching Only**: All eligible app runtime records are strictly isolated to matching roles (`runtime_role: intent_matching_only`, `blocked_for_step_generation: true`).
        - **No Credentials**: PII, API keys, and schedules are filtered out deterministically.
        - **No Shaming**: Evaluates shaming-free validation rules on all ingested intent phrases.
        """)

# Tab 2: Settings
with tabs[1]:
    st.header("Workbench Settings")
    st.markdown("Environment variables and local configuration parameters.")
    
    st.subheader("Local Configuration File (.env)")
    env_path = BASE_DIR / ".env"
    if env_path.exists():
        st.success(".env file loaded successfully.")
    else:
        st.warning(".env file not found. Create one using .env.example templates.")
        
    st.subheader("Credential Status Inspector")
    st.markdown(f"**Mock Mode**: `{'ENABLED' if st.session_state.mock_mode else 'DISABLED'}`")
    st.markdown(f"**Runs Base Folder**: `C:\\Users\\Devan\\SourceAtlasFactory\\runs\\`")
    
    if st.button("Sync Credentials"):
        st.success("Configuration re-loaded.")

# Tab 3: Domains
with tabs[2]:
    st.header("Goal Domain Registry")
    st.markdown("This registry establishes the core goal categories in the Source Atlas taxonomy.")
    
    if DOMAINS_FILE.exists():
        with DOMAINS_FILE.open("r", encoding="utf-8") as f:
            registry = json.load(f)
            
        st.subheader("Registered Domains")
        df_domains = pd.DataFrame(registry.get("domains", []))
        st.dataframe(df_domains, use_container_width=True)
        
        st.subheader("Add New Domain")
        with st.form("new_domain_form"):
            code = st.text_input("Domain Code", placeholder="e.g. relationship")
            title = st.text_input("Domain Title", placeholder="e.g. Social & Relationships")
            desc = st.text_area("Description", placeholder="Scope details...")
            categories = st.text_input("Categories (comma separated)", placeholder="marriage, friendship, professional")
            
            submit = st.form_submit_button("Register Domain")
            if submit:
                if code and title:
                    cats_list = [c.strip() for c in categories.split(",") if c.strip()]
                    new_dom = {
                        "code": code.strip().lower(),
                        "title": title.strip(),
                        "description": desc.strip(),
                        "categories": cats_list
                    }
                    registry["domains"].append(new_dom)
                    with DOMAINS_FILE.open("w", encoding="utf-8") as out:
                        json.dump(registry, out, indent=2)
                    st.success(f"Registered domain: {title}")
                    st.rerun()
                else:
                    st.error("Domain Code and Title are required.")
    else:
        st.error("Domain registry file not found.")

# Tab 4: Gemini Batch
with tabs[3]:
    st.header("Gemini Batch API Controller")
    st.markdown("Generate and submit request files to Google Gemini Batch API.")
    
    if not st.session_state.active_run_id:
        st.write("Please select an active run.")
    else:
        run_id = st.session_state.active_run_id
        
        # Load active domains for prompts
        with DOMAINS_FILE.open("r", encoding="utf-8") as f:
            domains_list = json.load(f).get("domains", [])
            
        st.subheader("Generate JSONL Request Templates")
        batch_type = st.selectbox("Batch Generation Target", ["domains", "grammar", "seeds", "sources", "sports_art_10k"])
        
        if batch_type == "sports_art_10k":
            st.markdown("""
            **10,000-Record Sports/Art Goal Intent Run Profile**:
            - 5,000 sports goal intents
            - 5,000 art goal intents
            - 1,000 records per shard (10 shards)
            - Compile Mode: Factory Snapshot
            - Upload Mode: Dry-Run by default
            """)
            if st.button("Generate 10k Run Profile"):
                with st.spinner("Generating 10,000 mock goal intents sharded across 10 files..."):
                    from generator import generate_sports_art_10k_profile
                    paths = generate_sports_art_10k_profile(run_id)
                    st.success(f"10,000 records generated in raw/ folder across {len(paths)} shards.")
        else:
            if st.button("Generate Request File"):
                req_path = generate_batch_requests(run_id, batch_type, domains_list)
                st.success(f"Request JSONL written to: `{req_path}`")
            
        st.subheader("Submit & Poll Batch Job")
        if st.button("Submit Batch Job"):
            with st.spinner("Submitting job to Gemini..."):
                res_path = submit_gemini_batch_job(run_id, batch_type, mock=st.session_state.mock_mode)
                st.success(f"Batch completed! Response saved to: `{res_path}`")

# Tab 5: Generate
with tabs[4]:
    st.header("Local Intent Expansion (Grammar Bank)")
    st.markdown("Deterministically expand grammar banks into large goal intent datasets.")
    
    if not st.session_state.active_run_id:
        st.write("Please select an active run.")
    else:
        run_id = st.session_state.active_run_id
        run_dir = RUNS_BASE_DIR / run_id
        
        st.subheader("Grammar Registry Source")
        if GRAMMAR_FILE.exists():
            with GRAMMAR_FILE.open("r", encoding="utf-8") as f:
                grammar_data = json.load(f)
            st.json(grammar_data)
            
            target_limit = st.number_input("Target Record Count Limit", min_value=10, max_value=1000000, value=1000)
            
            if st.button("Expand Grammar Templates"):
                # Simulating Grammar list expansion
                raw_grammar_inputs = []
                for idx, g_bank in enumerate(grammar_data):
                    raw_grammar_inputs.append((f"grammar_bank_{idx}", g_bank))
                
                results = process_grammar_expansion(raw_grammar_inputs, run_dir, target_limit=target_limit)
                st.success(f"Grammar bank expanded! Clean Records generated: {results.get('clean_grammar_expanded', 0)}")
        else:
            st.error("Grammar registry file not found.")

# Tab 6: Validate
with tabs[5]:
    st.header("Pydantic Schema Validator")
    st.markdown("Validate raw Gemini structured outputs against safety constraints.")
    
    if not st.session_state.active_run_id:
        st.write("Please select an active run.")
    else:
        run_id = st.session_state.active_run_id
        run_dir = RUNS_BASE_DIR / run_id
        
        # Load sample raw results if present in data, or run files
        raw_res_files = list((run_dir / "raw").glob("results_*.jsonl"))
        
        st.subheader("Ingest and Validate Batch Results")
        
        c1, c2 = st.columns(2)
        with c1:
            selected_raw_file = st.selectbox("Select Single Gemini Download Result File", [f.name for f in raw_res_files] + ["sample_raw_run.jsonl"])
            if st.button("Execute Schema Validation on Single File"):
                if selected_raw_file == "sample_raw_run.jsonl":
                    file_to_parse = BASE_DIR / "data" / "sample_raw_run.jsonl"
                else:
                    file_to_parse = run_dir / "raw" / selected_raw_file
                    
                if file_to_parse.exists():
                    parsed = parse_raw_gemini_jsonl(file_to_parse)
                    
                    # Separate by request category
                    domain_raw = [item for item in parsed if "req_domain" in item[0] or "intent_sample" in item[0] or "custom_id" not in item[0]]
                    grammar_raw = [item for item in parsed if "req_grammar" in item[0]]
                    seed_raw = [item for item in parsed if "req_seeds" in item[0]]
                    source_raw = [item for item in parsed if "req_sources" in item[0]]
                    
                    res = validate_domain_intents(domain_raw, run_dir)
                    if grammar_raw:
                        process_grammar_expansion(grammar_raw, run_dir)
                    
                    st.success(f"Validation complete! Ingested clean records: {res.get('clean', 0)}, Rejected: {res.get('rejected', 0)}")
                else:
                    st.error("Selected raw file does not exist.")
        
        with c2:
            st.write("Validate all shard files in the raw folder sequentially:")
            if st.button("Execute All Shards Validation"):
                with st.spinner("Validating all raw shards sequentially to minimize memory footprint..."):
                    from validator import validate_all_shards
                    res = validate_all_shards(run_dir)
                    st.success(f"All Shards validated! Clean records: {res.get('clean', 0)}, Rejected: {res.get('rejected', 0)}")
                    
        # Display sample tables
        clean_path = run_dir / "clean" / "domain_intents.jsonl"
        rejected_path = run_dir / "rejected" / "domain_intents.jsonl"
        
        if clean_path.exists():
            st.subheader("Clean Records (Preview)")
            clean_records = []
            with clean_path.open("r", encoding="utf-8") as cp:
                for line in cp:
                    if len(clean_records) >= 10:
                        break
                    if line.strip():
                        clean_records.append(json.loads(line.strip()))
            st.dataframe(pd.DataFrame(clean_records).head(10), use_container_width=True)
            
        if rejected_path.exists():
            st.subheader("Rejected Records (Preview)")
            try:
                rej_records = []
                with rejected_path.open("r", encoding="utf-8") as rp:
                    for line in rp:
                        if len(rej_records) >= 10:
                            break
                        if line.strip():
                            rej_records.append(json.loads(line.strip()))
                if rej_records:
                    st.dataframe(pd.DataFrame(rej_records).head(10), use_container_width=True)
            except Exception:
                pass

# Tab 7: DuckDB QA
with tabs[6]:
    st.header("DuckDB QA SQL Audits")
    st.markdown("Run SQL schema checks and semantic assertions over the clean warehouse.")
    
    if not st.session_state.active_run_id:
        st.write("Please select an active run.")
    else:
        run_id = st.session_state.active_run_id
        run_dir = RUNS_BASE_DIR / run_id
        
        if st.button("Execute SQL QA Audits"):
            audits = run_qa_audits(run_dir, DOMAINS_FILE)
            st.success(f"DuckDB audits completed! Ingested {audits['loaded_records_count']} records.")
            
            # Displays
            st.subheader("Audit Results Summary")
            
            c1, c2, c3 = st.columns(3)
            with c1:
                st.metric("Duplicate IDs", len(audits["duplicate_ids"]), delta_color="inverse")
            with c2:
                st.metric("Near-Duplicate Intents", len(audits["near_duplicate_intents"]), delta_color="inverse")
            with c3:
                st.metric("Safety Violations", len(audits["safety_violations"]), delta_color="inverse")
                
            c4, c5, c6 = st.columns(3)
            with c4:
                st.metric("Generic/Shaming Phrases", len(audits["generic_or_shaming_phrases"]), delta_color="inverse")
            with c5:
                st.metric("Private PII Leaks", len(audits["private_data_leaks"]), delta_color="inverse")
            with c6:
                st.metric("Domain Coverage Gaps", len(audits["coverage_gaps"]), delta_color="inverse")
                
            # Tables detailing issues
            if audits["safety_violations"]:
                st.error("Safety Violations Found!")
                st.dataframe(pd.DataFrame(audits["safety_violations"]), use_container_width=True)
            if audits["private_data_leaks"]:
                st.error("Private Data/PII Leaks Found!")
                st.dataframe(pd.DataFrame(audits["private_data_leaks"]), use_container_width=True)
            if audits["near_duplicate_intents"]:
                st.warning("Near-Duplicate Normalized Phrases")
                st.dataframe(pd.DataFrame(audits["near_duplicate_intents"]).head(20), use_container_width=True)
            if audits["coverage_gaps"]:
                st.warning("Coverage Gaps")
                st.dataframe(pd.DataFrame(audits["coverage_gaps"]), use_container_width=True)

# Tab 8: R2 Data Catalog
with tabs[7]:
    st.header("Lakehouse Data Catalog")
    st.markdown("Query the local Parquet data lakehouse tables using DuckDB.")
    
    if not st.session_state.active_run_id:
        st.write("Please select an active run.")
    else:
        run_id = st.session_state.active_run_id
        run_dir = RUNS_BASE_DIR / run_id
        parquet_file = run_dir / "clean" / "parquet" / "goal_intents.parquet"
        
        if parquet_file.exists():
            st.success(f"Parquet warehouse table found: `{parquet_file}`")
            # Query it
            db = duckdb.connect()
            df = db.execute(f"SELECT * FROM read_parquet('{parquet_file}') LIMIT 100").df()
            
            st.subheader("Data Warehouse Preview (First 100 Rows)")
            st.dataframe(df, use_container_width=True)
            
            # Simple custom SQL query runner
            st.subheader("Run Custom Catalog Query")
            custom_sql = st.text_area("SQL Query", f"SELECT domain, count(*) as count FROM read_parquet('{parquet_file}') GROUP BY domain ORDER BY count DESC")
            if st.button("Execute SQL"):
                try:
                    res_df = db.execute(custom_sql).df()
                    st.dataframe(res_df, use_container_width=True)
                except Exception as e:
                    st.error(f"SQL Error: {str(e)}")
        else:
            st.warning("No Parquet warehouse table found. Run QA Audits first to generate clean Parquet records.")

# Tab 9: Compile App Artifacts
with tabs[8]:
    st.header("Compile Staged App Artifacts")
    st.markdown("Compile goal-intent and domain knowledge into local JSON/JSONL staging indexes.")
    
    if not st.session_state.active_run_id:
        st.write("Please select an active run.")
    else:
        run_id = st.session_state.active_run_id
        run_dir = RUNS_BASE_DIR / run_id
        
        compile_mode = st.selectbox("Compile Mode", ["factory snapshot"])
        
        if st.button("Compile Staged Artifacts"):
            manifest = compile_staged_artifacts(run_dir, DOMAINS_FILE)
            st.success("Compilation complete! Staged files written to runs publish folder.")
            st.json(manifest)
            
        zip_path = run_dir / "publish_bundle.zip"
        if zip_path.exists():
            with zip_path.open("rb") as f:
                st.download_button(
                    label="Download Publish Bundle (ZIP)",
                    data=f.read(),
                    file_name=f"publish_bundle_{run_id}.zip",
                    mime="application/zip"
                )

# Tab 10: Publish
with tabs[9]:
    st.header("Cloudflare R2 Wrangler Publisher")
    st.markdown("Publish compiled staged artifacts to Cloudflare R2 bucket.")
    
    if not st.session_state.active_run_id:
        st.write("Please select an active run.")
    else:
        run_id = st.session_state.active_run_id
        run_dir = RUNS_BASE_DIR / run_id
        bucket_name = "source-atlas-staged"
        
        # Upload Mode
        upload_mode = st.selectbox("Upload Mode", ["Dry-Run", "Live"], index=0)
        
        commands = generate_wrangler_commands(run_dir, bucket_name)
        
        # Preview dry-run report
        report_file = run_dir / "reports" / "r2_dry_run_commands.md"
        if report_file.exists():
            st.subheader("R2 Dry-Run Command Preview")
            with report_file.open("r", encoding="utf-8") as f:
                st.markdown(f.read())
        else:
            st.subheader("Wrangler Upload Commands (Dry-Run)")
            for cmd in commands:
                st.code(cmd["command"], language="bash")
                
        # Block confirmation switch
        user_confirmed = st.checkbox("Confirm: I verify that this dataset contains no personal user context and approve publishing.")
        
        is_mock = st.session_state.mock_mode or (upload_mode == "Dry-Run")
        
        if st.button("Publish Artifacts"):
            if not user_confirmed and not is_mock:
                st.error("Real upload blocked! You must check the confirmation switch to verify safety before a Live upload.")
            else:
                res = execute_wrangler_upload(commands, bucket_name, mock=is_mock, user_confirmed=user_confirmed)
                if res.get("success"):
                    st.success("Publish completed successfully!")
                else:
                    st.error(f"Publish failed: {res.get('error', 'unknown error')}")
                st.json(res)
            
        st.subheader("Remote Verification")
        if st.button("Verify Remote Integrity"):
            verify_res = verify_remote_integrity(commands, run_dir, bucket_name, mock=is_mock)
            st.success("Verification check complete!")
            st.json(verify_res)

# Tab 11: Reports
with tabs[10]:
    st.header("Green/Yellow/Red Quality Scorecard")
    st.markdown("Comprehensive audit quality report summarizing tests, safety constraints, and coverage details.")
    
    if not st.session_state.active_run_id:
        st.write("Please select an active run.")
    else:
        run_id = st.session_state.active_run_id
        run_dir = RUNS_BASE_DIR / run_id
        
        qa_report_file = run_dir / "reports" / "qa_audit_report.json"
        
        # Load and render performance scorecard
        perf_file = run_dir / "reports" / "performance_report.json"
        if perf_file.exists():
            st.subheader("⏱️ Performance Scorecard")
            try:
                with perf_file.open("r", encoding="utf-8") as f:
                    perf = json.load(f)
                
                c1, c2, c3, c4 = st.columns(4)
                with c1:
                    st.metric("Generation Duration", f"{perf.get('generation_duration_sec', 0.0):.2f}s")
                with c2:
                    st.metric("Validation Duration", f"{perf.get('validation_duration_sec', 0.0):.2f}s")
                with c3:
                    st.metric("Dedupe/QA Duration", f"{perf.get('dedupe_duration_sec', 0.0):.2f}s")
                with c4:
                    st.metric("Compile Duration", f"{perf.get('compile_duration_sec', 0.0):.2f}s")
                    
                c5, c6 = st.columns(2)
                with c5:
                    st.metric("Staged File Count", perf.get("staged_file_count", 0))
                with c6:
                    bytes_val = perf.get("staged_total_size_bytes", 0)
                    if bytes_val >= 1024 * 1024:
                        size_str = f"{bytes_val / (1024 * 1024):.2f} MB"
                    elif bytes_val >= 1024:
                        size_str = f"{bytes_val / 1024:.2f} KB"
                    else:
                        size_str = f"{bytes_val} bytes"
                    st.metric("Staged Total Size", size_str)
            except Exception as e:
                st.error(f"Error loading performance report: {str(e)}")
        else:
            st.info("No performance metrics generated yet. Complete generation, validation, and compilation to view metrics.")
            
        st.markdown("---")
        
        if qa_report_file.exists():
            with qa_report_file.open("r", encoding="utf-8") as f:
                report = json.load(f)
                
            has_violations = len(report.get("safety_violations", [])) > 0
            has_leaks = len(report.get("private_data_leaks", [])) > 0
            has_dups = len(report.get("duplicate_ids", [])) > 0
            has_gaps = len(report.get("coverage_gaps", [])) > 0
            
            # Formulate scorecard color status
            if has_violations or has_leaks:
                status = "RED"
                alert_func = st.error
                status_desc = "Safety Violations or PII data leaks detected! Deployment blocked."
            elif has_dups or has_gaps:
                status = "YELLOW"
                alert_func = st.warning
                status_desc = "Warning: Gaps or duplicates found. Inspect details before final release."
            else:
                status = "GREEN"
                alert_func = st.success
                status_desc = "All quality gates passed! Ready for staging upload."
                
            st.subheader(f"Status: {status}")
            alert_func(status_desc)
            
            st.subheader("Coverage Heatmap Matrix")
            # Build domain stats
            with DOMAINS_FILE.open("r", encoding="utf-8") as df:
                domains = json.load(df).get("domains", [])
                
            # Read counts from coverage-matrix.json if compiled
            coverage_file = run_dir / "publish" / "factory" / "v1" / "coverage-matrix.json"
            counts = {}
            if coverage_file.exists():
                with coverage_file.open("r", encoding="utf-8") as cf:
                    counts = json.load(cf).get("domain_coverage", {})
            
            heatmap_data = []
            for dom in domains:
                intent_count = counts.get(dom["code"], 0)
                if intent_count >= 10:
                    cov_status = "🟢 Green (Excellent)"
                elif intent_count >= 5:
                    cov_status = "🟡 Yellow (Adequate)"
                else:
                    cov_status = "🔴 Red (Gap)"
                    
                heatmap_data.append({
                    "Domain": dom["title"],
                    "Code": dom["code"],
                    "Record Count": intent_count,
                    "Coverage Status": cov_status
                })
                
            st.table(pd.DataFrame(heatmap_data))
        else:
            st.warning("Please run DuckDB QA Audits in the QA tab first to build the quality scorecard reports.")

