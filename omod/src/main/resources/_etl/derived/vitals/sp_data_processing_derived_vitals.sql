-- $BEGIN
-- Vitals domain: per-encounter pivot first (all encounter types), then the
-- per-patient latest snapshot, whose anchor reads the encounter fact built in
-- the same run.
CALL sp_fact_encounter_vitals();
CALL sp_fact_patients_latest_vitals();
-- $END
