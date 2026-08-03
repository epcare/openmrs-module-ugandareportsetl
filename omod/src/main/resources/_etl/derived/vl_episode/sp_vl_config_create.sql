-- $BEGIN
-- Config tables from config/01_create_schema.sql
CREATE TABLE IF NOT EXISTS mamba_vl_concept_mapping (
    mapping_id INT AUTO_INCREMENT PRIMARY KEY,
    concept_id INT,
    concept_uuid CHAR(38) NOT NULL,
    canonical_field VARCHAR(100) NOT NULL,
    canonical_event_type VARCHAR(100),
    source_workflow VARCHAR(50),
    value_type VARCHAR(20),
    priority INT DEFAULT 0,
    effective_start_date DATE,
    effective_end_date DATE,
    is_active TINYINT(1) DEFAULT 1,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_concept_id (concept_id),
    INDEX idx_concept_uuid (concept_uuid),
    INDEX idx_canonical_field (canonical_field),
    INDEX idx_source_workflow (source_workflow),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS mamba_vl_coded_value_mapping (
    mapping_id INT AUTO_INCREMENT PRIMARY KEY,
    question_concept_uuid CHAR(38) NOT NULL,
    answer_concept_id INT NOT NULL,
    answer_concept_uuid CHAR(38) NOT NULL,
    answer_name VARCHAR(255),
    canonical_value VARCHAR(100) NOT NULL,
    is_valid_result TINYINT(1) DEFAULT 1,
    is_suppressed TINYINT(1),
    is_unsuppressed TINYINT(1),
    requires_recollection TINYINT(1) DEFAULT 0,
    effective_start_date DATE,
    effective_end_date DATE,
    is_active TINYINT(1) DEFAULT 1,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_question_uuid (question_concept_uuid),
    INDEX idx_answer_concept_id (answer_concept_id),
    INDEX idx_canonical_value (canonical_value),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS mamba_vl_source_mapping (
    mapping_id INT AUTO_INCREMENT PRIMARY KEY,
    form_uuid CHAR(38),
    form_id INT,
    encounter_type_uuid CHAR(38),
    encounter_type_id INT,
    source_workflow VARCHAR(50) NOT NULL,
    source_role VARCHAR(50),
    priority INT DEFAULT 0,
    effective_start_date DATE,
    effective_end_date DATE,
    is_active TINYINT(1) DEFAULT 1,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_form_uuid (form_uuid),
    INDEX idx_encounter_type_uuid (encounter_type_uuid),
    INDEX idx_source_workflow (source_workflow),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS mamba_vl_rule_config (
    config_id INT AUTO_INCREMENT PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL,
    rule_version VARCHAR(20) NOT NULL,
    population_group VARCHAR(50),
    parameter_name VARCHAR(100) NOT NULL,
    parameter_value VARCHAR(255) NOT NULL,
    parameter_type VARCHAR(20) DEFAULT 'string',
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    is_active TINYINT(1) DEFAULT 1,
    source_reference VARCHAR(255),
    approved_by VARCHAR(100),
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_rule_version (rule_name, rule_version, population_group, parameter_name),
    INDEX idx_rule_name (rule_name),
    INDEX idx_population_group (population_group),
    INDEX idx_effective_dates (effective_start_date, effective_end_date),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS mamba_vl_facility_testing_capability (
    capability_id INT AUTO_INCREMENT PRIMARY KEY,
    facility_id INT,
    location_id INT,
    location_uuid CHAR(38),
    testing_model VARCHAR(50) NOT NULL,
    device_type VARCHAR(100),
    device_identifier VARCHAR(100),
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    source VARCHAR(100),
    is_active TINYINT(1) DEFAULT 1,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_facility_id (facility_id),
    INDEX idx_location_id (location_id),
    INDEX idx_testing_model (testing_model),
    INDEX idx_effective_dates (effective_start_date, effective_end_date),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS mamba_vl_rule_version (
    version_id INT AUTO_INCREMENT PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL,
    active_version VARCHAR(50) NOT NULL,
    effective_date DATE NOT NULL,
    reason_for_change TEXT,
    approved_by VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uk_rule_name (rule_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- $END
