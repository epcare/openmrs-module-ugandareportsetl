-- $BEGIN
-- One row per ADR/side-effects obs group instance. Same pattern as the
-- treatment-interruptions fact: children pivoted from mamba_z_encounter_obs
-- and scoped by joining back to the group leader row, concept UUIDs for
-- portability, obs_value_text for resolved coded labels, DATE() wraps on
-- date answers. "Side effects" is a multiCheckbox (one obs row per selected
-- answer) so it is GROUP_CONCAT'd; the rest are single-answer pivots.
SET SESSION group_concat_max_len = 20000;

INSERT INTO mamba_fact_encounter_adr_side_effects (client_id,
                                                   patient_id,
                                                   encounter_id,
                                                   encounter_date,
                                                   location_id,
                                                   obs_group_id,
                                                   side_effects,
                                                   other_side_effects,
                                                   offending_agent,
                                                   other_medication,
                                                   grading,
                                                   severity,
                                                   action_taken,
                                                   outcome,
                                                   other_outcome,
                                                   date_of_occurrence)
SELECT z.person_id,
       z.person_id                        AS patient_id,
       z.encounter_id,
       DATE(z.encounter_datetime)         AS encounter_date,
       z.location_id,
       z.obs_group_id,
       GROUP_CONCAT(DISTINCT CASE WHEN z.obs_question_uuid = 'dce05b7f-30ab-102d-86b0-7a5022ba4115'
           THEN z.obs_value_text END SEPARATOR '; ')                       AS side_effects,
       MAX(CASE WHEN z.obs_question_uuid = 'd4f4c0e7-06f5-4aa6-a218-17b1f97c5a44'
           THEN z.obs_value_text END)                                      AS other_side_effects,
       MAX(CASE WHEN z.obs_question_uuid = '24b52dcb-2809-4ed8-92bb-b212f394bf50'
           THEN z.obs_value_text END)                                      AS offending_agent,
       MAX(CASE WHEN z.obs_question_uuid = 'b04eaf95-77c9-456a-99fb-f668f58a9386'
           THEN z.obs_value_text END)                                      AS other_medication,
       MAX(CASE WHEN z.obs_question_uuid = 'f2547a99-21c9-4e86-99e8-b6c4dda36f42'
           THEN z.obs_value_text END)                                      AS grading,
       MAX(CASE WHEN z.obs_question_uuid = 'dce0d9c2-30ab-102d-86b0-7a5022ba4115'
           THEN z.obs_value_text END)                                      AS severity,
       MAX(CASE WHEN z.obs_question_uuid = '14eb35a0-1454-47bb-90cf-bf6cf96340a8'
           THEN z.obs_value_text END)                                      AS action_taken,
       MAX(CASE WHEN z.obs_question_uuid = 'd0a568f1-fd17-4327-aba2-24619aa24273'
           THEN z.obs_value_text END)                                      AS outcome,
       MAX(CASE WHEN z.obs_question_uuid = '05018034-4bf1-4025-8396-5c08e3690c10'
           THEN z.obs_value_text END)                                      AS other_outcome,
       DATE(MAX(CASE WHEN z.obs_question_uuid = '648995af-baf8-4954-a850-2ead8162a86b'
           THEN z.obs_value_datetime END))                                 AS date_of_occurrence
FROM mamba_z_encounter_obs z
         INNER JOIN mamba_z_encounter_obs g
                    ON g.obs_id = z.obs_group_id
                        AND g.voided = 0
                        AND g.obs_question_uuid = 'b05f81ca-afa4-4c7d-af9c-4523947f5dd6'
WHERE z.voided = 0
GROUP BY z.person_id, z.encounter_id, z.encounter_datetime, z.location_id, z.obs_group_id;
-- $END
