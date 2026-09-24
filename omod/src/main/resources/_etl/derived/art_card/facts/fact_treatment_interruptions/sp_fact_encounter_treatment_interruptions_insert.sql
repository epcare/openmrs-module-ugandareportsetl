-- $BEGIN
-- One row per treatment-interruption obs group instance. Children are pivoted
-- from mamba_z_encounter_obs: member rows carry obs_group_id = the leader's
-- obs_id, and joining z back to the leader row (obs_question_uuid = the group
-- concept) scopes this to interruptions groups only. Concept UUIDs (not ids)
-- keep this portable across environments. Coded answers arrive resolved in
-- obs_value_text; date answers in obs_value_datetime are DATE()-wrapped per
-- house rule (they carry times).
SET SESSION group_concat_max_len = 20000;

INSERT INTO mamba_fact_encounter_treatment_interruptions (client_id,
                                                          patient_id,
                                                          encounter_id,
                                                          encounter_date,
                                                          location_id,
                                                          obs_group_id,
                                                          treatment_type,
                                                          interruption_stop_lost,
                                                          interruption_stop_date,
                                                          interruption_stop_reason,
                                                          interruption_restart_date)
SELECT z.person_id,
       z.person_id                        AS patient_id,
       z.encounter_id,
       DATE(z.encounter_datetime)         AS encounter_date,
       z.location_id,
       z.obs_group_id,
       GROUP_CONCAT(DISTINCT CASE WHEN z.obs_question_uuid = '3aaf3680-6240-4819-a704-e20a93841942'
           THEN z.obs_value_text END SEPARATOR '; ')                       AS treatment_type,
       MAX(CASE WHEN z.obs_question_uuid = '65d1bdf6-e518-4400-9f61-b7f2b1e80169'
           THEN z.obs_value_text END)                                      AS interruption_stop_lost,
       DATE(MAX(CASE WHEN z.obs_question_uuid = 'ac98d431-8ebc-4397-8c78-78b0eee0ffe7'
           THEN z.obs_value_datetime END))                                 AS interruption_stop_date,
       MAX(CASE WHEN z.obs_question_uuid = '89d3ee61-7c74-4537-b199-4026bd6a3f67'
           THEN z.obs_value_text END)                                      AS interruption_stop_reason,
       DATE(MAX(CASE WHEN z.obs_question_uuid = '160738AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
           THEN z.obs_value_datetime END))                                 AS interruption_restart_date
FROM mamba_z_encounter_obs z
         INNER JOIN mamba_z_encounter_obs g
                    ON g.obs_id = z.obs_group_id
                        AND g.voided = 0
                        AND g.obs_question_uuid = '2bb2e360-263c-4167-8c68-87dab66dc0f6'
WHERE z.voided = 0
GROUP BY z.person_id, z.encounter_id, z.encounter_datetime, z.location_id, z.obs_group_id;
-- $END
