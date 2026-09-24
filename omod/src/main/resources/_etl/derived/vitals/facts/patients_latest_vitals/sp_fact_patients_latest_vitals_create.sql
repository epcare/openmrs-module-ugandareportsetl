-- $BEGIN
-- ============================================================================
-- Patients Latest Vitals Fact Table - Create Script
-- ============================================================================
-- Purpose: Creates the mamba_fact_patients_latest_vitals table
-- Note: This is raw SQL, not a stored procedure
-- ============================================================================
-- One row per patient with their globally-latest value for each vitals
-- concept, sourced from ALL encounter types. Every value is paired with the
-- obs_datetime of the obs it came from (DATETIME - obs_datetime carries real
-- times; do not DATE-truncate the companions). BMI is computed from the
-- latest weight + latest height (never captured as obs).
-- ============================================================================

DROP TABLE IF EXISTS mamba_fact_patients_latest_vitals;

CREATE TABLE mamba_fact_patients_latest_vitals
(
    id                                  INT AUTO_INCREMENT,
    client_id                           INT          NOT NULL,
    patient_id                          INT          NOT NULL,
    systolic_bp                         DOUBLE       NULL,
    systolic_bp_obs_datetime            DATETIME     NULL,
    diastolic_bp                        DOUBLE       NULL,
    diastolic_bp_obs_datetime           DATETIME     NULL,
    pulse                               DOUBLE       NULL,
    pulse_obs_datetime                  DATETIME     NULL,
    temperature_c                       DOUBLE       NULL,
    temperature_c_obs_datetime          DATETIME     NULL,
    weight_kg                           DOUBLE       NULL,
    weight_kg_obs_datetime              DATETIME     NULL,
    height_cm                           DOUBLE       NULL,
    height_cm_obs_datetime              DATETIME     NULL,
    spo2                                DOUBLE       NULL,
    spo2_obs_datetime                   DATETIME     NULL,
    respiratory_rate                    DOUBLE       NULL,
    respiratory_rate_obs_datetime       DATETIME     NULL,
    muac                                DOUBLE       NULL,
    muac_obs_datetime                   DATETIME     NULL,
    general_patient_note                TEXT         NULL,
    general_patient_note_obs_datetime   DATETIME     NULL,
    bmi                                 DOUBLE       NULL,
    bmi_obs_datetime                    DATETIME     NULL,
    vitals_date                         DATE         NULL,
    latest_vitals_encounter_id          INT          NULL,
    latest_vitals_encounter_type        VARCHAR(100) NULL,
    location_id                         INT          NULL,
    voided                              INT          DEFAULT 0,
    date_created                        DATETIME     DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id)
) CHARSET = UTF8MB4;

CREATE INDEX
    mamba_fact_patients_latest_vitals_client_id_index ON mamba_fact_patients_latest_vitals (client_id);

CREATE INDEX
    mamba_fact_patients_latest_vitals_patient_id_index ON mamba_fact_patients_latest_vitals (patient_id);

CREATE INDEX
    mamba_fact_patients_latest_vitals_vitals_date_index ON mamba_fact_patients_latest_vitals (vitals_date);

CREATE INDEX
    mamba_fact_patients_latest_vitals_latest_encounter_id_index ON mamba_fact_patients_latest_vitals (latest_vitals_encounter_id);

CREATE INDEX
    mamba_fact_patients_latest_vitals_location_id_index ON mamba_fact_patients_latest_vitals (location_id);
-- $END
