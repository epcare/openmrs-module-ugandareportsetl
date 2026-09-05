-- ============================================
-- Comprehensive VL Episode ETL Procedure
-- ============================================
-- Purpose: Populate mamba_fact_viral_load_episode from all VL sources
-- Sources:
--   1. Native orders with linked results (~11% of data)
--   2. Legacy ART card observations (~89% of data)
--
-- Key Features:
--   - Extracts results from obs and DIRECTLY joins to orders via obs.order_id
--   - Handles both workflows: native (with order_id) and legacy/offered (without order_id)
--   - Matches orphan results to orders using accession number and patient+date window
--   - Builds comprehensive episodes
--   - Calculates suppression status
--   - Infers testing model
--   - Tracks linkage confidence
--   - Exposes data quality issues
--
-- Workflow Priority:
--   1. DIRECT_ORDER_ID: obs with order_id → Direct join to orders (HIGH confidence, ~11%)
--   2. ACCESSION_NUMBER: Match by accession number (HIGH confidence)
--   3. PATIENT_DATE: Match by patient + date window (MEDIUM confidence, 30-day default)
--   4. UNMATCHED: Orphan results without matching orders
--
-- Processing Steps:
--   1. Clear existing data
--   2. Extract native orders from orders table
--   3. Extract legacy derived orders from obs (Tests Ordered concept)
--   4. Extract results with direct obs.order_id linkage
--   4b. Extract qualitative-only results with direct linkage
--   4c. Remove duplicate order episodes (cleanup after direct linkage)
--   5. Match remaining by accession number
--   6. Match remaining by patient+date window
--   7-11. Calculate derived fields (suppression, testing model, etc.)
--
-- Created: 2026-07-29
-- Updated: 2026-08-14 - Added direct obs.order_id linkage and duplicate cleanup
-- ============================================

DROP PROCEDURE IF EXISTS sp_mamba_fact_vl_episode_etl;

DELIMITER //

