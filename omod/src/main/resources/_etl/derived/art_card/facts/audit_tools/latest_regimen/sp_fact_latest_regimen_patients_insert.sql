-- $BEGIN
-- Latest regimen per patient, consolidating every source of regimen data. Each
-- obs-derived value is paired with its obs_datetime (when it was recorded).
--   * current regimen   : concept 90315 (coded) + 99126 (free-text "other")
--   * baseline regimen  : concept 99061 (coded) + 99268 (free-text "other")  [ART Summary]
--   * transfer-in       : concept 99064 (coded) + 99269 (free-text "other")  [ART Summary]
--   * regimen line      : latest obs 164515/164350, falling back to the open
--                         program-workflow state (concept 166214)
--   * ART start date    : concept 99161
-- "Latest" uses the established house idiom (MAX(obs_datetime) + GROUP BY person_id).
-- Concept ids are not stored; names are resolved once at ETL time via concept_name.
INSERT INTO mamba_fact_patients_latest_regimen (
    client_id, patient_id,
    effective_regimen, effective_regimen_obs_datetime, effective_regimen_other, effective_regimen_source,
    current_regimen, current_regimen_obs_datetime, current_regimen_other, current_regimen_other_obs_datetime,
    current_regimen_encounter_type, current_regimen_location_id,
    baseline_regimen, baseline_regimen_obs_datetime, baseline_regimen_other, baseline_regimen_other_obs_datetime,
    transfer_in_regimen, transfer_in_regimen_obs_datetime, transfer_in_regimen_other, transfer_in_regimen_other_obs_datetime,
    regimen_line, regimen_line_obs_datetime, regimen_line_source,
    art_start_date, art_start_obs_datetime
)
SELECT
    cohort.client_id,
    cohort.client_id,
    COALESCE(cur.regimen, base.regimen, tin.regimen),
    CASE
        WHEN cur.regimen IS NOT NULL THEN cur.obs_datetime
        WHEN base.regimen IS NOT NULL THEN base.obs_datetime
        WHEN tin.regimen IS NOT NULL THEN tin.obs_datetime
    END,
    CASE
        WHEN cur.regimen IS NOT NULL THEN curo.value_text
        WHEN base.regimen IS NOT NULL THEN baseo.value_text
        WHEN tin.regimen IS NOT NULL THEN tino.value_text
    END,
    CASE
        WHEN cur.regimen IS NOT NULL THEN 'CURRENT'
        WHEN base.regimen IS NOT NULL THEN 'BASELINE'
        WHEN tin.regimen IS NOT NULL THEN 'TRANSFER_IN'
    END,

    cur.regimen, cur.obs_datetime, curo.value_text, curo.obs_datetime, cur.encounter_type, cur.location_id,
    base.regimen, base.obs_datetime, baseo.value_text, baseo.obs_datetime,
    tin.regimen, tin.obs_datetime, tino.value_text, tino.obs_datetime,
    COALESCE(lineobs.line_name, progline.line_name),
    COALESCE(lineobs.obs_datetime, CAST(progline.state_start AS DATETIME)),
    CASE
        WHEN lineobs.line_name IS NOT NULL THEN 'OBS'
        WHEN progline.line_name IS NOT NULL THEN 'PROGRAM_WORKFLOW'
    END,
    artstart.art_start,
    artstart.obs_datetime

