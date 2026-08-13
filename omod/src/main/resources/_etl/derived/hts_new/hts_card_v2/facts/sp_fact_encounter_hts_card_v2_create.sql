-- $BEGIN
CREATE TABLE mamba_fact_encounter_hts_card_v2
(
    id                                     INT AUTO_INCREMENT,
    encounter_id                           INT NULL,
    client_id                              INT          NULL,
    patient_id                             INT          NULL,
    encounter_date                         DATETIME         NULL,
    serial_number                          TEXT         NULL,
    accompanied_by                         VARCHAR(250) NULL,
    other_accompanied_by                   VARCHAR(250) NULL,
    hts_delivery_model                     VARCHAR(250) NULL,
    hts_approach                           VARCHAR(250) NULL,
    entry_point_hf                         VARCHAR(250) NULL,
    other_entry_point_hf                   VARCHAR(250) NULL,
    entry_point_community                  VARCHAR(250) NULL,
    other_entry_point_community            VARCHAR(250) NULL,
    reason_for_testing                     VARCHAR(250) NULL,
    other_reason_for_testing               VARCHAR(250) NULL,
    first_hiv_test                         VARCHAR(250) NULL,
    last_hiv_visit_date                    DATE         NULL,
    months_since_last_tested               VARCHAR(250) NULL,
    previous_test_result                   VARCHAR(250) NULL,
    times_tested_last_12_months           VARCHAR(250) NULL,
    number_sexual_partners_12_months       VARCHAR(250) NULL,
    previous_test_location                 VARCHAR(250) NULL,
    partner_tested_before                  VARCHAR(250) NULL,
    partner_test_result                    VARCHAR(250) NULL,
    client_at_risk                         VARCHAR(250) NULL,
    risk_profile                           VARCHAR(250) NULL,
    pre_test_counseling_done               VARCHAR(250) NULL,
    counseled_as                           VARCHAR(250) NULL,
    hiv_test_consent                       VARCHAR(250) NULL,
    consent_date                           DATE         NULL,
    determine_result                       VARCHAR(250) NULL,
    stat_pak_result                        VARCHAR(250) NULL,
    sd_bioline_result                      VARCHAR(250) NULL,
    final_result                           VARCHAR(250) NULL,
    sample_sent_to_lab                     VARCHAR(250) NULL,
    results_received_individual             VARCHAR(250) NULL,
    results_received_couple                VARCHAR(250) NULL,
    couple_results                         VARCHAR(250) NULL,
    screened_for_tb                        VARCHAR(250) NULL,
    presumptive_tb                         VARCHAR(250) NULL,
    tb_case_referred                       VARCHAR(250) NULL,
    linked_for_hiv_care                    VARCHAR(250) NULL,
    referral_facility_name                 VARCHAR(250) NULL,
    art_number                             VARCHAR(250) NULL,
    linked_prevention_services             VARCHAR(250) NULL,
    place_of_referral                      VARCHAR(250) NULL,
    received_prevention_services            VARCHAR(250) NULL,
    prevention_services                    VARCHAR(250) NULL,
    other_prevention_services               VARCHAR(250) NULL,
    recency_test_name                      VARCHAR(250) NULL,
    recency_test_date                      DATE         NULL,
    recency_blood_draw_consent             VARCHAR(250) NULL,
    recency_test_result                    VARCHAR(250) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_encounter_hts_card_v2_client_id_index ON mamba_fact_encounter_hts_card_v2 (client_id);

CREATE INDEX
    mamba_fact_encounter_hts_card_v2_patient_id_index ON mamba_fact_encounter_hts_card_v2 (patient_id);

CREATE INDEX
    mamba_fact_encounter_hts_card_v2_encounter_id_index ON mamba_fact_encounter_hts_card_v2 (encounter_id);

CREATE INDEX
    mamba_fact_encounter_hts_card_v2_encounter_date_index ON mamba_fact_encounter_hts_card_v2 (encounter_date);
-- $END