CREATE PROCEDURE sp_mamba_fact_vl_episode_etl()
BEGIN
    DECLARE start_time DATETIME DEFAULT NOW();
    DECLARE episode_count INT;
    DECLARE orphan_count INT;
    DECLARE unmatched_order_count INT;

    -- ============ STEP 1: Clear existing data ============
    TRUNCATE TABLE mamba_fact_viral_load_episode;

    -- ============ STEP 2: Extract native orders ============
    INSERT INTO mamba_fact_viral_load_episode (
        patient_id,
        native_order_id,
        native_order_uuid,
        order_record_type,
        order_source_workflow,
        order_date,
        order_date_source,
        order_encounter_id,
        ordering_provider_id,
        accession_number,
        accession_number_normalized,
        sample_collection_date,
        sample_collection_date_source,
        specimen_source,
        location_id,
        encounter_id,
        encounter_datetime,
        pipeline_status,
        is_order_without_result,
        linkage_method,
        linkage_confidence,
        etl_created_at
    )
    SELECT DISTINCT
        o.patient_id,
        o.order_id,
        o.uuid,
        'NATIVE_ORDER',
        'NEW_VL_REQUEST_FORM',
        DATE(o.date_activated) AS order_date,
        'order.date_activated',
        o.encounter_id,
        o.orderer,
        UPPER(TRIM(o.accession_number)) AS accession_number,
        UPPER(TRIM(REPLACE(REPLACE(o.accession_number, '-', ''), '/', ''))) AS accession_number_normalized,
        DATE(o.scheduled_date) AS sample_collection_date,
        'order.scheduled_date',
        tos.specimen_source,
        e.location_id,
        o.encounter_id,
        e.encounter_datetime,
        'ORDERED_NOT_COLLECTED',
        1 AS is_order_without_result,
        'UNMATCHED_ORDER',
        'HIGH',
        NOW()
    FROM orders o
    INNER JOIN test_order tos ON o.order_id = tos.order_id
    INNER JOIN patient p ON o.patient_id = p.patient_id
    LEFT JOIN encounter e ON o.encounter_id = e.encounter_id
    WHERE o.concept_id = 165412  -- Viral Load Test concept
      AND o.voided = 0
      AND (o.care_setting = 1 OR o.care_setting IS NULL)
      AND o.date_activated IS NOT NULL;

    -- ============ STEP 3: Extract legacy derived orders ============
    INSERT INTO mamba_fact_viral_load_episode (
        patient_id,
        derived_order_key,
        order_record_type,
        order_source_workflow,
        order_date,
        order_date_source,
        order_encounter_id,
        accession_number,
        location_id,
        encounter_id,
        encounter_datetime,
        pipeline_status,
        is_order_without_result,
        linkage_method,
        linkage_confidence,
        etl_created_at
    )
    SELECT DISTINCT
        obs_parent.person_id AS patient_id,
        CONCAT('LEGACY_OBS:', obs_parent.obs_id) AS derived_order_key,
        'DERIVED_LEGACY_ORDER',
        'LEGACY_ART_CARD',
        DATE(obs_parent.obs_datetime) AS order_date,
        'obs.obs_datetime',
        obs_parent.encounter_id,
        obs_accession.value_text AS accession_number,
        obs_parent.location_id,
        obs_parent.encounter_id,
        obs_parent.obs_datetime,
        'ORDERED_NOT_COLLECTED',
        1 AS is_order_without_result,
        'UNMATCHED_ORDER',
        'HIGH',
        NOW()
    FROM obs obs_parent
    INNER JOIN obs obs_ordered ON obs_parent.person_id = obs_ordered.person_id
        AND obs_parent.encounter_id = obs_ordered.encounter_id
    INNER JOIN patient p ON obs_parent.person_id = p.patient_id
    -- Legacy order detection: Tests Ordered (1271) -> Viral Load Test (165412)
    LEFT JOIN obs obs_accession ON obs_parent.person_id = obs_accession.person_id
        AND obs_accession.concept_id = 165845  -- Accession Number
        AND obs_accession.voided = 0
    WHERE obs_parent.concept_id = 165412  -- Viral Load Test panel
      AND obs_ordered.concept_id = 1271   -- Tests Ordered
      AND obs_ordered.value_coded = 165412  -- Answer: Viral Load Test
      AND obs_parent.voided = 0
      AND obs_ordered.voided = 0
      AND obs_parent.obs_group_id IS NULL;  -- Parent panel, not child

    -- ============ STEP 4: Extract VL results with direct order linkage ============
    -- Extracts VL results from obs and joins to orders table when obs.order_id exists
    -- This handles both workflows:
    --   1. Native orders: obs WITH order_id → Direct join to orders table (HIGH confidence)
    --   2. Legacy/offered: obs WITHOUT order_id → Will use fallback matching later
    INSERT INTO mamba_fact_viral_load_episode (
        patient_id,
        native_order_id,
        native_order_uuid,
        panel_obs_id,
        order_record_type,
        order_source_workflow,
        order_date,
        order_date_source,
        order_encounter_id,
        ordering_provider_id,
        accession_number,
        accession_number_normalized,
        result_encounter_id,
        viral_load_clinical_date,
        viral_load_date_source,
        result_database_creation_date,
        result_encounter_datetime,
        sample_collection_date,
        sample_collection_date_source,
        result_numeric_raw,
        result_numeric,
        result_numeric_copies,
        result_qualitative_raw,
        result_qualitative_concept_id,
        return_to_facility_date,
        specimen_source,
        location_id,
        encounter_id,
        encounter_datetime,
        pipeline_status,
        is_orphan_result,
        linkage_method,
        linkage_confidence,
        result_status,
        etl_created_at
    )
    SELECT DISTINCT
        obs_numeric.person_id AS patient_id,
        ord.order_id AS native_order_id,
        ord.uuid AS native_order_uuid,
        obs_numeric.obs_id AS panel_obs_id,
        CASE
            WHEN ord.order_id IS NOT NULL THEN 'NATIVE_ORDER'
            ELSE 'NO_ORDER'
        END AS order_record_type,
        CASE
            WHEN e.encounter_type = 15 THEN 'LEGACY_ART_CARD'
            WHEN e.encounter_type IN (SELECT encounter_type_id FROM encounter_type WHERE uuid = 'cbf01392-ca29-11e9-a32f-2a2ae2dbcce4') THEN 'NEW_VL_REQUEST_FORM'
            WHEN ord.order_id IS NOT NULL THEN 'NEW_VL_REQUEST_FORM'
            ELSE 'UNKNOWN'
        END AS order_source_workflow,
        COALESCE(DATE(ord.date_activated), NULL) AS order_date,
        CASE
            WHEN ord.order_id IS NOT NULL THEN 'order.date_activated'
            ELSE NULL
        END AS order_date_source,
        COALESCE(ord.encounter_id, NULL) AS order_encounter_id,
        COALESCE(ord.orderer, NULL) AS ordering_provider_id,
        -- Accession number: prioritize from orders table, then from obs
        COALESCE(
            UPPER(TRIM(ord.accession_number)),
            UPPER(TRIM(obs_accession.value_text)),
            NULL
        ) AS accession_number,
        COALESCE(
            UPPER(TRIM(REPLACE(REPLACE(ord.accession_number, '-', ''), '/', ''))),
            UPPER(TRIM(REPLACE(REPLACE(obs_accession.value_text, '-', ''), '/', ''))),
            NULL
        ) AS accession_number_normalized,
        obs_numeric.encounter_id AS result_encounter_id,
        COALESCE(
            DATE(obs_vl_date.value_datetime),
            DATE(obs_numeric.obs_datetime)
        ) AS viral_load_clinical_date,
        COALESCE(
            IF(obs_vl_date.obs_id IS NOT NULL, 'obs_datetime', NULL),
            'numeric_obs_datetime'
        ) AS viral_load_date_source,
        obs_numeric.date_created AS result_database_creation_date,
        obs_numeric.obs_datetime AS result_encounter_datetime,
        COALESCE(
            DATE(obs_sample_date.value_datetime),
            DATE(ord.scheduled_date),
            NULL
        ) AS sample_collection_date,
        COALESCE(
            IF(obs_sample_date.obs_id IS NOT NULL, 'obs_datetime', NULL),
            IF(ord.scheduled_date IS NOT NULL, 'order.scheduled_date', NULL),
            NULL
        ) AS sample_collection_date_source,
        obs_numeric.value_numeric AS result_numeric_raw,
        obs_numeric.value_numeric AS result_numeric,
        CAST(obs_numeric.value_numeric AS SIGNED) AS result_numeric_copies,
        obs_qual_coded.short_name AS result_qualitative_raw,
        obs_qual.value_coded AS result_qualitative_concept_id,
        DATE(obs_return_date.value_datetime) AS return_to_facility_date,
        tos.specimen_source,
        obs_numeric.location_id,
        obs_numeric.encounter_id,
        obs_numeric.obs_datetime,
        CASE
            WHEN ord.order_id IS NOT NULL THEN 'RESULT_ENTERED'
            ELSE 'ORPHAN_RESULT'
        END AS pipeline_status,
        CASE
            WHEN ord.order_id IS NOT NULL THEN 0
            ELSE 1
        END AS is_orphan_result,
        CASE
            WHEN ord.order_id IS NOT NULL THEN 'DIRECT_ORDER_ID'
            ELSE 'UNMATCHED_RESULT'
        END AS linkage_method,
        CASE
            WHEN ord.order_id IS NOT NULL THEN 'HIGH'
            ELSE 'MEDIUM'
        END AS linkage_confidence,
        'VALID' AS result_status,
        NOW()
    FROM obs obs_numeric
    -- LEFT JOIN to orders table using obs.order_id (direct foreign key linkage)
    LEFT JOIN orders ord ON obs_numeric.order_id = ord.order_id AND ord.voided = 0
    LEFT JOIN test_order tos ON ord.order_id = tos.order_id
    LEFT JOIN encounter e ON ord.encounter_id = e.encounter_id
    -- Start with numeric VL observations (concept 856)
    -- Join to qualitative VL result (concept 1305) by encounter + person + datetime
    LEFT JOIN obs obs_qual ON obs_numeric.person_id = obs_qual.person_id
        AND obs_numeric.encounter_id = obs_qual.encounter_id
        AND obs_qual.concept_id = 1305  -- VIRAL LOAD QUALITATIVE
        AND obs_qual.voided = 0
        AND (
            obs_qual.obs_datetime = obs_numeric.obs_datetime OR
            -- Allow slight time differences (within 1 minute)
            ABS(TIMESTAMPDIFF(SECOND, obs_qual.obs_datetime, obs_numeric.obs_datetime)) <= 60
        )
    LEFT JOIN concept obs_qual_coded ON obs_qual.value_coded = obs_qual_coded.concept_id
    -- Join to VL date (concept 163023) by encounter + person + datetime
    LEFT JOIN obs obs_vl_date ON obs_numeric.person_id = obs_vl_date.person_id
        AND obs_numeric.encounter_id = obs_vl_date.encounter_id
        AND obs_vl_date.concept_id = 163023  -- HIV VIRAL LOAD DATE
        AND obs_vl_date.value_datetime IS NOT NULL
        AND obs_vl_date.voided = 0
        AND (
            obs_vl_date.obs_datetime = obs_numeric.obs_datetime OR
            ABS(TIMESTAMPDIFF(SECOND, obs_vl_date.obs_datetime, obs_numeric.obs_datetime)) <= 60
        )
    -- Join to sample collection date (concept 163023) by encounter + person
    LEFT JOIN obs obs_sample_date ON obs_numeric.person_id = obs_sample_date.person_id
        AND obs_numeric.encounter_id = obs_sample_date.encounter_id
        AND obs_sample_date.concept_id = 163023
        AND obs_sample_date.value_datetime IS NOT NULL
        AND obs_sample_date.voided = 0
        AND obs_sample_date.obs_id != obs_vl_date.obs_id  -- Different from VL date
        AND (
            obs_sample_date.obs_datetime = obs_numeric.obs_datetime OR
            ABS(TIMESTAMPDIFF(SECOND, obs_sample_date.obs_datetime, obs_numeric.obs_datetime)) <= 60
        )
    -- Join to return to facility date
    LEFT JOIN obs obs_return_date ON obs_numeric.person_id = obs_return_date.person_id
        AND obs_numeric.encounter_id = obs_return_date.encounter_id
        AND obs_return_date.concept_id = 167944  -- DATE RESULT RECIEVED
        AND obs_return_date.voided = 0
        AND (
            obs_return_date.obs_datetime = obs_numeric.obs_datetime OR
            ABS(TIMESTAMPDIFF(SECOND, obs_return_date.obs_datetime, obs_numeric.obs_datetime)) <= 60
        )
    -- Join to accession number
    LEFT JOIN obs obs_accession ON obs_numeric.person_id = obs_accession.person_id
        AND obs_numeric.encounter_id = obs_accession.encounter_id
        AND obs_accession.concept_id = 165845  -- Lab Number
        AND obs_accession.voided = 0
        AND (
            obs_accession.obs_datetime = obs_numeric.obs_datetime OR
            ABS(TIMESTAMPDIFF(SECOND, obs_accession.obs_datetime, obs_numeric.obs_datetime)) <= 60
        )
    -- Join to specimen source
    LEFT JOIN obs obs_specimen ON obs_numeric.person_id = obs_specimen.person_id
        AND obs_numeric.encounter_id = obs_specimen.encounter_id
        AND obs_specimen.concept_id = 159959  -- SPECIMEN SITE
        AND obs_specimen.voided = 0
        AND (
            obs_specimen.obs_datetime = obs_numeric.obs_datetime OR
            ABS(TIMESTAMPDIFF(SECOND, obs_specimen.obs_datetime, obs_numeric.obs_datetime)) <= 60
        )
    WHERE obs_numeric.concept_id = 856  -- HIV VIRAL LOAD (numeric)
      AND obs_numeric.voided = 0
      AND obs_numeric.value_numeric IS NOT NULL;

    -- ============ STEP 4b: Extract VL results with only qualitative values (no numeric) ============
    -- Similar to STEP 4, handles qualitative-only results with direct order linkage
    INSERT INTO mamba_fact_viral_load_episode (
        patient_id,
        native_order_id,
        native_order_uuid,
        panel_obs_id,
        order_record_type,
        order_source_workflow,
        accession_number,
        accession_number_normalized,
        result_encounter_id,
        viral_load_clinical_date,
        viral_load_date_source,
        result_database_creation_date,
        result_encounter_datetime,
        result_qualitative_raw,
        result_qualitative_concept_id,
        location_id,
        encounter_id,
        encounter_datetime,
        pipeline_status,
        is_orphan_result,
        linkage_method,
        linkage_confidence,
        result_status,
        etl_created_at
    )
    SELECT DISTINCT
        obs_qual.person_id AS patient_id,
        ord.order_id AS native_order_id,
        ord.uuid AS native_order_uuid,
        obs_qual.obs_id AS panel_obs_id,
        CASE
            WHEN ord.order_id IS NOT NULL THEN 'NATIVE_ORDER'
            ELSE 'NO_ORDER'
        END AS order_record_type,
        CASE
            WHEN e.encounter_type = 15 THEN 'LEGACY_ART_CARD'
            WHEN e.encounter_type IN (SELECT encounter_type_id FROM encounter_type WHERE uuid = 'cbf01392-ca29-11e9-a32f-2a2ae2dbcce4') THEN 'NEW_VL_REQUEST_FORM'
            WHEN ord.order_id IS NOT NULL THEN 'NEW_VL_REQUEST_FORM'
            ELSE 'UNKNOWN'
        END AS order_source_workflow,
        -- Accession number: prioritize from orders table, then from obs
        COALESCE(
            UPPER(TRIM(ord.accession_number)),
            UPPER(TRIM(obs_accession.value_text)),
            NULL
        ) AS accession_number,
        COALESCE(
            UPPER(TRIM(REPLACE(REPLACE(ord.accession_number, '-', ''), '/', ''))),
            UPPER(TRIM(REPLACE(REPLACE(obs_accession.value_text, '-', ''), '/', ''))),
            NULL
        ) AS accession_number_normalized,
        obs_qual.encounter_id AS result_encounter_id,
        COALESCE(
            DATE(obs_vl_date.value_datetime),
            DATE(obs_qual.obs_datetime)
        ) AS viral_load_clinical_date,
        COALESCE(
            IF(obs_vl_date.obs_id IS NOT NULL, 'obs_datetime', NULL),
            'qualitative_obs_datetime'
        ) AS viral_load_date_source,
        obs_qual.date_created AS result_database_creation_date,
        obs_qual.obs_datetime AS result_encounter_datetime,
        obs_qual_coded.short_name AS result_qualitative_raw,
        obs_qual.value_coded AS result_qualitative_concept_id,
        obs_qual.location_id,
        obs_qual.encounter_id,
        obs_qual.obs_datetime,
        CASE
            WHEN ord.order_id IS NOT NULL THEN 'RESULT_ENTERED'
            ELSE 'ORPHAN_RESULT'
        END AS pipeline_status,
        CASE
            WHEN ord.order_id IS NOT NULL THEN 0
            ELSE 1
        END AS is_orphan_result,
        CASE
            WHEN ord.order_id IS NOT NULL THEN 'DIRECT_ORDER_ID'
            ELSE 'UNMATCHED_RESULT'
        END AS linkage_method,
        CASE
            WHEN ord.order_id IS NOT NULL THEN 'HIGH'
            ELSE 'MEDIUM'
        END AS linkage_confidence,
        'VALID' AS result_status,
        NOW()
    FROM obs obs_qual
    -- LEFT JOIN to orders table using obs.order_id (direct foreign key linkage)
    LEFT JOIN orders ord ON obs_qual.order_id = ord.order_id AND ord.voided = 0
    LEFT JOIN encounter e ON ord.encounter_id = e.encounter_id
    -- Join to VL date
    LEFT JOIN obs obs_vl_date ON obs_qual.person_id = obs_vl_date.person_id
        AND obs_qual.encounter_id = obs_vl_date.encounter_id
        AND obs_vl_date.concept_id = 163023  -- HIV VIRAL LOAD DATE
        AND obs_vl_date.value_datetime IS NOT NULL
        AND obs_vl_date.voided = 0
        AND (
            obs_vl_date.obs_datetime = obs_qual.obs_datetime OR
            ABS(TIMESTAMPDIFF(SECOND, obs_vl_date.obs_datetime, obs_qual.obs_datetime)) <= 60
        )
    -- Join to accession number
    LEFT JOIN obs obs_accession ON obs_qual.person_id = obs_accession.person_id
        AND obs_qual.encounter_id = obs_accession.encounter_id
        AND obs_accession.concept_id = 165845  -- Lab Number
        AND obs_accession.voided = 0
    LEFT JOIN concept obs_qual_coded ON obs_qual.value_coded = obs_qual_coded.concept_id
    -- Start with qualitative VL observations (concept 1305)
    WHERE obs_qual.concept_id = 1305  -- VIRAL LOAD QUALITATIVE
      AND obs_qual.voided = 0
      AND obs_qual.value_coded IS NOT NULL
      -- Exclude if already captured in numeric step (has corresponding numeric result)
      AND NOT EXISTS (
          SELECT 1 FROM obs obs_numeric
          WHERE obs_numeric.person_id = obs_qual.person_id
            AND obs_numeric.encounter_id = obs_qual.encounter_id
            AND obs_numeric.concept_id = 856
            AND obs_numeric.value_numeric IS NOT NULL
            AND obs_numeric.voided = 0
            AND (
                obs_numeric.obs_datetime = obs_qual.obs_datetime OR
                ABS(TIMESTAMPDIFF(SECOND, obs_numeric.obs_datetime, obs_qual.obs_datetime)) <= 60
            )
      );

    -- ============ STEP 4c: Remove duplicate order episodes that were directly linked ============
    -- After STEP 4 and 4b, we have both order episodes (from STEP 2) and result episodes
    -- For results directly linked via obs.order_id, we need to remove the duplicate order episodes
    DELETE odr FROM mamba_fact_viral_load_episode odr
    INNER JOIN mamba_fact_viral_load_episode res
        ON odr.native_order_id = res.native_order_id
        AND odr.native_order_id IS NOT NULL
    WHERE odr.is_order_without_result = 1
      AND res.linkage_method = 'DIRECT_ORDER_ID'
      AND odr.episode_id != res.episode_id;

    -- ============ STEP 5: Match orders to results by accession number ============
    -- Only processes results that are NOT already directly linked via obs.order_id
    -- Create temporary table for accession number matching
    CREATE TEMPORARY TABLE temp_accession_match AS
    SELECT
        odr.patient_id,
        UPPER(TRIM(REPLACE(REPLACE(odr.accession_number, '-', ''), '/', ''))) AS accession_norm,
        odr.episode_id AS order_episode_id,
        odr.native_order_id AS order_native_order_id,
        res.episode_id AS result_episode_id
    FROM mamba_fact_viral_load_episode odr
    INNER JOIN mamba_fact_viral_load_episode res
        ON odr.patient_id = res.patient_id
        AND UPPER(TRIM(REPLACE(REPLACE(odr.accession_number, '-', ''), '/', ''))) =
            UPPER(TRIM(REPLACE(REPLACE(res.accession_number, '-', ''), '/', '')))
    WHERE odr.accession_number IS NOT NULL
      AND odr.accession_number != ''
      AND odr.is_order_without_result = 1
      AND res.is_orphan_result = 1
      AND res.native_order_id IS NULL;  -- Skip already directly linked results

    UPDATE mamba_fact_viral_load_episode ep
    INNER JOIN temp_accession_match t ON ep.episode_id = t.result_episode_id
    SET ep.native_order_id = t.order_native_order_id,
        ep.linkage_method = 'ACCESSION_NUMBER',
        ep.linkage_confidence = 'HIGH',
        ep.pipeline_status = 'RESULT_ENTERED',
        ep.is_orphan_result = 0;

    -- Remove the now-matched orders
    DELETE FROM mamba_fact_viral_load_episode
    WHERE episode_id IN (SELECT order_episode_id FROM temp_accession_match);

    DROP TEMPORARY TABLE temp_accession_match;

    -- ============ STEP 6: Match orders to results by patient + date window ============
    -- Only processes results that are NOT already directly linked via obs.order_id
    -- Create temporary table for patient+date matching
    CREATE TEMPORARY TABLE temp_date_match AS
    SELECT
        odr.patient_id,
        DATEDIFF(COALESCE(res.viral_load_clinical_date, res.sample_collection_date),
                  odr.order_date) AS days_diff,
        odr.episode_id AS order_episode_id,
        odr.native_order_id AS order_native_order_id,
        res.episode_id AS result_episode_id
    FROM mamba_fact_viral_load_episode odr
    INNER JOIN mamba_fact_viral_load_episode res
        ON odr.patient_id = res.patient_id
    WHERE odr.is_order_without_result = 1
      AND res.is_orphan_result = 1
      AND res.native_order_id IS NULL  -- Skip already directly linked results
      AND COALESCE(res.viral_load_clinical_date, res.sample_collection_date) IS NOT NULL
      AND odr.order_date IS NOT NULL
      AND DATEDIFF(COALESCE(res.viral_load_clinical_date, res.sample_collection_date), odr.order_date)
          BETWEEN 0 AND (SELECT CAST(parameter_value AS UNSIGNED) FROM mamba_vl_rule_config
                        WHERE rule_name = 'MATCHING_WINDOW' AND parameter_name = 'patient_date_match_days')
      AND odr.episode_id = (
          -- Get the closest unmatched order
          SELECT closest.episode_id
          FROM mamba_fact_viral_load_episode closest
          WHERE closest.patient_id = odr.patient_id
            AND closest.is_order_without_result = 1
          ORDER BY ABS(DATEDIFF(COALESCE(res.viral_load_clinical_date, res.sample_collection_date),
                                closest.order_date))
          LIMIT 1
      );

    UPDATE mamba_fact_viral_load_episode ep
    INNER JOIN temp_date_match t ON ep.episode_id = t.result_episode_id
    SET ep.native_order_id = t.order_native_order_id,
        ep.linkage_method = 'PATIENT_DATE',
        ep.linkage_confidence = 'MEDIUM',
        ep.pipeline_status = 'RESULT_ENTERED',
        ep.is_orphan_result = 0,
        ep.linkage_score = t.days_diff;

    -- Remove the now-matched orders
    DELETE FROM mamba_fact_viral_load_episode
    WHERE episode_id IN (SELECT order_episode_id FROM temp_date_match);

    DROP TEMPORARY TABLE temp_date_match;

    -- ============ STEP 7: Calculate suppression status ============
    UPDATE mamba_fact_viral_load_episode ep
    SET ep.is_suppressed =
        CASE
            WHEN ep.result_qualitative_concept_id = 1306 THEN 1  -- Target Not Detected
            WHEN ep.result_numeric IS NOT NULL AND ep.result_numeric < ep.suppression_threshold THEN 1
            WHEN ep.result_qualitative_concept_id = 1301 AND ep.result_numeric IS NOT NULL
                AND ep.result_numeric < ep.suppression_threshold THEN 1
            WHEN ep.result_qualitative_concept_id IN (1306, 1304) THEN 1  -- TND or poor sample quality
            ELSE 0
        END,
        ep.is_unsuppressed =
        CASE
            WHEN ep.result_status = 'INVALID' OR ep.result_qualitative_raw LIKE '%POOR SAMPLE%' THEN NULL
            WHEN ep.result_numeric IS NOT NULL AND ep.result_numeric >= ep.suppression_threshold THEN 1
            WHEN ep.result_qualitative_concept_id = 1301 AND ep.result_numeric IS NULL THEN 1  -- Detected without numeric
            ELSE 0
        END,
        ep.is_high_viral_load =
        CASE
            WHEN ep.result_numeric >= 5000 THEN 1
            WHEN ep.result_numeric >= ep.suppression_threshold THEN 1
            WHEN ep.result_qualitative_concept_id = 1301 AND ep.result_numeric IS NULL THEN 1  -- Detected without numeric
            ELSE 0
        END,
        ep.result_interpretation =
        CASE
            WHEN ep.result_status = 'INVALID' OR ep.result_qualitative_raw LIKE '%POOR SAMPLE%' THEN 'INVALID'
            WHEN ep.result_qualitative_concept_id = 1306 THEN 'SUPPRESSED'
            WHEN ep.result_qualitative_concept_id = 1304 THEN 'INVALID'  -- Poor Sample Quality
            WHEN ep.result_numeric IS NOT NULL AND ep.result_numeric < ep.suppression_threshold THEN 'SUPPRESSED'
            WHEN ep.result_numeric IS NOT NULL AND ep.result_numeric >= ep.suppression_threshold THEN 'UNSUPPRESSED'
            WHEN ep.result_qualitative_concept_id = 1301 AND ep.result_numeric IS NULL THEN 'UNSUPPRESSED'
            WHEN ep.result_qualitative_concept_id = 1306 THEN 'SUPPRESSED'
            ELSE 'UNKNOWN'
        END,
        ep.requires_repeat_test =
        CASE
            WHEN ep.is_unsuppressed = 1 THEN 1
            ELSE 0
        END;

    -- ============ STEP 8: Infer testing model ============
    UPDATE mamba_fact_viral_load_episode ep
    SET ep.testing_model =
        CASE
            -- Same-day sample and result suggests POC
            WHEN DATEDIFF(ep.viral_load_clinical_date, ep.sample_collection_date) = 0
                AND DATEDIFF(ep.viral_load_clinical_date, ep.return_to_facility_date) <= 1
                THEN 'POINT_OF_CARE'
            -- Otherwise assume Central Lab (CPHL)
            ELSE 'CENTRAL_LAB'
        END,
        ep.testing_model_source = 'inferred_from_dates',
        ep.is_testing_model_inferred = 1,
        ep.testing_model_confidence = 'MEDIUM';

    -- ============ STEP 9: Calculate turnaround times ============
    UPDATE mamba_fact_viral_load_episode ep
    SET ep.order_to_collection_days = DATEDIFF(ep.sample_collection_date, ep.order_date),
        ep.collection_to_result_days = DATEDIFF(ep.viral_load_clinical_date, ep.sample_collection_date),
        ep.result_to_facility_days = DATEDIFF(ep.return_to_facility_date, ep.viral_load_clinical_date),
        ep.facility_to_emr_entry_days = DATEDIFF(ep.result_database_creation_date, ep.return_to_facility_date),
        ep.collection_to_facility_days = DATEDIFF(ep.return_to_facility_date, ep.sample_collection_date),
        ep.order_to_result_days = DATEDIFF(ep.viral_load_clinical_date, ep.order_date),
        ep.documentation_delay_days = DATEDIFF(ep.result_database_creation_date, ep.viral_load_clinical_date);

    -- ============ STEP 10: Calculate qualitative canonical values ============
    UPDATE mamba_fact_viral_load_episode ep
    LEFT JOIN mamba_vl_coded_value_mapping cm
        ON ep.result_qualitative_concept_id = cm.answer_concept_id
    SET ep.result_qualitative = cm.canonical_value;

    -- Handle special cases
    UPDATE mamba_fact_viral_load_episode
    SET result_qualitative = 'TARGET_NOT_DETECTED'
    WHERE result_qualitative_raw LIKE '%BDL%' OR result_qualitative_raw LIKE '%NOT DETECTED%';

    UPDATE mamba_fact_viral_load_episode
    SET result_qualitative = 'POOR_SAMPLE_QUALITY',
        result_status = 'INVALID',
        requires_recollection = 1
    WHERE result_qualitative_raw LIKE '%POOR%' OR result_qualitative_raw LIKE '%REJECTED%';

    -- ============ STEP 11: Get counts for summary ============
    SELECT COUNT(*) INTO episode_count FROM mamba_fact_viral_load_episode;
    SELECT COUNT(*) INTO orphan_count FROM mamba_fact_viral_load_episode WHERE is_orphan_result = 1;
    SELECT COUNT(*) INTO unmatched_order_count FROM mamba_fact_viral_load_episode WHERE is_order_without_result = 1;

    -- ============ SUMMARY ============
    SELECT
        'VL Episode ETL Completed' AS status,
        NOW() AS completed_at,
        TIMESTAMPDIFF(SECOND, start_time, NOW()) AS duration_seconds,
        episode_count AS total_episodes,
        orphan_count AS orphan_results,
        unmatched_order_count AS unmatched_orders,
        (SELECT COUNT(*) FROM mamba_fact_viral_load_episode WHERE is_suppressed = 1) AS suppressed_count,
        (SELECT COUNT(*) FROM mamba_fact_viral_load_episode WHERE is_unsuppressed = 1) AS unsuppressed_count,
        (SELECT COUNT(*) FROM mamba_fact_viral_load_episode WHERE testing_model = 'POINT_OF_CARE') AS poc_count,
        (SELECT COUNT(*) FROM mamba_fact_viral_load_episode WHERE linkage_method = 'DIRECT_ORDER_ID') AS direct_order_matched,
        (SELECT COUNT(*) FROM mamba_fact_viral_load_episode WHERE linkage_method = 'ACCESSION_NUMBER') AS accession_matched,
        (SELECT COUNT(*) FROM mamba_fact_viral_load_episode WHERE linkage_method = 'PATIENT_DATE') AS patient_date_matched;

