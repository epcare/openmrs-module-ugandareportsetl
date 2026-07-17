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
			log.info("Starting Run Analytics Task");
			
			UgandaReportsETLService service = Context.getService(UgandaReportsETLService.class);
			
			log.info("Executing ETL flattening script...");
			service.executeFlatteningScript();
			
			log.info("Run Analytics Task completed successfully");
		}
		catch (Exception e) {
			log.error("Error executing Run Analytics Task", e);
			throw new RuntimeException("Failed to run analytics ETL", e);
		}
	}
}
