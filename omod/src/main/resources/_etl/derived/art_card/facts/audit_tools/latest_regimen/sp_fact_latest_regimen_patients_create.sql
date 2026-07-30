-- $BEGIN
DROP TABLE IF EXISTS mamba_fact_patients_latest_regimen;
-- Stores resolved concept NAMES (joined via concept_name at ETL time) so that
-- reporting never needs to join concept_name. Concept ids are deliberately not kept.
-- Every obs-derived value is paired with its `*_obs_datetime` (when it was recorded).
CREATE TABLE mamba_fact_patients_latest_regimen
(
    id                              INT AUTO_INCREMENT,
    client_id                       INT NOT NULL,
    patient_id                      INT NOT NULL,

    -- Effective (best-available); falls back CURRENT -> BASELINE -> TRANSFER_IN
    -- so that newly-enrolled patients (baseline only) still appear on the table.
    effective_regimen               VARCHAR(255) NULL,
    effective_regimen_obs_datetime  DATETIME     NULL,
    effective_regimen_other         VARCHAR(255) NULL,
    effective_regimen_source        VARCHAR(20)  NULL,

    -- Current regimen: latest obs for concept 90315 (CURRENT ARV REGIMEN) from any
    -- encounter type (ART Card visit, ART Regimen Change, VL Request, ANC, Summary, ...).
    current_regimen                 VARCHAR(255) NULL,
    current_regimen_obs_datetime    DATETIME     NULL,
    current_regimen_other           VARCHAR(255) NULL,
    current_regimen_other_obs_datetime DATETIME  NULL,
    current_regimen_encounter_type  VARCHAR(100) NULL,
    current_regimen_location_id     INT          NULL,

    -- Baseline (initial) regimen: ART Card - Summary page, concept 99061
    baseline_regimen                VARCHAR(255) NULL,
    baseline_regimen_obs_datetime   DATETIME     NULL,
    baseline_regimen_other          VARCHAR(255) NULL,
    baseline_regimen_other_obs_datetime DATETIME NULL,

    -- Transfer-in regimen: ART Card - Summary page, concept 99064
    transfer_in_regimen             VARCHAR(255) NULL,
    transfer_in_regimen_obs_datetime DATETIME   NULL,
    transfer_in_regimen_other       VARCHAR(255) NULL,
    transfer_in_regimen_other_obs_datetime DATETIME NULL,

    -- Regimen line: latest obs (164515 / 164350) falling back to the open program
    -- workflow state (concept 166214). obs_datetime comes from the obs, or from
    -- patient_state.start_date when the line came from the program workflow.
    regimen_line                    VARCHAR(100) NULL,
    regimen_line_obs_datetime       DATETIME     NULL,
    regimen_line_source             VARCHAR(20)  NULL,

    -- ART start date (concept 99161 value_datetime) and when that obs was recorded.
    art_start_date                  DATE         NULL,
    art_start_obs_datetime          DATETIME     NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_patients_latest_regimen_client_id_index
    ON mamba_fact_patients_latest_regimen (client_id);

CREATE INDEX
    mamba_fact_patients_latest_regimen_patient_id_index
    ON mamba_fact_patients_latest_regimen (patient_id);

CREATE INDEX
    mamba_fact_patients_latest_regimen_effective_regimen_index
    ON mamba_fact_patients_latest_regimen (effective_regimen);

CREATE INDEX
    mamba_fact_patients_latest_regimen_line_index
    ON mamba_fact_patients_latest_regimen (regimen_line);

CREATE INDEX
    mamba_fact_patients_latest_regimen_source_index
    ON mamba_fact_patients_latest_regimen (effective_regimen_source);

-- $END
