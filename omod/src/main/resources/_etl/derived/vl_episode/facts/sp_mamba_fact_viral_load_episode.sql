-- $BEGIN
-- ============================================================================
-- Viral Load Episode Fact Table - Main Orchestrator
-- ============================================================================
-- Purpose: Main stored procedure that orchestrates VL episode fact table ETL
-- Calls create, insert, and update procedures in sequence
-- ============================================================================

-- Step 1: Create the table (drops existing first)
CALL sp_mamba_fact_viral_load_episode_create();

-- Step 2: Populate with data
CALL sp_mamba_fact_viral_load_episode_insert();

-- Step 3: Update (placeholder for future incremental logic)
CALL sp_mamba_fact_viral_load_episode_update();
-- $END