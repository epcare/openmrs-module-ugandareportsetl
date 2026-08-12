-- ============================================================================
-- Mamba ETL Cleanup Script
-- ============================================================================
-- Purpose: Drops all Mamba ETL procedures and tables for clean setup
-- Usage: Run before Setup Mamba ETL to ensure clean state
-- Updated: 2026-07-29 - Added all mamba tables including dim and flat tables
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- DROP ALL PROCEDURES (in dependency order - child procedures first)
-- ============================================================================

-- Drop main ETL procedures
DROP PROCEDURE IF EXISTS sp_mamba_data_processing_etl;
DROP PROCEDURE IF EXISTS sp_data_processing_derived_covid;
DROP PROCEDURE IF EXISTS sp_data_processing_derived_hiv_art;
DROP PROCEDURE IF EXISTS sp_data_processing_derived_hiv_art_card;
DROP PROCEDURE IF EXISTS sp_data_processing_derived_non_suppressed;
DROP PROCEDURE IF EXISTS sp_data_processing_derived_IIT;
DROP PROCEDURE IF EXISTS sp_data_processing_derived_hts;
DROP PROCEDURE IF EXISTS sp_data_processing_derived_hts_card_v2;
DROP PROCEDURE IF EXISTS sp_data_processing_derived_anc;
DROP PROCEDURE IF EXISTS sp_data_processing_derived_regimen_change;
DROP PROCEDURE IF EXISTS sp_data_processing_derived_vl_request;
DROP PROCEDURE IF EXISTS sp_data_processing_derived_vl_episode;
DROP PROCEDURE IF EXISTS sp_data_processing_derived_opd_attendance;
DROP PROCEDURE IF EXISTS sp_data_processing_derived_transfers;

-- Drop VL episode procedures
DROP PROCEDURE IF EXISTS sp_mamba_fact_vl_episode_etl;
DROP PROCEDURE IF EXISTS sp_mamba_fact_viral_load_episode;
DROP PROCEDURE IF EXISTS sp_mamba_fact_viral_load_episode_create;
DROP PROCEDURE IF EXISTS sp_mamba_fact_viral_load_episode_insert;
DROP PROCEDURE IF EXISTS sp_mamba_fact_viral_load_episode_update;
DROP PROCEDURE IF EXISTS 01_comprehensive_vl_episode;
DROP PROCEDURE IF EXISTS sp_get_latest_vl_per_patient;
DROP PROCEDURE IF EXISTS sp_get_vl_pipeline_summary;
DROP PROCEDURE IF EXISTS sp_data_processing_derived_vl_request;

-- Drop VL request procedures
DROP PROCEDURE IF EXISTS sp_mamba_fact_vl_request_etl;

-- Drop ARV orders procedures
DROP PROCEDURE IF EXISTS sp_data_processing_arv_orders;
DROP PROCEDURE IF EXISTS sp_fact_arv_orders_insert;

-- Drop Z-obs procedures
DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_insert;

-- Drop ETL obs group procedures
DROP PROCEDURE IF EXISTS sp_mamba_obs_group;
DROP PROCEDURE IF EXISTS sp_mamba_obs_group_create;
DROP PROCEDURE IF EXISTS sp_mamba_obs_group_insert;
DROP PROCEDURE IF EXISTS sp_mamba_obs_group_update;

-- Drop fact_encounter_diagnosis procedures
DROP PROCEDURE IF EXISTS sp_fact_encounter_diagnosis;
DROP PROCEDURE IF EXISTS sp_fact_encounter_diagnosis_create;
DROP PROCEDURE IF EXISTS sp_fact_encounter_diagnosis_insert;
DROP PROCEDURE IF EXISTS sp_fact_encounter_diagnosis_update;

