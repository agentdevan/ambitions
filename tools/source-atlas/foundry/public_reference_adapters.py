"""Production-grade deterministic public-reference adapters for Source Atlas."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .adapter_sdk import (
    AUTHORITY_TIERS,
    CONFIDENCE_STATES,
    SOURCE_STATES,
    AdapterRunContext,
    SourceAdapter,
    output_checksum,
    write_fixture,
)
from .model import PRIVACY_BOUNDARY, stable_id, utc_now
from .schemas import SCHEMA_KINDS
from .terms_registry import policy_gate_for_output, terms_entry


ADAPTER_IDS = {
    "onet.database": "onet_public_reference_adapter",
    "bls.public.data.api": "bls_public_labor_adapter",
    "wikidata.crosswalk": "wikidata_crosswalk_adapter",
    "openalex.dataset": "openalex_research_context_adapter",
    "usajobs.search": "restricted_source_policy_adapter",
    "college-scorecard.api": "college_scorecard_education_adapter",
    "westpoint.redbook.computer_science_major": "west_point_redbook_computer_science_credential_adapter",
    "nara.constitution.presidency": "nara_constitution_civic_adapter",
    "cdc.physical-activity.basics": "cdc_physical_activity_basics_adapter",
    "official.statcan.table.13100974": "statcan_table_13100974_health_provider_ehi_adapter",
    "sba.business_guide.start_business": "sba_business_guide_adapter",
    "nps.recreation-safety": "nps_recreation_safety_adapter",
    "americorps.volunteer_rate_state": "americorps_volunteer_rate_state_adapter",
    "state.travel.public_travel": "state_travel_public_reference_adapter",
    "usa.gov.change_address": "usagov_change_address_adapter",
    "irs.when_to_file": "irs_when_to_file_tax_deadline_adapter",
    "cfpb.adult_financial_education": "cfpb_adult_financial_education_adapter",
    "usa.gov.benefits": "usagov_benefits_reference_adapter",
    "ready.gov.kit": "ready_gov_emergency_kit_adapter",
    "energy.gov.energy_saver": "energy_gov_energy_saver_adapter",
    "usa.gov.home_repair": "usagov_home_repair_reference_adapter",
    "creative-commons.licenses": "creative_commons_licenses_reference_adapter",
    "w3c.web-standards": "w3c_web_standards_reference_adapter",
    "loc.primary_sources": "library_of_congress_primary_sources_reference_adapter",
    "nih.medlineplus.wellness": "nih_medlineplus_wellness_reference_adapter",
    "openalex.personal_growth_research": "openalex_personal_growth_research_adapter",
    "cdc.positive_parenting": "cdc_positive_parenting_reference_adapter",
    "acf.healthy_marriage_fatherhood": "acf_healthy_marriage_fatherhood_reference_adapter",
    "childwelfare.family_support": "childwelfare_family_support_reference_adapter",
}


OCCUPATION_FIXTURES = [
    {"canonical": "occupation.software_engineer", "onet": "15-1252.00", "bls": "15-1252", "label": "Software Developers", "wikidata": "Q80993", "openalex": "T10860", "confidence": "high", "domain": "software"},
    {"canonical": "occupation.registered_nurse", "onet": "29-1141.00", "bls": "29-1141", "label": "Registered Nurses", "wikidata": "Q186360", "openalex": "T11191", "confidence": "high", "domain": "healthcare"},
    {"canonical": "occupation.airline_pilot", "onet": "53-2011.00", "bls": "53-2011", "label": "Airline Pilots, Copilots, and Flight Engineers", "wikidata": "Q2095549", "openalex": "T12372", "confidence": "medium", "domain": "aviation"},
    {"canonical": "occupation.teacher", "onet": "25-2031.00", "bls": "25-2031", "label": "Secondary School Teachers", "wikidata": "Q37226", "openalex": "T10236", "confidence": "medium", "domain": "education"},
    {"canonical": "occupation.electrician", "onet": "47-2111.00", "bls": "47-2111", "label": "Electricians", "wikidata": "Q175310", "openalex": None, "confidence": "high", "domain": "trades"},
    {"canonical": "occupation.lawyer", "onet": "23-1011.00", "bls": "23-1011", "label": "Lawyers", "wikidata": "Q40348", "openalex": "T10084", "confidence": "medium", "domain": "law"},
    {"canonical": "occupation.audio_engineer", "onet": "27-4014.00", "bls": "27-4014", "label": "Sound Engineering Technicians", "wikidata": "Q946996", "openalex": "T11419", "confidence": "medium", "domain": "music"},
    {"canonical": "occupation.small_business_owner", "onet": "11-1021.00", "bls": "11-1021", "label": "General and Operations Managers", "wikidata": "Q131512", "openalex": "T10033", "confidence": "low", "domain": "business"},
    {"canonical": "occupation.music_artist", "onet": "27-2042.00", "bls": "27-2042", "label": "Musicians and Singers", "wikidata": "Q639669", "openalex": "T11176", "confidence": "medium", "domain": "music"},
    {"canonical": "occupation.astronaut", "onet": "19-2012.00", "bls": None, "label": "Physicists and Astronomers / Astronaut candidate context", "wikidata": "Q11631", "openalex": "T10187", "confidence": "review_required", "domain": "space"},
]

SKILL_FIXTURES = [
    "critical thinking",
    "active learning",
    "complex problem solving",
    "communication",
    "systems analysis",
    "monitoring",
    "coordination",
    "quality control analysis",
    "operation monitoring",
    "instruction",
    "equipment maintenance",
    "judgment and decision making",
]

KNOWLEDGE_FIXTURES = [
    "engineering and technology",
    "mathematics",
    "medicine and dentistry",
    "education and training",
    "law and government",
    "business and management",
    "communications and media",
]

SCENARIOS = [
    "NASA astronaut",
    "nurse",
    "pilot",
    "teacher",
    "software engineer",
    "small business owner",
    "music artist",
    "audio engineer",
    "marathon runner",
    "electrician/apprenticeship",
    "lawyer",
    "medical school path",
    "career pivot",
    "still-counts pivot",
]

EDUCATION_FIXTURES = [
    {
        "institution": "University of California, Berkeley",
        "unit_id": "110635",
        "program": "Computer and Information Sciences, General",
        "credential": "bachelor_degree",
        "claim_confidence": "medium",
        "jurisdiction": "US",
        "institution_type": "public_four_year",
    },
    {
        "institution": "Miami Dade College",
        "unit_id": "135717",
        "program": "Registered Nursing/Registered Nurse",
        "credential": "associate_degree",
        "claim_confidence": "medium",
        "jurisdiction": "US",
        "institution_type": "public_two_year",
    },
    {
        "institution": "CUNY City College",
        "unit_id": "190567",
        "program": "Education, General",
        "credential": "bachelor_degree",
        "claim_confidence": "medium",
        "jurisdiction": "US",
        "institution_type": "public_four_year",
    },
]

EDUCATION_CREDENTIAL_REQUIREMENT_FIXTURES = [
    {
        "subject": "institution.west_point.computer_science_major.curriculum",
        "label": "West Point Computer Science major curriculum reference",
        "claim_type": "credential_requirement",
        "text": "The United States Military Academy Redbook publishes official Computer Science major curriculum requirements as a bounded public institutional credential reference.",
        "gate_type": "institutional_credential_requirement_reference_only",
        "confidence": "high",
        "program": "Computer Science major",
        "credential": "Bachelor of Science",
    },
    {
        "subject": "institution.west_point.computer_science_major.depth_sequence",
        "label": "West Point Computer Science depth sequence reference",
        "claim_type": "credential_requirement",
        "text": "The United States Military Academy Redbook represents the Computer Science major as an institutional curriculum path with listed depth-sequence and program requirement context.",
        "gate_type": "institutional_curriculum_reference_only",
        "confidence": "high",
        "program": "Computer Science major",
        "credential": "Bachelor of Science",
    },
]

CIVIC_REQUIREMENT_FIXTURES = [
    {
        "subject": "presidential_eligibility.age",
        "label": "Presidential age eligibility reference",
        "claim_type": "eligibility_requirement",
        "text": "U.S. presidential eligibility includes a minimum age requirement as a public constitutional reference.",
        "gate_type": "public_civic_reference_only",
        "confidence": "high",
    },
    {
        "subject": "presidential_eligibility.citizenship_and_residency",
        "label": "Presidential citizenship and residency eligibility reference",
        "claim_type": "constitutional_requirement",
        "text": "U.S. presidential eligibility includes citizenship and residence-duration requirements as public constitutional references.",
        "gate_type": "public_constitutional_reference_only",
        "confidence": "high",
    },
]

BUSINESS_ENTREPRENEURSHIP_FIXTURES = [
    {
        "subject": "business_guide.business_plan",
        "label": "SBA business plan public reference",
        "claim_type": "business_formation_reference",
        "text": "The U.S. Small Business Administration business guide lists writing a business plan as a public business-startup reference, not as legal, tax, accounting, or personalized incorporation advice.",
        "gate_type": "public_business_startup_reference_only",
        "confidence": "high",
        "topic": "business plan",
    },
    {
        "subject": "business_guide.business_structure",
        "label": "SBA business structure public reference",
        "claim_type": "business_formation_reference",
        "text": "The U.S. Small Business Administration business guide lists choosing a business structure as a public startup reference that may require separate legal, tax, or professional confirmation.",
        "gate_type": "public_business_startup_reference_only",
        "confidence": "high",
        "topic": "business structure",
    },
    {
        "subject": "business_guide.funding",
        "label": "SBA funding public program reference",
        "claim_type": "public_program_reference",
        "text": "The U.S. Small Business Administration business guide includes public funding-reference context for starting a business, not a financing guarantee or personalized business plan.",
        "gate_type": "public_business_program_reference_only",
        "confidence": "high",
        "topic": "funding",
    },
]

HOBBIES_RECREATION_FIXTURES = [
    {
        "subject": "recreation_safety.trip_planning",
        "label": "NPS trip planning public recreation safety reference",
        "claim_type": "safety_guidance_reference",
        "text": "The National Park Service Health & Safety page points visitors to trip planning and preparedness as public recreation safety context, not emergency advice or a personalized outdoor plan.",
        "gate_type": "public_recreation_safety_reference_only",
        "confidence": "high",
        "topic": "trip planning",
    },
    {
        "subject": "recreation_safety.recreate_responsibly",
        "label": "NPS recreate responsibly public reference",
        "claim_type": "public_rules_reference",
        "text": "The National Park Service Health & Safety page references recreating responsibly, being prepared, and understanding limits as public recreation reference context, not unsafe instructions or a guarantee of safety.",
        "gate_type": "public_recreation_rules_reference_only",
        "confidence": "high",
        "topic": "recreate responsibly",
    },
    {
        "subject": "recreation_learning.health_and_safety_topics",
        "label": "NPS health and safety learning topics public reference",
        "claim_type": "learning_resource_reference",
        "text": "The National Park Service Health & Safety page lists public learning topics such as trip planning, severe weather, and healthy parks resources for general reference only.",
        "gate_type": "public_recreation_learning_reference_only",
        "confidence": "high",
        "topic": "health and safety topics",
    },
]

VOLUNTEERING_PUBLIC_REFERENCE_FIXTURES = [
    {
        "subject": "volunteering.civic_life.volunteer_rate",
        "label": "AmeriCorps volunteer-rate public data reference",
        "claim_type": "volunteer_rate_reference",
        "text": "AmeriCorps Open Data publishes State Ranking by Volunteer Rate as official public-domain volunteering and civic-life reference data for state-level volunteer-rate context, not as a current opportunity listing, eligibility decision, or personalized placement recommendation.",
        "gate_type": "public_volunteering_statistical_reference_only",
        "confidence": "high",
        "topic": "state volunteer rate",
    },
    {
        "subject": "volunteering.civic_life.civic_engagement",
        "label": "AmeriCorps civic engagement public data reference",
        "claim_type": "civic_engagement_reference",
        "text": "AmeriCorps Open Data describes volunteering and civic engagement trends and analysis for public reference only, not as service-program legal advice, a requirement guarantee, or a personalized volunteering plan.",
        "gate_type": "public_civic_engagement_reference_only",
        "confidence": "high",
        "topic": "civic engagement trends",
    },
    {
        "subject": "volunteering.civic_life.dataset_scope",
        "label": "AmeriCorps volunteering dataset scope reference",
        "claim_type": "public_dataset_scope_reference",
        "text": "AmeriCorps Open Data metadata identifies the State Ranking by Volunteer Rate dataset as national, state-granularity public-domain reference data with biennial posting context; Source Atlas must not treat it as real-time volunteer opportunity availability.",
        "gate_type": "public_volunteering_dataset_scope_reference_only",
        "confidence": "high",
        "topic": "dataset scope and cadence",
    },
]

HEALTH_WELLNESS_FIXTURES = [
    {
        "subject": "physical_activity.adult_guideline_context",
        "label": "CDC adult physical activity public guideline reference",
        "claim_type": "public_health_guideline",
        "text": "CDC Physical Activity Basics publishes general adult aerobic and muscle-strengthening activity guideline context for public health reference only, not medical advice, diagnosis, treatment, individualized clearance, or a personalized fitness plan.",
        "gate_type": "public_health_guideline_reference_only",
        "confidence": "high",
        "topic": "adult physical activity guideline context",
    },
    {
        "subject": "physical_activity.activity_types",
        "label": "CDC physical activity type public taxonomy reference",
        "claim_type": "exercise_taxonomy",
        "text": "CDC Physical Activity Basics describes physical activity concepts such as aerobic activity, muscle strengthening, and intensity as general public reference terms, not as a personalized training prescription.",
        "gate_type": "public_exercise_taxonomy_reference_only",
        "confidence": "high",
        "topic": "physical activity types",
    },
    {
        "subject": "physical_activity.health_benefits_context",
        "label": "CDC physical activity benefits public wellness reference",
        "claim_type": "wellness_safety_reference",
        "text": "CDC Physical Activity Basics provides general public wellness context about physical activity and health benefits; Source Atlas must not use it for diagnosis, treatment, emergency advice, or individualized health decisions.",
        "gate_type": "public_wellness_safety_reference_only",
        "confidence": "high",
        "topic": "physical activity benefits context",
    },
]

STATCAN_HEALTH_PROVIDER_EHI_FIXTURES = [
    {
        "subject": "statcan.table_13_10_0974_01.ehi_indicators",
        "label": "Statistics Canada health care provider EHI indicator table reference",
        "claim_type": "public_statistical_reference",
        "text": "Statistics Canada Table 13-10-0974-01 publishes annual public aggregate statistics for electronic health information indicators among health care providers, with Canada and provincial breakdown context for public statistical reference only.",
        "gate_type": "public_health_statistical_reference_only",
        "confidence": "high",
        "topic": "electronic health information indicators",
    },
    {
        "subject": "statcan.table_13_10_0974_01.provider_context",
        "label": "Statistics Canada health care provider public context reference",
        "claim_type": "public_health_statistical_context",
        "text": "Statistics Canada Table 13-10-0974-01 describes aggregate health care provider electronic health information context; Source Atlas must not use it for medical advice, diagnosis, treatment planning, or personal health recommendations.",
        "gate_type": "public_health_context_reference_only",
        "confidence": "high",
        "topic": "health care provider public context",
    },
]

TRAVEL_STATE_FIXTURES = [
    {
        "subject": "travel_documents.us_passport_application_help",
        "label": "Travel.State.Gov passport application public reference",
        "claim_type": "official_travel_requirement",
        "text": "Travel.State.Gov publishes U.S. passport application help and resources as official public travel document reference context, not visa advice, legal advice, guaranteed eligibility, or a custom itinerary.",
        "gate_type": "public_travel_document_reference_only",
        "confidence": "high",
        "topic": "passport application help",
    },
    {
        "subject": "travel_safety.travel_advisories",
        "label": "Travel.State.Gov travel advisories public safety notice reference",
        "claim_type": "public_safety_notice",
        "text": "Travel.State.Gov publishes destination Travel Advisories with risk level indicators and issue dates as public safety notice context, not emergency advice, a safety guarantee, or itinerary planning.",
        "gate_type": "public_travel_safety_notice_reference_only",
        "confidence": "high",
        "topic": "travel advisories",
    },
]

USAGOV_RELOCATION_FIXTURES = [
    {
        "subject": "relocation_admin.change_address",
        "label": "USA.gov change-address public relocation admin reference",
        "claim_type": "relocation_admin_reference",
        "text": "USA.gov publishes public change-address reference context for USPS mail forwarding and other government services to update, not address submission, legal advice, or a custom moving plan.",
        "gate_type": "public_relocation_admin_reference_only",
        "confidence": "high",
        "topic": "change address",
    },
]

IRS_WHEN_TO_FILE_FIXTURES = [
    {
        "subject": "tax_deadlines.individual_return_due_date",
        "label": "IRS individual return filing deadline public reference",
        "claim_type": "tax_deadline_reference",
        "text": "IRS When to File guidance publishes public individual income tax return filing-deadline context, including the general April filing-deadline pattern and official-source exceptions, for reference only and not as tax advice or a personalized filing strategy.",
        "gate_type": "public_tax_deadline_reference_only",
        "confidence": "high",
        "topic": "individual return filing deadline",
    },
]

CFPB_FINANCIAL_EDUCATION_FIXTURES = [
    {
        "subject": "financial_education.budgeting_tools",
        "label": "CFPB adult financial education budgeting tools public reference",
        "claim_type": "public_financial_education",
        "text": "The Consumer Financial Protection Bureau publishes adult financial education tools and resources, including budgeting and money-management education context, as public reference only and not as investment, tax, debt, or personalized financial advice.",
        "gate_type": "public_financial_education_reference_only",
        "confidence": "high",
        "topic": "budgeting and money-management tools",
    },
]

USAGOV_BENEFITS_FIXTURES = [
    {
        "subject": "public_benefits.government_benefits_directory",
        "label": "USA.gov government benefits public reference",
        "claim_type": "official_benefit_program_reference",
        "text": "USA.gov publishes public government benefits reference context that helps people find official benefit-program information, not a benefits eligibility guarantee, application decision, legal advice, or personalized financial plan.",
        "gate_type": "public_benefit_program_reference_only",
        "confidence": "high",
        "topic": "government benefits",
    },
]

HOME_LIFE_READY_FIXTURES = [
    {
        "subject": "home_preparedness.emergency_kit",
        "label": "Ready.gov emergency kit public preparedness reference",
        "claim_type": "safety_reference",
        "text": "Ready.gov publishes Build A Kit as official public emergency-preparedness reference context for household readiness, not emergency response advice, a safety guarantee, unsafe repair instructions, a household schedule, or a personalized home plan.",
        "gate_type": "public_home_preparedness_reference_only",
        "confidence": "high",
        "topic": "emergency kit",
    },
]

HOME_LIFE_ENERGY_FIXTURES = [
    {
        "subject": "home_energy.home_energy_audits",
        "label": "DOE Energy Saver home energy audit public reference",
        "claim_type": "maintenance_guidance_reference",
        "text": "The Department of Energy Energy Saver page includes home energy audits as public home energy and maintenance context, not a contractor recommendation, unsafe repair instruction, utility guarantee, or personalized household schedule.",
        "gate_type": "public_home_energy_reference_only",
        "confidence": "high",
        "topic": "home energy audits",
    },
    {
        "subject": "home_energy.weatherization_topics",
        "label": "DOE Energy Saver weatherization public reference",
        "claim_type": "maintenance_guidance_reference",
        "text": "The Department of Energy Energy Saver page includes weatherization topics such as air sealing, insulation, moisture control, and ventilation as public reference context, not a diagnosis of a private home condition or a do-it-yourself repair plan.",
        "gate_type": "public_home_energy_reference_only",
        "confidence": "high",
        "topic": "weatherization topics",
    },
]

USAGOV_HOME_REPAIR_FIXTURES = [
    {
        "subject": "home_admin.home_repair_assistance",
        "label": "USA.gov home repair assistance public program reference",
        "claim_type": "public_service_reference",
        "text": "USA.gov publishes government home repair assistance program reference context for finding official repair and improvement assistance information, not eligibility approval, a loan decision, legal advice, contractor advice, or a personalized household plan.",
        "gate_type": "public_home_service_reference_only",
        "confidence": "high",
        "topic": "home repair assistance",
    },
]

CREATIVE_COMMONS_LICENSE_FIXTURES = [
    {
        "subject": "creative_metadata.creative_commons_license_list",
        "label": "Creative Commons public license list reference",
        "claim_type": "creative_metadata_reference",
        "text": "Creative Commons publishes a public list of CC licenses and public-domain tools as creative metadata reference context, not copyright permission, license-selection advice, trademark permission, or a final reuse decision.",
        "gate_type": "public_creative_license_metadata_reference_only",
        "confidence": "high",
        "topic": "CC licenses and public-domain tools",
    },
]

W3C_WEB_STANDARD_FIXTURES = [
    {
        "subject": "creative_standards.w3c_web_standards",
        "label": "W3C web standards public reference",
        "claim_type": "public_standard_reference",
        "text": "W3C publishes web standards and drafts as public standards-body reference context for web and creative-technical projects, not implementation advice, trademark permission, patent advice, or a final creative plan.",
        "gate_type": "public_web_standard_reference_only",
        "confidence": "high",
        "topic": "web standards",
    },
]

LOC_PRIMARY_SOURCE_FIXTURES = [
    {
        "subject": "creative_learning.loc_primary_sources",
        "label": "Library of Congress primary sources learning reference",
        "claim_type": "public_learning_resource",
        "text": "The Library of Congress publishes Getting Started with Primary Sources as public learning-reference context for creative research and teaching, not copyright clearance, source-use permission, or a final creative project plan.",
        "gate_type": "public_creative_learning_reference_only",
        "confidence": "high",
        "topic": "primary sources learning reference",
    },
]

MEDLINEPLUS_WELLNESS_FIXTURES = [
    {
        "subject": "personal_growth.medlineplus_wellness_topics",
        "label": "MedlinePlus wellness and lifestyle public learning reference",
        "claim_type": "public_learning_reference",
        "text": "MedlinePlus publishes public wellness and lifestyle topic summaries as official National Library of Medicine learning-reference context, not mental health treatment, diagnosis, a clinical recommendation, or a cloud-personalized self-improvement plan.",
        "gate_type": "public_personal_growth_learning_reference_only",
        "confidence": "high",
        "topic": "wellness and lifestyle topic summaries",
    },
    {
        "subject": "personal_growth.medlineplus_stress_sleep_topics",
        "label": "MedlinePlus stress and sleep public wellness reference",
        "claim_type": "sensitive_wellness_reference",
        "text": "MedlinePlus publishes public stress, sleep, and wellness topic summaries as sensitive wellness reference context that may inform local inspection, not diagnosis, treatment, emergency advice, therapy, or individualized health guidance.",
        "gate_type": "sensitive_wellness_reference_only",
        "confidence": "high",
        "topic": "stress and sleep wellness topics",
    },
]

OPENALEX_PERSONAL_GROWTH_RESEARCH_FIXTURES = [
    {
        "subject": "personal_growth.openalex_behavior_change_metadata",
        "label": "OpenAlex behavior-change research metadata reference",
        "claim_type": "research_metadata_reference",
        "text": "OpenAlex provides CC0 scholarly metadata that can identify research-topic context for behavior change and habit formation, as supporting research metadata only and not normative authority, medical treatment guidance, diagnosis, or a final personal-growth plan.",
        "gate_type": "public_research_metadata_reference_only",
        "confidence": "medium",
        "topic": "behavior change and habit formation research metadata",
    },
]

RELATIONSHIPS_CDC_PARENTING_FIXTURES = [
    {
        "subject": "relationships_family.cdc_positive_parenting_tips",
        "label": "CDC positive parenting public education reference",
        "claim_type": "public_education_reference",
        "text": "CDC Positive Parenting Tips publishes age-based public parenting education context for general family reference only, not therapy, diagnosis, legal custody advice, a personalized parenting plan, or a judgment about a private relationship.",
        "gate_type": "public_family_education_reference_only",
        "confidence": "high",
        "topic": "positive parenting tips",
    },
    {
        "subject": "relationships_family.cdc_child_development_context",
        "label": "CDC child development family support reference",
        "claim_type": "sensitive_support_reference",
        "text": "CDC child development and positive parenting reference material can support local source inspection for general family context, not clinical treatment, emergency advice, child protection decisions, custody advice, or a personalized family assessment.",
        "gate_type": "sensitive_family_support_reference_only",
        "confidence": "high",
        "topic": "child development family context",
    },
]

RELATIONSHIPS_ACF_HMRF_FIXTURES = [
    {
        "subject": "relationships_family.acf_healthy_marriage_program",
        "label": "ACF Healthy Marriage public program reference",
        "claim_type": "public_family_service_reference",
        "text": "The Administration for Children and Families publishes Healthy Marriage public program reference context for family and relationship education services, not therapy, legal advice, eligibility approval, relationship judgment, or a personalized relationship plan.",
        "gate_type": "public_family_program_reference_only",
        "confidence": "high",
        "topic": "healthy marriage program reference",
    },
    {
        "subject": "relationships_family.acf_responsible_fatherhood_program",
        "label": "ACF Responsible Fatherhood public program reference",
        "claim_type": "public_family_service_reference",
        "text": "The Administration for Children and Families publishes Responsible Fatherhood public program reference context for family services and education, not custody advice, legal advice, therapy, eligibility approval, or a private family profile.",
        "gate_type": "public_family_program_reference_only",
        "confidence": "high",
        "topic": "responsible fatherhood program reference",
    },
]

RELATIONSHIPS_CHILDWELFARE_SUPPORT_FIXTURES = [
    {
        "subject": "relationships_family.childwelfare_information_gateway",
        "label": "Child Welfare Information Gateway family support reference",
        "claim_type": "sensitive_support_reference",
        "text": "Child Welfare Information Gateway publishes official public family-support and child-welfare information resources as sensitive support reference context, not legal custody advice, child protection advice, emergency intervention, therapy, or personalized family assessment.",
        "gate_type": "sensitive_family_support_reference_only",
        "confidence": "high",
        "topic": "family support public resources",
    },
]


class FixturePublicReferenceAdapter(SourceAdapter):
    source_id = ""
    adapter_id = ""
    domain = ""

    def discover(self, context: AdapterRunContext) -> dict[str, Any]:
        entry = terms_entry(self.source_id)
        return {
            "sourceID": self.source_id,
            "sourceURL": entry["source_url"],
            "termsURL": entry["terms_url"],
            "sourceState": context.source_state,
            "fixtureMode": context.fixture_mode,
        }

    def fetch(self, discovered: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        return {
            "sourceID": self.source_id,
            "adapterID": self.adapter_id,
            "fetchedAt": context.resolved_at(),
            "sourceState": context.source_state,
            "raw": self._raw_fixture(context.source_state),
            "discovered": discovered,
        }

    def parse(self, fetched: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        raw = fetched["raw"]
        if context.source_state == "malformed":
            return {"valid": False, "error": "malformed fixture payload", "records": []}
        return {"valid": True, "records": raw.get("records", []), "signals": raw.get("signals", {})}

    def normalize(self, parsed: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        created_at = context.resolved_at()
        entry = terms_entry(self.source_id)
        state = self._source_state(context.source_state)
        normalized = {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.adapterOutput.v1",
            "sourceID": self.source_id,
            "adapterID": self.adapter_id,
            "domain": self.domain,
            "dataClass": "official_public_source",
            "publicReferenceOnly": True,
            "createdAt": created_at,
            "sourceState": state,
            "terms": _terms_slice(entry),
            "claims": [],
            "requirements": [],
            "atoms": [],
            "edges": [],
            "lattices": [],
            "recipes": [],
            "sourceStates": [state],
            "coverageRecords": [],
            "crosswalks": [],
            "nonClaims": _non_claims(),
        }
        if not parsed.get("valid"):
            normalized["sourceState"]["packEligible"] = False
            normalized["sourceState"]["blockedReasons"].append(parsed.get("error", "parse failed"))
            return normalized
        self._populate_normalized(normalized, parsed["records"], context)
        if context.source_state == "missing-provenance":
            normalized["claims"][0]["provenanceIDs"] = []
        if context.source_state == "private-field-injected":
            normalized["syntheticRejectedArtifact"] = {"dataClass": "non_public_adapter_fixture", "marker": "reject"}
        return normalized

    def validate_terms(self, normalized: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        return policy_gate_for_output(self.source_id, normalized)

    def emit_provenance(self, normalized: dict[str, Any], context: AdapterRunContext) -> list[dict[str, Any]]:
        entry = terms_entry(self.source_id)
        if context.source_state == "missing-provenance":
            return []
        basis = {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state}
        return [
            {
                "schemaVersion": 1,
                "kind": SCHEMA_KINDS["provenance"],
                "id": stable_id("provenance", basis),
                "versionID": "adapter-broad-coverage-train-01",
                "sourceID": self.source_id,
                "sourceURL": entry["source_url"],
                "publisher": entry["publisher"],
                "locator": entry["source_url"],
                "retrievedAt": context.resolved_at(),
                "contentHash": output_checksum(normalized.get("claims", []) + normalized.get("atoms", [])),
                "authorityTier": entry["authority_tier"],
                "license": entry["license"],
                "termsURL": entry["terms_url"],
                "freshnessCadence": entry["freshness_cadence"],
                "sourceState": context.source_state,
                "jurisdiction": entry["jurisdiction"],
                "dataClass": "public_provenance",
                "publicReferenceOnly": True,
            }
        ]

    def emit_coverage(self, normalized: dict[str, Any], context: AdapterRunContext) -> dict[str, Any]:
        claims = normalized.get("claims", [])
        requirements = normalized.get("requirements", [])
        atoms = normalized.get("atoms", [])
        crosswalks = normalized.get("crosswalks", [])
        blocked = not normalized.get("sourceState", {}).get("packEligible", False)
        return {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.coverageRecord.v2",
            "domain": self.domain,
            "sourceLane": self.source_id,
            "adapter": self.adapter_id,
            "scenarioCoverage": scenario_overlay_for_outputs(normalized),
            "sourceAuthority": terms_entry(self.source_id)["authority_tier"],
            "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
            "sourceCount": 1,
            "claimCount": len(claims),
            "requirementCount": len(requirements),
            "atomCount": len(atoms),
            "edgeCount": len(normalized.get("edges", [])),
            "crosswalkCount": len(crosswalks),
            "provenanceCompleteness": bool(normalized.get("provenance")),
            "licenseStatus": normalized["terms"]["termsReviewStatus"],
            "redistributionStatus": normalized["terms"]["redistributionPolicy"],
            "freshnessStatus": context.source_state,
            "sourceStateCoverage": SOURCE_STATES,
            "unsupportedClaims": sum(1 for claim in claims if claim.get("confidence") == "unsupported"),
            "conflictedClaims": sum(1 for claim in claims if claim.get("confidence") == "conflicted"),
            "reviewRequiredClaims": sum(1 for claim in claims if claim.get("reviewRequirement")),
            "staleCriticalClaims": sum(1 for claim in claims if claim.get("sourceState") == "stale-critical"),
            "noFalseCompletionCoverage": True,
            "packReadiness": "blocked" if blocked else "candidate",
            "r2Readiness": "blocked" if blocked else "candidate_local_only",
            "evidenceArtifactPaths": [],
            "dataClass": "public_freshness",
            "publicReferenceOnly": True,
        }

    def emit_fixtures(self, output_root: Path) -> list[dict[str, Any]]:
        written: list[dict[str, Any]] = []
        for state in SOURCE_STATES:
            payload = self.run(AdapterRunContext(source_state=state, fixture_mode=True, created_at="2026-06-27T00:00:00Z"))
            expected_valid = state not in {"private-field-injected"}
            expected_codes = ["unsupported_data_class"] if state == "private-field-injected" else []
            path = output_root / self.source_id / f"{state}.json"
            written.append(write_fixture(path, payload, expected_valid, expected_codes))
        return written

    def emit_pack_candidates(self, normalized: dict[str, Any], context: AdapterRunContext) -> list[dict[str, Any]]:
        gate = policy_gate_for_output(self.source_id, normalized)
        if not gate["packable"] or context.source_state != "current" or not normalized.get("provenance"):
            return []
        return [
            {
                "schemaVersion": 1,
                "kind": "ambitions.sourceAtlas.packCandidate.v1",
                "id": stable_id("pack_candidate", {"sourceID": self.source_id, "adapterID": self.adapter_id}),
                "sourceID": self.source_id,
                "adapterID": self.adapter_id,
                "domain": self.domain,
                "recordCounts": {
                    "claims": len(normalized.get("claims", [])),
                    "requirements": len(normalized.get("requirements", [])),
                    "atoms": len(normalized.get("atoms", [])),
                    "edges": len(normalized.get("edges", [])),
                    "crosswalks": len(normalized.get("crosswalks", [])),
                },
                "termsGate": gate,
                "doesNotStoreFinalUserPath": True,
                "doesNotCreateFinalSchedule": True,
                "dataClass": "public_reference_claim",
                "publicReferenceOnly": True,
            }
        ]

    def _source_state(self, state: str) -> dict[str, Any]:
        blocked_states = {"unavailable", "stale-critical", "conflicted", "revoked", "unsupported", "malformed", "rate-limited", "terms-blocked", "missing-provenance", "private-field-injected"}
        reasons = []
        if state in blocked_states:
            reasons.append(f"source_state_{state}_blocks_pack_output")
        return {
            "state": state,
            "packEligible": state not in blocked_states,
            "runtimeEligible": state == "current",
            "blockedReasons": reasons,
            "dataClass": "public_freshness",
            "publicReferenceOnly": True,
        }

    def _raw_fixture(self, state: str) -> dict[str, Any]:
        if state in {"unavailable", "rate-limited", "terms-blocked", "unsupported", "revoked"}:
            return {"records": [], "signals": {"state": state}}
        return {"records": self._base_records(), "signals": {"state": state}}

    def _base_records(self) -> list[dict[str, Any]]:
        raise NotImplementedError("concrete adapters must provide deterministic fixture records")

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        raise NotImplementedError


class OnetAdapter(FixturePublicReferenceAdapter):
    source_id = "onet.database"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "occupation"

    def _base_records(self) -> list[dict[str, Any]]:
        return OCCUPATION_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        for item in records:
            claim = _claim(self.source_id, item["canonical"], f"{item['label']} is represented in O*NET occupation and skill taxonomy fixtures.", "occupation_taxonomy", item["confidence"], context.source_state, [provenance_id])
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["canonical"], claim["id"], "public_occupation_context", [provenance_id], context.source_state))
            normalized["atoms"].append(_atom(self.source_id, item["canonical"], item["label"], "occupation", [provenance_id]))
            for skill in SKILL_FIXTURES[:6]:
                skill_atom = _atom(self.source_id, f"{item['canonical']}.{skill}", skill, "skill", [provenance_id])
                normalized["atoms"].append(skill_atom)
                normalized["edges"].append(_edge(self.source_id, item["canonical"], normalized["atoms"][-2]["id"], skill_atom["id"], "uses_skill", [provenance_id]))
        normalized["atoms"].extend(_atom(self.source_id, f"knowledge.{name}", name, "knowledge", [provenance_id]) for name in KNOWLEDGE_FIXTURES)
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))
        normalized["recipes"].append(_recipe(self.source_id, "Broad occupational foundation recipe", normalized["atoms"][:10], normalized["requirements"], [provenance_id]))


class BlsAdapter(FixturePublicReferenceAdapter):
    source_id = "bls.public.data.api"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "labor_market"

    def _base_records(self) -> list[dict[str, Any]]:
        return [item for item in OCCUPATION_FIXTURES if item.get("bls")]

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {"v1": "no_key_public_requests", "v2": "registration_key_required_for_higher_limits", "fixtureTestsRequireCredentials": False}
        for item in records:
            claim = _claim(self.source_id, item["canonical"], f"{item['label']} has BLS/SOC labor-market context available for public reference.", "labor_market_context", "high", context.source_state, [provenance_id])
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["canonical"], claim["id"], "labor_context_reference", [provenance_id], context.source_state))
            normalized["atoms"].append(_atom(self.source_id, f"bls.{item['bls']}", f"SOC {item['bls']}", "occupation_code", [provenance_id]))


class WikidataAdapter(FixturePublicReferenceAdapter):
    source_id = "wikidata.crosswalk"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "entity_crosswalk"

    def _base_records(self) -> list[dict[str, Any]]:
        return [item for item in OCCUPATION_FIXTURES if item.get("wikidata")]

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        for item in records:
            confidence = "conflicted" if item["canonical"] == "occupation.astronaut" and context.source_state == "conflicted" else item["confidence"]
            normalized["crosswalks"].append(_crosswalk(item, confidence, [provenance_id]))
            normalized["claims"].append(_claim(self.source_id, item["canonical"], f"{item['label']} has Wikidata entity crosswalk candidate {item['wikidata']}.", "entity_label_crosswalk", confidence, context.source_state, [provenance_id]))


class OpenAlexAdapter(FixturePublicReferenceAdapter):
    source_id = "openalex.dataset"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "scholarly_reference"

    def _base_records(self) -> list[dict[str, Any]]:
        return [item for item in OCCUPATION_FIXTURES if item.get("openalex")]

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["offlineBulkOption"] = {"represented": True, "route": "OpenAlex snapshot", "fixtureTestsRequireCredentials": False}
        for item in records:
            normalized["claims"].append(_claim(self.source_id, item["canonical"], f"{item['label']} has OpenAlex research topic context candidate {item['openalex']}.", "research_topic_context", "medium", context.source_state, [provenance_id]))
            normalized["atoms"].append(_atom(self.source_id, f"openalex.{item['openalex']}", item["openalex"], "research_topic", [provenance_id]))


class RestrictedSourcePolicyAdapter(FixturePublicReferenceAdapter):
    source_id = "usajobs.search"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "restricted_policy"

    def _base_records(self) -> list[dict[str, Any]]:
        return [{"source": "USAJOBS", "policy": "lookup_only_not_packable"}]

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["sourceState"]["packEligible"] = False
        normalized["sourceState"]["blockedReasons"].append("restricted_terms_not_redistributable")
        normalized["claims"].append(_claim(self.source_id, "restricted.usajobs", "USAJOBS is represented as lookup-only until redistributable terms are explicitly reviewed.", "restricted_source_policy", "review_required", "terms-blocked", [provenance_id], review=True))


class CollegeScorecardAdapter(FixturePublicReferenceAdapter):
    source_id = "college-scorecard.api"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "education_credentialing"

    def _base_records(self) -> list[dict[str, Any]]:
        return EDUCATION_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_no_key",
            "liveMode": "requires_live_flag_and_api_governance_budget",
            "packOutput": "allowed_for_bounded_public_reference_metadata_with_attribution",
        }
        review_required = bool(terms_entry(self.source_id)["review_required"])
        for item in records:
            institution_key = f"institution.{item['unit_id']}"
            institution_claim = _claim(
                self.source_id,
                institution_key,
                f"{item['institution']} appears in College Scorecard fixture metadata as a candidate public institution reference.",
                "candidate_institution_reference",
                item["claim_confidence"],
                context.source_state,
                [provenance_id],
                review=review_required,
            )
            program_claim = _claim(
                self.source_id,
                f"{institution_key}.{item['program']}.{item['credential']}",
                f"{item['institution']} has College Scorecard fixture metadata for {item['program']} at {item['credential']} level as a candidate public program reference.",
                "candidate_education_program_reference",
                item["claim_confidence"],
                context.source_state,
                [provenance_id],
                review=review_required,
            )
            normalized["claims"].extend([institution_claim, program_claim])
            normalized["requirements"].append(_requirement(self.source_id, institution_key, institution_claim["id"], "candidate_institution_reference_only", [provenance_id], context.source_state))
            normalized["requirements"].append(_requirement(self.source_id, f"{institution_key}.{item['credential']}", program_claim["id"], "candidate_program_reference_only", [provenance_id], context.source_state))
            institution_atom = _atom(self.source_id, institution_key, item["institution"], "institution", [provenance_id])
            program_atom = _atom(self.source_id, f"{institution_key}.{item['program']}", item["program"], "education_program", [provenance_id])
            credential_atom = _atom(self.source_id, f"credential.{item['credential']}", item["credential"], "credential_level", [provenance_id])
            normalized["atoms"].extend([institution_atom, program_atom, credential_atom])
            normalized["edges"].append(_edge(self.source_id, institution_key, institution_atom["id"], program_atom["id"], "offers_candidate_program_reference", [provenance_id]))
            normalized["edges"].append(_edge(self.source_id, f"{institution_key}.{item['credential']}", program_atom["id"], credential_atom["id"], "has_candidate_credential_level", [provenance_id]))
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class WestPointRedbookComputerScienceCredentialAdapter(FixturePublicReferenceAdapter):
    source_id = "westpoint.redbook.computer_science_major"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "education_credentialing"

    def _base_records(self) -> list[dict[str, Any]]:
        return EDUCATION_CREDENTIAL_REQUIREMENT_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_institution_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_institutional_requirement_reference_with_attribution",
        }
        institution_atom = _atom(self.source_id, "institution.west_point", "United States Military Academy", "institution", [provenance_id])
        program_atom = _atom(self.source_id, "institution.west_point.computer_science_major", "Computer Science major", "education_program", [provenance_id])
        credential_atom = _atom(self.source_id, "credential.bachelor_of_science", "Bachelor of Science", "credential_level", [provenance_id])
        normalized["atoms"].extend([institution_atom, program_atom, credential_atom])
        normalized["edges"].append(_edge(self.source_id, "west_point.offers_computer_science_major", institution_atom["id"], program_atom["id"], "offers_public_curriculum_reference", [provenance_id]))
        normalized["edges"].append(_edge(self.source_id, "west_point.computer_science_major.bs", program_atom["id"], credential_atom["id"], "has_public_credential_level_reference", [provenance_id]))
        for item in records:
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.educationCredentialRequirementCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "program": item["program"],
                    "credential": item["credential"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateAdmissionsAdvice": True,
                    "doesNotCreateDegreePlan": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class NaraConstitutionCivicAdapter(FixturePublicReferenceAdapter):
    source_id = "nara.constitution.presidency"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "public_civic_requirements"

    def _base_records(self) -> list[dict[str, Any]]:
        return CIVIC_REQUIREMENT_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_public_reference_with_attribution",
        }
        for item in records:
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.civicRequirementCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateLegalAdvice": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )


class SbaBusinessGuideAdapter(FixturePublicReferenceAdapter):
    source_id = "sba.business_guide.start_business"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "business_entrepreneurship"

    def _base_records(self) -> list[dict[str, Any]]:
        return BUSINESS_ENTREPRENEURSHIP_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_sba_public_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_business_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "sba.business_guide", "SBA 10 steps to start your business guide", "business_public_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "business_startup_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_business_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.businessEntrepreneurshipCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateLegalAdvice": True,
                    "doesNotCreateTaxAdvice": True,
                    "doesNotCreatePersonalizedIncorporationStrategy": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class NpsRecreationSafetyAdapter(FixturePublicReferenceAdapter):
    source_id = "nps.recreation-safety"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "hobbies_recreation"

    def _base_records(self) -> list[dict[str, Any]]:
        return HOBBIES_RECREATION_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_nps_public_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_recreation_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "nps.health_and_safety", "NPS Health & Safety public reference page", "recreation_public_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "recreation_safety_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_recreation_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.hobbiesRecreationCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateEmergencyAdvice": True,
                    "doesNotCreateUnsafeInstructions": True,
                    "doesNotCreatePersonalizedRecreationPlan": True,
                    "mediaReuseExcluded": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class AmeriCorpsVolunteerRateStateAdapter(FixturePublicReferenceAdapter):
    source_id = "americorps.volunteer_rate_state"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "volunteering_public_reference"

    def _base_records(self) -> list[dict[str, Any]]:
        return VOLUNTEERING_PUBLIC_REFERENCE_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_americorps_open_data_reference",
            "liveMode": "requires_live_flag_execute_flag_and_socrata_public_dataset_budget",
            "packOutput": "allowed_for_bounded_public_domain_volunteering_reference_with_attribution",
        }
        dataset_atom = _atom(
            self.source_id,
            "americorps.open_data.state_ranking_by_volunteer_rate",
            "AmeriCorps State Ranking by Volunteer Rate open data reference",
            "volunteering_public_reference_dataset",
            [provenance_id],
        )
        normalized["atoms"].append(dataset_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "volunteering_public_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], dataset_atom["id"], topic_atom["id"], "includes_public_volunteering_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.volunteeringPublicReferenceCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateRealTimeListings": True,
                    "doesNotCreateEligibilityAdvice": True,
                    "doesNotCreatePersonalizedPlacementRecommendation": True,
                    "doesNotCreatePersonalizedVolunteeringPlan": True,
                    "historicalStatisticalReferenceOnly": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class CdcPhysicalActivityBasicsAdapter(FixturePublicReferenceAdapter):
    source_id = "cdc.physical-activity.basics"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "health_wellness_reference"

    def _base_records(self) -> list[dict[str, Any]]:
        return HEALTH_WELLNESS_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_cdc_public_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_health_wellness_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "cdc.physical_activity_basics", "CDC Physical Activity Basics public reference", "public_health_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "public_health_wellness_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_health_wellness_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.healthWellnessReferenceCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateMedicalAdvice": True,
                    "doesNotCreateDiagnosis": True,
                    "doesNotCreateTreatmentPlan": True,
                    "doesNotCreatePersonalizedFitnessPlan": True,
                    "mediaReuseExcluded": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class StatCanTable13100974HealthProviderEHIAdapter(FixturePublicReferenceAdapter):
    source_id = "official.statcan.table.13100974"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "health_wellness_reference"

    def _base_records(self) -> list[dict[str, Any]]:
        return STATCAN_HEALTH_PROVIDER_EHI_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_statcan_table_reference",
            "liveMode": "requires_live_flag_execute_flag_and_static_download_budget",
            "packOutput": "allowed_for_bounded_public_statistical_reference_with_attribution",
        }
        table_atom = _atom(
            self.source_id,
            "statcan.table_13_10_0974_01",
            "Statistics Canada Table 13-10-0974-01",
            "public_statistical_table",
            [provenance_id],
        )
        normalized["atoms"].append(table_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "public_health_statistics_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], table_atom["id"], topic_atom["id"], "includes_public_health_statistical_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.healthWellnessStatisticalReferenceCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateMedicalAdvice": True,
                    "doesNotCreateDiagnosis": True,
                    "doesNotCreateTreatmentPlan": True,
                    "doesNotCreatePersonalHealthRecommendation": True,
                    "aggregateStatisticsOnly": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class StateTravelPublicReferenceAdapter(FixturePublicReferenceAdapter):
    source_id = "state.travel.public_travel"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "travel_relocation"

    def _base_records(self) -> list[dict[str, Any]]:
        return TRAVEL_STATE_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_state_travel_public_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_travel_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "state.travel.public_travel", "Travel.State.Gov public travel references", "public_travel_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "public_travel_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_travel_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.travelRelocationCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateVisaAdvice": True,
                    "doesNotCreateLegalAdvice": True,
                    "doesNotCreateEmergencyAdvice": True,
                    "doesNotCreateItinerary": True,
                    "mediaReuseExcluded": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class UsaGovChangeAddressAdapter(FixturePublicReferenceAdapter):
    source_id = "usa.gov.change_address"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "travel_relocation"

    def _base_records(self) -> list[dict[str, Any]]:
        return USAGOV_RELOCATION_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_usagov_public_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_relocation_admin_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "usa.gov.change_address", "USA.gov change-address public reference page", "public_relocation_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "public_relocation_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_relocation_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.travelRelocationCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotSubmitAddress": True,
                    "doesNotCreateLegalAdvice": True,
                    "doesNotCreateMovingPlan": True,
                    "mediaReuseExcluded": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class IrsWhenToFileAdapter(FixturePublicReferenceAdapter):
    source_id = "irs.when_to_file"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "finance_public_reference"

    def _base_records(self) -> list[dict[str, Any]]:
        return IRS_WHEN_TO_FILE_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_irs_tax_deadline_public_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_tax_deadline_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "irs.when_to_file", "IRS When to File public reference page", "public_tax_deadline_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "public_tax_deadline_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_tax_deadline_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.financePublicReferenceCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateTaxAdvice": True,
                    "doesNotCreateLegalAdvice": True,
                    "doesNotCreatePersonalizedFilingStrategy": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class CfpbAdultFinancialEducationAdapter(FixturePublicReferenceAdapter):
    source_id = "cfpb.adult_financial_education"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "finance_public_reference"

    def _base_records(self) -> list[dict[str, Any]]:
        return CFPB_FINANCIAL_EDUCATION_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_cfpb_financial_education_public_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_financial_education_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "cfpb.adult_financial_education", "CFPB adult financial education tools and resources", "public_financial_education_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "public_financial_education_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_financial_education_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.financePublicReferenceCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateInvestmentAdvice": True,
                    "doesNotCreateTaxAdvice": True,
                    "doesNotCreateDebtAdvice": True,
                    "doesNotCreatePersonalizedFinancialPlan": True,
                    "mediaReuseExcluded": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class UsaGovBenefitsAdapter(FixturePublicReferenceAdapter):
    source_id = "usa.gov.benefits"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "finance_public_reference"

    def _base_records(self) -> list[dict[str, Any]]:
        return USAGOV_BENEFITS_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_usagov_benefits_public_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_benefits_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "usa.gov.benefits", "USA.gov benefits public reference page", "public_benefits_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "public_benefits_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_benefit_program_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.financePublicReferenceCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateBenefitEligibilityGuarantee": True,
                    "doesNotCreateApplicationDecision": True,
                    "doesNotCreateLegalAdvice": True,
                    "doesNotCreatePersonalizedFinancialPlan": True,
                    "mediaReuseExcluded": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class ReadyGovEmergencyKitAdapter(FixturePublicReferenceAdapter):
    source_id = "ready.gov.kit"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "home_life_admin"

    def _base_records(self) -> list[dict[str, Any]]:
        return HOME_LIFE_READY_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_ready_gov_emergency_kit_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_home_preparedness_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "ready.gov.kit", "Ready.gov Build A Kit public reference page", "public_home_preparedness_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "home_preparedness_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_home_preparedness_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.homeLifeAdminCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateEmergencyAdvice": True,
                    "doesNotCreateSafetyGuarantee": True,
                    "doesNotCreateUnsafeRepairInstructions": True,
                    "doesNotCreateHouseholdPlanningOutput": True,
                    "doesNotCreatePersonalizedHomePlan": True,
                    "mediaReuseExcluded": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class EnergyGovEnergySaverAdapter(FixturePublicReferenceAdapter):
    source_id = "energy.gov.energy_saver"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "home_life_admin"

    def _base_records(self) -> list[dict[str, Any]]:
        return HOME_LIFE_ENERGY_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_doe_energy_saver_home_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_home_energy_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "energy.gov.energy_saver", "DOE Energy Saver public home energy reference page", "public_home_energy_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "home_energy_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_home_energy_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.homeLifeAdminCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateContractorRecommendation": True,
                    "doesNotCreateUnsafeRepairInstructions": True,
                    "doesNotCreateUtilityGuarantee": True,
                    "doesNotCreateHouseholdPlanningOutput": True,
                    "doesNotDiagnosePrivateHomeCondition": True,
                    "mediaReuseExcluded": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class UsaGovHomeRepairAdapter(FixturePublicReferenceAdapter):
    source_id = "usa.gov.home_repair"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "home_life_admin"

    def _base_records(self) -> list[dict[str, Any]]:
        return USAGOV_HOME_REPAIR_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_usagov_home_repair_public_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_home_service_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "usa.gov.home_repair", "USA.gov home repair assistance public reference page", "public_home_service_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "home_service_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_home_service_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.homeLifeAdminCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateEligibilityApproval": True,
                    "doesNotCreateLoanDecision": True,
                    "doesNotCreateLegalAdvice": True,
                    "doesNotCreateContractorAdvice": True,
                    "doesNotCreatePersonalizedHouseholdPlan": True,
                    "mediaReuseExcluded": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class CreativeCommonsLicensesReferenceAdapter(FixturePublicReferenceAdapter):
    source_id = "creative-commons.licenses"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "creative_project_reference"

    def _base_records(self) -> list[dict[str, Any]]:
        return CREATIVE_COMMONS_LICENSE_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_creative_commons_license_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_creative_license_metadata_with_attribution",
        }
        guide_atom = _atom(self.source_id, "creative-commons.licenses", "Creative Commons licenses public reference page", "public_creative_license_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "creative_metadata_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_creative_metadata_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.creativeProjectReferenceCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotGrantCopyrightPermission": True,
                    "doesNotCreateLicenseSelectionAdvice": True,
                    "doesNotGrantTrademarkPermission": True,
                    "doesNotCreateReuseDecision": True,
                    "doesNotCreateFinalCreativePlan": True,
                    "thirdPartyContentExcluded": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class W3CWebStandardsReferenceAdapter(FixturePublicReferenceAdapter):
    source_id = "w3c.web-standards"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "creative_project_reference"

    def _base_records(self) -> list[dict[str, Any]]:
        return W3C_WEB_STANDARD_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_w3c_web_standards_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_web_standards_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "w3c.web-standards", "W3C web standards public reference page", "public_web_standards_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "web_standard_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_web_standard_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.creativeProjectReferenceCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateImplementationAdvice": True,
                    "doesNotGrantTrademarkPermission": True,
                    "doesNotCreatePatentAdvice": True,
                    "doesNotCreateFinalCreativePlan": True,
                    "thirdPartyContentExcluded": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class LibraryOfCongressPrimarySourcesReferenceAdapter(FixturePublicReferenceAdapter):
    source_id = "loc.primary_sources"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "creative_project_reference"

    def _base_records(self) -> list[dict[str, Any]]:
        return LOC_PRIMARY_SOURCE_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_loc_primary_sources_learning_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_creative_learning_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "loc.primary_sources", "Library of Congress primary sources learning reference page", "public_creative_learning_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "creative_learning_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_creative_learning_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.creativeProjectReferenceCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotGrantCopyrightClearance": True,
                    "doesNotGrantSourceUsePermission": True,
                    "doesNotCreateFinalCreativePlan": True,
                    "thirdPartyCollectionItemsExcluded": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class NihMedlinePlusWellnessReferenceAdapter(FixturePublicReferenceAdapter):
    source_id = "nih.medlineplus.wellness"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "personal_growth"

    def _base_records(self) -> list[dict[str, Any]]:
        return MEDLINEPLUS_WELLNESS_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_medlineplus_wellness_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_wellness_topic_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "nih.medlineplus.wellness", "MedlinePlus wellness public reference pages", "public_wellness_learning_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "personal_growth_wellness_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_wellness_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.personalGrowthCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateMentalHealthTreatment": True,
                    "doesNotCreateDiagnosis": True,
                    "doesNotCreateClinicalRecommendation": True,
                    "doesNotCreateTherapy": True,
                    "doesNotCreateEmergencyAdvice": True,
                    "doesNotCreateCloudPersonalizedPlan": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class OpenAlexPersonalGrowthResearchAdapter(FixturePublicReferenceAdapter):
    source_id = "openalex.personal_growth_research"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "personal_growth"

    def _base_records(self) -> list[dict[str, Any]]:
        return OPENALEX_PERSONAL_GROWTH_RESEARCH_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_openalex_personal_growth_metadata_reference",
            "liveMode": "requires_live_flag_rate_budget_policy_and_high_volume_review_for_bulk_use",
            "packOutput": "allowed_for_bounded_cc0_scholarly_metadata_reference",
        }
        guide_atom = _atom(self.source_id, "openalex.personal_growth_research", "OpenAlex personal-growth scholarly metadata reference", "public_research_metadata_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "personal_growth_research_metadata_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_research_metadata_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.personalGrowthCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateNormativeAuthority": True,
                    "doesNotCreateMedicalTreatmentGuidance": True,
                    "doesNotCreateDiagnosis": True,
                    "doesNotCreateFinalPersonalGrowthPlan": True,
                    "highVolumeUseRequiresApproval": True,
                    "dataClass": "public_provenance",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class CdcPositiveParentingReferenceAdapter(FixturePublicReferenceAdapter):
    source_id = "cdc.positive_parenting"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "relationships_family"

    def _base_records(self) -> list[dict[str, Any]]:
        return RELATIONSHIPS_CDC_PARENTING_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_cdc_positive_parenting_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_parenting_education_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "cdc.positive_parenting", "CDC Positive Parenting Tips public reference pages", "public_family_education_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "relationships_family_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_family_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.relationshipsFamilyCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateTherapy": True,
                    "doesNotCreateDiagnosis": True,
                    "doesNotCreateLegalCustodyAdvice": True,
                    "doesNotCreateRelationshipJudgment": True,
                    "doesNotCreatePersonalizedParentingPlan": True,
                    "doesNotCreateEmergencyAdvice": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class AcfHealthyMarriageFatherhoodReferenceAdapter(FixturePublicReferenceAdapter):
    source_id = "acf.healthy_marriage_fatherhood"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "relationships_family"

    def _base_records(self) -> list[dict[str, Any]]:
        return RELATIONSHIPS_ACF_HMRF_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_acf_hmrf_reference",
            "liveMode": "requires_live_flag_and_static_page_budget; current environment may receive ACF WAF challenge",
            "packOutput": "allowed_for_bounded_public_family_program_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "acf.healthy_marriage_fatherhood", "ACF Healthy Marriage and Responsible Fatherhood public reference pages", "public_family_program_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "relationships_family_program_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_public_family_program_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.relationshipsFamilyCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateTherapy": True,
                    "doesNotCreateLegalAdvice": True,
                    "doesNotCreateLegalCustodyAdvice": True,
                    "doesNotCreateEligibilityGuarantee": True,
                    "doesNotCreateRelationshipJudgment": True,
                    "doesNotCreatePersonalizedRelationshipPlan": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


class ChildWelfareFamilySupportReferenceAdapter(FixturePublicReferenceAdapter):
    source_id = "childwelfare.family_support"
    adapter_id = ADAPTER_IDS[source_id]
    domain = "relationships_family"

    def _base_records(self) -> list[dict[str, Any]]:
        return RELATIONSHIPS_CHILDWELFARE_SUPPORT_FIXTURES

    def _populate_normalized(self, normalized: dict[str, Any], records: list[dict[str, Any]], context: AdapterRunContext) -> None:
        provenance_id = stable_id("provenance", {"sourceID": self.source_id, "adapterID": self.adapter_id, "state": context.source_state})
        normalized["apiLanes"] = {
            "fixtureMode": "no_network_static_childwelfare_family_support_reference",
            "liveMode": "requires_live_flag_and_static_page_budget",
            "packOutput": "allowed_for_bounded_public_family_support_reference_with_attribution",
        }
        guide_atom = _atom(self.source_id, "childwelfare.family_support", "Child Welfare Information Gateway public family support reference", "sensitive_family_support_reference_guide", [provenance_id])
        normalized["atoms"].append(guide_atom)
        for item in records:
            topic_atom = _atom(self.source_id, item["subject"], item["topic"], "sensitive_family_support_reference_topic", [provenance_id])
            normalized["atoms"].append(topic_atom)
            normalized["edges"].append(_edge(self.source_id, item["subject"], guide_atom["id"], topic_atom["id"], "includes_sensitive_family_support_reference", [provenance_id]))
            claim = _claim(
                self.source_id,
                item["subject"],
                item["text"],
                item["claim_type"],
                item["confidence"],
                context.source_state,
                [provenance_id],
            )
            normalized["claims"].append(claim)
            normalized["requirements"].append(_requirement(self.source_id, item["subject"], claim["id"], item["gate_type"], [provenance_id], context.source_state))
            normalized["coverageRecords"].append(
                {
                    "schemaVersion": 1,
                    "kind": "ambitions.sourceAtlas.relationshipsFamilyCoverage.v1",
                    "sourceID": self.source_id,
                    "subject": item["subject"],
                    "label": item["label"],
                    "claimType": item["claim_type"],
                    "jurisdiction": terms_entry(self.source_id)["jurisdiction"],
                    "doesNotCreateChildProtectionAdvice": True,
                    "doesNotCreateLegalCustodyAdvice": True,
                    "doesNotCreateEmergencyIntervention": True,
                    "doesNotCreateTherapy": True,
                    "doesNotCreatePersonalizedFamilyAssessment": True,
                    "dataClass": "public_freshness",
                    "publicReferenceOnly": True,
                }
            )
        normalized["lattices"].append(_lattice(self.source_id, normalized["atoms"], normalized["edges"], []))


def adapter_instances() -> list[SourceAdapter]:
    return [
        OnetAdapter(),
        BlsAdapter(),
        WikidataAdapter(),
        OpenAlexAdapter(),
        RestrictedSourcePolicyAdapter(),
        CollegeScorecardAdapter(),
        WestPointRedbookComputerScienceCredentialAdapter(),
        NaraConstitutionCivicAdapter(),
        CdcPhysicalActivityBasicsAdapter(),
        StatCanTable13100974HealthProviderEHIAdapter(),
        SbaBusinessGuideAdapter(),
        NpsRecreationSafetyAdapter(),
        AmeriCorpsVolunteerRateStateAdapter(),
        StateTravelPublicReferenceAdapter(),
        UsaGovChangeAddressAdapter(),
        IrsWhenToFileAdapter(),
        CfpbAdultFinancialEducationAdapter(),
        UsaGovBenefitsAdapter(),
        ReadyGovEmergencyKitAdapter(),
        EnergyGovEnergySaverAdapter(),
        UsaGovHomeRepairAdapter(),
        CreativeCommonsLicensesReferenceAdapter(),
        W3CWebStandardsReferenceAdapter(),
        LibraryOfCongressPrimarySourcesReferenceAdapter(),
        NihMedlinePlusWellnessReferenceAdapter(),
        OpenAlexPersonalGrowthResearchAdapter(),
        CdcPositiveParentingReferenceAdapter(),
        AcfHealthyMarriageFatherhoodReferenceAdapter(),
        ChildWelfareFamilySupportReferenceAdapter(),
    ]


def run_all_adapters(source_state: str = "current", created_at: str | None = None) -> list[dict[str, Any]]:
    context = AdapterRunContext(source_state=source_state, fixture_mode=True, created_at=created_at or utc_now())
    return [adapter.run(context) for adapter in adapter_instances()]


def emit_all_adapter_fixtures(output_root: Path) -> dict[str, Any]:
    written: list[dict[str, Any]] = []
    for adapter in adapter_instances():
        written.extend(adapter.emit_fixtures(output_root))
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.adapterFixtureManifest.v1",
        "fixtureCount": len(written),
        "sourceStates": SOURCE_STATES,
        "fixtures": written,
    }


def scenario_overlay_for_outputs(output: dict[str, Any]) -> list[dict[str, Any]]:
    source_state = output.get("sourceState", {}).get("state", "unsupported")
    domain = output.get("domain")
    rows: list[dict[str, Any]] = []
    for scenario in SCENARIOS:
        status = "partially covered"
        reason = "public foundation references available, no user path generated"
        if source_state == "stale":
            status, reason = "stale", "source state is stale"
        elif source_state == "stale-critical":
            status, reason = "stale-critical", "critical stale source blocked from runtime use"
        elif source_state in {"unavailable", "unsupported", "malformed", "rate-limited"}:
            status, reason = "unsupported", f"source state {source_state}"
        elif source_state == "terms-blocked" or output.get("terms", {}).get("redistributionPolicy") == "lookup_only_not_packable":
            status, reason = "not packable due to terms", "terms registry blocks redistribution"
        elif source_state == "conflicted":
            status, reason = "review required", "conflicted source claims route to review"
        elif scenario == "marathon runner":
            status, reason = "missing official source", "athletic training source lane not included in Train 01"
        elif scenario in {"career pivot", "still-counts pivot"} and domain in {"occupation", "entity_crosswalk"}:
            status, reason = "covered", "transfer and crosswalk atoms can support local composition later"
        rows.append({"scenario": scenario, "coverage": status, "reason": reason, "doesNotCreateUserPath": True})
    return rows


def review_queue_items(outputs: list[dict[str, Any]]) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    for output in outputs:
        source_id = output["sourceID"]
        for claim in output.get("claims", []):
            if claim.get("reviewRequirement") or claim.get("confidence") in {"low", "conflicted", "review_required"}:
                items.append(_review_item(source_id, claim["id"], "low-confidence or conflicted claim", claim.get("confidence", "review_required")))
            if claim.get("sourceState") in {"stale-critical", "revoked"}:
                items.append(_review_item(source_id, claim["id"], "stale-critical or revoked fact", claim.get("sourceState")))
        gate = output.get("termsValidation", {})
        if not gate.get("packable", False):
            items.append(_review_item(source_id, f"terms.{source_id}", "restricted terms or unclear license", "review_required"))
    return items


def _terms_slice(entry: dict[str, Any]) -> dict[str, Any]:
    return {
        "sourceID": entry["source_id"],
        "publisher": entry["publisher"],
        "license": entry["license"],
        "licenseVersion": entry["license_version"],
        "termsURL": entry["terms_url"],
        "authorityTier": entry["authority_tier"],
        "redistributionPolicy": entry["redistribution_policy"],
        "r2PackPolicy": entry["r2_pack_policy"],
        "attributionRequired": entry["attribution_required"],
        "freshnessCadence": entry["freshness_cadence"],
        "termsReviewStatus": entry["terms_review_status"],
        "lastTermsReviewed": entry["last_terms_reviewed"],
        "reviewRequired": entry["review_required"],
    }


def _claim(source_id: str, key: str, text: str, claim_type: str, confidence: str, source_state: str, provenance_ids: list[str], review: bool = False) -> dict[str, Any]:
    assert confidence in CONFIDENCE_STATES
    entry = terms_entry(source_id)
    return {
        "schemaVersion": 1,
        "kind": SCHEMA_KINDS["claim"],
        "id": stable_id("claim", {"sourceID": source_id, "key": key, "type": claim_type}),
        "versionID": "adapter-broad-coverage-train-01",
        "text": text,
        "claimType": claim_type,
        "state": "source_backed" if confidence not in {"unsupported", "conflicted", "review_required"} else "candidate",
        "freshness": "current" if source_state == "current" else source_state,
        "sourceIDs": [source_id],
        "provenanceIDs": provenance_ids,
        "sourceID": source_id,
        "sourceURL": entry["source_url"],
        "publisher": entry["publisher"],
        "authorityTier": entry["authority_tier"],
        "licenseTermsReference": entry["terms_url"],
        "freshnessCadence": entry["freshness_cadence"],
        "sourceState": source_state,
        "jurisdiction": entry["jurisdiction"],
        "confidence": confidence,
        "reviewRequirement": review or confidence in {"low", "conflicted", "review_required"},
        "checksum": stable_id("claim.checksum", {"text": text, "source": source_id}).split(".", 1)[1],
        "dataClass": "public_reference_claim",
        "publicReferenceOnly": True,
    }


def _requirement(source_id: str, key: str, claim_id: str, gate_type: str, provenance_ids: list[str], source_state: str) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": SCHEMA_KINDS["requirement"],
        "id": stable_id("requirement", {"sourceID": source_id, "key": key, "gate": gate_type}),
        "versionID": "adapter-broad-coverage-train-01",
        "claimID": claim_id,
        "gateType": gate_type,
        "structuredRule": {"type": "public_reference_only", "sourceState": source_state, "doesNotCreateRuntimeStep": True},
        "sourceIDs": [source_id],
        "provenanceIDs": provenance_ids,
        "dataClass": "public_requirement",
        "publicReferenceOnly": True,
    }


def _atom(source_id: str, key: str, label: str, atom_type: str, provenance_ids: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": SCHEMA_KINDS["atom"],
        "id": stable_id("atom", {"sourceID": source_id, "key": key, "label": label}),
        "versionID": "adapter-broad-coverage-train-01",
        "label": label,
        "atomType": atom_type,
        "sourceIDs": [source_id],
        "provenanceIDs": provenance_ids,
        "dataClass": "public_atom_edge_lattice",
        "publicReferenceOnly": True,
    }


def _edge(source_id: str, key: str, from_atom_id: str, to_atom_id: str, relationship: str, provenance_ids: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": SCHEMA_KINDS["edge"],
        "id": stable_id("edge", {"sourceID": source_id, "key": key, "from": from_atom_id, "to": to_atom_id, "relationship": relationship}),
        "versionID": "adapter-broad-coverage-train-01",
        "fromAtomID": from_atom_id,
        "toAtomID": to_atom_id,
        "relationship": relationship,
        "sourceIDs": [source_id],
        "provenanceIDs": provenance_ids,
        "dataClass": "public_atom_edge_lattice",
        "publicReferenceOnly": True,
    }


def _lattice(source_id: str, atoms: list[dict[str, Any]], edges: list[dict[str, Any]], recipes: list[dict[str, Any]]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": SCHEMA_KINDS["lattice"],
        "id": stable_id("lattice", {"sourceID": source_id, "atomCount": len(atoms), "edgeCount": len(edges)}),
        "versionID": "adapter-broad-coverage-train-01",
        "atomIDs": [atom["id"] for atom in atoms],
        "edgeIDs": [edge["id"] for edge in edges],
        "recipeIDs": [recipe["id"] for recipe in recipes],
        "dataClass": "public_atom_edge_lattice",
        "publicReferenceOnly": True,
    }


def _recipe(source_id: str, title: str, atoms: list[dict[str, Any]], requirements: list[dict[str, Any]], provenance_ids: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": SCHEMA_KINDS["recipe"],
        "id": stable_id("recipe", {"sourceID": source_id, "title": title}),
        "versionID": "adapter-broad-coverage-train-01",
        "title": title,
        "inputAtomIDs": [atom["id"] for atom in atoms[:5]],
        "outputAtomIDs": [atom["id"] for atom in atoms[5:10]],
        "requirementIDs": [item["id"] for item in requirements],
        "sourceIDs": [source_id],
        "provenanceIDs": provenance_ids,
        "doesNotStoreFinalUserPath": True,
        "doesNotCreateFinalSchedule": True,
        "localRuntimeJoinRequired": True,
        "dataClass": "public_recipe",
        "publicReferenceOnly": True,
    }


def _crosswalk(item: dict[str, Any], confidence: str, provenance_ids: list[str]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.entityCrosswalk.v1",
        "id": stable_id("crosswalk", item),
        "canonicalOccupationID": item["canonical"],
        "onetOccupationCode": item.get("onet"),
        "blsSocCode": item.get("bls"),
        "wikidataQID": item.get("wikidata"),
        "openAlexID": item.get("openalex"),
        "label": item["label"],
        "candidates": [
            {"source": "onet", "id": item.get("onet"), "confidence": item["confidence"]},
            {"source": "bls", "id": item.get("bls"), "confidence": item["confidence"] if item.get("bls") else "unsupported"},
            {"source": "wikidata", "id": item.get("wikidata"), "confidence": confidence},
            {"source": "openalex", "id": item.get("openalex"), "confidence": item["confidence"] if item.get("openalex") else "unsupported"},
        ],
        "confidence": confidence,
        "ambiguityPreserved": True,
        "silentWinnerSelectionAllowed": False,
        "reviewRequired": confidence in {"low", "conflicted", "review_required"},
        "sourceIDs": ["wikidata.crosswalk"],
        "provenanceIDs": provenance_ids,
        "dataClass": "public_ontology",
        "publicReferenceOnly": True,
    }


def _review_item(source_id: str, item_id: str, reason: str, status: str) -> dict[str, Any]:
    category = "regulated_claim" if any(term in item_id for term in ["lawyer", "nurse", "medical"]) else "source_review"
    return {
        "id": stable_id("review", {"sourceID": source_id, "itemID": item_id, "reason": reason}),
        "sourceID": source_id,
        "itemID": item_id,
        "category": category,
        "reason": reason,
        "status": status,
        "requiresHumanReview": True,
        "dataClass": "public_provenance",
        "publicReferenceOnly": True,
    }


def _non_claims() -> list[str]:
    return [
        "does not create final user paths",
        "does not create final schedules",
        "does not create Step lists",
        "does not gather private user data",
        "does not claim legal, privacy, release, or R2 production readiness",
    ]
