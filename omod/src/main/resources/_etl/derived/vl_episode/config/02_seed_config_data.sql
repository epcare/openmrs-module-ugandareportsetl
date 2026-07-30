-- ============================================================================
-- Viral-Load Mamba ETL Configuration Seed Data
-- Version: 1.0
-- Date: 2026-07-28
-- Database: stambrose (UgandaEMR)
--
-- This script populates the mamba VL configuration tables with initial data.
--
-- Usage:
--   mysql -u openmrs -popenmrs stambrose < 02_seed_config_data.sql
-- ============================================================================

SET NAMES utf8mb4;

-- Clear existing seed data (safe to rerun)
DELETE FROM mamba_vl_concept_mapping WHERE created_at < NOW();
DELETE FROM mamba_vl_coded_value_mapping WHERE created_at < NOW();
DELETE FROM mamba_vl_source_mapping WHERE created_at < NOW();
DELETE FROM mamba_vl_rule_config WHERE created_at < NOW();

-- ============================================================================
-- CONCEPT MAPPINGS
-- ============================================================================

-- Core VL Panel and Result Concepts
INSERT INTO mamba_vl_concept_mapping
(concept_id, concept_uuid, canonical_field, canonical_event_type, source_workflow, value_type, priority, notes)
VALUES
-- VL Panel (parent observation)
(165412, '1eb05918-f50c-4cad-a827-3c78f296a10a', 'VL_PANEL', 'RESULT_FINALIZED', 'LEGACY_ART_CARD', 'Panel', 1, 'Viral Load Test panel - parent obs for all VL results'),

-- Numeric Result
(856, 'dc8d83e3-30ab-102d-86b0-7a5022ba4115', 'NUMERIC_RESULT', 'RESULT_FINALIZED', 'LEGACY_ART_CARD', 'Numeric', 1, 'HIV VIRAL LOAD - numeric copies/ml'),

-- Qualitative Result
(1305, 'dca12261-30ab-102d-86b0-7a5022ba4115', 'QUALITATIVE_RESULT', 'RESULT_FINALIZED', 'LEGACY_ART_CARD', 'Coded', 1, 'VIRAL LOAD QUALITATIVE'),

-- VL Clinical Date (legacy)
(163023, '0b434cfa-b11c-4d14-aaa2-9aed6ca2da88', 'VL_CLINICAL_DATE', 'SAMPLE_COLLECTED', 'LEGACY_ART_CARD', 'Date', 1, 'HIV VIRAL LOAD DATE - legacy VL taken date'),

-- Sample Collection Date (new form)
(163023, '0b434cfa-b11c-4d14-aaa2-9aed6ca2da88', 'SAMPLE_COLLECTION_DATE', 'SAMPLE_COLLECTED', 'NEW_VL_REQUEST_FORM', 'Date', 1, 'Sample collection date in new VL request form'),

-- Accession Number
(165845, '0f998893-ab24-4ee4-922a-f197ac5fd6e6', 'ACCESSION_NUMBER', 'ORDER_PLACED', 'NEW_VL_REQUEST_FORM', 'Text', 1, 'Lab Number / Specimen ID'),

-- Date Result Received
(167944, '5b4037d6-a7e2-11ed-afa1-0242ac120002', 'RETURN_TO_FACILITY_DATE', 'RESULT_RETURNED_TO_FACILITY', 'NEW_VL_REQUEST_FORM', 'Date', 1, 'DATE RESULT RECIEVED'),

-- Legacy Order Question
(1271, 'dca07f4a-30ab-102d-86b0-7a5022ba4115', 'TESTS_ORDERED_QUESTION', 'ORDER_PLACED', 'LEGACY_ART_CARD', 'Question', 1, 'TESTS ORDERED - parent question for legacy VL orders'),

-- VL Order Answer
(165412, '1eb05918-f50c-4cad-a827-3c78f296a10a', 'VL_ORDER', 'ORDER_PLACED', 'LEGACY_ART_CARD', 'Answer', 1, 'Viral Load Test - answer to Tests Ordered question');

-- PMTCT and Clinical Context Concepts
INSERT INTO mamba_vl_concept_mapping
(concept_id, concept_uuid, canonical_field, canonical_event_type, source_workflow, value_type, priority, notes)
VALUES
-- Pregnancy Status
(155748, 'dcda5179-30ab-102d-86b0-7a5022ba4115', 'PREGNANCY_STATUS', 'PATIENT_CONTEXT', 'NEW_VL_REQUEST_FORM', 'Coded', 1, 'Pregnant status'),

-- Breastfeeding Status
(1599, '9e5ac0a8-6041-4feb-8c07-fe522ef5f9ab', 'BREASTFEEDING_STATUS', 'PATIENT_CONTEXT', 'NEW_VL_REQUEST_FORM', 'Coded', 1, 'Breastfeeding status'),

