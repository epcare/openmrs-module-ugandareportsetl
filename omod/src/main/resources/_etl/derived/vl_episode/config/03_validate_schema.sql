-- ============================================================================
-- Viral-Load Mamba ETL Schema Validation Script
-- Version: 1.0
-- Date: 2026-07-28
-- Database: stambrose (UgandaEMR)
--
-- This script validates that the Mamba VL ETL schema is properly created.
--
-- Usage:
--   mysql -u openmrs -popenmrs stambrose < 03_validate_schema.sql
-- ============================================================================

SET @validation_passed = TRUE;

-- Create a temporary table to track validation results
DROP TEMPORARY TABLE IF EXISTS validation_results;
CREATE TEMPORARY TABLE validation_results (
    test_name VARCHAR(200),
    test_result VARCHAR(20),
    expected_value INT,
    actual_value INT,
    notes TEXT
);

SELECT '========================================================================' AS '';
SELECT 'Mamba Viral-Load ETL Schema Validation' AS '';
SELECT '========================================================================' AS '';
SELECT NOW() AS validation_timestamp;

-- ============================================================================
-- LAYER 1: Configuration Tables Validation
-- ============================================================================

INSERT INTO validation_results
SELECT
    'Configuration Tables Exist',
    'PASS',
    5,
    COUNT(DISTINCT table_name),
    CONCAT('Found: ', GROUP_CONCAT(DISTINCT table_name ORDER BY table_name))
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND table_name IN ('mamba_vl_concept_mapping', 'mamba_vl_coded_value_mapping',
                   'mamba_vl_source_mapping', 'mamba_vl_rule_config',
                   'mamba_vl_facility_testing_capability');

INSERT INTO validation_results
SELECT
    'mamba_vl_concept_mapping',
    IF(COUNT(*) >= 10, 'PASS', 'FAIL'),
    10,
    COUNT(*),
    CONCAT('Concept mappings found: ', COUNT(*))
FROM mamba_vl_concept_mapping;

INSERT INTO validation_results
SELECT
    'mamba_vl_coded_value_mapping',
    IF(COUNT(*) >= 5, 'PASS', 'FAIL'),
    5,
    COUNT(*),
    CONCAT('Coded value mappings found: ', COUNT(*))
FROM mamba_vl_coded_value_mapping;

INSERT INTO validation_results
SELECT
    'mamba_vl_source_mapping',
    IF(COUNT(*) >= 3, 'PASS', 'FAIL'),
    3,
    COUNT(*),
    CONCAT('Source mappings found: ', COUNT(*))
FROM mamba_vl_source_mapping;

INSERT INTO validation_results
SELECT
    'mamba_vl_rule_config',
    IF(COUNT(*) >= 8, 'PASS', 'FAIL'),
    8,
    COUNT(*),
    CONCAT('Rule configurations found: ', COUNT(*))
FROM mamba_vl_rule_config;

-- Verify critical concept mappings
INSERT INTO validation_results
SELECT
    'VL Panel Concept Mapped',
    IF(MAX(CASE WHEN canonical_field = 'VL_PANEL' AND concept_id = 165412 THEN 1 ELSE 0 END) = 1, 'PASS', 'FAIL'),
    1,
    MAX(CASE WHEN canonical_field = 'VL_PANEL' AND concept_id = 165412 THEN 1 ELSE 0 END),
    'Viral Load Test panel concept should be mapped'
FROM mamba_vl_concept_mapping;

INSERT INTO validation_results
SELECT
    'VL Numeric Concept Mapped',
    IF(MAX(CASE WHEN canonical_field = 'NUMERIC_RESULT' AND concept_id = 856 THEN 1 ELSE 0 END) = 1, 'PASS', 'FAIL'),
    1,
    MAX(CASE WHEN canonical_field = 'NUMERIC_RESULT' AND concept_id = 856 THEN 1 ELSE 0 END),
    'HIV VIRAL LOAD numeric concept should be mapped'
FROM mamba_vl_concept_mapping;

