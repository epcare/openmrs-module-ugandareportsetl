-- $BEGIN
DROP TABLE IF EXISTS mamba_fact_patients_latest_family_planning;
CREATE TABLE mamba_fact_patients_latest_family_planning
(
    id             INT AUTO_INCREMENT,
    client_id      INT NOT NULL,
    patient_id     INT NOT NULL,
    encounter_date DATE NULL,
    status         VARCHAR(100) NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_family_planning_client_id_index ON mamba_fact_patients_latest_family_planning (client_id);

CREATE INDEX
    mamba_fact_patients_latest_family_planning_patient_id_index ON mamba_fact_patients_latest_family_planning (patient_id);

-- $END

