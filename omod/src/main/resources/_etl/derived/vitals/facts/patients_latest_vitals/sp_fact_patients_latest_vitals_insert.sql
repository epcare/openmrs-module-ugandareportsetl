-- $BEGIN
-- Per-patient globally-latest vitals across ALL encounter types. House idiom
-- (cf. sp_fact_latest_regimen_patients_insert.sql): MAX(obs_datetime) per
-- person + concept, with MAX(value_*) breaking exact-obs_datetime ties
-- deterministically. Voided obs AND voided encounters are excluded at BOTH
-- subquery levels. The anchor (vitals_date / latest_vitals_encounter_id /
-- type / location) comes from the MAX(encounter_id) self-join on
-- mamba_fact_encounter_vitals built earlier in this run
-- (cf. sp_fact_latest_return_date_patients_insert.sql). BMI is computed from
-- the latest weight + latest height, which may come from different encounters
-- (bmi_obs_datetime = later of the two obs datetimes).
INSERT INTO mamba_fact_patients_latest_vitals (
    client_id, patient_id,
    systolic_bp, systolic_bp_obs_datetime,
    diastolic_bp, diastolic_bp_obs_datetime,
    pulse, pulse_obs_datetime,
    temperature_c, temperature_c_obs_datetime,
    weight_kg, weight_kg_obs_datetime,
    height_cm, height_cm_obs_datetime,
    spo2, spo2_obs_datetime,
    respiratory_rate, respiratory_rate_obs_datetime,
    muac, muac_obs_datetime,
    general_patient_note, general_patient_note_obs_datetime,
    bmi, bmi_obs_datetime,
    vitals_date, latest_vitals_encounter_id, latest_vitals_encounter_type, location_id
)
SELECT
    cohort.client_id,
    cohort.client_id AS patient_id,
    sbp.systolic_bp,     sbp.obs_datetime,
    dbp.diastolic_bp,    dbp.obs_datetime,
    pls.pulse,           pls.obs_datetime,
    tmp.temperature_c,   tmp.obs_datetime,
    wt.weight_kg,        wt.obs_datetime,
    ht.height_cm,        ht.obs_datetime,
    ox.spo2,             ox.obs_datetime,
    rr.respiratory_rate, rr.obs_datetime,
    mu.muac,             mu.obs_datetime,
    note.general_patient_note, note.obs_datetime,
    CASE WHEN wt.weight_kg IS NOT NULL AND ht.height_cm IS NOT NULL AND ht.height_cm > 0
         THEN ROUND(wt.weight_kg / ((ht.height_cm / 100) * (ht.height_cm / 100)), 1)
    END AS bmi,
    CASE WHEN wt.weight_kg IS NOT NULL AND ht.height_cm IS NOT NULL AND ht.height_cm > 0
         THEN GREATEST(wt.obs_datetime, ht.obs_datetime)
    END AS bmi_obs_datetime,
    DATE(vx.encounter_date),
    vx.encounter_id,
    vx.encounter_type,
    vx.location_id
FROM (
    SELECT DISTINCT o.person_id AS client_id
    FROM obs o
             INNER JOIN encounter e ON e.encounter_id = o.encounter_id AND e.voided = 0
             INNER JOIN patient p ON p.patient_id = o.person_id AND p.voided = 0
    WHERE o.concept_id IN (5085, 5086, 5087, 5088, 5089, 5090, 5092, 5242, 1343, 165095)
      AND o.voided = 0
) cohort

-- Systolic blood pressure (5085)
LEFT JOIN (
    SELECT o.person_id, MAX(o.value_numeric) AS systolic_bp, MAX(o.obs_datetime) AS obs_datetime
    FROM obs o
             INNER JOIN encounter e ON e.encounter_id = o.encounter_id AND e.voided = 0
             INNER JOIN (
        SELECT o2.person_id, MAX(o2.obs_datetime) AS latest_date
        FROM obs o2
                 INNER JOIN encounter e2 ON e2.encounter_id = o2.encounter_id AND e2.voided = 0
        WHERE o2.concept_id = 5085
          AND o2.voided = 0
          AND o2.value_numeric IS NOT NULL
        GROUP BY o2.person_id
    ) a ON o.person_id = a.person_id
    WHERE o.concept_id = 5085
      AND o.obs_datetime = a.latest_date
      AND o.voided = 0
      AND o.value_numeric IS NOT NULL
    GROUP BY o.person_id
) sbp ON cohort.client_id = sbp.person_id

