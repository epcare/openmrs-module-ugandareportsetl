DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_data_processing_etl;

CREATE PROCEDURE sp_mamba_data_processing_etl(IN etl_incremental_mode INT)

BEGIN
    -- add base folder SP here if any --
    CALL sp_mamba_system_drop_fact_tables();
    CALL sp_data_processing_derived_opd_attendance();
    CALL sp_fact_encounter_diagnosis();
    CALL sp_data_processing_derived_transfers();
    CALL sp_data_processing_derived_non_suppressed();
    CALL sp_data_processing_derived_hiv_art_card();
    CALL sp_data_processing_arv_orders();
    CALL sp_data_processing_derived_IIT();
    CALL sp_data_processing_derived_regimen_change();
    CALL sp_data_processing_derived_vl_request();
    CALL sp_data_processing_derived_hts();
    CALL sp_data_processing_derived_anc();
    CALL sp_data_processing_derived_cacx_screening();
    CALL sp_data_processing_derived_cacx_treatment();
    CALL sp_data_processing_derived_vl_episode();

END //

DELIMITER ;


    -- $END