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
 * Represents the progress and status information of an ETL process execution. This provides users
 * with real-time feedback about what's happening during the ETL process to reduce anxiety and
 * improve troubleshooting.
 */
public class ETLProgressInfo {
	
	private Integer id;
	
	private Date startTime;
	
	private Date endTime;
	
	private Date nextSchedule;
	
	private Long executionDurationSeconds;
	
	private Long missedScheduleBySeconds;
	
	private String completionStatus;
	
	private String transactionStatus;
	
	private String successOrErrorMessage;
	
	private Double progressPercentage;
	
	private String currentStage;
	
	/**
	 * Number of mamba_* tables currently present in the ETL database.
	 */
	private Integer availableTables;
	
	/**
	 * Number of mamba_* tables expected when the ETL cycle completes (the at-rest count).
	 */
	private Integer expectedTables;
	
	public ETLProgressInfo() {
	}
	
	public ETLProgressInfo(Integer id, Date startTime, Date endTime, Date nextSchedule, Long executionDurationSeconds,
	    Long missedScheduleBySeconds, String completionStatus, String transactionStatus, String successOrErrorMessage) {
		this.id = id;
		this.startTime = startTime;
		this.endTime = endTime;
		this.nextSchedule = nextSchedule;
		this.executionDurationSeconds = executionDurationSeconds;
		this.missedScheduleBySeconds = missedScheduleBySeconds;
		this.completionStatus = completionStatus;
		this.transactionStatus = transactionStatus;
		this.successOrErrorMessage = successOrErrorMessage;
	}
	
	// Getters and Setters
	public Integer getId() {
		return id;
	}
	
	public void setId(Integer id) {
		this.id = id;
	}
	
	public Date getStartTime() {
		return startTime;
	}
	
	public void setStartTime(Date startTime) {
		this.startTime = startTime;
	}
	
	public Date getEndTime() {
		return endTime;
	}
	
	public void setEndTime(Date endTime) {
		this.endTime = endTime;
	}
	
	public Date getNextSchedule() {
		return nextSchedule;
	}
	
	public void setNextSchedule(Date nextSchedule) {
		this.nextSchedule = nextSchedule;
	}
	
	public Long getExecutionDurationSeconds() {
		return executionDurationSeconds;
	}
	
	public void setExecutionDurationSeconds(Long executionDurationSeconds) {
		this.executionDurationSeconds = executionDurationSeconds;
	}
	
	public Long getMissedScheduleBySeconds() {
		return missedScheduleBySeconds;
	}
	
	public void setMissedScheduleBySeconds(Long missedScheduleBySeconds) {
		this.missedScheduleBySeconds = missedScheduleBySeconds;
	}
	
	public String getCompletionStatus() {
		return completionStatus;
	}
	
	public void setCompletionStatus(String completionStatus) {
		this.completionStatus = completionStatus;
	}
	
	public String getTransactionStatus() {
		return transactionStatus;
	}
	
	public void setTransactionStatus(String transactionStatus) {
		this.transactionStatus = transactionStatus;
	}
	
	public String getSuccessOrErrorMessage() {
		return successOrErrorMessage;
	}
	
	public void setSuccessOrErrorMessage(String successOrErrorMessage) {
		this.successOrErrorMessage = successOrErrorMessage;
	}
	
	public Double getProgressPercentage() {
		return progressPercentage;
	}
	
	public void setProgressPercentage(Double progressPercentage) {
		this.progressPercentage = progressPercentage;
	}
	
	public String getCurrentStage() {
		return currentStage;
	}
	
	public void setCurrentStage(String currentStage) {
		this.currentStage = currentStage;
	}
	
	public Integer getAvailableTables() {
		return availableTables;
	}
	
	public void setAvailableTables(Integer availableTables) {
		this.availableTables = availableTables;
	}
	
	public Integer getExpectedTables() {
		return expectedTables;
	}
	
	public void setExpectedTables(Integer expectedTables) {
		this.expectedTables = expectedTables;
	}
	
	/**
	 * Determines if the ETL process is currently running
	 */
	public boolean isRunning() {
		return "RUNNING".equals(transactionStatus);
	}
	
	/**
	 * Determines if the ETL process completed successfully
	 */
	public boolean isCompleted() {
		return "COMPLETED".equals(transactionStatus) && "SUCCESS".equals(completionStatus);
	}
	
	/**
	 * Determines if the ETL process completed with errors
	 */
	public boolean hasErrors() {
		return "ERROR".equals(completionStatus);
	}
	
	/**
	 * Gets a user-friendly status message
	 */
	public String getStatusMessage() {
		if (isRunning()) {
			return "ETL process is currently running";
		} else if (isCompleted()) {
			return "ETL process completed successfully";
		} else if (hasErrors()) {
			return "ETL process completed with errors: " + successOrErrorMessage;
		} else {
			return "ETL process status: " + transactionStatus + " - " + completionStatus;
		}
	}
	
	/**
	 * Gets the execution duration in a human-readable format
	 */
	public String getFormattedDuration() {
		if (executionDurationSeconds == null) {
			return "N/A";
		}
		
		long seconds = executionDurationSeconds;
		if (seconds < 60) {
			return seconds + " seconds";
		} else if (seconds < 3600) {
			long minutes = seconds / 60;
			long remainingSeconds = seconds % 60;
			return minutes + " minutes " + remainingSeconds + " seconds";
		} else {
			long hours = seconds / 3600;
			long minutes = (seconds % 3600) / 60;
			return hours + " hours " + minutes + " minutes";
		}
	}
}
