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
 * Task to setup and configure Mamba ETL infrastructure for Uganda Reports ETL module. This task: 1.
 * Adds necessary MambaETL properties to openmrs-runtime.properties 2. Sets up the Mamba ETL
 * infrastructure (tables, procedures) 3. Executes the initial flattening script
 */
public class SetupMambaETLTask extends AbstractTask {
	
	private static final Log log = LogFactory.getLog(SetupMambaETLTask.class);
	
	@Override
	public void execute() {
		try {
			log.info("Starting Mamba ETL Setup Task");
			
			UgandaReportsETLService service = Context.getService(UgandaReportsETLService.class);
			
			// Step 1: Add MambaETL properties
			log.info("Adding MambaETL properties...");
			service.addMambaetlProperties();
			
			// Step 2: Setup Mamba ETL infrastructure
			log.info("Setting up Mamba ETL infrastructure...");
			service.setupMambaETL();
			
			// Step 3: Execute initial flattening script
			log.info("Executing initial ETL flattening script...");
			service.executeFlatteningScript();
			
			log.info("Mamba ETL Setup Task completed successfully");
		}
		catch (Exception e) {
			log.error("Error executing Mamba ETL Setup Task", e);
			throw new RuntimeException("Failed to setup Mamba ETL", e);
		}
	}
}
