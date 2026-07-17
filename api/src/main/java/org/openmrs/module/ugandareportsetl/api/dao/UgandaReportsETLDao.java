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
import org.openmrs.module.ugandareportsetl.api.ETLProgressInfo;
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
	 * Map a database row to ETLProgressInfo
	 */
	private ETLProgressInfo mapRowToProgressInfo(Object[] row) {
		return new ETLProgressInfo((Integer) row[0], // id
		        (java.util.Date) row[1], // start_time
		        (java.util.Date) row[2], // end_time
		        (java.util.Date) row[3], // next_schedule
		        (Long) row[4], // execution_duration_seconds
		        (Long) row[5], // missed_schedule_by_seconds
		        (String) row[6], // completion_status
		        (String) row[7], // transaction_status
		        (String) row[8] // success_or_error_message
		);
	}
}
