-- $BEGIN
UPDATE mamba_fact_encounter_regimen_change a
         INNER JOIN mamba_flat_encounter_regimen_change b
            ON a.encounter_id = b.encounter_id
SET a.current_regimen = b.current_regimen,
    a.current_regimen_line = b.current_regimen_line,
    a.regimen_change_type = b.regimen_change_type,
    a.new_regimen = b.new_regimen,
    a.new_regimen_line = b.new_regimen_line,
    a.reason_for_regimen_substitution = b.reason_for_regimen_substitution,
    a.reason_for_regimen_switch = b.reason_for_regimen_switch,
    a.clinical_notes = b.clinical_notes
WHERE b.voided = 0;
-- $END