-- ANC Number (using UUID directly)
(NULL, 'c7231d96-34d8-4bf7-a509-c810f75e3329', 'ANC_NUMBER', 'PATIENT_CONTEXT', 'NEW_VL_REQUEST_FORM', 'Text', 1, 'ANC number'),

-- PNC Number (using UUID directly)
(NULL, 'ef1f4c7a-2b90-4412-83bb-87ae8094ce4c', 'PNC_NUMBER', 'PATIENT_CONTEXT', 'NEW_VL_REQUEST_FORM', 'Text', 1, 'PNC number'),

-- ART Start Date (using UUID directly)
(NULL, 'ab505422-26d9-41f1-a079-c3d222000440', 'ART_START_DATE', 'ART_INITIATION', 'NEW_VL_REQUEST_FORM', 'Date', 1, 'ART start date as recorded on VL form');

-- ============================================================================
-- CODED VALUE MAPPINGS - VL Qualitative Results
-- ============================================================================

INSERT INTO mamba_vl_coded_value_mapping
(question_concept_uuid, answer_concept_id, answer_concept_uuid, answer_name, canonical_value, is_valid_result, is_suppressed, is_unsuppressed, requires_recollection, notes)
VALUES
-- Question: VIRAL LOAD QUALITATIVE (1305)
('dca12261-30ab-102d-86b0-7a5022ba4115', 1306, 'dca1269d-30ab-102d-86b0-7a5022ba4115', 'BEYOND DETECTABLE LIMIT', 'TARGET_NOT_DETECTED', 1, 1, 0, 0, 'Target Not Detected / BDL / Beyond Detectable Limit - suppressed'),

('dca12261-30ab-102d-86b0-7a5022ba4115', 1301, 'dca10c94-30ab-102d-86b0-7a5022ba4115', 'DETECTED', 'DETECTED', 1, NULL, NULL, 0, 'Detected - interpretation depends on numeric value'),

('dca12261-30ab-102d-86b0-7a5022ba4115', 1304, 'dca11907-30ab-102d-86b0-7a5022ba4115', 'POOR SAMPLE QUALITY', 'POOR_SAMPLE_QUALITY', 0, NULL, NULL, 1, 'Poor Sample Quality / PSQ - requires recollection'),

('dca12261-30ab-102d-86b0-7a5022ba4115', 1310, 'dca126de-30ab-102d-86b0-7a5022ba4115', 'SAMPLE REJECTED', 'REJECTED', 0, NULL, NULL, 1, 'Sample Rejected - requires recollection'),

('dca12261-30ab-102d-86b0-7a5022ba4115', 1302, 'dca10d78-30ab-102d-86b0-7a5022ba4115', '< 400 copies', 'LESS_THAN_400', 1, 1, 0, 0, '< 400 copies - legacy suppressed indicator'),

('dca12261-30ab-102d-86b0-7a5022ba4115', 1303, 'dca111bd-30ab-102d-86b0-7a5022ba4115', '>= 400 copies', 'GREATER_THAN_400', 1, NULL, NULL, 0, '>= 400 copies - legacy unsuppressed indicator'),

('dca12261-30ab-102d-86b0-7a5022ba4115', 1307, 'dca12ad3-30ab-102d-86b0-7a5022ba4115', 'INVALID', 'INVALID', 0, NULL, NULL, 1, 'Invalid result');

-- ============================================================================
-- SOURCE MAPPINGS - Forms and Encounters
-- ============================================================================

INSERT INTO mamba_vl_source_mapping
(form_uuid, form_id, encounter_type_uuid, encounter_type_id, source_workflow, source_role, priority, notes)
VALUES
-- New VL Request Form
('c0ba84af-d2b3-485f-bede-9c008fbc0d03', 59, 'cbf01392-ca29-11e9-a32f-2a2ae2dbcce4', NULL, 'NEW_VL_REQUEST_FORM', 'PRIMARY', 10, 'HMIS ACP 002: Viral Load Request Form - creates native orders'),

-- Legacy ART Card Encounter
(NULL, NULL, '8d5b2be0-c2cc-11de-8d13-0010c6dffd0f', 15, 'LEGACY_ART_CARD', 'PRIMARY', 5, 'ART Card - Encounter - historical VL workflow'),

-- Lab Encounter
(NULL, NULL, NULL, NULL, 'LAB_INTERFACE', 'SECONDARY', 3, 'Lab system integration'),

-- Lab Request Encounter (general)
('14f82cc8-ca2a-11e9-a32f-2a2ae2dbcce4', 30, NULL, NULL, 'LAB_INTERFACE', 'SECONDARY', 3, 'HMIS LAB 001: General Laboratory Test Request Form');

