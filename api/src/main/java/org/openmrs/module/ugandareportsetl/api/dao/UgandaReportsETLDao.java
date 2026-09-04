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
package org.openmrs.module.ugandareportsetl.api.dao;

import org.hibernate.criterion.Restrictions;
import org.openmrs.api.db.hibernate.DbSession;
import org.openmrs.api.db.hibernate.DbSessionFactory;
import org.openmrs.module.ugandareportsetl.api.ETLErrorLog;
import org.openmrs.module.ugandareportsetl.api.ETLProgressInfo;
import org.openmrs.module.ugandareportsetl.api.ETLSettings;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository("ugandareportsetl.UgandaReportsETLDao")
public class UgandaReportsETLDao {
	
	@Autowired
	DbSessionFactory sessionFactory;
	
	private DbSession getSession() {
		return sessionFactory.getCurrentSession();
	}
	
	/**
	 * Execute the Mamba ETL flattening script
	 */
	public void executeFlatteningScript() {
		getSession().createSQLQuery("CALL sp_mamba_data_processing_etl(1)").executeUpdate();
	}
	
	/**
	 * Execute the Mamba ETL cleanup script - drops all procedures and tables
	 */
	public void executeMambaETLCleanup() {
		// Read and execute the cleanup SQL script
		org.springframework.core.io.Resource resource = new org.springframework.core.io.ClassPathResource(
		        "_etl/sp_mamba_etl_cleanup.sql");
		try {
			java.io.InputStream is = resource.getInputStream();
			java.util.Scanner scanner = new java.util.Scanner(is).useDelimiter("A");
			String sql = scanner.next();
			scanner.close();
			
			// Split by semicolon and execute each statement
			String[] statements = sql.split(";");
			for (String statement : statements) {
				String trimmed = statement.trim();
				if (!trimmed.isEmpty() && !trimmed.startsWith("--")) {
					try {
						getSession().createSQLQuery(trimmed).executeUpdate();
					}
					catch (Exception e) {
						// Log but continue - some objects may not exist
						System.out.println("Cleanup statement skipped: " + e.getMessage());
					}
				}
			}
		}
		catch (Exception e) {
			throw new RuntimeException("Failed to execute Mamba ETL cleanup script", e);
		}
	}
	
	/**
	 * Get current ETL progress information
	 */
	public ETLProgressInfo getETLProgress(String sql) {
		Object result = getSession().createSQLQuery(sql).uniqueResult();
		if (result == null) {
			return null;
		}
		
		Object[] row = (Object[]) result;
		return mapRowToProgressInfo(row);
	}

	/**
	 * Run a scalar COUNT(*) query, e.g. counting mamba_% tables in information_schema.
	 *
	 * @return the count, or 0 when the query yields nothing
	 */
	public int countTablesMatching(String sql) {
		Object result = getSession().createSQLQuery(sql).uniqueResult();
		return result instanceof Number ? ((Number) result).intValue() : 0;
	}
	
	/**
	 * Get recent ETL executions
	 */
	@SuppressWarnings("unchecked")
	public java.util.List<ETLProgressInfo> getRecentETLExecutions(String sql) {
		java.util.List<Object[]> results = getSession().createSQLQuery(sql).list();
		java.util.List<ETLProgressInfo> progressList = new java.util.ArrayList<>();

		for (Object[] row : results) {
			progressList.add(mapRowToProgressInfo(row));
		}

		return progressList;
	}
	
	/**
	 * Get error log entries from the Mamba ETL error log table
	 */
	@SuppressWarnings("unchecked")
	public java.util.List<ETLErrorLog> getEtlErrorLogEntries(String sql) {
		java.util.List<Object[]> results = getSession().createSQLQuery(sql).list();
		java.util.List<ETLErrorLog> errorList = new java.util.ArrayList<>();

		for (Object[] row : results) {
			errorList.add(mapRowToErrorLog(row));
		}

		return errorList;
	}
	
	/**
	 * Get the most recent error log entry
	 */
	public ETLErrorLog getMostRecentErrorLogEntry(String sql) {
		Object result = getSession().createSQLQuery(sql).uniqueResult();
		if (result == null) {
			return null;
		}
		
		Object[] row = (Object[]) result;
		return mapRowToErrorLog(row);
	}
	
	/**
	 * Get ETL settings from the user settings table
	 */
	public ETLSettings getEtlSettings(String sql) {
		Object result = getSession().createSQLQuery(sql).uniqueResult();
		if (result == null) {
			return null;
		}
		
		Object[] row = (Object[]) result;
		return mapRowToSettings(row);
	}
	
	/**
	 * Map a database row to ETLProgressInfo
	 */
	private ETLProgressInfo mapRowToProgressInfo(Object[] row) {
		return new ETLProgressInfo((Integer) row[0], // id
		        (java.util.Date) row[1], // start_time
		        (java.util.Date) row[2], // end_time
		        (java.util.Date) row[3], // next_schedule
		        row[4] != null ? ((java.math.BigInteger) row[4]).longValue() : null, // execution_duration_seconds
		        row[5] != null ? ((java.math.BigInteger) row[5]).longValue() : null, // missed_schedule_by_seconds
		        (String) row[6], // completion_status
		        (String) row[7], // transaction_status
		        (String) row[8] // success_or_error_message
		);
	}
	
	/**
	 * Map a database row to ETLErrorLog
	 */
	private ETLErrorLog mapRowToErrorLog(Object[] row) {
		return new ETLErrorLog((Integer) row[0], // id
		        (String) row[1], // procedure_name
		        (String) row[2], // error_message
		        (Integer) row[3], // error_code
		        (String) row[4], // sql_state
		        (java.util.Date) row[5] // error_time
		);
	}
	
	/**
	 * Map a database row to ETLSettings
	 */
	private ETLSettings mapRowToSettings(Object[] row) {
		return new ETLSettings((Integer) row[0], // id
		        (String) row[1], // openmrs_database
		        (String) row[2], // etl_database
		        (String) row[3], // concepts_locale
		        row[4] != null ? ((Number) row[4]).intValue() : null, // table_partition_number
		        toBoolean(row[5]), // incremental_mode_switch
		        toBoolean(row[6]), // automatic_flattening_mode_switch
		        row[7] != null ? ((Number) row[7]).intValue() : null, // etl_interval_seconds
		        toBoolean(row[8]), // incremental_mode_switch_cascaded
		        row[9] != null ? ((Number) row[9]).intValue() : null // last_etl_schedule_insert_id
		);
	}

	/**
	 * Coerce a TINYINT(1) column value to boolean. Hibernate maps TINYINT(1) to
	 * java.lang.Boolean while some drivers/queries return a Number — accept both.
	 */
	private static boolean toBoolean(Object value) {
		if (value == null) {
			return false;
		}
		if (value instanceof Boolean) {
			return (Boolean) value;
		}
		if (value instanceof Number) {
			return ((Number) value).intValue() == 1;
		}
		return Boolean.parseBoolean(value.toString());
	}
}
