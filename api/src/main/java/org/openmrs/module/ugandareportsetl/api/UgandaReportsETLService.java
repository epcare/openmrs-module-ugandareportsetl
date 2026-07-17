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
package org.openmrs.module.ugandareportsetl.api;

import org.openmrs.api.APIException;
import org.openmrs.api.OpenmrsService;
import org.springframework.transaction.annotation.Transactional;

/**
 * This service exposes the UgandaReportsETL module's core functionality. It is a Spring managed
 * bean which is configured in moduleApplicationContext.xml.
 * <p>
 * It can be accessed only via Context:<br>
 * <code>
 * Context.getService(UgandaReportsETLService.class).someMethod();
 * </code>
 * 
 * @see org.openmrs.api.context.Context
 */
@Transactional
public interface UgandaReportsETLService extends OpenmrsService {
	
	/**
	 * Configure and add Mamba ETL properties to the runtime configuration
	 * 
	 * @throws APIException
	 */
	void addMambaetlProperties() throws APIException;
	
	/**
	 * Setup Mamba ETL infrastructure including creating necessary tables and procedures
	 * 
	 * @throws APIException
	 */
	void setupMambaETL() throws APIException;
	
	/**
	 * Execute the ETL flattening script to process data
	 * 
	 * @throws APIException
	 */
	void executeFlatteningScript() throws APIException;
	
	/**
	 * Get the current ETL progress information including status, duration, and stage
	 * 
	 * @return ETLProgressInfo containing current progress details
	 * @throws APIException
	 */
	ETLProgressInfo getETLProgress() throws APIException;
	
	/**
	 * Get the most recent ETL execution log (last N executions)
	 * 
	 * @param limit number of recent executions to return
	 * @return List of recent ETL executions
	 * @throws APIException
	 */
	java.util.List<ETLProgressInfo> getRecentETLExecutions(int limit) throws APIException;
	
	/**
	 * Check if ETL is currently running
	 * 
	 * @return true if ETL is currently running, false otherwise
	 */
	boolean isETLRunning();
	
}
