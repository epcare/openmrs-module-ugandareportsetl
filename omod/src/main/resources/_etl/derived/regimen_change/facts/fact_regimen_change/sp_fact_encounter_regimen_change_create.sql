-- $BEGIN
CREATE TABLE mamba_fact_encounter_regimen_change
(
    id                                    INT AUTO_INCREMENT,
    encounter_id                          INT          NULL,
    client_id                             INT          NULL,
    patient_id                            INT          NULL,
    encounter_date                        DATE         NULL,
    current_regimen                       VARCHAR(255) NULL,
    current_regimen_line                  VARCHAR(255) NULL,
    regimen_change_type                   VARCHAR(255) NULL,
    new_regimen                           VARCHAR(255) NULL,
    new_regimen_line                      VARCHAR(255) NULL,
    reason_for_regimen_substitution       TEXT NULL,
    reason_for_regimen_switch             TEXT NULL,
    clinical_notes                        TEXT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX mamba_fact_encounter_regimen_change_client_id_index
    ON mamba_fact_encounter_regimen_change (client_id);

CREATE INDEX mamba_fact_encounter_regimen_change_patient_id_index
    ON mamba_fact_encounter_regimen_change (patient_id);

CREATE INDEX mamba_fact_encounter_regimen_change_encounter_id_index
    ON mamba_fact_encounter_regimen_change (encounter_id);

CREATE INDEX mamba_fact_encounter_regimen_change_encounter_date_index
    ON mamba_fact_encounter_regimen_change (encounter_date);
-- $END