-- Diastolic blood pressure (5086)
LEFT JOIN (
    SELECT o.person_id, MAX(o.value_numeric) AS diastolic_bp, MAX(o.obs_datetime) AS obs_datetime
    FROM obs o
             INNER JOIN encounter e ON e.encounter_id = o.encounter_id AND e.voided = 0
             INNER JOIN (
        SELECT o2.person_id, MAX(o2.obs_datetime) AS latest_date
        FROM obs o2
                 INNER JOIN encounter e2 ON e2.encounter_id = o2.encounter_id AND e2.voided = 0
        WHERE o2.concept_id = 5086
          AND o2.voided = 0
          AND o2.value_numeric IS NOT NULL
        GROUP BY o2.person_id
    ) a ON o.person_id = a.person_id
    WHERE o.concept_id = 5086
      AND o.obs_datetime = a.latest_date
      AND o.voided = 0
      AND o.value_numeric IS NOT NULL
    GROUP BY o.person_id
) dbp ON cohort.client_id = dbp.person_id

-- Pulse (5087)
LEFT JOIN (
    SELECT o.person_id, MAX(o.value_numeric) AS pulse, MAX(o.obs_datetime) AS obs_datetime
    FROM obs o
             INNER JOIN encounter e ON e.encounter_id = o.encounter_id AND e.voided = 0
             INNER JOIN (
        SELECT o2.person_id, MAX(o2.obs_datetime) AS latest_date
        FROM obs o2
                 INNER JOIN encounter e2 ON e2.encounter_id = o2.encounter_id AND e2.voided = 0
        WHERE o2.concept_id = 5087
          AND o2.voided = 0
          AND o2.value_numeric IS NOT NULL
        GROUP BY o2.person_id
    ) a ON o.person_id = a.person_id
    WHERE o.concept_id = 5087
      AND o.obs_datetime = a.latest_date
      AND o.voided = 0
      AND o.value_numeric IS NOT NULL
    GROUP BY o.person_id
) pls ON cohort.client_id = pls.person_id

-- Temperature (5088)
LEFT JOIN (
    SELECT o.person_id, MAX(o.value_numeric) AS temperature_c, MAX(o.obs_datetime) AS obs_datetime
    FROM obs o
             INNER JOIN encounter e ON e.encounter_id = o.encounter_id AND e.voided = 0
             INNER JOIN (
        SELECT o2.person_id, MAX(o2.obs_datetime) AS latest_date
        FROM obs o2
                 INNER JOIN encounter e2 ON e2.encounter_id = o2.encounter_id AND e2.voided = 0
        WHERE o2.concept_id = 5088
          AND o2.voided = 0
          AND o2.value_numeric IS NOT NULL
        GROUP BY o2.person_id
    ) a ON o.person_id = a.person_id
    WHERE o.concept_id = 5088
      AND o.obs_datetime = a.latest_date
      AND o.voided = 0
      AND o.value_numeric IS NOT NULL
    GROUP BY o.person_id
) tmp ON cohort.client_id = tmp.person_id

-- Weight (5089)
LEFT JOIN (
    SELECT o.person_id, MAX(o.value_numeric) AS weight_kg, MAX(o.obs_datetime) AS obs_datetime
    FROM obs o
             INNER JOIN encounter e ON e.encounter_id = o.encounter_id AND e.voided = 0
             INNER JOIN (
        SELECT o2.person_id, MAX(o2.obs_datetime) AS latest_date
        FROM obs o2
                 INNER JOIN encounter e2 ON e2.encounter_id = o2.encounter_id AND e2.voided = 0
        WHERE o2.concept_id = 5089
          AND o2.voided = 0
          AND o2.value_numeric IS NOT NULL
        GROUP BY o2.person_id
    ) a ON o.person_id = a.person_id
    WHERE o.concept_id = 5089
      AND o.obs_datetime = a.latest_date
      AND o.voided = 0
      AND o.value_numeric IS NOT NULL
    GROUP BY o.person_id
) wt ON cohort.client_id = wt.person_id

-- Height (5090)
LEFT JOIN (
    SELECT o.person_id, MAX(o.value_numeric) AS height_cm, MAX(o.obs_datetime) AS obs_datetime
    FROM obs o
             INNER JOIN encounter e ON e.encounter_id = o.encounter_id AND e.voided = 0
             INNER JOIN (
        SELECT o2.person_id, MAX(o2.obs_datetime) AS latest_date
        FROM obs o2
                 INNER JOIN encounter e2 ON e2.encounter_id = o2.encounter_id AND e2.voided = 0
        WHERE o2.concept_id = 5090
          AND o2.voided = 0
          AND o2.value_numeric IS NOT NULL
        GROUP BY o2.person_id
    ) a ON o.person_id = a.person_id
    WHERE o.concept_id = 5090
      AND o.obs_datetime = a.latest_date
      AND o.voided = 0
      AND o.value_numeric IS NOT NULL
    GROUP BY o.person_id
) ht ON cohort.client_id = ht.person_id

