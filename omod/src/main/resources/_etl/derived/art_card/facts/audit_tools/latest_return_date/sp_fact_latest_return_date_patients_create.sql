-- $BEGIN
CREATE TABLE mamba_fact_patients_latest_return_date
(
    id                                      INT AUTO_INCREMENT,
    client_id                               INT NOT NULL,
    patient_id                              INT NOT NULL,
    return_date                             DATE NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_return_date_client_id_index ON mamba_fact_patients_latest_return_date (client_id);

CREATE INDEX
    mamba_fact_patients_latest_return_date_patient_id_index ON mamba_fact_patients_latest_return_date (patient_id);

-- $END

