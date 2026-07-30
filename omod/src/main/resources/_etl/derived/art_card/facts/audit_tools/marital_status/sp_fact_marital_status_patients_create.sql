-- $BEGIN
DROP TABLE IF EXISTS mamba_fact_patients_marital_status;
CREATE TABLE mamba_fact_patients_marital_status
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    patient_id     INT NOT NULL,
    marital_status VARCHAR(80) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_marital_status_client_id_index ON mamba_fact_patients_marital_status (client_id);

CREATE INDEX
    mamba_fact_patients_marital_status_patient_id_index ON mamba_fact_patients_marital_status (patient_id);

-- $END

