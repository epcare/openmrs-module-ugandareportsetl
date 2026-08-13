-- $BEGIN
-- ============================================================================
-- HTS Contact Tracing Fact Table - Create Script
-- ============================================================================
-- Purpose: Creates the mamba_fact_encounter_hts_contact_tracing table
-- Note: This is raw SQL, not a stored procedure
-- ============================================================================
CREATE TABLE mamba_fact_encounter_hts_contact_tracing
(
    id                                     INT AUTO_INCREMENT,
    encounter_id                           INT NULL,
    client_id                              INT          NULL,
    patient_id                             INT          NULL,
    encounter_date                         DATETIME         NULL,
    hts_number                             VARCHAR(250) NULL,
    contact_tracing_category               VARCHAR(250) NULL,
    contact_type                           VARCHAR(250) NULL,
    reason_why_at_risk                     VARCHAR(250) NULL,
    other_reason_why_at_risk               VARCHAR(250) NULL,
    entry_point_hf                         VARCHAR(250) NULL,
    other_entry_point_hf                   VARCHAR(250) NULL,
    entry_point_community                  VARCHAR(250) NULL,
    other_entry_point_community            VARCHAR(250) NULL,
    special_category                       VARCHAR(250) NULL,
    other_special_category                 VARCHAR(250) NULL,
    number_sexual_partners                 VARCHAR(250) NULL,
    number_biological_children              VARCHAR(250) NULL,
    number_social_contact                  VARCHAR(250) NULL,
    number_pwid_contact                    VARCHAR(250) NULL,
    attempt_made                           VARCHAR(250) NULL,
    index_counselled                       VARCHAR(250) NULL,
    index_date_reached                     DATE         NULL,
    encounter_outcome                      VARCHAR(250) NULL,
    remarks                                VARCHAR(500) NULL,
    contact_name                           VARCHAR(250) NULL,
    contact_number                         VARCHAR(250) NULL,
    contact_category                      VARCHAR(250) NULL,
    other_contact_category                VARCHAR(250) NULL,
    common_name                            VARCHAR(250) NULL,
    contact_age                            VARCHAR(250) NULL,
    contact_sex                            VARCHAR(250) NULL,
    contact_telephone                      VARCHAR(250) NULL,
    contact_alternative_telephone          VARCHAR(250) NULL,
    contact_residential_place              VARCHAR(250) NULL,
    contact_notification_method            VARCHAR(250) NULL,
    contact_violence_history               VARCHAR(250) NULL,
    contact_encounter_date                 DATE         NULL,
    contact_reach_attempt                  VARCHAR(250) NULL,
    contact_encounter_means                VARCHAR(250) NULL,
    other_contact_encounter_means          VARCHAR(250) NULL,
    contact_encounter_outcome              VARCHAR(250) NULL,
    other_contact_encounter_outcome        VARCHAR(250) NULL,
    hiv_test_date                          DATE         NULL,
    hiv_test_results                       VARCHAR(250) NULL,
    case_closure_status                    VARCHAR(250) NULL,
    other_case_closure_status              VARCHAR(250) NULL,
    contact_clinic_number                  VARCHAR(250) NULL,
    hiv_prevention_services                VARCHAR(500) NULL,
    other_prevention_services               VARCHAR(250) NULL,
    experienced_violence                   VARCHAR(250) NULL,
    type_of_violence                       VARCHAR(250) NULL,
    contact_care_comments                  VARCHAR(500) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_encounter_hts_contact_tracing_client_id_index ON mamba_fact_encounter_hts_contact_tracing (client_id);

CREATE INDEX
    mamba_fact_encounter_hts_contact_tracing_patient_id_index ON mamba_fact_encounter_hts_contact_tracing (patient_id);

CREATE INDEX
    mamba_fact_encounter_hts_contact_tracing_encounter_id_index ON mamba_fact_encounter_hts_contact_tracing (encounter_id);

CREATE INDEX
    mamba_fact_encounter_hts_contact_tracing_encounter_date_index ON mamba_fact_encounter_hts_contact_tracing (encounter_date);

CREATE INDEX
    mamba_fact_encounter_hts_contact_tracing_contact_category_index ON mamba_fact_encounter_hts_contact_tracing (contact_tracing_category);
-- $END
