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
			// Configure ETL properties
			Context.getService(UgandaReportsETLService.class).addMambaetlProperties();
			
			// Setup Mamba ETL infrastructure
			Context.getService(UgandaReportsETLService.class).setupMambaETL();
			
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
