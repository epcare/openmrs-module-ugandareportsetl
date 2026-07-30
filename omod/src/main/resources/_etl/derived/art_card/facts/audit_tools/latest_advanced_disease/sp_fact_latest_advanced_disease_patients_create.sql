-- $BEGIN
DROP TABLE IF EXISTS mamba_fact_patients_latest_advanced_disease;
CREATE TABLE mamba_fact_patients_latest_advanced_disease
(
    id                                      INT AUTO_INCREMENT,
    client_id                               INT NOT NULL,
    patient_id                              INT NOT NULL,
    encounter_date                          DATE NULL,
    advanced_disease                        VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_advanced_disease_client_id_index ON mamba_fact_patients_latest_advanced_disease (client_id);

CREATE INDEX
    mamba_fact_patients_latest_advanced_disease_patient_id_index ON mamba_fact_patients_latest_advanced_disease (patient_id);

-- $END

