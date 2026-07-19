-- $BEGIN
INSERT INTO mamba_fact_encounter_regimen_change (encounter_id,
                                                client_id,
                                                encounter_date,
                                                current_regimen,
                                                current_regimen_line,
                                                regimen_change_type,
                                                new_regimen,
                                                new_regimen_line,
                                                reason_for_regimen_substitution,
                                                reason_for_regimen_switch,
                                                clinical_notes)
SELECT a.encounter_id,
       a.client_id,
       a.encounter_datetime,
       current_regimen,
       current_regimen_line,
       regimen_change_type,
       new_regimen,
       new_regimen_line,
       reason_for_regimen_substitution,
       reason_for_regimen_switch,
       clinical_notes
FROM mamba_flat_encounter_regimen_change a
WHERE a.voided = 0;
-- $END