/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
package org.openmrs.module.ugandareportsetl.api.impl;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.api.APIException;
import org.openmrs.api.UserService;
import org.openmrs.api.context.Context;
import org.openmrs.api.impl.BaseOpenmrsService;
import org.openmrs.module.mambacore.api.FlattenDatabaseService;
import org.openmrs.module.ugandareportsetl.api.ETLProgressInfo;
import org.openmrs.module.ugandareportsetl.api.UgandaReportsETLService;
import org.openmrs.module.ugandareportsetl.api.dao.UgandaReportsETLDao;
import org.openmrs.util.OpenmrsUtil;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Properties;

/**
 * Default implementation of {@link UgandaReportsETLService}.
 */
public class UgandaReportsETLServiceImpl extends BaseOpenmrsService implements UgandaReportsETLService {
	
	protected final Log log = LogFactory.getLog(this.getClass());
	
	private UgandaReportsETLDao dao;
	
	/**
	 * Injected in moduleApplicationContext.xml
	 */
	public void setDao(UgandaReportsETLDao dao) {
		this.dao = dao;
	}
	
	@Override
	public void addMambaetlProperties() throws APIException {
		try {
			log.info("Adding Mamba ETL properties...");
			
			File appDataDir = new File(OpenmrsUtil.getApplicationDataDirectory());
			File propertiesFile = new File(appDataDir, "openmrs-runtime.properties");
			Properties properties = new Properties();
			
			FileInputStream in = null;
			try {
				in = new FileInputStream(propertiesFile);
				properties.load(in);
			}
			catch (IOException e) {
				log.error("Failed to read properties file: " + e.getMessage());
				return;
			}
			finally {
				if (in != null) {
					try {
						in.close();
					}
					catch (IOException e) {
						log.error("Failed to close input stream: " + e.getMessage());
					}
				}
			}
			
			String connectionUrl = properties.getProperty("connection.url");
			String dbName = null;
			
			if (connectionUrl != null && connectionUrl.contains("/")) {
				try {
					int lastSlash = connectionUrl.lastIndexOf('/');
					int questionMark = connectionUrl.indexOf('?', lastSlash);
					if (lastSlash != -1 && questionMark != -1) {
						dbName = connectionUrl.substring(lastSlash + 1, questionMark);
					} else if (lastSlash != -1) {
						dbName = connectionUrl.substring(lastSlash + 1);
					}
				}
				catch (Exception e) {
					log.error("Error parsing connection.url: " + e.getMessage());
				}
			}
			
			if (dbName == null || dbName.isEmpty()) {
				dbName = "openmrs";
				log.warn("Using fallback database name: " + dbName);
			}
			
			String username = properties.getProperty("connection.username", "openmrs");
			if (username.isEmpty()) {
				username = "openmrs";
				log.warn("Using fallback username: " + username);
			}
			
			String password = properties.getProperty("connection.password", "openmrs");
			if (password.isEmpty()) {
				password = "openmrs";
				log.warn("Using fallback password");
			}
			
			setPropertyIfAbsent(properties, "mambaetl.analysis.db.openmrs_database", dbName);
			setPropertyIfAbsent(properties, "mambaetl.analysis.db.etl_database", dbName);
			setPropertyIfAbsent(properties, "mambaetl.analysis.db.username", username);
			setPropertyIfAbsent(properties, "mambaetl.analysis.db.password", password);
			setPropertyIfAbsent(properties, "mambaetl.analysis.columns", "49");
			setPropertyIfAbsent(properties, "mambaetl.analysis.incremental_mode", "1");
			setPropertyIfAbsent(properties, "mambaetl.analysis.etl_interval", "3600");
			setPropertyIfAbsent(properties, "mambaetl.analysis.locale", "en");
			setPropertyIfAbsent(properties, "mambaetl.analysis.automated_flattening", "0");
			
			FileOutputStream out = null;
			try {
				out = new FileOutputStream(propertiesFile);
				properties.store(out, "Updated with MambaETL related properties (added only if missing)");
				log.info("MambaETL properties checked and updated successfully.");
			}
			catch (IOException e) {
				log.error("Failed to write properties file: " + e.getMessage());
			}
			finally {
				if (out != null) {
					try {
						out.close();
					}
					catch (IOException e) {
						log.error("Failed to close output stream: " + e.getMessage());
					}
				}
			}
		}
		catch (Exception e) {
			log.error("Error adding Mamba ETL properties", e);
			throw new APIException("Error adding Mamba ETL properties", e);
		}
	}
	
	@Override
	public void setupMambaETL() throws APIException {
		try {
			log.info("Setting up Mamba ETL infrastructure...");
			
			FlattenDatabaseService flattenDatabaseService = Context.getService(FlattenDatabaseService.class);
			flattenDatabaseService.setupEtl();
			
			log.info("Mamba ETL infrastructure setup completed successfully");
		}
		catch (Exception e) {
			log.error("Error setting up Mamba ETL infrastructure", e);
			throw new APIException("Error setting up Mamba ETL infrastructure", e);
		}
	}
	
