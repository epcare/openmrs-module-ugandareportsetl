DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_vitals_query;
CREATE PROCEDURE sp_fact_encounter_vitals_query(IN START_DATE
                                                DATETIME, END_DATE DATETIME)
BEGIN
    SELECT *
    FROM mamba_fact_encounter_vitals vitals WHERE vitals.encounter_date >= START_DATE
      AND vitals.encounter_date <= END_DATE;
END //

DELIMITER ;
