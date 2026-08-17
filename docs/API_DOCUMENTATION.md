# Uganda Reports ETL - REST API Documentation

**Module:** ugandareportsetl  
**Base URL:** `/ws/rest/v1/ugandareportsetl`  
**Authentication:** OpenMRS session authentication (required)  
**Version:** 1.0.0-SNAPSHOT  

---

## Overview

The Uganda Reports ETL module provides REST APIs for monitoring and managing ETL (Extract, Transform, Load) processes. These endpoints allow frontend applications to track ETL execution status, view error logs, and monitor configuration settings.

---

## Authentication

All endpoints require a valid OpenMRS session. Include the session cookie with requests:

```javascript
fetch('/openmrs/ws/rest/v1/ugandareportsetl/health', {
  credentials: 'include'  // Include session cookies
});
```

---

## Endpoints

### 1. Health Check

**Endpoint:** `GET /ws/rest/v1/ugandareportsetl/health`

**Description:** Basic health check for the ETL module.

**Response:**
```json
{
  "status": "UP",
  "module": "ugandareportsetl",
  "description": "Uganda Reports ETL Module",
  "timestamp": "2026-08-15 10:30:45"
}
```

**Example:**
```bash
curl http://localhost:8088/openmrs/ws/rest/v1/ugandareportsetl/health
```

---

### 2. Simple Status

**Endpoint:** `GET /ws/rest/v1/ugandareportsetl/status`

**Description:** Simple status endpoint for quick module availability check.

**Response:**
```json
{
  "module": "ugandareportsetl",
  "status": "running",
  "message": "Uganda Reports ETL is running",
  "timestamp": "2026-08-15 10:30:45"
}
```

---

### 3. Main ETL Endpoint

**Endpoint:** `GET /ws/rest/v1/ugandareportsetl`

**Description:** Main endpoint with query-based routing for different ETL operations.

#### Query Parameters

| Query | Description | Default Limit |
|-------|-------------|---------------|
| `(none)` | Recent ETL executions | 10 |
| `q=progress` | Current ETL progress | - |
| `q=settings` | ETL configuration settings | - |
| `q=errors` | ETL error logs | 10 |
| `q=status` | ETL running status | - |

**Optional Parameters:**
- `limit` - Number of results (default: 10, max: 100)

---

### 3.1 Recent Executions (Default)

**Endpoint:** `GET /ws/rest/v1/ugandareportsetl` or `GET /ws/rest/v1/ugandareportsetl?limit=20`

**Description:** Returns the most recent ETL execution records.

**Response:**
```json
{
  "query": "recent",
  "limit": 10,
  "count": 5,
  "data": [
    {
      "id": 123,
      "startTime": "2026-08-15T09:00:00",
      "endTime": "2026-08-15T09:15:30",
      "nextSchedule": "2026-08-15T10:00:00",
      "executionDurationSeconds": 930,
      "missedScheduleBySeconds": null,
      "completionStatus": "SUCCESS",
      "transactionStatus": "COMPLETED",
      "successOrErrorMessage": "ETL completed successfully",
      "currentStage": "Finalizing ETL process",
      "progressPercentage": 100.0
    }
  ],
  "timestamp": "2026-08-15T10:30:45"
}
```

**ETLProgressInfo Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | Integer | ETL execution ID |
| `startTime` | DateTime | Execution start time |
| `endTime` | DateTime | Execution end time (null if running) |
| `nextSchedule` | DateTime | Next scheduled execution time |
| `executionDurationSeconds` | Long | Duration in seconds |
| `missedScheduleBySeconds` | Long | Seconds past scheduled start (null if on time) |
| `completionStatus` | String | SUCCESS, ERROR, or IN_PROGRESS |
| `transactionStatus` | String | RUNNING, COMPLETED, or FAILED |
| `successOrErrorMessage` | String | Status message or error description |
| `currentStage` | String | Current processing stage (calculated) |
| `progressPercentage` | Double | Estimated progress percentage (calculated) |

---

### 3.2 ETL Progress

**Endpoint:** `GET /ws/rest/v1/ugandareportsetl?q=progress`

**Description:** Returns detailed information about the current or most recent ETL execution.

**Response:**
```json
{
  "query": "progress",
  "data": {
    "id": 456,
    "startTime": "2026-08-15T10:00:00",
    "endTime": null,
    "nextSchedule": "2026-08-15T11:00:00",
    "executionDurationSeconds": 1800,
    "missedScheduleBySeconds": null,
    "completionStatus": "IN_PROGRESS",
    "transactionStatus": "RUNNING",
    "successOrErrorMessage": null,
    "currentStage": "Processing HTS data",
    "progressPercentage": 65.5
  },
  "timestamp": "2026-08-15T10:30:45"
}
```

