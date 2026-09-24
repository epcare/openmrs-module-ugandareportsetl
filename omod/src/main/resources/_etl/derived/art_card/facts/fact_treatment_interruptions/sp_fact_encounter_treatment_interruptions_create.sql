-- $BEGIN
-- ============================================================================
-- Treatment Interruptions Fact Table - Create Script
-- ============================================================================
-- One row per ART/TPT/Fluconazole/TB treatment-interruption obs group instance
-- (group leader concept 2bb2e360-263c-4167-8c68-87dab66dc0f6, "Interruptions"
-- repeating group on the HMIS 003 Clinical Assessment page).
--
-- The engine's flat pivot filters obs_group_id IS NULL, so group members never
-- land in mamba_flat_encounter_art_card. This fact pivots them from
-- mamba_z_encounter_obs instead (see remove-obs-group-child-calls.sh).
-- ============================================================================

DROP TABLE IF EXISTS mamba_fact_encounter_treatment_interruptions;

CREATE TABLE mamba_fact_encounter_treatment_interruptions
(
    id                         INT AUTO_INCREMENT,
    client_id                  INT          NOT NULL,
    patient_id                 INT          NOT NULL,
    encounter_id               INT          NOT NULL,
    encounter_date             DATE         NULL,
    location_id                INT          NULL,
    obs_group_id               INT          NOT NULL COMMENT 'obs_id of the group leader row; the instance key',
    treatment_type             VARCHAR(250) NULL,
    interruption_stop_lost     VARCHAR(250) NULL,
    interruption_stop_date     DATE         NULL,
    interruption_stop_reason   VARCHAR(500) NULL,
    interruption_restart_date  DATE         NULL,
    date_created               DATETIME     DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id)
) CHARSET = UTF8MB4;

CREATE INDEX
    mamba_fact_encounter_trt_interruptions_client_id_index ON mamba_fact_encounter_treatment_interruptions (client_id);

CREATE INDEX
    mamba_fact_encounter_trt_interruptions_patient_id_index ON mamba_fact_encounter_treatment_interruptions (patient_id);

CREATE INDEX
    mamba_fact_encounter_trt_interruptions_encounter_id_index ON mamba_fact_encounter_treatment_interruptions (encounter_id);

CREATE INDEX
    mamba_fact_encounter_trt_interruptions_encounter_date_index ON mamba_fact_encounter_treatment_interruptions (encounter_date);

CREATE INDEX
    mamba_fact_encounter_trt_interruptions_obs_group_id_index ON mamba_fact_encounter_treatment_interruptions (obs_group_id);
-- $END
