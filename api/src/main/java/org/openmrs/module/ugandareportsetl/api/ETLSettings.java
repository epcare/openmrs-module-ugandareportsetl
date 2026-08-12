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

/**
 * Represents ETL configuration settings from the Mamba ETL user settings table.
 */
public class ETLSettings {
	
	private Integer id;
	
	private String openmrsDatabase;
	
	private String etlDatabase;
	
	private String conceptsLocale;
	
	private Integer tablePartitionNumber;
	
	private Boolean incrementalModeSwitch;
	
	private Boolean automaticFlatteningModeSwitch;
	
	private Integer etlIntervalSeconds;
	
	private Boolean incrementalModeSwitchCascaded;
	
	private Integer lastEtlScheduleInsertId;
	
	public ETLSettings() {
	}
	
	public ETLSettings(Integer id, String openmrsDatabase, String etlDatabase, String conceptsLocale,
	    Integer tablePartitionNumber, Boolean incrementalModeSwitch, Boolean automaticFlatteningModeSwitch,
	    Integer etlIntervalSeconds, Boolean incrementalModeSwitchCascaded, Integer lastEtlScheduleInsertId) {
		this.id = id;
		this.openmrsDatabase = openmrsDatabase;
		this.etlDatabase = etlDatabase;
		this.conceptsLocale = conceptsLocale;
		this.tablePartitionNumber = tablePartitionNumber;
		this.incrementalModeSwitch = incrementalModeSwitch;
		this.automaticFlatteningModeSwitch = automaticFlatteningModeSwitch;
		this.etlIntervalSeconds = etlIntervalSeconds;
		this.incrementalModeSwitchCascaded = incrementalModeSwitchCascaded;
		this.lastEtlScheduleInsertId = lastEtlScheduleInsertId;
	}
	
	// Getters and Setters
	public Integer getId() {
		return id;
	}
	
	public void setId(Integer id) {
		this.id = id;
	}
	
	public String getOpenmrsDatabase() {
		return openmrsDatabase;
	}
	
	public void setOpenmrsDatabase(String openmrsDatabase) {
		this.openmrsDatabase = openmrsDatabase;
	}
	
	public String getEtlDatabase() {
		return etlDatabase;
	}
	
	public void setEtlDatabase(String etlDatabase) {
		this.etlDatabase = etlDatabase;
	}
	
	public String getConceptsLocale() {
		return conceptsLocale;
	}
	
	public void setConceptsLocale(String conceptsLocale) {
		this.conceptsLocale = conceptsLocale;
	}
	
	public Integer getTablePartitionNumber() {
		return tablePartitionNumber;
	}
	
	public void setTablePartitionNumber(Integer tablePartitionNumber) {
		this.tablePartitionNumber = tablePartitionNumber;
	}
	
	public Boolean getIncrementalModeSwitch() {
		return incrementalModeSwitch;
	}
	
	public void setIncrementalModeSwitch(Boolean incrementalModeSwitch) {
		this.incrementalModeSwitch = incrementalModeSwitch;
	}
	
	public Boolean getAutomaticFlatteningModeSwitch() {
		return automaticFlatteningModeSwitch;
	}
	
	public void setAutomaticFlatteningModeSwitch(Boolean automaticFlatteningModeSwitch) {
		this.automaticFlatteningModeSwitch = automaticFlatteningModeSwitch;
	}
	
	public Integer getEtlIntervalSeconds() {
		return etlIntervalSeconds;
	}
	
	public void setEtlIntervalSeconds(Integer etlIntervalSeconds) {
		this.etlIntervalSeconds = etlIntervalSeconds;
	}
	
	public Boolean getIncrementalModeSwitchCascaded() {
		return incrementalModeSwitchCascaded;
	}
	
	public void setIncrementalModeSwitchCascaded(Boolean incrementalModeSwitchCascaded) {
		this.incrementalModeSwitchCascaded = incrementalModeSwitchCascaded;
	}
	
	public Integer getLastEtlScheduleInsertId() {
		return lastEtlScheduleInsertId;
	}
	
	public void setLastEtlScheduleInsertId(Integer lastEtlScheduleInsertId) {
		this.lastEtlScheduleInsertId = lastEtlScheduleInsertId;
	}
}
