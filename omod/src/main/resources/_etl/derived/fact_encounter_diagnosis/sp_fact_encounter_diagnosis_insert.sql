-- $BEGIN
INSERT INTO mamba_fact_encounter_diagnosis
(
    diagnosis_id,
    encounter_id,
    patient_id,
    client_id,
    condition_id,
    certainty,
    dx_rank,
    diagnosis_coded,
    diagnosis_non_coded,
    diagnosis_coded_name,
    coded_diagnosis_name,
    diagnosis_display,
    diagnosis_name_locale,
    diagnosis_name_type,
    uuid,
    creator,
    date_created,
    changed_by,
    date_changed,
    voided,
    voided_by,
    date_voided,
    void_reason,
    form_namespace_and_path
)
SELECT
    new.diagnosis_id,
    new.encounter_id,
    new.patient_id,
    new.client_id,
    new.condition_id,
    new.certainty,
    new.dx_rank,
    new.diagnosis_coded,
    new.diagnosis_non_coded,
    new.diagnosis_coded_name,
    new.coded_diagnosis_name,
    new.diagnosis_display,
    new.diagnosis_name_locale,
    new.diagnosis_name_type,
    new.uuid,
    new.creator,
    new.date_created,
    new.changed_by,
    new.date_changed,
    new.voided,
    new.voided_by,
    new.date_voided,
    new.void_reason,
    new.form_namespace_and_path
FROM (
    SELECT
        ed.diagnosis_id,
        ed.encounter_id,
        ed.patient_id,
        ed.patient_id as client_id,
        ed.condition_id,
        ed.certainty,
        ed.dx_rank,
        ed.diagnosis_coded,
        ed.diagnosis_non_coded,
        ed.diagnosis_coded_name,

        COALESCE(cn_by_id.name, cn_pref.name, cn_any.name) AS coded_diagnosis_name,
        COALESCE(ed.diagnosis_non_coded, cn_by_id.name, cn_pref.name, cn_any.name) AS diagnosis_display,

        COALESCE(cn_by_id.locale, cn_pref.locale, cn_any.locale) AS diagnosis_name_locale,
        COALESCE(cn_by_id.concept_name_type, cn_pref.concept_name_type, cn_any.concept_name_type) AS diagnosis_name_type,

        ed.uuid,
        ed.creator,
        ed.date_created,
        ed.changed_by,
        ed.date_changed,
        ed.voided,
        ed.voided_by,
        ed.date_voided,
        ed.void_reason,
        ed.form_namespace_and_path
    FROM encounter_diagnosis ed

    LEFT JOIN concept_name cn_by_id
       ON cn_by_id.concept_name_id = ed.diagnosis_coded_name
      AND cn_by_id.voided = 0

LEFT JOIN (
    SELECT concept_id, name, locale, concept_name_type
    FROM concept_name
    WHERE voided = 0
      AND locale = 'en'
      AND locale_preferred = 1
) cn_pref
       ON cn_pref.concept_id = ed.diagnosis_coded

LEFT JOIN (
    SELECT cn1.concept_id, cn1.name, cn1.locale, cn1.concept_name_type
    FROM concept_name cn1
    JOIN (
        SELECT concept_id, MIN(concept_name_id) AS min_id
        FROM concept_name
        WHERE voided = 0
          AND locale = 'en'
        GROUP BY concept_id
    ) m
      ON m.concept_id = cn1.concept_id
     AND m.min_id = cn1.concept_name_id
) cn_any
       ON cn_any.concept_id = ed.diagnosis_coded
) AS new

ON DUPLICATE KEY UPDATE
    encounter_id = new.encounter_id,
    patient_id = new.patient_id,
    client_id = new.client_id,
    condition_id = new.condition_id,
    certainty = new.certainty,
    dx_rank = new.dx_rank,
    diagnosis_coded = new.diagnosis_coded,
    diagnosis_non_coded = new.diagnosis_non_coded,
    diagnosis_coded_name = new.diagnosis_coded_name,
    coded_diagnosis_name = new.coded_diagnosis_name,
    diagnosis_display = new.diagnosis_display,
    diagnosis_name_locale = new.diagnosis_name_locale,
    diagnosis_name_type = new.diagnosis_name_type,
    uuid = new.uuid,
    creator = new.creator,
    date_created = new.date_created,
    changed_by = new.changed_by,
    date_changed = new.date_changed,
    voided = new.voided,
    voided_by = new.voided_by,
    date_voided = new.date_voided,
    void_reason = new.void_reason,
    form_namespace_and_path = new.form_namespace_and_path;
-- $END
