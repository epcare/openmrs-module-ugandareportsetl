-- $BEGIN
-- ============================================
-- Comprehensive Viral Load Episode Table
-- ============================================
-- Purpose: Single reference table for all VL workflows
-- Replaces: 35-table design with one consolidated table
-- Supports: All HMIS 106A VL reporting requirements
--
-- Based on: Comprehensive VL ETL Planning Document
-- Created: 2026-07-29
-- ============================================

-- Drop existing table if needed
DROP TABLE IF EXISTS mamba_fact_viral_load_episode;

-- Create the comprehensive VL episode table
CREATE TABLE mamba_fact_viral_load_episode (
    -- ============ IDENTIFIERS ============
    episode_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    patient_uuid CHAR(38),

    -- ============ ORDER INFORMATION ============
    native_order_id INT,
    native_order_uuid CHAR(38),
    derived_order_key VARCHAR(100),  -- Format: LEGACY_OBS:{obs_id}
    order_record_type ENUM('NATIVE_ORDER', 'DERIVED_LEGACY_ORDER', 'EXTERNAL_ORDER', 'NO_ORDER'),
    order_source_workflow ENUM('LEGACY_ART_CARD', 'NEW_VL_REQUEST_FORM', 'UNKNOWN'),
    order_date DATE,
    order_date_source VARCHAR(50),
    order_encounter_id INT,
    ordering_provider_id INT,
    order_status VARCHAR(50),
    order_action VARCHAR(50),  -- NEW, REVISE, RENEW, DISCONTINUE
    previous_order_id INT,
    accession_number VARCHAR(100),
    accession_number_normalized VARCHAR(100),

    -- ============ SAMPLE INFORMATION ============
    sample_collection_date DATE,
    sample_collection_date_source VARCHAR(50),
    sample_collection_date_conflict TINYINT(1) DEFAULT 0,
    specimen_source VARCHAR(100),
    specimen_type VARCHAR(100),
    sample_dispatch_date DATE,
    lab_receipt_date DATE,
    sample_status VARCHAR(50),
    rejection_reason TEXT,

    -- ============ RESULT INFORMATION ============
    result_encounter_id INT,
    panel_obs_id INT,
    viral_load_clinical_date DATE,
    viral_load_date_source VARCHAR(50),
    laboratory_result_date DATE,
    return_to_facility_date DATE,
    result_database_creation_date DATETIME,
    result_encounter_datetime DATETIME,

    -- Numeric Result
    result_numeric_raw DOUBLE,
    result_numeric DOUBLE,
    result_modifier VARCHAR(10),  -- <, >, =
    result_numeric_copies INT,
    lower_detection_limit INT,

    -- Qualitative Result
    result_qualitative_raw VARCHAR(100),
    result_qualitative VARCHAR(50),  -- TARGET_NOT_DETECTED, DETECTED, POOR_SAMPLE_QUALITY, INVALID
    result_qualitative_concept_id INT,

    -- Result Status
    result_status VARCHAR(50),  -- VALID, INVALID, REJECTED, PENDING
    is_valid_result TINYINT(1),

    -- ============ SUPPRESSION INTERPRETATION ============
    result_interpretation VARCHAR(50),  -- SUPPRESSED, UNSUPPRESSED, INVALID, UNKNOWN
    suppression_threshold INT DEFAULT 1000,
    is_suppressed TINYINT(1),
    is_unsuppressed TINYINT(1),
    is_high_viral_load TINYINT(1),
    requires_repeat_test TINYINT(1),
    requires_recollection TINYINT(1),
    has_numeric_qualitative_conflict TINYINT(1) DEFAULT 0,

    -- ============ CLINICAL CONTEXT (at time of order/sample) ============
    -- ART Status
    art_start_date DATE,
    art_restart_date DATE,
    transfer_in_date DATE,
    days_on_art_at_order INT,
    current_regimen_at_order VARCHAR(250),
    current_regimen_line VARCHAR(100),
    arv_adherence VARCHAR(50),

    -- PMTCT Context
    pregnancy_status ENUM('YES', 'NO', 'UNKNOWN'),
    pregnancy_status_at_order VARCHAR(50),
    breastfeeding_status ENUM('YES', 'NO', 'UNKNOWN'),
    breastfeeding_status_at_order VARCHAR(50),
    gestational_age_weeks INT,
    delivery_date DATE,
    is_pmtct_context TINYINT(1),
    anc_number DOUBLE,
    pnc_number VARCHAR(100),

    -- TB Status
    has_active_tb VARCHAR(50),
    tb_treatment_phase VARCHAR(100),

    -- WHO Stage
    current_who_stage VARCHAR(100),

    -- VL Indication
    recorded_vl_indication VARCHAR(250),
    calculated_vl_indication VARCHAR(250),  -- ROUTINE, FIRST_AFTER_ART_INIT, SUSPECTED_FAILURE, etc.

    -- ============ TESTING MODEL ============
    testing_model ENUM('CENTRAL_LAB', 'POINT_OF_CARE', 'OTHER_LAB', 'UNKNOWN'),
    testing_model_source VARCHAR(100),
    testing_model_confidence ENUM('HIGH', 'MEDIUM', 'LOW'),
    is_testing_model_inferred TINYINT(1) DEFAULT 0,
    performing_laboratory_name VARCHAR(250),

    -- ============ ORDER-RESULT LINKAGE ============
    linkage_method ENUM('DIRECT_ORDER_ID', 'ACCESSION_NUMBER', 'PATIENT_DATE', 'SAME_ENCOUNTER', 'UNMATCHED_RESULT', 'UNMATCHED_ORDER'),
    linkage_confidence ENUM('HIGH', 'MEDIUM', 'LOW'),
    linkage_score INT,
    is_orphan_result TINYINT(1) DEFAULT 0,
    is_order_without_result TINYINT(1) DEFAULT 0,

    -- ============ TURNAROUND TIMES (days) ============
    order_to_collection_days INT,
    collection_to_dispatch_days INT,
    dispatch_to_lab_receipt_days INT,
    lab_processing_days INT,
    result_to_facility_days INT,
    facility_to_emr_entry_days INT,
    collection_to_result_days INT,
    collection_to_facility_days INT,
    order_to_result_days INT,
    documentation_delay_days INT,

    -- ============ HIGH VL FOLLOW-UP ============
    previous_unsuppressed_vl_date DATE,
    high_vl_episode_number INT,
    repeat_vl_due_date DATE,
    repeat_vl_completed TINYINT(1),
    repeat_vl_suppressed TINYINT(1),
    persistent_unsuppressed TINYINT(1),

    -- ============ DUE STATUS (snapshot) ============
    next_expected_vl_date DATE,
    is_due TINYINT(1),
    is_overdue TINYINT(1),
    days_until_due INT,
    days_overdue INT,
    due_reason VARCHAR(250),

    -- ============ PIPELINE STATUS ============
    pipeline_status ENUM(
        'DUE_NOT_ORDERED',
        'ORDERED_NOT_COLLECTED',
        'COLLECTED_NOT_DISPATCHED',
        'DISPATCHED_NOT_RECEIVED_AT_LAB',
        'LAB_RECEIVED_RESULT_PENDING',
        'RESULT_FINAL_NOT_RETURNED_TO_FACILITY',
        'RETURNED_NOT_ENTERED_IN_EMR',
        'RESULT_ENTERED',
        'SAMPLE_REJECTED',
        'ORDER_CANCELLED',
        'ORDER_WITHOUT_RESULT',
        'ORPHAN_RESULT',
        'UNKNOWN'
    ),

    -- ============ LOCATION ============
    encounter_id INT,
    location_id INT,
    encounter_datetime DATETIME,

    -- ============ ETL METADATA ============
    source_record_id INT,
    source_uuid CHAR(38),
    etl_rule_version VARCHAR(50),
    etl_run_id INT,
    etl_created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    etl_updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- ============ INDEXES ============
    INDEX idx_patient_id (patient_id),
    INDEX idx_location_id (location_id),
    INDEX idx_order_date (order_date),
    INDEX idx_sample_collection_date (sample_collection_date),
    INDEX idx_vl_clinical_date (viral_load_clinical_date),
    INDEX idx_native_order_id (native_order_id),
    INDEX idx_accession_number (accession_number),
    INDEX idx_linkage_method (linkage_method),
    INDEX idx_testing_model (testing_model),
    INDEX idx_pipeline_status (pipeline_status),
    INDEX idx_is_suppressed (is_suppressed),
    INDEX idx_is_orphan (is_orphan_result, is_order_without_result),
    INDEX idx_location_order_date (location_id, order_date),
    INDEX idx_location_sample_date (location_id, sample_collection_date),
    INDEX idx_patient_vl_date (patient_id, viral_load_clinical_date),

    -- Composite for due status queries
    INDEX idx_due_status (location_id, is_due, is_overdue, next_expected_vl_date)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Comprehensive viral load episode table - single source for all VL reporting';

SELECT 'mamba_fact_viral_load_episode table created successfully' AS status;
-- $END
