# Uganda Reports ETL Module

## Overview

The Uganda Reports ETL Module is an OpenMRS module that implements HMIS 106A HIV Prevention, Care and Treatment Indicator Reporting. It provides ETL (Extract, Transform, Load) functionality using the Mamba ETL framework and integrates with Report Builder for generating standardized HIV indicators.

**Key Features:**
- HMIS 106A indicator reporting (7 sections, ~77 indicators)
- Mamba ETL integration for data processing
- Report Builder integration for indicator definition
- REST API for ETL monitoring and status tracking
- Automated ETL execution via scheduled tasks

---

## Documentation

| Document | Description |
|----------|-------------|
| **[REST API Documentation](docs/FRONTEND_API_DOCUMENTATION.md)** | Complete API reference for ETL monitoring endpoints |
| **[HMIS 106A Indicator Creation Guide](docs/HMIS_106A_INDICATOR_CREATION_GUIDE.md)** | Guide for creating and configuring HMIS 106A indicators |

---

## Quick Start

### Installation

1. Build the module:
```bash
mvn clean install
```

2. Upload the resulting `.omod` file via OpenMRS Administration > Manage Modules

Or, drop the `.omod` into the `~/.OpenMRS/modules` folder and restart OpenMRS.

### Initial Setup

After installation, configure the ETL:

1. Navigate to the module settings in OpenMRS
2. Configure database connections (source OpenMRS database, target ETL database)
3. Set ETL execution interval
4. Run the initial ETL via the "Setup Mamba ETL" scheduled task

---

## REST API

Two controllers expose the module's API (source: `omod/src/main/java/org/openmrs/module/ugandareportsetl/web/controller/`). All endpoints are **read-only GETs** returning JSON and require an authenticated OpenMRS session (HTTP Basic Auth). Triggering the ETL is deliberately *not* a REST operation here — use the **Setup Mamba ETL** scheduled task.

| Controller | Base path | Purpose |
|------------|-----------|---------|
| `MambaETLStatusRestController` | `/ws/rest/v1/ugandareportsetl/etl` | ETL monitoring |
| `UgandaReportsETLResourceController` | `/ws/rest/v1/ugandareportsetl` | Routed monitoring + module health |

### ETL Monitoring — `MambaETLStatusRestController`

Base URL: `/openmrs/ws/rest/v1/ugandareportsetl/etl`

#### `GET /etl/progress`

Current execution progress. While a run is `RUNNING`, progress is measured by **tables built vs expected**: `availableTables` is the live count of `mamba_*` tables, `expectedTables` is the count learned after the last completed run (persisted in the global property `ugandareportsetl.expectedMambaTables`, also editable in Administration → Maintenance → Settings). Until that property has been learned, the percentage falls back to an elapsed-time estimate.

```json
{
  "success": true,
  "isRunning": false,
  "isCompleted": true,
  "hasErrors": false,
  "statusMessage": "ETL process completed successfully",
  "formattedDuration": "14 minutes 9 seconds",
  "progressPercentage": 100.0,
  "currentStage": null,
  "data": {
    "id": 3,
    "startTime": "2026-08-28 05:03:19",
    "endTime": "2026-08-28 05:12:11",
    "executionDurationSeconds": 532,
    "completionStatus": "SUCCESS",
    "transactionStatus": "COMPLETED",
    "successOrErrorMessage": null,
    "availableTables": 107,
    "expectedTables": 107
  }
}
```

#### `GET /etl/recent?limit=N`

Recent execution history. `limit` defaults to `10`, is capped at `100`, and must be `≥ 1`.

```json
{ "success": true, "count": 2, "results": [ { "id": 3, "startTime": "...", "completionStatus": "SUCCESS", "transactionStatus": "COMPLETED", "...": "..." } ] }
```

#### `GET /etl/errors?limit=N`

Error-log entries from `_mamba_etl_error_log`. `limit` defaults to `50`, is capped at `500`, and must be `≥ 1`. Invalid `limit` returns `{ "success": false, "error": "limit must be >= 1" }`.