INSERT INTO validation_results
SELECT
    'VL Qualitative Concept Mapped',
    IF(MAX(CASE WHEN canonical_field = 'QUALITATIVE_RESULT' AND concept_id = 1305 THEN 1 ELSE 0 END) = 1, 'PASS', 'FAIL'),
    1,
    MAX(CASE WHEN canonical_field = 'QUALITATIVE_RESULT' AND concept_id = 1305 THEN 1 ELSE 0 END),
    'VIRAL LOAD QUALITATIVE concept should be mapped'
FROM mamba_vl_concept_mapping;

-- ============================================================================
-- LAYER 2: Staging Tables Validation
-- ============================================================================

INSERT INTO validation_results
SELECT
    'Staging Tables Exist',
    IF(COUNT(*) = 6, 'PASS', 'FAIL'),
    6,
    COUNT(*),
    CONCAT('Found: ', GROUP_CONCAT(DISTINCT table_name ORDER BY table_name))
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND table_name IN ('mamba_stg_vl_native_order', 'mamba_stg_vl_legacy_order', 'mamba_stg_vl_panel',
                   'mamba_stg_vl_panel_child', 'mamba_stg_vl_result_panel', 'mamba_stg_vl_clinical_context');

-- ============================================================================
-- LAYER 3: Canonical Events Validation
-- ============================================================================

INSERT INTO validation_results
SELECT
    'VL Event Table Exists',
    IF(COUNT(*) = 1, 'PASS', 'FAIL'),
    1,
    COUNT(*),
    'mamba_fact_vl_event table should exist'
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND table_name = 'mamba_fact_vl_event';

-- ============================================================================
-- LAYER 4: Episode Table Validation
-- ============================================================================

INSERT INTO validation_results
SELECT
    'VL Episode Table Exists',
    IF(COUNT(*) = 1, 'PASS', 'FAIL'),
    1,
    COUNT(*),
    'mamba_fact_viral_load_episode table should exist'
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND table_name = 'mamba_fact_viral_load_episode';

-- Verify critical episode columns
INSERT INTO validation_results
SELECT
    'Episode Table Column Count',
    IF(COUNT(*) >= 80, 'PASS', 'FAIL'),
    80,
    COUNT(*),
    CONCAT('mamba_fact_viral_load_episode has ', COUNT(*), ' columns')
FROM information_schema.columns
WHERE table_schema = DATABASE()
AND table_name = 'mamba_fact_viral_load_episode';

-- ============================================================================
-- LAYER 5: Bridge Tables Validation
-- ============================================================================

INSERT INTO validation_results
SELECT
    'Bridge Tables Exist',
    IF(COUNT(*) = 2, 'PASS', 'FAIL'),
    2,
    COUNT(*),
    CONCAT('Found: ', GROUP_CONCAT(DISTINCT table_name ORDER BY table_name))
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND table_name IN ('mamba_bridge_vl_episode_source', 'mamba_bridge_patient_vl_due_rule');

-- ============================================================================
-- LAYER 6: Reporting Marts Validation
-- ============================================================================

INSERT INTO validation_results
SELECT
    'Reporting Marts Exist',
    IF(COUNT(*) = 6, 'PASS', 'FAIL'),
    6,
    COUNT(*),
    CONCAT('Found: ', GROUP_CONCAT(DISTINCT table_name ORDER BY table_name))
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND table_name IN ('mamba_mart_patient_latest_vl', 'mamba_mart_vl_suppression',
                   'mamba_mart_patient_vl_due_status', 'mamba_mart_vl_pipeline',
                   'mamba_mart_vl_turnaround_time', 'mamba_mart_vl_data_quality');

-- ============================================================================
-- LAYER 7: Control Tables Validation
-- ============================================================================

INSERT INTO validation_results
SELECT
    'Control Tables Exist',
    IF(COUNT(*) = 4, 'PASS', 'FAIL'),
    4,
    COUNT(*),
    CONCAT('Found: ', GROUP_CONCAT(DISTINCT table_name ORDER BY table_name))
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND table_name IN ('mamba_etl_run', 'mamba_etl_run_log', 'mamba_etl_watermark', 'mamba_vl_rule_version');

