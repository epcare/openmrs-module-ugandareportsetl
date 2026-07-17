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
import org.openmrs.module.mambacore.api.FlattenDatabaseService;
import org.openmrs.module.ugandareportsetl.api.UgandaReportsETLService;
import org.openmrs.scheduler.tasks.AbstractTask;

/**
 * Task to setup and configure Mamba ETL infrastructure for Uganda Reports ETL module. This task: 1.
 * Adds necessary MambaETL properties to openmrs-runtime.properties 2. Sets up the Mamba ETL
 * infrastructure (tables, procedures) Note: This task may fail if the Mamba ETL SQL scripts have
 * dependency issues. The scripts at
 * /Users/lubwamasamuel/openmrs/stambrose/configuration/mambaetl/epcare/ should be reviewed for
 * proper procedure creation order. Common issues: - Procedures called before they are defined -
 * Missing procedure definitions (e.g., sp_fact_encounter_diagnosis) - SQL syntax errors in compound
 * statements
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
			try {
				FlattenDatabaseService flattenDatabaseService = Context.getService(FlattenDatabaseService.class);
				flattenDatabaseService.setupEtl();
				log.info("Mamba ETL infrastructure setup completed successfully");
			}
			catch (Exception e) {
				log.error("Mamba ETL setup failed - this may be due to SQL script dependency issues", e);
				log.error("Please check the SQL scripts at: /Users/lubwamasamuel/openmrs/stambrose/configuration/mambaetl/epcare/");
				log.error("Common fixes:");
				log.error("1. Ensure sp_fact_encounter_diagnosis procedure exists");
				log.error("2. Reorder procedures so called procedures are defined before callers");
				log.error("3. Run SQL scripts manually to identify specific syntax errors");
				throw e;
			}
			
		}
		catch (Exception e) {
			log.error("Error executing Mamba ETL Setup Task", e);
			throw new RuntimeException("Failed to setup Mamba ETL", e);
		}
	}
}
