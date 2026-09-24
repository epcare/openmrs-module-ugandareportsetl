DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_adr_side_effects_query;
CREATE PROCEDURE sp_fact_encounter_adr_side_effects_query(IN START_DATE
                                                          DATETIME, END_DATE DATETIME)
BEGIN
    SELECT *
    FROM mamba_fact_encounter_adr_side_effects
    WHERE encounter_date >= START_DATE
      AND encounter_date <= END_DATE;
END //

DELIMITER ;