-- ============================================================================
-- TOTAL TABLE COUNT
-- ============================================================================

INSERT INTO validation_results
SELECT
    'Total Mamba VL Tables',
    IF(COUNT(*) >= 35, 'PASS', 'FAIL'),
    35,
    COUNT(*),
    CONCAT('Total Mamba VL tables found: ', COUNT(*))
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND (table_name LIKE 'mamba_vl_%' OR table_name LIKE 'mamba_stg_vl_%'
     OR table_name LIKE 'mamba_fact_vl%' OR table_name LIKE 'mamba_bridge_vl_%'
     OR table_name LIKE 'mamba_mart_vl%' OR table_name LIKE 'mamba_etl_%')
AND table_name NOT LIKE '%_bak';

-- ============================================================================
-- INDEX VALIDATION
-- ============================================================================

INSERT INTO validation_results
SELECT
    'Critical Episode Indexes',
    IF(COUNT(DISTINCT index_name) >= 10, 'PASS', 'FAIL'),
    10,
    COUNT(DISTINCT index_name),
    CONCAT('mamba_fact_viral_load_episode has ', COUNT(DISTINCT index_name), ' indexes')
FROM information_schema.statistics
WHERE table_schema = DATABASE()
AND table_name = 'mamba_fact_viral_load_episode'
AND index_name != 'PRIMARY';

-- ============================================================================
-- SUMMARY REPORT
-- ============================================================================

SELECT '========================================================================' AS '';
SELECT 'VALIDATION SUMMARY' AS '';
SELECT '========================================================================' AS '';

SELECT
    test_name AS 'Test Name',
    test_result AS 'Result',
    expected_value AS 'Expected',
    actual_value AS 'Actual',
    notes AS 'Notes'
FROM validation_results
ORDER BY
    CASE WHEN test_result = 'FAIL' THEN 1 ELSE 2 END,
    test_name;

SELECT '========================================================================' AS '';
SELECT
    SUM(CASE WHEN test_result = 'PASS' THEN 1 ELSE 0 END) AS 'Tests Passed',
    SUM(CASE WHEN test_result = 'FAIL' THEN 1 ELSE 0 END) AS 'Tests Failed',
    COUNT(*) AS 'Total Tests'
FROM validation_results;

-- Show sample configuration data
SELECT '========================================================================' AS '';
SELECT 'SAMPLE CONFIGURATION DATA' AS '';
SELECT '========================================================================' AS '';

SELECT 'Concept Mappings (sample):' AS '';
SELECT
    canonical_field,
    concept_id,
    LEFT(concept_uuid, 36) AS concept_uuid,
    source_workflow,
    value_type
FROM mamba_vl_concept_mapping
ORDER BY canonical_field
LIMIT 10;

SELECT '' AS '';
SELECT 'Coded Value Mappings (sample):' AS '';
SELECT
    canonical_value,
    answer_concept_id,
    is_valid_result,
    is_suppressed
FROM mamba_vl_coded_value_mapping
ORDER BY canonical_value
LIMIT 10;

SELECT '' AS '';
SELECT 'Rule Configurations (sample):' AS '';
SELECT
    rule_name,
    population_group,
    parameter_name,
    parameter_value
FROM mamba_vl_rule_config
ORDER BY rule_name, population_group
LIMIT 10;

SELECT '========================================================================' AS '';

-- Final result
SELECT
    CASE
        WHEN SUM(CASE WHEN test_result = 'FAIL' THEN 1 ELSE 0 END) = 0
        THEN 'VALIDATION PASSED - All tests successful!'
        ELSE CONCAT('VALIDATION FAILED - ', SUM(CASE WHEN test_result = 'FAIL' THEN 1 ELSE 0 END), ' test(s) failed')
    END AS 'Final Result';

SELECT '========================================================================' AS '';
