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

import java.util.List;

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
	 * Cleanup Mamba ETL - drops all procedures and tables for clean setup
	 * 
	 * @throws APIException
	 */
	void cleanupMambaETL() throws APIException;
	
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
	
	/**
	 * Get error log entries from the Mamba ETL error log table
	 * 
	 * @param limit number of recent error entries to return
	 * @return List of recent error log entries
	 * @throws APIException
	 */
	java.util.List<ETLErrorLog> getETLErrorLogs(int limit) throws APIException;
	
	/**
	 * Get the most recent error log entry
	 * 
	 * @return The most recent error log entry, or null if no errors exist
	 * @throws APIException
	 */
	ETLErrorLog getMostRecentErrorLog() throws APIException;
	
	/**
	 * Get the current ETL settings from the user settings table
	 *
	 * @return Current ETL settings, or null if not configured
	 * @throws APIException
	 */
	ETLSettings getETLSettings() throws APIException;

	/**
	 * List all mamba_* tables in the ETL database with metadata (approximate row count, engine,
	 * category).
	 *
	 * @return list of table descriptors, one map per table
	 * @throws APIException
	 */
	java.util.List<java.util.Map<String, Object>> getEtlTables() throws APIException;

	/**
	 * Fetch a page of rows from a mamba_* table.
	 *
	 * @param tableName exact table name (must exist and match mamba_*)
	 * @param limit page size (already clamped by the caller)
	 * @param offset row offset (already clamped by the caller)
	 * @return descriptor map: tableName, totalRows, limit, offset, orderBy, columns, rows
	 * @throws APIException when the table is not an addressable mamba_* table
	 */
	java.util.Map<String, Object> getEtlTableData(String tableName, int limit, int offset) throws APIException;

}
