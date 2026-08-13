-- $BEGIN
-- Main procedure to process HIV Self-Testing ETL
CALL sp_fact_encounter_hiv_self_testing_create();
CALL sp_fact_encounter_hiv_self_testing_insert();
-- $END
