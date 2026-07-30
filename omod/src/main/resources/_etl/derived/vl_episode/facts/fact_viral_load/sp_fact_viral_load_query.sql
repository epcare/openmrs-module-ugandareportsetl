-- $BEGIN
-- ============================================================================
-- Viral Load Fact Table - Query Procedures
-- Common query patterns for viral load data
-- ============================================================================

-- Get latest viral load per patient
DROP PROCEDURE IF EXISTS sp_q_latest_vl_per_patient;

DELIMITER //

CREATE PROCEDURE sp_q_latest_vl_per_patient(
    IN p_location_id INT,
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT
        patient_id,
        MAX(viral_load_date) AS latest_vl_date,
        MAX(viral_load_id) AS latest_vl_id,
        SUM(CASE WHEN is_suppressed = 1 THEN 1 ELSE 0 END) AS suppressed_count,
        SUM(CASE WHEN is_unsuppressed = 1 THEN 1 ELSE 0 END) AS unsuppressed_count,
        COUNT(*) AS total_vl_count
    FROM mamba_fact_viral_load
    WHERE (p_location_id IS NULL OR location_id = p_location_id)
    AND (p_start_date IS NULL OR viral_load_date >= p_start_date)
    AND (p_end_date IS NULL OR viral_load_date <= p_end_date)
    AND is_valid_result = 1
    GROUP BY patient_id;
END //

DELIMITER ;

-- Get suppression statistics by location
DROP PROCEDURE IF EXISTS sp_q_suppression_by_location;

DELIMITER //

CREATE PROCEDURE sp_q_suppression_by_location(
    IN p_location_id INT,
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT
        location_id,
        COUNT(*) AS total_vl,
        SUM(CASE WHEN is_suppressed = 1 THEN 1 ELSE 0 END) AS suppressed,
        SUM(CASE WHEN is_unsuppressed = 1 THEN 1 ELSE 0 END) AS unsuppressed,
        ROUND(SUM(CASE WHEN is_suppressed = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS suppression_rate
    FROM mamba_fact_viral_load
    WHERE (p_location_id IS NULL OR location_id = p_location_id)
    AND (p_start_date IS NULL OR viral_load_date >= p_start_date)
    AND (p_end_date IS NULL OR viral_load_date <= p_end_date)
    AND is_valid_result = 1
    GROUP BY location_id;
END //

DELIMITER ;

-- Get patients due for viral load (no VL in last 12 months)
DROP PROCEDURE IF EXISTS sp_q_patients_due_for_vl;

DELIMITER //

CREATE PROCEDURE sp_q_patients_due_for_vl(
    IN p_location_id INT
)
BEGIN
    SELECT DISTINCT
        p.patient_id,
        p.person_name,
        MAX(vl.viral_load_date) AS last_vl_date,
        DATEDIFF(CURDATE(), MAX(vl.viral_load_date)) AS days_since_last_vl,
        CASE
            WHEN MAX(vl.viral_load_date) IS NULL THEN 'NEVER_HAD_VL'
            WHEN DATEDIFF(CURDATE(), MAX(vl.viral_load_date)) >= 365 THEN 'DUE_FOR_ROUTINE_VL'
            ELSE NULL
        END AS due_reason
    FROM patient p
    LEFT JOIN mamba_fact_viral_load vl ON p.patient_id = vl.patient_id
    WHERE p.voided = 0
    AND (p_location_id IS NULL OR vl.location_id = p_location_id OR vl.location_id IS NULL)
    GROUP BY p.patient_id, p.person_name
    HAVING MAX(vl.viral_load_date) IS NULL
       OR DATEDIFF(CURDATE(), MAX(vl.viral_load_date)) >= 365;
END //

DELIMITER ;

-- $END
