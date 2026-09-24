-- $BEGIN
-- One row per encounter (ANY type) with >= 1 vitals concept. Reads raw obs +
-- encounter (NOT the flat table) so ART Card / ANC / PNC vitals are covered.
-- MAX(CASE ...) pivots and collapses duplicated obs of the same concept on one
-- encounter to a single deterministic (max) value. BMI is computed in the
-- outer SELECT because pivot aliases are not referenceable at the same SELECT
-- level. Obs-group children are deliberately included (ART-card vitals often
-- sit inside obs groups). DATE() wrap on encounter_datetime feeding the DATE
-- column per house rule.
INSERT INTO mamba_fact_encounter_vitals (
    encounter_id, patient_id,client_id, encounter_date, location_id,
    encounter_type_id, encounter_type,
    systolic_bp, diastolic_bp, pulse, temperature_c,
    weight_kg, height_cm, spo2, respiratory_rate, muac,
    general_patient_note, bmi
)
SELECT
    pv.encounter_id,
    pv.patient_id,
    pv.patient_id AS client_id,
    pv.encounter_date,
    pv.location_id,
    pv.encounter_type_id,
    pv.encounter_type,
    pv.systolic_bp,
    pv.diastolic_bp,
    pv.pulse,
    pv.temperature_c,
    pv.weight_kg,
    pv.height_cm,
    pv.spo2,
    pv.respiratory_rate,
    pv.muac,
    pv.general_patient_note,
    CASE WHEN pv.weight_kg IS NOT NULL AND pv.height_cm IS NOT NULL AND pv.height_cm > 0
         THEN ROUND(pv.weight_kg / ((pv.height_cm / 100) * (pv.height_cm / 100)), 1)
    END AS bmi
FROM (
    SELECT
        e.encounter_id,
        e.patient_id AS client_id,
        e.patient_id AS patient_id,
        DATE(e.encounter_datetime) AS encounter_date,
        e.location_id,
        e.encounter_type AS encounter_type_id,
        et.name AS encounter_type,
        MAX(CASE WHEN o.concept_id = 5085  THEN o.value_numeric END) AS systolic_bp,
        MAX(CASE WHEN o.concept_id = 5086  THEN o.value_numeric END) AS diastolic_bp,
        MAX(CASE WHEN o.concept_id = 5087  THEN o.value_numeric END) AS pulse,
        MAX(CASE WHEN o.concept_id = 5088  THEN o.value_numeric END) AS temperature_c,
        MAX(CASE WHEN o.concept_id = 5089  THEN o.value_numeric END) AS weight_kg,
        MAX(CASE WHEN o.concept_id = 5090  THEN o.value_numeric END) AS height_cm,
        MAX(CASE WHEN o.concept_id = 5092  THEN o.value_numeric END) AS spo2,
        MAX(CASE WHEN o.concept_id = 5242  THEN o.value_numeric END) AS respiratory_rate,
        MAX(CASE WHEN o.concept_id = 1343  THEN o.value_numeric END) AS muac,
        MAX(CASE WHEN o.concept_id = 165095 THEN o.value_text   END) AS general_patient_note
    FROM encounter e
             INNER JOIN obs o
                        ON o.encounter_id = e.encounter_id
                            AND o.voided = 0
             INNER JOIN encounter_type et
                        ON e.encounter_type = et.encounter_type_id
    WHERE e.voided = 0
      AND o.concept_id IN (5085, 5086, 5087, 5088, 5089, 5090, 5092, 5242, 1343, 165095)
    GROUP BY e.encounter_id, e.patient_id, e.encounter_datetime, e.location_id,
             e.encounter_type, et.name
) pv;
-- $END
