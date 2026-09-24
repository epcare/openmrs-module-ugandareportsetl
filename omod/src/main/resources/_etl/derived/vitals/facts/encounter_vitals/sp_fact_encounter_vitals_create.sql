-- $BEGIN
-- ============================================================================
-- Vitals Fact Table - Create Script
-- ============================================================================
-- Purpose: Creates the mamba_fact_encounter_vitals table
-- Note: This is raw SQL, not a stored procedure
-- ============================================================================
-- One row per encounter carrying >= 1 vitals concept, across ALL encounter
-- types (Vitals header widget, ART Card, ANC, PNC, ...). BMI is computed,
-- never captured as obs (concept 1342 has no obs anywhere).
-- ============================================================================

DROP TABLE IF EXISTS mamba_fact_encounter_vitals;

CREATE TABLE mamba_fact_encounter_vitals
(
    id                            INT AUTO_INCREMENT,
    encounter_id                  INT          NULL,
    client_id                     INT          NOT NULL,
    patient_id                    INT          NOT NULL,
    encounter_date                DATE         NULL,
    location_id                   INT          NULL,
    encounter_type_id             INT          NULL,
    encounter_type                VARCHAR(100) NULL,
    systolic_bp                   DOUBLE       NULL,
    diastolic_bp                  DOUBLE       NULL,
    pulse                         DOUBLE       NULL,
    temperature_c                 DOUBLE       NULL,
    weight_kg                     DOUBLE       NULL,
    height_cm                     DOUBLE       NULL,
    spo2                          DOUBLE       NULL,
    respiratory_rate              DOUBLE       NULL,
    muac                          DOUBLE       NULL,
    general_patient_note          TEXT         NULL,
    bmi                           DOUBLE       NULL,
    voided                        INT          DEFAULT 0,
    date_created                  DATETIME     DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id)
) CHARSET = UTF8MB4;

CREATE INDEX
    mamba_fact_encounter_vitals_client_id_index ON mamba_fact_encounter_vitals (client_id);

CREATE INDEX
    mamba_fact_encounter_vitals_patient_id_index ON mamba_fact_encounter_vitals (patient_id);

CREATE INDEX
    mamba_fact_encounter_vitals_encounter_id_index ON mamba_fact_encounter_vitals (encounter_id);

CREATE INDEX
    mamba_fact_encounter_vitals_encounter_date_index ON mamba_fact_encounter_vitals (encounter_date);

CREATE INDEX
    mamba_fact_encounter_vitals_location_id_index ON mamba_fact_encounter_vitals (location_id);

CREATE INDEX
    mamba_fact_encounter_vitals_encounter_type_id_index ON mamba_fact_encounter_vitals (encounter_type_id);
-- $END
