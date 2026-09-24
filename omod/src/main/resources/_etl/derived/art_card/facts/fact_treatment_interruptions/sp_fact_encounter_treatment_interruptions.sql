-- $BEGIN
CALL sp_fact_encounter_treatment_interruptions_create();
CALL sp_fact_encounter_treatment_interruptions_insert();
CALL sp_fact_encounter_treatment_interruptions_update();
-- $END
