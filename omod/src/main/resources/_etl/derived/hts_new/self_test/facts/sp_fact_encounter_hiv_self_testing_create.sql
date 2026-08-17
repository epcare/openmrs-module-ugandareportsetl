-- $BEGIN
-- ============================================================================
-- HIV Self-Testing Fact Table - Create Script
-- ============================================================================
-- Purpose: Creates the mamba_fact_encounter_hiv_self_testing table
-- Note: This is raw SQL, not a stored procedure
-- ============================================================================
-- This table stores HIV Self-Testing (HIVST) kit distribution and results
-- for HMIS 106A indicators HT05 (Facility) and HT06 (Community)
-- ============================================================================

CREATE TABLE mamba_fact_encounter_hiv_self_testing
(
    id                                     INT AUTO_INCREMENT,
    encounter_id                           INT NULL,
    client_id                              INT          NULL,
    patient_id                             INT          NULL,
    encounter_date                         DATETIME         NULL,
    location_id                            INT          NULL,
    serial_number                          VARCHAR(250) NULL,
    special_category                       VARCHAR(250) NULL,
    other_special_category                 VARCHAR(250) NULL,
    distribution_model                     VARCHAR(250) NULL,
    hf_entry_point                         VARCHAR(250) NULL,
    other_hf_entry_point                   VARCHAR(250) NULL,
    community_entry_point                  VARCHAR(250) NULL,
    other_community_entry_point            VARCHAR(250) NULL,
    hiv_self_testing_approach              VARCHAR(250) NULL,
    batch_number                           VARCHAR(250) NULL,
    expiry_date                            DATE         NULL,
    test_kit_distributor                   VARCHAR(250) NULL,
    other_test_kit_distributor             VARCHAR(250) NULL,
    use_of_test_kit                        VARCHAR(250) NULL,
    other_use_of_test_kit                  VARCHAR(250) NULL,
    secondary_user_name                     VARCHAR(250) NULL,
    secondary_user_age                     VARCHAR(50)  NULL,
    secondary_user_sex                      VARCHAR(50)  NULL,
    hivst_results                          VARCHAR(250) NULL,
    confirmatory_test_results              VARCHAR(250) NULL,
    linked_to_hiv_prevention_services     VARCHAR(50)  NULL,
    hiv_prevention_services                VARCHAR(500) NULL,
    other_prevention_services               VARCHAR(250) NULL,
    linked_to_hiv_care                      VARCHAR(50)  NULL,
    art_no                                 VARCHAR(250) NULL,
    facility_name                          VARCHAR(250) NULL,
    type_of_violence                       VARCHAR(250) NULL,
    referred_to                            VARCHAR(250) NULL,
    other_referral_location                VARCHAR(250) NULL,
    voided                                 INT          DEFAULT 0,
    date_created                           DATETIME     DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_encounter_hiv_self_testing_client_id_index ON mamba_fact_encounter_hiv_self_testing (client_id);

CREATE INDEX
    mamba_fact_encounter_hiv_self_testing_patient_id_index ON mamba_fact_encounter_hiv_self_testing (patient_id);

CREATE INDEX
    mamba_fact_encounter_hiv_self_testing_encounter_id_index ON mamba_fact_encounter_hiv_self_testing (encounter_id);

CREATE INDEX
    mamba_fact_encounter_hiv_self_testing_encounter_date_index ON mamba_fact_encounter_hiv_self_testing (encounter_date);

CREATE INDEX
    mamba_fact_encounter_hiv_self_testing_location_id_index ON mamba_fact_encounter_hiv_self_testing (location_id);

CREATE INDEX
    mamba_fact_encounter_hiv_self_testing_distribution_model_index ON mamba_fact_encounter_hiv_self_testing (distribution_model);

CREATE INDEX
    mamba_fact_encounter_hiv_self_testing_hivst_results_index ON mamba_fact_encounter_hiv_self_testing (hivst_results);
-- $END