-- Driving set: one row per non-voided patient with any regimen obs (current/baseline/transfer-in)
FROM (
         SELECT DISTINCT o.person_id AS client_id
         FROM obs o
                  INNER JOIN patient p ON p.patient_id = o.person_id AND p.voided = 0
         WHERE o.concept_id IN (90315, 99061, 99064)
           AND o.voided = 0
     ) cohort

    -- Latest CURRENT regimen (90315), with source encounter type + location + recorded time
    LEFT JOIN (
        SELECT o.person_id, cn.name AS regimen, o.obs_datetime, o.location_id, et.name AS encounter_type
        FROM obs o
                 INNER JOIN (
            SELECT person_id, MAX(obs_datetime) latest_date
            FROM obs
            WHERE concept_id = 90315 AND voided = 0 AND value_coded IS NOT NULL
            GROUP BY person_id
        ) a ON o.person_id = a.person_id
                 LEFT JOIN concept_name cn
                           ON o.value_coded = cn.concept_id
                               AND cn.concept_name_type = 'FULLY_SPECIFIED'
                               AND cn.locale = 'en'
                               AND cn.voided = 0
                 LEFT JOIN encounter e ON o.encounter_id = e.encounter_id
                 LEFT JOIN encounter_type et ON e.encounter_type = et.encounter_type_id
        WHERE o.concept_id = 90315
          AND o.obs_datetime = a.latest_date
          AND o.voided = 0
          AND o.value_coded IS NOT NULL
        GROUP BY o.person_id
    ) cur ON cohort.client_id = cur.person_id

    -- Latest CURRENT regimen "other" free text (99126)
    LEFT JOIN (
        SELECT o.person_id, o.value_text, o.obs_datetime
        FROM obs o
                 INNER JOIN (
            SELECT person_id, MAX(obs_datetime) latest_date
            FROM obs
            WHERE concept_id = 99126 AND voided = 0 AND value_text IS NOT NULL
            GROUP BY person_id
        ) a ON o.person_id = a.person_id
        WHERE o.concept_id = 99126
          AND o.obs_datetime = a.latest_date
          AND o.voided = 0
          AND o.value_text IS NOT NULL
        GROUP BY o.person_id
    ) curo ON cohort.client_id = curo.person_id

    -- Latest BASELINE regimen (99061)
    LEFT JOIN (
        SELECT o.person_id, cn.name AS regimen, o.obs_datetime
        FROM obs o
                 INNER JOIN (
            SELECT person_id, MAX(obs_datetime) latest_date
            FROM obs
            WHERE concept_id = 99061 AND voided = 0 AND value_coded IS NOT NULL
            GROUP BY person_id
        ) a ON o.person_id = a.person_id
                 LEFT JOIN concept_name cn
                           ON o.value_coded = cn.concept_id
                               AND cn.concept_name_type = 'FULLY_SPECIFIED'
                               AND cn.locale = 'en'
                               AND cn.voided = 0
        WHERE o.concept_id = 99061
          AND o.obs_datetime = a.latest_date
          AND o.voided = 0
          AND o.value_coded IS NOT NULL
        GROUP BY o.person_id
    ) base ON cohort.client_id = base.person_id

    -- Latest BASELINE regimen "other" free text (99268)
    LEFT JOIN (
        SELECT o.person_id, o.value_text, o.obs_datetime
        FROM obs o
                 INNER JOIN (
            SELECT person_id, MAX(obs_datetime) latest_date
            FROM obs
            WHERE concept_id = 99268 AND voided = 0 AND value_text IS NOT NULL
            GROUP BY person_id
        ) a ON o.person_id = a.person_id
        WHERE o.concept_id = 99268
          AND o.obs_datetime = a.latest_date
          AND o.voided = 0
          AND o.value_text IS NOT NULL
        GROUP BY o.person_id
    ) baseo ON cohort.client_id = baseo.person_id

    -- Latest TRANSFER-IN regimen (99064)
    LEFT JOIN (
        SELECT o.person_id, cn.name AS regimen, o.obs_datetime
        FROM obs o
                 INNER JOIN (
            SELECT person_id, MAX(obs_datetime) latest_date
            FROM obs
            WHERE concept_id = 99064 AND voided = 0 AND value_coded IS NOT NULL
            GROUP BY person_id
        ) a ON o.person_id = a.person_id
                 LEFT JOIN concept_name cn
                           ON o.value_coded = cn.concept_id
                               AND cn.concept_name_type = 'FULLY_SPECIFIED'
                               AND cn.locale = 'en'
                               AND cn.voided = 0
        WHERE o.concept_id = 99064
          AND o.obs_datetime = a.latest_date
          AND o.voided = 0
          AND o.value_coded IS NOT NULL
        GROUP BY o.person_id
    ) tin ON cohort.client_id = tin.person_id

    -- Latest TRANSFER-IN regimen "other" free text (99269)
    LEFT JOIN (
        SELECT o.person_id, o.value_text, o.obs_datetime
        FROM obs o
                 INNER JOIN (
            SELECT person_id, MAX(obs_datetime) latest_date
            FROM obs
            WHERE concept_id = 99269 AND voided = 0 AND value_text IS NOT NULL
            GROUP BY person_id
        ) a ON o.person_id = a.person_id
        WHERE o.concept_id = 99269
          AND o.obs_datetime = a.latest_date
          AND o.voided = 0
          AND o.value_text IS NOT NULL
        GROUP BY o.person_id
    ) tino ON cohort.client_id = tino.person_id

    -- Latest regimen LINE from obs (164515 Current Regimen Line / 164350 Previous ARV Regimen line)
    LEFT JOIN (
        SELECT o.person_id, cn.name AS line_name, o.obs_datetime
        FROM obs o
                 INNER JOIN (
            SELECT person_id, MAX(obs_datetime) latest_date
            FROM obs
            WHERE concept_id IN (164515, 164350) AND voided = 0 AND value_coded IS NOT NULL
            GROUP BY person_id
        ) a ON o.person_id = a.person_id
                 LEFT JOIN concept_name cn
                           ON o.value_coded = cn.concept_id
                               AND cn.concept_name_type = 'FULLY_SPECIFIED'
                               AND cn.locale = 'en'
                               AND cn.voided = 0
        WHERE o.concept_id IN (164515, 164350)
          AND o.obs_datetime = a.latest_date
          AND o.voided = 0
          AND o.value_coded IS NOT NULL
        GROUP BY o.person_id
    ) lineobs ON cohort.client_id = lineobs.person_id

    -- Regimen line from the OPEN program-workflow state (concept 166214) — fallback.
    -- state_start (patient_state.start_date) is used as the "recorded" datetime.
    LEFT JOIN (
        SELECT pp.patient_id, cn.name AS line_name, ps.start_date AS state_start
        FROM patient_state ps
                 INNER JOIN patient_program pp
                            ON ps.patient_program_id = pp.patient_program_id AND pp.voided = 0
                 INNER JOIN program_workflow_state pws ON ps.state = pws.program_workflow_state_id
                 INNER JOIN program_workflow pw ON pws.program_workflow_id = pw.program_workflow_id
                 LEFT JOIN concept_name cn
                           ON pws.concept_id = cn.concept_id
                               AND cn.concept_name_type = 'FULLY_SPECIFIED'
                               AND cn.locale = 'en'
                               AND cn.voided = 0
        WHERE pw.concept_id = 166214
          AND ps.end_date IS NULL
        GROUP BY pp.patient_id
    ) progline ON cohort.client_id = progline.patient_id

    -- ART start date (99161): value_datetime = when ART started; obs_datetime = when recorded
    LEFT JOIN (
        SELECT o.person_id, DATE(o.value_datetime) AS art_start, o.obs_datetime
        FROM obs o
                 INNER JOIN (
            SELECT person_id, MAX(obs_datetime) latest_date
            FROM obs
            WHERE concept_id = 99161 AND voided = 0 AND value_datetime IS NOT NULL
            GROUP BY person_id
        ) a ON o.person_id = a.person_id
        WHERE o.concept_id = 99161
          AND o.obs_datetime = a.latest_date
          AND o.voided = 0
          AND o.value_datetime IS NOT NULL
        GROUP BY o.person_id
    ) artstart ON cohort.client_id = artstart.person_id;
-- $END
