-- $BEGIN
-- ARV Orders ETL - Track ARV regimen prescriptions from orders table
-- This ETL identifies patients on ART by checking for ARV regimen drug orders

-- Create and populate ARV Orders fact table
CALL sp_fact_arv_orders_create();
CALL sp_fact_arv_orders_insert();

-- Create and populate latest ARV order summary table
CALL sp_fact_patients_latest_arv_order_create();
CALL sp_fact_patients_latest_arv_order_insert();

-- $END