```json
{
  "success": true,
  "count": 1,
  "results": [ { "id": 36, "procedureName": "sp_data_processing_derived_vl_episode", "errorMessage": "Incorrect date value: ...", "errorCode": 1292, "sqlState": "22007", "errorTime": "2026-08-30 20:31:23" } ],
  "mostRecentError": { "procedureName": "...", "errorMessage": "...", "errorCode": 1292, "errorTime": "..." }
}
```

#### `GET /etl/settings`

Current ETL configuration from `_mamba_etl_user_settings`.

```json
{
  "success": true,
  "isConfigured": true,
  "data": {
    "id": 1,
    "openmrsDatabase": "bombo",
    "etlDatabase": "bombo",
    "conceptsLocale": "en",
    "tablePartitionNumber": 49,
    "incrementalModeSwitch": true,
    "automaticFlatteningModeSwitch": false,
    "etlIntervalSeconds": 3600,
    "incrementalModeSwitchCascaded": false,
    "lastEtlScheduleInsertId": 3
  }
}
```

#### `GET /etl/status`

Lightweight running check.

```json
{ "success": true, "isRunning": false, "message": "ETL process is not running", "lastExecution": { "...": "same shape as /etl/progress data" } }
```

### Module Root — `UgandaReportsETLResourceController`

Base URL: `/openmrs/ws/rest/v1/ugandareportsetl`

#### `GET /ugandareportsetl?q=<query>&limit=N`

A routed view over the same monitoring data. `q` is one of `progress`, `settings`, `errors`, `status`; **omitting `q` returns recent executions**. Each response echoes the query and a `timestamp`:

| `q` | Response body |
|-----|---------------|
| *(none)* | `{ "query": "recent", "limit": 10, "count": 10, "data": [ ...executions... ], "timestamp": "..." }` |
| `progress` | `{ "query": "progress", "data": { ...ETLProgressInfo... }, "timestamp": "..." }` |
| `settings` | `{ "query": "settings", "data": { ...ETLSettings... }, "timestamp": "..." }` |
| `errors` | `{ "query": "errors", "limit": 50, "count": 1, "data": [ ...ETLErrorLog... ], "timestamp": "..." }` |
| `status` | `{ "query": "status", "running": false, "progress": { ...when available... }, "timestamp": "..." }` |

#### `GET /ugandareportsetl/health`

```json
{ "status": "UP", "module": "ugandareportsetl", "description": "Uganda Reports ETL Module", "timestamp": "..." }
```

#### `GET /ugandareportsetl/status`

```json
{ "module": "ugandareportsetl", "status": "running", "message": "Uganda Reports ETL is running", "timestamp": "..." }
```

### Examples

```bash
# Progress with the table-based measure (Basic Auth)
curl -u admin:password \
  'http://localhost:8088/openmrs/ws/rest/v1/ugandareportsetl/etl/progress'

# Last 20 runs
curl -u admin:password \
  'http://localhost:8088/openmrs/ws/rest/v1/ugandareportsetl/etl/recent?limit=20'

# Routed equivalent of /etl/errors
curl -u admin:password \
  'http://localhost:8088/openmrs/ws/rest/v1/ugandareportsetl?q=errors&limit=5'
```

```javascript
// Get current ETL progress
fetch('/openmrs/ws/rest/v1/ugandareportsetl/etl/progress')
  .then(r => r.json())
  .then(data => console.log(data.progressPercentage + '% complete — tables ' +
    data.data.availableTables + '/' + data.data.expectedTables));
```

See [REST API Documentation](docs/FRONTEND_API_DOCUMENTATION.md) for the frontend-oriented API reference.

---

## HMIS 106A Indicators

### Sections Covered

