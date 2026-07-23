-- $BEGIN
SET @arv_concepts = '630,794,90002,99001,99002,99003,99004,99005,99006,99007,99008,99009,99010,99011,99012,99013,99014,99015,99016,99017,99018,99019,99039,99040,99041,99042,99043,99044,99045,99046,99047,99048,99143,99144,99277,99282,99283,99284,99285,99286,99884,99885,99887,99888,163017,164976,164977,164978,164979,165780,165794,175325,175329';

INSERT INTO mamba_fact_arv_orders (
    client_id, patient_id, order_id, encounter_id,
    regimen_concept_id, regimen,
    drug_inventory_id, drug_name,
    date_activated, date_stopped, auto_expire_date,
    coverage_start_date, coverage_end_date, days_on_drugs,
    dose, dose_units, quantity, quantity_units,
    duration, duration_units, duration_units_concept_id,
    frequency, route,
    order_number, order_action, urgency, voided
)
SELECT DISTINCT
    o.patient_id as client_id,
    o.patient_id as patient_id,
    o.order_id,
    o.encounter_id,
    o.concept_id as regimen_concept_id,
    (SELECT name FROM concept_name WHERE concept_id = o.concept_id AND concept_name_type = 'FULLY_SPECIFIED' AND locale = 'en' AND voided = 0 LIMIT 1) as regimen,
    do.drug_inventory_id,
    d.name as drug_name,
    o.date_activated,
    o.date_stopped,
    o.auto_expire_date,
    DATE(o.date_activated) as coverage_start_date,
    CASE
        WHEN do.duration IS NOT NULL AND do.duration_units IS NOT NULL THEN
            DATE_ADD(DATE(o.date_activated), INTERVAL fn_duration_to_days(do.duration, do.duration_units) DAY)
        WHEN o.auto_expire_date IS NOT NULL THEN
            DATE(o.auto_expire_date)
        ELSE
            DATE_ADD(DATE(o.date_activated), INTERVAL 30 DAY)
    END as coverage_end_date,
    CASE
        WHEN do.duration IS NOT NULL AND do.duration_units IS NOT NULL THEN
            fn_duration_to_days(do.duration, do.duration_units)
        WHEN o.auto_expire_date IS NOT NULL THEN
            DATEDIFF(o.auto_expire_date, o.date_activated)
        ELSE
            30
    END as days_on_drugs,
    do.dose,
    du.name as dose_units,
    do.quantity,
    qu.name as quantity_units,
    do.duration,
    dur_units.name as duration_units,
    do.duration_units as duration_units_concept_id,
    fr.name as frequency,
    rt.name as route,
    o.order_number,
    NULL as order_action,
    o.urgency,
    o.voided
FROM orders o
INNER JOIN drug_order do ON do.order_id = o.order_id
INNER JOIN drug d ON d.drug_id = do.drug_inventory_id
LEFT JOIN concept_name dur_units ON dur_units.concept_id = do.duration_units AND dur_units.concept_name_type = 'FULLY_SPECIFIED' AND dur_units.locale = 'en' AND dur_units.voided = 0
LEFT JOIN concept_name du ON du.concept_id = do.dose_units AND du.concept_name_type = 'FULLY_SPECIFIED' AND du.locale = 'en' AND du.voided = 0
LEFT JOIN concept_name qu ON qu.concept_id = do.quantity_units AND qu.concept_name_type = 'FULLY_SPECIFIED' AND qu.locale = 'en' AND qu.voided = 0
LEFT JOIN concept_name fr ON fr.concept_id = do.frequency AND fr.concept_name_type = 'FULLY_SPECIFIED' AND fr.locale = 'en' AND fr.voided = 0
LEFT JOIN concept_name rt ON rt.concept_id = do.route AND rt.concept_name_type = 'FULLY_SPECIFIED' AND rt.locale = 'en' AND rt.voided = 0
WHERE FIND_IN_SET(o.concept_id, @arv_concepts) > 0
  AND o.voided = 0;
-- $END