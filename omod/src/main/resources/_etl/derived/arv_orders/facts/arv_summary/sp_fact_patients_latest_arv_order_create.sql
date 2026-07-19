-- $BEGIN
-- Create ARV Summary Fact Table

DROP TABLE IF EXISTS mamba_fact_patients_latest_arv_order;

CREATE TABLE IF NOT EXISTS mamba_fact_patients_latest_arv_order (
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
-- $END