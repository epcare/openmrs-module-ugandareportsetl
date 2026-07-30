-- ============================================================================
-- Function: fn_duration_to_days
-- ============================================================================
-- Purpose: Convert duration values to days based on duration units concept ID
-- Used by: ARV Orders ETL (sp_fact_arv_orders_insert)
--
-- Duration unit concept IDs:
--   162583: Seconds
--   1733: Minutes
--   1822: Hours
--   1072: Days
--   1073: Weeks
--   1074: Months
--   1734: Years
--   162582: Number of occurrences
-- ============================================================================

DROP FUNCTION IF EXISTS fn_duration_to_days;

DELIMITER //

CREATE FUNCTION fn_duration_to_days(
    duration_value INT,
    duration_units_concept_id INT
) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE days INT;

    IF duration_units_concept_id = 1072 THEN
        -- Days: no conversion
        SET days = duration_value;
    ELSEIF duration_units_concept_id = 1073 THEN
        -- Weeks: × 7
        SET days = duration_value * 7;
    ELSEIF duration_units_concept_id = 1074 THEN
        -- Months: × 30 (standard approximation)
        SET days = duration_value * 30;
    ELSEIF duration_units_concept_id = 1734 THEN
        -- Years: × 365
        SET days = duration_value * 365;
    ELSEIF duration_units_concept_id = 1822 THEN
        -- Hours: ÷ 24
        SET days = FLOOR(duration_value / 24);
    ELSEIF duration_units_concept_id = 1733 THEN
        -- Minutes: ÷ (24*60)
        SET days = FLOOR(duration_value / 1440);
    ELSEIF duration_units_concept_id = 162583 THEN
        -- Seconds: ÷ (24*60*60)
        SET days = FLOOR(duration_value / 86400);
    ELSE
        -- Default: assume days
        SET days = duration_value;
    END IF;

    RETURN days;
END //

DELIMITER ;