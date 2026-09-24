-- $BEGIN

INSERT INTO mamba_fact_encounter_hiv_art_card (
    encounter_id,
    client_id,
    patient_id,
    encounter_date,
    method_of_family_planning,
    cd4,
    hiv_viral_load,
    historical_drug_start_date,
    historical_drug_stop_date,
    medication_orders,
    viral_load_qualitative,
    hepatitis_b_test___qualitative,
    duration_units,
    return_visit_date,
    cd4_count,
    estimated_date_of_confinement,
    pmtct,
    pregnant,
    scheduled_patient_visist,
    who_hiv_clinical_stage,
    name_of_location_transferred_to,
    tuberculosis_status,
    tuberculosis_treatment_start_date,
    adherence_assessment_code,
    reason_for_missing_arv_administration,
    medication_or_other_side_effects,
    family_planning_status,
    symptom_diagnosis,
    transfered_out_to_another_facility,
    tuberculosis_treatment_stop_date,
    current_arv_regimen,
    art_duration,
    current_art_duration,
    mid_upper_arm_circumference_code,
    district_tuberculosis_number,
    other_medications_dispensed,
    arv_regimen_days_dispensed,
    ar_regimen_dose,
    nutrition_support_and_infant_feeding,
    other_side_effects,
    other_reason_for_missing_arv,
    current_regimen_other,
    transfer_out_date,
    cotrim_given,
    syphilis_test_result_for_partner,
    eid_visit_1_z_score,
    medication_duration,
    medication_prescribed_per_dose,
    tuberculosis_polymerase,
    specimen_sources,
    estimated_gestational_age,
    hiv_viral_load_date,
    other_reason_for_appointment,
    nutrition_assesment,
    differentiated_service_delivery,
    stable_in_dsdm,
    tpt_start_date,
    tpt_completion_date,
    advanced_disease_status,
    tpt_status,
    rpr_test_results,
    crag_test_results,
    tb_lam_results,
    cervical_cancer_screening,
    intention_to_conceive,
    tb_microscopy_results,
    quantity_unit,
    tpt_side_effects,
    lab_number,
    test,
    test_result,
    refill_point_code,
    next_return_date_at_facility,
    indication_for_viral_load_testing,
    htn_status,
    diabetes_mellitus_status,
    anxiety_and_or_depression,
    alcohol_and_substance_use_disorder,
    oedema,
    inr_no,
    pregnancy_status,
    digital_health_messaging_registration,
    cacx_screening_visit_type,
    cacx_screening_method,
    cacx_screening_status,
    cacx_treatment,
    syphilis_status,
    tb_regimen,
    other_tpt_status,
    hpvVacStatus,
    interruption_reason,
    hpv_vaccination_date,
    covidVaccStatus,
    covid_vaccination_date,
    reasons_for_next_appointment,
    outcome,
    clinical_notes,
    client_represented,
    anc_no,
    lnmp,
    other_reason_stopped_treatment
)

