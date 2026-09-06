/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.ugandareportsetl.web.controller;

import org.openmrs.api.context.Context;
import org.openmrs.module.ugandareportsetl.api.ETLErrorLog;
import org.openmrs.module.ugandareportsetl.api.ETLProgressInfo;
import org.openmrs.module.ugandareportsetl.api.ETLSettings;
import org.openmrs.module.ugandareportsetl.api.UgandaReportsETLService;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Spring REST Controller for Uganda Reports ETL monitoring.
 * <p>
 * Base URL: /ws/rest/v1/ugandareportsetl/etl
 */
@RestController
@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/ugandareportsetl/etl")
public class MambaETLStatusRestController {
	
	private static final Logger log = LoggerFactory.getLogger(MambaETLStatusRestController.class);
	
	private static final Integer DEFAULT_RECENT_LIMIT = 10;
	
	private static final Integer DEFAULT_ERROR_LIMIT = 50;
	
	private UgandaReportsETLService getService() {
		return Context.getService(UgandaReportsETLService.class);
	}
	
	/**
	 * Get current ETL execution progress and status.
	 * <p>
	 * GET parameters: None
	 * 
	 * @return Map containing current ETL progress information
	 */
	@RequestMapping(value = "/progress", method = RequestMethod.GET)
	public Map<String, Object> getETLProgress() {
		try {
			ETLProgressInfo progress = getService().getETLProgress();

			Map<String, Object> response = new HashMap<>();
			if (progress != null) {
				response.put("success", true);
				response.put("data", progress);
				response.put("isRunning", progress.isRunning());
				response.put("isCompleted", progress.isCompleted());
				response.put("hasErrors", progress.hasErrors());
				response.put("statusMessage", progress.getStatusMessage());
				response.put("formattedDuration", progress.getFormattedDuration());
				response.put("progressPercentage", progress.getProgressPercentage());
				response.put("currentStage", progress.getCurrentStage());
			} else {
				response.put("success", true);
				response.put("data", null);
				response.put("message", "No ETL executions found");
			}
			return response;

		} catch (Exception e) {
			log.error("Error fetching ETL progress", e);
			return buildErrorResponse("An internal error occurred while fetching ETL progress");
		}
	}
	
	/**
	 * Get recent ETL execution history.
	 * <p>
	 * GET parameters: - limit (optional): Number of recent executions to return, defaults to 10
	 * 
	 * @param limit Number of recent executions to return
	 * @return Map containing list of recent ETL executions
	 */
	@RequestMapping(value = "/recent", method = RequestMethod.GET)
	public Map<String, Object> getRecentETLExecutions(
			@RequestParam(value = "limit", required = false, defaultValue = "10") Integer limit) {

		try {
			// Validate limit parameter
			if (limit != null && limit < 1) {
				throw new IllegalArgumentException("limit must be >= 1");
			}
			if (limit != null && limit > 100) {
				limit = 100; // Cap at 100 to prevent excessive responses
			}

			List<ETLProgressInfo> recentExecutions = getService().getRecentETLExecutions(limit);

			Map<String, Object> response = new HashMap<>();
			response.put("success", true);
			response.put("count", recentExecutions.size());
			response.put("results", recentExecutions);
			return response;

		} catch (IllegalArgumentException e) {
			log.warn("Invalid request parameters: {}", e.getMessage());
			return buildErrorResponse(e.getMessage());
		} catch (Exception e) {
			log.error("Error fetching recent ETL executions", e);
			return buildErrorResponse("An internal error occurred while fetching recent ETL executions");
		}
	}
	
	/**
	 * Get ETL error log entries.
	 * <p>
	 * GET parameters: - limit (optional): Number of error entries to return, defaults to 50
	 * 
	 * @param limit Number of error entries to return
	 * @return Map containing list of error log entries
	 */
	@RequestMapping(value = "/errors", method = RequestMethod.GET)
	public Map<String, Object> getETLErrors(
			@RequestParam(value = "limit", required = false, defaultValue = "50") Integer limit) {

		try {
			// Validate limit parameter
			if (limit != null && limit < 1) {
				throw new IllegalArgumentException("limit must be >= 1");
			}
			if (limit != null && limit > 500) {
				limit = 500; // Cap at 500 for error logs
			}

			List<ETLErrorLog> errorLogs = getService().getETLErrorLogs(limit);

			Map<String, Object> response = new HashMap<>();
			response.put("success", true);
			response.put("count", errorLogs.size());
			response.put("results", errorLogs);

			// Add summary of most recent error if available
			if (!errorLogs.isEmpty()) {
				ETLErrorLog mostRecent = errorLogs.get(0);
				Map<String, Object> summary = new HashMap<>();
				summary.put("procedureName", mostRecent.getProcedureName());
				summary.put("errorMessage", mostRecent.getErrorMessage());
				summary.put("errorCode", mostRecent.getErrorCode());
				summary.put("errorTime", mostRecent.getErrorTime());
				response.put("mostRecentError", summary);
			}

			return response;

		} catch (IllegalArgumentException e) {
			log.warn("Invalid request parameters: {}", e.getMessage());
			return buildErrorResponse(e.getMessage());
		} catch (Exception e) {
			log.error("Error fetching ETL error logs", e);
			return buildErrorResponse("An internal error occurred while fetching ETL error logs");
		}
	}
	
