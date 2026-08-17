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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * REST Controller for Uganda Reports ETL module.
 * <p>
 * Provides comprehensive ETL monitoring and control endpoints through query parameters.
 * <p>
 * Base URL: /ws/rest/v1/ugandareportsetl
 */
@RestController
@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + "/ugandareportsetl")
public class UgandaReportsETLResourceController {

	private UgandaReportsETLService getService() {
		return Context.getService(UgandaReportsETLService.class);
	}

	/**
	 * Main ETL endpoint - routes to different responses based on query parameter
	 *
	 * @param q the query type: progress, settings, errors, status, or default (recent executions)
	 * @param limit optional limit for results (default: 10)
	 * @param response HTTP response
	 * @return JSON response based on query type
	 */
	@GetMapping
	public Object handleETLRequest(
			@RequestParam(value = "q", required = false) String q,
			@RequestParam(value = "limit", defaultValue = "10") int limit,
			HttpServletResponse response) throws IOException {

		UgandaReportsETLService service = getService();

		// Route based on query parameter
		if (q == null || q.isEmpty()) {
			// Default: return recent executions
			return getRecentExecutions(service, limit);
		}

		if ("progress".equalsIgnoreCase(q)) {
			return getProgress(service);
		} else if ("settings".equalsIgnoreCase(q)) {
			return getSettings(service);
		} else if ("errors".equalsIgnoreCase(q)) {
			return getErrors(service, limit);
		} else if ("status".equalsIgnoreCase(q)) {
			return getStatus(service);
		} else {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid query parameter: " + q);
			return null;
		}
	}

	/**
	 * Get current ETL progress
	 */
	private Map<String, Object> getProgress(UgandaReportsETLService service) {
		ETLProgressInfo progress = service.getETLProgress();
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("query", "progress");
		result.put("data", progress);
		result.put("timestamp", new Date());
		return result;
	}

	/**
	 * Get ETL settings
	 */
	private Map<String, Object> getSettings(UgandaReportsETLService service) {
		ETLSettings settings = service.getETLSettings();
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("query", "settings");
		result.put("data", settings);
		result.put("timestamp", new Date());
		return result;
	}

	/**
	 * Get ETL error logs
	 */
	private Map<String, Object> getErrors(UgandaReportsETLService service, int limit) {
		List<ETLErrorLog> errors = service.getETLErrorLogs(limit);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("query", "errors");
		result.put("limit", limit);
		result.put("count", errors.size());
		result.put("data", errors);
		result.put("timestamp", new Date());
		return result;
	}

	/**
	 * Get ETL status
	 */
	private Map<String, Object> getStatus(UgandaReportsETLService service) {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("query", "status");
		result.put("running", service.isETLRunning());
		result.put("timestamp", new Date());

		// Include current progress if available
		try {
			ETLProgressInfo progress = service.getETLProgress();
			if (progress != null) {
				result.put("progress", progress);
			}
		} catch (Exception e) {
			result.put("progressError", e.getMessage());
		}

		return result;
	}

	/**
	 * Get recent ETL executions (default endpoint)
	 */
	private Map<String, Object> getRecentExecutions(UgandaReportsETLService service, int limit) {
		List<ETLProgressInfo> executions = service.getRecentETLExecutions(limit);
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("query", "recent");
		result.put("limit", limit);
		result.put("count", executions.size());
		result.put("data", executions);
		result.put("timestamp", new Date());
		return result;
	}

	/**
	 * Simple health check endpoint
	 */
	@GetMapping(value = "/health")
	public Map<String, String> getHealth() {
		Map<String, String> result = new HashMap<String, String>();
		result.put("status", "UP");
		result.put("module", "ugandareportsetl");
		result.put("description", "Uganda Reports ETL Module");
		result.put("timestamp", new Date().toString());
		return result;
	}

	/**
	 * Simple status check endpoint
	 */
	@GetMapping(value = "/status")
	public Map<String, Object> getSimpleStatus() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("module", "ugandareportsetl");
		result.put("status", "running");
		result.put("message", "Uganda Reports ETL is running");
		result.put("timestamp", new Date().toString());
		return result;
	}
}
