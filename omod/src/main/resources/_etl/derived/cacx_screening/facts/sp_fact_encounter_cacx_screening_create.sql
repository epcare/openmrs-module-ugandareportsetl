-- $BEGIN
CREATE TABLE mamba_fact_encounter_cacx_screening
(
    id                                    INT AUTO_INCREMENT,
    encounter_id                          INT NULL,
    client_id                             INT          NULL,
    patient_id                            INT          NULL,
    encounter_date                        DATETIME         NULL,
    serial_number                         TEXT         NULL,
    reg_number                            TEXT         NULL,
    referred_in                           VARCHAR(250) NULL,
    entry_point                           VARCHAR(250) NULL,
    hiv_status                            VARCHAR(250) NULL,
    art_status                            VARCHAR(250) NULL,
    ever_been_screened                    VARCHAR(250) NULL,
    given_pre_test                        VARCHAR(250) NULL,
    menstruating_now                      VARCHAR(250) NULL,
    pregnant_now                          VARCHAR(250) NULL,
    been_pregnant_last_three_months       VARCHAR(250) NULL,
    hysterectomy                          VARCHAR(250) NULL,
    previously_on_cacx_treatment          VARCHAR(250) NULL,
    cacx_screening                        VARCHAR(250) NULL,
    ready_to_receive_service              VARCHAR(250) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_encounter_cacx_screening_client_id_index ON mamba_fact_encounter_cacx_screening (client_id);

CREATE INDEX
    mamba_fact_encounter_cacx_screening_patient_id_index ON mamba_fact_encounter_cacx_screening (patient_id);

CREATE INDEX
    mamba_fact_encounter_cacx_screening_encounter_id_index ON mamba_fact_encounter_cacx_screening (encounter_id);

CREATE INDEX
    mamba_fact_encounter_cacx_screening_encounter_date_index ON mamba_fact_encounter_cacx_screening (encounter_date);
-- $END