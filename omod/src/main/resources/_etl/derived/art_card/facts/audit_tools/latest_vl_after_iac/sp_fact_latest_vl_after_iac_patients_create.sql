-- $BEGIN
DROP TABLE IF EXISTS mamba_fact_patients_latest_vl_after_iac;
CREATE TABLE mamba_fact_patients_latest_vl_after_iac
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    patient_id     INT NOT NULL,
    encounter_date DATE NULL,
    results        VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_vl_after_iac_client_id_index ON mamba_fact_patients_latest_vl_after_iac (client_id);

CREATE INDEX
    mamba_fact_patients_latest_vl_after_iac_patient_id_index ON mamba_fact_patients_latest_vl_after_iac (patient_id);

-- $END

