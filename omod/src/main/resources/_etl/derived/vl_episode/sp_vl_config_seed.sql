-- $BEGIN
-- Clear existing seed data (safe to rerun)
DELETE FROM mamba_vl_concept_mapping WHERE created_at < NOW();
DELETE FROM mamba_vl_coded_value_mapping WHERE created_at < NOW();
DELETE FROM mamba_vl_source_mapping WHERE created_at < NOW();
DELETE FROM mamba_vl_rule_config WHERE created_at < NOW();
DELETE FROM mamba_vl_facility_testing_capability WHERE created_at < NOW();

-- Concept Mappings
INSERT INTO mamba_vl_concept_mapping
(concept_id, concept_uuid, canonical_field, canonical_event_type, source_workflow, value_type, priority, notes)
VALUES
(165412, '1eb05918-f50c-4cad-a827-3c78f296a10a', 'VL_PANEL', 'RESULT_FINALIZED', 'LEGACY_ART_CARD', 'Panel', 1, 'Viral Load Test panel'),
(856, 'dc8d83e3-30ab-102d-86b0-7a5022ba4115', 'NUMERIC_RESULT', 'RESULT_FINALIZED', 'LEGACY_ART_CARD', 'Numeric', 1, 'HIV VIRAL LOAD numeric'),
(1305, 'dca12261-30ab-102d-86b0-7a5022ba4115', 'QUALITATIVE_RESULT', 'RESULT_FINALIZED', 'LEGACY_ART_CARD', 'Coded', 1, 'VIRAL LOAD QUALITATIVE'),
(163023, '0b434cfa-b11c-4d14-aaa2-9aed6ca2da88', 'VL_CLINICAL_DATE', 'SAMPLE_COLLECTED', 'LEGACY_ART_CARD', 'Date', 1, 'HIV VIRAL LOAD DATE'),
(163023, '0b434cfa-b11c-4d14-aaa2-9aed6ca2da88', 'SAMPLE_COLLECTION_DATE', 'SAMPLE_COLLECTED', 'NEW_VL_REQUEST_FORM', 'Date', 1, 'Sample collection date'),
(165845, '0f998893-ab24-4ee4-922a-f197ac5fd6e6', 'ACCESSION_NUMBER', 'ORDER_PLACED', 'NEW_VL_REQUEST_FORM', 'Text', 1, 'Lab Number'),
(167944, '5b4037d6-a7e2-11ed-afa1-0242ac120002', 'RETURN_TO_FACILITY_DATE', 'RESULT_RETURNED_TO_FACILITY', 'NEW_VL_REQUEST_FORM', 'Date', 1, 'DATE RESULT RECIEVED'),
(1271, 'dca07f4a-30ab-102d-86b0-7a5022ba4115', 'TESTS_ORDERED_QUESTION', 'ORDER_PLACED', 'LEGACY_ART_CARD', 'Question', 1, 'TESTS ORDERED'),
(165412, '1eb05918-f50c-4cad-a827-3c78f296a10a', 'VL_ORDER', 'ORDER_PLACED', 'LEGACY_ART_CARD', 'Answer', 1, 'Viral Load Test'),
(155748, 'dcda5179-30ab-102d-86b0-7a5022ba4115', 'PREGNANCY_STATUS', 'PATIENT_CONTEXT', 'NEW_VL_REQUEST_FORM', 'Coded', 1, 'Pregnant status'),
(1599, '9e5ac0a8-6041-4feb-8c07-fe522ef5f9ab', 'BREASTFEEDING_STATUS', 'PATIENT_CONTEXT', 'NEW_VL_REQUEST_FORM', 'Coded', 1, 'Breastfeeding status');

