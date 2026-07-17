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
package org.openmrs.module.ugandareportsetl.api.impl;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.api.APIException;
import org.openmrs.api.UserService;
import org.openmrs.api.context.Context;
import org.openmrs.api.impl.BaseOpenmrsService;
import org.openmrs.module.mambacore.api.FlattenDatabaseService;
import org.openmrs.module.ugandareportsetl.api.UgandaReportsETLService;
import org.openmrs.module.ugandareportsetl.api.dao.UgandaReportsETLDao;
import org.openmrs.util.OpenmrsUtil;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Properties;

/**
 * Default implementation of {@link UgandaReportsETLService}.
 */
public class UgandaReportsETLServiceImpl extends BaseOpenmrsService implements UgandaReportsETLService {
	
	protected final Log log = LogFactory.getLog(this.getClass());
	
	private UgandaReportsETLDao dao;
	
	/**
	 * Injected in moduleApplicationContext.xml
	 */
	public void setDao(UgandaReportsETLDao dao) {
		this.dao = dao;
	}
	
	@Override
	public void addMambaetlProperties() throws APIException {
		try {
			log.info("Adding Mamba ETL properties...");
			
			File appDataDir = new File(OpenmrsUtil.getApplicationDataDirectory());
			File propertiesFile = new File(appDataDir, "openmrs-runtime.properties");
			Properties properties = new Properties();
			
			FileInputStream in = null;
			try {
				in = new FileInputStream(propertiesFile);
				properties.load(in);
			}
			catch (IOException e) {
				log.error("Failed to read properties file: " + e.getMessage());
				return;
			}
			finally {
				if (in != null) {
					try {
						in.close();
					}
					catch (IOException e) {
						log.error("Failed to close input stream: " + e.getMessage());
					}
				}
			}
			
			String connectionUrl = properties.getProperty("connection.url");
			String dbName = null;
			
			if (connectionUrl != null && connectionUrl.contains("/")) {
				try {
					int lastSlash = connectionUrl.lastIndexOf('/');
					int questionMark = connectionUrl.indexOf('?', lastSlash);
					if (lastSlash != -1 && questionMark != -1) {
						dbName = connectionUrl.substring(lastSlash + 1, questionMark);
					} else if (lastSlash != -1) {
						dbName = connectionUrl.substring(lastSlash + 1);
					}
				}
				catch (Exception e) {
					log.error("Error parsing connection.url: " + e.getMessage());
				}
			}
			
			if (dbName == null || dbName.isEmpty()) {
				dbName = "openmrs";
				log.warn("Using fallback database name: " + dbName);
			}
			
			String username = properties.getProperty("connection.username", "openmrs");
			if (username.isEmpty()) {
				username = "openmrs";
				log.warn("Using fallback username: " + username);
			}
			
			String password = properties.getProperty("connection.password", "openmrs");
			if (password.isEmpty()) {
				password = "openmrs";
				log.warn("Using fallback password");
			}
			
			setPropertyIfAbsent(properties, "mambaetl.analysis.db.openmrs_database", dbName);
			setPropertyIfAbsent(properties, "mambaetl.analysis.db.etl_database", dbName);
			setPropertyIfAbsent(properties, "mambaetl.analysis.db.username", username);
			setPropertyIfAbsent(properties, "mambaetl.analysis.db.password", password);
			setPropertyIfAbsent(properties, "mambaetl.analysis.columns", "49");
			setPropertyIfAbsent(properties, "mambaetl.analysis.incremental_mode", "1");
			setPropertyIfAbsent(properties, "mambaetl.analysis.etl_interval", "3600");
			setPropertyIfAbsent(properties, "mambaetl.analysis.locale", "en");
			setPropertyIfAbsent(properties, "mambaetl.analysis.automated_flattening", "0");
			
			FileOutputStream out = null;
			try {
				out = new FileOutputStream(propertiesFile);
				properties.store(out, "Updated with MambaETL related properties (added only if missing)");
				log.info("MambaETL properties checked and updated successfully.");
			}
			catch (IOException e) {
				log.error("Failed to write properties file: " + e.getMessage());
			}
			finally {
				if (out != null) {
					try {
						out.close();
					}
					catch (IOException e) {
						log.error("Failed to close output stream: " + e.getMessage());
					}
				}
			}
		}
		catch (Exception e) {
			log.error("Error adding Mamba ETL properties", e);
			throw new APIException("Error adding Mamba ETL properties", e);
		}
	}
	
	@Override
	public void setupMambaETL() throws APIException {
		try {
			log.info("Setting up Mamba ETL infrastructure...");
			
			FlattenDatabaseService flattenDatabaseService = Context.getService(FlattenDatabaseService.class);
			flattenDatabaseService.setupEtl();
			
			log.info("Mamba ETL infrastructure setup completed successfully");
		}
		catch (Exception e) {
			log.error("Error setting up Mamba ETL infrastructure", e);
			throw new APIException("Error setting up Mamba ETL infrastructure", e);
		}
	}
	
	@Override
	public void executeFlatteningScript() throws APIException {
		try {
			log.info("Executing Mamba ETL flattening script...");
			
			dao.executeFlatteningScript();
			
			log.info("Mamba ETL flattening script completed successfully");
		}
		catch (Exception e) {
			log.error("Error executing Mamba ETL flattening script", e);
			throw new APIException("Error executing Mamba ETL flattening script", e);
		}
	}
	
	/**
	 * Helper method to set a property only if it's not already present
	 */
	private static void setPropertyIfAbsent(Properties properties, String key, String value) {
		if (!properties.containsKey(key) || properties.getProperty(key) == null
		        || properties.getProperty(key).trim().isEmpty()) {
			properties.setProperty(key, value);
		}
	}
}
