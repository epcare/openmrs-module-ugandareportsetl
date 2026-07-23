-- $BEGIN
CREATE TABLE mamba_fact_encounter_vl_request
(
    id                                    INT AUTO_INCREMENT,
    encounter_id                          INT          NULL,
    client_id                             INT          NULL,
    patient_id                            INT          NULL,
    encounter_date                        DATE         NULL,

    indication_for_vl_testing             VARCHAR(255) NULL,
    sample_collection_date                DATE NULL,
    art_start_date                        DATE NULL,
    current_who_clinical_stage            VARCHAR(255) NULL,
    current_regimen_line                  VARCHAR(255) NULL,
    current_regimen                       VARCHAR(255) NULL,
    other_current_regimen                 VARCHAR(255) NULL,
    pregnant_mother                       VARCHAR(255) NULL,
    anc_number                            VARCHAR(50) NULL,
    pnc_number                            VARCHAR(50) NULL,
    breastfeeding_mother                 VARCHAR(255) NULL,
    has_active_tb                         VARCHAR(255) NULL,
    tb_treatment_phase                    VARCHAR(255) NULL,
    arv_adherence                         VARCHAR(255) NULL,
    dsdm_models                           VARCHAR(255) NULL,
    viral_load_qualitative                VARCHAR(255) NULL,
    viral_load_quantitative               INT NULL,

    PRIMARY KEY (id),
    INDEX mamba_fact_encounter_vl_request_client_id_index (client_id),
    INDEX mamba_fact_encounter_vl_request_patient_id_index (patient_id),
    INDEX mamba_fact_encounter_vl_request_encounter_id_index (encounter_id),
    INDEX mamba_fact_encounter_vl_request_encounter_date_index (encounter_date)
)
    CHARSET = UTF8;
-- $END
