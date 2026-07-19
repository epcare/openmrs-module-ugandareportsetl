-- $BEGIN
-- ARV Orders Fact Table - HIV/AIDS ARV regimen orders with drug coverage periods

-- Drop existing table if exists
DROP TABLE IF EXISTS mamba_fact_arv_orders;

-- Create ARV Orders Fact Table
CREATE TABLE IF NOT EXISTS mamba_fact_arv_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL COMMENT 'Patient ID',
    order_id INT NOT NULL UNIQUE COMMENT 'Order ID from orders table',
    encounter_id INT COMMENT 'Encounter ID when order was placed',

    -- Regimen Information
    regimen_concept_id INT NOT NULL COMMENT 'Concept ID of the ARV regimen prescribed',
    regimen VARCHAR(255) COMMENT 'Regimen name from concept',
    drug_inventory_id INT COMMENT 'Drug inventory ID from drug_order',
    drug_name VARCHAR(255) COMMENT 'Drug name from drug table',

    -- Timing Information
    date_activated DATETIME COMMENT 'When the order was activated (coverage start)',
    date_stopped DATETIME COMMENT 'When the order was stopped',
    auto_expire_date DATETIME COMMENT 'When the prescription expires (system calc)',

    -- Coverage Period (CALCULATED)
    coverage_start_date DATE COMMENT 'When drug coverage starts',
    coverage_end_date DATE COMMENT 'When drug coverage ends (date_activated + duration)',
    days_on_drugs INT COMMENT 'Calculated days of drug coverage',

    -- Dosing Information
    dose DOUBLE COMMENT 'Dose amount',
    dose_units VARCHAR(100) COMMENT 'Dose units',
    quantity DOUBLE COMMENT 'Quantity dispensed',
    quantity_units VARCHAR(100) COMMENT 'Quantity units',
    duration INT COMMENT 'Duration as entered',
    duration_units VARCHAR(100) COMMENT 'Duration units (Days, Weeks, Months, Years)',
    duration_units_concept_id INT COMMENT 'Duration units concept ID',
    frequency VARCHAR(100) COMMENT 'Dosing frequency',
    route VARCHAR(100) COMMENT 'Administration route',

    -- Order Metadata
    order_number VARCHAR(50) COMMENT 'Order number',
    order_action VARCHAR(50) COMMENT 'NEW, REVISE, DISCONTINUE',
    urgency VARCHAR(50) COMMENT 'ROUTINE, STAT',
    voided TINYINT DEFAULT 0 COMMENT 'Whether order is voided',

    -- Timestamps
    date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Indexes
    INDEX idx_client_id (client_id),
    INDEX idx_date_activated (date_activated),
    INDEX idx_coverage_period (coverage_start_date, coverage_end_date),
    INDEX idx_regimen_concept_id (regimen_concept_id),
    INDEX idx_active_orders (client_id, coverage_start_date, coverage_end_date, voided)
) COMMENT='HIV/AIDS ARV regimen orders with drug coverage periods';

-- $END