| Section | Indicators | Status |
|---------|-----------|--------|
| **1A** HIV Care/ART Services | 52 | Partially implemented |
| **1B** Cervical Cancer Services | 6 | Partially implemented |
| **1C** ART Quarterly Cohort Analysis | 3 cohorts | Partially implemented |
| **1D** TPT Completion | 2 | Partially implemented |
| **1E** CrAg-Positive Cohort Monitoring | 3 | Partially implemented |
| **1F** Post-Exposure Prophylaxis | 6 | Planned |
| **1G** Pre-Exposure Prophylaxis | 5 | Planned |

See [HMIS 106A Indicator Creation Guide](docs/HMIS_106A_INDICATOR_CREATION_GUIDE.md) for detailed indicator definitions and creation instructions.

---

## Architecture

### ETL Framework (Mamba)

The module uses Mamba ETL for data processing:

- **Source Database:** OpenMRS production database
- **Target Database:** Analysis/ETL database (separate schema)
- **Processing:** Stored procedures for fact table generation
- **Scheduling:** Automated via OpenMRS scheduled tasks

### Report Builder Integration

Indicators are defined through Report Builder themes:

| Theme Code | Name | Source Table |
|------------|------|--------------|
| HC | HIV Care | `mamba_fact_encounter_hiv_art_card` |
| CX | Cervical Cancer | `mamba_fact_encounter_hiv_art_card` |
| TB | TB Services | `mamba_fact_encounter_hiv_art_card` |
| NCD | NCD Integration | `mamba_fact_encounter_hiv_art_card` |
| VL | Viral Load | `mamba_fact_patients_latest_viral_load` |
| ART | ART Summary | `mamba_fact_encounter_hiv_art_summary` |

---

## Scheduled Tasks

The module provides the following scheduled tasks:

| Task | Description | Usage |
|------|-------------|-------|
| **Setup Mamba ETL** | Initializes and runs the ETL process | Run manually or on schedule |
| **Run Analytics** | Executes analytics queries | Run on schedule for reports |

---

## Building from Source

**Requirements:**
- Java 1.8+
- Maven 3.x+

**Build Commands:**
```bash
# Clean build
mvn clean install

# Build and deploy to OpenMRS (if configured)
mvn clean install -P deploy-web
```

The `.omod` file will be in `omod/target/` after building.

---

## Code Formatting

This project uses Spotless for code formatting. Spotless runs automatically during the build process.

To format code manually:
```bash
mvn spotless:apply
```

To check formatting:
```bash
mvn spotless:check
```

---

## Database Configuration

### Default Database Settings

| Property | Default | Description |
|----------|---------|-------------|
| Source Database | `openmrs` | OpenMRS production database |
| Target Database | `analysis_db` | ETL data warehouse |
| ETL Interval | 3600 seconds | How often ETL runs |

### Database Access

For testing and development, you may need direct database access:
```bash
mysql -u openmrs -popenmrs -D stambrose
```

---

## Troubleshooting

### ETL Not Running

1. Check ETL status via API: `GET /ws/rest/v1/ugandareportsetl/etl/status`
2. Review error logs: `GET /ws/rest/v1/ugandareportsetl/etl/errors`
3. Verify database connectivity in module settings
4. Check scheduled task configuration

### Build Errors

- **webservices.rest dependency not found:** Ensure `webservices.rest-omod-common` dependency is correctly configured in `omod/pom.xml`
- **Compilation errors:** Run `mvn clean` and rebuild

### Missing Indicators

1. Verify ETL has completed successfully
2. Check Report Builder theme configuration
3. Ensure fact tables exist in target database
4. Review indicator SQL definitions

---

## Contributing

When contributing to this module:

1. Follow the existing code style (enforced by Spotless)
2. Add documentation for new indicators
3. Update API docs if adding new endpoints
4. Test ETL procedures before committing

---

## License

This module is licensed under the Mozilla Public License v2.0. See LICENSE file for details.

---

## Support

For issues or questions:
- Check the [REST API Documentation](docs/FRONTEND_API_DOCUMENTATION.md) for API issues
- Review the [HMIS 106A Indicator Creation Guide](docs/HMIS_106A_INDICATOR_CREATION_GUIDE.md) for indicator questions
- Open an issue in the project repository
