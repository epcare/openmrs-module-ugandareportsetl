-- $BEGIN
UPDATE mamba_fact_encounter_vl_request a
         INNER JOIN mamba_flat_encounter_vl_request b
            ON a.encounter_id = b.encounter_id
SET a.indication_for_vl_testing = b.indication_for_vl_testing,
    a.sample_collection_date = b.sample_collection_date,
    a.art_start_date = b.art_start_date,
    a.current_who_clinical_stage = b.current_who_clinical_stage,
    a.current_regimen_line = b.current_regimen_line,
    a.current_regimen = b.current_regimen,
    a.other_current_regimen = b.other_current_regimen,
    a.pregnant_mother = b.pregnant_mother,
    a.anc_number = b.anc_number,
    a.pnc_number = b.pnc_number,
    a.breastfeeding_mother = b.breastfeeding_mother,
    a.has_active_tb = b.has_active_tb,
    a.tb_treatment_phase = b.tb_treatment_phase,
    a.arv_adherence = b.arv_adherence,
    a.dsdm_models = b.dsdm_models,
    a.viral_load_qualitative = b.viral_load_qualitative,
    a.viral_load_quantitative = b.viral_load_quantitative
WHERE b.voided = 0;
-- $END