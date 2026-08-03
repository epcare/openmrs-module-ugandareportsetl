-- $BEGIN
-- ============================================================================
-- Viral Load Episode Fact Table - Insert Script
-- ============================================================================
-- Purpose: Populates the mamba_fact_viral_load_episode table with data
-- Calls the comprehensive VL episode ETL stored procedure
-- ============================================================================

-- Call the comprehensive VL episode ETL
-- This procedure populates mamba_fact_viral_load_episode with full
-- order-result matching and all derived fields
CALL sp_mamba_fact_vl_episode_etl();
-- $END