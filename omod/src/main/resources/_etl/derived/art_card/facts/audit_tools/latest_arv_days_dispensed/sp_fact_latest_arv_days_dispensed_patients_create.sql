-- $BEGIN
DROP TABLE IF EXISTS mamba_fact_patients_latest_arv_days_dispensed;
CREATE TABLE mamba_fact_patients_latest_arv_days_dispensed
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    patient_id     INT NOT NULL,
    encounter_date DATE NULL,
    days         INT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_arv_days_dispensed_client_id_index ON mamba_fact_patients_latest_arv_days_dispensed (client_id);

CREATE INDEX
    mamba_fact_patients_latest_arv_days_dispensed_patient_id_index ON mamba_fact_patients_latest_arv_days_dispensed (patient_id);

-- $END

