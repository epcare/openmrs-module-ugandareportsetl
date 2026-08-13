-- $BEGIN
-- ============================================================================
-- HIV Self-Testing Fact Table - Insert Script
-- ============================================================================
-- Purpose: Inserts data from HIV Self-Testing encounters into fact table
-- Uses: mamba_flat_encounter_hiv_self_testing (created by Mamba ETL)
-- Note: Ensure flat table is regenerated with all columns before running:
--       DROP TABLE mamba_flat_encounter_hiv_self_testing;
--       CALL sp_mamba_flat_encounter_table_create('mamba_flat_encounter_hiv_self_testing');
--       CALL sp_mamba_flat_encounter_table_insert('mamba_flat_encounter_hiv_self_testing', 'b75fc5be-83a6-4771-afae-87d1b68af4f7');
-- ============================================================================
INSERT INTO mamba_fact_encounter_hiv_self_testing (
    encounter_id,
    client_id,
    patient_id,
    encounter_date,
    location_id,
    serial_number,
    special_category,
    other_special_category,
    distribution_model,
    hf_entry_point,
    other_hf_entry_point,
    community_entry_point,
    other_community_entry_point,
    hiv_self_testing_approach,
    batch_number,
    expiry_date,
    test_kit_distributor,
    other_test_kit_distributor,
    use_of_test_kit,
    other_use_of_test_kit,
    secondary_user_name,
    secondary_user_age,
    secondary_user_sex,
    hivst_results,
    confirmatory_test_results,
    linked_to_hiv_prevention_services,
    hiv_prevention_services,
    other_prevention_services,
    linked_to_hiv_care,
    art_no,
    facility_name,
    type_of_violence,
    referred_to,
    other_referral_location
)
SELECT
    encounter_id,
    client_id,
    client_id AS patient_id,
    encounter_datetime AS encounter_date,
    location_id,
    serial_number,
    special_category,
    other_special_category,
    distribution_model,
    hf_entry_point,
    other_hf_entry_point,
    community_entry_point,
    other_community_entry_point,
    hiv_self_testing_approach,
    batch_number,
    expiry_date,
    test_kit_distributor,
    other_test_kit_distributor,
    use_of_test_kit,
    other_use_of_test_kit,
    secondary_user_name,
    CAST(secondary_user_age AS CHAR) AS secondary_user_age,
    secondary_user_sex,
    hivst_results,
    confirmatory_test_results,
    linked_to_hiv_prevention_services,
    hiv_prevention_services,
    other_prevention_services,
    linked_to_hiv_care,
    art_no,
    facility_name,
    type_of_violence,
    referred_to,
    other_referral_location
FROM mamba_flat_encounter_hiv_self_testing;
-- $END
