/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 *
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.ugandareportsetl.tasks;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.api.context.Context;
import org.openmrs.module.ugandareportsetl.api.UgandaReportsETLService;
import org.openmrs.scheduler.tasks.AbstractTask;

/**
 * Recurring task to execute the Mamba ETL flattening script for analytics processing. This task
 * should be scheduled to run at regular intervals (e.g., hourly or daily) to process new data into
 * the flattened analytics schema. Recommended configuration: - Repeat Interval: 3600000 (1 hour in
 * milliseconds) or as needed - Start On Startup: false (manually trigger after initial setup)
 */
public class RunAnalyticsTask extends AbstractTask {
	
	private static final Log log = LogFactory.getLog(RunAnalyticsTask.class);
	
	@Override
	public void execute() {
		try {
			log.info("=== Starting Run Analytics Task ===");
			log.info("ETL Process started at: " + new java.util.Date());
			
			// Log initial status
			log.info("Stage 1/4: Initializing ETL process...");
			
			UgandaReportsETLService service = Context.getService(UgandaReportsETLService.class);
			
			// Check if ETL is already running
			if (service.isETLRunning()) {
				log.warn("ETL process is already running. Skipping this execution to avoid conflicts.");
				return;
			}
			
			log.info("Stage 2/4: Executing ETL flattening script...");
			log.info("This may take several minutes depending on data volume...");
			long startTime = System.currentTimeMillis();
			
			service.executeFlatteningScript();
			
			long duration = System.currentTimeMillis() - startTime;
			log.info("Stage 3/4: ETL flattening script completed in " + (duration / 1000) + " seconds");
			
			// Log completion status
			log.info("Stage 4/4: Processing final status...");
			log.info("=== Run Analytics Task completed successfully ===");
			log.info("Total execution time: " + (duration / 1000) + " seconds");
			
			// Log progress information
			try {
				if (service.getETLProgress() != null) {
					log.info("ETL Progress: " + service.getETLProgress().getStatusMessage());
				}
			}
			catch (Exception e) {
				log.debug("Could not fetch final progress information: " + e.getMessage());
			}
			
		}
		catch (Exception e) {
			log.error("=== Error executing Run Analytics Task ===");
			log.error("Error Stage: " + determineErrorStage(e));
			log.error("Error Details: " + e.getMessage(), e);
			throw new RuntimeException("Failed to run analytics ETL", e);
		}
		finally {
			log.info("=== Run Analytics Task finished at: " + new java.util.Date() + " ===");
		}
	}
	
	/**
	 * Determine which stage the error occurred at based on the exception
	 */
	private String determineErrorStage(Exception e) {
		String message = e.getMessage();
		if (message != null) {
			if (message.contains("Connection") || message.contains("database")) {
				return "Database Connection";
			} else if (message.contains("table") && message.contains("doesn't exist")) {
				return "Table Creation";
			} else if (message.contains("stored procedure") || message.contains("procedure")) {
				return "Stored Procedure Execution";
			} else if (message.contains("timeout") || message.contains("timed out")) {
				return "Process Timeout";
			} else if (message.contains("memory") || message.contains("OutOfMemory")) {
				return "Memory Resources";
			}
		}
		return "Unknown Stage";
	}
}
