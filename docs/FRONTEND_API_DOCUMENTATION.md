# Uganda Reports ETL - REST API Documentation

## Overview

The Uganda Reports ETL module provides REST endpoints for monitoring ETL (Extract, Transform, Load) processes, viewing execution history, error logs, and configuration settings.

**Base URL:** `/ws/rest/v1/ugandareportsetl/etl`

**Authentication:** Requires OpenMRS session authentication (same as other OpenMRS REST endpoints)

---

## Endpoints

### 1. Get ETL Progress

Get the current ETL execution status and progress.

**Endpoint:** `GET /ws/rest/v1/ugandareportsetl/etl/progress`

**Parameters:** None

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 123,
    "startTime": "2026-08-15T10:00:00.000Z",
    "endTime": "2026-08-15T10:15:30.000Z",
    "nextSchedule": "2026-08-15T11:00:00.000Z",
    "executionDurationSeconds": 930,
    "missedScheduleBySeconds": 0,
    "completionStatus": "SUCCESS",
    "transactionStatus": "COMPLETED",
    "successOrErrorMessage": null,
    "progressPercentage": 100.0,
    "currentStage": "Finalization"
  },
  "isRunning": false,
  "isCompleted": true,
  "hasErrors": false,
  "statusMessage": "ETL process completed successfully",
  "formattedDuration": "15 minutes 30 seconds",
  "progressPercentage": 100.0,
  "currentStage": "Finalization"
}
```

**When no ETL executions found:**
```json
{
  "success": true,
  "data": null,
  "message": "No ETL executions found"
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "An internal error occurred while fetching ETL progress"
}
```

---

### 2. Get Recent ETL Executions

Get recent ETL execution history.

**Endpoint:** `GET /ws/rest/v1/ugandareportsetl/etl/recent`

**Parameters:**
| Name | Type | Required | Default | Max | Description |
|------|------|----------|---------|-----|-------------|
| limit | integer | No | 10 | 100 | Number of executions to return |

**Request Example:**
```
GET /ws/rest/v1/ugandareportsetl/etl/recent?limit=20
```

**Response:**
```json
{
  "success": true,
  "count": 20,
  "results": [
    {
      "id": 123,
      "startTime": "2026-08-15T10:00:00.000Z",
      "endTime": "2026-08-15T10:15:30.000Z",
      "nextSchedule": "2026-08-15T11:00:00.000Z",
      "executionDurationSeconds": 930,
      "missedScheduleBySeconds": 0,
      "completionStatus": "SUCCESS",
      "transactionStatus": "COMPLETED",
      "successOrErrorMessage": null,
      "progressPercentage": 100.0,
      "currentStage": "Finalization"
    }
    // ... more executions
  ]
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "limit must be >= 1"
}
```

---

### 3. Get ETL Error Logs

Get ETL error log entries for troubleshooting.

**Endpoint:** `GET /ws/rest/v1/ugandareportsetl/etl/errors`

**Parameters:**
| Name | Type | Required | Default | Max | Description |
|------|------|----------|---------|-----|-------------|
| limit | integer | No | 50 | 500 | Number of error entries to return |

**Request Example:**
```
GET /ws/rest/v1/ugandareportsetl/etl/errors?limit=100
```

**Response:**
```json
{
  "success": true,
  "count": 5,
  "results": [
    {
      "id": 456,
      "procedureName": "sp_fact_encounter_hiv_art_card",
      "errorMessage": "Deadlock found when trying to get lock",
      "errorCode": 1213,
      "sqlState": "40001",
      "errorTime": "2026-08-15T10:05:23.000Z"
    }
  ],
  "mostRecentError": {
    "procedureName": "sp_fact_encounter_hiv_art_card",
    "errorMessage": "Deadlock found when trying to get lock",
    "errorCode": 1213,
    "errorTime": "2026-08-15T10:05:23.000Z"
  }
}
```

---

### 4. Get ETL Settings

Get current ETL configuration settings.

**Endpoint:** `GET /ws/rest/v1/ugandareportsetl/etl/settings`

**Parameters:** None

**Response (when configured):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "openmrsDatabase": "openmrs",
    "etlDatabase": "analysis_db",
    "conceptsLocale": "en",
    "tablePartitionNumber": 10,
    "incrementalModeSwitch": true,
    "automaticFlatteningModeSwitch": true,
    "etlIntervalSeconds": 3600,
    "incrementalModeSwitchCascaded": true,
    "lastEtlScheduleInsertId": 12345
  },
  "isConfigured": true
}
```

**Response (when not configured):**
```json
{
  "success": true,
  "data": null,
  "isConfigured": false,
  "message": "ETL settings not configured"
}
```

---

### 5. Get ETL Status

Check if the ETL process is currently running.

**Endpoint:** `GET /ws/rest/v1/ugandareportsetl/etl/status`

**Parameters:** None

**Response:**
```json
{
  "success": true,
  "isRunning": true,
  "message": "ETL process is currently running",
  "lastExecution": {
    "id": 123,
    "startTime": "2026-08-15T10:00:00.000Z",
    "endTime": null,
    "nextSchedule": "2026-08-15T11:00:00.000Z",
    "executionDurationSeconds": 300,
    "completionStatus": "IN_PROGRESS",
    "transactionStatus": "RUNNING",
    "successOrErrorMessage": null,
    "progressPercentage": 35.5,
    "currentStage": "Processing ART Cards"
  }
}
```

---

## Data Models