-- ============================================================================
-- RULE CONFIGURATION - Suppression and Due Rules
-- ============================================================================

-- Suppression Threshold Rules
INSERT INTO mamba_vl_rule_config
(rule_name, rule_version, population_group, parameter_name, parameter_value, parameter_type, effective_start_date, source_reference, approved_by, notes)
VALUES
-- Current suppression threshold (Uganda guidelines)
('SUPPRESSION_THRESHOLD', '1.0', 'ALL', 'threshold_copies_ml', '1000', 'integer', '2020-01-01', 'Uganda VL Testing Guidelines 2020', 'MoH', 'Standard suppression threshold: <1000 copies/ml'),

-- Routine VL intervals
('ROUTINE_VL_INTERVAL_DAYS', '1.0', 'ESTABLISHED_ART', 'interval_days', '365', 'integer', '2020-01-01', 'Uganda VL Testing Guidelines 2020', 'MoH', 'Routine annual VL for stable patients'),

('FIRST_VL_AFTER_INITIATION_DAYS', '1.0', 'NEW_ART_INITIATION', 'interval_days', '90', 'integer', '2020-01-01', 'Uganda VL Testing Guidelines 2020', 'MoH', 'First VL 3 months after ART initiation'),

('FIRST_VL_AFTER_INITIATION_DAYS', '1.0', 'ART_RESTART', 'interval_days', '90', 'integer', '2020-01-01', 'Uganda VL Testing Guidelines 2020', 'MoH', 'First VL 3 months after ART restart'),

-- PMTCT VL intervals
('PREGNANCY_VL_INTERVAL_DAYS', '1.0', 'PREGNANT_ON_ART', 'interval_days', '90', 'integer', '2020-01-01', 'Uganda PMTCT Guidelines 2020', 'MoH', 'VL every 3 months during pregnancy'),

('BREASTFEEDING_VL_INTERVAL_DAYS', '1.0', 'BREASTFEEDING', 'interval_days', '90', 'integer', '2020-01-01', 'Uganda PMTCT Guidelines 2020', 'MoH', 'VL every 3 months during breastfeeding'),

-- High VL follow-up
('HIGH_VL_REPEAT_INTERVAL_DAYS', '1.0', 'HIGH_VL', 'interval_days', '90', 'integer', '2020-01-01', 'Uganda VL Testing Guidelines 2020', 'MoH', 'Repeat VL 3 months after unsuppressed result'),

-- Order-result matching
('MATCHING_WINDOW_DAYS', '1.0', 'ALL', 'max_days_difference', '30', 'integer', '2020-01-01', 'ETL Configuration', 'ETL Team', 'Maximum days between order and result for patient-date matching'),

-- Turnaround targets
('TURNAROUND_TARGET_DAYS', '1.0', 'ALL', 'order_to_result_target', '30', 'integer', '2020-01-01', 'MoH Performance Targets', 'MoH', 'Target: order to result within 30 days'),

('TURNAROUND_TARGET_DAYS', '1.0', 'ALL', 'result_to_entry_target', '7', 'integer', '2020-01-01', 'MoH Performance Targets', 'MoH', 'Target: result to EMR entry within 7 days');

-- ============================================================================
-- FACILITY TESTING CAPABILITY (placeholder)
-- ============================================================================

-- Note: This table should be populated based on facility POC device inventory
-- Default entries for CPHL and unknown facilities

INSERT INTO mamba_vl_facility_testing_capability
(facility_id, location_id, location_uuid, testing_model, device_type, effective_start_date, source, notes)
VALUES
(NULL, NULL, NULL, 'CENTRAL_LAB', NULL, '2020-01-01', 'DEFAULT', 'CPHL Central Public Health Laboratories - default for Uganda'),

(NULL, NULL, NULL, 'UNKNOWN', NULL, '2020-01-01', 'DEFAULT', 'Unknown testing model - used when testing location cannot be determined');

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================

-- Verify seed data
SELECT '=== Concept Mappings ===' as info;
SELECT canonical_field, COUNT(*) as count FROM mamba_vl_concept_mapping GROUP BY canonical_field;

SELECT '=== Coded Value Mappings ===' as info;
SELECT canonical_value, COUNT(*) as count FROM mamba_vl_coded_value_mapping GROUP BY canonical_value;

SELECT '=== Source Mappings ===' as info;
SELECT source_workflow, source_role, COUNT(*) as count FROM mamba_vl_source_mapping GROUP BY source_workflow, source_role;

SELECT '=== Rule Configurations ===' as info;
SELECT rule_name, population_group, COUNT(*) as count FROM mamba_vl_rule_config GROUP BY rule_name, population_group;

SELECT '=== Seed Data Complete ===' as info;
