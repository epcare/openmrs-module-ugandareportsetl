DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_encounter_regimen_change_query;
CREATE PROCEDURE sp_fact_encounter_regimen_change_query(IN p_client_id INT, IN p_encounter_date DATE)
BEGIN
    SELECT *
    FROM mamba_fact_encounter_regimen_change
    WHERE (p_client_id IS NULL OR client_id = p_client_id)
      AND (p_encounter_date IS NULL OR encounter_date = p_encounter_date)
    ORDER BY encounter_date DESC;
END //

DELIMITER ;
