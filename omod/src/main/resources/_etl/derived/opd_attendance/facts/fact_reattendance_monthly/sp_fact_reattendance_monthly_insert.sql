-- $BEGIN
INSERT INTO mamba_fact_reattendance_monthly
(
  client_id,
  patient_id,
  report_month,
  attended_visit_count
)
SELECT
  new.client_id,
  new.patient_id,
  new.report_month,
  new.attended_visit_count
FROM (
  SELECT
    av.client_id,
    av.patient_id,
    STR_TO_DATE(DATE_FORMAT(av.first_qualifying_encounter_datetime,'%Y-%m-01'),'%Y-%m-%d') AS report_month,
    COUNT(DISTINCT av.visit_id) AS attended_visit_count
  FROM mamba_fact_attended_visit av
  GROUP BY
    av.client_id,
    av.patient_id,
    STR_TO_DATE(DATE_FORMAT(av.first_qualifying_encounter_datetime,'%Y-%m-01'),'%Y-%m-%d')
  HAVING COUNT(DISTINCT av.visit_id) > 1
) AS new
ON DUPLICATE KEY UPDATE
  attended_visit_count = new.attended_visit_count;
-- $END