	@Override
	public void executeFlatteningScript() throws APIException {
		try {
			log.info("=== Starting Mamba ETL Flattening Script ===");
			log.info("Timestamp: " + new java.util.Date());
			log.info("Processing Mode: Incremental ETL (existing tables will be preserved and updated)");
			
			// Log that we're about to execute the stored procedure
			log.info("Executing stored procedure: sp_mamba_data_processing_etl(1)");
			log.info("This process will:");
			log.info("  1. Drop existing fact tables");
			log.info("  2. Recreate fact tables");
			log.info("  3. Process OPD attendance data");
			log.info("  4. Process diagnosis data");
			log.info("  5. Process transfer data");
			log.info("  6. Process non-suppressed data");
			log.info("  7. Process HIV ART card data");
			log.info("  8. Process IIT data");
			log.info("  9. Process HTS data");
			log.info(" 10. Process ANC data");
			
			long startTime = System.currentTimeMillis();
			
			dao.executeFlatteningScript();
			
			long duration = System.currentTimeMillis() - startTime;
			log.info("=== Mamba ETL Flattening Script Completed Successfully ===");
			log.info("Total Duration: " + (duration / 1000) + " seconds");
			log.info("Completion Time: " + new java.util.Date());
			
		}
		catch (Exception e) {
			log.error("=== Error Executing Mamba ETL Flattening Script ===");
			log.error("Error occurred during stored procedure execution");
			log.error("Possible causes:");
			log.error("  - Stored procedure does not exist");
			log.error("  - Database connection issues");
			log.error("  - SQL syntax errors in stored procedures");
			log.error("  - Insufficient database permissions");
			log.error("Please check the Mamba ETL setup and stored procedures");
			log.error("Error executing Mamba ETL flattening script", e);
			throw new APIException("Error executing Mamba ETL flattening script", e);
		}
	}
	
	/**
	 * Helper method to set a property only if it's not already present
	 */
	private static void setPropertyIfAbsent(Properties properties, String key, String value) {
		if (!properties.containsKey(key) || properties.getProperty(key) == null
		        || properties.getProperty(key).trim().isEmpty()) {
			properties.setProperty(key, value);
		}
	}
	
	@Override
	public ETLProgressInfo getETLProgress() throws APIException {
		try {
			log.info("Fetching ETL progress information...");
			
			// Query the Mamba ETL schedule table for the most recent execution
			String sql = "SELECT id, start_time, end_time, next_schedule, "
			        + "execution_duration_seconds, missed_schedule_by_seconds, "
			        + "completion_status, transaction_status, success_or_error_message " + "FROM _mamba_etl_schedule "
			        + "ORDER BY id DESC " + "LIMIT 1";
			
			ETLProgressInfo progress = dao.getETLProgress(sql);
			
			// Enhance with current stage information
			if (progress != null && progress.isRunning()) {
				progress.setCurrentStage(determineCurrentStage(progress));
				progress.setProgressPercentage(calculateProgress(progress));
			}
			
			return progress;
		}
		catch (Exception e) {
			log.error("Error fetching ETL progress", e);
			throw new APIException("Error fetching ETL progress", e);
		}
	}
	
	@Override
	public java.util.List<ETLProgressInfo> getRecentETLExecutions(int limit) throws APIException {
		try {
			log.info("Fetching recent ETL executions (limit: " + limit + ")...");
			
			String sql = "SELECT id, start_time, end_time, next_schedule, "
			        + "execution_duration_seconds, missed_schedule_by_seconds, "
			        + "completion_status, transaction_status, success_or_error_message " + "FROM _mamba_etl_schedule "
			        + "ORDER BY id DESC " + "LIMIT " + limit;
			
			return dao.getRecentETLExecutions(sql);
		}
		catch (Exception e) {
			log.error("Error fetching recent ETL executions", e);
			throw new APIException("Error fetching recent ETL executions", e);
		}
	}
	
	@Override
	public boolean isETLRunning() {
		try {
			ETLProgressInfo progress = getETLProgress();
			return progress != null && progress.isRunning();
		}
		catch (Exception e) {
			log.error("Error checking if ETL is running", e);
			return false;
		}
	}
	
	/**
	 * Determines the current stage of ETL processing based on execution time and status
	 */
	private String determineCurrentStage(ETLProgressInfo progress) {
		long elapsedSeconds = progress.getExecutionDurationSeconds() != null ? progress.getExecutionDurationSeconds() : 0;
		
		// Estimated durations for each stage (in seconds)
		// These can be adjusted based on actual performance
		if (elapsedSeconds < 30) {
			return "Initializing ETL process";
		} else if (elapsedSeconds < 60) {
			return "Dropping existing fact tables";
		} else if (elapsedSeconds < 180) {
			return "Processing OPD attendance data";
		} else if (elapsedSeconds < 240) {
			return "Processing diagnosis data";
		} else if (elapsedSeconds < 300) {
			return "Processing transfer data";
		} else if (elapsedSeconds < 360) {
			return "Processing non-suppressed data";
		} else if (elapsedSeconds < 480) {
			return "Processing HIV ART card data";
		} else if (elapsedSeconds < 600) {
			return "Processing IIT data";
		} else if (elapsedSeconds < 720) {
			return "Processing HTS data";
		} else if (elapsedSeconds < 840) {
			return "Processing ANC data";
		} else {
			return "Finalizing ETL process";
		}
	}
	
	/**
	 * Calculates estimated progress percentage based on elapsed time
	 */
	private double calculateProgress(ETLProgressInfo progress) {
		long elapsedSeconds = progress.getExecutionDurationSeconds() != null ? progress.getExecutionDurationSeconds() : 0;
		
		// Estimated total time for complete ETL process (in seconds)
		// This should be adjusted based on actual performance data
		long estimatedTotalSeconds = 900; // 15 minutes
		
		double progressPercent = Math.min(100.0, (elapsedSeconds * 100.0) / estimatedTotalSeconds);
		return Math.round(progressPercent * 100) / 100.0; // Round to 2 decimal places
	}
}
