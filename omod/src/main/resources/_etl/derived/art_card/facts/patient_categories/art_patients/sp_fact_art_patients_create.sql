-- $BEGIN
DROP TABLE IF EXISTS mamba_fact_art_patients;
CREATE TABLE mamba_fact_art_patients
(
    id        INT AUTO_INCREMENT,
    client_id INT NULL,
    patient_id INT NULL,
    birthdate DATE NULL,
    age       INT NULL,
    gender    VARCHAR(10) NULL,
    dead      BIT NULL,
    age_group VARCHAR(20) NULL,


    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_art_patients_client_id_index ON mamba_fact_art_patients (client_id);

CREATE INDEX
    mamba_fact_art_patients_patient_id_index ON mamba_fact_art_patients (patient_id);

-- $END

