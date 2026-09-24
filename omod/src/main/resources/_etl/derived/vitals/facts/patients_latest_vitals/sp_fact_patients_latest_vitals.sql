-- $BEGIN
CALL sp_fact_patients_latest_vitals_create();
CALL sp_fact_patients_latest_vitals_insert();
CALL sp_fact_patients_latest_vitals_update();
-- $END
