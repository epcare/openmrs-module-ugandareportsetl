-- $BEGIN
DROP TABLE IF EXISTS mamba_fact_patients_latest_index_tested_partners_status;
CREATE TABLE mamba_fact_patients_latest_index_tested_partners_status
(
    id                                      INT AUTO_INCREMENT,
    client_id                               INT NOT NULL,
    patient_id                              INT NOT NULL,
    no                            INT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_patients_latest_partners_status_client_id_index ON mamba_fact_patients_latest_index_tested_partners_status (client_id);

CREATE INDEX
    mamba_patients_latest_partners_status_patient_id_index ON mamba_fact_patients_latest_index_tested_partners_status (patient_id);

-- $END

