DELIMITER //

DROP PROCEDURE IF EXISTS sp_fact_latest_regimen_patients_query;
CREATE PROCEDURE sp_fact_latest_regimen_patients_query(IN p_client_id INT)
BEGIN
    SELECT *
    FROM mamba_fact_patients_latest_regimen
    WHERE (p_client_id IS NULL OR client_id = p_client_id)
    ORDER BY client_id;
END //

DELIMITER ;
