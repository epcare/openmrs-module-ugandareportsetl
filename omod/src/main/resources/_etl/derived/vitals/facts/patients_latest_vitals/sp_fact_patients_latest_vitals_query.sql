DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_patients_latest_vitals_query;
CREATE PROCEDURE sp_fact_patients_latest_vitals_query(IN START_DATE
                                                      DATETIME, END_DATE DATETIME)
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_vitals latest_vitals WHERE latest_vitals.vitals_date >= START_DATE
      AND latest_vitals.vitals_date <= END_DATE;
END //

DELIMITER ;
