-- $BEGIN
-- Populate ARV Summary Fact Table with latest ARV order per patient

INSERT INTO mamba_fact_patients_latest_arv_order (
    client_id, patient_id, order_id,
    current_regimen_concept_id, current_regimen,
    current_drug_inventory_id, current_drug_name,
    date_activated, date_stopped, auto_expire_date,
    coverage_start_date, coverage_end_date, days_on_drugs,
    dose, dose_units, quantity, duration,
    is_active_on_art, art_start_date
)
SELECT
    ao.client_id,
    ao.client_id,
    ao.order_id,
    ao.regimen_concept_id as current_regimen_concept_id,
    ao.regimen as current_regimen,
    ao.drug_inventory_id as current_drug_inventory_id,
    ao.drug_name as current_drug_name,
    ao.date_activated,
    ao.date_stopped,
    ao.auto_expire_date,
    ao.coverage_start_date,
    ao.coverage_end_date,
    ao.days_on_drugs,
    ao.dose,
    ao.dose_units,
    ao.quantity,
    ao.duration,
    CASE
        WHEN ao.date_stopped IS NULL THEN 1
        ELSE 0
    END as is_active_on_art,
    (SELECT MIN(date_activated) FROM mamba_fact_arv_orders WHERE client_id = ao.client_id) as art_start_date
FROM mamba_fact_arv_orders ao
WHERE ao.order_id = (
    SELECT MAX(order_id)
    FROM mamba_fact_arv_orders
    WHERE client_id = ao.client_id
);
-- $END
