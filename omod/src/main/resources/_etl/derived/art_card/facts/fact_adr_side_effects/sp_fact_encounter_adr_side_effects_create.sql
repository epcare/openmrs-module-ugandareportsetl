-- $BEGIN
-- ============================================================================
-- ADR / Side Effects Fact Table - Create Script
-- ============================================================================
-- One row per ADR/side-effects obs group instance (group leader concept
-- b05f81ca-afa4-4c7d-af9c-4523947f5dd6, "ADR/Side Effects" repeating group on
-- the HMIS 003 Clinical Assessment page) - feeds HMIS 106A ADR01/ADR02.
--
-- The engine's flat pivot filters obs_group_id IS NULL, so group members never
-- land in mamba_flat_encounter_art_card. This fact pivots them from
-- mamba_z_encounter_obs instead (see remove-obs-group-child-calls.sh). Group
-- scoping also disambiguates the shared concepts: dce05b7f ("Side effects"
-- here vs "Diagnosis" top-level), d4f4c0e7 and d0a568f1.
-- ============================================================================

DROP TABLE IF EXISTS mamba_fact_encounter_adr_side_effects;

CREATE TABLE mamba_fact_encounter_adr_side_effects
(
    id                  INT AUTO_INCREMENT,
    client_id           INT           NOT NULL,
    patient_id          INT           NOT NULL,
    encounter_id        INT           NOT NULL,
    encounter_date      DATE          NULL,
    location_id         INT           NULL,
    obs_group_id        INT           NOT NULL COMMENT 'obs_id of the group leader row; the instance key',
    side_effects        VARCHAR(1000) NULL COMMENT 'multi-select; selected answers joined with ;',
    other_side_effects  VARCHAR(500)  NULL,
    offending_agent     VARCHAR(250)  NULL,
    other_medication    VARCHAR(500)  NULL,
    grading             VARCHAR(250)  NULL,
    severity            VARCHAR(250)  NULL,
    action_taken        VARCHAR(250)  NULL,
    outcome             VARCHAR(250)  NULL,
    other_outcome       VARCHAR(250)  NULL,
    date_of_occurrence  DATE          NULL,
    date_created        DATETIME      DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id)
) CHARSET = UTF8MB4;

CREATE INDEX
    mamba_fact_encounter_adr_side_effects_client_id_index ON mamba_fact_encounter_adr_side_effects (client_id);

CREATE INDEX
    mamba_fact_encounter_adr_side_effects_patient_id_index ON mamba_fact_encounter_adr_side_effects (patient_id);

CREATE INDEX
    mamba_fact_encounter_adr_side_effects_encounter_id_index ON mamba_fact_encounter_adr_side_effects (encounter_id);

CREATE INDEX
    mamba_fact_encounter_adr_side_effects_encounter_date_index ON mamba_fact_encounter_adr_side_effects (encounter_date);

CREATE INDEX
    mamba_fact_encounter_adr_side_effects_obs_group_id_index ON mamba_fact_encounter_adr_side_effects (obs_group_id);
-- $END
