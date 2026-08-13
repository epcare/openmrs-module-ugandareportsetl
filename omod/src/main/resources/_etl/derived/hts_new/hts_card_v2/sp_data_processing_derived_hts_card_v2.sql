-- $BEGIN
-- Main procedure to process HTS Client Card v2 ETL
CALL sp_fact_encounter_hts_card_v2_create();
CALL sp_fact_encounter_hts_card_v2_insert();
-- $END