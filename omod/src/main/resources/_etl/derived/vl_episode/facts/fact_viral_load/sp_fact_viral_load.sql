-- $BEGIN
-- ============================================================================
-- Viral Load Fact Table - Main Orchestration
-- ============================================================================

-- Drop existing procedure
DROP PROCEDURE IF EXISTS sp_fact_viral_load;

DELIMITER //

CREATE PROCEDURE sp_fact_viral_load()
BEGIN
    DECLARE v_start_time DATETIME DEFAULT NOW();
    DECLARE v_rows_inserted INT;

    -- Log start
    INSERT INTO mamba_etl_run_log (run_id, log_level, message, step_name, duration_ms)
    VALUES (
        (SELECT MAX(run_id) FROM mamba_etl_run),
        'INFO',
        'Starting Viral Load fact table build',
        'VL_FACT_START',
        0
    );

    -- Create table (if not exists)
    -- Source: sp_fact_viral_load_create.sql
    -- Note: Table creation happens once, not on every run

    -- Truncate existing data
    TRUNCATE TABLE mamba_fact_viral_load;

    -- Insert data
    -- Source: sp_fact_viral_load_insert.sql
    INSERT INTO mamba_fact_viral_load (
        patient_id, encounter_id, visit_id, panel_obs_id, order_id, accession_number,
        order_date, sample_collection_date, viral_load_date, return_to_facility_date,
        viral_load_numeric, viral_load_qualitative, viral_load_interpretation,
        is_valid_result, invalid_reason,
        is_suppressed, is_unsuppressed, is_high_viral_load, suppression_threshold,
        art_start_date, days_on_art, current_regimen, current_regimen_line,
        pregnant_status, breastfeeding_status,
        indication_for_vl_testing, specimen_source, source_workflow, location_id,
        date_created
    )
    SELECT
        o.person_id, o.encounter_id, e.visit_id, o.obs_id, o.order_id, o.accession_number,
        COALESCE(ord.date_activated,
            (SELECT order_obs.obs_datetime FROM obs order_obs
             WHERE order_obs.concept_id = 1271 AND order_obs.value_coded = 165412
             AND order_obs.encounter_id = o.encounter_id AND order_obs.voided = 0 LIMIT 1)
        ) AS order_date,
        COALESCE(
            (SELECT child.value_datetime FROM obs child WHERE child.obs_group_id = o.obs_id
             AND child.concept_id = (SELECT concept_id FROM concept WHERE uuid = '0b434cfa-b11c-4d14-aaa2-9aed6ca2da88') LIMIT 1),
            (SELECT child.value_datetime FROM obs child WHERE child.obs_group_id = o.obs_id
             AND child.concept_id = 163023 LIMIT 1)
        ) AS sample_collection_date,
        o.obs_datetime,
        (SELECT child.value_datetime FROM obs child WHERE child.obs_group_id = o.obs_id
         AND child.concept_id = (SELECT concept_id FROM concept WHERE uuid = '5b4037d6-a7e2-11ed-afa1-0242ac120002') LIMIT 1),
        (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1),
        (SELECT coded.name FROM obs child LEFT JOIN concept_name coded ON child.value_coded = coded.concept_id
         WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 AND coded.locale = 'en' AND coded.voided = 0 LIMIT 1),
        CASE
            WHEN (SELECT child.value_coded FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 LIMIT 1) = 1306 THEN 'TARGET_NOT_DETECTED'
            WHEN (SELECT child.value_coded FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 LIMIT 1) = 1301 THEN 'DETECTED'
            WHEN (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1) < 1000 THEN 'SUPPRESSED'
            WHEN (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1) >= 1000 THEN 'UNSUPPRESSED'
            ELSE NULL
        END,
        CASE WHEN (SELECT child.value_coded FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 LIMIT 1) IN (1304, 1310) THEN 0 ELSE 1 END,
        CASE WHEN (SELECT child.value_coded FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 LIMIT 1) = 1304 THEN 'Poor Sample Quality'
             WHEN (SELECT child.value_coded FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 LIMIT 1) = 1310 THEN 'Rejected' ELSE NULL END,
        CASE WHEN (SELECT child.value_coded FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 LIMIT 1) = 1306 THEN 1
             WHEN (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1) < 1000 THEN 1
             WHEN (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1) >= 1000 THEN 0 ELSE NULL END,
        CASE WHEN (SELECT child.value_coded FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 LIMIT 1) = 1301 THEN 1
             WHEN (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1) >= 1000 THEN 1
             WHEN (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1) < 1000 THEN 0 ELSE NULL END,
        CASE WHEN (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1) >= 1000 THEN 1 ELSE 0 END,
        1000,
        (SELECT MIN(pp.date_enrolled) FROM patient_program pp JOIN program pr ON pp.program_id = pr.program_id
         WHERE pp.patient_id = o.person_id AND pp.voided = 0 AND (pr.uuid LIKE '%a9bb3860%' OR pr.uuid LIKE '%c4b6b5e6%')),
        DATEDIFF(o.obs_datetime, (SELECT MIN(pp.date_enrolled) FROM patient_program pp JOIN program pr ON pp.program_id = pr.program_id
                                     WHERE pp.patient_id = o.person_id AND pp.voided = 0 AND (pr.uuid LIKE '%a9bb3860%' OR pr.uuid LIKE '%c4b6b5e6%'))),
        (SELECT current_regimen FROM mamba_fact_patients_latest_current_regimen WHERE client_id = o.person_id),
        (SELECT regimen_line FROM mamba_fact_patients_latest_current_regimen WHERE client_id = o.person_id),
        (SELECT preg.value_coded FROM obs preg WHERE preg.person_id = o.person_id AND preg.concept_id = 155748 AND preg.voided = 0 ORDER BY preg.obs_datetime DESC LIMIT 1),
        (SELECT bf.value_coded FROM obs bf WHERE bf.person_id = o.person_id AND bf.concept_id = 1599 AND bf.voided = 0 ORDER BY bf.obs_datetime DESC LIMIT 1),
        (SELECT GROUP_CONCAT(DISTINCT child.value_coded) FROM obs child WHERE child.obs_group_id = o.obs_id
         AND child.concept_id = (SELECT concept_id FROM concept WHERE uuid = '168689') AND child.voided = 0),
        (SELECT cs.name FROM test_order tor JOIN concept_name cs ON tor.specimen_source = cs.concept_id
         WHERE tor.order_id = o.order_id AND cs.locale = 'en' AND cs.concept_name_type = 'FULLY_SPECIFIED' LIMIT 1),
        CASE WHEN e.encounter_type = 15 THEN 'LEGACY_ART_CARD'
             WHEN e.encounter_type IN (SELECT encounter_type_id FROM encounter_type WHERE uuid = 'cbf01392-ca29-11e9-a32f-2a2ae2dbcce4') THEN 'NEW_VL_REQUEST_FORM' ELSE 'UNKNOWN' END,
        o.location_id,
        NOW()
    FROM obs o
    JOIN person p ON o.person_id = p.person_id
    LEFT JOIN encounter e ON o.encounter_id = e.encounter_id
    LEFT JOIN orders ord ON o.order_id = ord.order_id
    LEFT JOIN mamba_fact_patients_latest_current_regimen reg ON o.person_id = reg.client_id
    WHERE o.concept_id = 165412 AND o.voided = 0 AND p.voided = 0;

    SET v_rows_inserted = ROW_COUNT();

    -- Log completion
    INSERT INTO mamba_etl_run_log (run_id, log_level, message, step_name, duration_ms)
    VALUES (
        (SELECT MAX(run_id) FROM mamba_etl_run),
        'INFO',
        CONCAT('Viral Load fact table completed: ', v_rows_inserted, ' records in ',
               TIMESTAMPDIFF(SECOND, v_start_time, NOW()), ' seconds'),
        'VL_FACT_COMPLETE',
        TIMESTAMPDIFF(MICROSECOND, v_start_time, NOW()) / 1000
    );

    -- Return result
    SELECT 'Viral Load fact table build complete' AS result,
           v_rows_inserted AS rows_inserted,
           TIMESTAMPDIFF(SECOND, v_start_time, NOW()) AS duration_seconds;

END //

DELIMITER ;

-- Execute the procedure
CALL sp_fact_viral_load();

-- $END