-- Coded Value Mappings
INSERT INTO mamba_vl_coded_value_mapping
(question_concept_uuid, answer_concept_id, answer_concept_uuid, answer_name, canonical_value, is_valid_result, is_suppressed, is_unsuppressed, requires_recollection)
VALUES
('dca12261-30ab-102d-86b0-7a5022ba4115', 1306, 'dca1269d-30ab-102d-86b0-7a5022ba4115', 'BEYOND DETECTABLE LIMIT', 'TARGET_NOT_DETECTED', 1, 1, 0, 0),
('dca12261-30ab-102d-86b0-7a5022ba4115', 1301, 'dca10c94-30ab-102d-86b0-7a5022ba4115', 'DETECTED', 'DETECTED', 1, NULL, NULL, 0),
('dca12261-30ab-102d-86b0-7a5022ba4115', 1304, 'dca11907-30ab-102d-86b0-7a5022ba4115', 'POOR SAMPLE QUALITY', 'POOR_SAMPLE_QUALITY', 0, NULL, NULL, 1),
('dca12261-30ab-102d-86b0-7a5022ba4115', 1310, 'dca126de-30ab-102d-86b0-7a5022ba4115', 'SAMPLE REJECTED', 'REJECTED', 0, NULL, NULL, 1),
('dca12261-30ab-102d-86b0-7a5022ba4115', 1302, 'dca10d78-30ab-102d-86b0-7a5022ba4115', '< 400 copies', 'LESS_THAN_400', 1, 1, 0, 0),
('dca12261-30ab-102d-86b0-7a5022ba4115', 1303, 'dca111bd-30ab-102d-86b0-7a5022ba4115', '>= 400 copies', 'GREATER_THAN_400', 1, NULL, NULL, 0),
('dca12261-30ab-102d-86b0-7a5022ba4115', 1307, 'dca12ad3-30ab-102d-86b0-7a5022ba4115', 'INVALID', 'INVALID', 0, NULL, NULL, 1);

-- Source Mappings
INSERT INTO mamba_vl_source_mapping
(form_uuid, encounter_type_uuid, source_workflow, source_role, priority)
VALUES
('c0ba84af-d2b3-485f-bede-9c008fbc0d03', 'cbf01392-ca29-11e9-a32f-2a2ae2dbcce4', 'NEW_VL_REQUEST_FORM', 'PRIMARY', 10),
(NULL, '8d5b2be0-c2cc-11de-8d13-0010c6dffd0f', 'LEGACY_ART_CARD', 'PRIMARY', 5);

-- Rule Configuration
INSERT INTO mamba_vl_rule_config
(rule_name, rule_version, population_group, parameter_name, parameter_value, parameter_type, effective_start_date)
VALUES
('SUPPRESSION_THRESHOLD', '1.0', 'ALL', 'threshold_copies_ml', '1000', 'integer', '2020-01-01'),
('SUPPRESSION_THRESHOLD', '1.0', 'PREGNANT', 'threshold_copies_ml', '1000', 'integer', '2020-01-01'),
('SUPPRESSION_THRESHOLD', '1.0', 'BREASTFEEDING', 'threshold_copies_ml', '1000', 'integer', '2020-01-01'),
('MATCHING_WINDOW_DAYS', '1.0', 'ALL', 'max_days_difference', '30', 'integer', '2020-01-01');

-- Facility Testing Capability
INSERT INTO mamba_vl_facility_testing_capability
(location_uuid, testing_model, effective_start_date)
VALUES
(NULL, 'CENTRAL_LAB', '2020-01-01'),
(NULL, 'UNKNOWN', '2020-01-01');

-- Rule Version
INSERT INTO mamba_vl_rule_version (rule_name, active_version, effective_date)
VALUES
('SUPPRESSION_THRESHOLD', '1.0', '2020-01-01'),
('MATCHING_WINDOW_DAYS', '1.0', '2020-01-01'),
('ROUTINE_VL_INTERVAL_DAYS', '1.0', '2020-01-01')
ON DUPLICATE KEY UPDATE active_version = VALUES(active_version);
-- $END
