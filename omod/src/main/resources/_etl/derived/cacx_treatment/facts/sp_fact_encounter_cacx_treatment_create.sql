-- $BEGIN
CREATE TABLE mamba_fact_encounter_cacx_treatment
(
    id                                    INT AUTO_INCREMENT,
    encounter_id                          INT NULL,
    client_id                             INT          NULL,
    patient_id                            INT          NULL,
    encounter_date                        DATETIME         NULL,
    visit_type                            VARCHAR(250) NULL,
    other_visit_type                      TEXT         NULL,
    hpv_test_done                         VARCHAR(250) NULL,
    hpv_result                            VARCHAR(250) NULL,
    via_done                              VARCHAR(250) NULL,
    why_no_via                            VARCHAR(250) NULL,
    via_procedure_screening_results       VARCHAR(250) NULL,
    via_vat_procedure_results             VARCHAR(250) NULL,
    colposcopy_results                    VARCHAR(250) NULL,
    pap_smear_results                     VARCHAR(250) NULL,
    histology_results                     VARCHAR(250) NULL,
    treatment_provided                    VARCHAR(250) NULL,
    other_treatment_provided              TEXT         NULL,
    timelines                             VARCHAR(250) NULL,
    reasons_for_postponing                VARCHAR(250) NULL,
    other_reasons_for_postponing          TEXT         NULL,
    other_services                        VARCHAR(250) NULL,
    other_treatment                       TEXT         NULL,
    referred_out                          VARCHAR(250) NULL,
    reasons_for_referral                  VARCHAR(250) NULL,
    other_reasons_for_referral            TEXT         NULL,
    health_facility_referred_to           TEXT         NULL,
    service_offered                       VARCHAR(250) NULL,
    date_service_offered                  DATE         NULL,
    comments                              TEXT         NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8;

CREATE INDEX
    mamba_fact_encounter_cacx_treatment_client_id_index ON mamba_fact_encounter_cacx_treatment (client_id);

CREATE INDEX
    mamba_fact_encounter_cacx_treatment_patient_id_index ON mamba_fact_encounter_cacx_treatment (patient_id);

CREATE INDEX
    mamba_fact_encounter_cacx_treatment_encounter_id_index ON mamba_fact_encounter_cacx_treatment (encounter_id);

CREATE INDEX
    mamba_fact_encounter_cacx_treatment_encounter_date_index ON mamba_fact_encounter_cacx_treatment (encounter_date);
-- $END