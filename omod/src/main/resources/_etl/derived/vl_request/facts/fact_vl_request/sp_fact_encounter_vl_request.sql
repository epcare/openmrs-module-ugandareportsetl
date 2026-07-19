-- $BEGIN
DROP PROCEDURE IF EXISTS sp_fact_encounter_vl_request;

DELIMITER //
CREATE PROCEDURE sp_fact_encounter_vl_request()
BEGIN

    CALL sp_fact_encounter_vl_request_create();
    CALL sp_fact_encounter_vl_request_insert();
    CALL sp_fact_encounter_vl_request_update();

END //
DELIMITER ;
-- $END