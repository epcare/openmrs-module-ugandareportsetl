-- $BEGIN
INSERT INTO mamba_fact_art_patients(client_id,
                                      patient_id,
                                      birthdate,
                                      age,
                                      gender,
                                      dead,
                                      age_group)
	SELECT DISTINCT e.client_id, e.patient_id, birthdate, mdp.age, gender, dead, mda.datim_agegroup as age_group
	FROM (SELECT DISTINCT client_id, patient_id FROM mamba_fact_encounter_hiv_art_card) e
	         INNER JOIN mamba_fact_patients_latest_patient_demographics mdp ON e.client_id = mdp.patient_id
	LEFT JOIN mamba_dim_agegroup mda on mda.age = mdp.age;
-- $END