### ETLProgressInfo

Represents the progress and status of an ETL execution.

| Field | Type | Description |
|-------|------|-------------|
| id | Integer | Unique identifier for the execution |
| startTime | DateTime | When the ETL execution started |
| endTime | DateTime | When the ETL execution ended (null if running) |
| nextSchedule | DateTime | When the next ETL is scheduled |
| executionDurationSeconds | Long | How long the execution took (in seconds) |
| missedScheduleBySeconds | Long | How late the execution started (in seconds) |
| completionStatus | String | SUCCESS, ERROR, IN_PROGRESS |
| transactionStatus | String | RUNNING, COMPLETED, FAILED |
| successOrErrorMessage | String | Error message if failed |
| progressPercentage | Double | 0-100, completion percentage |
| currentStage | String | Current processing stage name |

**Computed Properties (included in responses):**
| Field | Type | Description |
|-------|------|-------------|
| isRunning | Boolean | true if transactionStatus = "RUNNING" |
| isCompleted | Boolean | true if completed successfully |
| hasErrors | Boolean | true if completionStatus = "ERROR" |
| statusMessage | String | User-friendly status description |
| formattedDuration | String | Human-readable duration (e.g., "15 minutes 30 seconds") |

---

### ETLErrorLog

Represents an error log entry from ETL execution.

| Field | Type | Description |
|-------|------|-------------|
| id | Integer | Unique identifier for the error log |
| procedureName | String | Name of the stored procedure that failed |
| errorMessage | String | Detailed error message |
| errorCode | Integer | Database error code |
| sqlState | String | SQL state code |
| errorTime | DateTime | When the error occurred |

---

### ETLSettings

Represents ETL configuration settings.

| Field | Type | Description |
|-------|------|-------------|
| id | Integer | Settings record ID |
| openmrsDatabase | String | Source OpenMRS database name |
| etlDatabase | String | Target ETL database name |
| conceptsLocale | String | Locale for concept translations |
| tablePartitionNumber | Integer | Number of table partitions |
| incrementalModeSwitch | Boolean | Enable incremental ETL mode |
| automaticFlatteningModeSwitch | Boolean | Enable automatic flattening |
| etlIntervalSeconds | Integer | ETL run interval in seconds |
| incrementalModeSwitchCascaded | Boolean | Cascaded incremental mode |
| lastEtlScheduleInsertId | Integer | Last schedule ID |

---

## Common Response Fields

All endpoints return a response with these common fields:

| Field | Type | Description |
|-------|------|-------------|
| success | Boolean | true if request succeeded |
| error | String | Error message (present only when success=false) |

---

## Error Handling

All endpoints return error responses in this format:

```json
{
  "success": false,
  "error": "Error message describing what went wrong"
}
```

**Common Error Scenarios:**
- Invalid parameter values (e.g., negative limit)
- Internal server errors
- Database connection issues

---

## Rate Limiting & Performance

- **Recommended polling interval:** 5-10 seconds for progress/status checks
- **Maximum limit parameters:** Enforced to prevent excessive responses
- **Typical response time:** < 500ms for most endpoints

---

## Usage Examples

### JavaScript/Fetch

```javascript
// Get current ETL progress
async function getETLProgress() {
  const response = await fetch('/openmrs/ws/rest/v1/ugandareportsetl/etl/progress');
  const data = await response.json();
  
  if (data.success) {
    console.log('Progress:', data.progressPercentage + '%');
    console.log('Status:', data.statusMessage);
  } else {
    console.error('Error:', data.error);
  }
}

// Get recent executions
async function getRecentExecutions(limit = 10) {
  const response = await fetch(
    `/openmrs/ws/rest/v1/ugandareportsetl/etl/recent?limit=${limit}`
  );
  return await response.json();
}

// Poll for ETL completion
async function waitForETLCompletion() {
  while (true) {
    const response = await fetch('/openmrs/ws/rest/v1/ugandareportsetl/etl/status');
    const data = await response.json();
    
    if (!data.isRunning) {
      console.log('ETL completed!');
      return data.lastExecution;
    }
    
    await new Promise(resolve => setTimeout(resolve, 5000));
  }
}
```

### cURL

```bash
# Get current ETL progress
curl -X GET 'http://localhost:8080/openmrs/ws/rest/v1/ugandareportsetl/etl/progress' \
  -b 'JSESSIONID=your-session-id'

# Get recent executions
curl -X GET 'http://localhost:8080/openmrs/ws/rest/v1/ugandareportsetl/etl/recent?limit=20' \
  -b 'JSESSIONID=your-session-id'

# Get error logs
curl -X GET 'http://localhost:8080/openmrs/ws/rest/v1/ugandareportsetl/etl/errors?limit=100' \
  -b 'JSESSIONID=your-session-id'

# Get ETL settings
curl -X GET 'http://localhost:8080/openmrs/ws/rest/v1/ugandareportsetl/etl/settings' \
  -b 'JSESSIONID=your-session-id'

# Check ETL status
curl -X GET 'http://localhost:8080/openmrs/ws/rest/v1/ugandareportsetl/etl/status' \
  -b 'JSESSIONID=your-session-id'
```

---

## Notes

- All datetime fields are in ISO 8601 format (UTC)
- All endpoints require valid OpenMRS session authentication
- The module uses Spring MVC (not OpenMRS REST Web Services module) for these endpoints
- For write operations (triggering ETL, updating settings), use the OpenMRS UI or scheduled tasks
