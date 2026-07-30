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
package org.openmrs.module.ugandareportsetl;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.api.context.Context;
import org.openmrs.module.BaseModuleActivator;
import org.openmrs.module.mambacore.api.FlattenDatabaseService;
import org.openmrs.module.ugandareportsetl.api.UgandaReportsETLService;
import org.openmrs.module.ugandareportsetl.tasks.SetupMambaETLTask;
import org.openmrs.scheduler.SchedulerException;
import org.openmrs.scheduler.TaskDefinition;

import java.util.Calendar;
import java.util.UUID;

/**
 * This class contains the logic that is run every time this module is either started or stopped.
 */
public class UgandaReportsETLActivator extends BaseModuleActivator {
	
	protected Log log = LogFactory.getLog(getClass());
	
	@Override
	public void started() {
		log.info("UgandaReportsETL module started - initializing...");
		
		try {
			UgandaReportsETLService service = Context.getService(UgandaReportsETLService.class);
			
			// Step 0: Cleanup existing Mamba ETL objects (for clean setup)
			log.info("Step 0: Cleaning up existing Mamba ETL procedures and tables...");
			try {
				service.cleanupMambaETL();
				log.info("Mamba ETL cleanup completed successfully");
			}
			catch (Exception e) {
				log.warn("Mamba ETL cleanup failed - continuing with setup (this may cause issues)", e);
			}
			
			// Step 1: Configure ETL properties
			log.info("Step 1: Configuring ETL properties...");
			service.addMambaetlProperties();
			
			// Step 2: Setup Mamba ETL infrastructure
			log.info("Step 2: Setting up Mamba ETL infrastructure...");
			service.setupMambaETL();
			
			log.info("UgandaReportsETL module started successfully");
		}
		catch (Exception e) {
			log.error("Error starting UgandaReportsETL module", e);
		}
	}
	
	@Override
	public void stopped() {
		try {
			Context.getService(FlattenDatabaseService.class).shutdownEtlThread();
		}
		catch (Exception e) {
			log.error("Error shutting down ETL thread", e);
		}
		log.info("UgandaReportsETL module stopped");
	}
	
}
