-- $BEGIN
-- ============================================================================
-- Viral Load Fact Table - Schema Definition
-- Simplified single-table approach for viral load data
-- ============================================================================

-- Drop existing table if exists
DROP TABLE IF EXISTS mamba_fact_viral_load;

-- Create the viral load fact table
CREATE TABLE mamba_fact_viral_load (
    viral_load_id INT AUTO_INCREMENT PRIMARY KEY,

    -- Patient identification
    patient_id INT NOT NULL,
    encounter_id INT,
    visit_id INT,

    -- Episode identifiers
    panel_obs_id INT,
    order_id INT,
    accession_number VARCHAR(200),

    -- Dates
    order_date DATE,
    sample_collection_date DATE,
    viral_load_date DATE NOT NULL,
    return_to_facility_date DATE,

    -- Results
    viral_load_numeric DOUBLE,
    viral_load_qualitative VARCHAR(100),
    viral_load_interpretation VARCHAR(100),
    is_valid_result TINYINT(1) DEFAULT 1,
    invalid_reason VARCHAR(255),

    -- Suppression
    is_suppressed TINYINT(1),
    is_unsuppressed TINYINT(1),
    is_high_viral_load TINYINT(1),
    suppression_threshold INT DEFAULT 1000,

    -- Clinical context (at time of VL)
    art_start_date DATE,
    days_on_art INT,
    current_regimen VARCHAR(255),
    current_regimen_line VARCHAR(50),
    pregnant_status VARCHAR(50),
    breastfeeding_status VARCHAR(50),

    -- Order metadata
    indication_for_vl_testing VARCHAR(255),
    specimen_source VARCHAR(100),

    -- Source workflow
    source_workflow VARCHAR(50),  -- LEGACY_ART_CARD, NEW_VL_REQUEST_FORM, UNKNOWN

    -- Location
    location_id INT,

    -- Audit
    date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Indexes for performance
    INDEX idx_patient_id (patient_id),
    INDEX idx_viral_load_date (viral_load_date),
    INDEX idx_encounter_id (encounter_id),
    INDEX idx_is_suppressed (is_suppressed),
    INDEX idx_is_valid_result (is_valid_result),
    INDEX idx_source_workflow (source_workflow),
    INDEX idx_location_id (location_id)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- $END