-- Blood oxygen saturation / SpO2 (5092)
LEFT JOIN (
    SELECT o.person_id, MAX(o.value_numeric) AS spo2, MAX(o.obs_datetime) AS obs_datetime
    FROM obs o
             INNER JOIN encounter e ON e.encounter_id = o.encounter_id AND e.voided = 0
             INNER JOIN (
        SELECT o2.person_id, MAX(o2.obs_datetime) AS latest_date
        FROM obs o2
                 INNER JOIN encounter e2 ON e2.encounter_id = o2.encounter_id AND e2.voided = 0
        WHERE o2.concept_id = 5092
          AND o2.voided = 0
          AND o2.value_numeric IS NOT NULL
        GROUP BY o2.person_id
    ) a ON o.person_id = a.person_id
    WHERE o.concept_id = 5092
      AND o.obs_datetime = a.latest_date
      AND o.voided = 0
      AND o.value_numeric IS NOT NULL
    GROUP BY o.person_id
) ox ON cohort.client_id = ox.person_id

-- Respiratory rate (5242)
LEFT JOIN (
    SELECT o.person_id, MAX(o.value_numeric) AS respiratory_rate, MAX(o.obs_datetime) AS obs_datetime
    FROM obs o
             INNER JOIN encounter e ON e.encounter_id = o.encounter_id AND e.voided = 0
             INNER JOIN (
        SELECT o2.person_id, MAX(o2.obs_datetime) AS latest_date
        FROM obs o2
                 INNER JOIN encounter e2 ON e2.encounter_id = o2.encounter_id AND e2.voided = 0
        WHERE o2.concept_id = 5242
          AND o2.voided = 0
          AND o2.value_numeric IS NOT NULL
        GROUP BY o2.person_id
    ) a ON o.person_id = a.person_id
    WHERE o.concept_id = 5242
      AND o.obs_datetime = a.latest_date
      AND o.voided = 0
      AND o.value_numeric IS NOT NULL
    GROUP BY o.person_id
) rr ON cohort.client_id = rr.person_id

-- Mid-upper arm circumference (1343)
LEFT JOIN (
    SELECT o.person_id, MAX(o.value_numeric) AS muac, MAX(o.obs_datetime) AS obs_datetime
    FROM obs o
             INNER JOIN encounter e ON e.encounter_id = o.encounter_id AND e.voided = 0
             INNER JOIN (
        SELECT o2.person_id, MAX(o2.obs_datetime) AS latest_date
        FROM obs o2
                 INNER JOIN encounter e2 ON e2.encounter_id = o2.encounter_id AND e2.voided = 0
        WHERE o2.concept_id = 1343
          AND o2.voided = 0
          AND o2.value_numeric IS NOT NULL
        GROUP BY o2.person_id
    ) a ON o.person_id = a.person_id
    WHERE o.concept_id = 1343
      AND o.obs_datetime = a.latest_date
      AND o.voided = 0
      AND o.value_numeric IS NOT NULL
    GROUP BY o.person_id
) mu ON cohort.client_id = mu.person_id

-- General patient note (165095) - Text concept, value lives in value_text
LEFT JOIN (
    SELECT o.person_id, MAX(o.value_text) AS general_patient_note, MAX(o.obs_datetime) AS obs_datetime
    FROM obs o
             INNER JOIN encounter e ON e.encounter_id = o.encounter_id AND e.voided = 0
             INNER JOIN (
        SELECT o2.person_id, MAX(o2.obs_datetime) AS latest_date
        FROM obs o2
                 INNER JOIN encounter e2 ON e2.encounter_id = o2.encounter_id AND e2.voided = 0
        WHERE o2.concept_id = 165095
          AND o2.voided = 0
          AND o2.value_text IS NOT NULL
        GROUP BY o2.person_id
    ) a ON o.person_id = a.person_id
    WHERE o.concept_id = 165095
      AND o.obs_datetime = a.latest_date
      AND o.voided = 0
      AND o.value_text IS NOT NULL
    GROUP BY o.person_id
) note ON cohort.client_id = note.person_id

-- Anchor: the patient's globally-latest vitals-bearing encounter (all types),
-- from the encounter fact built earlier in this run.
LEFT JOIN (
    SELECT client_id, MAX(encounter_id) AS encounter_id
    FROM mamba_fact_encounter_vitals
    GROUP BY client_id
) latest_enc ON cohort.client_id = latest_enc.client_id
LEFT JOIN mamba_fact_encounter_vitals vx ON vx.encounter_id = latest_enc.encounter_id;
-- $END
