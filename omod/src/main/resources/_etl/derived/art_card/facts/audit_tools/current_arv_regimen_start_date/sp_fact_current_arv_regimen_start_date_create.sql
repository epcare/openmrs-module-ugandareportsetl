-- $BEGIN
CREATE TABLE mamba_fact_current_arv_regimen_start_date
(
    id                                    INT AUTO_INCREMENT,
    client_id                             INT NULL,
    patient_id                            INT NULL,
    arv_regimen_start_date                 DATE  NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_current_arv_regimen_start_date_client_id_index ON mamba_fact_current_arv_regimen_start_date (client_id);

CREATE INDEX
    mamba_fact_current_arv_regimen_start_date_patient_id_index ON mamba_fact_current_arv_regimen_start_date (patient_id);

-- $END