-- Drop hts_card_v2 procedures
DROP PROCEDURE IF EXISTS sp_fact_encounter_hts_card_v2;
DROP PROCEDURE IF EXISTS sp_fact_encounter_hts_card_v2_create;
DROP PROCEDURE IF EXISTS sp_fact_encounter_hts_card_v2_insert;
DROP PROCEDURE IF EXISTS sp_fact_encounter_hts_card_v2_update;
DROP PROCEDURE IF EXISTS sp_fact_encounter_hts_card_v2_query;

-- ============================================================================
-- DROP ALL TABLES (in dependency order - child tables first)
-- ============================================================================

-- ===== FACT TABLES =====

-- VL episode tables
DROP TABLE IF EXISTS mamba_fact_viral_load_episode;
DROP TABLE IF EXISTS mamba_fact_vl_rule_config;
DROP TABLE IF EXISTS mamba_vl_concept_mapping;
DROP TABLE IF EXISTS mamba_vl_coded_value_mapping;
DROP TABLE IF EXISTS mamba_vl_source_mapping;

-- ARV orders tables
DROP TABLE IF EXISTS mamba_fact_arv_orders;

-- Non-suppressed tables
DROP TABLE IF EXISTS mamba_fact_non_suppressed_obs_group;
DROP TABLE IF EXISTS mamba_fact_non_suppressed_repeat_vl;

-- Audit tool tables
DROP TABLE IF EXISTS mamba_fact_audit_tool_art_patients;
DROP TABLE IF EXISTS mamba_fact_eid_patients;

-- Patient latest tables (alphabetically sorted)
DROP TABLE IF EXISTS mamba_fact_patients_latest_adherence;
DROP TABLE IF EXISTS mamba_fact_patients_latest_advanced_disease;
DROP TABLE IF EXISTS mamba_fact_patients_latest_arv_days_dispensed;
DROP TABLE IF EXISTS mamba_fact_patients_latest_current_regimen;
DROP TABLE IF EXISTS mamba_fact_patients_latest_family_planning;
DROP TABLE IF EXISTS mamba_fact_patients_latest_hepatitis_b_test;
DROP TABLE IF EXISTS mamba_fact_patients_latest_iac_decision_outcome;
DROP TABLE IF EXISTS mamba_fact_patients_latest_iac_sessions;
DROP TABLE IF EXISTS mamba_fact_patients_latest_index_tested_children;
DROP TABLE IF EXISTS mamba_fact_patients_latest_index_tested_children_status;
DROP TABLE IF EXISTS mamba_fact_patients_latest_index_tested_partners;
DROP TABLE IF EXISTS mamba_fact_patients_latest_index_tested_partners_status;
DROP TABLE IF EXISTS mamba_fact_patients_latest_nutrition_assesment;
DROP TABLE IF EXISTS mamba_fact_patients_latest_nutrition_support;
DROP TABLE IF EXISTS mamba_fact_patients_latest_patient_demographics;
DROP TABLE IF EXISTS mamba_fact_patients_latest_pregnancy_status;
DROP TABLE IF EXISTS mamba_fact_patients_latest_regimen;
DROP TABLE IF EXISTS mamba_fact_patients_latest_regimen_line;
DROP TABLE IF EXISTS mamba_fact_patients_latest_return_date;
DROP TABLE IF EXISTS mamba_fact_patients_latest_tb_status;
DROP TABLE IF EXISTS mamba_fact_patients_latest_tpt_status;
DROP TABLE IF EXISTS mamba_fact_patients_latest_viral_load;
DROP TABLE IF EXISTS mamba_fact_patients_latest_viral_load_ordered;
DROP TABLE IF EXISTS mamba_fact_patients_latest_vl_after_iac;
DROP TABLE IF EXISTS mamba_fact_patients_latest_who_stage;
DROP TABLE IF EXISTS mamba_fact_patients_latest_arv_order;

