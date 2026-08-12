/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 *
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.ugandareportsetl.api;

import java.util.Date;

/**
 * Represents an error log entry from the Mamba ETL error log table.
 */
public class ETLErrorLog {
	
	private Integer id;
	
	private String procedureName;
	
	private String errorMessage;
	
	private Integer errorCode;
	
	private String sqlState;
	
	private Date errorTime;
	
	public ETLErrorLog() {
	}
	
	public ETLErrorLog(Integer id, String procedureName, String errorMessage, Integer errorCode, String sqlState,
	    Date errorTime) {
		this.id = id;
		this.procedureName = procedureName;
		this.errorMessage = errorMessage;
		this.errorCode = errorCode;
		this.sqlState = sqlState;
		this.errorTime = errorTime;
	}
	
	// Getters and Setters
	public Integer getId() {
		return id;
	}
	
	public void setId(Integer id) {
		this.id = id;
	}
	
	public String getProcedureName() {
		return procedureName;
	}
	
	public void setProcedureName(String procedureName) {
		this.procedureName = procedureName;
	}
	
	public String getErrorMessage() {
		return errorMessage;
	}
	
	public void setErrorMessage(String errorMessage) {
		this.errorMessage = errorMessage;
	}
	
	public Integer getErrorCode() {
		return errorCode;
	}
	
	public void setErrorCode(Integer errorCode) {
		this.errorCode = errorCode;
	}
	
	public String getSqlState() {
		return sqlState;
	}
	
	public void setSqlState(String sqlState) {
		this.sqlState = sqlState;
	}
	
	public Date getErrorTime() {
		return errorTime;
	}
	
	public void setErrorTime(Date errorTime) {
		this.errorTime = errorTime;
	}
}
