-- $BEGIN
SELECT *
FROM mamba_fact_encounter_vl_request
WHERE client_id = :client_id
  AND (:encounter_date IS NULL OR encounter_date = :encounter_date)
ORDER BY encounter_date DESC;
-- $END