-- Patient category tables
DROP TABLE IF EXISTS mamba_fact_patients_interruptions_details;
DROP TABLE IF EXISTS mamba_fact_patients_no_of_interruptions;
DROP TABLE IF EXISTS mamba_fact_patients_marital_status;
DROP TABLE IF EXISTS mamba_fact_patients_nationality;
DROP TABLE IF EXISTS mamba_fact_art_patients;
DROP TABLE IF EXISTS mamba_fact_active_in_care;
DROP TABLE IF EXISTS mamba_fact_current_arv_regimen_start_date;
DROP TABLE IF EXISTS mamba_fact_marital_status_patients;
DROP TABLE IF EXISTS mamba_fact_nationality_patients;
DROP TABLE IF EXISTS mamba_fact_reattendance_monthly;
DROP TABLE IF EXISTS mamba_fact_transfer_in;
DROP TABLE IF EXISTS mamba_fact_transfer_out;

-- Encounter fact tables
DROP TABLE IF EXISTS mamba_fact_encounter_anc_card;
DROP TABLE IF EXISTS mamba_fact_encounter_cacx_screening;
DROP TABLE IF EXISTS mamba_fact_encounter_cacx_treatment;
DROP TABLE IF EXISTS mamba_fact_encounter_diagnosis;
DROP TABLE IF EXISTS mamba_fact_encounter_hiv_art_card;
DROP TABLE IF EXISTS mamba_fact_encounter_hiv_art_health_education;
DROP TABLE IF EXISTS mamba_fact_encounter_hiv_art_summary;
DROP TABLE IF EXISTS mamba_fact_encounter_hts_card;
DROP TABLE IF EXISTS mamba_fact_encounter_hts_card_v2;
DROP TABLE IF EXISTS mamba_fact_encounter_non_suppressed_card;
DROP TABLE IF EXISTS mamba_fact_encounter_non_suppressed_obs_group;
DROP TABLE IF EXISTS mamba_fact_encounter_non_suppressed_repeat_vl;
DROP TABLE IF EXISTS mamba_fact_encounter_regimen_change;
DROP TABLE IF EXISTS mamba_fact_encounter_vl_request;

-- Other fact tables
DROP TABLE IF EXISTS mamba_fact_attended_visit;
DROP TABLE IF EXISTS mamba_fact_medication_orders;
DROP TABLE IF EXISTS mamba_fact_test_orders;
DROP TABLE IF EXISTS mamba_fact_test_orders_results;
DROP TABLE IF EXISTS mamba_fact_regimen_change;

-- ===== FLAT TABLES =====

DROP TABLE IF EXISTS mamba_flat_encounter_anc_register;
DROP TABLE IF EXISTS mamba_flat_encounter_anc_register_1;
DROP TABLE IF EXISTS mamba_flat_encounter_art_card;
DROP TABLE IF EXISTS mamba_flat_encounter_art_card_1;
DROP TABLE IF EXISTS mamba_flat_encounter_art_health_education;
DROP TABLE IF EXISTS mamba_flat_encounter_art_summary_card;
DROP TABLE IF EXISTS mamba_flat_encounter_art_summary_card_1;
DROP TABLE IF EXISTS mamba_flat_encounter_hts_card;
DROP TABLE IF EXISTS mamba_flat_encounter_hts_card_1;
DROP TABLE IF EXISTS mamba_flat_encounter_hts_card_v2;
DROP TABLE IF EXISTS mamba_flat_encounter_non_suppressed;
DROP TABLE IF EXISTS mamba_flat_encounter_regimen_change;
DROP TABLE IF EXISTS mamba_flat_encounter_tb_enrollment;
DROP TABLE IF EXISTS mamba_flat_encounter_tb_followup;
DROP TABLE IF EXISTS mamba_flat_encounter_tb_followup_1;
DROP TABLE IF EXISTS mamba_flat_encounter_vl_request;
DROP TABLE IF EXISTS mamba_flat_encounter_cacx_screening;
DROP TABLE IF EXISTS mamba_flat_encounter_cacx_treatment;

-- ===== DIMENSION TABLES =====