**Computed Methods (Java-side, not in JSON):**
- `isRunning()` - Returns true if `transactionStatus === "RUNNING"`
- `isCompleted()` - Returns true if `transactionStatus === "COMPLETED"` AND `completionStatus === "SUCCESS"`
- `hasErrors()` - Returns true if `completionStatus === "ERROR"`
- `getStatusMessage()` - Human-readable status message
- `getFormattedDuration()` - Human-readable duration (e.g., "15 minutes 30 seconds")

---

### 3.3 ETL Settings

**Endpoint:** `GET /ws/rest/v1/ugandareportsetl?q=settings`

**Description:** Returns the current ETL configuration settings from the `_mamba_etl_user_settings` table.

**Response:**
```json
{
  "query": "settings",
  "data": {
    "id": 1,
    "openmrsDatabase": "openmrs",
    "etlDatabase": "stambrose",
    "conceptsLocale": "en",
    "tablePartitionNumber": 49,
    "incrementalModeSwitch": true,
    "automaticFlatteningModeSwitch": false,
    "etlIntervalSeconds": 3600,
    "incrementalModeSwitchCascaded": true,
    "lastEtlScheduleInsertId": 12345
  },
  "timestamp": "2026-08-15T10:30:45"
}
```

**ETLSettings Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | Integer | Settings record ID |
| `openmrsDatabase` | String | Source OpenMRS database name |
| `etlDatabase` | String | Target ETL database name |
| `conceptsLocale` | String | Locale for concept mappings (e.g., "en") |
| `tablePartitionNumber` | Integer | Number of table partitions for ETL |
| `incrementalModeSwitch` | Boolean | Enable incremental ETL mode |
| `automaticFlatteningModeSwitch` | Boolean | Enable automatic data flattening |
| `etlIntervalSeconds` | Integer | ETL schedule interval in seconds (3600 = hourly) |
| `incrementalModeSwitchCascaded` | Boolean | Cascade incremental mode setting |
| `lastEtlScheduleInsertId` | Integer | Last inserted schedule record ID |

---

### 3.4 Error Logs

**Endpoint:** `GET /ws/rest/v1/ugandareportsetl?q=errors&limit=50`

**Description:** Returns recent error log entries from the `_mamba_etl_error_log` table.

**Response:**
```json
{
  "query": "errors",
  "limit": 50,
  "count": 3,
  "data": [
    {
      "id": 789,
      "procedureName": "sp_data_processing_derived_art",
      "errorMessage": "Duplicate entry '12345' for key 'PRIMARY'",
      "errorCode": 1062,
      "sqlState": "23000",
      "errorTime": "2026-08-15T09:45:00"
    },
    {
      "id": 788,
      "procedureName": "sp_mamba_data_processing_etl",
      "errorMessage": "Table '_mamba_etl.etl_schedule' doesn't exist",
      "errorCode": 1146,
      "sqlState": "HY000",
      "errorTime": "2026-08-15T09:30:00"
    }
  ],
  "timestamp": "2026-08-15T10:30:45"
}
```

**ETLErrorLog Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | Integer | Error log entry ID |
| `procedureName` | String | Name of the stored procedure that failed |
| `errorMessage` | String | Error message text |
| `errorCode` | Integer | Database error code (MySQL error number) |
| `sqlState` | String | SQL state code (e.g., "23000", "HY000") |
| `errorTime` | DateTime | When the error occurred |

---

### 3.5 ETL Status

**Endpoint:** `GET /ws/rest/v1/ugandareportsetl?q=status`

**Description:** Returns a concise status indicating whether the ETL is currently running.

**Response:**
```json
{
  "query": "status",
  "running": true,
  "timestamp": "2026-08-15T10:30:45",
  "progress": {
    "id": 456,
    "transactionStatus": "RUNNING",
    "progressPercentage": 65.5,
    "currentStage": "Processing HTS data"
  }
}
```

**Note:** If the ETL is not running, `progress` will be null or represent the last completed execution.

---

## HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Bad Request (invalid query parameter) |
| 401 | Unauthorized (not authenticated) |
| 404 | Not Found |
| 500 | Internal Server Error |

---

## Error Response Format

```json
{
  "error": "Invalid query parameter: invalid_query",
  "status": 400
}
```

---

## Data Source Tables

The API queries the following Mamba ETL tables:

| Table | Purpose | Used By Endpoint |
|-------|---------|------------------|
| `_mamba_etl_schedule` | ETL execution records | progress, status, recent executions |
| `_mamba_etl_error_log` | Error log entries | errors |
| `_mamba_etl_user_settings` | Configuration settings | settings |

---

## Current Stage Calculation

When the ETL is running, the service calculates `currentStage` and `progressPercentage` based on elapsed time:

