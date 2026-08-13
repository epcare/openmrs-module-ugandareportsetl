-- $BEGIN
-- Main procedure to process HTS Contact Tracing ETL
CALL sp_fact_encounter_hts_contact_tracing_create();
CALL sp_fact_encounter_hts_contact_tracing_insert();
-- $END
