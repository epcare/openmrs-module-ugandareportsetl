-- $BEGIN
-- ============================================================================
-- Viral Load Fact Table - Data Insertion
-- Populates mamba_fact_viral_load from source tables
-- ============================================================================

-- Clear existing data
TRUNCATE TABLE mamba_fact_viral_load;

-- Insert viral load records
INSERT INTO mamba_fact_viral_load (
    patient_id,
    encounter_id,
    visit_id,
    panel_obs_id,
    order_id,
    accession_number,
    order_date,
    sample_collection_date,
    viral_load_date,
    return_to_facility_date,
    viral_load_numeric,
    viral_load_qualitative,
    viral_load_interpretation,
    is_valid_result,
    invalid_reason,
    is_suppressed,
    is_unsuppressed,
    is_high_viral_load,
    suppression_threshold,
    art_start_date,
    days_on_art,
    current_regimen,
    current_regimen_line,
    pregnant_status,
    breastfeeding_status,
    indication_for_vl_testing,
    specimen_source,
    source_workflow,
    location_id,
    date_created
)
SELECT
    -- Patient
    o.person_id AS patient_id,
    o.encounter_id,
    e.visit_id,

    -- Episode identifiers
    o.obs_id AS panel_obs_id,
    o.order_id,
    o.accession_number,

    -- Order date (from native order or derived from obs)
    COALESCE(
        DATE(ord.date_activated),
        -- Try to find legacy order from Tests Ordered
        (SELECT DATE(order_obs.obs_datetime)
         FROM obs order_obs
         WHERE order_obs.concept_id = 1271
         AND order_obs.value_coded = 165412
         AND order_obs.encounter_id = o.encounter_id
         AND order_obs.voided = 0
         LIMIT 1)
    ) AS order_date,

    -- Sample collection date (try new form date, then legacy date)
    COALESCE(
        -- New form sample collection date
        (SELECT DATE(child.value_datetime)
         FROM obs child
         WHERE child.obs_group_id = o.obs_id
         AND child.concept_id = (SELECT concept_id FROM concept WHERE uuid = '0b434cfa-b11c-4d14-aaa2-9aed6ca2da88')
         LIMIT 1),
        -- Legacy VL taken date
        (SELECT DATE(child.value_datetime)
         FROM obs child
         WHERE child.obs_group_id = o.obs_id
         AND child.concept_id = 163023
         LIMIT 1)
    ) AS sample_collection_date,

    -- VL clinical date (panel obs_datetime)
    DATE(o.obs_datetime) AS viral_load_date,

    -- Return to facility date
    (SELECT DATE(child.value_datetime)
     FROM obs child
     WHERE child.obs_group_id = o.obs_id
     AND child.concept_id = (SELECT concept_id FROM concept WHERE uuid = '5b4037d6-a7e2-11ed-afa1-0242ac120002')
     LIMIT 1) AS return_to_facility_date,

    -- Numeric result
    (SELECT child.value_numeric
     FROM obs child
     WHERE child.obs_group_id = o.obs_id
     AND child.concept_id = 856
     LIMIT 1) AS viral_load_numeric,

    -- Qualitative result
    (SELECT coded.name
     FROM obs child
     LEFT JOIN concept_name coded ON child.value_coded = coded.concept_id
     WHERE child.obs_group_id = o.obs_id
     AND child.concept_id = 1305
     AND coded.locale = 'en'
     AND coded.voided = 0
     LIMIT 1) AS viral_load_qualitative,

    -- Interpretation
    CASE
        WHEN (SELECT child.value_coded FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 LIMIT 1) = 1306 THEN 'TARGET_NOT_DETECTED'
        WHEN (SELECT child.value_coded FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 LIMIT 1) = 1301 THEN 'DETECTED'
        WHEN (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1) < 1000 THEN 'SUPPRESSED'
        WHEN (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1) >= 1000 THEN 'UNSUPPRESSED'
        ELSE NULL
    END AS viral_load_interpretation,

    -- Valid result flag
    CASE
        WHEN (SELECT child.value_coded FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 LIMIT 1) IN (1304, 1310) THEN 0  -- PSQ, Rejected
        ELSE 1
    END AS is_valid_result,

    -- Invalid reason
    CASE
        WHEN (SELECT child.value_coded FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 LIMIT 1) = 1304 THEN 'Poor Sample Quality'
        WHEN (SELECT child.value_coded FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 LIMIT 1) = 1310 THEN 'Rejected'
        ELSE NULL
    END AS invalid_reason,

    -- Suppression status (1000 copies/mL threshold)
    CASE
        WHEN (SELECT child.value_coded FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 LIMIT 1) = 1306 THEN 1  -- Target Not Detected
        WHEN (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1) < 1000 THEN 1
        WHEN (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1) >= 1000 THEN 0
        ELSE NULL
    END AS is_suppressed,

    CASE
        WHEN (SELECT child.value_coded FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 1305 LIMIT 1) = 1301 THEN 1  -- Detected
        WHEN (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1) >= 1000 THEN 1
        WHEN (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1) < 1000 THEN 0
        ELSE NULL
    END AS is_unsuppressed,

    CASE
        WHEN (SELECT child.value_numeric FROM obs child WHERE child.obs_group_id = o.obs_id AND child.concept_id = 856 LIMIT 1) >= 1000 THEN 1
        ELSE 0
    END AS is_high_viral_load,

    1000 AS suppression_threshold,

    -- ART start date (from programs)
    (SELECT MIN(pp.date_enrolled)
     FROM patient_program pp
     JOIN program pr ON pp.program_id = pr.program_id
     WHERE pp.patient_id = o.person_id
     AND pp.voided = 0
     AND (pr.uuid LIKE '%a9bb3860%' OR pr.uuid LIKE '%c4b6b5e6%'))  -- HIV programs
    AS art_start_date,

    -- Days on ART
    DATEDIFF(
        o.obs_datetime,
        (SELECT MIN(pp.date_enrolled)
         FROM patient_program pp
         JOIN program pr ON pp.program_id = pr.program_id
         WHERE pp.patient_id = o.person_id
         AND pp.voided = 0
         AND (pr.uuid LIKE '%a9bb3860%' OR pr.uuid LIKE '%c4b6b5e6%'))
    ) AS days_on_art,

    -- Current regimen
    (SELECT current_regimen FROM mamba_fact_patients_latest_current_regimen WHERE client_id = o.person_id) AS current_regimen,

    -- Current regimen line
    (SELECT regimen_line FROM mamba_fact_patients_latest_current_regimen WHERE client_id = o.person_id) AS current_regimen_line,

    -- Pregnancy status (latest)
    (SELECT preg.value_coded
     FROM obs preg
     WHERE preg.person_id = o.person_id
     AND preg.concept_id = 155748  -- Pregnant
     AND preg.voided = 0
     ORDER BY preg.obs_datetime DESC
     LIMIT 1) AS pregnant_status,

    -- Breastfeeding status (latest)
    (SELECT bf.value_coded
     FROM obs bf
     WHERE bf.person_id = o.person_id
     AND bf.concept_id = 1599  -- Breastfeeding
     AND bf.voided = 0
     ORDER BY bf.obs_datetime DESC
     LIMIT 1) AS breastfeeding_status,

    -- Indication for VL testing
    (SELECT GROUP_CONCAT(DISTINCT child.value_coded ORDER BY child.value_coded)
     FROM obs child
     WHERE child.obs_group_id = o.obs_id
     AND child.concept_id = (SELECT concept_id FROM concept WHERE uuid = '168689')  -- Indication
     AND child.voided = 0) AS indication_for_vl_testing,

    -- Specimen source
    (SELECT cs.name FROM test_order tor JOIN concept_name cs ON tor.specimen_source = cs.concept_id
     WHERE tor.order_id = o.order_id
     AND cs.locale = 'en' AND cs.concept_name_type = 'FULLY_SPECIFIED'
     LIMIT 1) AS specimen_source,

    -- Source workflow
    CASE
        WHEN e.encounter_type = 15 THEN 'LEGACY_ART_CARD'
        WHEN e.encounter_type IN (SELECT encounter_type_id FROM encounter_type WHERE uuid = 'cbf01392-ca29-11e9-a32f-2a2ae2dbcce4') THEN 'NEW_VL_REQUEST_FORM'
        ELSE 'UNKNOWN'
    END AS source_workflow,

    o.location_id,

    NOW() AS date_created

FROM obs o
-- Link to person
JOIN person p ON o.person_id = p.person_id
-- Link to encounter
LEFT JOIN encounter e ON o.encounter_id = e.encounter_id
-- Link to order (if exists)
LEFT JOIN orders ord ON o.order_id = ord.order_id
-- Left join to existing regimen fact (if exists)
LEFT JOIN mamba_fact_patients_latest_current_regimen reg ON o.person_id = reg.client_id

WHERE o.concept_id = 165412  -- Viral Load Test panel
AND o.voided = 0
AND p.voided = 0;

-- Log result
SELECT CONCAT('Viral Load fact table populated: ', ROW_COUNT(), ' records') AS result;

-- $END