END//

DELIMITER ;

-- ============ HELPER: Get Latest VL per Patient ============
DROP PROCEDURE IF EXISTS sp_get_latest_vl_per_patient;

DELIMITER //

CREATE PROCEDURE sp_get_latest_vl_per_patient(
    IN p_location_id INT,
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT
        vl.patient_id,
        vl.viral_load_clinical_date AS latest_vl_date,
        vl.result_numeric AS latest_vl_result,
        vl.result_qualitative AS latest_vl_qualitative,
        vl.result_interpretation AS latest_interpretation,
        vl.is_suppressed,
        vl.is_unsuppressed,
        vl.testing_model,
        vl.days_since_latest_vl,
        vl.next_expected_vl_date,
        vl.is_due,
        vl.is_overdue,
        vl.due_reason
    FROM mamba_fact_viral_load_episode vl
    WHERE (p_location_id IS NULL OR vl.location_id = p_location_id)
      AND (p_start_date IS NULL OR vl.viral_load_clinical_date >= p_start_date)
      AND (p_end_date IS NULL OR vl.viral_load_clinical_date <= p_end_date)
      AND vl.viral_load_clinical_date IS NOT NULL
      AND vl.panel_obs_id IS NOT NULL  -- Has actual result
    ORDER BY vl.patient_id, vl.viral_load_clinical_date DESC;
END//

DELIMITER ;

-- ============ HELPER: Get Pipeline Status ============
DROP PROCEDURE IF EXISTS sp_get_vl_pipeline_summary;

DELIMITER //

CREATE PROCEDURE sp_get_vl_pipeline_summary(
    IN p_location_id INT,
    IN p_as_of_date DATE
)
BEGIN
    SELECT
        pipeline_status,
        COUNT(*) AS count,
        COUNT(DISTINCT patient_id) AS unique_patients
    FROM mamba_fact_viral_load_episode
    WHERE (p_location_id IS NULL OR location_id = p_location_id)
      AND (p_as_of_date IS NULL OR order_date <= p_as_of_date)
    GROUP BY pipeline_status
    ORDER BY count DESC;
END//

DELIMITER ;