DROP TABLE IF EXISTS mamba_dim_agegroup;
DROP TABLE IF EXISTS mamba_dim_concept;
DROP TABLE IF EXISTS mamba_dim_concept_answer;
DROP TABLE IF EXISTS mamba_dim_concept_datatype;
DROP TABLE IF EXISTS mamba_dim_concept_name;
DROP TABLE IF EXISTS mamba_dim_encounter;
DROP TABLE IF EXISTS mamba_dim_encounter_type;
DROP TABLE IF EXISTS mamba_dim_location;
DROP TABLE IF EXISTS mamba_dim_orders;
DROP TABLE IF EXISTS mamba_dim_patient_identifier;
DROP TABLE IF EXISTS mamba_dim_patient_identifier_type;
DROP TABLE IF EXISTS mamba_dim_person;
DROP TABLE IF EXISTS mamba_dim_person_address;
DROP TABLE IF EXISTS mamba_dim_person_attribute;
DROP TABLE IF EXISTS mamba_dim_person_attribute_type;
DROP TABLE IF EXISTS mamba_dim_person_name;
DROP TABLE IF EXISTS mamba_dim_relationship;
DROP TABLE IF EXISTS mamba_dim_report_definition;
DROP TABLE IF EXISTS mamba_dim_report_definition_parameters;
DROP TABLE IF EXISTS mamba_dim_users;

-- ===== STAGING/SOURCE TABLES =====

DROP TABLE IF EXISTS mamba_stg_vl_native_order;
DROP TABLE IF EXISTS mamba_stg_vl_legacy_order;
DROP TABLE IF EXISTS mamba_stg_vl_panel;
DROP TABLE IF EXISTS mamba_stg_vl_panel_child;
DROP TABLE IF EXISTS mamba_stg_vl_result_panel;
DROP TABLE IF EXISTS mamba_stg_vl_clinical_context;

-- ===== VL BRIDGE TABLES =====

DROP TABLE IF EXISTS mamba_bridge_patient_vl_due_rule;
DROP TABLE IF EXISTS mamba_bridge_vl_episode_source;

-- ===== VL MART TABLES =====

DROP TABLE IF EXISTS mamba_mart_patient_latest_vl;
DROP TABLE IF EXISTS mamba_mart_patient_vl_due_status;
DROP TABLE IF EXISTS mamba_mart_vl_data_quality;
DROP TABLE IF EXISTS mamba_mart_vl_pipeline;
DROP TABLE IF EXISTS mamba_mart_vl_suppression;
DROP TABLE IF EXISTS mamba_mart_vl_turnaround_time;

-- ===== VL CONFIG TABLES =====

DROP TABLE IF EXISTS mamba_vl_facility_testing_capability;
DROP TABLE IF EXISTS mamba_vl_rule_config;
DROP TABLE IF EXISTS mamba_vl_rule_version;

-- ===== ETL SYSTEM AND METADATA TABLES =====

DROP TABLE IF EXISTS mamba_etl_run;
DROP TABLE IF EXISTS mamba_etl_run_log;
DROP TABLE IF EXISTS mamba_etl_watermark;
DROP TABLE IF EXISTS mamba_concept_metadata;
DROP TABLE IF EXISTS mamba_etl_incremental_columns_index_all;
DROP TABLE IF EXISTS mamba_flat_table_config;
DROP TABLE IF EXISTS mamba_flat_table_config_incremental;
DROP TABLE IF EXISTS mamba_obs_group;
DROP TABLE IF EXISTS mamba_z_encounter_obs;
DROP TABLE IF EXISTS _mamba_etl_error_log;
DROP TABLE IF EXISTS _mamba_etl_schedule;
DROP TABLE IF EXISTS _mamba_etl_user_settings;

-- Note: Functions (fn_duration_to_days, fn_period_has_coverage) must be dropped manually
-- if needed, as DROP FUNCTION cannot be executed from within stored procedures

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'Mamba ETL cleanup completed successfully' AS status;