SELECT
    encounters.encounter_id,

    /* Core encounter identifiers */
    COALESCE(a.client_id, b.client_id, c.client_id),
    COALESCE(a.client_id, b.client_id, c.client_id) AS patient_id,
    COALESCE(a.encounter_datetime, b.encounter_datetime, c.encounter_datetime) AS encounter_date,

    /* ART-card data */
    method_of_family_planning,
    cd4,
    hiv_viral_load,
    historical_drug_start_date,
    historical_drug_stop_date,
    medication_orders,
    viral_load_qualitative,
    hepatitis_b_test___qualitative,
    duration_units,
    return_visit_date,
    cd4_count,
    estimated_date_of_confinement,
    pmtct,
    pregnant,
    scheduled_patient_visist,
    who_hiv_clinical_stage,
    name_of_location_transferred_to,
    tuberculosis_status,
    tuberculosis_treatment_start_date,
    adherence_assessment_code,
    reason_for_missing_arv_administration,
    medication_or_other_side_effects,
    family_planning_status,
    symptom_diagnosis,
    transfered_out_to_another_facility,
    tuberculosis_treatment_stop_date,
    current_arv_regimen,
    art_duration,
    current_art_duration,
    mid_upper_arm_circumference_code,
    district_tuberculosis_number,
    other_medications_dispensed,
    FLOOR(arv_regimen_days_dispensed),
    ar_regimen_dose,
    nutrition_support_and_infant_feeding,
    other_side_effects,
    other_reason_for_missing_arv,
    current_regimen_other,
    transfer_out_date,
    cotrim_given,
    syphilis_test_result_for_partner,
    eid_visit_1_z_score,
    medication_duration,
    medication_prescribed_per_dose,
    tuberculosis_polymerase,
    specimen_sources,
    estimated_gestational_age,
    hiv_viral_load_date,
    other_reason_for_appointment,
    nutrition_assesment,
    differentiated_service_delivery,
    stable_in_dsdm,
    tpt_start_date,
    tpt_completion_date,
    advanced_disease_status,
    tpt_status,
    rpr_test_results,
    crag_test_results,
    tb_lam_results,
    cervical_cancer_screening,
    intention_to_conceive,
    tb_microscopy_results,
    quantity_unit,
    tpt_side_effects,
    lab_number,
    test,
    test_result,
    refill_point_code,
    next_return_date_at_facility,
    indication_for_viral_load_testing,
    htn_status,
    diabetes_mellitus_status,
    anxiety_and_or_depression,
    alcohol_and_substance_use_disorder,
    oedema,
    inr_no,
    pregnancy_status,
    digital_health_messaging_registration,
    cacx_screening_visit_type,
    cacx_screening_method,
    cacx_screening_status,
    cacx_treatment,
    syphilis_status,
    tb_regimen,
    other_tpt_status,
    hpvVacStatus,
    interruption_reason,
    hpv_vaccination_date,
    covidVaccStatus,
    covid_vaccination_date,
    reasons_for_next_appointment,
    outcome,
    clinical_notes,
    client_represented,
    `anc_no.`,
    lnmp,
    other_reason_stopped_treatment

FROM (
         /*
          * Build the complete set of encounters first.
          *
          * UNION (rather than UNION ALL) guarantees one encounter_id
          * in the driving dataset even if it occurs in all 3 fragments.
          */
         SELECT encounter_id
         FROM mamba_flat_encounter_art_card

         UNION

         SELECT encounter_id
         FROM mamba_flat_encounter_art_card_1

         UNION

         SELECT encounter_id
         FROM mamba_flat_encounter_art_card_2
     ) encounters

         LEFT JOIN mamba_flat_encounter_art_card a
                   ON a.encounter_id = encounters.encounter_id

         LEFT JOIN mamba_flat_encounter_art_card_1 b
                   ON b.encounter_id = encounters.encounter_id

         LEFT JOIN mamba_flat_encounter_art_card_2 c
                   ON c.encounter_id = encounters.encounter_id;


-- ---------------------------------------------------------------------------
-- Repeating-group rollups. Grouped obs are excluded from the flat pivot
-- (obs_group_id IS NULL), so the pass-through above cannot fill these; pivot
-- mamba_z_encounter_obs directly (z is refreshed before facts run, so no
-- ordering dependency on the instance fact tables). One row per encounter
-- here: multi-instance values are '; '-joined for strings, latest kept for
-- dates. Per-instance detail remains in mamba_fact_encounter_treatment_
-- interruptions / mamba_fact_encounter_adr_side_effects.
SET SESSION group_concat_max_len = 20000;

