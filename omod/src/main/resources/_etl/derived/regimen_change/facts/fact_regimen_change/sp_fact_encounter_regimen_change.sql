-- $BEGIN
DROP PROCEDURE IF EXISTS sp_fact_encounter_regimen_change;

DELIMITER //
CREATE PROCEDURE sp_fact_encounter_regimen_change()
BEGIN

    CALL sp_fact_encounter_regimen_change_create();
    CALL sp_fact_encounter_regimen_change_insert();
    CALL sp_fact_encounter_regimen_change_update();

END //
DELIMITER ;
-- $END