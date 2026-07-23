-- $BEGIN
-- ARV Summary Fact Table - Latest ARV status per patient

DROP TABLE IF EXISTS mamba_fact_patients_latest_arv_order;

CREATE TABLE mamba_fact_patients_latest_arv_order (
    client_id INT PRIMARY KEY COMMENT 'Patient ID',
    order_id INT COMMENT 'Most recent order ID',

    -- Current Regimen
    current_regimen_concept_id INT COMMENT 'Current regimen concept ID',
    current_regimen VARCHAR(255) COMMENT 'Current regimen name',
    current_drug_inventory_id INT COMMENT 'Current drug inventory ID',
    current_drug_name VARCHAR(255) COMMENT 'Current drug name',

    -- Timing
    date_activated DATETIME COMMENT 'Date order was activated',
    date_stopped DATETIME COMMENT 'Date order was stopped',
    auto_expire_date DATETIME COMMENT 'Date prescription expires',

    -- Coverage Period
    coverage_start_date DATE COMMENT 'Drug coverage start date',
    coverage_end_date DATE COMMENT 'Drug coverage end date',
    days_on_drugs INT COMMENT 'Days of drug coverage',

    -- Dosing
    dose DOUBLE,
    dose_units VARCHAR(100),
    quantity DOUBLE,
    duration INT COMMENT 'Duration value from drug_order',

    -- Active Status
    is_active_on_art TINYINT DEFAULT 1 COMMENT 'Currently active on ART',
    art_start_date DATETIME COMMENT 'First known ART start date (baseline)',

    -- Timestamps
    date_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_regimen_concept_id (current_regimen_concept_id),
    INDEX idx_active_on_art (is_active_on_art),
    INDEX idx_coverage_period (coverage_start_date, coverage_end_date)
) COMMENT='Latest ARV order status per patient with drug coverage periods';

-- Populate summary table with latest ARV order per patient
INSERT INTO mamba_fact_patients_latest_arv_order (
    client_id, order_id,
    current_regimen_concept_id, current_regimen,
    current_drug_inventory_id, current_drug_name,
    date_activated, date_stopped, auto_expire_date,
    coverage_start_date, coverage_end_date, days_on_drugs,
    dose, dose_units, quantity, duration,
    is_active_on_art, art_start_date
)
SELECT
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