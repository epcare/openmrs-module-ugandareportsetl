-- ============================================================================
-- Viral Load Episode Domain - Main Orchestration
-- ============================================================================
-- Updated: 2026-07-29
-- Now uses the new comprehensive VL episode ETL (encounter-based structure)
-- The old sp_fact_viral_load() used obs_group_id approach which doesn't match
-- this database's structure where VL obs are linked by encounter_id + obs_datetime
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_data_processing_derived_vl_episode;

DELIMITER //

CREATE PROCEDURE sp_data_processing_derived_vl_episode()
BEGIN
    -- Call the new comprehensive VL episode ETL
    -- This creates mamba_fact_viral_load_episode table with full order-result matching
    CALL sp_mamba_fact_vl_episode_etl();
END//

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_data_processing_derived_vl_episode;

DELIMITER //

CREATE PROCEDURE sp_data_processing_derived_vl_episode()
BEGIN
    -- Call the new comprehensive VL episode ETL
    -- This creates mamba_fact_viral_load_episode table with full order-result matching
    CALL sp_mamba_fact_vl_episode_etl();
END//

DELIMITER ;

-- $END