UPDATE mamba_fact_encounter_hiv_art_card f
JOIN (
    SELECT z.encounter_id,
           GROUP_CONCAT(DISTINCT CASE WHEN z.obs_question_uuid = '3aaf3680-6240-4819-a704-e20a93841942'
               THEN z.obs_value_text END SEPARATOR '; ')                       AS interruption_treatment_type,
           GROUP_CONCAT(DISTINCT CASE WHEN z.obs_question_uuid = '65d1bdf6-e518-4400-9f61-b7f2b1e80169'
               THEN z.obs_value_text END SEPARATOR '; ')                       AS interruption_stop_lost,
           DATE(MAX(CASE WHEN z.obs_question_uuid = 'ac98d431-8ebc-4397-8c78-78b0eee0ffe7'
               THEN z.obs_value_datetime END))                                 AS interruption_stop_date,
           GROUP_CONCAT(DISTINCT CASE WHEN z.obs_question_uuid = '89d3ee61-7c74-4537-b199-4026bd6a3f67'
               THEN z.obs_value_text END SEPARATOR '; ')                       AS interruption_stop_reason,
           DATE(MAX(CASE WHEN z.obs_question_uuid = '160738AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
               THEN z.obs_value_datetime END))                                 AS interruption_restart_date
    FROM mamba_z_encounter_obs z
             INNER JOIN mamba_z_encounter_obs g
                        ON g.obs_id = z.obs_group_id
                            AND g.voided = 0
                            AND g.obs_question_uuid = '2bb2e360-263c-4167-8c68-87dab66dc0f6'
    WHERE z.voided = 0
    GROUP BY z.encounter_id
) t ON t.encounter_id = f.encounter_id
SET f.interruption_treatment_type = t.interruption_treatment_type,
    f.interruption_stop_lost      = t.interruption_stop_lost,
    f.interruption_stop_date      = t.interruption_stop_date,
    f.interruption_stop_reason    = t.interruption_stop_reason,
    f.interruption_restart_date   = t.interruption_restart_date;

UPDATE mamba_fact_encounter_hiv_art_card f
JOIN (
    SELECT z.encounter_id,
           GROUP_CONCAT(DISTINCT CASE WHEN z.obs_question_uuid = 'dce05b7f-30ab-102d-86b0-7a5022ba4115'
               THEN z.obs_value_text END SEPARATOR '; ')                       AS adr_side_effects_selection,
           GROUP_CONCAT(DISTINCT CASE WHEN z.obs_question_uuid = '24b52dcb-2809-4ed8-92bb-b212f394bf50'
               THEN z.obs_value_text END SEPARATOR '; ')                       AS offending_agent,
           GROUP_CONCAT(DISTINCT CASE WHEN z.obs_question_uuid = 'f2547a99-21c9-4e86-99e8-b6c4dda36f42'
               THEN z.obs_value_text END SEPARATOR '; ')                       AS adr_grading,
           GROUP_CONCAT(DISTINCT CASE WHEN z.obs_question_uuid = 'dce0d9c2-30ab-102d-86b0-7a5022ba4115'
               THEN z.obs_value_text END SEPARATOR '; ')                       AS adr_severity,
           GROUP_CONCAT(DISTINCT CASE WHEN z.obs_question_uuid = '14eb35a0-1454-47bb-90cf-bf6cf96340a8'
               THEN z.obs_value_text END SEPARATOR '; ')                       AS adr_action_taken,
           GROUP_CONCAT(DISTINCT CASE WHEN z.obs_question_uuid = '05018034-4bf1-4025-8396-5c08e3690c10'
               THEN z.obs_value_text END SEPARATOR '; ')                       AS adr_other_outcome,
           DATE(MAX(CASE WHEN z.obs_question_uuid = '648995af-baf8-4954-a850-2ead8162a86b'
               THEN z.obs_value_datetime END))                                 AS adr_date_of_occurrence
    FROM mamba_z_encounter_obs z
             INNER JOIN mamba_z_encounter_obs g
                        ON g.obs_id = z.obs_group_id
                            AND g.voided = 0
                            AND g.obs_question_uuid = 'b05f81ca-afa4-4c7d-af9c-4523947f5dd6'
    WHERE z.voided = 0
    GROUP BY z.encounter_id
) a ON a.encounter_id = f.encounter_id
SET f.adr_side_effects_selected = a.adr_side_effects_selection,
    f.offending_agent    = a.offending_agent,
    f.adr_grading        = a.adr_grading,
    f.adr_severity       = a.adr_severity,
    f.adr_action_taken   = a.adr_action_taken,
    f.adr_other_outcome  = a.adr_other_outcome,
    f.adr_date_of_occurrence = a.adr_date_of_occurrence;
-- $END
