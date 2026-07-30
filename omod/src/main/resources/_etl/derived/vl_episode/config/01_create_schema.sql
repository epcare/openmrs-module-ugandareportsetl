-- ============================================================================
-- Viral-Load Mamba ETL Schema Creation Script
-- Version: 1.0
-- Date: 2026-07-28
-- Database: stambrose (UgandaEMR)
--
-- This script creates the mamba viral-load ETL schema and all required tables.
-- Follows existing Mamba ETL naming conventions (mamba_fact_*, mamba_*)
--
-- Usage:
--   mysql -u openmrs -popenmrs stambrose < 01_create_schema.sql
--
-- The script is safe to rerun - it uses IF NOT EXISTS
-- ============================================================================

SET NAMES utf8mb4;

-- ============================================================================
-- LAYER 1: CONFIGURATION TABLES (mamba_vl_*)
-- ============================================================================

-- 1.1 Concept Mapping Table
CREATE TABLE IF NOT EXISTS mamba_vl_concept_mapping (
    mapping_id INT AUTO_INCREMENT PRIMARY KEY,
    concept_id INT,
    concept_uuid CHAR(38) NOT NULL,
    canonical_field VARCHAR(100) NOT NULL,
    canonical_event_type VARCHAR(100),
    source_workflow VARCHAR(50),
    value_type VARCHAR(20),
    priority INT DEFAULT 0,
    effective_start_date DATE,
    effective_end_date DATE,
    is_active TINYINT(1) DEFAULT 1,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_concept_id (concept_id),
    INDEX idx_concept_uuid (concept_uuid),
    INDEX idx_canonical_field (canonical_field),
    INDEX idx_source_workflow (source_workflow),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 1.2 Coded Value Mapping Table
CREATE TABLE IF NOT EXISTS mamba_vl_coded_value_mapping (
    mapping_id INT AUTO_INCREMENT PRIMARY KEY,
    question_concept_uuid CHAR(38) NOT NULL,
    answer_concept_id INT NOT NULL,
    answer_concept_uuid CHAR(38) NOT NULL,
    answer_name VARCHAR(255),
    canonical_value VARCHAR(100) NOT NULL,
    is_valid_result TINYINT(1) DEFAULT 1,
    is_suppressed TINYINT(1),
    is_unsuppressed TINYINT(1),
    requires_recollection TINYINT(1) DEFAULT 0,
    effective_start_date DATE,
    effective_end_date DATE,
    is_active TINYINT(1) DEFAULT 1,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_question_uuid (question_concept_uuid),
    INDEX idx_answer_concept_id (answer_concept_id),
    INDEX idx_canonical_value (canonical_value),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 1.3 Source Mapping Table
CREATE TABLE IF NOT EXISTS mamba_vl_source_mapping (
    mapping_id INT AUTO_INCREMENT PRIMARY KEY,
    form_uuid CHAR(38),
    form_id INT,
    encounter_type_uuid CHAR(38),
    encounter_type_id INT,
    source_workflow VARCHAR(50) NOT NULL,
    source_role VARCHAR(50),
    priority INT DEFAULT 0,
    effective_start_date DATE,
    effective_end_date DATE,
    is_active TINYINT(1) DEFAULT 1,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_form_uuid (form_uuid),
    INDEX idx_encounter_type_uuid (encounter_type_uuid),
    INDEX idx_source_workflow (source_workflow),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 1.4 Rule Configuration Table
CREATE TABLE IF NOT EXISTS mamba_vl_rule_config (
    config_id INT AUTO_INCREMENT PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL,
    rule_version VARCHAR(20) NOT NULL,
    population_group VARCHAR(50),
    parameter_name VARCHAR(100) NOT NULL,
    parameter_value VARCHAR(255) NOT NULL,
    parameter_type VARCHAR(20) DEFAULT 'string',
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    is_active TINYINT(1) DEFAULT 1,
    source_reference VARCHAR(255),
    approved_by VARCHAR(100),
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_rule_version (rule_name, rule_version, population_group, parameter_name),
    INDEX idx_rule_name (rule_name),
    INDEX idx_population_group (population_group),
    INDEX idx_effective_dates (effective_start_date, effective_end_date),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 1.5 Facility Testing Capability Table
CREATE TABLE IF NOT EXISTS mamba_vl_facility_testing_capability (
    capability_id INT AUTO_INCREMENT PRIMARY KEY,
    facility_id INT,
    location_id INT,
    location_uuid CHAR(38),
    testing_model VARCHAR(50) NOT NULL,
    device_type VARCHAR(100),
    device_identifier VARCHAR(100),
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    source VARCHAR(100),
    is_active TINYINT(1) DEFAULT 1,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_facility_id (facility_id),
    INDEX idx_location_id (location_id),
    INDEX idx_testing_model (testing_model),
    INDEX idx_effective_dates (effective_start_date, effective_end_date),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- LAYER 2: STAGING TABLES (mamba_stg_vl_*)
-- ============================================================================

-- 2.1 Native Order Staging Table
CREATE TABLE IF NOT EXISTS mamba_stg_vl_native_order (
    order_id INT NOT NULL,
    order_uuid CHAR(38),
    order_number VARCHAR(150),
    patient_id INT NOT NULL,
    encounter_id INT,
    order_type INT,
    ordered_concept_id INT NOT NULL,
    ordered_concept_uuid CHAR(38) NOT NULL,
    date_activated DATETIME,
    scheduled_date DATE,
    date_created DATETIME,
    date_stopped DATE,
    auto_expire_date DATETIME,
    accession_number VARCHAR(200),
    urgency VARCHAR(50),
    order_action VARCHAR(50),
    previous_order_id INT,
    order_group_id INT,
    fulfiller_status VARCHAR(100),
    order_reason_coded INT,
    order_reason_non_coded TEXT,
    orderer INT,
    care_setting VARCHAR(50),
    specimen_source_concept INT,
    specimen_source_name VARCHAR(250),
    clinical_history TEXT,
    frequency VARCHAR(100),
    number_of_repeats INT,
    location_concept INT,
    comment_to_fulfiller TEXT,
    source_workflow VARCHAR(50) DEFAULT 'NEW_VL_REQUEST_FORM',
    voided TINYINT(1) DEFAULT 0,
    etl_extracted_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (order_id),
    INDEX idx_patient_id (patient_id),
    INDEX idx_encounter_id (encounter_id),
    INDEX idx_accession_number (accession_number),
    INDEX idx_date_activated (date_activated),
    INDEX idx_source_workflow (source_workflow)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.2 Legacy Order Staging Table
CREATE TABLE IF NOT EXISTS mamba_stg_vl_legacy_order (
    source_order_key VARCHAR(100) NOT NULL,
    legacy_order_obs_id INT NOT NULL,
    legacy_order_obs_uuid CHAR(38),
    patient_id INT NOT NULL,
    encounter_id INT,
    order_date DATETIME,
    location_id INT,
    ordered_test_concept_id INT NOT NULL,
    ordered_test_concept_uuid CHAR(38) NOT NULL,
    order_record_type VARCHAR(50) DEFAULT 'DERIVED_LEGACY_ORDER',
    source_workflow VARCHAR(50) DEFAULT 'LEGACY_ART_CARD',
    creator INT,
    date_created DATETIME,
    voided TINYINT(1) DEFAULT 0,
    etl_extracted_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (source_order_key),
    INDEX idx_patient_id (patient_id),
    INDEX idx_encounter_id (encounter_id),
    INDEX idx_order_date (order_date),
    INDEX idx_source_workflow (source_workflow)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.3 VL Panel Staging Table
CREATE TABLE IF NOT EXISTS mamba_stg_vl_panel (
    panel_obs_id INT NOT NULL,
    panel_obs_uuid CHAR(38),
    patient_id INT NOT NULL,
    encounter_id INT,
    panel_order_id INT,
    obs_datetime DATETIME,
    location_id INT,
    accession_number VARCHAR(200),
    date_created DATETIME,
    status VARCHAR(50),
    source_workflow VARCHAR(50),
    voided TINYINT(1) DEFAULT 0,
    etl_extracted_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (panel_obs_id),
    INDEX idx_patient_id (patient_id),
    INDEX idx_encounter_id (encounter_id),
    INDEX idx_panel_order_id (panel_order_id),
    INDEX idx_accession_number (accession_number),
    INDEX idx_obs_datetime (obs_datetime),
    INDEX idx_source_workflow (source_workflow)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.4 VL Panel Child Staging Table
CREATE TABLE IF NOT EXISTS mamba_stg_vl_panel_child (
    child_obs_id INT NOT NULL,
    child_obs_uuid CHAR(38),
    panel_obs_id INT NOT NULL,
    patient_id INT NOT NULL,
    encounter_id INT,
    order_id INT,
    concept_id INT NOT NULL,
    concept_uuid CHAR(38) NOT NULL,
    canonical_field VARCHAR(100),
    obs_datetime DATETIME,
    value_numeric DOUBLE,
    value_coded INT,
    value_coded_name VARCHAR(255),
    value_datetime DATE,
    value_text TEXT,
    value_modifier VARCHAR(10),
    accession_number VARCHAR(200),
    date_created DATETIME,
    status VARCHAR(50),
    voided TINYINT(1) DEFAULT 0,
    etl_extracted_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (child_obs_id),
    INDEX idx_panel_obs_id (panel_obs_id),
    INDEX idx_patient_id (patient_id),
    INDEX idx_concept_id (concept_id),
    INDEX idx_canonical_field (canonical_field),
    INDEX idx_order_id (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.5 Result Panel Reconstruction Table
CREATE TABLE IF NOT EXISTS mamba_stg_vl_result_panel (
    source_panel_key VARCHAR(100) NOT NULL,
    panel_obs_id INT NOT NULL,
    patient_id INT NOT NULL,
    encounter_id INT,
    panel_order_id INT,
    effective_order_id INT,
    accession_number_raw VARCHAR(200),
    accession_number_normalized VARCHAR(200),
    legacy_vl_taken_date DATE,
    new_sample_collection_date DATE,
    canonical_sample_collection_date DATE,
    sample_collection_date_source VARCHAR(50),
    sample_collection_date_conflict TINYINT(1) DEFAULT 0,
    return_to_facility_date DATE,
    numeric_result DOUBLE,
    numeric_modifier VARCHAR(10),
    numeric_result_raw DOUBLE,
    qualitative_result_concept_id INT,
    qualitative_result_concept_uuid CHAR(38),
    qualitative_result_raw VARCHAR(255),
    qualitative_result_canonical VARCHAR(100),
    first_child_created_at DATETIME,
    last_child_created_at DATETIME,
    distinct_child_order_count INT DEFAULT 0,
    child_order_ids_consolidated VARCHAR(500),
    source_workflow VARCHAR(50),
    source_priority INT DEFAULT 0,
    is_valid_candidate_result TINYINT(1) DEFAULT 1,
    invalid_reason VARCHAR(255),
    etl_extracted_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (source_panel_key),
    INDEX idx_patient_id (patient_id),
    INDEX idx_effective_order_id (effective_order_id),
    INDEX idx_accession_number (accession_number_normalized),
    INDEX idx_canonical_sample_date (canonical_sample_collection_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2.6 Clinical Context Staging Table
CREATE TABLE IF NOT EXISTS mamba_stg_vl_clinical_context (
    context_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    context_date DATE NOT NULL,
    art_start_date DATE,
    art_restart_date DATE,
    transfer_in_date DATE,
    enrollment_date DATE,
    current_art_status VARCHAR(50),
    current_regimen_concept_id INT,
    current_regimen_name VARCHAR(255),
    regimen_line VARCHAR(50),
    pregnancy_status VARCHAR(50),
    gestational_age_weeks INT,
    expected_delivery_date DATE,
    delivery_date DATE,
    postpartum_status VARCHAR(50),
    breastfeeding_status VARCHAR(50),
    pmtct_enrolled TINYINT(1),
    latest_valid_vl_date DATE,
    latest_valid_vl_result DOUBLE,
    latest_vl_suppressed TINYINT(1),
    previous_unsuppressed_vl_date DATE,
    iac_initiation_date DATE,
    iac_completion_date DATE,
    eac_initiation_date DATE,
    eac_completion_date DATE,
    regimen_switch_date DATE,
    transfer_out_date DATE,
    death_date DATE,
    treatment_stop_date DATE,
    context_as_of_date DATETIME DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uk_patient_date (patient_id, context_date),
    INDEX idx_art_start_date (art_start_date),
    INDEX idx_pregnancy_status (pregnancy_status),
    INDEX idx_breastfeeding_status (breastfeeding_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- LAYER 3: CANONICAL EVENTS (mamba_fact_vl_*)
-- ============================================================================

-- 3.1 VL Event Fact Table
CREATE TABLE IF NOT EXISTS mamba_fact_vl_event (
    vl_event_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_date DATE,
    event_datetime DATETIME,
    clinical_date DATE,
    recorded_date DATE,
    source_workflow VARCHAR(50),
    source_table VARCHAR(50),
    source_record_id INT,
    source_uuid CHAR(38),
    encounter_id INT,
    order_id INT,
    obs_id INT,
    obs_group_id INT,
    accession_number VARCHAR(200),
    external_result_id VARCHAR(200),
    location_id INT,
    event_value_numeric DOUBLE,
    event_value_text TEXT,
    event_value_coded INT,
    is_voided TINYINT(1) DEFAULT 0,
    etl_run_id INT,
    etl_loaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_patient_id (patient_id),
    INDEX idx_event_type (event_type),
    INDEX idx_event_date (event_date),
    INDEX idx_order_id (order_id),
    INDEX idx_accession_number (accession_number),
    INDEX idx_source_workflow (source_workflow)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- LAYER 4: EPISODE TABLE (mamba_fact_viral_load_episode)
-- ============================================================================

CREATE TABLE IF NOT EXISTS mamba_fact_viral_load_episode (
    viral_load_episode_id INT AUTO_INCREMENT PRIMARY KEY,

    -- Episode identifiers
    patient_id INT NOT NULL,
    patient_uuid CHAR(38),
    native_order_id INT,
    native_order_uuid CHAR(38),
    derived_order_key VARCHAR(100),
    result_encounter_id INT,
    panel_obs_id INT,
    accession_number_raw VARCHAR(200),
    accession_number_normalized VARCHAR(200),
    external_result_id VARCHAR(200),

    -- Order information
    order_record_type VARCHAR(50),
    order_date DATE,
    order_date_source VARCHAR(50),
    order_encounter_id INT,
    order_source_workflow VARCHAR(50),
    ordering_provider_id INT,
    ordered_test_concept_uuid CHAR(38),
    order_status VARCHAR(50),
    order_action VARCHAR(50),
    order_reason_coded INT,
    previous_order_id INT,
    root_order_id INT,
    order_group_id INT,

    -- Specimen information
    sample_collection_date DATE,
    sample_collection_date_source VARCHAR(50),
    specimen_source VARCHAR(100),
    sample_type VARCHAR(100),
    sample_dispatch_date DATE,
    lab_receipt_date DATE,
    sample_status VARCHAR(50),
    rejection_reason VARCHAR(255),

    -- Result information
    viral_load_clinical_date DATE,
    viral_load_date_source VARCHAR(50),
    laboratory_result_date DATE,
    return_to_facility_date DATE,
    result_encounter_datetime DATETIME,
    result_database_creation_date DATETIME,
    result_numeric_raw DOUBLE,
    result_numeric DOUBLE,
    result_operator VARCHAR(10),
    result_qualitative_raw VARCHAR(255),
    result_qualitative VARCHAR(100),
    result_status VARCHAR(50),
    lower_detection_limit INT,
    is_valid_result TINYINT(1),
    invalid_reason VARCHAR(255),
    result_source_workflow VARCHAR(50),

    -- Clinical context
    art_start_date DATE,
    art_restart_date DATE,
    transfer_in_date DATE,
    days_on_art_at_order INT,
    days_on_art_at_sample INT,
    current_regimen_at_order VARCHAR(255),
    current_regimen_at_result VARCHAR(255),
    pregnancy_status_at_order VARCHAR(50),
    pregnancy_status_at_sample VARCHAR(50),
    breastfeeding_status_at_order VARCHAR(50),
    breastfeeding_status_at_sample VARCHAR(50),
    gestational_age_weeks INT,
    delivery_date DATE,
    is_pmtct_context TINYINT(1),
    recorded_vl_indication VARCHAR(100),
    calculated_vl_indication VARCHAR(100),

    -- Interpretation
    result_interpretation VARCHAR(100),
    suppression_threshold INT,
    suppression_rule_version VARCHAR(50),
    is_suppressed TINYINT(1),
    is_unsuppressed TINYINT(1),
    is_high_viral_load TINYINT(1),
    requires_repeat_test TINYINT(1),
    requires_recollection TINYINT(1),
    has_numeric_qualitative_conflict TINYINT(1),

    -- Linkage
    linkage_method VARCHAR(50),
    linkage_confidence VARCHAR(20),
    linkage_score INT,
    matched_order_date_difference_days INT,
    linkage_rule_version VARCHAR(50),
    is_orphan_result TINYINT(1) DEFAULT 0,
    is_order_without_result TINYINT(1) DEFAULT 0,

    -- Testing model
    testing_model VARCHAR(50),
    performing_laboratory_name VARCHAR(255),
    performing_laboratory_code VARCHAR(100),
    device_identifier VARCHAR(100),
    testing_model_source VARCHAR(100),
    testing_model_confidence VARCHAR(20),
    is_testing_model_inferred TINYINT(1) DEFAULT 0,
    testing_model_rule_version VARCHAR(50),

    -- Turnaround
    order_to_collection_days INT,
    collection_to_dispatch_days INT,
    dispatch_to_lab_receipt_days INT,
    lab_processing_days INT,
    result_to_facility_days INT,
    facility_to_emr_entry_days INT,
    collection_to_result_days INT,
    collection_to_facility_days INT,
    collection_to_emr_entry_days INT,
    order_to_result_days INT,
    documentation_delay_days INT,

    -- Audit fields
    canonical_source_priority INT,
    etl_rule_version VARCHAR(50),
    etl_run_id INT,
    etl_created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    etl_updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_patient_id (patient_id),
    INDEX idx_native_order_id (native_order_id),
    INDEX idx_accession_number (accession_number_normalized),
    INDEX idx_order_date (order_date),
    INDEX idx_sample_collection_date (sample_collection_date),
    INDEX idx_viral_load_clinical_date (viral_load_clinical_date),
    INDEX idx_result_source_workflow (result_source_workflow),
    INDEX idx_is_valid_result (is_valid_result),
    INDEX idx_is_suppressed (is_suppressed),
    INDEX idx_is_orphan_result (is_orphan_result)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- LAYER 5: BRIDGE TABLES (mamba_bridge_vl_*)
-- ============================================================================

-- 5.1 Episode Source Bridge Table
CREATE TABLE IF NOT EXISTS mamba_bridge_vl_episode_source (
    bridge_id INT AUTO_INCREMENT PRIMARY KEY,
    viral_load_episode_id INT NOT NULL,
    source_table VARCHAR(50) NOT NULL,
    source_record_id INT NOT NULL,
    source_uuid CHAR(38),
    source_role VARCHAR(50) NOT NULL,
    source_priority INT DEFAULT 0,
    is_canonical_source TINYINT(1) DEFAULT 0,
    conflict_type VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_viral_load_episode_id (viral_load_episode_id),
    INDEX idx_source_table_record (source_table, source_record_id),
    INDEX idx_source_role (source_role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5.2 Patient Due Rule Bridge Table
CREATE TABLE IF NOT EXISTS mamba_bridge_patient_vl_due_rule (
    bridge_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    assessment_date DATE NOT NULL,
    applicable_rule VARCHAR(100) NOT NULL,
    calculated_due_date DATE,
    rule_priority INT DEFAULT 0,
    is_selected_rule TINYINT(1) DEFAULT 0,
    rule_version VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_patient_assessment (patient_id, assessment_date),
    INDEX idx_applicable_rule (applicable_rule),
    INDEX idx_calculated_due_date (calculated_due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- LAYER 6: REPORTING MARTS (mamba_mart_vl_*)
-- ============================================================================

-- 6.1 Patient Latest Viral Load Mart
CREATE TABLE IF NOT EXISTS mamba_mart_patient_latest_vl (
    patient_id INT NOT NULL PRIMARY KEY,
    latest_valid_vl_episode_id INT,
    latest_valid_vl_date DATE,
    latest_result_numeric DOUBLE,
    latest_result_qualitative VARCHAR(100),
    latest_result_interpretation VARCHAR(100),
    latest_is_suppressed TINYINT(1),
    latest_testing_model VARCHAR(50),
    latest_result_source VARCHAR(50),
    latest_return_to_facility_date DATE,
    latest_result_database_creation_date DATE,
    days_since_latest_valid_vl INT,
    latest_unsuppressed_vl_date DATE,
    latest_pending_order_date DATE,
    pending_order_exists TINYINT(1) DEFAULT 0,
    vl_due_date DATE,
    vl_due_status VARCHAR(50),
    vl_due_reason VARCHAR(100),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_latest_valid_vl_date (latest_valid_vl_date),
    INDEX idx_vl_due_date (vl_due_date),
    INDEX idx_vl_due_status (vl_due_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6.2 Viral Load Suppression Mart
CREATE TABLE IF NOT EXISTS mamba_mart_vl_suppression (
    suppression_id INT AUTO_INCREMENT PRIMARY KEY,
    report_period_start DATE NOT NULL,
    report_period_end DATE NOT NULL,
    facility_id INT,
    location_id INT,
    age_group VARCHAR(20),
    sex VARCHAR(10),
    pregnancy_status VARCHAR(50),
    breastfeeding_status VARCHAR(50),
    pmtct_status VARCHAR(50),
    art_duration_category VARCHAR(50),
    regimen_line VARCHAR(50),
    testing_model VARCHAR(50),
    result_source VARCHAR(50),

    total_valid_results INT DEFAULT 0,
    suppressed_results INT DEFAULT 0,
    unsuppressed_results INT DEFAULT 0,
    high_viral_load_results INT DEFAULT 0,
    invalid_results INT DEFAULT 0,
    rejected_results INT DEFAULT 0,
    numeric_only_results INT DEFAULT 0,
    qualitative_only_results INT DEFAULT 0,
    conflicting_results INT DEFAULT 0,

    suppression_rate DECIMAL(5,2),
    repeat_test_ordered INT DEFAULT 0,
    repeat_test_completed INT DEFAULT 0,
    repeat_suppressed INT DEFAULT 0,
    persistent_unsuppressed INT DEFAULT 0,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_report_period (report_period_start, report_period_end),
    INDEX idx_facility_id (facility_id),
    INDEX idx_age_group (age_group),
    INDEX idx_testing_model (testing_model)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6.3 Patient VL Due Status Mart
CREATE TABLE IF NOT EXISTS mamba_mart_patient_vl_due_status (
    patient_id INT NOT NULL,
    assessment_date DATE NOT NULL,
    patient_group VARCHAR(50),
    selected_due_schedule VARCHAR(100),
    art_start_date DATE,
    art_restart_date DATE,
    enrollment_date DATE,
    transfer_in_date DATE,
    pregnancy_status VARCHAR(50),
    breastfeeding_status VARCHAR(50),
    gestational_age_weeks INT,
    delivery_date DATE,

    latest_valid_vl_date DATE,
    latest_valid_vl_episode_id INT,
    latest_valid_vl_result DOUBLE,
    previous_unsuppressed_vl_date DATE,

    next_expected_vl_date DATE,
    is_due TINYINT(1),
    is_overdue TINYINT(1),
    days_until_due INT,
    days_overdue INT,
    due_reason VARCHAR(100),

    pending_order_exists TINYINT(1) DEFAULT 0,
    pending_order_date DATE,
    pending_sample_exists TINYINT(1) DEFAULT 0,
    pending_result_exists TINYINT(1) DEFAULT 0,
    rejected_sample_requires_recollection TINYINT(1) DEFAULT 0,

    due_rule_version VARCHAR(50),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (patient_id, assessment_date),
    INDEX idx_assessment_date (assessment_date),
    INDEX idx_next_expected_vl_date (next_expected_vl_date),
    INDEX idx_is_due (is_due),
    INDEX idx_is_overdue (is_overdue),
    INDEX idx_due_reason (due_reason)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6.4 VL Order Pipeline Mart
CREATE TABLE IF NOT EXISTS mamba_mart_vl_pipeline (
    pipeline_id INT AUTO_INCREMENT PRIMARY KEY,
    viral_load_episode_id INT NOT NULL,
    patient_id INT NOT NULL,
    facility_id INT,
    location_id INT,

    order_date DATE,
    sample_collection_date DATE,
    result_date DATE,
    return_to_facility_date DATE,
    entry_in_emr_date DATE,

    current_pipeline_stage VARCHAR(50),
    days_in_current_stage INT,
    target_days_for_stage INT,
    exceeds_target TINYINT(1) DEFAULT 0,

    testing_model VARCHAR(50),
    linkage_confidence VARCHAR(20),
    data_quality_flags TEXT,

    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_patient_id (patient_id),
    INDEX idx_facility_id (facility_id),
    INDEX idx_current_stage (current_pipeline_stage),
    INDEX idx_order_date (order_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6.5 VL Turnaround Time Mart
CREATE TABLE IF NOT EXISTS mamba_mart_vl_turnaround_time (
    turnaround_id INT AUTO_INCREMENT PRIMARY KEY,
    viral_load_episode_id INT NOT NULL,
    patient_id INT NOT NULL,
    facility_id INT,
    location_id INT,
    reporting_period_start DATE,
    reporting_period_end DATE,

    order_to_collection_days INT,
    collection_to_dispatch_days INT,
    dispatch_to_lab_receipt_days INT,
    lab_processing_days INT,
    result_to_facility_days INT,
    facility_to_emr_entry_days INT,
    collection_to_result_days INT,
    collection_to_facility_days INT,
    collection_to_emr_entry_days INT,
    order_to_result_days INT,
    documentation_delay_days INT,

    pmtct_status VARCHAR(50),
    testing_model VARCHAR(50),
    performing_laboratory VARCHAR(100),
    specimen_type VARCHAR(100),
    linkage_confidence VARCHAR(20),
    result_source_workflow VARCHAR(50),

    date_quality_flags TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_patient_id (patient_id),
    INDEX idx_facility_id (facility_id),
    INDEX idx_reporting_period (reporting_period_start, reporting_period_end),
    INDEX idx_testing_model (testing_model)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6.6 VL Data Quality Mart
CREATE TABLE IF NOT EXISTS mamba_mart_vl_data_quality (
    quality_issue_id INT AUTO_INCREMENT PRIMARY KEY,
    viral_load_episode_id INT,
    patient_id INT NOT NULL,
    facility_id INT,
    source_record_id INT,
    source_table VARCHAR(50),

    issue_type VARCHAR(100) NOT NULL,
    issue_severity VARCHAR(20) DEFAULT 'MEDIUM',
    issue_description TEXT,
    suggested_remediation TEXT,

    rule_version VARCHAR(50),
    detected_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME,

    INDEX idx_patient_id (patient_id),
    INDEX idx_facility_id (facility_id),
    INDEX idx_issue_type (issue_type),
    INDEX idx_issue_severity (issue_severity),
    INDEX idx_detected_at (detected_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- LAYER 7: CONTROL TABLES (mamba_etl_*)
-- ============================================================================

-- 7.1 ETL Run Table
CREATE TABLE IF NOT EXISTS mamba_etl_run (
    run_id INT AUTO_INCREMENT PRIMARY KEY,
    run_type VARCHAR(50) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    status VARCHAR(20) NOT NULL,
    rows_extracted INT DEFAULT 0,
    rows_inserted INT DEFAULT 0,
    rows_updated INT DEFAULT 0,
    rows_rejected INT DEFAULT 0,
    patients_rebuilt INT DEFAULT 0,
    error_message TEXT,
    rule_version VARCHAR(50),
    source_watermark DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_run_type (run_type),
    INDEX idx_start_time (start_time),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7.2 ETL Run Log Table
CREATE TABLE IF NOT EXISTS mamba_etl_run_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    run_id INT NOT NULL,
    log_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    log_level VARCHAR(20) DEFAULT 'INFO',
    message TEXT,
    step_name VARCHAR(100),
    duration_ms INT,

    INDEX idx_run_id (run_id),
    INDEX idx_log_timestamp (log_timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7.3 ETL Watermark Table
CREATE TABLE IF NOT EXISTS mamba_etl_watermark (
    watermark_id INT AUTO_INCREMENT PRIMARY KEY,
    source_table VARCHAR(50) NOT NULL,
    last_extracted_id INT,
    last_extracted_uuid CHAR(38),
    last_extracted_datetime DATETIME,
    last_run_id INT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_source_table (source_table)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7.4 Rule Version Table
CREATE TABLE IF NOT EXISTS mamba_vl_rule_version (
    version_id INT AUTO_INCREMENT PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL,
    active_version VARCHAR(50) NOT NULL,
    effective_date DATE NOT NULL,
    reason_for_change TEXT,
    approved_by VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uk_rule_name (rule_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- END OF SCHEMA CREATION
-- ============================================================================
