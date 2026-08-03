-- $BEGIN
-- ============================================================================
-- Viral Load Episode Domain - Main Orchestration
-- ============================================================================
-- Updated: 2026-07-30
-- Now follows Mamba ETL pattern with proper SP structure
-- Calls orchestrator which handles create/insert/update
-- ============================================================================

-- Step 1: Create config tables (if not exists)
CALL sp_vl_config_create();

-- Step 2: Seed config data
CALL sp_vl_config_seed();

-- Step 3: Call the VL episode fact table orchestrator
-- This creates table, populates data, and handles updates
CALL sp_mamba_fact_viral_load_episode();
-- $END