DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_data_processing_etl_scheduled;

-- ============================================================================
-- Scheduled-mode wrapper around sp_mamba_data_processing_etl
-- ============================================================================
-- Mirrors the bookkeeping done by sp_mamba_etl_schedule() on the scheduler
-- path, so that manual/API-triggered runs are first-class citizens:
--   1. Inserts a _mamba_etl_schedule row (RUNNING) for this run
--   2. Points _mamba_etl_user_settings.last_etl_schedule_insert_id at it, so
--      step-level error handlers mark THIS run's row instead of rewriting the
--      last scheduled run's historical row
--   3. Marks the row SUCCESS/COMPLETED on completion
-- On failure, the failing step's EXIT handler marks this row ERROR/COMPLETED
-- (with the error message) and RESIGNALs, so the final UPDATE never runs.
-- ============================================================================
CREATE PROCEDURE sp_mamba_data_processing_etl_scheduled(IN etl_incremental_mode INT)
BEGIN
    DECLARE v_start_time DATETIME DEFAULT NOW();
    DECLARE v_schedule_id INT;
    DECLARE v_running INT;

    -- Heal stale rows exactly as a scheduler tick would before checking
    CALL sp_mamba_etl_un_stuck_scheduler();

    -- Refuse concurrent runs: the scheduler and this proc share the single
    -- last_etl_schedule_insert_id pointer, so overlapping runs would mark
    -- each other's schedule rows
    SELECT COUNT(*) INTO v_running
    FROM _mamba_etl_schedule
    WHERE transaction_status = 'RUNNING'
      AND completion_status IS NULL;

    IF v_running > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sp_mamba_data_processing_etl_scheduled: an ETL schedule run is already RUNNING';
    END IF;

    INSERT INTO _mamba_etl_schedule(start_time, transaction_status)
    VALUES (v_start_time, 'RUNNING');

    SET v_schedule_id = LAST_INSERT_ID();

    UPDATE _mamba_etl_user_settings
    SET last_etl_schedule_insert_id = v_schedule_id
    WHERE TRUE
    ORDER BY id DESC
    LIMIT 1;

    CALL sp_mamba_data_processing_etl(etl_incremental_mode);

    UPDATE _mamba_etl_schedule
    SET end_time                   = NOW(),
        execution_duration_seconds = TIMESTAMPDIFF(SECOND, v_start_time, NOW()),
        completion_status          = 'SUCCESS',
        transaction_status         = 'COMPLETED'
    WHERE id = v_schedule_id;

END //

DELIMITER ;


    -- $END