	/**
	 * Get current ETL configuration settings.
	 * <p>
	 * GET parameters: None
	 * 
	 * @return Map containing current ETL settings
	 */
	@RequestMapping(value = "/settings", method = RequestMethod.GET)
	public Map<String, Object> getETLSettings() {
		try {
			ETLSettings settings = getService().getETLSettings();

			Map<String, Object> response = new HashMap<>();
			if (settings != null) {
				response.put("success", true);
				response.put("data", settings);
				response.put("isConfigured", true);
			} else {
				response.put("success", true);
				response.put("data", null);
				response.put("isConfigured", false);
				response.put("message", "ETL settings not configured");
			}
			return response;

		} catch (Exception e) {
			log.error("Error fetching ETL settings", e);
			return buildErrorResponse("An internal error occurred while fetching ETL settings");
		}
	}
	
	/**
	 * Check if ETL is currently running.
	 * <p>
	 * GET parameters: None
	 * 
	 * @return Map containing ETL running status
	 */
	@RequestMapping(value = "/status", method = RequestMethod.GET)
	public Map<String, Object> getETLStatus() {
		try {
			boolean isRunning = getService().isETLRunning();
			ETLProgressInfo progress = getService().getETLProgress();

			Map<String, Object> response = new HashMap<>();
			response.put("success", true);
			response.put("isRunning", isRunning);
			response.put("message", isRunning ? "ETL process is currently running" : "ETL process is not running");

			if (progress != null) {
				response.put("lastExecution", progress);
			}

			return response;

		} catch (Exception e) {
			log.error("Error checking ETL status", e);
			return buildErrorResponse("An internal error occurred while checking ETL status");
		}
	}

	/**
	 * List all mamba_* tables in the ETL database.
	 * <p>
	 * GET parameters: None. Row counts come from information_schema and are approximate for
	 * InnoDB; fetch /etl/tables/{tableName}/data for the exact total of a single table.
	 *
	 * @return Map with the table list, each entry carrying tableName, tableRows, engine,
	 *         createTime and a category (DIMENSION / SOURCE / FLAT / FACT / CONFIG)
	 */
	@RequestMapping(value = "/tables", method = RequestMethod.GET)
	public Map<String, Object> getEtlTables() {
		try {
			List<Map<String, Object>> tables = getService().getEtlTables();

			Map<String, Object> response = new HashMap<>();
			response.put("success", true);
			response.put("count", tables.size());
			response.put("approximateRowCounts", true);
			response.put("results", tables);
			return response;

		} catch (Exception e) {
			log.error("Error listing ETL tables", e);
			return buildErrorResponse("An internal error occurred while listing ETL tables");
		}
	}

	/**
	 * Fetch a page of rows from one mamba_* table.
	 * <p>
	 * GET parameters: - limit (optional): page size, defaults to 50, capped at 500 - offset
	 * (optional): row offset, defaults to 0
	 * <p>
	 * Rows are ordered by the table's primary key (or first column when no key exists) so pages
	 * stay deterministic. Only existing mamba_* tables are addressable; anything else returns
	 * { "success": false, "error": "..." }.
	 *
	 * @return Map with totalRows, pagination echo, column metadata and the rows
	 */
	@RequestMapping(value = "/tables/{tableName}/data", method = RequestMethod.GET)
	public Map<String, Object> getEtlTableData(
			@PathVariable("tableName") String tableName,
			@RequestParam(value = "limit", required = false, defaultValue = "50") Integer limit,
			@RequestParam(value = "offset", required = false, defaultValue = "0") Integer offset) {

		try {
			if (limit == null || limit < 1) {
				return buildErrorResponse("limit must be >= 1");
			}
			if (limit > 500) {
				limit = 500; // Cap page size
			}
			if (offset == null || offset < 0) {
				return buildErrorResponse("offset must be >= 0");
			}

			Map<String, Object> data = getService().getEtlTableData(tableName, limit, offset);

			Map<String, Object> response = new HashMap<>();
			response.put("success", true);
			response.putAll(data);
			return response;

		} catch (Exception e) {
			log.error("Error fetching data from ETL table " + tableName, e);
			return buildErrorResponse(e.getMessage());
		}
	}
	
	/**
	 * Build error response.
	 */
	private Map<String, Object> buildErrorResponse(String message) {
		Map<String, Object> response = new HashMap<>();
		response.put("success", false);
		response.put("error", message);
		return response;
	}
}
