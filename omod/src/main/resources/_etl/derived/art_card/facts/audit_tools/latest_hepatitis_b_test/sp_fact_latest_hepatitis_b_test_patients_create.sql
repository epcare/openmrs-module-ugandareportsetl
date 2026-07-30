-- $BEGIN
DROP TABLE IF EXISTS mamba_fact_patients_latest_hepatitis_b_test;
CREATE TABLE mamba_fact_patients_latest_hepatitis_b_test
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    patient_id     INT NOT NULL,
    encounter_date DATE NULL,
    result         VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_hepatitis_b_test_client_id_index ON mamba_fact_patients_latest_hepatitis_b_test (client_id);

CREATE INDEX
    mamba_fact_patients_latest_hepatitis_b_test_patient_id_index ON mamba_fact_patients_latest_hepatitis_b_test (patient_id);

-- $END