| Elapsed Time | Stage | Estimated % |
|--------------|-------|-------------|
| 0-30s | Initializing ETL process | 0-3% |
| 30-60s | Dropping existing fact tables | 3-7% |
| 60-180s | Processing OPD attendance data | 7-20% |
| 180-240s | Processing diagnosis data | 20-27% |
| 240-300s | Processing transfer data | 27-33% |
| 300-360s | Processing non-suppressed data | 33-40% |
| 360-480s | Processing HIV ART card data | 40-53% |
| 480-600s | Processing IIT data | 53-67% |
| 600-720s | Processing HTS data | 67-80% |
| 720-840s | Processing ANC data | 80-93% |
| 840s+ | Finalizing ETL process | 93-100% |

**Total estimated duration:** 900 seconds (15 minutes)

*Note: These durations are estimates and should be adjusted based on actual performance data.*

---

## ETL Processing Stages

The ETL executes the following stored procedures in order:

1. `sp_mamba_system_drop_fact_tables` - Drop existing fact tables
2. `sp_data_processing_derived_opd_attendance` - OPD attendance
3. `sp_fact_encounter_diagnosis` - Diagnosis data
4. `sp_data_processing_derived_transfers` - Transfer data
5. `sp_data_processing_derived_non_suppressed` - Non-suppressed patients
6. `sp_data_processing_derived_hiv_art_card` - HIV ART card
7. `sp_data_processing_arv_orders` - ARV orders
8. `sp_data_processing_derived_IIT` - IIT data
9. `sp_data_processing_derived_regimen_change` - Regimen changes
10. `sp_data_processing_derived_vl_request` - Viral load requests
11. `sp_data_processing_derived_hts_card_v2` - HTS card v2
12. `sp_data_processing_derived_hts_contact_tracing` - HTS contact tracing
13. `sp_data_processing_derived_hiv_self_testing` - HIV self-testing
14. `sp_data_processing_derived_anc` - ANC data
15. `sp_data_processing_derived_cacx_screening` - CACX screening
16. `sp_data_processing_derived_cacx_treatment` - CACX treatment
17. `sp_data_processing_derived_vl_episode` - Viral load episodes

---

## Frontend Integration Example

```typescript
const BASE_URL = '/openmrs/ws/rest/v1/ugandareportsetl';

// Health check
async function checkHealth() {
  const response = await fetch(`${BASE_URL}/health`, { credentials: 'include' });
  return await response.json();
}

// Get recent executions
async function getRecentExecutions(limit = 10) {
  const response = await fetch(`${BASE_URL}?limit=${limit}`, { credentials: 'include' });
  return await response.json();
}

// Get ETL progress
async function getETLProgress() {
  const response = await fetch(`${BASE_URL}?q=progress`, { credentials: 'include' });
  return await response.json();
}

// Get ETL settings
async function getETLSettings() {
  const response = await fetch(`${BASE_URL}?q=settings`, { credentials: 'include' });
  return await response.json();
}

// Get error logs
async function getErrorLogs(limit = 50) {
  const response = await fetch(`${BASE_URL}?q=errors&limit=${limit}`, { credentials: 'include' });
  return await response.json();
}

// Get ETL status
async function getETLStatus() {
  const response = await fetch(`${BASE_URL}?q=status`, { credentials: 'include' });
  return await response.json();
}

// Polling example for real-time updates
function pollETLStatus(callback: (data: any) => void, interval: number = 30000) {
  const poll = async () => {
    try {
      const data = await getETLStatus();
      callback(data);
      
      // Continue polling if ETL is running
      if (data.running) {
        setTimeout(poll, interval);
      }
    } catch (error) {
      console.error('Polling error:', error);
      setTimeout(poll, interval);
    }
  };
  
  poll();
}
```

---

## Best Practices

1. **Polling Intervals:**
   - Status check: every 30 seconds
   - Progress updates: every 15-30 seconds during execution
   - Error logs: every 60 seconds
   - Settings: cache on load (changes infrequently)

2. **Error Handling:**
   - Always handle network errors gracefully
   - Show loading states during API calls
   - Display meaningful error messages to users

3. **Performance:**
   - Implement client-side rate limiting
   - Cache settings and configuration data
   - Stop polling when ETL is not running

4. **Authentication:**
   - Ensure session is valid before making requests
   - Handle 401 Unauthorized responses (redirect to login)
   - Use `credentials: 'include'` for cookie-based auth

---

## Module Information

- **Module Name:** ugandareportsetl
- **Package:** `org.openmrs.module.ugandareportsetl`
- **Controller:** `UgandaReportsETLResourceController`
- **Service:** `UgandaReportsETLService`
- **Required OpenMRS Version:** 2.8.7+
- **Required REST Web Services:** 2.28.0+

---

## Support

For issues or questions:
1. Check OpenMRS logs for ETL module errors
2. Verify module is started in OpenMRS administration
3. Test endpoints using curl/Postman first
4. Check network tab in browser developer tools
5. Verify Mamba ETL tables exist in database

---

*Last Updated: 2026-08-15*
*Document Version: 1.0*