-- $BEGIN
-- HTS screening results (determine/stat-pak/sd-bioline/final) are recorded as members of the
-- test-order obs group (leader concept 199095), so the engine's flat pivot excludes them from
-- the main flat table (obs_group_id IS NULL filter). Instead of per-group child tables, this
-- insert pivots mamba_z_encounter_obs directly: z carries obs_group_id per member row and the
-- resolved answer name in obs_value_text, and it is maintained on incremental runs, so results
-- are as fresh as the last tick. Only the latest test group per encounter (MAX obs_group_id)
-- is used; main-flat columns remain the fallback for any top-level results.
INSERT INTO mamba_fact_encounter_hts_card_v2 (encounter_id,
                                              client_id,
                                              patient_id,
                                              encounter_date,
                                              serial_number,
                                              accompanied_by,
                                              other_accompanied_by,
                                              hts_delivery_model,
                                              hts_approach,
                                              entry_point_hf,
                                              other_entry_point_hf,
                                              entry_point_community,
                                              other_entry_point_community,
                                              reason_for_testing,
                                              other_reason_for_testing,
                                              first_hiv_test,
                                              last_hiv_visit_date,
                                              months_since_last_tested,
                                              previous_test_result,
                                              times_tested_last_12_months,
                                              number_sexual_partners_12_months,
                                              previous_test_location,
                                              partner_tested_before,
                                              partner_test_result,
                                              client_at_risk,
                                              risk_profile,
                                              pre_test_counseling_done,
                                              counseled_as,
                                              hiv_test_consent,
                                              consent_date,
                                              determine_result,
                                              stat_pak_result,
                                              sd_bioline_result,
                                              final_result,
                                              sample_sent_to_lab,
                                              results_received_individual,
                                              results_received_couple,
                                              couple_results,
                                              screened_for_tb,
                                              presumptive_tb,
                                              tb_case_referred,
                                              linked_for_hiv_care,
                                              referral_facility_name,
                                              art_number,
                                              linked_prevention_services,
                                              place_of_referral,
                                              received_prevention_services,
                                              prevention_services,
                                              other_prevention_services,
                                              recency_test_name,
                                              recency_test_date,
                                              recency_blood_draw_consent,
                                              recency_test_result)
SELECT a.encounter_id,
       a.client_id,
       a.client_id                                         AS patient_id,
       a.encounter_datetime,
       serial_number,
       accompanied_by,
       other_accompanied_by,
       hts_delivery_model,
       hts_approach,
       entry_point_hf,
       other_entry_point_hf,
       entry_point_community,
       other_entry_point_community,
       reason_for_testing,
       other_reason_for_testing,
       first_hiv_test,
       last_hiv_visit_date,
       months_since_last_tested,
       previous_test_result,
       times_tested_last_12_months,
       number_sexual_partners_12_months,
       previous_test_location,
       partner_tested_before,
       partner_test_result,
       client_at_risk,
       risk_profile,
       pre_test_counseling_done,
       counseled_as,
       hiv_test_consent,
       consent_date,
       COALESCE(r.determine_result, a.determine_result)   AS determine_result,
       COALESCE(r.stat_pak_result, a.stat_pak_result)     AS stat_pak_result,
       COALESCE(r.sd_bioline_result, a.sd_bioline_result) AS sd_bioline_result,
       COALESCE(r.final_result, a.final_result)           AS final_result,
       sample_sent_to_lab,
       results_received_individual,
       results_received_couple,
       couple_results,
       screened_for_tb,
       presumptive_tb,
       tb_case_referred,
       linked_for_hiv_care,
       referral_facility_name,
       art_number,
       linked_prevention_services,
       place_of_referral,
       received_prevention_services,
       prevention_services,
       other_prevention_services,
       recency_test_name,
       recency_test_date,
       recency_blood_draw_consent,
       recency_test_result
FROM mamba_flat_encounter_hts_card_v2 a
         LEFT JOIN (SELECT m.encounter_id,
                           MAX(CASE WHEN m.obs_question_concept_id = 198941 THEN m.obs_value_text END) AS determine_result,  -- 7803ffa8-c24f-41ec-89f8-821e2a71fda6
                           MAX(CASE WHEN m.obs_question_concept_id = 198942 THEN m.obs_value_text END) AS stat_pak_result,    -- 85534e6a-22a1-433e-aa57-f358f1eb0a16
                           MAX(CASE WHEN m.obs_question_concept_id = 198943 THEN m.obs_value_text END) AS sd_bioline_result,  -- ad4760fe-9a58-4e60-b626-29d345b9a220
                           MAX(CASE WHEN m.obs_question_concept_id = 199094 THEN m.obs_value_text END) AS final_result        -- 37a5bf42-5b94-4ae7-8c46-9ebff55ef349
                    FROM mamba_z_encounter_obs m
                             JOIN (SELECT encounter_id, MAX(obs_group_id) AS g -- latest test group per encounter
                                   FROM mamba_z_encounter_obs
                                   WHERE obs_group_id IS NOT NULL
                                     AND voided = 0
                                     AND obs_question_concept_id IN (198941, 198942, 198943, 199094)
                                   GROUP BY encounter_id) latest
                                  ON latest.encounter_id = m.encounter_id
                                      AND latest.g = m.obs_group_id
                    WHERE m.obs_group_id IS NOT NULL
                      AND m.voided = 0
                    GROUP BY m.encounter_id) r
                   ON r.encounter_id = a.encounter_id;
-- $END
